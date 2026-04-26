import type { RewardTableDefinition } from "../core/GameTypes";

export const REWARD_TABLES: RewardTableDefinition[] = [
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
      { itemId: "weathered_command_sword", weight: 28, mapIds: ["first_claim"] },
      { itemId: "emberglass_wand", weight: 28, mapIds: ["first_claim"] },
      { itemId: "pilgrim_crook", weight: 28, mapIds: ["first_claim"] },
      { itemId: "scouts_bow", weight: 18, mapIds: ["first_claim"] },
      { itemId: "marcher_plate", weight: 18, mapIds: ["first_claim"] },
      { itemId: "runewoven_robes", weight: 18, mapIds: ["first_claim"] },
      { itemId: "dawnward_vestments", weight: 18, mapIds: ["first_claim"] },
      { itemId: "captains_seal", weight: 7, mapIds: ["first_claim"] },
      { itemId: "aether_lens", weight: 7, mapIds: ["first_claim"] },
      { itemId: "green_chapel_icon", weight: 7, mapIds: ["first_claim"] },
      { itemId: "ashbound_censer", weight: 2, mapIds: ["first_claim"], repeatClearOnly: true }
    ],
    resourceRewards: [
      { resource: "crowns", amount: 45 },
      { resource: "stone", amount: 25 }
    ],
    xpRewards: [{ amount: 35 }],
    firstClearBonus: {
      resources: {
        crowns: 85,
        stone: 45,
        aether: 20
      },
      xp: 45
    },
    repeatClearReward: {
      resources: {
        crowns: 35,
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
      { itemId: "scouts_bow", weight: 18, mapIds: ["broken_ford"] },
      { itemId: "marcher_plate", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "runewoven_robes", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "dawnward_vestments", weight: 14, mapIds: ["broken_ford"] },
      { itemId: "captains_seal", weight: 13, mapIds: ["broken_ford"] },
      { itemId: "aether_lens", weight: 13, mapIds: ["broken_ford"] },
      { itemId: "green_chapel_icon", weight: 13, mapIds: ["broken_ford"] },
      { itemId: "fordbreaker_halberd", weight: 12, mapIds: ["broken_ford"] },
      { itemId: "ashbound_censer", weight: 9, mapIds: ["broken_ford"] },
      { itemId: "oathbound_aegis", weight: 4, mapIds: ["broken_ford"] },
      { itemId: "starfall_prism", weight: 4, mapIds: ["broken_ford"] },
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
  }
];
