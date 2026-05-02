import type { ItemDefinition, ItemDuplicateConversion } from "../GameTypes";

export function createUniqueDuplicateConversion(item: ItemDefinition): ItemDuplicateConversion {
  const highRarity = item.rarity === "rare" || item.rarity === "epic" || item.rarity === "legendary";
  const amountByRarity: Record<ItemDefinition["rarity"], number> = {
    common: 40,
    uncommon: 70,
    rare: 25,
    epic: 45,
    legendary: 75
  };
  return {
    itemId: item.id,
    reason: "unique_duplicate",
    resources: highRarity
      ? { aether: amountByRarity[item.rarity] }
      : { crowns: amountByRarity[item.rarity] }
  };
}
