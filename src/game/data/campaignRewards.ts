import type { RewardTableDefinition } from "../core/GameTypes";

export const BORDER_MARCHES_REWARD_TABLES: RewardTableDefinition[] = [
  {
    id: "first_claim_rewards",
    name: "First Claim Spoils",
    guaranteedItemIds: [],
    deterministicItemIds: [
      "weathered_command_sword",
      "emberglass_wand",
      "pilgrim_crook",
      "marcher_plate",
      "runewoven_robes",
      "dawnward_vestments",
      "captains_seal",
      "aether_lens",
      "green_chapel_icon"
    ],
    rolls: 1,
    weightedItemPool: [
      { itemId: "weathered_command_sword", weight: 30, mapIds: ["first_claim"] },
      { itemId: "emberglass_wand", weight: 30, mapIds: ["first_claim"] },
      { itemId: "pilgrim_crook", weight: 30, mapIds: ["first_claim"] },
      { itemId: "scouts_bow", weight: 20, mapIds: ["first_claim"] },
      { itemId: "marcher_plate", weight: 18, mapIds: ["first_claim"] },
      { itemId: "runewoven_robes", weight: 18, mapIds: ["first_claim"] },
      { itemId: "dawnward_vestments", weight: 18, mapIds: ["first_claim"] },
      { itemId: "captains_seal", weight: 5, mapIds: ["first_claim"] },
      { itemId: "aether_lens", weight: 5, mapIds: ["first_claim"] },
      { itemId: "green_chapel_icon", weight: 5, mapIds: ["first_claim"] },
      { itemId: "ashbound_censer", weight: 2, mapIds: ["first_claim"], repeatClearOnly: true }
    ],
    resourceRewards: [
      { resource: "crowns", amount: 45 },
      { resource: "stone", amount: 25 }
    ],
    xpRewards: [{ amount: 35 }],
    firstClearBonus: {
      resources: {
        crowns: 75,
        stone: 40,
        aether: 15
      },
      xp: 40
    },
    repeatClearReward: {
      resources: {
        crowns: 30,
        stone: 20
      },
      xp: 15
    }
  },
  {
    id: "broken_ford_rewards",
    name: "Broken Ford Spoils",
    guaranteedItemIds: [],
    deterministicItemIds: [
      "fordbreaker_halberd",
      "captains_seal",
      "aether_lens",
      "scouts_bow",
      "oathbound_aegis",
      "starfall_prism",
      "ascendant_signet"
    ],
    rolls: 1,
    weightedItemPool: [
      { itemId: "scouts_bow", weight: 16, mapIds: ["broken_ford"] },
      { itemId: "marcher_plate", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "runewoven_robes", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "dawnward_vestments", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "captains_seal", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "aether_lens", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "green_chapel_icon", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "fordbreaker_halberd", weight: 12, mapIds: ["broken_ford"] },
      { itemId: "ashbound_censer", weight: 10, mapIds: ["broken_ford"] },
      { itemId: "oathbound_aegis", weight: 5, mapIds: ["broken_ford"] },
      { itemId: "starfall_prism", weight: 5, mapIds: ["broken_ford"] },
      { itemId: "ascendant_signet", weight: 1, mapIds: ["broken_ford"], repeatClearOnly: true }
    ],
    resourceRewards: [
      { resource: "crowns", amount: 60 },
      { resource: "iron", amount: 35 },
      { resource: "aether", amount: 20 }
    ],
    xpRewards: [{ amount: 55 }],
    firstClearBonus: {
      itemIds: ["fordbreaker_halberd"],
      resources: {
        crowns: 110,
        iron: 50,
        aether: 30
      },
      xp: 65
    },
    repeatClearReward: {
      resources: {
        crowns: 45,
        iron: 20
      },
      xp: 25
    }
  },
  {
    id: "ashen_outpost_rewards",
    name: "Ashen Outpost Spoils",
    guaranteedItemIds: [],
    deterministicItemIds: [
      "ashbound_censer",
      "starfall_prism",
      "captains_seal",
      "aether_lens",
      "oathbound_aegis",
      "ascendant_signet"
    ],
    rolls: 1,
    weightedItemPool: [
      { itemId: "ashbound_censer", weight: 22, mapIds: ["ashen_outpost"] },
      { itemId: "captains_seal", weight: 15, mapIds: ["ashen_outpost"] },
      { itemId: "aether_lens", weight: 15, mapIds: ["ashen_outpost"] },
      { itemId: "green_chapel_icon", weight: 10, mapIds: ["ashen_outpost"] },
      { itemId: "fordbreaker_halberd", weight: 11, mapIds: ["ashen_outpost"] },
      { itemId: "oathbound_aegis", weight: 6, mapIds: ["ashen_outpost"] },
      { itemId: "starfall_prism", weight: 7, mapIds: ["ashen_outpost"] },
      { itemId: "ascendant_signet", weight: 1, mapIds: ["ashen_outpost"], repeatClearOnly: true }
    ],
    resourceRewards: [
      { resource: "crowns", amount: 90 },
      { resource: "stone", amount: 35 },
      { resource: "iron", amount: 60 },
      { resource: "aether", amount: 45 }
    ],
    xpRewards: [{ amount: 85 }],
    firstClearBonus: {
      itemIds: ["ashbound_censer"],
      resources: {
        crowns: 150,
        stone: 80,
        iron: 70,
        aether: 55
      },
      xp: 95
    },
    repeatClearReward: {
      resources: {
        crowns: 65,
        iron: 35,
        aether: 25
      },
      xp: 35
    }
  }
];

export const CINDERFEN_ROAD_REWARD_TABLES: RewardTableDefinition[] = [
  {
    id: "cinderfen_causeway_rewards",
    name: "Cinderfen Crossing Spoils",
    guaranteedItemIds: [],
    deterministicItemIds: [
      "aether_lens",
      "ashbound_censer",
      "captains_seal",
      "fordbreaker_halberd",
      "starfall_prism"
    ],
    rolls: 1,
    weightedItemPool: [
      { itemId: "aether_lens", weight: 18, mapIds: ["cinderfen_causeway"], firstClearOnly: true },
      { itemId: "ashbound_censer", weight: 16, mapIds: ["cinderfen_causeway"], firstClearOnly: true },
      { itemId: "captains_seal", weight: 14, mapIds: ["cinderfen_causeway"], firstClearOnly: true },
      { itemId: "green_chapel_icon", weight: 10, mapIds: ["cinderfen_causeway"], firstClearOnly: true },
      { itemId: "fordbreaker_halberd", weight: 9, mapIds: ["cinderfen_causeway"], firstClearOnly: true },
      { itemId: "starfall_prism", weight: 4, mapIds: ["cinderfen_causeway"], firstClearOnly: true }
    ],
    resourceRewards: [
      { resource: "crowns", amount: 16, firstClearOnly: true },
      { resource: "stone", amount: 10, firstClearOnly: true },
      { resource: "iron", amount: 8, firstClearOnly: true },
      { resource: "aether", amount: 6, firstClearOnly: true }
    ],
    xpRewards: [{ amount: 30, firstClearOnly: true }],
    firstClearBonus: {
      resources: {
        crowns: 14,
        stone: 10,
        iron: 8,
        aether: 6
      },
      xp: 35
    },
    repeatClearReward: {
      resources: {
        crowns: 6,
        iron: 3,
        aether: 2
      },
      xp: 4
    }
  },
  {
    id: "cinderfen_watchpost_rewards",
    name: "Cinderfen Watch Spoils",
    guaranteedItemIds: [],
    deterministicItemIds: [
      "ashbound_censer",
      "aether_lens",
      "captains_seal",
      "scouts_bow",
      "green_chapel_icon"
    ],
    rolls: 1,
    weightedItemPool: [
      { itemId: "ashbound_censer", weight: 17, mapIds: ["cinderfen_watchpost"], firstClearOnly: true },
      { itemId: "aether_lens", weight: 16, mapIds: ["cinderfen_watchpost"], firstClearOnly: true },
      { itemId: "captains_seal", weight: 13, mapIds: ["cinderfen_watchpost"], firstClearOnly: true },
      { itemId: "scouts_bow", weight: 12, mapIds: ["cinderfen_watchpost"], firstClearOnly: true },
      { itemId: "green_chapel_icon", weight: 10, mapIds: ["cinderfen_watchpost"], firstClearOnly: true },
      { itemId: "fordbreaker_halberd", weight: 5, mapIds: ["cinderfen_watchpost"], firstClearOnly: true }
    ],
    resourceRewards: [
      { resource: "crowns", amount: 18, firstClearOnly: true },
      { resource: "stone", amount: 10, firstClearOnly: true },
      { resource: "iron", amount: 8, firstClearOnly: true },
      { resource: "aether", amount: 5, firstClearOnly: true }
    ],
    xpRewards: [{ amount: 32, firstClearOnly: true }],
    firstClearBonus: {
      resources: {
        crowns: 16,
        stone: 10,
        iron: 8,
        aether: 5
      },
      xp: 34
    },
    repeatClearReward: {
      resources: {
        crowns: 5,
        iron: 2,
        aether: 1
      },
      xp: 3
    }
  }
];

export const CAMPAIGN_REWARD_TABLES: RewardTableDefinition[] = [
  ...BORDER_MARCHES_REWARD_TABLES,
  ...CINDERFEN_ROAD_REWARD_TABLES
];
