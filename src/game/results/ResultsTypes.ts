import type { BattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { BattleRewardResult, BattleStats, ResourceBag, RewardLevelUpSummary } from "../core/GameTypes";
import type { MissionOptionalObjectiveState } from "../core/campaign/CampaignMissionRules";
import type { RelicRewardAcquisition, RelicRewardChoice } from "../core/RelicRewardRules";
import type { RivalBattleOutcomeSummary } from "../core/RivalRules";
import type { HeroSaveData } from "../save/SaveTypes";

export interface CampaignResultsData {
  completedNodeId: string;
  completedNodeName: string;
  unlockedNodeIds: string[];
  unlockedNodeNames: string[];
  nodeReward: BattleRewardResult;
  nodeLevelUp: RewardLevelUpSummary;
  campaignResources: ResourceBag;
  wasFirstClear?: boolean;
  wasReplay?: boolean;
  nodeRewardClaimed?: boolean;
  nodeRewardAlreadyClaimed?: boolean;
  optionalObjectives?: MissionOptionalObjectiveState[];
}

export interface ResultsData {
  stats: BattleStats;
  heroSave: HeroSaveData;
  startingHeroSave?: HeroSaveData;
  rewardItemIds?: string[];
  reward?: BattleRewardResult;
  rewardLevelUp?: RewardLevelUpSummary;
  launchRequest?: BattleLaunchRequest;
  campaignResult?: CampaignResultsData;
  rivalResult?: RivalBattleOutcomeSummary;
  relicReward?: RelicRewardAcquisition;
  relicRewardChoice?: RelicRewardChoice;
}
