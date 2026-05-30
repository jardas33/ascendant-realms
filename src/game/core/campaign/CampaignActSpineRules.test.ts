import { describe, expect, it } from "vitest";
import {
  completeCampaignNode,
  createStartedCampaignSave,
  formatCampaignActStepLabel,
  getAct1CampaignSpine,
  getCampaignActRecommendedNextStep,
  getCampaignActResultsGuidance,
  getCampaignActStepForNode,
  getCampaignNodeLockedReason
} from "../CampaignRules";
import { CAMPAIGN_NODES } from "../../data/campaignNodes";
import { validateContent } from "../../data/contentValidation";

describe("campaign Act 1 spine rules", () => {
  it("defines the intended Act 1 order without binding Tutorial to campaign save state", () => {
    const spine = getAct1CampaignSpine();

    expect(spine.map((step) => step.title)).toEqual([
      "Training / Proving Grounds",
      "First Campaign Battle",
      "Base Development",
      "Resource Control",
      "Rival Pressure",
      "Ashen Outpost Finale",
      "Replay / Optional Objective Loop"
    ]);
    expect(spine[0]).toMatchObject({
      kind: "training",
      pacingTier: "training"
    });
    expect(spine[0].nodeId).toBeUndefined();
    expect(spine.filter((step) => step.kind === "campaign_battle").map((step) => step.nodeId)).toEqual([
      "border_village",
      "old_stone_road",
      "aether_well_ruins",
      "bandit_hillfort",
      "ashen_outpost"
    ]);
    expect(spine.at(-1)).toMatchObject({
      kind: "replay_loop",
      pacingTier: "replay"
    });
  });

  it("defaults old campaign saves into the first Act 1 campaign node with clear locked reasons", () => {
    const campaign = createStartedCampaignSave();
    const border = CAMPAIGN_NODES.find((node) => node.id === "border_village")!;
    const oldRoad = CAMPAIGN_NODES.find((node) => node.id === "old_stone_road")!;

    expect(getCampaignActRecommendedNextStep(campaign).nodeId).toBe("border_village");
    expect(getCampaignNodeLockedReason(border, campaign)).toBe("Ready to start.");
    expect(getCampaignNodeLockedReason(oldRoad, campaign)).toBe("Complete Border Village first.");
  });

  it("first clear unlocks the next Act 1 step and marks completed battles replayable", () => {
    const campaign = createStartedCampaignSave();
    const border = CAMPAIGN_NODES.find((node) => node.id === "border_village")!;
    const afterBorder = completeCampaignNode(campaign, border);

    expect(afterBorder.completedNodeIds).toContain("border_village");
    expect(afterBorder.unlockedNodeIds).toContain("old_stone_road");
    expect(getCampaignActRecommendedNextStep(afterBorder).nodeId).toBe("old_stone_road");
    expect(getCampaignNodeLockedReason(border, afterBorder)).toBe("Completed battle nodes are replayable.");
  });

  it("returns concise Results next-step guidance for first clears and replays", () => {
    const oldRoad = getCampaignActStepForNode("old_stone_road")!;
    const firstClear = getCampaignActResultsGuidance({
      completedNodeId: "old_stone_road",
      wasReplay: false,
      unlockedNodeNames: ["Aether Well Ruins", "Bandit Hillfort"],
      rewardItemCount: 0,
      skillPointsGained: 1
    });
    const replay = getCampaignActResultsGuidance({
      completedNodeId: "ashen_outpost",
      wasReplay: true,
      optionalObjectives: [{ persisted: false, newlyRecorded: false }]
    });

    expect(formatCampaignActStepLabel(oldRoad)).toBe("Act 1 Step 3: Base Development");
    expect(firstClear?.nextAction).toContain("Next mission unlocked: Aether Well Ruins, Bandit Hillfort.");
    expect(firstClear?.nextAction).toContain("Spend skill points");
    expect(firstClear?.onboardingHint).toContain("branch opens");
    expect(replay).toMatchObject({
      nextAction: "Replay objective still open.",
      onboardingHint: "Replay rewards stay reduced and one-time node rewards remain claimed."
    });

    const finale = getCampaignActResultsGuidance({
      completedNodeId: "ashen_outpost",
      wasReplay: false,
      unlockedNodeNames: [],
      rewardItemCount: 1,
      skillPointsGained: 1
    });
    expect(finale?.nextAction).toContain("Act 1 complete");
    expect(finale?.nextAction).toContain("Spend skill points");
    expect(finale?.nextAction).toContain("Equip new rewards");
  });

  it("validates Act 1 spine content with the broader content validator", () => {
    expect(validateContent()).toEqual([]);
  });
});
