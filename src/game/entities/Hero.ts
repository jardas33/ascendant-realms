import Phaser from "phaser";
import type { HeroClassDefinition, ItemInstance, OriginDefinition, UnitDefinition } from "../core/GameTypes";
import type { HeroSaveData } from "../save/SaveTypes";
import { ABILITY_BY_ID, ITEM_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { HERO_HP_PER_LEVEL, HERO_MANA_PER_LEVEL, LEVEL_XP_THRESHOLDS } from "../core/Constants";
import { calculateLiveHeroStats, getUnlockedAbilityIds } from "../core/HeroProgressionRules";
import { applyLevelProgression } from "../core/Progression";
import { Unit } from "./Unit";

export class Hero extends Unit {
  readonly heroName: string;
  readonly classId: string;
  readonly originId: string;
  readonly primaryAbilityId: string;
  level: number;
  xp: number;
  skillPoints: number;
  maxMana: number;
  mana: number;
  might: number;
  command: number;
  arcana: number;
  faith: number;
  unlockedAbilities: string[];
  completedBattles: number;
  clearedMapIds: string[];
  manaRegenMultiplier = 1;
  inventory: ItemInstance[];
  equipment: HeroSaveData["equipment"];
  allocatedSkills: HeroSaveData["allocatedSkills"];
  factionReputation: Record<string, number>;
  abilityCooldowns: Record<string, number> = {};

  constructor(
    scene: Phaser.Scene,
    save: HeroSaveData,
    heroClass: HeroClassDefinition,
    origin: OriginDefinition,
    x: number,
    y: number
  ) {
    const stats = calculateLiveHeroStats(save, heroClass, origin, SKILL_NODE_BY_ID, ITEM_BY_ID);
    const definition: UnitDefinition = {
      id: `hero_${heroClass.id}`,
      name: save.heroName,
      factionId: "free_marches",
      role: `${heroClass.name} hero`,
      description: heroClass.description,
      cost: {},
      trainTime: 0,
      radius: 19,
      color: heroClass.color,
      visionRadius: heroClass.visionRadius,
      projectileColor: heroClass.id === "arcanist" ? 0xff8b3d : undefined,
      stats: {
        maxHp: stats.maxHp,
        damage: stats.damage,
        armor: stats.armor,
        speed: stats.speed,
        range: stats.range,
        attackCooldown: stats.attackCooldown
      },
      xpValue: 150
    };

    super(scene, definition, "player", x, y, { id: "hero-player", kind: "hero" });
    this.heroName = save.heroName;
    this.classId = heroClass.id;
    this.originId = origin.id;
    this.primaryAbilityId = heroClass.primaryAbilityId;
    this.level = save.level;
    this.xp = save.xp;
    this.skillPoints = save.skillPoints;
    this.maxMana = stats.maxMana;
    this.mana = this.maxMana;
    this.might = stats.might;
    this.command = stats.command;
    this.arcana = stats.arcana;
    this.faith = stats.faith;
    this.unlockedAbilities = getUnlockedAbilityIds(save, heroClass, SKILL_NODE_BY_ID);
    this.completedBattles = save.completedBattles;
    this.clearedMapIds = [...save.clearedMapIds];
    this.inventory = [...save.inventory];
    this.equipment = { ...save.equipment };
    this.allocatedSkills = { ...save.allocatedSkills };
    this.factionReputation = { ...save.factionReputation };
    this.view?.setDepth(12);
  }

  addXp(amount: number): { leveledUp: boolean; levelsGained: number } {
    const previousLevel = this.level;
    this.xp += amount;
    const result = applyLevelProgression({
      previousLevel,
      xp: this.xp,
      skillPoints: this.skillPoints,
      maxHp: this.maxHp,
      maxMana: this.maxMana,
      thresholds: LEVEL_XP_THRESHOLDS,
      hpPerLevel: HERO_HP_PER_LEVEL,
      manaPerLevel: HERO_MANA_PER_LEVEL
    });

    if (result.leveledUp) {
      this.level = result.level;
      this.skillPoints = result.skillPoints;
      this.maxHp = result.maxHp;
      this.hp = this.maxHp;
      this.maxMana = result.maxMana;
      this.mana = this.maxMana;
      this.updateHealthBar();
      return { leveledUp: true, levelsGained: result.levelsGained };
    }

    return { leveledUp: false, levelsGained: 0 };
  }

  tickCooldowns(deltaSeconds: number): void {
    Object.keys(this.abilityCooldowns).forEach((abilityId) => {
      this.abilityCooldowns[abilityId] = Math.max(0, this.abilityCooldowns[abilityId] - deltaSeconds);
    });
    this.mana = Math.min(this.maxMana, this.mana + deltaSeconds * 1.5 * this.manaRegenMultiplier);
  }

  toSaveData(): HeroSaveData {
    const ability = ABILITY_BY_ID[this.primaryAbilityId];
    const unlocked = new Set(this.unlockedAbilities);
    if (ability) {
      unlocked.add(ability.id);
    }

    return {
      heroName: this.heroName,
      classId: this.classId,
      originId: this.originId,
      level: this.level,
      xp: this.xp,
      skillPoints: this.skillPoints,
      unlockedAbilities: [...unlocked],
      completedBattles: this.completedBattles,
      clearedMapIds: [...this.clearedMapIds],
      inventory: [...this.inventory],
      equipment: { ...this.equipment },
      allocatedSkills: { ...this.allocatedSkills },
      factionReputation: { ...this.factionReputation },
      stats: {
        might: this.might,
        command: this.command,
        arcana: this.arcana,
        faith: this.faith
      }
    };
  }
}
