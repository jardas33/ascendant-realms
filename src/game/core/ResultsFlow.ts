import type {
  BattleStats,
  EquipmentSlot,
  HeroBaseStats,
  HeroClassDefinition,
  ItemDefinition,
  OriginDefinition,
  SkillNodeDefinition
} from "./GameTypes";
import { calculateLiveHeroStats, equipItem, findItemInstance, saveWithRecalculatedStats } from "./HeroProgressionRules";
import type { HeroSaveData } from "../save/SaveTypes";
import type { ItemInstance } from "./GameTypes";

export const RESULT_STAT_COMPARE_KEYS: Array<keyof HeroBaseStats> = [
  "maxHp",
  "maxMana",
  "damage",
  "armor",
  "range",
  "attackCooldown",
  "speed",
  "might",
  "command",
  "arcana",
  "faith"
];

export type RewardItemState = "new" | "duplicate" | "already_owned";

export interface RewardItemPresentation {
  item: ItemDefinition;
  instance?: ItemInstance;
  state: RewardItemState;
  occurrence: number;
}

export interface StatDelta {
  key: keyof HeroBaseStats;
  before: number;
  after: number;
  delta: number;
}

export interface EquipRewardItemResult {
  ok: boolean;
  hero: HeroSaveData;
  message: string;
  slot?: EquipmentSlot;
  previousItem?: ItemDefinition;
  equippedItem?: ItemDefinition;
  deltas: StatDelta[];
}

export function buildRewardItemPresentations(options: {
  itemIds: string[];
  itemInstances?: ItemInstance[];
  itemById: Record<string, ItemDefinition>;
  startingInventory: ItemInstance[];
  alreadyPresentedIds?: string[];
}): RewardItemPresentation[] {
  const seen = new Set(options.alreadyPresentedIds ?? []);
  const startingCatalogIds = new Set(options.startingInventory.map((instance) => instance.itemId));
  const instancesByItemId = new Map<string, ItemInstance[]>();
  (options.itemInstances ?? []).forEach((instance) => {
    instancesByItemId.set(instance.itemId, [...(instancesByItemId.get(instance.itemId) ?? []), instance]);
  });
  return options.itemIds
    .reduce<RewardItemPresentation[]>((presentations, itemId, index) => {
      const item = options.itemById[itemId];
      if (!item) {
        return presentations;
      }
      const duplicate = seen.has(itemId);
      seen.add(itemId);
      const instance = instancesByItemId.get(itemId)?.shift();
      presentations.push({
        item,
        instance,
        occurrence: index + 1,
        state: duplicate ? "duplicate" : startingCatalogIds.has(itemId) && !instance ? "already_owned" : "new"
      });
      return presentations;
    }, []);
}

export function equipRewardItemNow(options: {
  hero: HeroSaveData;
  itemInstanceId: string;
  itemById: Record<string, ItemDefinition>;
  heroClass: HeroClassDefinition;
  origin: OriginDefinition;
  skillById: Record<string, SkillNodeDefinition>;
}): EquipRewardItemResult {
  const instance = findItemInstance(options.hero.inventory, options.itemInstanceId);
  const item = instance ? options.itemById[instance.itemId] : undefined;
  if (!instance || !item) {
    return {
      ok: false,
      hero: options.hero,
      message: "Unknown item.",
      deltas: []
    };
  }

  const beforeStats = calculateLiveHeroStats(options.hero, options.heroClass, options.origin, options.skillById, options.itemById);
  const previousInstance = options.hero.equipment[item.slot] ? findItemInstance(options.hero.inventory, options.hero.equipment[item.slot]!) : undefined;
  const previousItem = previousInstance ? options.itemById[previousInstance.itemId] : undefined;
  const equipped = equipItem(options.hero, instance.instanceId, options.itemById);
  if (!equipped.ok) {
    return {
      ok: false,
      hero: options.hero,
      message: equipped.message,
      slot: item.slot,
      previousItem,
      equippedItem: item,
      deltas: []
    };
  }

  const hero = saveWithRecalculatedStats(equipped.hero, options.heroClass, options.origin, options.skillById, options.itemById);
  const afterStats = calculateLiveHeroStats(hero, options.heroClass, options.origin, options.skillById, options.itemById);
  return {
    ok: true,
    hero,
    message: previousItem ? `${item.name} equipped, replacing ${previousItem.name}.` : `${item.name} equipped.`,
    slot: item.slot,
    previousItem,
    equippedItem: item,
    deltas: calculateStatDeltas(beforeStats, afterStats)
  };
}

export function calculateStatDeltas(before: HeroBaseStats, after: HeroBaseStats): StatDelta[] {
  return RESULT_STAT_COMPARE_KEYS.map((key) => ({
    key,
    before: roundStat(before[key]),
    after: roundStat(after[key]),
    delta: roundStat(after[key] - before[key])
  })).filter((delta) => delta.delta !== 0);
}

export function createDefeatTips(
  stats: BattleStats,
  options: { hero?: HeroSaveData; mapId?: string; campaignNodeId?: string } = {}
): string[] {
  const tips: string[] = [];
  addObjectiveDefeatTips(stats, options, tips);
  if (stats.resourcesCaptured === 0) {
    tips.push("Capture the Crown Shrine early so your economy starts before the first wave.");
  }
  if (!stats.builtBuildingIds.includes("barracks")) {
    tips.push("Build a Barracks from the Command Hall, then let construction finish before queueing troops.");
  }
  const trainedArmyUnits = stats.trainedUnitIds.filter((unitId) => unitId === "militia" || unitId === "ranger").length;
  if (trainedArmyUnits < 2) {
    tips.push("Queue Militia first, then add Rangers once you can afford a longer fight.");
  }
  if (options.hero && hasUnequippedItems(options.hero)) {
    tips.push("Open Hero Inventory and equip rewards from earlier victories before retrying.");
  }
  if (stats.timeSeconds < 180) {
    tips.push("Drop to Story or Easy while learning the opening; Normal becomes dangerous after the tutorial window.");
  }
  tips.push("Use hero abilities during the first wave and retreat wounded heroes or troops toward the Command Hall.");
  return [...new Set(tips)].slice(0, 4);
}

function addObjectiveDefeatTips(
  stats: BattleStats,
  options: { mapId?: string; campaignNodeId?: string },
  tips: string[]
): void {
  const isAshenOutpost = options.mapId === "ashen_outpost" || options.campaignNodeId === "ashen_outpost";
  if (!isAshenOutpost) {
    return;
  }

  if (!stats.completedObjectiveIds.includes("capture_burned_shrine")) {
    tips.push("On Ashen Outpost, capture Burned Shrine before the final attack; it weakens the gate Watchtower.");
    return;
  }
  if (!stats.completedObjectiveIds.includes("destroy_enemy_barracks")) {
    tips.push("After Burned Shrine, destroy Enemy Barracks before burning down the Stronghold.");
    return;
  }
  if (!stats.completedObjectiveIds.includes("defeat_outpost_captain")) {
    tips.push("Save hero abilities for the Outpost Captain once the shrine and barracks objectives are secure.");
  }
}

export function rewardStateLabel(state: RewardItemState): string {
  if (state === "duplicate") {
    return "Duplicate reward";
  }
  if (state === "already_owned") {
    return "Already owned";
  }
  return "New";
}

function roundStat(value: number): number {
  return Math.round(value * 100) / 100;
}

function hasUnequippedItems(hero: HeroSaveData): boolean {
  const equipped = new Set(Object.values(hero.equipment).filter((instanceId): instanceId is string => typeof instanceId === "string"));
  return hero.inventory.some((instance) => !equipped.has(instance.instanceId));
}
