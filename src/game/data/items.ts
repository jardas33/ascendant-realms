import type { ItemDefinition } from "../core/GameTypes";

export const ITEMS: ItemDefinition[] = [
  {
    id: "weathered_command_sword",
    name: "Weathered Command Sword",
    slot: "weapon",
    rarity: "common",
    description: "A plain officer's blade that helps a new hero lead from the front.",
    statMods: {
      damage: 4,
      might: 1,
      command: 1
    }
  },
  {
    id: "emberglass_wand",
    name: "Emberglass Wand",
    slot: "weapon",
    rarity: "common",
    description: "A warm crystal focus favored by battlefield arcanists.",
    statMods: {
      damage: 2,
      maxMana: 20,
      arcana: 2
    }
  },
  {
    id: "pilgrim_crook",
    name: "Pilgrim Crook",
    slot: "weapon",
    rarity: "common",
    description: "A humble staff marked with roadside blessings.",
    statMods: {
      damage: 2,
      maxMana: 12,
      faith: 2
    }
  },
  {
    id: "marcher_plate",
    name: "Marcher Plate",
    slot: "armor",
    rarity: "uncommon",
    description: "Sturdy armor assembled by Free Marches smiths.",
    statMods: {
      maxHp: 36,
      armor: 2,
      speed: -4
    }
  },
  {
    id: "runewoven_robes",
    name: "Runewoven Robes",
    slot: "armor",
    rarity: "uncommon",
    description: "Light robes stitched with simple protection sigils.",
    statMods: {
      maxHp: 18,
      maxMana: 28,
      armor: 1,
      arcana: 1
    }
  },
  {
    id: "dawnward_vestments",
    name: "Dawnward Vestments",
    slot: "armor",
    rarity: "uncommon",
    description: "Traveler's vestments that steady the hand and heart.",
    statMods: {
      maxHp: 24,
      armor: 1,
      faith: 2
    }
  },
  {
    id: "captains_seal",
    name: "Captain's Seal",
    slot: "trinket",
    rarity: "rare",
    description: "A brass seal that turns scattered fighters into a company.",
    statMods: {
      command: 3,
      maxHp: 16
    }
  },
  {
    id: "aether_lens",
    name: "Aether Lens",
    slot: "trinket",
    rarity: "rare",
    description: "A focused lens that sharpens spellcraft.",
    statMods: {
      arcana: 3,
      maxMana: 30
    }
  },
  {
    id: "green_chapel_icon",
    name: "Green Chapel Icon",
    slot: "trinket",
    rarity: "rare",
    description: "A small field icon carried by healers and oathbound scouts.",
    statMods: {
      faith: 3,
      command: 1,
      maxMana: 16
    }
  }
];
