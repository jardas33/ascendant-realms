import type { CampaignActStepDefinition, CampaignNodeDefinition, CampaignNodeStatus } from "../GameTypes";
import { ACT1_CAMPAIGN_SPINE } from "../../data/act1CampaignSpine";
import { CAMPAIGN_NODES } from "../../data/campaignNodes";
import type { CampaignSaveData } from "../../save/SaveTypes";
import { getCampaignNodeStatus } from "./CampaignNodeRules";

const ACT1_RECOMMENDED_NODE_ORDER = [
  "border_village",
  "old_stone_road",
  "aether_well_ruins",
  "bandit_hillfort",
  "ashen_outpost"
];

const NODE_BY_ID = new Map(CAMPAIGN_NODES.map((node) => [node.id, node]));

export interface CampaignActResultsGuidance {
  actStepLabel: string;
  nextAction: string;
  onboardingHint: string;
  replayHint: string;
}

export function getAct1CampaignSpine(): CampaignActStepDefinition[] {
  return ACT1_CAMPAIGN_SPINE;
}

export function getCampaignActStepForNode(nodeId: string): CampaignActStepDefinition | undefined {
  return ACT1_CAMPAIGN_SPINE.find((step) => step.nodeId === nodeId || step.supportNodeIds?.includes(nodeId));
}

export function getCampaignActStepStatus(step: CampaignActStepDefinition, campaign: CampaignSaveData): CampaignNodeStatus | "training" | "replay" {
  if (step.kind === "training") {
    return "training";
  }
  if (step.kind === "replay_loop") {
    return "replay";
  }
  const node = step.nodeId ? NODE_BY_ID.get(step.nodeId) : undefined;
  return node ? getCampaignNodeStatus(node, campaign) : "locked";
}

export function getCampaignActRecommendedNextStep(campaign: CampaignSaveData): CampaignActStepDefinition {
  const completed = new Set(campaign.completedNodeIds);
  const nextNodeId = ACT1_RECOMMENDED_NODE_ORDER.find((nodeId) => !completed.has(nodeId));
  if (!nextNodeId) {
    return ACT1_CAMPAIGN_SPINE.find((step) => step.kind === "replay_loop") ?? ACT1_CAMPAIGN_SPINE[ACT1_CAMPAIGN_SPINE.length - 1];
  }
  return getCampaignActStepForNode(nextNodeId) ?? ACT1_CAMPAIGN_SPINE[1];
}

export function formatCampaignActStepLabel(step: CampaignActStepDefinition): string {
  return `Act 1 Step ${step.order}: ${step.title}`;
}

export function formatCampaignActMechanicFocus(step: CampaignActStepDefinition): string {
  return step.mechanicFocus.join(", ");
}

export function getCampaignNodeLockedReason(node: CampaignNodeDefinition, campaign: CampaignSaveData): string {
  const status = getCampaignNodeStatus(node, campaign);
  if (status !== "locked") {
    return status === "completed" ? "Completed battle nodes are replayable." : "Ready to start.";
  }
  if (node.isPlaceholder) {
    return node.placeholderDescription ?? "Future content placeholder.";
  }
  if (campaign.lockedNodeIds.includes(node.id)) {
    return "Locked by a campaign choice or future route branch.";
  }
  const missingPrerequisites = node.prerequisites.filter((nodeId) => !campaign.completedNodeIds.includes(nodeId));
  if (missingPrerequisites.length > 0) {
    return `Complete ${formatNodeNames(missingPrerequisites)} first.`;
  }
  if (!campaign.unlockedNodeIds.includes(node.id)) {
    return "Unlock this node by clearing the previous campaign step.";
  }
  return "Locked until campaign prerequisites are met.";
}

export function getCampaignActResultsGuidance(options: {
  completedNodeId?: string;
  wasReplay?: boolean;
  unlockedNodeNames?: string[];
  optionalObjectives?: Array<{ persisted: boolean; newlyRecorded: boolean }>;
  rewardItemCount?: number;
  skillPointsGained?: number;
}): CampaignActResultsGuidance | undefined {
  const step = options.completedNodeId ? getCampaignActStepForNode(options.completedNodeId) : undefined;
  if (!step) {
    return undefined;
  }
  const openObjectiveCount = (options.optionalObjectives ?? []).filter((objective) => !objective.persisted).length;
  if (options.wasReplay) {
    return {
      actStepLabel: formatCampaignActStepLabel(step),
      nextAction: openObjectiveCount > 0 ? "Replay objective still open." : "Replay complete; choose another campaign node.",
      onboardingHint: "Replay rewards stay reduced and one-time node rewards remain claimed.",
      replayHint: step.replayHint ?? "One-time rewards do not duplicate."
    };
  }

  const unlockedCopy =
    (options.unlockedNodeNames ?? []).length > 0 ? `Next mission unlocked: ${options.unlockedNodeNames!.join(", ")}.` : step.nextAction;
  const skillCopy = (options.skillPointsGained ?? 0) > 0 ? " Spend skill points in Hero Inventory." : "";
  const equipCopy = (options.rewardItemCount ?? 0) > 0 ? " Equip new rewards before the next launch." : "";
  return {
    actStepLabel: formatCampaignActStepLabel(step),
    nextAction: `${unlockedCopy}${skillCopy}${equipCopy}`.trim(),
    onboardingHint: step.resultsHint,
    replayHint: step.replayHint ?? "Completed battle nodes are replayable with safe repeat rewards."
  };
}

function formatNodeNames(nodeIds: string[]): string {
  return nodeIds.map((nodeId) => NODE_BY_ID.get(nodeId)?.name ?? nodeId).join(", ");
}
