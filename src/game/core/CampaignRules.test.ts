import { describe, expect, it } from "vitest";
import {
  applyCampaignChoice,
  completeCampaignNode,
  completeCampaignNodeWithRewards,
  createStartedCampaignSave,
  getCampaignChoiceAvailability,
  getCampaignNodeStatus,
  getCampaignProgressSummary
} from "./CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { consumeBattleCampaignModifiers } from "../data/campaignModifiers";
import { createNewHeroSave } from "../data/heroes";
import { getReputationBattleLaunchModifiers, getReputationRank } from "../data/reputation";

const CHAPTER_ONE_COMPLETED_NODE_IDS = [
  "border_village",
  "old_stone_road",
  "marcher_camp",
  "aether_well_ruins",
  "bandit_hillfort",
  "chapel_of_the_marches",
  "refugee_caravan",
  "ashen_outpost"
];

const POST_ASHEN_UNLOCKED_NODE_IDS = [...CHAPTER_ONE_COMPLETED_NODE_IDS, "cinderfen_overlook"];

function createPostOverlookCampaign(resources = { crowns: 120, stone: 0, iron: 0, aether: 60 }) {
  return createStartedCampaignSave({
    ...createStartedCampaignSave(),
    completedNodeIds: [...CHAPTER_ONE_COMPLETED_NODE_IDS, "cinderfen_overlook"],
    unlockedNodeIds: [...POST_ASHEN_UNLOCKED_NODE_IDS, "cinderfen_waystation", "cinderfen_crossing"],
    resources,
    nodeRewardsClaimedIds: []
  });
}

const MALREC_STANDARD_TROPHY = {
  trophyId: "trophy_malrec_outpost_standard",
  enemyHeroId: "captain_malrec",
  earnedAt: "2026-05-03T12:00:00.000Z",
  sourceNodeId: "ashen_outpost",
  label: "Malrec's Outpost Standard",
  description: "The torn fortress standard of Captain Malrec's Ashen Outpost command.",
  effect: "Milestone one-time first-defeat reward claimed."
};

describe("campaign rules", () => {
  it("unlocks the first node and gates later nodes by prerequisites", () => {
    const campaign = createStartedCampaignSave();
    const borderVillage = CAMPAIGN_NODES.find((node) => node.id === "border_village");
    const oldRoad = CAMPAIGN_NODES.find((node) => node.id === "old_stone_road");

    expect(borderVillage && getCampaignNodeStatus(borderVillage, campaign)).toBe("available");
    expect(oldRoad && getCampaignNodeStatus(oldRoad, campaign)).toBe("locked");
  });

  it("opens the Chapter 2 event after Ashen Outpost and gates the battle behind the event choice", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_crossing"
      ]
    });
    const overlook = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_overlook")!;
    const waystation = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_waystation")!;
    const crossing = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_crossing")!;
    const watch = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_watch")!;

    expect(getCampaignNodeStatus(overlook, campaign)).toBe("available");
    expect(getCampaignNodeStatus(waystation, campaign)).toBe("locked");
    expect(getCampaignNodeStatus(crossing, campaign)).toBe("locked");
    expect(getCampaignNodeStatus(watch, campaign)).toBe("locked");
    expect(getCampaignProgressSummary(campaign)).toBe("8/12 nodes completed");
  });

  it("calculates reputation ranks from simple thresholds", () => {
    expect(getReputationRank(50).id).toBe("honored");
    expect(getReputationRank(25).id).toBe("friendly");
    expect(getReputationRank(0).id).toBe("neutral");
    expect(getReputationRank(-25).id).toBe("disliked");
    expect(getReputationRank(-50).id).toBe("hostile");
  });

  it("completes nodes and unlocks their next choices", () => {
    const campaign = createStartedCampaignSave();
    const borderVillage = CAMPAIGN_NODES.find((node) => node.id === "border_village");
    expect(borderVillage).toBeDefined();

    const next = completeCampaignNode(campaign, borderVillage!);
    const oldRoad = CAMPAIGN_NODES.find((node) => node.id === "old_stone_road");

    expect(next.completedNodeIds).toContain("border_village");
    expect(oldRoad && getCampaignNodeStatus(oldRoad, next)).toBe("available");
  });

  it("claims node rewards once while preserving completion progress", () => {
    const campaign = createStartedCampaignSave();
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "border_village")!;

    const completed = completeCampaignNodeWithRewards({ campaign, hero, node });
    const repeated = completeCampaignNodeWithRewards({
      campaign: completed.campaign,
      hero: completed.hero,
      node
    });

    expect(completed.campaign.completedNodeIds).toContain(node.id);
    expect(completed.campaign.nodeRewardsClaimedIds).toContain(node.id);
    expect(completed.campaign.resources.crowns).toBe(50);
    expect(completed.hero.inventory.some((instance) => instance.itemId === "weathered_command_sword")).toBe(true);
    expect(repeated.nodeReward.itemIds).toEqual([]);
    expect(repeated.nodeReward.resources).toEqual({});
    expect(repeated.campaign.resources.crowns).toBe(50);
  });

  it("locks choices when costs or requirements are not met", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["old_stone_road", "aether_well_ruins"],
      unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "chapel_of_the_marches"],
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "shepherd", "temple_orphan");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "chapel_of_the_marches")!;
    const choice = node.choices!.find((entry) => entry.id === "repair_chapel")!;

    const availability = getCampaignChoiceAvailability({ campaign, hero, node, choice });
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(availability.ok).toBe(false);
    expect(availability.reasons).toContain("Need 45 Crowns");
    expect(applied.ok).toBe(false);
    expect(applied.campaign).toBe(campaign);
    expect(applied.hero).toBe(hero);
  });

  it("pays choice costs and grants campaign resources, items, XP, and reputation", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 120, stone: 80, iron: 0, aether: 5 },
      completedNodeIds: ["old_stone_road", "aether_well_ruins"],
      unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "chapel_of_the_marches"],
      activeModifierIds: ["angered_raiders"],
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "shepherd", "temple_orphan");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "chapel_of_the_marches")!;
    const choice = node.choices!.find((entry) => entry.id === "repair_chapel")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.campaign.resources).toMatchObject({ crowns: 75, stone: 25, aether: 40 });
    expect(applied.campaign.completedNodeIds).toContain("chapel_of_the_marches");
    expect(applied.campaign.unlockedNodeIds).toContain("ashen_outpost");
    expect(applied.hero.factionReputation.free_marches).toBe(hero.factionReputation.free_marches + 2);
    expect(applied.hero.factionReputation.old_faith).toBe(hero.factionReputation.old_faith + 6);
    expect(applied.campaign.activeModifierIds).toContain("local_support");
    expect(applied.campaign.activeModifierIds).not.toContain("angered_raiders");
  });

  it("keeps an event node open for non-completing choices", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["old_stone_road", "aether_well_ruins"],
      unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "chapel_of_the_marches"],
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "shepherd", "temple_orphan");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "chapel_of_the_marches")!;
    const choice = node.choices!.find((entry) => entry.id === "ask_for_guidance")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.completedNode).toBe(false);
    expect(applied.campaign.completedNodeIds).not.toContain(node.id);
    expect(applied.campaign.choiceIdsClaimed).toContain(`${node.id}:${choice.id}`);
    expect(applied.campaign.unlockedNodeIds).toContain("refugee_caravan");
    expect(applied.campaign.unlockedNodeIds).toContain("ashen_outpost");
  });

  it("locks remaining choices after a completing event choice", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["old_stone_road", "aether_well_ruins"],
      unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "chapel_of_the_marches"],
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "shepherd", "temple_orphan");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "chapel_of_the_marches")!;
    const completingChoice = node.choices!.find((entry) => entry.id === "pray_for_strength")!;
    const laterChoice = node.choices!.find((entry) => entry.id === "ask_for_guidance")!;

    const completed = applyCampaignChoice({ campaign, hero, node, choice: completingChoice });
    const repeated = applyCampaignChoice({ campaign: completed.campaign, hero: completed.hero, node, choice: laterChoice });

    expect(completed.ok).toBe(true);
    expect(completed.campaign.completedNodeIds).toContain(node.id);
    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Node completed");
  });

  it("prevents once-only choices from repeating", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "refugee_caravan"],
      resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "refugee_caravan")!;
    const choice = node.choices!.find((entry) => entry.id === "demand_tribute")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });
    const repeated = applyCampaignChoice({ campaign: applied.campaign, hero: applied.hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.campaign.resources.crowns).toBe(65);
    expect(applied.hero.factionReputation.free_marches).toBe(hero.factionReputation.free_marches - 2);
    expect(applied.hero.factionReputation.common_folk).toBe(hero.factionReputation.common_folk - 8);
    expect(applied.campaign.activeModifierIds).toContain("angered_raiders");
    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Already chosen");
    expect(repeated.campaign.resources.crowns).toBe(65);
  });

  it("applies the Cinderfen Overlook choice cost, rewards, reputation, unlock, and duplicate prevention", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook"
      ],
      resources: { crowns: 80, stone: 0, iron: 0, aether: 30 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "shepherd", "temple_orphan");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const choice = node.choices!.find((entry) => entry.id === "study_the_cinders")!;

    expect(getCampaignNodeStatus(node, campaign)).toBe("available");
    expect(getCampaignChoiceAvailability({ campaign, hero, node, choice }).ok).toBe(true);
    const applied = applyCampaignChoice({ campaign, hero, node, choice });
    const repeated = applyCampaignChoice({ campaign: applied.campaign, hero: applied.hero, node, choice });
    const waystation = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const crossing = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_crossing")!;

    expect(applied.ok).toBe(true);
    expect(applied.completedNode).toBe(true);
    expect(applied.campaign.resources.aether).toBe(6);
    expect(applied.campaign.resourcesSpent.aether).toBe(24);
    expect(applied.campaign.completedNodeIds).toContain("cinderfen_overlook");
    expect(applied.campaign.choiceIdsClaimed).toContain("cinderfen_overlook:study_the_cinders");
    expect(applied.campaign.unlockedNodeIds).toContain("cinderfen_waystation");
    expect(applied.campaign.unlockedNodeIds).toContain("cinderfen_crossing");
    expect(getCampaignNodeStatus(waystation, applied.campaign)).toBe("available");
    expect(getCampaignNodeStatus(crossing, applied.campaign)).toBe("available");
    expect(applied.hero.inventory.some((instance) => instance.itemId === "emberglass_wand")).toBe(true);
    expect(applied.hero.xp).toBe(20);
    expect(applied.hero.factionReputation.old_faith).toBe(hero.factionReputation.old_faith + 5);
    expect(applied.hero.factionReputation.ashen_covenant).toBe(hero.factionReputation.ashen_covenant - 2);
    expect(applied.campaign.activeModifierIds).toContain("blessed_road");
    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Node completed");
    expect(repeated.reason).toContain("Already chosen");
    expect(repeated.campaign.resources.aether).toBe(6);
  });

  it("locks Cinderfen Overlook choices when their campaign resource costs are missing", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost"
      ],
      unlockedNodeIds: [
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook"
      ],
      resources: { crowns: 80, stone: 0, iron: 0, aether: 5 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const choice = node.choices!.find((entry) => entry.id === "study_the_cinders")!;

    const availability = getCampaignChoiceAvailability({ campaign, hero, node, choice });
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(availability.ok).toBe(false);
    expect(availability.reasons).toContain("Need 24 Aether");
    expect(applied.ok).toBe(false);
    expect(applied.campaign.resources.aether).toBe(5);
    expect(applied.campaign.completedNodeIds).not.toContain("cinderfen_overlook");
  });

  it("locks the Malrec Standard Cinderfen choice until the rival trophy is present", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: CHAPTER_ONE_COMPLETED_NODE_IDS,
      unlockedNodeIds: POST_ASHEN_UNLOCKED_NODE_IDS,
      resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
      rivalTrophies: [],
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const choice = node.choices!.find((entry) => entry.id === "raise_malrecs_standard")!;

    const availability = getCampaignChoiceAvailability({ campaign, hero, node, choice });
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(availability.ok).toBe(false);
    expect(availability.reasons).toContain("Requires trophy Malrec's Outpost Standard");
    expect(applied.ok).toBe(false);
    expect(applied.reason).toContain("Requires trophy Malrec's Outpost Standard");
    expect(applied.campaign.completedNodeIds).not.toContain("cinderfen_overlook");
    expect(applied.campaign.activeModifierIds).not.toContain("well_rested");
    expect(applied.hero.xp).toBe(hero.xp);
  });

  it("applies the Malrec Standard Cinderfen choice once when the trophy is present", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: CHAPTER_ONE_COMPLETED_NODE_IDS,
      unlockedNodeIds: POST_ASHEN_UNLOCKED_NODE_IDS,
      resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
      rivalTrophies: [MALREC_STANDARD_TROPHY],
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const choice = node.choices!.find((entry) => entry.id === "raise_malrecs_standard")!;
    const crossing = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_crossing")!;

    const availability = getCampaignChoiceAvailability({ campaign, hero, node, choice });
    const applied = applyCampaignChoice({ campaign, hero, node, choice });
    const repeated = applyCampaignChoice({ campaign: applied.campaign, hero: applied.hero, node, choice });

    expect(availability.ok).toBe(true);
    expect(applied.ok).toBe(true);
    expect(applied.completedNode).toBe(true);
    expect(applied.campaign.completedNodeIds).toContain("cinderfen_overlook");
    expect(applied.campaign.choiceIdsClaimed).toContain("cinderfen_overlook:raise_malrecs_standard");
    expect(applied.campaign.rivalTrophies).toEqual([MALREC_STANDARD_TROPHY]);
    expect(applied.campaign.resources).toMatchObject({ crowns: 0, stone: 0, iron: 0, aether: 0 });
    expect(applied.campaign.activeModifierIds).toEqual(["well_rested"]);
    expect(applied.hero.xp).toBe(hero.xp + 10);
    expect(applied.hero.factionReputation.free_marches).toBe(hero.factionReputation.free_marches + 3);
    expect(getCampaignNodeStatus(crossing, applied.campaign)).toBe("available");
    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Node completed");
    expect(repeated.reason).toContain("Already chosen");
    expect(repeated.campaign.activeModifierIds).toEqual(["well_rested"]);
    expect(repeated.hero.xp).toBe(hero.xp + 10);
  });

  it("unlocks Cinderfen Waystation after Overlook and grants a repeatable service modifier", () => {
    const campaign = createPostOverlookCampaign();
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const choice = node.choices!.find((entry) => entry.id === "marsh_guides")!;

    expect(getCampaignNodeStatus(node, campaign)).toBe("available");
    expect(getCampaignChoiceAvailability({ campaign, hero, node, choice }).ok).toBe(true);
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.completedNode).toBe(false);
    expect(applied.campaign.completedNodeIds).not.toContain("cinderfen_waystation");
    expect(applied.campaign.resources.crowns).toBe(85);
    expect(applied.campaign.resourcesSpent.crowns).toBe(35);
    expect(applied.campaign.activeModifierIds).toContain("marsh_guides");
    expect(applied.campaign.townServiceUseCounts["cinderfen_waystation:marsh_guides"]).toBe(1);
  });

  it("blocks Cinderfen Waystation services when resources are insufficient", () => {
    const campaign = createPostOverlookCampaign({ crowns: 20, stone: 0, iron: 0, aether: 10 });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const choice = node.choices!.find((entry) => entry.id === "ash_filters")!;

    const availability = getCampaignChoiceAvailability({ campaign, hero, node, choice });
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(availability.ok).toBe(false);
    expect(availability.reasons).toContain("Need 35 Crowns");
    expect(availability.reasons).toContain("Need 15 Aether");
    expect(applied.ok).toBe(false);
    expect(applied.campaign.resources).toMatchObject({ crowns: 20, aether: 10 });
    expect(applied.campaign.activeModifierIds).not.toContain("ash_filters");
  });

  it("prevents the one-time Cinderfen refugee scout service from duplicating rewards", () => {
    const campaign = createPostOverlookCampaign();
    const hero = createNewHeroSave("Aster", "shepherd", "temple_orphan");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const choice = node.choices!.find((entry) => entry.id === "refugee_scouts")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });
    const repeated = applyCampaignChoice({ campaign: applied.campaign, hero: applied.hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.campaign.resources.crowns).toBe(95);
    expect(applied.campaign.choiceIdsClaimed).toContain("cinderfen_waystation:refugee_scouts");
    expect(applied.campaign.townServiceClaimedIds).toContain("cinderfen_waystation:refugee_scouts");
    expect(applied.hero.xp).toBe(hero.xp + 10);
    expect(applied.hero.factionReputation.common_folk).toBe(hero.factionReputation.common_folk + 2);
    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Already purchased");
    expect(repeated.campaign.resources.crowns).toBe(95);
    expect(repeated.hero.xp).toBe(hero.xp + 10);
  });

  it("lets repeatable Cinderfen Waystation services track repeated use", () => {
    const campaign = createPostOverlookCampaign();
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const choice = node.choices!.find((entry) => entry.id === "shrine_attunement")!;

    const first = applyCampaignChoice({ campaign, hero, node, choice });
    const second = applyCampaignChoice({ campaign: first.campaign, hero: first.hero, node, choice });

    expect(first.ok).toBe(true);
    expect(second.ok).toBe(true);
    expect(second.campaign.resources.aether).toBe(36);
    expect(second.campaign.resourcesSpent.aether).toBe(24);
    expect(second.campaign.activeModifierIds).toEqual(["shrine_attunement"]);
    expect(second.campaign.townServiceUseCounts["cinderfen_waystation:shrine_attunement"]).toBe(2);
  });

  it("consumes Cinderfen Waystation battle prep only when launching Cinderfen Crossing", () => {
    const campaign = {
      ...createPostOverlookCampaign(),
      activeModifierIds: ["marsh_guides", "shrine_attunement"]
    };
    const oldRoad = CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!;
    const crossing = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_crossing")!;
    const watch = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_watch")!;

    const skipped = consumeBattleCampaignModifiers({ campaign, node: oldRoad });
    const consumed = consumeBattleCampaignModifiers({ campaign, node: crossing });
    const watchConsumed = consumeBattleCampaignModifiers({ campaign, node: watch });

    expect(skipped.launchModifiers).toEqual([]);
    expect(skipped.campaign.activeModifierIds).toEqual(["marsh_guides", "shrine_attunement"]);
    expect(consumed.launchModifiers.map((modifier) => modifier.id)).toEqual(["marsh_guides", "shrine_attunement"]);
    expect(consumed.campaign.activeModifierIds).toEqual([]);
    expect(watchConsumed.launchModifiers.map((modifier) => modifier.id)).toEqual(["marsh_guides"]);
    expect(watchConsumed.campaign.activeModifierIds).toEqual(["shrine_attunement"]);
  });

  it("unlocks Cinderfen Watch only after Cinderfen Crossing is completed", () => {
    const campaign = createPostOverlookCampaign();
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const crossing = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_crossing")!;
    const watch = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_watch")!;

    expect(getCampaignNodeStatus(watch, campaign)).toBe("locked");

    const completed = completeCampaignNodeWithRewards({ campaign, hero, node: crossing });

    expect(completed.campaign.completedNodeIds).toContain("cinderfen_crossing");
    expect(completed.campaign.unlockedNodeIds).toContain("cinderfen_watch");
    expect(getCampaignNodeStatus(watch, completed.campaign)).toBe("available");
    expect(completed.nodeReward).toMatchObject({
      xp: 60,
      resources: { crowns: 40, stone: 20, iron: 20, aether: 12 },
      itemIds: ["scouts_bow"]
    });
  });

  it("grants item and completes the new caravan event when choosing protection", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "refugee_caravan"],
      resources: { crowns: 60, stone: 0, iron: 20, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "refugee_caravan")!;
    const choice = node.choices!.find((entry) => entry.id === "protect_them")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.campaign.resources.crowns).toBe(20);
    expect(applied.campaign.resources.iron).toBe(20);
    expect(applied.campaign.completedNodeIds).toContain("refugee_caravan");
    expect(applied.hero.inventory.some((instance) => instance.itemId === "scouts_bow")).toBe(true);
    expect(applied.hero.xp).toBe(40);
    expect(applied.hero.factionReputation.common_folk).toBe(hero.factionReputation.common_folk + 8);
    expect(applied.campaign.activeModifierIds).toContain("inspired_militia");
  });

  it("lets choices lock future nodes and clamps reputation", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      unlockedNodeIds: ["border_village", "old_stone_road"],
      resources: { crowns: 0, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 10,
        ashen_covenant: -10,
        sylvan_concord: 0,
        common_folk: 98,
        old_faith: 0
      }
    };
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "border_village")!;
    const target = CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!;
    const choice = {
      id: "test_lock",
      label: "Test Lock",
      description: "Synthetic consequence check.",
      reputationChanges: { common_folk: 10 },
      lockNodeIds: [target.id],
      onceOnly: true,
      completesNode: false
    };

    const applied = applyCampaignChoice({ campaign, hero, node: { ...node, choices: [choice] }, choice });

    expect(applied.ok).toBe(true);
    expect(applied.hero.factionReputation.common_folk).toBe(100);
    expect(applied.campaign.lockedNodeIds).toContain(target.id);
    expect(getCampaignNodeStatus(target, applied.campaign)).toBe("locked");
  });

  it("local support improves the next node resource reward and then expires", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      activeModifierIds: ["local_support"],
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "border_village")!;

    const completed = completeCampaignNodeWithRewards({ campaign, hero, node });

    expect(completed.nodeReward.resources.crowns).toBe(57);
    expect(completed.campaign.resources.crowns).toBe(57);
    expect(completed.campaign.activeModifierIds).not.toContain("local_support");
  });

  it("unlocks Marcher Camp after Old Stone Road and keeps it open after services", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road"],
      resources: { crowns: 90, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const choice = node.choices!.find((entry) => entry.id === "rest_and_recovery")!;

    expect(getCampaignNodeStatus(node, campaign)).toBe("available");
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.completedNode).toBe(false);
    expect(applied.campaign.completedNodeIds).not.toContain("marcher_camp");
    expect(getCampaignNodeStatus(node, applied.campaign)).toBe("available");
  });

  it("pays town service costs and tracks resources spent", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 90, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const choice = node.choices!.find((entry) => entry.id === "rest_and_recovery")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.campaign.resources.crowns).toBe(60);
    expect(applied.campaign.resourcesSpent.crowns).toBe(30);
    expect(applied.campaign.activeModifierIds).toContain("well_rested");
    expect(applied.campaign.townServiceUseCounts["marcher_camp:rest_and_recovery"]).toBe(1);
  });

  it("discounts Marcher Camp services when Common Folk reputation is friendly", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 90, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 10,
        ashen_covenant: -10,
        sylvan_concord: 0,
        common_folk: 25,
        old_faith: 0
      }
    };
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const choice = node.choices!.find((entry) => entry.id === "rest_and_recovery")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.campaign.resources.crowns).toBe(63);
    expect(applied.campaign.resourcesSpent.crowns).toBe(27);
  });

  it("improves Chapel Aether rewards when Old Faith reputation is friendly", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      resources: { crowns: 120, stone: 80, iron: 0, aether: 0 },
      completedNodeIds: ["old_stone_road", "aether_well_ruins"],
      unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "chapel_of_the_marches"],
      nodeRewardsClaimedIds: []
    });
    const hero = {
      ...createNewHeroSave("Aster", "shepherd", "temple_orphan"),
      factionReputation: {
        free_marches: 10,
        ashen_covenant: -10,
        sylvan_concord: 0,
        common_folk: 0,
        old_faith: 25
      }
    };
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "chapel_of_the_marches")!;
    const choice = node.choices!.find((entry) => entry.id === "repair_chapel")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(applied.ok).toBe(true);
    expect(applied.campaign.resources.aether).toBe(40);
    expect(applied.hero.factionReputation.old_faith).toBe(31);
  });

  it("adds minor Ashen pressure when Ashen Covenant reputation is hostile", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 10,
        ashen_covenant: -50,
        sylvan_concord: 0,
        common_folk: 0,
        old_faith: 0
      }
    };
    const ashenNode = CAMPAIGN_NODES.find((entry) => entry.id === "ashen_outpost")!;

    expect(getReputationBattleLaunchModifiers(hero, ashenNode).map((modifier) => modifier.id)).toEqual([
      "ashen_hostile_pressure"
    ]);
  });

  it("blocks town services when resources are insufficient", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 10, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const choice = node.choices!.find((entry) => entry.id === "hire_volunteers")!;

    const availability = getCampaignChoiceAvailability({ campaign, hero, node, choice });
    const applied = applyCampaignChoice({ campaign, hero, node, choice });

    expect(availability.ok).toBe(false);
    expect(availability.reasons).toContain("Need 50 Crowns");
    expect(applied.ok).toBe(false);
    expect(applied.campaign.resources.crowns).toBe(10);
  });

  it("adds purchased town items to inventory and prevents one-time repurchase", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 120, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const choice = node.choices!.find((entry) => entry.id === "purchase_emberglass_wand")!;

    const applied = applyCampaignChoice({ campaign, hero, node, choice });
    const repeated = applyCampaignChoice({ campaign: applied.campaign, hero: applied.hero, node, choice });

    expect(applied.ok).toBe(true);
    const purchased = applied.hero.inventory.find((instance) => instance.itemId === "emberglass_wand");
    expect(purchased).toBeDefined();
    expect(purchased?.source).toBe("campaign_choice:marcher_camp:purchase_emberglass_wand");
    expect(applied.campaign.townServiceClaimedIds).toContain("marcher_camp:purchase_emberglass_wand");
    expect(applied.campaign.resources.crowns).toBe(60);
    expect(repeated.ok).toBe(false);
    expect(repeated.reason).toContain("Already purchased");
  });

  it("lets repeatable town services run more than once", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 100, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const choice = node.choices!.find((entry) => entry.id === "buy_supplies")!;

    const first = applyCampaignChoice({ campaign, hero, node, choice });
    const second = applyCampaignChoice({ campaign: first.campaign, hero: first.hero, node, choice });

    expect(first.ok).toBe(true);
    expect(second.ok).toBe(true);
    expect(second.campaign.resources.crowns).toBe(20);
    expect(second.campaign.resources.stone).toBe(60);
    expect(second.campaign.resources.iron).toBe(36);
    expect(second.campaign.resources.aether).toBe(20);
    expect(second.campaign.townServiceUseCounts["marcher_camp:buy_supplies"]).toBe(2);
  });

  it("applies Marcher Camp next-battle modifiers through launch consumption", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 90, stone: 0, iron: 0, aether: 0 },
      nodeRewardsClaimedIds: []
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const town = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const rest = town.choices!.find((entry) => entry.id === "rest_and_recovery")!;
    const serviced = applyCampaignChoice({ campaign, hero, node: town, choice: rest });
    const nextBattle = CAMPAIGN_NODES.find((entry) => entry.id === "aether_well_ruins")!;

    const consumed = consumeBattleCampaignModifiers({ campaign: serviced.campaign, node: nextBattle });

    expect(consumed.launchModifiers.map((modifier) => modifier.id)).toEqual(["well_rested"]);
    expect(consumed.campaign.activeModifierIds).not.toContain("well_rested");
  });
});
