import { describe, expect, it } from "vitest";
import {
  applyCampaignChoice,
  completeCampaignNode,
  completeCampaignNodeWithRewards,
  createStartedCampaignSave,
  getCampaignChoiceAvailability,
  getCampaignNodeStatus
} from "./CampaignRules";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { consumeBattleCampaignModifiers } from "../data/campaignModifiers";
import { createNewHeroSave } from "../data/heroes";

describe("campaign rules", () => {
  it("unlocks the first node and gates later nodes by prerequisites", () => {
    const campaign = createStartedCampaignSave();
    const borderVillage = CAMPAIGN_NODES.find((node) => node.id === "border_village");
    const oldRoad = CAMPAIGN_NODES.find((node) => node.id === "old_stone_road");

    expect(borderVillage && getCampaignNodeStatus(borderVillage, campaign)).toBe("available");
    expect(oldRoad && getCampaignNodeStatus(oldRoad, campaign)).toBe("locked");
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
