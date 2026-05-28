import type { BattleSecondaryObjectiveDefinition, CampaignNodeDefinition } from "../GameTypes";
import { CAMPAIGN_NODE_BY_ID, MAP_BY_ID } from "../../data/contentIndex";
import type { CampaignSaveData } from "../../save/SaveTypes";

export type MissionObjectiveStateLabel = "Newly recorded" | "Already recorded" | "Incomplete";

export interface MissionOptionalObjectiveState {
  key: string;
  objectiveId: string;
  name: string;
  description: string;
  completedThisRun: boolean;
  persisted: boolean;
  newlyRecorded: boolean;
  statusLabel: MissionObjectiveStateLabel;
}

export interface MissionOptionalObjectiveRecordResult {
  campaign: CampaignSaveData;
  objectives: MissionOptionalObjectiveState[];
  newlyRecordedKeys: string[];
}

export interface CampaignMissionRewardState {
  isFirstClear: boolean;
  isReplay: boolean;
  nodeRewardClaimed: boolean;
  nodeRewardAlreadyClaimed: boolean;
  statusLabel: "First clear" | "Replay";
  rewardLabel: string;
}

export function getCampaignMissionRewardState(
  campaign: CampaignSaveData,
  node: CampaignNodeDefinition
): CampaignMissionRewardState {
  const previouslyCompleted = campaign.completedNodeIds.includes(node.id);
  const nodeRewardAlreadyClaimed = campaign.nodeRewardsClaimedIds.includes(node.id);
  return {
    isFirstClear: !previouslyCompleted,
    isReplay: previouslyCompleted,
    nodeRewardClaimed: !nodeRewardAlreadyClaimed,
    nodeRewardAlreadyClaimed,
    statusLabel: previouslyCompleted ? "Replay" : "First clear",
    rewardLabel: nodeRewardAlreadyClaimed
      ? "Campaign node reward already claimed"
      : previouslyCompleted
        ? "Replay with unclaimed campaign node reward"
        : "First-clear campaign node reward available"
  };
}

export function missionObjectiveCompletionKey(nodeId: string, objectiveId: string): string {
  return `${nodeId}:${objectiveId}`;
}

export function isKnownMissionObjectiveCompletionId(key: string): boolean {
  const { nodeId, objectiveId } = parseMissionObjectiveCompletionKey(key);
  if (!nodeId || !objectiveId) {
    return false;
  }
  const node = CAMPAIGN_NODE_BY_ID[nodeId];
  if (!node) {
    return false;
  }
  return getMissionOptionalObjectiveDefinitions(node).some((objective) => objective.id === objectiveId);
}

export function getMissionOptionalObjectiveDefinitions(
  node: CampaignNodeDefinition
): BattleSecondaryObjectiveDefinition[] {
  return MAP_BY_ID[node.mapId]?.scenario.objectives.secondaryObjectives ?? [];
}

export function getMissionOptionalObjectiveStates(options: {
  campaign: CampaignSaveData;
  node: CampaignNodeDefinition;
  completedObjectiveIds?: string[];
}): MissionOptionalObjectiveState[] {
  const completedThisRun = new Set(options.completedObjectiveIds ?? []);
  const persisted = new Set(options.campaign.optionalObjectiveCompletionIds);
  return getMissionOptionalObjectiveDefinitions(options.node).map((objective) => {
    const key = missionObjectiveCompletionKey(options.node.id, objective.id);
    const wasPersisted = persisted.has(key);
    const completed = completedThisRun.has(objective.id);
    return {
      key,
      objectiveId: objective.id,
      name: objective.name,
      description: objective.description,
      completedThisRun: completed,
      persisted: wasPersisted || completed,
      newlyRecorded: completed && !wasPersisted,
      statusLabel: completed && !wasPersisted ? "Newly recorded" : wasPersisted ? "Already recorded" : "Incomplete"
    };
  });
}

export function recordMissionOptionalObjectiveCompletions(options: {
  campaign: CampaignSaveData;
  node: CampaignNodeDefinition;
  completedObjectiveIds?: string[];
}): MissionOptionalObjectiveRecordResult {
  const states = getMissionOptionalObjectiveStates(options);
  const claimed = new Set(options.campaign.optionalObjectiveCompletionIds.filter(isKnownMissionObjectiveCompletionId));
  const newlyRecordedKeys: string[] = [];
  states.forEach((objective) => {
    if (!objective.completedThisRun || claimed.has(objective.key)) {
      return;
    }
    claimed.add(objective.key);
    newlyRecordedKeys.push(objective.key);
  });
  return {
    campaign: {
      ...options.campaign,
      optionalObjectiveCompletionIds: [...claimed]
    },
    objectives: states,
    newlyRecordedKeys
  };
}

function parseMissionObjectiveCompletionKey(key: string): { nodeId?: string; objectiveId?: string } {
  const separator = key.indexOf(":");
  if (separator <= 0 || separator >= key.length - 1) {
    return {};
  }
  return {
    nodeId: key.slice(0, separator),
    objectiveId: key.slice(separator + 1)
  };
}
