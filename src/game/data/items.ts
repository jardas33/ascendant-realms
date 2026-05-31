import type { ItemDefinition } from "../core/GameTypes";

export const ITEMS: ItemDefinition[] = [
  {
    id: "weathered_command_sword",
    name: "Weathered Command Sword",
    slot: "weapon",
    rarity: "common",
    unique: true,
    description: "A plain officer's blade that helps a new hero lead from the front.",
    flavorText: "Its edge is nicked, but the salute it earns is still sharp.",
    factionOrigin: "free_marches",
    classAffinity: ["warlord"],
    tags: ["starter", "melee", "command"],
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
    flavorText: "Hold it near a campfire and the glass remembers every spark.",
    factionOrigin: "free_marches",
    classAffinity: ["arcanist"],
    tags: ["starter", "magic", "mana"],
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
    flavorText: "Every notch marks another village that opened its gate.",
    factionOrigin: "free_marches",
    classAffinity: ["shepherd"],
    tags: ["starter", "support", "faith"],
    statMods: {
      damage: 2,
      maxMana: 12,
      faith: 2
    }
  },
  {
    id: "scouts_bow",
    name: "Scout's Bow",
    slot: "weapon",
    rarity: "uncommon",
    description: "A compact bow for commanders who prefer safer angles.",
    flavorText: "The string is waxed with river reed oil from the eastern crossings.",
    factionOrigin: "free_marches",
    classAffinity: ["warlord", "shepherd"],
    tags: ["ranged", "speed", "utility"],
    statMods: {
      damage: 3,
      range: 24,
      speed: 3,
      command: 1
    }
  },
  {
    id: "marcher_plate",
    name: "Marcher Plate",
    slot: "armor",
    rarity: "uncommon",
    description: "Sturdy armor assembled by Barrosan Freeholds smiths.",
    flavorText: "Every plate is stamped by a town that refused to kneel.",
    factionOrigin: "free_marches",
    classAffinity: ["warlord"],
    tags: ["armor", "frontline", "hp"],
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
    flavorText: "The thread catches on moonlight and old warding words.",
    factionOrigin: "free_marches",
    classAffinity: ["arcanist"],
    tags: ["armor", "magic", "mana"],
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
    flavorText: "Worn thin at the knees from tending the wounded.",
    factionOrigin: "free_marches",
    classAffinity: ["shepherd"],
    tags: ["armor", "support", "faith"],
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
    unique: true,
    description: "A brass seal that turns scattered fighters into a company.",
    flavorText: "Press it into wax and people start standing straighter.",
    factionOrigin: "free_marches",
    classAffinity: ["warlord"],
    tags: ["command", "army", "hp"],
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
    unique: true,
    description: "A focused lens that sharpens spellcraft.",
    flavorText: "Look through it too long and your thoughts gain edges.",
    factionOrigin: "free_marches",
    classAffinity: ["arcanist"],
    tags: ["magic", "mana", "arcana"],
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
    unique: true,
    description: "A small field icon carried by healers and oathbound scouts.",
    flavorText: "It smells faintly of rain, candle smoke, and mended leather.",
    factionOrigin: "free_marches",
    classAffinity: ["shepherd"],
    tags: ["faith", "support", "mana"],
    statMods: {
      faith: 3,
      command: 1,
      maxMana: 16
    }
  },
  {
    id: "fordbreaker_halberd",
    name: "Fordbreaker Halberd",
    slot: "weapon",
    rarity: "rare",
    unique: true,
    description: "A river-guard polearm built to hold a narrow crossing.",
    flavorText: "The haft is scarred where shield lines broke and reformed.",
    factionOrigin: "free_marches",
    classAffinity: ["warlord"],
    tags: ["melee", "range", "broken_ford"],
    statMods: {
      damage: 6,
      range: 12,
      might: 2
    }
  },
  {
    id: "ashbound_censer",
    name: "Ashbound Censer",
    slot: "weapon",
    rarity: "rare",
    unique: true,
    description: "A captured focus that turns grim rites into controlled power.",
    flavorText: "The chain is warm even when the coals have gone dark.",
    factionOrigin: "ashen_covenant",
    classAffinity: ["arcanist", "shepherd"],
    tags: ["magic", "faith", "damage"],
    statMods: {
      damage: 4,
      maxMana: 18,
      arcana: 1,
      faith: 1
    }
  },
  {
    id: "ember_raider_blade",
    name: "Ember Raider Blade",
    slot: "weapon",
    rarity: "rare",
    unique: true,
    description: "A captured raider sword that still carries the rhythm of Gorak Emberhand's charges.",
    flavorText: "The fuller is black with smoke, but the grip is worn by a living hand.",
    factionOrigin: "ashen_covenant",
    classAffinity: ["warlord"],
    tags: ["rival", "melee", "ember"],
    statMods: {
      damage: 5,
      might: 2,
      speed: 2
    }
  },
  {
    id: "cinderseer_lens",
    name: "Cinder-Seer Lens",
    slot: "trinket",
    rarity: "rare",
    unique: true,
    description: "A small aether lens recovered from Veyra of the Cinders after her rites were broken.",
    flavorText: "Its fractures glow brightest when no fire is nearby.",
    factionOrigin: "ashen_covenant",
    classAffinity: ["arcanist", "shepherd"],
    tags: ["rival", "magic", "aether"],
    statMods: {
      arcana: 2,
      maxMana: 24,
      damage: 2
    }
  },
  {
    id: "malrecs_bastion_sigil",
    name: "Malrec's Bastion Sigil",
    slot: "trinket",
    rarity: "epic",
    unique: true,
    description: "A fortress command sigil taken from Captain Malrec's outpost command.",
    flavorText: "It is heavier than a trinket should be, as if part of the wall came with it.",
    factionOrigin: "ashen_covenant",
    classAffinity: ["warlord", "shepherd"],
    tags: ["rival", "command", "milestone"],
    statMods: {
      command: 3,
      armor: 1,
      maxHp: 28
    }
  },
  {
    id: "emberbrand_shard",
    name: "Emberbrand Shard",
    slot: "relic",
    rarity: "rare",
    unique: true,
    description: "A Warrior relic for a direct damage build, turning a rival charge into a measured counterblow.",
    flavorText: "Warm ash clings to it no matter how often it is cleaned.",
    factionOrigin: "ashen_covenant",
    classAffinity: ["warlord"],
    tags: ["rival", "relic", "warrior", "damage", "might"],
    statMods: {
      damage: 2,
      might: 1
    }
  },
  {
    id: "cinderseer_focus",
    name: "Cinder-Seer Focus",
    slot: "relic",
    rarity: "rare",
    unique: true,
    description: "A Seer relic for a mana and ability-support build, steadying spellcraft under pressure.",
    flavorText: "Its fractures glow brightest when the battlefield goes quiet.",
    factionOrigin: "ashen_covenant",
    classAffinity: ["arcanist", "shepherd"],
    tags: ["rival", "relic", "seer", "mana", "arcana"],
    statMods: {
      maxMana: 18,
      arcana: 2
    }
  },
  {
    id: "outpost_command_signet",
    name: "Outpost Command Signet",
    slot: "relic",
    rarity: "epic",
    unique: true,
    description: "A Commander relic for a durable leadership build, holding an Ashen outpost line together.",
    flavorText: "It feels less like jewelry than a piece of the wall.",
    factionOrigin: "ashen_covenant",
    classAffinity: ["warlord", "shepherd"],
    tags: ["rival", "relic", "commander", "hp", "armor", "command"],
    statMods: {
      maxHp: 24,
      armor: 1,
      command: 1
    }
  },
  {
    id: "oathbound_aegis",
    name: "Oathbound Aegis",
    slot: "armor",
    rarity: "epic",
    unique: true,
    description: "A commander cuirass etched with oaths from three lost companies.",
    flavorText: "The names are heavy, but they help carry the living.",
    factionOrigin: "free_marches",
    classAffinity: ["warlord", "shepherd"],
    tags: ["armor", "command", "epic"],
    statMods: {
      maxHp: 54,
      armor: 3,
      command: 2,
      faith: 1
    }
  },
  {
    id: "starfall_prism",
    name: "Starfall Prism",
    slot: "trinket",
    rarity: "epic",
    unique: true,
    description: "A broken prism that hums when spellfire gathers nearby.",
    flavorText: "It has too many reflections for a single room.",
    factionOrigin: "sylvan_concord",
    classAffinity: ["arcanist"],
    tags: ["magic", "mana", "epic"],
    statMods: {
      arcana: 4,
      maxMana: 42,
      attackCooldown: -0.05
    }
  },
  {
    id: "ascendant_signet",
    name: "Ascendant Signet",
    slot: "trinket",
    rarity: "legendary",
    unique: true,
    description: "A rare seal from the first realm-claiming hosts.",
    flavorText: "It does not command loyalty. It reminds people why they offered it.",
    factionOrigin: "free_marches",
    classAffinity: ["warlord", "arcanist", "shepherd"],
    tags: ["legendary", "all-rounder", "command"],
    statMods: {
      maxHp: 32,
      maxMana: 32,
      damage: 3,
      command: 3,
      arcana: 2,
      faith: 2
    }
  }
];
