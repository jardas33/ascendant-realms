import type { CampaignNodeDefinition } from "../core/GameTypes";
import { BORDER_MARCHES_NODES } from "./borderMarchesNodes";
import { CINDERFEN_ROAD_NODES } from "./cinderfenRoadNodes";

export { BORDER_MARCHES_NODES } from "./borderMarchesNodes";
export { CINDERFEN_ROAD_NODES } from "./cinderfenRoadNodes";

export const CAMPAIGN_NODES: CampaignNodeDefinition[] = [...BORDER_MARCHES_NODES, ...CINDERFEN_ROAD_NODES];
