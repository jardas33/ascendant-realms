import { describe, expect, it } from "vitest";
import {
  DEFAULT_PLAYTEST_STRONGHOLD_PROFILES,
  analyzePlaytestTelemetry,
  renderPlaytestMarkdownReport,
  runScriptedPlaytestSuite
} from "./ScriptedBattlePlaytest";

describe("ScriptedBattlePlaytest", () => {
  const noStrongholdProfile = DEFAULT_PLAYTEST_STRONGHOLD_PROFILES.find((profile) => profile.id === "no_stronghold")!;

  it("runs every current campaign battle node with the three core scripts and stronghold profiles", () => {
    const report = runScriptedPlaytestSuite();

    expect(report.telemetry).toHaveLength(60);
    expect(new Set(report.telemetry.map((run) => run.nodeId))).toEqual(
      new Set(["border_village", "old_stone_road", "aether_well_ruins", "bandit_hillfort", "ashen_outpost"])
    );
    expect(new Set(report.telemetry.map((run) => run.playerScript))).toEqual(
      new Set(["safe_beginner", "greedy_economy", "fast_army"])
    );
    expect(new Set(report.telemetry.map((run) => run.strongholdProfileId))).toEqual(
      new Set(["no_stronghold", "training_yard_path", "defensive_watch_post_path", "economy_quartermaster_path"])
    );
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
    const report = runScriptedPlaytestSuite({
      scripts: ["safe_beginner"],
      strongholdProfiles: [noStrongholdProfile, trainingProfile, watchPostProfile, quartermasterProfile]
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

    expect(trainingAshen?.strongholdUpgradeIds).toContain("training_yard_i");
    expect(trainingAshen?.startingUnits.militia).toBeGreaterThan(4);
    expect(quartermasterBandit?.strongholdUpgradeIds).toContain("quartermaster_stores_i");
    expect(quartermasterBandit?.startingResources.crowns).toBeGreaterThan(380);
    expect(watchSummary?.warnings.join(" ")).toContain("did not improve");
  });
});
