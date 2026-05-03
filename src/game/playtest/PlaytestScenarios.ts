import { requireCampaignNode } from "../data/contentIndex";
import type { PlaytestScenarioDefinition } from "./PlaytestTypes";

export const BATTLE_NODE_IDS = [
  "border_village",
  "old_stone_road",
  "aether_well_ruins",
  "bandit_hillfort",
  "ashen_outpost",
  "cinderfen_crossing",
  "cinderfen_watch"
] as const;

export const DEFAULT_PLAYTEST_SCENARIOS: PlaytestScenarioDefinition[] = BATTLE_NODE_IDS.map((nodeId) => {
  const node = requireCampaignNode(nodeId);
  return { nodeId, expectedDifficulty: node.difficulty };
});
