import Phaser from "phaser";
import { unitBattleAssetIds } from "../assets/AssetKeys";
import type {
  EntityKind,
  Position,
  Team,
  UnitDefinition,
  EnemyEliteSquadDefinition,
  UnitVeterancyRankId,
  UnitVeterancyState
} from "../core/GameTypes";
import {
  addUnitVeterancyXp,
  createUnitVeterancyState,
  getUnitVeterancyRank
} from "../data/unitVeterancy";
import { DEFAULT_BEHAVIOUR_MODE, type BehaviourMode } from "../systems/BehaviourModeSystem";
import { BaseEntity } from "./BaseEntity";

const PLAYER_MOVE_COMBAT_SUPPRESSION_SECONDS = 1.15;

export interface UnitPatrolRoute {
  origin: Position;
  destination: Position;
  headingTo: "destination" | "origin";
}

export class Unit extends BaseEntity {
  readonly definition: UnitDefinition;
  readonly unitInstanceId: string;
  readonly unitTypeId: string;
  veterancy: UnitVeterancyState;
  retinueUnitId?: string;
  enemyHeroId?: string;
  enemyHeroName?: string;
  enemyHeroTitle?: string;
  enemyEliteSquadId?: string;
  enemyEliteSquadName?: string;
  enemyEliteSquadLabel?: string;
  enemyEliteCounterplay?: string;
  enemyEliteBonusSummary?: string;
  enemyHeroAbilityCooldowns = new Map<string, number>();
  attackTargetId?: string;
  attackTargetLabel?: string;
  moveTarget?: Position;
  attackMove = false;
  patrolRoute?: UnitPatrolRoute;
  activeConstructionSiteId?: string;
  pausedConstructionSiteId?: string;
  activeRepairTargetId?: string;
  pausedRepairTargetId?: string;
  activeResourceSiteId?: string;
  activeResourceSiteLabel?: string;
  behaviourMode: BehaviourMode = DEFAULT_BEHAVIOUR_MODE;
  moveOrderCombatSuppressionSeconds = 0;
  attackCooldownRemaining = 0;
  damageBuffMultiplier = 1;
  damageBuffRemaining = 0;
  armorBuffBonus = 0;
  armorBuffRemaining = 0;
  upgradeDamageMultiplier = 1;
  eliteDamageMultiplier = 1;
  upgradeRangeMultiplier = 1;
  upgradeAttackCooldownMultiplier = 1;
  veterancyDamageMultiplier = 1;
  factionSpeedMultiplier = 1;
  veterancyArmorBonus = 0;
  readonly appliedUpgradeIds = new Set<string>();

  private body?: Phaser.GameObjects.Arc;
  private sprite?: Phaser.GameObjects.Image;

  constructor(
    scene: Phaser.Scene,
    definition: UnitDefinition,
    team: Team,
    x: number,
    y: number,
    options: { id?: string; kind?: Extract<EntityKind, "unit" | "hero"> } = {}
  ) {
    super({
      id: options.id,
      kind: options.kind ?? "unit",
      team,
      x,
      y,
      radius: definition.radius,
      maxHp: definition.stats.maxHp,
      armor: definition.stats.armor
    });
    this.definition = definition;
    this.unitInstanceId = this.id;
    this.unitTypeId = definition.id;
    this.veterancy = createUnitVeterancyState(this.id, definition.id);
    const isHero = options.kind === "hero";
    this.createCommonView(scene, definition.name, this.healthColorForTeam(), true);
    const layout = this.addBattleView(scene, options.kind ?? "unit");
    const selectionRadius = Math.max(this.radius + 7, isHero ? 23 : 20);
    this.configureCommonViewLayout({
      healthBarY: layout.visualTop - (isHero ? 13 : 11),
      healthBarWidth: isHero ? 56 : 42,
      healthBarHeight: isHero ? 6 : 5,
      labelY: layout.visualBottom + 7,
      selectionRadius,
      selectionWidth: selectionRadius * (isHero ? 2.35 : 2.15),
      selectionHeight: Math.max(9, selectionRadius * (isHero ? 0.62 : 0.56)),
      selectionY: layout.visualBottom + 0.5
    });
    this.setSelectionRingLayer(1);
  }

  get speed(): number {
    return this.definition.stats.speed * this.factionSpeedMultiplier;
  }

  get damage(): number {
    return (
      this.definition.stats.damage *
      (this.damageBuffMultiplier ?? 1) *
      (this.upgradeDamageMultiplier ?? 1) *
      (this.eliteDamageMultiplier ?? 1) *
      (this.veterancyDamageMultiplier ?? 1)
    );
  }

  get range(): number {
    return this.definition.stats.range * this.upgradeRangeMultiplier;
  }

  get attackCooldown(): number {
    return this.definition.stats.attackCooldown * this.upgradeAttackCooldownMultiplier;
  }

  commandMove(target: Position, attackMove = false, options: { preservePatrol?: boolean } = {}): void {
    if (!options.preservePatrol) {
      this.clearPatrolRoute();
    }
    this.pauseConstructionWork();
    this.pauseRepairWork();
    this.clearResourceSiteWork();
    this.moveTarget = { ...target };
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = attackMove;
    this.moveOrderCombatSuppressionSeconds = attackMove ? 0 : PLAYER_MOVE_COMBAT_SUPPRESSION_SECONDS;
  }

  commandAttack(targetId: string, targetLabel?: string): void {
    this.clearPatrolRoute();
    this.pauseConstructionWork();
    this.pauseRepairWork();
    this.clearResourceSiteWork();
    this.attackTargetId = targetId;
    this.attackTargetLabel = targetLabel;
    this.attackMove = true;
    this.moveOrderCombatSuppressionSeconds = 0;
  }

  commandStop(): void {
    this.clearPatrolRoute();
    this.pauseConstructionWork();
    this.pauseRepairWork();
    this.clearResourceSiteWork();
    this.moveTarget = undefined;
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = false;
    this.moveOrderCombatSuppressionSeconds = 0;
  }

  commandConstructionMove(target: Position, siteId: string): void {
    this.clearPatrolRoute();
    this.pauseRepairWork();
    this.clearResourceSiteWork();
    this.activeConstructionSiteId = siteId;
    this.pausedConstructionSiteId = undefined;
    this.moveTarget = { ...target };
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = false;
  }

  markConstructionWork(siteId: string): void {
    this.pauseRepairWork();
    this.clearResourceSiteWork();
    this.activeConstructionSiteId = siteId;
    this.pausedConstructionSiteId = undefined;
  }

  commandRepairMove(target: Position, repairTargetId: string): void {
    this.clearPatrolRoute();
    this.pauseConstructionWork();
    this.clearResourceSiteWork();
    this.activeRepairTargetId = repairTargetId;
    this.pausedRepairTargetId = undefined;
    this.moveTarget = { ...target };
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = false;
  }

  markRepairWork(repairTargetId: string): void {
    this.pauseConstructionWork();
    this.clearResourceSiteWork();
    this.activeRepairTargetId = repairTargetId;
    this.pausedRepairTargetId = undefined;
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = false;
  }

  clearRepairWork(repairTargetId?: string): void {
    if (!repairTargetId || this.activeRepairTargetId === repairTargetId) {
      this.activeRepairTargetId = undefined;
    }
    if (!repairTargetId || this.pausedRepairTargetId === repairTargetId) {
      this.pausedRepairTargetId = undefined;
    }
  }

  commandResourceSiteMove(target: Position, siteId: string, siteLabel: string): void {
    this.clearPatrolRoute();
    this.pauseConstructionWork();
    this.pauseRepairWork();
    this.activeResourceSiteId = siteId;
    this.activeResourceSiteLabel = siteLabel;
    this.moveTarget = { ...target };
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = false;
    this.moveOrderCombatSuppressionSeconds = 0;
  }

  commandPatrol(destination: Position): void {
    this.pauseConstructionWork();
    this.pauseRepairWork();
    this.clearResourceSiteWork();
    this.patrolRoute = {
      origin: { ...this.position },
      destination: { ...destination },
      headingTo: "destination"
    };
    this.moveTarget = { ...destination };
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = true;
    this.moveOrderCombatSuppressionSeconds = 0;
  }

  advancePatrolRoute(): boolean {
    if (!this.patrolRoute) {
      return false;
    }
    this.patrolRoute.headingTo = this.patrolRoute.headingTo === "destination" ? "origin" : "destination";
    this.resumePatrolRoute();
    return true;
  }

  resumePatrolRoute(): boolean {
    if (!this.patrolRoute || this.moveTarget || this.attackTargetId) {
      return false;
    }
    const target = this.patrolRoute.headingTo === "destination" ? this.patrolRoute.destination : this.patrolRoute.origin;
    this.commandMove(target, true, { preservePatrol: true });
    return true;
  }

  clearPatrolRoute(): void {
    this.patrolRoute = undefined;
  }

  applyEnemyEliteSquad(squad: EnemyEliteSquadDefinition): void {
    if (this.team !== "enemy") {
      return;
    }
    this.enemyEliteSquadId = squad.id;
    this.enemyEliteSquadName = squad.name;
    this.enemyEliteSquadLabel = squad.shortLabel;
    this.enemyEliteCounterplay = squad.counterplay;
    this.enemyEliteBonusSummary = `+${Math.round((squad.maxHpMultiplier - 1) * 100)}% HP, +${Math.round(
      (squad.damageMultiplier - 1) * 100
    )}% damage${squad.armorBonus > 0 ? `, +${squad.armorBonus} armor` : ""}`;
    const hpRatio = this.maxHp > 0 ? this.hp / this.maxHp : 1;
    this.maxHp = Math.round(this.maxHp * squad.maxHpMultiplier);
    this.hp = Math.max(1, Math.round(this.maxHp * hpRatio));
    this.armor += squad.armorBonus;
    this.eliteDamageMultiplier = Math.max(this.eliteDamageMultiplier, squad.damageMultiplier);
    this.label?.setText(`${squad.shortLabel} ${this.definition.name}`);
    this.label?.setColor("#ffd27a");
    this.updateHealthBar();
  }

  markResourceSiteWork(siteId: string, siteLabel: string): void {
    this.pauseConstructionWork();
    this.pauseRepairWork();
    this.activeResourceSiteId = siteId;
    this.activeResourceSiteLabel = siteLabel;
    this.attackTargetId = undefined;
    this.attackTargetLabel = undefined;
    this.attackMove = false;
    this.moveOrderCombatSuppressionSeconds = 0;
  }

  clearResourceSiteWork(siteId?: string): void {
    if (!siteId || this.activeResourceSiteId === siteId) {
      this.activeResourceSiteId = undefined;
      this.activeResourceSiteLabel = undefined;
    }
  }

  private pauseConstructionWork(): void {
    if (this.activeConstructionSiteId) {
      this.pausedConstructionSiteId = this.activeConstructionSiteId;
    }
    this.activeConstructionSiteId = undefined;
  }

  private pauseRepairWork(): void {
    if (this.activeRepairTargetId) {
      this.pausedRepairTargetId = this.activeRepairTargetId;
    }
    this.activeRepairTargetId = undefined;
  }

  applyDamageBuff(multiplier: number, duration: number): void {
    this.damageBuffMultiplier = Math.max(this.damageBuffMultiplier, multiplier);
    this.damageBuffRemaining = Math.max(this.damageBuffRemaining, duration);
    this.body?.setStrokeStyle(3, 0xffdf75, 1);
    this.sprite?.setTint(0xffe59a);
  }

  applyArmorBuff(bonus: number, duration: number): void {
    const nextBonus = Math.max(0, Math.round(bonus));
    if (nextBonus > this.armorBuffBonus) {
      this.armor += nextBonus - this.armorBuffBonus;
      this.armorBuffBonus = nextBonus;
    }
    this.armorBuffRemaining = Math.max(this.armorBuffRemaining, duration);
    this.body?.setStrokeStyle(3, 0xb9d7ff, 1);
    this.sprite?.setTint(0xc8ddff);
  }

  addVeterancyXp(amount: number): ReturnType<typeof addUnitVeterancyXp> {
    const result = addUnitVeterancyXp(this.veterancy, amount);
    this.veterancy = result.state;
    if (result.rankedUp) {
      this.applyVeterancyRank(result.currentRank.id);
    }
    return result;
  }

  applyVeterancyRank(rankId: UnitVeterancyRankId): void {
    const rank = getUnitVeterancyRank(rankId);
    const currentHpRatio = this.maxHp > 0 ? this.hp / this.maxHp : 1;
    const nextMaxHp = Math.round(this.definition.stats.maxHp * rank.maxHpMultiplier);
    const armorDelta = rank.armorBonus - this.veterancyArmorBonus;

    this.maxHp = nextMaxHp;
    this.hp = Math.max(1, Math.min(this.maxHp, Math.round(this.maxHp * currentHpRatio)));
    this.armor += armorDelta;
    this.veterancyArmorBonus = rank.armorBonus;
    this.veterancyDamageMultiplier = rank.damageMultiplier;
    this.veterancy = {
      ...this.veterancy,
      rank: rank.id
    };
    this.updateHealthBar();
  }

  updateBuffs(deltaSeconds: number): void {
    if (this.damageBuffRemaining > 0) {
      this.damageBuffRemaining -= deltaSeconds;
      if (this.damageBuffRemaining <= 0) {
        this.damageBuffMultiplier = 1;
        if (this.armorBuffRemaining <= 0) {
          this.body?.setStrokeStyle(2, 0x172019, 0.9);
          this.sprite?.clearTint();
        }
      }
    }
    if (this.armorBuffRemaining > 0) {
      this.armorBuffRemaining -= deltaSeconds;
      if (this.armorBuffRemaining <= 0) {
        this.armor -= this.armorBuffBonus;
        this.armorBuffBonus = 0;
        if (this.damageBuffRemaining <= 0) {
          this.body?.setStrokeStyle(2, 0x172019, 0.9);
          this.sprite?.clearTint();
        }
      }
    }
  }

  private addBattleView(
    scene: Phaser.Scene,
    kind: Extract<EntityKind, "unit" | "hero">
  ): { visualTop: number; visualBottom: number } {
    const assetId = unitBattleAssetIds(this.definition.id).find((candidate) => scene.textures.exists(candidate));
    const shadow = scene.add.ellipse(0, this.radius * 0.58, this.radius * 2.5, this.radius * 0.72, 0x000000, 0.32);
    this.view?.addAt(shadow, 0);

    if (assetId) {
      const spriteY = this.radius * 0.1;
      const originY = 0.8;
      this.sprite = scene.add.image(0, spriteY, assetId).setOrigin(0.5, originY);
      const targetHeight = kind === "hero" ? this.radius * 4.35 : this.radius * 3.65;
      const sourceHeight = Math.max(1, this.sprite.height);
      this.sprite.setScale(targetHeight / sourceHeight);
      this.sprite.setDepth(1);
      this.view?.addAt(this.sprite, 1);
      return {
        visualTop: spriteY - targetHeight * originY,
        visualBottom: Math.max(this.radius * 0.95, spriteY + targetHeight * (1 - originY))
      };
    }

    this.body = scene.add.circle(0, 0, this.radius, this.definition.color, 0.95).setStrokeStyle(2, 0x172019, 0.9);
    this.view?.addAt(this.body, 1);
    return {
      visualTop: -this.radius,
      visualBottom: this.radius
    };
  }

  private healthColorForTeam(): number {
    if (this.team === "player") {
      return 0x78dc7b;
    }
    if (this.team === "enemy") {
      return 0xe15e55;
    }
    return 0xd2bb72;
  }
}
