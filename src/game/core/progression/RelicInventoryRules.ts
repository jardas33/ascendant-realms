import type { ItemDefinition, ItemInstance } from "../GameTypes";
import type { HeroSaveData } from "../../save/SaveTypes";

export interface RelicInventoryState {
  acquiredRelicIds: string[];
  equippedRelicIds: string[];
}

export function getRelicInventoryState(
  hero: HeroSaveData,
  itemById: Record<string, ItemDefinition>
): RelicInventoryState {
  const acquiredRelicIds = [
    ...new Set(
      hero.inventory
        .filter((instance) => itemById[instance.itemId]?.slot === "relic")
        .map((instance) => instance.itemId)
    )
  ];
  const equippedRelicIds = Object.values(hero.equipment)
    .map((instanceId) => hero.inventory.find((instance) => instance.instanceId === instanceId))
    .filter((instance): instance is ItemInstance => Boolean(instance && itemById[instance.itemId]?.slot === "relic"))
    .map((instance) => instance.itemId);

  return {
    acquiredRelicIds,
    equippedRelicIds: [...new Set(equippedRelicIds)]
  };
}

export function heroOwnsRelic(
  hero: HeroSaveData,
  relicItemId: string,
  itemById: Record<string, ItemDefinition>
): boolean {
  return hero.inventory.some((instance) => instance.itemId === relicItemId && itemById[instance.itemId]?.slot === "relic");
}
