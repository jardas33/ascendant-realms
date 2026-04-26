import type { UnitDefinition } from "../core/GameTypes";

export const UNITS: UnitDefinition[] = [
  {
    id: "militia",
    name: "Militia",
    factionId: "free_marches",
    role: "Cheap melee infantry",
    description: "Reliable town guard with spears and stubborn courage.",
    cost: { crowns: 60, iron: 20 },
    trainTime: 4,
    radius: 13,
    color: 0x8fcf91,
    stats: {
      maxHp: 90,
      damage: 9,
      range: 28,
      attackCooldown: 1,
      speed: 90,
      armor: 1
    },
    xpValue: 15
  },
  {
    id: "ranger",
    name: "Ranger",
    factionId: "free_marches",
    role: "Ranged skirmisher",
    description: "A light archer who fights best behind a front line.",
    cost: { crowns: 80, iron: 30 },
    trainTime: 5,
    radius: 12,
    color: 0x6eb5d8,
    projectileColor: 0xc7e8a2,
    stats: {
      maxHp: 65,
      damage: 8,
      range: 160,
      attackCooldown: 1.35,
      speed: 95,
      armor: 0
    },
    xpValue: 20,
    prerequisites: { buildingIds: ["barracks"] }
  },
  {
    id: "acolyte",
    name: "Acolyte",
    factionId: "free_marches",
    role: "Weak magic support",
    description: "A novice ritualist with fragile but useful ranged magic.",
    cost: { crowns: 70, aether: 40 },
    trainTime: 6,
    radius: 12,
    color: 0xb6e6d3,
    projectileColor: 0x8ff7ff,
    stats: {
      maxHp: 55,
      damage: 6,
      range: 140,
      attackCooldown: 1.2,
      speed: 85,
      armor: 0
    },
    xpValue: 20,
    prerequisites: { buildingIds: ["mystic_lodge"] }
  },
  {
    id: "raider",
    name: "Raider",
    factionId: "ashen_covenant",
    role: "Enemy melee attacker",
    description: "Fast enemy infantry that pressures resource sites.",
    cost: { crowns: 55, iron: 20 },
    trainTime: 4,
    radius: 13,
    color: 0xc75f4e,
    stats: {
      maxHp: 85,
      damage: 9,
      range: 28,
      attackCooldown: 1,
      speed: 98,
      armor: 1
    },
    xpValue: 15
  },
  {
    id: "hexer",
    name: "Hexer",
    factionId: "ashen_covenant",
    role: "Enemy ranged magic",
    description: "A brittle caster whose bolts punish clumped troops.",
    cost: { crowns: 75, aether: 35 },
    trainTime: 5,
    radius: 12,
    color: 0xb36ee2,
    projectileColor: 0xdd8cff,
    stats: {
      maxHp: 60,
      damage: 8,
      range: 150,
      attackCooldown: 1.25,
      speed: 88,
      armor: 0
    },
    xpValue: 20
  },
  {
    id: "brute",
    name: "Brute",
    factionId: "ashen_covenant",
    role: "Enemy tank",
    description: "A heavy brawler meant to soak damage during attack waves.",
    cost: { crowns: 110, iron: 50 },
    trainTime: 7,
    radius: 16,
    color: 0x9f4a36,
    stats: {
      maxHp: 160,
      damage: 13,
      range: 30,
      attackCooldown: 1.25,
      speed: 72,
      armor: 3
    },
    xpValue: 30
  },
  {
    id: "enemy_commander",
    name: "Ashen Commander",
    factionId: "ashen_covenant",
    role: "Enemy hero placeholder",
    description: "A dangerous commander who joins larger enemy attacks.",
    cost: {},
    trainTime: 0,
    radius: 18,
    color: 0xf06a43,
    stats: {
      maxHp: 260,
      damage: 16,
      range: 34,
      attackCooldown: 1.1,
      speed: 92,
      armor: 3
    },
    xpValue: 150
  },
  {
    id: "wild_hound",
    name: "Wild Hound",
    factionId: "wilds",
    role: "Neutral fast monster",
    description: "A territorial beast guarding ruins and roads.",
    cost: {},
    trainTime: 0,
    radius: 12,
    color: 0x8f7a54,
    stats: {
      maxHp: 55,
      damage: 7,
      range: 24,
      attackCooldown: 0.9,
      speed: 105,
      armor: 0
    },
    xpValue: 12
  },
  {
    id: "stone_imp",
    name: "Stone Imp",
    factionId: "wilds",
    role: "Neutral tough monster",
    description: "A squat stone creature drawn to old quarries.",
    cost: {},
    trainTime: 0,
    radius: 14,
    color: 0x948a7a,
    stats: {
      maxHp: 85,
      damage: 8,
      range: 26,
      attackCooldown: 1.2,
      speed: 72,
      armor: 2
    },
    xpValue: 18
  }
];
