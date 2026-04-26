import type { UpgradeDefinition } from "../core/GameTypes";

export const UPGRADES: UpgradeDefinition[] = [
  {
    id: "infantry_weapons_1",
    name: "Infantry Weapons I",
    description: "Sharpened blades and hafted spearheads raise melee infantry damage.",
    cost: { crowns: 120, iron: 70 },
    researchTimeSeconds: 18,
    prerequisites: { buildingIds: ["command_hall"] },
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
    cost: { crowns: 120, iron: 60 },
    researchTimeSeconds: 20,
    prerequisites: { buildingIds: ["barracks"] },
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
    cost: { crowns: 130, stone: 70, iron: 50 },
    researchTimeSeconds: 22,
    prerequisites: { buildingIds: ["command_hall"] },
    effects: [
      {
        type: "unit-stat-mod",
        unitIds: ["militia", "ranger", "acolyte"],
        armorBonus: 1
      }
    ]
  },
  {
    id: "aether_study_1",
    name: "Aether Study I",
    description: "A simple rite improves Acolyte focus and the hero's mana recovery.",
    cost: { crowns: 100, aether: 90 },
    researchTimeSeconds: 24,
    prerequisites: { buildingIds: ["mystic_lodge"] },
    effects: [
      {
        type: "unit-stat-mod",
        unitIds: ["acolyte"],
        damageMultiplier: 1.1
      },
      {
        type: "hero-mana-regen",
        multiplier: 1.25
      }
    ]
  }
];
