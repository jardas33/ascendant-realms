import type { ItemDefinition, ItemInstance } from "../GameTypes";
import { generateItemAffixIds } from "../../data/itemAffixes";
import type { HeroSaveData } from "../../save/SaveTypes";

export interface CreateItemInstanceOptions {
  item?: ItemDefinition;
  itemById?: Record<string, ItemDefinition>;
  affixes?: string[];
  deterministicAffixes?: boolean;
  rng?: () => number;
}

export function createItemInstance(
  itemId: string,
  source: string,
  acquiredAt = new Date().toISOString(),
  options: CreateItemInstanceOptions = {}
): ItemInstance {
  const item = options.item ?? options.itemById?.[itemId];
  const affixes = options.affixes ?? (item ? generateItemAffixIds(item, { deterministic: options.deterministicAffixes, rng: options.rng }) : []);
  return {
    instanceId: `${sanitizeItemInstancePart(source)}:${sanitizeItemInstancePart(itemId)}:${Date.now().toString(36)}:${Math.random().toString(36).slice(2, 8)}`,
    itemId,
    acquiredAt,
    source,
    affixes: [...new Set(affixes)],
    locked: false,
    favorite: false
  };
}

export function findItemInstance(inventory: ItemInstance[], instanceOrCatalogId: string): ItemInstance | undefined {
  return inventory.find((instance) => instance.instanceId === instanceOrCatalogId) ?? inventory.find((instance) => instance.itemId === instanceOrCatalogId);
}

export function heroOwnsCatalogItem(save: HeroSaveData, itemId: string): boolean {
  return save.inventory.some((instance) => instance.itemId === itemId);
}

function sanitizeItemInstancePart(value: string): string {
  return value.replace(/[^a-zA-Z0-9_-]/g, "_");
}
