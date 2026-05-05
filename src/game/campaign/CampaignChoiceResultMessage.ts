import type { CampaignChoiceResult } from "../core/campaign/CampaignChoiceRules";
import type { CampaignNodeDefinition } from "../core/GameTypes";
import { CAMPAIGN_MODIFIER_BY_ID } from "../data/contentIndex";
import type { HeroSaveData } from "../save/SaveTypes";
import { formatCampaignNodeList } from "./CampaignNavigation";
import { formatChoiceCostSummary, formatChoiceRewardSummary, type CampaignChoiceDefinition } from "./CampaignChoiceViewModel";
import { CINDERFEN_ROUTE_COMPLETE_STATUS } from "./CampaignRouteStatusViewModel";

export function formatCampaignChoiceResultMessage(options: {
  node: CampaignNodeDefinition;
  choice: CampaignChoiceDefinition;
  heroSave: HeroSaveData;
  result: CampaignChoiceResult;
}): string {
  const { node, choice, heroSave, result } = options;
  const rewards = formatChoiceRewardSummary(choice, heroSave, node);
  const costs = formatChoiceCostSummary({ node, choice, heroSave });
  const unlocked = result.unlockedNodeIds.map((nodeId) => formatCampaignNodeList([nodeId]) || nodeId);
  const locked = result.lockedNodeIds.map((nodeId) => formatCampaignNodeList([nodeId]) || nodeId);
  const modifiers = result.grantedModifierIds.map((modifierId) => CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? modifierId);
  const verb = node.nodeType === "town" ? "used" : "chosen";
  const routeComplete = node.id === "cinderfen_aftermath" && result.completedNode ? ` ${CINDERFEN_ROUTE_COMPLETE_STATUS}` : "";

  return `${choice.label} ${verb}.${costs !== "None" ? ` Spent ${costs}.` : ""}${rewards ? ` ${rewards}.` : ""}${modifiers.length > 0 ? ` Modifier gained: ${modifiers.join(", ")}.` : ""}${unlocked.length > 0 ? ` New path: ${unlocked.join(", ")}.` : ""}${locked.length > 0 ? ` Path closed: ${locked.join(", ")}.` : ""}${routeComplete}`;
}
