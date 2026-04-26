import type { CampaignNodeDefinition } from "../core/GameTypes";

export const CAMPAIGN_NODES: CampaignNodeDefinition[] = [
  {
    id: "border_village",
    name: "Border Village",
    description: "A Free Marches village is holding against Ashen raiders. Secure the settlement and prove your banner can protect the frontier.",
    nodeType: "battle",
    difficulty: "easy",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    prerequisites: [],
    rewards: {
      xp: 35,
      resources: { crowns: 50 },
      itemIds: ["weathered_command_sword"]
    },
    unlocks: ["old_stone_road"],
    x: 12,
    y: 66
  },
  {
    id: "old_stone_road",
    name: "Old Stone Road",
    description: "The old trade road links every nearby claim. Clear the patrol route before the enemy turns it into an invasion lane.",
    nodeType: "battle",
    difficulty: "easy",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    prerequisites: ["border_village"],
    rewards: {
      xp: 40,
      resources: { crowns: 45, stone: 35 }
    },
    unlocks: ["aether_well_ruins", "bandit_hillfort"],
    x: 30,
    y: 52
  },
  {
    id: "aether_well_ruins",
    name: "Aether Well Ruins",
    description: "A broken well still leaks power under the stones. Claim it before Ashen hexers bind the site for war.",
    nodeType: "battle",
    difficulty: "normal",
    mapId: "broken_ford",
    enemyFactionId: "ashen_covenant",
    prerequisites: ["old_stone_road"],
    rewards: {
      xp: 50,
      resources: { aether: 45 },
      itemIds: ["aether_lens"]
    },
    unlocks: ["chapel_of_the_marches"],
    x: 52,
    y: 30
  },
  {
    id: "bandit_hillfort",
    name: "Bandit Hillfort",
    description: "A raider-backed hillfort taxes the valley by threat of blade. Break its outer guard and deny the Ashen Covenant a staging point.",
    nodeType: "battle",
    difficulty: "normal",
    mapId: "broken_ford",
    enemyFactionId: "ashen_covenant",
    prerequisites: ["old_stone_road"],
    rewards: {
      xp: 55,
      resources: { crowns: 70, iron: 40 },
      itemIds: ["captains_seal"]
    },
    unlocks: ["ashen_outpost"],
    x: 56,
    y: 67
  },
  {
    id: "chapel_of_the_marches",
    name: "Chapel of the Marches",
    description: "A roadside chapel shelters wounded scouts and old oaths. Restore its signal fire to strengthen the march.",
    nodeType: "shrine",
    difficulty: "story",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    prerequisites: ["aether_well_ruins"],
    rewards: {
      xp: 30,
      resources: { aether: 30 },
      itemIds: ["green_chapel_icon"]
    },
    unlocks: ["ashen_outpost"],
    x: 74,
    y: 38
  },
  {
    id: "ashen_outpost",
    name: "Ashen Outpost",
    description: "The first Ashen forward camp anchors the enemy push. Destroy the outpost and the border breathes again.",
    nodeType: "battle",
    difficulty: "normal",
    mapId: "broken_ford",
    enemyFactionId: "ashen_covenant",
    prerequisites: ["bandit_hillfort", "chapel_of_the_marches"],
    rewards: {
      xp: 75,
      resources: { crowns: 100, iron: 55, aether: 35 },
      itemIds: ["ashbound_censer"]
    },
    unlocks: [],
    x: 88,
    y: 54
  }
];
