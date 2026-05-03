import Phaser from "phaser";
import type { BattleMapDefinition, Position, Team } from "../core/GameTypes";
import { applyRivalModifiersToEnemyHeroStats } from "../core/RivalRules";
import { CAMPAIGN_MODIFIER_BY_ID, requireBuilding, requireHeroClass, requireOrigin, requireUnit } from "../data/contentIndex";
import { getBattleDifficulty } from "../data/battlePacing";
import { createEnemyHeroUnitDefinition, ENEMY_HERO_BY_ID } from "../data/enemyHeroes";
import { applyStrongholdBuildingEffects, getStrongholdBattleEffects } from "../data/strongholdUpgrades";
import { createUnitVeterancyState } from "../data/unitVeterancy";
import { Building } from "../entities/Building";
import { CaptureSite } from "../entities/CaptureSite";
import { Hero } from "../entities/Hero";
import { Unit } from "../entities/Unit";
import type { HeroSaveData } from "../save/SaveTypes";
import type { ResolvedBattleLaunch } from "./BattleLaunchRequest";

interface SpawnBattleScenarioOptions {
  scene: Phaser.Scene;
  activeMap: BattleMapDefinition;
  heroSave: HeroSaveData;
  launch: ResolvedBattleLaunch;
  addUnit: (unit: Unit) => void;
  addBuilding: (building: Building) => void;
}

export interface SpawnBattleScenarioResult {
  hero: Hero;
  captureSites: CaptureSite[];
  neutralCampLabels: NeutralCampLabel[];
}

export interface NeutralCampLabel {
  id: string;
  position: Position;
  label: Phaser.GameObjects.Text;
}

export function spawnBattleScenario(options: SpawnBattleScenarioOptions): SpawnBattleScenarioResult {
  const { scene, activeMap, heroSave, launch, addUnit, addBuilding } = options;
  const scenario = activeMap.scenario;
  const strongholdEffects = getStrongholdBattleEffects(launch.request.modifiers);
  scenario.buildingSpawns.forEach((spawn) => {
    addBuilding(
      new Building(
        scene,
        applyStrongholdBuildingEffects(requireBuilding(spawn.buildingId), spawn.team, strongholdEffects),
        spawn.team,
        spawn.x,
        spawn.y
      )
    );
  });

  const heroClass = requireHeroClass(heroSave.classId);
  const origin = requireOrigin(heroSave.originId);
  const hero = new Hero(scene, heroSave, heroClass, origin, scenario.heroSpawn.x, scenario.heroSpawn.y);
  addUnit(hero);
  applyHeroLaunchModifiers(hero, launch);

  const difficulty = getBattleDifficulty(launch.request.difficulty);
  const enemyStartingSpawns = new Set(difficulty.enemyStartingUnitSpawnIds);
  scenario.unitSpawns.forEach((spawn) => {
    if (spawn.team === "enemy" && !enemyStartingSpawns.has(spawn.id)) {
      return;
    }
    spawnUnit({
      scene,
      addUnit,
      unitId: spawn.unitId,
      team: spawn.team,
      x: spawn.x,
      y: spawn.y,
      enemyHeroId: spawn.team === "enemy" && spawn.unitId === "enemy_commander" ? launch.request.enemyHeroId : undefined,
      modifiers: launch.request.modifiers
    });
  });
  spawnLaunchModifierUnits({ scene, activeMap, launch, addUnit });
  spawnRetinueUnits({ scene, activeMap, launch, addUnit });

  const captureSites = activeMap.captureSites.map((siteDefinition) => new CaptureSite(scene, siteDefinition));

  const neutralCampLabels: NeutralCampLabel[] = [];
  activeMap.neutralCamps.forEach((camp) => {
    camp.unitIds.forEach((unitId, index) => {
      const angle = index * 2.1;
      spawnUnit({
        scene,
        addUnit,
        unitId,
        team: "neutral",
        x: camp.x + Math.cos(angle) * 34,
        y: camp.y + Math.sin(angle) * 34
      });
    });
    const label = scene.add
      .text(camp.x, camp.y - 58, camp.name, {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "12px",
        color: "#d7cf9f",
        stroke: "#101511",
        strokeThickness: 4
      })
      .setOrigin(0.5)
      .setDepth(1);
    neutralCampLabels.push({
      id: camp.id,
      position: { x: camp.x, y: camp.y },
      label
    });
  });

  return { hero, captureSites, neutralCampLabels };
}

function spawnUnit(options: {
  scene: Phaser.Scene;
  addUnit: (unit: Unit) => void;
  unitId: string;
  team: Team;
  x: number;
  y: number;
  id?: string;
  enemyHeroId?: string;
  modifiers?: ResolvedBattleLaunch["request"]["modifiers"];
}): Unit {
  const baseDefinition = requireUnit(options.unitId);
  const enemyHero = options.enemyHeroId ? ENEMY_HERO_BY_ID[options.enemyHeroId] : undefined;
  const adjustedEnemyHero = enemyHero
    ? {
        ...enemyHero,
        stats: applyRivalModifiersToEnemyHeroStats(enemyHero.stats, options.modifiers)
      }
    : undefined;
  const unit = new Unit(
    options.scene,
    adjustedEnemyHero ? createEnemyHeroUnitDefinition(adjustedEnemyHero, baseDefinition) : baseDefinition,
    options.team,
    options.x,
    options.y,
    { id: options.id }
  );
  if (enemyHero) {
    unit.enemyHeroId = enemyHero.id;
    unit.enemyHeroName = enemyHero.name;
    unit.enemyHeroTitle = enemyHero.title;
  }
  options.addUnit(unit);
  return unit;
}

function applyHeroLaunchModifiers(hero: Hero, launch: ResolvedBattleLaunch): void {
  const strongholdEffects = getStrongholdBattleEffects(launch.request.modifiers);
  const manaMultiplier = launch.request.modifiers.reduce((multiplier, modifier) => {
    const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
    return Math.max(multiplier, definition?.effects.heroManaMultiplier ?? multiplier);
  }, strongholdEffects.heroMaxManaMultiplier);
  const hpMultiplier = launch.request.modifiers.reduce((multiplier, modifier) => {
    const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
    return Math.max(multiplier, definition?.effects.heroMaxHpMultiplier ?? multiplier);
  }, strongholdEffects.heroMaxHpMultiplier);
  if (hpMultiplier > 1) {
    hero.maxHp = Math.round(hero.maxHp * hpMultiplier);
    hero.hp = hero.maxHp;
    hero.updateHealthBar();
  }
  if (manaMultiplier > 1) {
    hero.maxMana = Math.round(hero.maxMana * manaMultiplier);
    hero.mana = hero.maxMana;
  }
}

function spawnLaunchModifierUnits(options: {
  scene: Phaser.Scene;
  activeMap: BattleMapDefinition;
  launch: ResolvedBattleLaunch;
  addUnit: (unit: Unit) => void;
}): void {
  const { scene, activeMap, launch, addUnit } = options;
  let playerExtraCount = 0;
  launch.request.modifiers.forEach((modifier, modifierIndex) => {
    const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
    if (!definition) {
      return;
    }
    definition.effects.extraPlayerUnitIds?.forEach((unitId, index) => {
      playerExtraCount += 1;
      spawnUnit({
        scene,
        addUnit,
        unitId,
        team: "player",
        x: activeMap.playerStart.x + 92 + index * 34,
        y: activeMap.playerStart.y + 72 + modifierIndex * 24
      });
    });
    definition.effects.extraEnemyUnitIds?.forEach((unitId, index) => {
      spawnUnit({
        scene,
        addUnit,
        unitId,
        team: "enemy",
        x: activeMap.enemyStart.x - 92 - index * 34,
        y: activeMap.enemyStart.y + 72 + modifierIndex * 24
      });
    });
  });
  getStrongholdBattleEffects(launch.request.modifiers).extraPlayerUnitIds.forEach((unitId, index) => {
    spawnUnit({
      scene,
      addUnit,
      unitId,
      team: "player",
      x: activeMap.playerStart.x + 92 + (playerExtraCount + index) * 34,
      y: activeMap.playerStart.y + 96
    });
  });
}

function spawnRetinueUnits(options: {
  scene: Phaser.Scene;
  activeMap: BattleMapDefinition;
  launch: ResolvedBattleLaunch;
  addUnit: (unit: Unit) => void;
}): void {
  if (options.launch.request.mode !== "campaign_node") {
    return;
  }
  options.launch.request.retinueUnits?.forEach((retinueUnit, index) => {
    const unit = spawnUnit({
      scene: options.scene,
      addUnit: options.addUnit,
      unitId: retinueUnit.unitTypeId,
      team: "player",
      x: options.activeMap.playerStart.x + 92 + index * 34,
      y: options.activeMap.playerStart.y + 132,
      id: retinueUnit.retinueUnitId
    });
    unit.retinueUnitId = retinueUnit.retinueUnitId;
    unit.veterancy = {
      ...createUnitVeterancyState(retinueUnit.retinueUnitId, retinueUnit.unitTypeId, retinueUnit.xp),
      rank: retinueUnit.rank,
      kills: retinueUnit.kills
    };
    unit.applyVeterancyRank(retinueUnit.rank);
  });
}
