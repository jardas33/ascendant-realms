import type {
  CampaignNodeChoiceDefinition,
  CampaignNodeDefinition,
  CampaignChoiceRewardDefinition,
  Cost,
  ResourceBag
} from "../core/GameTypes";
import type { HeroSaveData } from "../save/SaveTypes";

export const TRACKED_REPUTATION_FACTION_IDS = [
  "free_marches",
  "common_folk",
  "old_faith",
  "ashen_covenant",
  "sylvan_concord"
] as const;

export type ReputationFactionId = (typeof TRACKED_REPUTATION_FACTION_IDS)[number];
export type ReputationRankId = "hostile" | "disliked" | "neutral" | "friendly" | "honored";

export interface ReputationRankDefinition {
  id: ReputationRankId;
  label: string;
  description: string;
}

export type ReputationEffectDefinition =
  | {
      id: "common_folk_friendly_services";
      factionId: "common_folk";
      requiredRank: "friendly";
      name: string;
      description: string;
      effects: [{ type: "town-choice-cost-multiplier"; nodeIds: string[]; multiplier: number }];
    }
  | {
      id: "free_marches_friendly_stronghold";
      factionId: "free_marches";
      requiredRank: "friendly";
      name: string;
      description: string;
      effects: [{ type: "stronghold-crown-cost-multiplier"; multiplier: number }];
    }
  | {
      id: "old_faith_friendly_chapel";
      factionId: "old_faith";
      requiredRank: "friendly";
      name: string;
      description: string;
      effects: [{ type: "chapel-aether-bonus"; nodeIds: string[]; amount: number }];
    }
  | {
      id: "ashen_covenant_hostile_pressure";
      factionId: "ashen_covenant";
      requiredRank: "hostile";
      name: string;
      description: string;
      effects: [{ type: "ashen-hostile-pressure"; modifierId: "ashen_hostile_pressure" }];
    };

export const REPUTATION_RANKS: Record<ReputationRankId, ReputationRankDefinition> = {
  hostile: {
    id: "hostile",
    label: "Hostile",
    description: "At -50 or lower; this faction acts against the campaign."
  },
  disliked: {
    id: "disliked",
    label: "Disliked",
    description: "At -25 or lower; this faction distrusts the campaign."
  },
  neutral: {
    id: "neutral",
    label: "Neutral",
    description: "Between -24 and +24; no reputation effect is active."
  },
  friendly: {
    id: "friendly",
    label: "Friendly",
    description: "At +25 or higher; this faction offers small campaign support."
  },
  honored: {
    id: "honored",
    label: "Honored",
    description: "At +50 or higher; this faction strongly supports the campaign."
  }
};

export const REPUTATION_THRESHOLDS = {
  friendly: 25,
  honored: 50,
  disliked: -25,
  hostile: -50
} as const;

export const ASHEN_HOSTILE_PRESSURE_MODIFIER_ID = "ashen_hostile_pressure";

export const REPUTATION_EFFECTS: ReputationEffectDefinition[] = [
  {
    id: "common_folk_friendly_services",
    factionId: "common_folk",
    requiredRank: "friendly",
    name: "Roadside Favors",
    description: "Marcher Camp services cost 10% fewer resources.",
    effects: [{ type: "town-choice-cost-multiplier", nodeIds: ["marcher_camp"], multiplier: 0.9 }]
  },
  {
    id: "free_marches_friendly_stronghold",
    factionId: "free_marches",
    requiredRank: "friendly",
    name: "Marcher Contracts",
    description: "Stronghold upgrades cost 10% fewer Crowns.",
    effects: [{ type: "stronghold-crown-cost-multiplier", multiplier: 0.9 }]
  },
  {
    id: "old_faith_friendly_chapel",
    factionId: "old_faith",
    requiredRank: "friendly",
    name: "Green Chapel Rites",
    description: "Chapel choices with Aether rewards grant +5 Aether.",
    effects: [{ type: "chapel-aether-bonus", nodeIds: ["chapel_of_the_marches"], amount: 5 }]
  },
  {
    id: "ashen_covenant_hostile_pressure",
    factionId: "ashen_covenant",
    requiredRank: "hostile",
    name: "Marked by Ash",
    description: "Ashen Covenant battles start with one extra Raider.",
    effects: [{ type: "ashen-hostile-pressure", modifierId: ASHEN_HOSTILE_PRESSURE_MODIFIER_ID }]
  }
];

export function getReputationRank(value: number): ReputationRankDefinition {
  const normalized = Math.round(value);
  if (normalized <= REPUTATION_THRESHOLDS.hostile) {
    return REPUTATION_RANKS.hostile;
  }
  if (normalized <= REPUTATION_THRESHOLDS.disliked) {
    return REPUTATION_RANKS.disliked;
  }
  if (normalized >= REPUTATION_THRESHOLDS.honored) {
    return REPUTATION_RANKS.honored;
  }
  if (normalized >= REPUTATION_THRESHOLDS.friendly) {
    return REPUTATION_RANKS.friendly;
  }
  return REPUTATION_RANKS.neutral;
}

export function getFactionReputationValue(hero: HeroSaveData, factionId: string): number {
  return Math.round(hero.factionReputation[factionId] ?? 0);
}

export function getActiveReputationEffects(hero: HeroSaveData): ReputationEffectDefinition[] {
  return REPUTATION_EFFECTS.filter((effect) =>
    isReputationEffectActive(effect, getFactionReputationValue(hero, effect.factionId))
  );
}

export function getAdjustedCampaignChoiceCost(options: {
  hero: HeroSaveData;
  node: CampaignNodeDefinition;
  choice: CampaignNodeChoiceDefinition;
}): Partial<ResourceBag> {
  const multiplier = getActiveReputationEffects(options.hero).reduce((current, reputationEffect) => {
    const townEffect = reputationEffect.effects.find((effect) => effect.type === "town-choice-cost-multiplier");
    if (!townEffect || !townEffect.nodeIds.includes(options.node.id)) {
      return current;
    }
    return Math.min(current, townEffect.multiplier);
  }, 1);
  return multiplyResources(options.choice.costs ?? {}, multiplier);
}

export function getAdjustedCampaignChoiceRewards(options: {
  hero: HeroSaveData;
  node: CampaignNodeDefinition;
  choice: CampaignNodeChoiceDefinition;
}): CampaignChoiceRewardDefinition | undefined {
  const rewards = options.choice.rewards;
  if (!rewards) {
    return undefined;
  }
  const aetherBonus = getActiveReputationEffects(options.hero).reduce((total, reputationEffect) => {
    const chapelEffect = reputationEffect.effects.find((effect) => effect.type === "chapel-aether-bonus");
    if (!chapelEffect || !chapelEffect.nodeIds.includes(options.node.id)) {
      return total;
    }
    return total + chapelEffect.amount;
  }, 0);
  const baseAether = rewards.resources?.aether ?? 0;
  if (aetherBonus <= 0 || baseAether <= 0) {
    return rewards;
  }
  return {
    ...rewards,
    resources: {
      ...(rewards.resources ?? {}),
      aether: baseAether + aetherBonus
    }
  };
}

export function getAdjustedStrongholdUpgradeCost(cost: Cost, hero?: HeroSaveData): Cost {
  if (!hero) {
    return { ...cost };
  }
  const multiplier = getActiveReputationEffects(hero).reduce((current, reputationEffect) => {
    const strongholdEffect = reputationEffect.effects.find((effect) => effect.type === "stronghold-crown-cost-multiplier");
    return strongholdEffect ? Math.min(current, strongholdEffect.multiplier) : current;
  }, 1);
  if (multiplier >= 1 || cost.crowns === undefined) {
    return { ...cost };
  }
  return {
    ...cost,
    crowns: Math.max(0, Math.floor(cost.crowns * multiplier))
  };
}

export function getReputationBattleLaunchModifiers(hero: HeroSaveData, node: CampaignNodeDefinition): Array<{ id: string }> {
  return getActiveReputationEffects(hero).flatMap((reputationEffect) =>
    reputationEffect.effects.flatMap((effect) => {
      if (effect.type !== "ashen-hostile-pressure" || node.enemyFactionId !== "ashen_covenant") {
        return [];
      }
      return [{ id: effect.modifierId }];
    })
  );
}

export function formatReputationValue(value: number): string {
  return `${value > 0 ? "+" : ""}${value}`;
}

function isReputationEffectActive(effect: ReputationEffectDefinition, value: number): boolean {
  if (effect.requiredRank === "hostile") {
    return value <= REPUTATION_THRESHOLDS.hostile;
  }
  return value >= REPUTATION_THRESHOLDS.friendly;
}

function multiplyResources(resources: Partial<ResourceBag>, multiplier: number): Partial<ResourceBag> {
  if (multiplier >= 1) {
    return { ...resources };
  }
  return Object.fromEntries(
    Object.entries(resources).map(([resource, amount]) => [resource, Math.max(0, Math.floor((amount ?? 0) * multiplier))])
  ) as Partial<ResourceBag>;
}
