import type { BattleLaunchMode } from "../battle/BattleLaunchRequest";
import { RELIC_REWARD_BY_ENEMY_HERO_ID, RELIC_REWARD_DEFINITIONS } from "../data/relicRewards";
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

export interface RelicRewardChoiceOption {
  definition: RelicRewardDefinition;
  item: ItemDefinition;
  sourceMatched: boolean;
  owned: boolean;
}

export interface RelicRewardChoice {
  sourceDefinition: RelicRewardDefinition;
  sourceEnemyHeroId: string;
  sourceLabel: string;
  options: RelicRewardChoiceOption[];
  choiceLabel: string;
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

export function createEligibleRelicRewardChoice(options: {
  hero: HeroSaveData;
  itemById: Record<string, ItemDefinition>;
} & RelicRewardEligibilityInput): { choice?: RelicRewardChoice; duplicateReward?: RelicRewardAcquisition } {
  const sourceDefinition = selectEligibleRelicRewardDefinition(options);
  if (!sourceDefinition) {
    return {};
  }
  const sourceItem = options.itemById[sourceDefinition.itemId];
  if (!sourceItem || sourceItem.slot !== "relic") {
    return {};
  }

  const candidates = RELIC_REWARD_DEFINITIONS.map((definition) => ({
    definition,
    item: options.itemById[definition.itemId],
    sourceMatched: definition.id === sourceDefinition.id,
    owned: heroOwnsRelic(options.hero, definition.itemId, options.itemById)
  })).filter((option): option is RelicRewardChoiceOption => Boolean(option.item && option.item.slot === "relic"));

  const available = candidates.filter((option) => !option.owned);
  if (available.length === 0) {
    return {
      duplicateReward: createDuplicateRelicReward(sourceDefinition, sourceItem)
    };
  }

  const sourceOption = available.find((option) => option.sourceMatched);
  const alternateOptions = available
    .filter((option) => !option.sourceMatched)
    .sort((left, right) => left.definition.name.localeCompare(right.definition.name));
  const choiceOptions = [sourceOption, ...alternateOptions].filter((option): option is RelicRewardChoiceOption => Boolean(option)).slice(0, 2);

  return {
    choice: {
      sourceDefinition,
      sourceEnemyHeroId: sourceDefinition.sourceEnemyHeroId,
      sourceLabel: sourceDefinition.sourceLabel,
      options: choiceOptions,
      choiceLabel:
        choiceOptions.length > 1
          ? "Choose one relic for this hero build."
          : "Confirm this relic for this hero build."
    }
  };
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
  return grantRelicRewardDefinition({
    hero: options.hero,
    definition,
    itemById: options.itemById,
    acquiredAt: options.acquiredAt
  });
}

export function grantRelicRewardChoiceSelection(options: {
  hero: HeroSaveData;
  choice: RelicRewardChoice;
  relicRewardId: string;
  itemById: Record<string, ItemDefinition>;
  acquiredAt: string;
}): { hero: HeroSaveData; relicReward?: RelicRewardAcquisition; message: string; ok: boolean } {
  const selected = options.choice.options.find((option) => option.definition.id === options.relicRewardId);
  if (!selected) {
    return {
      hero: options.hero,
      ok: false,
      message: "That relic choice is no longer available."
    };
  }
  const granted = grantRelicRewardDefinition({
    hero: options.hero,
    definition: selected.definition,
    itemById: options.itemById,
    acquiredAt: options.acquiredAt
  });
  if (!granted.relicReward) {
    return {
      hero: options.hero,
      ok: false,
      message: "That relic could not be added to inventory."
    };
  }
  return {
    hero: granted.hero,
    relicReward: granted.relicReward,
    ok: true,
    message:
      granted.relicReward.status === "granted"
        ? `${granted.relicReward.item.name} chosen for a ${formatRelicBuildArchetype(selected.definition)} build. Relic effects are active when equipped.`
        : `${granted.relicReward.item.name} was already owned, so the duplicate relic converted to resources.`
  };
}

export function grantRelicRewardDefinition(options: {
  hero: HeroSaveData;
  definition: RelicRewardDefinition;
  itemById: Record<string, ItemDefinition>;
  acquiredAt: string;
}): { hero: HeroSaveData; relicReward?: RelicRewardAcquisition } {
  const item = options.itemById[options.definition.itemId];
  if (!item || item.slot !== "relic") {
    return { hero: options.hero };
  }
  if (heroOwnsRelic(options.hero, item.id, options.itemById)) {
    return {
      hero: options.hero,
      relicReward: createDuplicateRelicReward(options.definition, item)
    };
  }

  const itemInstance = createItemInstance(item.id, `relic_reward:${options.definition.sourceEnemyHeroId}`, options.acquiredAt, {
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
      definition: options.definition,
      item,
      status: "granted",
      itemInstance,
      inventoryLabel: `${item.name} added to hero inventory.`
    }
  };
}

export function formatRelicBuildArchetype(definition: RelicRewardDefinition): string {
  switch (definition.buildArchetype) {
    case "warrior":
      return "Warrior";
    case "seer":
      return "Seer";
    case "commander":
      return "Commander";
    default:
      return definition.buildArchetype;
  }
}

function createDuplicateRelicReward(definition: RelicRewardDefinition, item: ItemDefinition): RelicRewardAcquisition {
  const duplicateConversion = createUniqueDuplicateConversion(item);
  return {
    definition,
    item,
    status: "duplicate_converted",
    duplicateConversion,
    inventoryLabel: `${item.name} was already in inventory; duplicate converted.`
  };
}
