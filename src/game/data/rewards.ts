import type { RewardTableDefinition } from "../core/GameTypes";

export const REWARD_TABLES: RewardTableDefinition[] = [
  {
    id: "first_claim_rewards",
    name: "First Claim Spoils",
    itemIds: [
      "weathered_command_sword",
      "emberglass_wand",
      "pilgrim_crook",
      "marcher_plate",
      "runewoven_robes",
      "dawnward_vestments",
      "captains_seal",
      "aether_lens",
      "green_chapel_icon"
    ]
  },
  {
    id: "broken_ford_rewards",
    name: "Broken Ford Spoils",
    itemIds: [
      "captains_seal",
      "marcher_plate",
      "aether_lens",
      "weathered_command_sword",
      "runewoven_robes",
      "emberglass_wand",
      "green_chapel_icon",
      "dawnward_vestments",
      "pilgrim_crook"
    ]
  }
];
