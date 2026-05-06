import type { CampaignSaveData } from "../save/SaveTypes";

export const CINDERFEN_ROUTE_COMPLETE_TITLE = "Cinderfen route secured";
export const CINDERFEN_ROUTE_COMPLETE_BODY =
  "Chapter 2 route complete. The Watch Road is held; future Cinderfen roads will open in a later prototype.";
export const CINDERFEN_ROUTE_COMPLETE_STATUS =
  "Cinderfen route secured. Chapter 2 route complete; future Cinderfen roads will open later.";

export function createCampaignRouteStatusViewModel(campaignSave: CampaignSaveData) {
  if (!campaignSave.completedNodeIds.includes("cinderfen_aftermath")) {
    return undefined;
  }
  return {
    isComplete: true,
    title: CINDERFEN_ROUTE_COMPLETE_TITLE,
    body: CINDERFEN_ROUTE_COMPLETE_BODY,
    actions: ["Review rewards", "Try Skirmish maps", "Future Cinderfen roads pending"],
    statusMessage: CINDERFEN_ROUTE_COMPLETE_STATUS
  };
}
