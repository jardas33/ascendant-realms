import { cloneBattleLaunchRequestWithHero, createSkirmishBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { CurrentStoredGameSave } from "../save/SaveTypes";
import type { ResultsData } from "./ResultsTypes";

function heroForResultsContinuation(data: ResultsData) {
  return data.stats.outcome === "defeat" ? data.startingHeroSave ?? data.heroSave : data.heroSave;
}

export function createRetryBattleData(data: ResultsData): { launchRequest: ReturnType<typeof createSkirmishBattleLaunchRequest> } {
  const retryHero = heroForResultsContinuation(data);
  return {
    launchRequest: data.launchRequest
      ? cloneBattleLaunchRequestWithHero(data.launchRequest, retryHero, { sourceId: "results_retry" })
      : createSkirmishBattleLaunchRequest(retryHero, { sourceId: "results_retry" })
  };
}

export function createInventorySceneData(data: ResultsData): Record<string, unknown> {
  return {
    heroSave: heroForResultsContinuation(data),
    stats: data.stats,
    rewardItemIds: data.rewardItemIds,
    reward: data.reward,
    rewardLevelUp: data.rewardLevelUp,
    launchRequest: data.launchRequest,
    returnMode: data.launchRequest?.mode === "campaign_node" ? "campaign" : "skirmish"
  };
}

export function createCampaignMapReturnData(data: ResultsData, save: CurrentStoredGameSave): Record<string, unknown> {
  return {
    heroSave: save.hero,
    campaignSave: save.campaign,
    stats: data.stats,
    completedNodeId: data.campaignResult?.completedNodeId
  };
}

export function renderPrimaryActions(data: ResultsData): string {
  const isCampaign = data.launchRequest?.mode === "campaign_node";
  if (data.stats.outcome === "defeat") {
    return `
      <button data-results-action="retry">Retry</button>
      <button data-results-action="inventory">Open Hero Inventory</button>
      <button data-results-action="${isCampaign ? "campaign" : "menu"}">${isCampaign ? "Campaign Map" : "Main Menu"}</button>
      ${isCampaign ? `<button data-results-action="menu">Main Menu</button>` : ""}
    `;
  }
  return `
    ${isCampaign ? `<button data-results-action="campaign">Campaign Map</button>` : `<button data-results-action="skirmish">Continue Skirmish</button>`}
    <button data-results-action="inventory">Open Hero Inventory</button>
    <button data-results-action="menu">Main Menu</button>
  `;
}
