import type { HeroClassDefinition } from "../core/GameTypes";

export const HERO_CLASSES: HeroClassDefinition[] = [
  {
    id: "warlord",
    name: "Warlord",
    description: "A strong melee commander who makes nearby soldiers hit harder.",
    primaryAbilityId: "rally_banner",
    abilityIds: ["rally_banner", "cleave", "war_cry"],
    color: 0xe2b34b,
    visionRadius: 540,
    baseStats: {
      maxHp: 260,
      maxMana: 60,
      damage: 18,
      armor: 4,
      speed: 110,
      range: 34,
      attackCooldown: 1.1,
      might: 8,
      command: 8,
      arcana: 2,
      faith: 3
    }
  },
  {
    id: "arcanist",
    name: "Arcanist",
    description: "A magic damage specialist who burns priority targets.",
    primaryAbilityId: "firebolt",
    abilityIds: ["firebolt", "arcane_burst", "blink"],
    color: 0xf07d3c,
    visionRadius: 560,
    baseStats: {
      maxHp: 160,
      maxMana: 180,
      damage: 10,
      armor: 1,
      speed: 105,
      range: 150,
      attackCooldown: 1.25,
      might: 2,
      command: 4,
      arcana: 10,
      faith: 4
    }
  },
  {
    id: "shepherd",
    name: "Shepherd",
    description: "A healer and holy commander who keeps a small force alive.",
    primaryAbilityId: "heal",
    abilityIds: ["heal", "blessing", "sanctify_ground"],
    color: 0x8ed98f,
    visionRadius: 540,
    baseStats: {
      maxHp: 200,
      maxMana: 130,
      damage: 12,
      armor: 2,
      speed: 105,
      range: 120,
      attackCooldown: 1.2,
      might: 3,
      command: 6,
      arcana: 4,
      faith: 10
    }
  }
];
