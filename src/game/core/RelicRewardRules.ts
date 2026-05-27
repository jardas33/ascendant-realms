import type { BattleLaunchMode } from "../battle/BattleLaunchRequest";
import { RELIC_REWARD_BY_ENEMY_HERO_ID } from "../data/relicRewards";
import type { ItemDefinition, ItemDuplicateConversion, ItemInstance, RelicRewardDefinition } from "./GameTypes";
import type { HeroSaveData } from "../save/SaveTypes";
import { createItemInstance } from "./progression/AffixRules";
import { createUniqueDuplicateConversion } from "./progression/DuplicateRewardRules";
import { heroOwnsRelic } from "./progression/RelicInventoryRules";

export interface RelicRewardEligibilityInput {
  outcome: "victory" | "defeat";
  mode?: BattleLaunchMode;
  rewardsDisabled?: boolean;
  enemyHeroId?: string;
  enemyHeroDefeated?: boolean;
}

export type RelicRewardAcquisitionStatus = "granted" | "duplicate_converted";

export interface RelicRewardAcquisition {
  definition: RelicRewardDefinition;
  item: ItemDefinition;
  status: RelicRewardAcquisitionStatus;
  itemInstance?: ItemInstance;
  duplicateConversion?: ItemDuplicateConversion;
  inventoryLabel: string;
}

export function selectEligibleRelicRewardDefinition(input: RelicRewardEligibilityInput): RelicRewardDefinition | undefined {
  if (
    input.outcome !== "victory" ||
    input.mode === "tutorial" ||
    input.rewardsDisabled ||
    !input.enemyHeroId ||
    !input.enemyHeroDefeated
  ) {
    return undefined;
  }
  const definition = RELIC_REWARD_BY_ENEMY_HERO_ID[input.enemyHeroId];
  if (!definition) {
    return undefined;
  }
  return definition;
}

export function grantEligibleRelicReward(options: {
  hero: HeroSaveData;
  itemById: Record<string, ItemDefinition>;
  acquiredAt: string;
} & RelicRewardEligibilityInput): { hero: HeroSaveData; relicReward?: RelicRewardAcquisition } {
  const definition = selectEligibleRelicRewardDefinition(options);
  if (!definition) {
    return { hero: options.hero };
  }
  const item = options.itemById[definition.itemId];
  if (!item || item.slot !== "relic") {
    return { hero: options.hero };
  }
  if (heroOwnsRelic(options.hero, item.id, options.itemById)) {
    const duplicateConversion = createUniqueDuplicateConversion(item);
    return {
      hero: options.hero,
      relicReward: {
        definition,
        item,
        status: "duplicate_converted",
        duplicateConversion,
        inventoryLabel: `${item.name} was already in inventory; duplicate converted.`
      }
    };
  }

  const itemInstance = createItemInstance(item.id, `relic_reward:${options.enemyHeroId ?? "unknown"}`, options.acquiredAt, {
    item,
    itemById: options.itemById,
    affixes: []
  });
  return {
    hero: {
      ...options.hero,
      inventory: [...options.hero.inventory, itemInstance]
    },
    relicReward: {
      definition,
      item,
      status: "granted",
      itemInstance,
      inventoryLabel: `${item.name} added to hero inventory.`
    }
  };
}
