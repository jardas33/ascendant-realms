import type { EquipmentSlot, HeroBaseStats, ItemDefinition } from "../core/GameTypes";
import { grantRelicRewardChoiceSelection } from "../core/RelicRewardRules";
import { calculateLiveHeroStats, findItemInstance } from "../core/HeroProgressionRules";
import { equipRewardItemNow, type StatDelta } from "../core/ResultsFlow";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import type { HeroSaveData } from "../save/SaveTypes";
import type { ResultsData } from "./ResultsTypes";

export const EQUIPPABLE_SLOTS: EquipmentSlot[] = ["weapon", "armor", "trinket", "relic"];

export interface ResultsEquipActionResult {
  ok: boolean;
  data: ResultsData;
  message: string;
}

export function equipResultsRewardItem(data: ResultsData, itemInstanceId: string): ResultsEquipActionResult {
  const heroClass = HERO_CLASS_BY_ID[data.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
  const origin = ORIGIN_BY_ID[data.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
  const result = equipRewardItemNow({
    hero: data.heroSave,
    itemInstanceId,
    itemById: ITEM_BY_ID,
    heroClass,
    origin,
    skillById: SKILL_NODE_BY_ID
  });
  return {
    ok: result.ok,
    data: result.ok ? { ...data, heroSave: result.hero } : data,
    message: result.message
  };
}

export function keepResultsRewardItem(data: ResultsData, itemInstanceId: string): ResultsEquipActionResult {
  const instance = findItemInstance(data.heroSave.inventory, itemInstanceId);
  const item = instance ? ITEM_BY_ID[instance.itemId] : undefined;
  if (!instance || !item) {
    return {
      ok: false,
      data,
      message: "That reward is no longer in this hero's inventory."
    };
  }
  return {
    ok: true,
    data,
    message: `${item.name} kept in inventory. Open Hero Inventory when you want to equip it.`
  };
}

export function chooseResultsRelicReward(data: ResultsData, relicRewardId: string): ResultsEquipActionResult {
  if (!data.relicRewardChoice) {
    return {
      ok: false,
      data,
      message: "There is no relic choice waiting on this Results screen."
    };
  }
  const result = grantRelicRewardChoiceSelection({
    hero: data.heroSave,
    choice: data.relicRewardChoice,
    relicRewardId,
    itemById: ITEM_BY_ID,
    acquiredAt: new Date().toISOString()
  });
  return {
    ok: result.ok,
    data: result.ok
      ? {
          ...data,
          heroSave: result.hero,
          relicReward: result.relicReward,
          relicRewardChoice: undefined,
          rivalResult: data.rivalResult
            ? {
                ...data.rivalResult,
                relicReward: result.relicReward,
                relicRewardChoice: undefined,
                relicRewardText:
                  result.relicReward?.status === "granted"
                    ? `${result.relicReward.item.name} added to inventory. Relic effects are active when equipped.`
                    : result.message
              }
            : data.rivalResult
        }
      : data,
    message: result.message
  };
}

export function previewEquipDeltas(data: ResultsData, itemInstanceId: string): StatDelta[] {
  const heroClass = HERO_CLASS_BY_ID[data.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
  const origin = ORIGIN_BY_ID[data.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
  return equipRewardItemNow({
    hero: data.heroSave,
    itemInstanceId,
    itemById: ITEM_BY_ID,
    heroClass,
    origin,
    skillById: SKILL_NODE_BY_ID
  }).deltas;
}

export function currentItemInSlot(data: ResultsData, slot: EquipmentSlot): ItemDefinition | undefined {
  const instanceId = data.heroSave.equipment[slot];
  const instance = instanceId ? findItemInstance(data.heroSave.inventory, instanceId) : undefined;
  return instance ? ITEM_BY_ID[instance.itemId] : undefined;
}

export function liveStatsFor(save: HeroSaveData): HeroBaseStats {
  const heroClass = HERO_CLASS_BY_ID[save.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
  const origin = ORIGIN_BY_ID[save.originId] ?? Object.values(ORIGIN_BY_ID)[0];
  return calculateLiveHeroStats(save, heroClass, origin, SKILL_NODE_BY_ID, ITEM_BY_ID);
}

export function heroStatsRows(save: HeroSaveData): Array<[string, number]> {
  const stats = liveStatsFor(save);
  return [
    ["HP", stats.maxHp],
    ["Mana", stats.maxMana],
    ["Damage", stats.damage],
    ["Armor", stats.armor],
    ["Range", stats.range],
    ["Speed", stats.speed],
    ["Might", stats.might],
    ["Command", stats.command],
    ["Arcana", stats.arcana],
    ["Faith", stats.faith]
  ];
}
