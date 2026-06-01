import { describe, expect, it } from "vitest";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { createNewHeroSave } from "../data/heroes";
import { createCampaignChapterPanelViewModels } from "./CampaignChapterPanelViewModel";
import { createCampaignChoiceViewModels } from "./CampaignChoiceViewModel";
import { createCampaignNodeCardViewModel } from "./CampaignNodeCardViewModel";
import { formatCampaignMissionPanelNextStep, renderNodeDetails } from "./CampaignNodePanel";
import { createCampaignRouteStatusViewModel } from "./CampaignRouteStatusViewModel";

describe("campaign presentation view models", () => {
  it("keeps campaign node card selectors and labels stable", () => {
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_aftermath")!;

    const card = createCampaignNodeCardViewModel({ node, status: "completed", selected: true });

    expect(card.testId).toBe("campaign-node-cinderfen_aftermath");
    expect(card.cssClass).toContain("campaign-node completed selected");
    expect(card.cssClass).toContain("chapter-cinderfen_road");
    expect(card.style).toBe("--node-x: 88%; --node-y: 14%");
    expect(card.mapX).toBe(88);
    expect(card.mapY).toBe(14);
    expect(card.nodeTypeLabel).toBe("Event");
    expect(card.statusLabel).toBe("Completed");
  });

  it("labels completed battle nodes as replayable when campaign state is present", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["ashen_outpost"],
      unlockedNodeIds: ["ashen_outpost"],
      nodeRewardsClaimedIds: ["ashen_outpost"]
    });
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "ashen_outpost")!;

    const card = createCampaignNodeCardViewModel({ node, status: "completed", selected: true, campaignSave: campaign });

    expect(card.statusLabel).toBe("Replayable (Completed)");
    expect(card.rewardStateLabel).toBe("Campaign node reward already claimed");
  });

  it("renders campaign briefing, mission type, modifier, and reward preview copy", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      unlockedNodeIds: ["ashen_outpost"]
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "ashen_outpost")!;

    const html = renderNodeDetails({ node, campaignSave: campaign, heroSave: hero });

    expect(html).toContain("Mission type");
    expect(html).toContain("Assault");
    expect(html).toContain("Primary objective");
    expect(html).toContain("Defeat Captain Malrec");
    expect(html).toContain("Scenario modifiers");
    expect(html).toContain("Fortified Enemy");
    expect(html).toContain("Reward preview");
    expect(html).toContain("champion relic eligibility");
    expect(html).toContain("Act 1 Step 6: Ashen Outpost Finale");
    expect(html).toContain("Pacing tier");
    expect(html).toContain("Milestone");
    expect(html).toContain("Equip the relic, spend skill points");
    expect(html).toContain("Enemy doctrine: Fortress");
    expect(html).toContain("The enemy will preserve reserves");
    expect(html).toContain("Counterplay");
    expect(html).toContain("Attack economy first");
    expect(html).toContain("Elite squad");
    expect(html).toContain("Cinder Iron Guard");
    expect(html).toContain("Pre-battle intelligence");
    expect(html).toContain("Tactical plan");
    expect(html).toContain("Resource Push");
    expect(html).toContain("Selected plan");
    expect(html).toContain("Guarded Advance");
    expect(html).toContain("data-tactical-plan=\"champion_hunt\"");
  });

  it("renders mission-local Lume Network briefing for Aether Well Ruins only", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["aether_well_ruins", "bandit_hillfort"]
    });
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const aetherWell = CAMPAIGN_NODES.find((entry) => entry.id === "aether_well_ruins")!;
    const hillfort = CAMPAIGN_NODES.find((entry) => entry.id === "bandit_hillfort")!;

    const aetherHtml = renderNodeDetails({ node: aetherWell, campaignSave: campaign, heroSave: hero });
    const hillfortHtml = renderNodeDetails({ node: hillfort, campaignSave: campaign, heroSave: hero });

    expect(aetherHtml).toContain("Linked Ward");
    expect(aetherHtml).toContain("Hold two linked sites to wake a Lume Ward. Enemy recapture severs the link.");
    expect(aetherHtml).toContain("8% less incoming damage");
    expect(hillfortHtml).not.toContain("Hold two linked sites to wake a Lume Ward");
  });

  it("renders Act 1 locked reasons and onboarding hints on early campaign nodes", () => {
    const campaign = createStartedCampaignSave();
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const border = CAMPAIGN_NODES.find((entry) => entry.id === "border_village")!;
    const oldRoad = CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!;

    const borderHtml = renderNodeDetails({ node: border, campaignSave: campaign, heroSave: hero });
    const oldRoadHtml = renderNodeDetails({ node: oldRoad, campaignSave: campaign, heroSave: hero });

    expect(borderHtml).toContain("Act 1 Step 2: First Campaign Battle");
    expect(borderHtml).toContain("First Campaign Battle");
    expect(borderHtml).toContain("Ready to start.");
    expect(oldRoadHtml).toContain("Act 1 Step 3: Base Development");
    expect(oldRoadHtml).toContain("Complete Salto Outskirts first.");
    expect(oldRoadHtml).toContain("Train Workers early");
  });

  it("keeps Act 1 mission card premises concise while preserving stable node ids", () => {
    const act1Nodes = [
      ["border_village", "Salto Outskirts", "A first stand outside Salto"],
      ["old_stone_road", "Old Stone Road", "The trade road tests a cleaner economy"],
      ["aether_well_ruins", "Aether Well Ruins", "A ruined well on Broken Ford"],
      ["chapel_of_the_marches", "Chapel of the Barrosan Marches", "A roadside chapel offers one clear support choice"],
      ["marcher_camp", "Marcher Camp", "A Barrosan support camp"],
      ["bandit_hillfort", "Bandit Hillfort", "A raider-backed hillfort"],
      ["refugee_caravan", "Refugee Caravan", "A vulnerable caravan"],
      ["ashen_outpost", "Ashen Outpost", "The Act 1 finale"]
    ] as const;

    act1Nodes.forEach(([id, name, premise]) => {
      const node = CAMPAIGN_NODES.find((entry) => entry.id === id)!;
      expect(node.id).toBe(id);
      expect(node.name).toBe(name);
      expect(node.description).toContain(premise);
      expect(node.description.length).toBeLessThanOrEqual(120);
    });
  });

  it("formats locked reasons or recommended next steps for compact mission cards", () => {
    const freshCampaign = createStartedCampaignSave();
    const postOldRoad = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["border_village", "old_stone_road", "aether_well_ruins", "bandit_hillfort", "refugee_caravan", "marcher_camp"]
    });
    const aetherWell = CAMPAIGN_NODES.find((entry) => entry.id === "aether_well_ruins")!;
    const oldRoad = CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!;
    const ashenOutpost = CAMPAIGN_NODES.find((entry) => entry.id === "ashen_outpost")!;
    const postFinale = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["ashen_outpost"],
      unlockedNodeIds: ["ashen_outpost", "cinderfen_overlook"],
      nodeRewardsClaimedIds: ["ashen_outpost"]
    });

    expect(formatCampaignMissionPanelNextStep(aetherWell, freshCampaign)).toBe("Complete Old Stone Road first.");
    expect(formatCampaignMissionPanelNextStep(aetherWell, postOldRoad)).toContain("Clear Bandit Hillfort");
    expect(formatCampaignMissionPanelNextStep(oldRoad, postOldRoad)).toContain("Replay this road");
    expect(formatCampaignMissionPanelNextStep(ashenOutpost, postFinale)).toContain("Act 1 complete");
  });

  it("formats chapter card progress without involving the scene", () => {
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road", "ashen_outpost", "cinderfen_overlook"],
      unlockedNodeIds: ["border_village", "old_stone_road", "ashen_outpost", "cinderfen_overlook"]
    });

    const chapterCards = createCampaignChapterPanelViewModels(campaign);

    expect(chapterCards.find((entry) => entry.chapter.id === "border_marches")).toMatchObject({
      testId: "campaign-chapter-border_marches",
      cssClass: "chapter-card unlocked",
      progressText: "3/8 current nodes complete"
    });
    expect(chapterCards.find((entry) => entry.chapter.id === "cinderfen_road")).toMatchObject({
      testId: "campaign-chapter-cinderfen_road",
      cssClass: "chapter-card unlocked",
      progressText: "1/5 current nodes complete"
    });
  });

  it("separates town service choice labels from event choice rendering", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["cinderfen_overlook"],
      unlockedNodeIds: ["cinderfen_waystation"],
      resources: { crowns: 80, stone: 0, iron: 0, aether: 40 }
    });
    const waystation = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;

    const choices = createCampaignChoiceViewModels({
      node: waystation,
      status: "available",
      campaignSave: campaign,
      heroSave: hero
    });
    const shrineAttunement = choices.find((entry) => entry.choice.id === "shrine_attunement")!;

    expect(shrineAttunement.locked).toBe(false);
    expect(shrineAttunement.costSummary).toBe("12 Aether");
    expect(shrineAttunement.outcomeSummary).toBe("Keeps this node open.");
    expect(shrineAttunement.availabilityLabel).toBe("Repeatable service.");
    expect(shrineAttunement.ctaLabel).toBe("Use Service");
  });

  it("surfaces stock-purchase metadata for town services", () => {
    const hero = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const campaign = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["border_village", "old_stone_road"],
      unlockedNodeIds: ["marcher_camp"],
      resources: { crowns: 120, stone: 0, iron: 20, aether: 20 }
    });
    const camp = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;

    const choices = createCampaignChoiceViewModels({
      node: camp,
      status: "available",
      campaignSave: campaign,
      heroSave: hero
    });
    const stockPurchase = choices.find((entry) => entry.choice.id === "purchase_emberglass_wand")!;

    expect(stockPurchase.ctaLabel).toBe("Purchase");
    expect(stockPurchase.availabilityLabel).toBe("Purchase once.");
    expect(stockPurchase.stock).toMatchObject({
      name: "Emberglass Wand",
      rarityLabel: "Common",
      slotLabel: "Weapon"
    });
  });

  it("builds route-complete status copy only after Cinderfen Aftermath", () => {
    const incomplete = createStartedCampaignSave();
    const complete = createStartedCampaignSave({
      ...createStartedCampaignSave(),
      completedNodeIds: ["cinderfen_aftermath"]
    });

    expect(createCampaignRouteStatusViewModel(incomplete)).toBeUndefined();
    expect(createCampaignRouteStatusViewModel(complete)).toMatchObject({
      isComplete: true,
      title: "Cinderfen route secured",
      statusMessage: "Cinderfen route secured. Chapter 2 route complete; future Cinderfen roads will open later."
    });
  });
});
