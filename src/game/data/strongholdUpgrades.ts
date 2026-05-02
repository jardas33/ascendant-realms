import type {
  ResourceBag,
  StrongholdUpgradeDefinition,
  StrongholdUpgradeId,
  StrongholdUpgradeEffectDefinition
} from "../core/GameTypes";

export const STRONGHOLD_LAUNCH_MODIFIER_PREFIX = "stronghold:";

export interface StrongholdBattleEffects {
  extraPlayerUnitIds: string[];
  startingResources: Partial<ResourceBag>;
  heroMaxHpMultiplier: number;
  buildingVisionBonus: number;
}

export const STRONGHOLD_UPGRADES: StrongholdUpgradeDefinition[] = [
  {
    id: "training_yard_i",
    name: "Training Yard I",
    description: "Future battles start with one extra Militia near the Command Hall.",
    tier: 1,
    cost: { crowns: 80, iron: 35 },
    prerequisites: {},
    effects: [{ type: "extra-starting-unit", unitId: "militia", count: 1 }],
    maxRank: 1,
    iconKey: "training_yard",
    flavorText: "A ring of trampled earth, sparring posts, and patient veterans turns frightened levies into a line that holds."
  },
  {
    id: "watch_post_i",
    name: "Watch Post I",
    description: "Player buildings reveal more fog in future battles.",
    tier: 1,
    cost: { crowns: 70, stone: 45 },
    prerequisites: {},
    effects: [{ type: "building-vision-bonus", amount: 80 }],
    maxRank: 1,
    iconKey: "watch_post",
    flavorText: "A raised platform and a brass horn give the camp a longer look at trouble before trouble reaches the gate."
  },
  {
    id: "quartermaster_stores_i",
    name: "Quartermaster Stores I",
    description: "Future battles start with +50 Crowns and +30 Stone.",
    tier: 1,
    cost: { crowns: 85, stone: 50 },
    prerequisites: {},
    effects: [{ type: "starting-resources", resources: { crowns: 50, stone: 30 } }],
    maxRank: 1,
    iconKey: "quartermaster_stores",
    flavorText: "Tidy ledgers, dry crates, and a suspiciously cheerful quartermaster make every march begin with fewer empty hands."
  },
  {
    id: "chapel_corner_i",
    name: "Chapel Corner I",
    description: "The hero starts future battles with +5% maximum HP.",
    tier: 1,
    cost: { crowns: 75, aether: 25 },
    prerequisites: {},
    effects: [{ type: "hero-max-hp-multiplier", multiplier: 1.05 }],
    maxRank: 1,
    iconKey: "chapel_corner",
    flavorText: "A canvas awning, a travel-worn altar, and a little quiet before battle help the commander endure the worst of it."
  },
  {
    id: "ranger_paths_i",
    name: "Ranger Paths I",
    description: "Future battles start with one extra Ranger near the Command Hall.",
    tier: 1,
    cost: { crowns: 90, iron: 45 },
    prerequisites: { upgradeRanks: { training_yard_i: 1 } },
    effects: [{ type: "extra-starting-unit", unitId: "ranger", count: 1 }],
    maxRank: 1,
    iconKey: "ranger_paths",
    flavorText: "Marked trails and hidden caches let the scouts arrive before the banners are even unpacked."
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
  return effects;
}

export function createEmptyStrongholdBattleEffects(): StrongholdBattleEffects {
  return {
    extraPlayerUnitIds: [],
    startingResources: {},
    heroMaxHpMultiplier: 1,
    buildingVisionBonus: 0
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
  if (effect.type === "building-vision-bonus") {
    effects.buildingVisionBonus += effect.amount;
  }
}
