import Phaser from "phaser";
import type { BattleMapDefinition, Team } from "../core/GameTypes";
import { CAMPAIGN_MODIFIER_BY_ID, requireBuilding, requireHeroClass, requireOrigin, requireUnit } from "../data/contentIndex";
import { getBattleDifficulty } from "../data/battlePacing";
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
}

export function spawnBattleScenario(options: SpawnBattleScenarioOptions): SpawnBattleScenarioResult {
  const { scene, activeMap, heroSave, launch, addUnit, addBuilding } = options;
  const scenario = activeMap.scenario;
  scenario.buildingSpawns.forEach((spawn) => {
    addBuilding(new Building(scene, requireBuilding(spawn.buildingId), spawn.team, spawn.x, spawn.y));
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
    spawnUnit({ scene, addUnit, unitId: spawn.unitId, team: spawn.team, x: spawn.x, y: spawn.y });
  });
  spawnLaunchModifierUnits({ scene, activeMap, launch, addUnit });

  const captureSites = activeMap.captureSites.map((siteDefinition) => new CaptureSite(scene, siteDefinition));

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
    scene.add
      .text(camp.x, camp.y - 58, camp.name, {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "12px",
        color: "#d7cf9f",
        stroke: "#101511",
        strokeThickness: 4
      })
      .setOrigin(0.5)
      .setDepth(1);
  });

  return { hero, captureSites };
}

function spawnUnit(options: {
  scene: Phaser.Scene;
  addUnit: (unit: Unit) => void;
  unitId: string;
  team: Team;
  x: number;
  y: number;
}): Unit {
  const unit = new Unit(options.scene, requireUnit(options.unitId), options.team, options.x, options.y);
  options.addUnit(unit);
  return unit;
}

function applyHeroLaunchModifiers(hero: Hero, launch: ResolvedBattleLaunch): void {
  const manaMultiplier = launch.request.modifiers.reduce((multiplier, modifier) => {
    const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
    return Math.max(multiplier, definition?.effects.heroManaMultiplier ?? multiplier);
  }, 1);
  const hpMultiplier = launch.request.modifiers.reduce((multiplier, modifier) => {
    const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
    return Math.max(multiplier, definition?.effects.heroMaxHpMultiplier ?? multiplier);
  }, 1);
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
  launch.request.modifiers.forEach((modifier, modifierIndex) => {
    const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
    if (!definition) {
      return;
    }
    definition.effects.extraPlayerUnitIds?.forEach((unitId, index) => {
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
}
