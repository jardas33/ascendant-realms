import type {
  BattleDifficulty,
  BattleMapDefinition,
  CampaignNodeDefinition,
  CombatStats,
  ResourceBag,
  UnitDefinition
} from "../core/GameTypes";
import { FIRST_MATCH_TUTORIAL_PROTECTION, getBattleDifficulty } from "../data/battlePacing";
import { requireHeroClass, requireOrigin, requireUnit } from "../data/contentIndex";
import type { StrongholdBattleEffects } from "../data/strongholdUpgrades";
import { applyUnitVeterancyStatBonuses, getUnitVeterancyRank } from "../data/unitVeterancy";
import { createFallbackHeroSave } from "../save/SaveDefaults";
import type { HeroSaveData, RetinueUnitSaveData } from "../save/SaveTypes";

export function createPlaytestHeroForNode(nodeId: string): HeroSaveData {
  const hero = createFallbackHeroSave();
  if (nodeId === "border_village") {
    return hero;
  }
  if (nodeId === "old_stone_road") {
    return {
      ...hero,
      xp: 75,
      completedBattles: 1,
      clearedMapIds: ["first_claim"],
      inventory: [{ instanceId: "sim-weathered-sword", itemId: "weathered_command_sword", acquiredAt: "sim", source: "playtest", affixes: [] }]
    };
  }
  if (nodeId === "ashen_outpost") {
    return {
      ...hero,
      level: 3,
      xp: 270,
      skillPoints: 1,
      completedBattles: 4,
      clearedMapIds: ["first_claim", "broken_ford"],
      inventory: [
        { instanceId: "sim-weathered-sword", itemId: "weathered_command_sword", acquiredAt: "sim", source: "playtest", affixes: [] },
        { instanceId: "sim-fordbreaker", itemId: "fordbreaker_halberd", acquiredAt: "sim", source: "playtest", affixes: [] },
        { instanceId: "sim-captains-seal", itemId: "captains_seal", acquiredAt: "sim", source: "playtest", affixes: [] }
      ],
      stats: { ...hero.stats, might: hero.stats.might + 2, command: hero.stats.command + 1 }
    };
  }
  if (nodeId === "cinderfen_crossing" || nodeId === "cinderfen_watch") {
    return {
      ...hero,
      level: 4,
      xp: nodeId === "cinderfen_watch" ? 645 : 520,
      skillPoints: 3,
      completedBattles: nodeId === "cinderfen_watch" ? 6 : 5,
      clearedMapIds:
        nodeId === "cinderfen_watch"
          ? ["first_claim", "broken_ford", "ashen_outpost", "cinderfen_causeway"]
          : ["first_claim", "broken_ford", "ashen_outpost"],
      inventory: [
        { instanceId: "sim-weathered-sword", itemId: "weathered_command_sword", acquiredAt: "sim", source: "playtest", affixes: [] },
        { instanceId: "sim-fordbreaker", itemId: "fordbreaker_halberd", acquiredAt: "sim", source: "playtest", affixes: [] },
        { instanceId: "sim-captains-seal", itemId: "captains_seal", acquiredAt: "sim", source: "playtest", affixes: [] },
        { instanceId: "sim-oathbound-aegis", itemId: "oathbound_aegis", acquiredAt: "sim", source: "playtest", affixes: [] },
        ...(nodeId === "cinderfen_watch"
          ? [{ instanceId: "sim-scouts-bow", itemId: "scouts_bow", acquiredAt: "sim", source: "playtest", affixes: [] }]
          : [])
      ],
      stats: { ...hero.stats, might: hero.stats.might + 3, command: hero.stats.command + 2 }
    };
  }
  return {
    ...hero,
    level: 2,
    xp: 140,
    skillPoints: 1,
    completedBattles: 2,
    clearedMapIds: ["first_claim"],
    inventory: [
      { instanceId: "sim-weathered-sword", itemId: "weathered_command_sword", acquiredAt: "sim", source: "playtest", affixes: [] }
    ],
    stats: { ...hero.stats, might: hero.stats.might + 1 }
  };
}

export function initialPlayerUnits(map: BattleMapDefinition): Record<string, number> {
  return map.scenario.unitSpawns
    .filter((spawn) => spawn.team === "player")
    .reduce<Record<string, number>>((counts, spawn) => {
      counts[spawn.unitId] = (counts[spawn.unitId] ?? 0) + 1;
      return counts;
    }, {});
}

export function initialEnemyArmy(map: BattleMapDefinition, difficulty: BattleDifficulty): string[] {
  const allowed = new Set(getBattleDifficulty(difficulty).enemyStartingUnitSpawnIds);
  return map.scenario.unitSpawns
    .filter((spawn) => spawn.team === "enemy" && allowed.has(spawn.id))
    .map((spawn) => spawn.unitId);
}

export function firstAttackTime(node: CampaignNodeDefinition, firstAttackDelay: number): number {
  if (node.id === "border_village") {
    return Math.max(firstAttackDelay, FIRST_MATCH_TUTORIAL_PROTECTION.firstAttackAllowedAfterSeconds);
  }
  return firstAttackDelay;
}

export function unitStrength(unit: UnitDefinition): number {
  return unitStrengthFromStats(unit.stats);
}

export function unitStrengthFromStats(stats: CombatStats): number {
  const rangeFactor = stats.range >= 120 ? 1.22 : 1;
  return stats.maxHp / 22 + (stats.damage / stats.attackCooldown) * rangeFactor + stats.armor * 1.6;
}

export function retinueStrengthBonusForUnit(unit: RetinueUnitSaveData): number {
  const definition = requireUnit(unit.unitTypeId);
  return Math.max(0, unitStrengthFromStats(applyUnitVeterancyStatBonuses(definition.stats, unit.rank)) - unitStrength(definition));
}

export function heroStrength(hero: HeroSaveData): number {
  const heroClass = requireHeroClass(hero.classId);
  const origin = requireOrigin(hero.originId);
  return (
    heroClass.baseStats.maxHp / 24 +
    heroClass.baseStats.damage / heroClass.baseStats.attackCooldown +
    hero.level * 4 +
    hero.stats.might * 0.8 +
    hero.stats.command * 0.6 +
    (origin.statMods.might ?? 0) * 0.7
  );
}


export function cloneStrongholdBattleEffects(effects: StrongholdBattleEffects): StrongholdBattleEffects {
  return {
    extraPlayerUnitIds: [...effects.extraPlayerUnitIds],
    startingResources: { ...effects.startingResources },
    heroMaxHpMultiplier: effects.heroMaxHpMultiplier,
    heroMaxManaMultiplier: effects.heroMaxManaMultiplier,
    buildingVisionBonus: effects.buildingVisionBonus,
    enemyWarningLeadSeconds: effects.enemyWarningLeadSeconds,
    watchtowerRangeMultiplier: effects.watchtowerRangeMultiplier,
    firstBuildingConstructionTimeMultiplier: effects.firstBuildingConstructionTimeMultiplier,
    unitTrainingTimeMultipliers: { ...effects.unitTrainingTimeMultipliers },
    firstCaptureBonusResourceAdditions: Object.fromEntries(
      Object.entries(effects.firstCaptureBonusResourceAdditions).map(([siteId, resources]) => [siteId, { ...resources }])
    )
  };
}


export function formatResources(resources: Partial<ResourceBag>): string {
  const parts = [
    ["Crowns", resources.crowns ?? 0],
    ["Stone", resources.stone ?? 0],
    ["Iron", resources.iron ?? 0],
    ["Aether", resources.aether ?? 0]
  ] as const;
  const active = parts.filter(([, amount]) => amount > 0);
  return active.length > 0 ? active.map(([label, amount]) => `${amount} ${label}`).join(", ") : "none";
}


export function formatRetinueTelemetry(unit: RetinueUnitSaveData): string {
  return `${getUnitVeterancyRank(unit.rank).name} ${titleCase(unit.unitTypeId)}`;
}


function titleCase(value: string): string {
  return value
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}
