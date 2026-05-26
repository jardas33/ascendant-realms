import type { UpgradeDefinition } from "../core/GameTypes";

export const UPGRADES: UpgradeDefinition[] = [
  {
    id: "camp_foundations_1",
    name: "Camp Foundations I",
    description: "Masons reinforce the Command Hall footings so the base hub survives early pressure a little longer.",
    ownerBuildingId: "command_hall",
    category: "core",
    tier: 1,
    cost: { crowns: 90, stone: 70 },
    researchTimeSeconds: 18,
    prerequisites: { buildingIds: ["command_hall"] },
    effectSummary: "Base hub: +1 armor.",
    effects: [
      {
        type: "building-stat-mod",
        buildingIds: ["command_hall", "enemy_stronghold"],
        armorBonus: 1
      }
    ]
  },
  {
    id: "infantry_weapons_1",
    name: "Infantry Weapons I",
    description: "Sharpened blades and hafted spearheads raise melee infantry damage.",
    ownerBuildingId: "barracks",
    category: "infantry",
    tier: 1,
    cost: { crowns: 120, iron: 70 },
    researchTimeSeconds: 18,
    prerequisites: { buildingIds: ["barracks"] },
    effectSummary: "Militia and Raiders: +10% damage.",
    effects: [
      {
        type: "unit-stat-mod",
        unitIds: ["militia", "raider"],
        damageMultiplier: 1.1
      }
    ]
  },
  {
    id: "ranger_training_1",
    name: "Ranger Training I",
    description: "Field drills improve ranger draw speed and effective range.",
    ownerBuildingId: "barracks",
    category: "ranger",
    tier: 1,
    cost: { crowns: 120, iron: 60 },
    researchTimeSeconds: 20,
    prerequisites: { buildingIds: ["barracks"] },
    effectSummary: "Rangers: +10% range and -10% attack cooldown.",
    effects: [
      {
        type: "unit-stat-mod",
        unitIds: ["ranger"],
        rangeMultiplier: 1.1,
        attackCooldownMultiplier: 0.9
      }
    ]
  },
  {
    id: "reinforced_armor_1",
    name: "Reinforced Armor I",
    description: "Better buckles and shield facings give basic troops more staying power.",
    ownerBuildingId: "barracks",
    category: "infantry",
    tier: 1,
    cost: { crowns: 130, stone: 70, iron: 50 },
    researchTimeSeconds: 22,
    prerequisites: { buildingIds: ["barracks"] },
    effectSummary: "Basic troops and Ashen squads: +1 armor.",
    effects: [
      {
        type: "unit-stat-mod",
        unitIds: ["militia", "ranger", "acolyte", "raider", "hexer", "brute"],
        armorBonus: 1
      }
    ]
  },
  {
    id: "aether_study_1",
    name: "Aether Study I",
    description: "A simple rite improves Acolyte focus and the hero's mana recovery.",
    ownerBuildingId: "mystic_lodge",
    category: "aether",
    tier: 1,
    cost: { crowns: 100, aether: 90 },
    researchTimeSeconds: 24,
    prerequisites: { buildingIds: ["mystic_lodge"] },
    effectSummary: "Acolytes and Hexers: +10% damage; hero: +25% mana regen.",
    effects: [
      {
        type: "unit-stat-mod",
        unitIds: ["acolyte", "hexer"],
        damageMultiplier: 1.1
      },
      {
        type: "hero-mana-regen",
        multiplier: 1.25
      }
    ]
  },
  {
    id: "sentry_bracing_1",
    name: "Sentry Bracing I",
    description: "Carpenters brace Watchtower platforms after the camp foundations are secured.",
    ownerBuildingId: "watchtower",
    category: "defense",
    tier: 1,
    cost: { crowns: 90, stone: 80, iron: 40 },
    researchTimeSeconds: 20,
    prerequisites: { buildingIds: ["watchtower"], upgradeIds: ["camp_foundations_1"] },
    effectSummary: "Watchtowers: +1 armor.",
    effects: [
      {
        type: "building-stat-mod",
        buildingIds: ["watchtower"],
        armorBonus: 1
      }
    ]
  },
  {
    id: "ember_blades_trait",
    name: "Ember Blades",
    description: "Ashen raiders carry ember-treated weapons. This is currently represented by faction traits rather than player research.",
    ownerBuildingId: "enemy_barracks",
    category: "faction_trait",
    tier: 1,
    cost: {},
    researchTimeSeconds: 0,
    prerequisites: { buildingIds: ["enemy_barracks"] },
    effectSummary: "Raiders: +5% damage through Ashen faction traits.",
    effects: [
      {
        type: "unit-stat-mod",
        unitIds: ["raider"],
        damageMultiplier: 1.05
      }
    ]
  }
];
