import type { CampaignSaveData } from "../save/SaveTypes";

export const CINDERFEN_ROUTE_COMPLETE_TITLE = "Cinderfen route secured";
export const CINDERFEN_ROUTE_COMPLETE_BODY =
  "Chapter 2 slice complete. The current playable Cinderfen route ends at Aftermath, with more Cinderfen content coming later.";
export const CINDERFEN_ROUTE_COMPLETE_STATUS =
  "Cinderfen route secured. Chapter 2 slice complete. More Cinderfen content coming later.";

export function createCampaignRouteStatusViewModel(campaignSave: CampaignSaveData) {
  if (!campaignSave.completedNodeIds.includes("cinderfen_aftermath")) {
    return undefined;
  }
  return {
    isComplete: true,
    title: CINDERFEN_ROUTE_COMPLETE_TITLE,
    body: CINDERFEN_ROUTE_COMPLETE_BODY,
    actions: ["Review rewards", "Try Skirmish maps", "Wait for the next Cinderfen expansion"],
    statusMessage: CINDERFEN_ROUTE_COMPLETE_STATUS
  };
}
