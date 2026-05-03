import { describe, expect, it } from "vitest";
import {
  DEFAULT_PLAYTEST_STRONGHOLD_PROFILES,
  DEFAULT_PLAYTEST_SCENARIOS,
  analyzePlaytestTelemetry,
  renderPlaytestMarkdownReport,
  runScriptedBattlePlaytest,
  runScriptedPlaytestSuite
} from "./ScriptedBattlePlaytest";
import { CAMPAIGN_NODES } from "../data/campaignNodes";

describe("ScriptedBattlePlaytest", () => {
  const noStrongholdProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "no_stronghold")!;

  it("runs every current campaign battle node with the three core scripts and stronghold profiles", () => {
    const report = runScriptedPlaytestSuite();

    expect(report.telemetry).toHaveLength(216);
    expect(new Set(report.telemetry.map((run) => run.nodeId))).toEqual(
      new Set([
        "border_village",
        "old_stone_road",
        "aether_well_ruins",
        "bandit_hillfort",
        "ashen_outpost",
        "cinderfen_crossing"
      ])
    );
    expect(new Set(report.telemetry.map((run) => run.playerScript))).toEqual(
      new Set(["safe_beginner", "greedy_economy", "fast_army"])
    );
    expect(new Set(report.telemetry.map((run) => run.strongholdProfileId))).toEqual(
      new Set([
        "no_stronghold",
        "training_yard_path",
        "defensive_watch_post_path",
        "economy_quartermaster_path",
        "tier_two_quartermaster_path",
        "chapel_corner_path",
        "ranger_paths_path",
        "retinue_veteran_militia",
        "retinue_veteran_ranger",
        "retinue_mixed_veterans",
        "retinue_training_yard_path",
        "retinue_quartermaster_path"
      ])
    );
    expect(report.telemetry.some((run) => run.retinueUnits.includes("Veteran Militia"))).toBe(true);
  });

  it("includes the playable Chapter 2 battle while excluding non-battle event nodes", () => {
    const scenarioNodeIds = DEFAULT_PLAYTEST_SCENARIOS.map((scenario) => scenario.nodeId);
    const eventNodeIds = CAMPAIGN_NODES.filter((node) => node.nodeType === "event").map((node) => node.id);

    expect(CAMPAIGN_NODES.filter((node) => node.isPlaceholder).map((node) => node.id)).toEqual([]);
    expect(eventNodeIds).toEqual(expect.arrayContaining(["refugee_caravan", "cinderfen_overlook"]));
    expect(scenarioNodeIds).toEqual([
      "border_village",
      "old_stone_road",
      "aether_well_ruins",
      "bandit_hillfort",
      "ashen_outpost",
      "cinderfen_crossing"
    ]);
    eventNodeIds.forEach((nodeId) => {
      expect(scenarioNodeIds).not.toContain(nodeId);
    });
  });

  it("models the Cinder Shrine first-capture surge in Cinderfen scripts", () => {
    const run = runScriptedBattlePlaytest({
      scenario: { nodeId: "cinderfen_crossing", expectedDifficulty: "normal" },
      scriptId: "greedy_economy"
    });

    expect(run.commandLog).toEqual(expect.arrayContaining([expect.stringContaining("captured Cinder Shrine")]));
    expect(run.commandLog).toEqual(expect.arrayContaining([expect.stringContaining("Cinder Shrine Surge: 20 Aether")]));
  });

  it("captures opening timing and command telemetry for the tutorial battles", () => {
    const report = runScriptedPlaytestSuite({
      scenarios: [
        { nodeId: "border_village", expectedDifficulty: "easy" },
        { nodeId: "old_stone_road", expectedDifficulty: "easy" }
      ],
      scripts: ["safe_beginner", "greedy_economy", "fast_army"],
      strongholdProfiles: [noStrongholdProfile]
    });

    const borderSafe = report.telemetry.find(
      (run) => run.nodeId === "border_village" && run.playerScript === "safe_beginner"
    );
    const oldGreedy = report.telemetry.find(
      (run) => run.nodeId === "old_stone_road" && run.playerScript === "greedy_economy"
    );

    expect(borderSafe?.timeFirstSiteCaptured).toBeGreaterThan(0);
    expect(borderSafe?.timeBarracksPlaced).toBeGreaterThan(0);
    expect(borderSafe?.timeBarracksCompleted).toBeGreaterThan(borderSafe?.timeBarracksPlaced ?? 0);
    expect(borderSafe?.timeFirstEnemyWarning).toBeGreaterThan(0);
    expect(borderSafe?.commandLog.some((entry) => entry.includes("select hero"))).toBe(true);
    expect(oldGreedy?.timeBarracksCompleted).toBeGreaterThan(oldGreedy?.timeFirstEnemyWarning ?? 0);
  });

  it("analyzes results and renders a markdown report with tuning prompts", () => {
    const report = runScriptedPlaytestSuite({
      scenarios: [{ nodeId: "ashen_outpost", expectedDifficulty: "normal" }],
      scripts: ["safe_beginner", "greedy_economy", "fast_army"],
      strongholdProfiles: [noStrongholdProfile]
    });
    const analysis = analyzePlaytestTelemetry(report.telemetry);
    const markdown = renderPlaytestMarkdownReport({ ...report, analysis });

    expect(analysis.nodeSummaries).toHaveLength(1);
    expect(analysis.suggestedTuningChanges.length).toBeGreaterThan(0);
    expect(markdown).toContain("# Automated Playtest Telemetry");
    expect(markdown).toContain("## Suggested Tuning Changes");
    expect(markdown).toContain("Ashen Outpost");
  });

  it("separates fair-opening strategy spread from a structural too-hard verdict", () => {
    const report = runScriptedPlaytestSuite({
      scenarios: [{ nodeId: "ashen_outpost", expectedDifficulty: "normal" }],
      scripts: ["safe_beginner", "greedy_economy", "fast_army"],
      strongholdProfiles: [noStrongholdProfile]
    });
    const analysis = analyzePlaytestTelemetry(report.telemetry);
    const summary = analysis.nodeSummaries.find((entry) => entry.nodeId === "ashen_outpost");
    const markdown = renderPlaytestMarkdownReport({ ...report, analysis });

    expect(summary?.verdict).toBe("needs_human_review");
    expect(analysis.tooHardNodes).not.toContain("ashen_outpost");
    expect(summary?.notes.join(" ")).toContain("strategy-spread review");
    expect(markdown).toContain("Needs human review");
    expect(markdown).toContain("Review strategy spread");
  });

  it("keeps all-win nodes reasonable when they still cost units", () => {
    const report = runScriptedPlaytestSuite({
      scenarios: [{ nodeId: "old_stone_road", expectedDifficulty: "easy" }],
      scripts: ["safe_beginner", "greedy_economy", "fast_army"],
      strongholdProfiles: [noStrongholdProfile]
    });
    const summary = report.analysis.nodeSummaries.find((entry) => entry.nodeId === "old_stone_road");

    expect(summary?.victories).toBe(3);
    expect(summary?.verdict).toBe("reasonable");
  });

  it("applies affordable stronghold effects and reports profile warnings", () => {
    const trainingProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "training_yard_path")!;
    const watchPostProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "defensive_watch_post_path")!;
    const quartermasterProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "economy_quartermaster_path")!;
    const tierTwoQuartermasterProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "tier_two_quartermaster_path")!;
    const chapelProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "chapel_corner_path")!;
    const rangerProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "ranger_paths_path")!;
    const report = runScriptedPlaytestSuite({
      scripts: ["safe_beginner"],
      strongholdProfiles: [
        noStrongholdProfile,
        trainingProfile,
        watchPostProfile,
        quartermasterProfile,
        tierTwoQuartermasterProfile,
        chapelProfile,
        rangerProfile
      ]
    });

    const trainingAshen = report.telemetry.find(
      (run) => run.strongholdProfileId === "training_yard_path" && run.nodeId === "ashen_outpost"
    );
    const quartermasterBandit = report.telemetry.find(
      (run) => run.strongholdProfileId === "economy_quartermaster_path" && run.nodeId === "bandit_hillfort"
    );
    const watchSummary = report.analysis.strongholdProfileSummaries.find(
      (summary) => summary.profileId === "defensive_watch_post_path"
    );
    const watchBandit = report.telemetry.find(
      (run) => run.strongholdProfileId === "defensive_watch_post_path" && run.nodeId === "bandit_hillfort"
    );
    const baselineBandit = report.telemetry.find((run) => run.strongholdProfileId === "no_stronghold" && run.nodeId === "bandit_hillfort");
    const rangerAshen = report.telemetry.find(
      (run) => run.strongholdProfileId === "ranger_paths_path" && run.nodeId === "ashen_outpost"
    );
    const tierTwoQuartermasterAshen = report.telemetry.find(
      (run) => run.strongholdProfileId === "tier_two_quartermaster_path" && run.nodeId === "ashen_outpost"
    );

    expect(trainingAshen?.strongholdUpgradeIds).toContain("training_yard_i");
    expect(trainingAshen?.startingUnits.militia).toBeGreaterThan(4);
    expect(quartermasterBandit?.strongholdUpgradeIds).toContain("quartermaster_stores_i");
    expect(quartermasterBandit?.startingResources).toMatchObject({ crowns: 440, stone: 295, iron: 160, aether: 85 });
    expect(quartermasterBandit?.timeBarracksCompleted).toBeLessThan(baselineBandit?.timeBarracksCompleted ?? 999);
    expect(watchBandit?.timeFirstEnemyWarning).toBeLessThan(baselineBandit?.timeFirstEnemyWarning ?? 999);
    expect(watchSummary?.warnings).toEqual([]);
    expect(rangerAshen?.strongholdUpgradeIds).toEqual(expect.arrayContaining(["training_yard_i", "ranger_paths_i"]));
    expect(rangerAshen?.startingUnits.militia).toBeGreaterThan(4);
    expect(tierTwoQuartermasterAshen?.strongholdUpgradeIds).toEqual(
      expect.arrayContaining(["quartermaster_stores_i", "quartermaster_stores_ii"])
    );
    expect(tierTwoQuartermasterAshen?.strongholdEffects.startingResources).toMatchObject({
      crowns: 140,
      stone: 90,
      iron: 55,
      aether: 30
    });
    expect(tierTwoQuartermasterAshen?.startingResources).toMatchObject({ crowns: 700, stone: 480, iron: 290, aether: 170 });
  });

  it("models retinue profiles without making them mandatory in telemetry", () => {
    const veteranMilitiaProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "retinue_veteran_militia")!;
    const veteranRangerProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "retinue_veteran_ranger")!;
    const mixedProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "retinue_mixed_veterans")!;
    const retinueTrainingProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "retinue_training_yard_path")!;
    const retinueQuartermasterProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "retinue_quartermaster_path")!;
    const report = runScriptedPlaytestSuite({
      scripts: ["safe_beginner", "greedy_economy", "fast_army"],
      strongholdProfiles: [
        noStrongholdProfile,
        veteranMilitiaProfile,
        veteranRangerProfile,
        mixedProfile,
        retinueTrainingProfile,
        retinueQuartermasterProfile
      ]
    });

    const militiaBorder = report.telemetry.find(
      (run) => run.strongholdProfileId === "retinue_veteran_militia" && run.nodeId === "border_village"
    );
    const rangerAshen = report.telemetry.find(
      (run) => run.strongholdProfileId === "retinue_veteran_ranger" && run.nodeId === "ashen_outpost"
    );
    const mixedAshen = report.telemetry.find(
      (run) => run.strongholdProfileId === "retinue_mixed_veterans" && run.nodeId === "ashen_outpost"
    );
    const retinueTrainingAshen = report.telemetry.find(
      (run) => run.strongholdProfileId === "retinue_training_yard_path" && run.nodeId === "ashen_outpost"
    );
    const retinueQuartermasterAshen = report.telemetry.find(
      (run) => run.strongholdProfileId === "retinue_quartermaster_path" && run.nodeId === "ashen_outpost"
    );

    expect(militiaBorder?.retinueUnits).toEqual(["Veteran Militia"]);
    expect(militiaBorder?.startingUnits.militia).toBeGreaterThan(2);
    expect(rangerAshen?.retinueUnits).toEqual(["Veteran Ranger"]);
    expect(mixedAshen?.retinueUnits).toEqual(["Veteran Militia", "Seasoned Ranger"]);
    expect(retinueTrainingAshen?.strongholdUpgradeIds).toEqual(expect.arrayContaining(["training_yard_i", "training_yard_ii"]));
    expect(retinueTrainingAshen?.retinueUnits).toEqual(["Veteran Militia", "Seasoned Ranger", "Seasoned Militia"]);
    expect(retinueQuartermasterAshen?.strongholdUpgradeIds).toEqual(
      expect.arrayContaining(["quartermaster_stores_i", "quartermaster_stores_ii"])
    );
    expect(retinueQuartermasterAshen?.retinueUnits).toEqual(["Veteran Militia", "Seasoned Ranger"]);
    expect(report.analysis.tooEasyNodes).toEqual([]);
  });
});
