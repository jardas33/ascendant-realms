import type { RewardTableDefinition } from "../core/GameTypes";
import { CAMPAIGN_REWARD_TABLES } from "./campaignRewards";

export {
  BORDER_MARCHES_REWARD_TABLES,
  CAMPAIGN_REWARD_TABLES,
  CINDERFEN_ROAD_REWARD_TABLES
} from "./campaignRewards";

export const REWARD_TABLES: RewardTableDefinition[] = [...CAMPAIGN_REWARD_TABLES];
