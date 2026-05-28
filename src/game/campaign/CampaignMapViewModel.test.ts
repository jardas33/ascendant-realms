import { describe, expect, it } from "vitest";
import { createStartedCampaignSave, getCampaignChapterStatus } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { createNewHeroSave } from "../data/heroes";
import { formatChoiceModifierSummary, formatChoiceReputationSummary, formatChoiceRewardSummary } from "./CampaignChoicePanel";
import { canStartCampaignNode } from "./CampaignNavigation";
import { createCampaignMapViewModel } from "./CampaignMapViewModel";
import { createCampaignNodeCardViewModel } from "./CampaignNodeCardViewModel";
import { renderNodeButton, renderNodeDetails } from "./CampaignNodePanel";
import { formatResourceRewards } from "./CampaignResourcePanel";
import { renderRivalIntelPanel } from "./RivalIntelPanel";
import { renderRetinuePanel } from "./RetinuePanel";

describe("campaign map presentation helpers", () => {
  it("creates a stable view model with selected node and node statuses", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave();

    const viewModel = createCampaignMapViewModel({
      heroSave: hero,
      campaignSave: campaign,
      selectedNodeId: "border_village"
    });

    expect(viewModel.campaignStateLabel).toBe("Live");
    expect(viewModel.selectedNode?.id).toBe("border_village");
    expect(viewModel.nodes.find((entry) => entry.node.id === "border_village")).toMatchObject({
      status: "available",
      selected: true
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "old_stone_road")?.status).toBe("locked");
    expect(viewModel.chapters.find((entry) => entry.chapter.id === "border_marches")).toMatchObject({
      status: "unlocked",
      completedNodeCount: 0,
      currentNodeCount: 8
    });
    expect(viewModel.chapters.find((entry) => entry.chapter.id === "cinderfen_road")).toMatchObject({
      status: "locked",
      completedNodeCount: 0,
      currentNodeCount: 5
    });
  });

  it("shows Chapter 2 as unlocked after Ashen with a playable event gate before the battle", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
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
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_overlook"
    });
    const eventNode = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const waystationNode = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const battleNode = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_crossing")!;
    const watchNode = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_watch")!;
    const aftermathNode = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_aftermath")!;

    const viewModel = createCampaignMapViewModel({
      heroSave: hero,
      campaignSave: campaign,
      selectedNodeId: "cinderfen_overlook"
    });
    const chapterTwo = viewModel.chapters.find((entry) => entry.chapter.id === "cinderfen_road")!;
    const html = renderNodeDetails({ node: eventNode, campaignSave: campaign, heroSave: hero });

    expect(getCampaignChapterStatus(chapterTwo.chapter, campaign)).toBe("unlocked");
    expect(chapterTwo).toMatchObject({
      status: "unlocked",
      completedNodeCount: 0,
      currentNodeCount: 5
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "cinderfen_overlook")).toMatchObject({
      status: "available",
      selected: true
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "cinderfen_crossing")).toMatchObject({
      status: "locked",
      selected: false
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "cinderfen_waystation")).toMatchObject({
      status: "locked",
      selected: false
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "cinderfen_watch")).toMatchObject({
      status: "locked",
      selected: false
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "cinderfen_aftermath")).toMatchObject({
      status: "locked",
      selected: false
    });
    expect(canStartCampaignNode(eventNode, campaign)).toBe(false);
    expect(canStartCampaignNode(waystationNode, campaign)).toBe(false);
    expect(canStartCampaignNode(battleNode, campaign)).toBe(false);
    expect(canStartCampaignNode(watchNode, campaign)).toBe(false);
    expect(canStartCampaignNode(aftermathNode, campaign)).toBe(false);
    expect(html).toContain("Scout the Causeway");
    expect(html).toContain("Aid the Marsh Refugees");
    expect(html).toContain("Study the Cinders");
    expect(html).toContain("Raise Malrec&#039;s Standard");
    expect(html).toContain("Requires trophy Malrec&#039;s Outpost Standard");
    expect(html).toContain("Cost: 30 Crowns");
    expect(html).toContain("Modifiers: Gain Local Support");
    expect(html).toContain("Outcome: Completes this node.");
    expect(html).not.toContain("Future battle locked");
  });

  it("shows the Malrec trophy Cinderfen choice as available when the standard was earned", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
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
      resources: { crowns: 100, stone: 0, iron: 0, aether: 30 },
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_overlook",
      rivalTrophies: [
        {
          trophyId: "trophy_malrec_outpost_standard",
          enemyHeroId: "captain_malrec",
          earnedAt: "2026-05-03T12:00:00.000Z",
          sourceNodeId: "ashen_outpost",
          label: "Malrec's Outpost Standard",
          description: "The torn fortress standard of Captain Malrec's Ashen Outpost command."
        }
      ]
    });
    const eventNode = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;

    const html = renderNodeDetails({ node: eventNode, campaignSave: campaign, heroSave: hero });

    expect(html).toContain("data-campaign-choice=\"raise_malrecs_standard\"");
    expect(html).toContain("Raise Malrec&#039;s Standard");
    expect(html).toContain("Rewards: 10 XP");
    expect(html).toContain("Reputation: +3 The Free Marches");
    expect(html).toContain("Modifiers: Gain Well Rested");
    expect(html).not.toContain("Requires trophy Malrec&#039;s Outpost Standard");
  });

  it("shows Cinderfen Crossing launch details after the overlook event is completed", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook"
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
        "cinderfen_waystation",
        "cinderfen_crossing"
      ],
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_crossing"
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_crossing")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(canStartCampaignNode(node, campaign)).toBe(true);
    expect(html).toContain("Cinderfen Crossing");
    expect(html).toContain("Hexfire Cult");
    expect(html).toContain("Scout&#039;s Bow");
  });

  it("shows Cinderfen Watch launch details after Cinderfen Crossing is completed", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_crossing"
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
        "cinderfen_waystation",
        "cinderfen_crossing",
        "cinderfen_watch"
      ],
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_watch"
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_watch")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(canStartCampaignNode(node, campaign)).toBe(true);
    expect(html).toContain("Cinderfen Watch");
    expect(html).toContain("Normal");
    expect(html).toContain("Hexfire Cult");
    expect(html).toContain("40 Crowns, 22 Stone, 18 Iron, 10 Aether");
  });

  it("shows Cinderfen Waystation services after Overlook is completed", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook"
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
        "cinderfen_waystation",
        "cinderfen_crossing"
      ],
      resources: { crowns: 80, stone: 0, iron: 0, aether: 40 },
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_waystation"
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(canStartCampaignNode(node, campaign)).toBe(false);
    expect(html).toContain("Town Services");
    expect(html).toContain("Marsh Guides");
    expect(html).toContain("Next Cinderfen battle: wider base vision and earlier enemy warnings.");
    expect(html).toContain("Cost: 35 Crowns");
    expect(html).toContain("Modifiers: Gain Marsh Guides");
    expect(html).toContain("Ash Filters");
    expect(html).toContain("Next Cinderfen battle: the hero starts with a small HP and Mana buffer.");
    expect(html).toContain("Cost: 35 Crowns, 15 Aether");
    expect(html).toContain("Refugee Scouts");
    expect(html).toContain("Local scouts confirm the Cinder Shrine and central guardians");
    expect(html).toContain("Reputation: +2 Common Folk");
    expect(html).toContain("Shrine Attunement");
    expect(html).toContain("Cinder Shrine Surge grants +5 extra Aether");
    expect(html).toContain("Modifiers: Gain Shrine Attunement");
    expect(html).toContain("Outcome: Keeps this node open.");
    expect(html).toContain("Repeatable service.");
    expect(html).toContain("One-time service.");
  });

  it("shows Cinderfen Aftermath choices after Cinderfen Watch is completed", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: [
        "border_village",
        "old_stone_road",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_crossing",
        "cinderfen_watch"
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
        "cinderfen_waystation",
        "cinderfen_crossing",
        "cinderfen_watch",
        "cinderfen_aftermath"
      ],
      resources: { crowns: 80, stone: 40, iron: 0, aether: 30 },
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_aftermath"
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_aftermath")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(canStartCampaignNode(node, campaign)).toBe(false);
    expect(html).toContain("Cinderfen Aftermath");
    expect(html).toContain("One modest settlement choice");
    expect(html).toContain("Secure the Watch Road");
    expect(html).toContain("Cost: 45 Crowns, 18 Stone");
    expect(html).toContain("Rewards: 12 XP, 10 Stone");
    expect(html).toContain("Reputation: +4 The Free Marches");
    expect(html).toContain("Modifiers: Gain Local Support");
    expect(html).toContain("Aid the Fenfolk");
    expect(html).toContain("Cost: 40 Crowns");
    expect(html).toContain("Reputation: +5 Common Folk");
    expect(html).toContain("Study the Ashen Marks");
    expect(html).toContain("Cost: 18 Aether");
    expect(html).toContain("Pilgrim Crook");
    expect(html).toContain("Reputation: +4 Old Faith");
    expect(html).toContain("Display Malrec&#039;s Standard");
    expect(html).toContain("Requires trophy Malrec&#039;s Outpost Standard");
    expect(html).toContain("Outcome: Completes this node.");
  });

  it("shows Cinderfen route completion while leaving Chapter 1 stable", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
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
        "ashen_outpost",
        "cinderfen_overlook",
        "cinderfen_crossing",
        "cinderfen_watch",
        "cinderfen_aftermath"
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
        "cinderfen_waystation",
        "cinderfen_crossing",
        "cinderfen_watch",
        "cinderfen_aftermath"
      ],
      selectedChapterId: "cinderfen_road",
      selectedNodeId: "cinderfen_aftermath"
    });

    const viewModel = createCampaignMapViewModel({
      heroSave: hero,
      campaignSave: campaign,
      selectedNodeId: "cinderfen_aftermath"
    });
    const chapterOne = viewModel.chapters.find((entry) => entry.chapter.id === "border_marches")!;
    const chapterTwo = viewModel.chapters.find((entry) => entry.chapter.id === "cinderfen_road")!;

    expect(viewModel.progressSummary).toBe("12/13 nodes completed");
    expect(chapterOne).toMatchObject({
      status: "unlocked",
      completedNodeCount: 8,
      currentNodeCount: 8
    });
    expect(chapterTwo).toMatchObject({
      status: "unlocked",
      completedNodeCount: 4,
      currentNodeCount: 5
    });
    expect(viewModel.nodes.find((entry) => entry.node.id === "border_village")?.status).toBe("completed");
    expect(viewModel.nodes.find((entry) => entry.node.id === "cinderfen_aftermath")).toMatchObject({
      status: "completed",
      selected: true
    });
  });

  it("shows replay, reward-claimed, optional objective, and build-hint copy for completed battle nodes", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["ashen_outpost"],
      unlockedNodeIds: ["ashen_outpost"],
      nodeRewardsClaimedIds: ["ashen_outpost"],
      optionalObjectiveCompletionIds: ["ashen_outpost:capture_burned_shrine"]
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "ashen_outpost")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(canStartCampaignNode(node, campaign)).toBe(true);
    expect(html).toContain("Battle - Replayable");
    expect(html).toContain("Replay reward");
    expect(html).toContain("Campaign node reward already claimed");
    expect(html).toContain("Burned Shrine: Recorded");
    expect(html).toContain("Build hint: Commander");
  });

  it("keeps future placeholder nodes upcoming and impossible to launch", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["cinderfen_aftermath"],
      unlockedNodeIds: ["cinderfen_future_spur"]
    });
    const placeholderNode = {
      ...CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_aftermath")!,
      id: "cinderfen_future_spur",
      name: "Cinderfen Future Spur",
      description: "Future Chapter 2 content placeholder.",
      isPlaceholder: true,
      placeholderDescription: "More Cinderfen content coming later.",
      prerequisites: ["cinderfen_aftermath"],
      choices: undefined,
      unlocks: []
    };
    const status = "locked" as const;

    const buttonHtml = renderNodeButton(createCampaignNodeCardViewModel({ node: placeholderNode, status, selected: false }));
    const detailsHtml = renderNodeDetails({ node: placeholderNode, campaignSave: campaign, heroSave: hero });

    expect(canStartCampaignNode(placeholderNode, campaign)).toBe(false);
    expect(buttonHtml).toContain("Event - Upcoming");
    expect(detailsHtml).toContain("Event - Upcoming");
    expect(detailsHtml).toContain("No battle launch");
    expect(detailsHtml).toContain("More Cinderfen content coming later.");
  });

  it("shows reputation ranks and active reputation effects in the view model", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 25,
        ashen_covenant: -50,
        sylvan_concord: 0,
        common_folk: 50,
        old_faith: 25
      }
    };
    const campaign = createStartedCampaignSave();

    const viewModel = createCampaignMapViewModel({
      heroSave: hero,
      campaignSave: campaign,
      selectedNodeId: "border_village"
    });

    expect(viewModel.reputation.rows.find((row) => row.factionId === "common_folk")).toMatchObject({
      value: 50,
      rankLabel: "Honored"
    });
    expect(viewModel.reputation.rows.find((row) => row.factionId === "ashen_covenant")?.rankLabel).toBe("Hostile");
    expect(viewModel.reputation.activeEffects.map((effect) => effect.id)).toEqual([
      "common_folk_friendly_services",
      "free_marches_friendly_stronghold",
      "old_faith_friendly_chapel",
      "ashen_covenant_hostile_pressure"
    ]);
  });

  it("shows known rival intel in the view model, panel, and selected node preview", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins"],
      rivals: [
        {
          enemyHeroId: "veyra_cinders",
          encounters: 1,
          defeats: 0,
          victoriesAgainstPlayer: 0,
          lastEncounterNodeId: "aether_well_ruins",
          lastOutcome: "escaped",
          disposition: "wary",
          activeModifiers: ["rival_wary_hp_5"],
          isKnownToPlayer: true
        }
      ],
      rivalTrophies: [
        {
          trophyId: "trophy_veyra_cinder_lens",
          enemyHeroId: "veyra_cinders",
          earnedAt: "2026-05-02T19:58:00.000Z",
          sourceNodeId: "aether_well_ruins",
          label: "Cinder-Seer's Cracked Lens",
          description: "A cracked aether lens recovered after Veyra of the Cinders was driven from the ruins.",
          effect: "First defeat claimed: +20 Aether, +90 XP, and +1 Old Faith reputation."
        }
      ]
    });

    const viewModel = createCampaignMapViewModel({
      heroSave: hero,
      campaignSave: campaign,
      selectedNodeId: "aether_well_ruins"
    });
    const panelHtml = renderRivalIntelPanel(campaign);
    const nodeHtml = renderNodeDetails({
      node: CAMPAIGN_NODES.find((entry) => entry.id === "aether_well_ruins")!,
      campaignSave: campaign,
      heroSave: hero
    });

    expect(viewModel.rivalIntel[0]).toMatchObject({
      enemyHeroId: "veyra_cinders",
      lastOutcomeLabel: "Escaped",
      dispositionLabel: "Wary",
      trophyLabel: "Cinder-Seer's Cracked Lens",
      firstDefeatRewardClaimed: true
    });
    expect(viewModel.rivalTrophies[0]).toMatchObject({
      label: "Cinder-Seer's Cracked Lens",
      enemyHeroName: "Veyra of the Cinders"
    });
    expect(panelHtml).toContain("Rival Intel");
    expect(panelHtml).toContain("Veyra of the Cinders");
    expect(panelHtml).toContain("+5% HP next encounter");
    expect(panelHtml).toContain("One-time first-defeat reward: Claimed");
    expect(panelHtml).toContain("Rival Trophies");
    expect(panelHtml).toContain("First-defeat trophies are cosmetic records claimed once");
    expect(panelHtml).toContain("Cinder-Seer&#039;s Cracked Lens");
    expect(panelHtml).toContain("First defeat claimed: +20 Aether");
    expect(nodeHtml).toContain("Rival Status");
    expect(nodeHtml).toContain("Enemy Commander");
    expect(nodeHtml).toContain("Veyra of the Cinders, Hexfire Seer");
    expect(nodeHtml).toContain("Hexfire Bolt");
    expect(nodeHtml).toContain("Escaped - Wary");
  });

  it("previews first-encounter rival commander copy before the rival is known", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "bandit_hillfort"]
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "bandit_hillfort")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(html).toContain("Enemy Commander");
    expect(html).toContain("Gorak Emberhand, Ashen Raider Captain");
    expect(html).toContain("Rival Status");
    expect(html).toContain("Unseen rival - first encounter");
    expect(html).toContain("First encounter: no rival modifier is active.");
    expect(html).toContain("Ember Strike");
    expect(html).toContain("Rally Raiders");
  });

  it("formats resource and choice reward summaries without scene state", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "refugee_caravan")!;
    const choice = node.choices!.find((entry) => entry.id === "demand_tribute")!;

    expect(formatResourceRewards({ crowns: 90, stone: 0 })).toEqual(["90 Crowns"]);
    expect(formatChoiceRewardSummary(choice, hero, node)).toContain("65 Crowns");
    expect(formatChoiceModifierSummary(choice, hero, node)).toContain("Gain Angered Raiders");
    expect(formatChoiceReputationSummary(choice, hero, node)).toContain("-8 Common Folk (to -8 Neutral)");
  });

  it("previews the resulting reputation rank on choice cards", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      factionReputation: {
        free_marches: 10,
        ashen_covenant: -10,
        sylvan_concord: 0,
        common_folk: 20,
        old_faith: 0
      }
    };
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "refugee_caravan")!;
    const choice = node.choices!.find((entry) => entry.id === "protect_them")!;

    expect(formatChoiceReputationSummary(choice, hero, node)).toContain("+8 Common Folk (to +28 Friendly)");
  });

  it("renders town service details with stable choice actions", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "marcher_camp"],
      resources: { crowns: 120, stone: 0, iron: 20, aether: 20 },
      nodeRewardsClaimedIds: []
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(html).toContain("Town Services");
    expect(html).toContain("data-campaign-choice=\"rest_and_recovery\"");
    expect(html).toContain("Purchase Emberglass Wand");
    expect(html).toContain("Repeatable service.");
  });

  it("renders Retinue Camp capacity, death rule, and Training Yard II bonus copy", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      strongholdUpgradeRanks: { training_yard_ii: 1 },
      retinueUnits: [
        {
          retinueUnitId: "retinue:test:militia",
          unitTypeId: "militia",
          name: "Gate Militia",
          rank: "veteran",
          xp: 140,
          kills: 3,
          sourceBattleId: "old_stone_road",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active"
        }
      ]
    });

    const html = renderRetinuePanel(campaign);

    expect(html).toContain("1/3 active");
    expect(html).toContain("Training Yard II");
    expect(html).toContain("+1 capacity active");
    expect(html).toContain("Retinue death is permanent in V1");
    expect(html).toContain("Veteran Militia");
    expect(html).toContain("140/230 XP to Elite");
    expect(html).toContain("Dismiss from Retinue");
  });
});
