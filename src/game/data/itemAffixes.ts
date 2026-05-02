import type { EquipmentSlot, HeroStatMods, ItemAffixDefinition, ItemDefinition, ItemInstance, ItemRarity } from "../core/GameTypes";

export const ITEM_AFFIXES: ItemAffixDefinition[] = [
  {
    id: "sturdy",
    name: "Sturdy",
    tier: "minor",
    allowedSlots: ["armor", "trinket"],
    statMods: { maxHp: 14 },
    tags: ["survival", "hp"],
    weight: 14
  },
  {
    id: "sharp",
    name: "Sharp",
    tier: "minor",
    allowedSlots: ["weapon"],
    statMods: { damage: 2 },
    tags: ["damage", "weapon"],
    weight: 16
  },
  {
    id: "guarding",
    name: "Guarding",
    tier: "minor",
    allowedSlots: ["armor", "trinket"],
    statMods: { armor: 1 },
    tags: ["armor", "defense"],
    weight: 13
  },
  {
    id: "aether_touched",
    name: "Aether-Touched",
    tier: "minor",
    allowedSlots: ["weapon", "armor", "trinket"],
    statMods: { maxMana: 12 },
    tags: ["aether", "mana"],
    weight: 11
  },
  {
    id: "commanding",
    name: "Commanding",
    tier: "minor",
    allowedSlots: ["weapon", "armor", "trinket"],
    statMods: { command: 1 },
    tags: ["command", "army"],
    weight: 9
  },
  {
    id: "faithful",
    name: "Faithful",
    tier: "minor",
    allowedSlots: ["weapon", "armor", "trinket"],
    statMods: { faith: 1 },
    tags: ["faith", "support"],
    weight: 9
  },
  {
    id: "swift",
    name: "Swift",
    tier: "minor",
    allowedSlots: ["weapon", "armor", "trinket"],
    statMods: { speed: 3 },
    tags: ["speed", "mobility"],
    weight: 8
  },
  {
    id: "embered",
    name: "Embered",
    tier: "minor",
    allowedSlots: ["weapon", "trinket"],
    statMods: { damage: 1, arcana: 1 },
    tags: ["magic", "ashen"],
    weight: 6
  },
  {
    id: "rangers",
    name: "Ranger's",
    tier: "minor",
    allowedSlots: ["weapon"],
    statMods: { range: 16 },
    tags: ["ranged", "range"],
    weight: 7
  }
];

export const ITEM_AFFIX_BY_ID: Record<string, ItemAffixDefinition> = Object.fromEntries(ITEM_AFFIXES.map((affix) => [affix.id, affix]));

export interface GenerateItemAffixOptions {
  deterministic?: boolean;
  rng?: () => number;
  count?: number;
}

const DETERMINISTIC_AFFIX_COUNTS: Record<ItemRarity, number> = {
  common: 1,
  uncommon: 1,
  rare: 2,
  epic: 2,
  legendary: 3
};

export function getAffixCountForRarity(rarity: ItemRarity, options: { deterministic?: boolean; rng?: () => number } = {}): number {
  if (options.deterministic) {
    return DETERMINISTIC_AFFIX_COUNTS[rarity];
  }
  const rng = options.rng ?? Math.random;
  switch (rarity) {
    case "common":
      return rng() < 0.45 ? 1 : 0;
    case "uncommon":
      return 1;
    case "rare":
      return rng() < 0.4 ? 2 : 1;
    case "epic":
      return 2;
    case "legendary":
      return rng() < 0.5 ? 3 : 2;
  }
}

export function generateItemAffixIds(item: ItemDefinition, options: GenerateItemAffixOptions = {}): string[] {
  const count = Math.max(0, Math.floor(options.count ?? getAffixCountForRarity(item.rarity, options)));
  if (count <= 0) {
    return [];
  }
  const candidates = ITEM_AFFIXES.filter((affix) => canApplyAffixToSlot(affix, item.slot) && affix.weight > 0);
  if (options.deterministic) {
    return [...candidates]
      .sort((a, b) => b.weight - a.weight || a.id.localeCompare(b.id))
      .slice(0, count)
      .map((affix) => affix.id);
  }

  const picked: string[] = [];
  let remaining = [...candidates];
  for (let index = 0; index < count && remaining.length > 0; index += 1) {
    const affix = pickWeightedAffix(remaining, options.rng ?? Math.random);
    if (!affix) {
      break;
    }
    picked.push(affix.id);
    remaining = remaining.filter((candidate) => candidate.id !== affix.id);
  }
  return picked;
}

export function getItemInstanceAffixes(item: ItemDefinition, instance: ItemInstance): ItemAffixDefinition[] {
  return instance.affixes
    .map((affixId) => ITEM_AFFIX_BY_ID[affixId])
    .filter((affix): affix is ItemAffixDefinition => affix !== undefined && canApplyAffixToSlot(affix, item.slot));
}

export function getItemAffixStatMods(item: ItemDefinition, instance: ItemInstance): HeroStatMods {
  return mergeHeroStatMods(...getItemInstanceAffixes(item, instance).map((affix) => affix.statMods));
}

export function getItemTotalStatMods(item: ItemDefinition, instance: ItemInstance): HeroStatMods {
  return mergeHeroStatMods(item.statMods, getItemAffixStatMods(item, instance));
}

export function canApplyAffixToSlot(affix: ItemAffixDefinition, slot: EquipmentSlot): boolean {
  return affix.allowedSlots.includes(slot);
}

export function isItemAffixId(value: string): boolean {
  return ITEM_AFFIX_BY_ID[value] !== undefined;
}

function pickWeightedAffix(entries: ItemAffixDefinition[], rng: () => number): ItemAffixDefinition | undefined {
  const totalWeight = entries.reduce((total, entry) => total + Math.max(0, entry.weight), 0);
  if (totalWeight <= 0) {
    return undefined;
  }
  let roll = Math.max(0, Math.min(0.999999, rng())) * totalWeight;
  for (const entry of entries) {
    roll -= Math.max(0, entry.weight);
    if (roll <= 0) {
      return entry;
    }
  }
  return entries.at(-1);
}

function mergeHeroStatMods(...modsList: HeroStatMods[]): HeroStatMods {
  const merged: HeroStatMods = {};
  modsList.forEach((mods) => {
    Object.entries(mods).forEach(([key, value]) => {
      if (typeof value === "number") {
        const target = merged as Record<string, number>;
        target[key] = (target[key] ?? 0) + value;
      }
    });
  });
  return merged;
}
