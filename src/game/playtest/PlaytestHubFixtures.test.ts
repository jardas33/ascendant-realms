import { describe, expect, it } from "vitest";
import { createPlaytestHubBattleLaunchRequest, createPlaytestHubCampaignSave, createPlaytestHubHeroSave, createPlaytestHubResultsData } from "./PlaytestHubFixtures";

describe("PlaytestHubFixtures", () => {
  it("creates readable hero, inventory, relic, and Retinue preview fixtures without changing stable ids", () => {
    const hero = createPlaytestHubHeroSave();
    expect(hero.heroName).toBe("Aster");
    expect(hero.inventory.map((item) => item.itemId)).toEqual(
      expect.arrayContaining(["weathered_command_sword", "emberbrand_shard", "cinderseer_focus", "oathbound_aegis"])
    );
    expect(hero.equipment.relic).toBe("playtest:emberbrand_shard");

    const campaign = createPlaytestHubCampaignSave({ retinueMode: "recovering" });
    expect(campaign.selectedNodeId).toBe("border_village");
    expect(campaign.retinueUnits.some((unit) => unit.status === "recovering" && unit.recoveryMissionsRemaining === 1)).toBe(true);
  });

  it("marks every hub battle launch as no-save/no-reward and preserves Tutorial protection", () => {
    const ordinary = createPlaytestHubBattleLaunchRequest("battle_selected_hero");
    expect(ordinary.rewardsDisabled).toBe(true);
    expect(ordinary.privatePlaytestHubScenarioId).toBe("battle_selected_hero");
    expect(ordinary.privatePlaytestNotice).toContain("not saved");
    expect(ordinary.mode).toBe("campaign_node");

    const performanceLume = createPlaytestHubBattleLaunchRequest("perf_lume_auto");
    expect(performanceLume.rewardsDisabled).toBe(true);
    expect(performanceLume.privatePlaytestHubScenarioId).toBe("perf_lume_auto");
    expect(performanceLume.privatePlaytestDemoId).toBe("aether_well_lume_private_demo");
    expect(performanceLume.campaignNodeId).toBe("aether_well_ruins");

    const benchmarkRepresentative = createPlaytestHubBattleLaunchRequest("benchmark_battle_tier_m_representative");
    expect(benchmarkRepresentative.rewardsDisabled).toBe(true);
    expect(benchmarkRepresentative.privatePlaytestHubScenarioId).toBe("benchmark_battle_tier_m_representative");
    expect(benchmarkRepresentative.privatePlaytestDemoId).toBe("aether_well_lume_private_demo");
    expect(benchmarkRepresentative.campaignNodeId).toBe("aether_well_ruins");

    const tutorial = createPlaytestHubBattleLaunchRequest("tutorial_proving_grounds");
    expect(tutorial.mode).toBe("tutorial");
    expect(tutorial.privatePlaytestHubScenarioId).toBe("tutorial_proving_grounds");
    expect(tutorial.privatePlaytestNotice).toContain("not saved");
  });

  it("creates isolated ordinary, defeat, and private-demo Results fixtures", () => {
    const victory = createPlaytestHubResultsData("victory");
    expect(victory.launchRequest).toBeDefined();
    expect(victory.launchRequest?.rewardsDisabled).toBe(true);
    expect(victory.launchRequest?.privatePlaytestHubScenarioId).toBe("ordinary_results");
    expect(victory.campaignResult?.nodeRewardClaimed).toBe(true);

    const defeat = createPlaytestHubResultsData("defeat");
    expect(defeat.stats.outcome).toBe("defeat");
    expect(defeat.launchRequest).toBeDefined();
    expect(defeat.launchRequest?.privatePlaytestHubScenarioId).toBe("defeat_results");
    expect(defeat.campaignResult?.nodeRewardClaimed).toBe(false);

    const privateDemo = createPlaytestHubResultsData("private-demo");
    expect(privateDemo.launchRequest).toBeDefined();
    expect(privateDemo.launchRequest?.privatePlaytestHubScenarioId).toBe("private_demo_results");
    expect(privateDemo.launchRequest?.privatePlaytestDemoId).toBe("aether_well_lume_private_demo");
    expect(privateDemo.campaignResult).toBeUndefined();
  });
});
