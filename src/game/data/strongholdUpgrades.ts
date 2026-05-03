import type {
  BuildingDefinition,
  CampaignModifierDefinition,
  ResourceBag,
  StrongholdUpgradeDefinition,
  StrongholdUpgradeId,
  StrongholdUpgradeEffectDefinition,
  Team
} from "../core/GameTypes";
import { CAMPAIGN_MODIFIER_BY_ID, isCampaignModifierId } from "./campaignModifiers";

export const STRONGHOLD_LAUNCH_MODIFIER_PREFIX = "stronghold:";

export interface StrongholdBattleEffects {
  extraPlayerUnitIds: string[];
  startingResources: Partial<ResourceBag>;
  heroMaxHpMultiplier: number;
  heroMaxManaMultiplier: number;
  buildingVisionBonus: number;
  enemyWarningLeadSeconds: number;
  watchtowerRangeMultiplier: number;
  firstBuildingConstructionTimeMultiplier: number;
  unitTrainingTimeMultipliers: Partial<Record<string, number>>;
  firstCaptureBonusResourceAdditions: Record<string, Partial<ResourceBag>>;
}

export const STRONGHOLD_UPGRADES: StrongholdUpgradeDefinition[] = [
  {
    id: "training_yard_i",
    name: "Training Yard I",
    description: "Future battles start with +1 Militia near the Command Hall.",
    tier: 1,
    cost: { crowns: 80, iron: 35 },
    prerequisites: {},
    effects: [{ type: "extra-starting-unit", unitId: "militia", count: 1 }],
    maxRank: 1,
    iconKey: "training_yard",
    flavorText: "A ring of trampled earth, sparring posts, and patient veterans turns frightened levies into a line that holds."
  },
  {
    id: "training_yard_ii",
    name: "Training Yard II",
    description: "Future battles drill faster: Militia and Rangers train 10% faster, and Retinue capacity increases by +1.",
    tier: 2,
    cost: { crowns: 70, iron: 35 },
    prerequisites: { upgradeRanks: { training_yard_i: 1 } },
    effects: [
      { type: "unit-training-time-multiplier", unitId: "militia", multiplier: 0.9 },
      { type: "unit-training-time-multiplier", unitId: "ranger", multiplier: 0.9 }
    ],
    maxRank: 1,
    iconKey: "training_yard",
    flavorText: "A second ring, better drill calls, and fewer borrowed spears let the camp turn recruits into a fighting line with less wasted daylight."
  },
  {
    id: "watch_post_i",
    name: "Watch Post I",
    description:
      "Future battles reveal trouble sooner: first-wave warnings arrive 25s earlier, player buildings gain +80 vision, and Watchtowers fire 10% farther.",
    tier: 1,
    cost: { crowns: 70, stone: 45 },
    prerequisites: {},
    effects: [
      { type: "building-vision-bonus", amount: 80 },
      { type: "enemy-wave-warning-lead", seconds: 25 },
      { type: "watchtower-range-multiplier", multiplier: 1.1 }
    ],
    maxRank: 1,
    iconKey: "watch_post",
    flavorText: "A raised platform and a brass horn give the camp a longer look at trouble before trouble reaches the gate."
  },
  {
    id: "watch_post_ii",
    name: "Watch Post II",
    description: "Future battles extend the warning net: first-wave warnings arrive 15s earlier again, and Watchtowers fire 20% farther total.",
    tier: 2,
    cost: { crowns: 95, stone: 55, aether: 25 },
    prerequisites: { upgradeRanks: { watch_post_i: 1 } },
    effects: [
      { type: "enemy-wave-warning-lead", seconds: 15 },
      { type: "watchtower-range-multiplier", multiplier: 1.2 }
    ],
    maxRank: 1,
    iconKey: "watch_post",
    flavorText: "Stone footings, signal lanterns, and better sight-lines turn a watchman into a warning network."
  },
  {
    id: "quartermaster_stores_i",
    name: "Quartermaster Stores I",
    description:
      "Future battles start stocked: +60 Crowns, +40 Stone, +20 Iron, +10 Aether, and the first player building finishes 10% faster.",
    tier: 1,
    cost: { crowns: 85, stone: 50 },
    prerequisites: {},
    effects: [
      { type: "starting-resources", resources: { crowns: 60, stone: 40, iron: 20, aether: 10 } },
      { type: "first-building-construction-time-multiplier", multiplier: 0.9 }
    ],
    maxRank: 1,
    iconKey: "quartermaster_stores",
    flavorText: "Tidy ledgers, dry crates, and a suspiciously cheerful quartermaster make every march begin with fewer empty hands."
  },
  {
    id: "quartermaster_stores_ii",
    name: "Quartermaster Stores II",
    description: "Future battles add a Tier II stockpile: +80 Crowns, +50 Stone, +35 Iron, and +20 Aether.",
    tier: 2,
    cost: { crowns: 105, stone: 55, iron: 35 },
    prerequisites: { upgradeRanks: { quartermaster_stores_i: 1 } },
    effects: [{ type: "starting-resources", resources: { crowns: 80, stone: 50, iron: 35, aether: 20 } }],
    maxRank: 1,
    iconKey: "quartermaster_stores",
    flavorText: "Wax-sealed manifests and hard-won reserve crates make the next march feel planned instead of merely survived."
  },
  {
    id: "chapel_corner_i",
    name: "Chapel Corner I",
    description: "The hero starts future battles with +5% maximum HP and Mana.",
    tier: 1,
    cost: { crowns: 75, aether: 25 },
    prerequisites: {},
    effects: [
      { type: "hero-max-hp-multiplier", multiplier: 1.05 },
      { type: "hero-max-mana-multiplier", multiplier: 1.05 }
    ],
    maxRank: 1,
    iconKey: "chapel_corner",
    flavorText: "A canvas awning, a travel-worn altar, and a little quiet before battle help the commander endure the worst of it."
  },
  {
    id: "chapel_corner_ii",
    name: "Chapel Corner II",
    description: "The hero starts future battles with +8% maximum HP and +8% maximum Mana.",
    tier: 2,
    cost: { crowns: 95, aether: 45 },
    prerequisites: { upgradeRanks: { chapel_corner_i: 1 } },
    effects: [
      { type: "hero-max-hp-multiplier", multiplier: 1.08 },
      { type: "hero-max-mana-multiplier", multiplier: 1.08 }
    ],
    maxRank: 1,
    iconKey: "chapel_corner",
    flavorText: "A consecrated bell and steadier rites give the hero a small reserve of breath and focus when the line begins to buckle."
  },
  {
    id: "ranger_paths_i",
    name: "Ranger Paths I",
    description: "Rangers train 10% faster in future battles.",
    tier: 1,
    cost: { crowns: 90, iron: 40 },
    prerequisites: { upgradeRanks: { training_yard_i: 1 } },
    effects: [{ type: "unit-training-time-multiplier", unitId: "ranger", multiplier: 0.9 }],
    maxRank: 1,
    iconKey: "ranger_paths",
    flavorText: "Marked trails and hidden caches let the scouts arrive before the banners are even unpacked."
  },
  {
    id: "ranger_paths_ii",
    name: "Ranger Paths II",
    description: "Future battles start with +1 Ranger near the Command Hall.",
    tier: 2,
    cost: { crowns: 75, iron: 35 },
    prerequisites: { upgradeRanks: { ranger_paths_i: 1 } },
    effects: [{ type: "extra-starting-unit", unitId: "ranger", count: 1 }],
    maxRank: 1,
    iconKey: "ranger_paths",
    flavorText: "The best trail marks are never written down. By the time the camp forms ranks, one scout is already where they need to be."
  }
];

export const STRONGHOLD_UPGRADE_BY_ID: Record<StrongholdUpgradeId, StrongholdUpgradeDefinition> = Object.fromEntries(
  STRONGHOLD_UPGRADES.map((upgrade) => [upgrade.id, upgrade])
) as Record<StrongholdUpgradeId, StrongholdUpgradeDefinition>;

export function isStrongholdUpgradeId(value: string): value is StrongholdUpgradeId {
  return value in STRONGHOLD_UPGRADE_BY_ID;
}

export function strongholdLaunchModifierId(upgradeId: StrongholdUpgradeId): string {
  return `${STRONGHOLD_LAUNCH_MODIFIER_PREFIX}${upgradeId}`;
}

export function strongholdUpgradeIdFromModifier(modifierId: string): StrongholdUpgradeId | undefined {
  if (!modifierId.startsWith(STRONGHOLD_LAUNCH_MODIFIER_PREFIX)) {
    return undefined;
  }
  const upgradeId = modifierId.slice(STRONGHOLD_LAUNCH_MODIFIER_PREFIX.length);
  return isStrongholdUpgradeId(upgradeId) ? upgradeId : undefined;
}

export function strongholdUpgradeForModifier(modifierId: string): StrongholdUpgradeDefinition | undefined {
  const upgradeId = strongholdUpgradeIdFromModifier(modifierId);
  return upgradeId ? STRONGHOLD_UPGRADE_BY_ID[upgradeId] : undefined;
}

export function getStrongholdBattleEffects(modifiers: Array<{ id: string }>): StrongholdBattleEffects {
  const effects = createEmptyStrongholdBattleEffects();
  modifiers
    .map((modifier) => strongholdUpgradeForModifier(modifier.id))
    .filter((upgrade): upgrade is StrongholdUpgradeDefinition => Boolean(upgrade))
    .forEach((upgrade) => {
      upgrade.effects.forEach((effect) => applyStrongholdEffect(effects, effect));
    });
  modifiers
    .map((modifier) => (isCampaignModifierId(modifier.id) ? CAMPAIGN_MODIFIER_BY_ID[modifier.id] : undefined))
    .filter((modifier): modifier is CampaignModifierDefinition => Boolean(modifier))
    .forEach((modifier) => applyCampaignModifierBattleEffects(effects, modifier));
  return effects;
}

export function createEmptyStrongholdBattleEffects(): StrongholdBattleEffects {
  return {
    extraPlayerUnitIds: [],
    startingResources: {},
    heroMaxHpMultiplier: 1,
    heroMaxManaMultiplier: 1,
    buildingVisionBonus: 0,
    enemyWarningLeadSeconds: 0,
    watchtowerRangeMultiplier: 1,
    firstBuildingConstructionTimeMultiplier: 1,
    unitTrainingTimeMultipliers: {},
    firstCaptureBonusResourceAdditions: {}
  };
}

export function applyStrongholdBuildingEffects(
  definition: BuildingDefinition,
  team: Team,
  effects: Pick<StrongholdBattleEffects, "watchtowerRangeMultiplier">
): BuildingDefinition {
  if (team !== "player" || definition.id !== "watchtower" || !definition.attack || effects.watchtowerRangeMultiplier <= 1) {
    return definition;
  }
  return {
    ...definition,
    attack: {
      ...definition.attack,
      range: Math.round(definition.attack.range * effects.watchtowerRangeMultiplier)
    }
  };
}

function applyStrongholdEffect(effects: StrongholdBattleEffects, effect: StrongholdUpgradeEffectDefinition): void {
  if (effect.type === "extra-starting-unit") {
    for (let index = 0; index < effect.count; index += 1) {
      effects.extraPlayerUnitIds.push(effect.unitId);
    }
    return;
  }
  if (effect.type === "starting-resources") {
    effects.startingResources = {
      crowns: (effects.startingResources.crowns ?? 0) + (effect.resources.crowns ?? 0),
      stone: (effects.startingResources.stone ?? 0) + (effect.resources.stone ?? 0),
      iron: (effects.startingResources.iron ?? 0) + (effect.resources.iron ?? 0),
      aether: (effects.startingResources.aether ?? 0) + (effect.resources.aether ?? 0)
    };
    return;
  }
  if (effect.type === "hero-max-hp-multiplier") {
    effects.heroMaxHpMultiplier = Math.max(effects.heroMaxHpMultiplier, effect.multiplier);
    return;
  }
  if (effect.type === "hero-max-mana-multiplier") {
    effects.heroMaxManaMultiplier = Math.max(effects.heroMaxManaMultiplier, effect.multiplier);
    return;
  }
  if (effect.type === "building-vision-bonus") {
    effects.buildingVisionBonus += effect.amount;
    return;
  }
  if (effect.type === "enemy-wave-warning-lead") {
    effects.enemyWarningLeadSeconds += effect.seconds;
    return;
  }
  if (effect.type === "watchtower-range-multiplier") {
    effects.watchtowerRangeMultiplier = Math.max(effects.watchtowerRangeMultiplier, effect.multiplier);
    return;
  }
  if (effect.type === "first-building-construction-time-multiplier") {
    effects.firstBuildingConstructionTimeMultiplier = Math.min(
      effects.firstBuildingConstructionTimeMultiplier,
      effect.multiplier
    );
    return;
  }
  if (effect.type === "unit-training-time-multiplier") {
    effects.unitTrainingTimeMultipliers = {
      ...effects.unitTrainingTimeMultipliers,
      [effect.unitId]: Math.min(effects.unitTrainingTimeMultipliers[effect.unitId] ?? 1, effect.multiplier)
    };
  }
}

function applyCampaignModifierBattleEffects(effects: StrongholdBattleEffects, modifier: CampaignModifierDefinition): void {
  if (modifier.effects.heroMaxHpMultiplier) {
    effects.heroMaxHpMultiplier = Math.max(effects.heroMaxHpMultiplier, modifier.effects.heroMaxHpMultiplier);
  }
  if (modifier.effects.heroManaMultiplier) {
    effects.heroMaxManaMultiplier = Math.max(effects.heroMaxManaMultiplier, modifier.effects.heroManaMultiplier);
  }
  if (modifier.effects.buildingVisionBonus) {
    effects.buildingVisionBonus += modifier.effects.buildingVisionBonus;
  }
  if (modifier.effects.enemyWarningLeadSeconds) {
    effects.enemyWarningLeadSeconds += modifier.effects.enemyWarningLeadSeconds;
  }
  Object.entries(modifier.effects.firstCaptureBonusResourceAdditions ?? {}).forEach(([siteId, resources]) => {
    const existing = effects.firstCaptureBonusResourceAdditions[siteId] ?? {};
    effects.firstCaptureBonusResourceAdditions[siteId] = {
      crowns: (existing.crowns ?? 0) + (resources.crowns ?? 0),
      stone: (existing.stone ?? 0) + (resources.stone ?? 0),
      iron: (existing.iron ?? 0) + (resources.iron ?? 0),
      aether: (existing.aether ?? 0) + (resources.aether ?? 0)
    };
  });
}
