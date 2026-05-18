import { describe, expect, it } from "vitest";
import {
  renderScenarioLabMarkdownReport,
  renderScenarioProfileCatalogMarkdown,
  renderWatchpointSummaryMarkdown,
  runScenarioLab,
  SCENARIO_LAB_PROFILES,
  watchpointSummaryRequiresHumanTesting
} from "./ScriptedBattlePlaytest";

describe("ScenarioLab", () => {
  it("defines the required automated scenario profiles with metadata", () => {
    expect(SCENARIO_LAB_PROFILES.map((profile) => profile.id)).toEqual([
      "baseline_cautious",
      "no_retinue",
      "one_veteran",
      "mixed_veterans",
      "retinue_training_yard_ii",
      "greedy_economy",
      "fast_army",
      "pressure_ignoring",
      "objective_rush",
      "safe_beginner"
    ]);

    SCENARIO_LAB_PROFILES.forEach((profile) => {
      expect(profile.name).toBeTruthy();
      expect(profile.routeAssumptions.length).toBeGreaterThan(0);
      expect(profile.playerBehaviorModel).toBeTruthy();
      expect(profile.preferredStrongholdProfileIds.length).toBeGreaterThan(0);
      expect(profile.scriptIds.length).toBeGreaterThan(0);
      expect(profile.nodeIds.length).toBeGreaterThan(0);
      expect(profile.expectedStrengths.length).toBeGreaterThan(0);
      expect(profile.expectedWeaknesses.length).toBeGreaterThan(0);
      expect(profile.watchpointRelevance.length).toBeGreaterThan(0);
      expect(profile.automationNotes.length).toBeGreaterThan(0);
    });
  });

  it("runs the scenario lab and creates stable profile, metric, and watchpoint summaries", () => {
    const report = runScenarioLab();

    expect(report.schemaVersion).toBe(1);
    expect(report.generatedBy).toBe("Ascendant Realms automated playtest scenario lab v1");
    expect(report.sourceReportSchemaVersion).toBe(3);
    expect(report.sourceRunCount).toBe(255);
    expect(report.profiles).toHaveLength(10);
    expect(report.runMetrics.length).toBeGreaterThan(255);
    expect(report.nodeRiskSummaries.map((summary) => summary.nodeId)).toEqual([
      "border_village",
      "old_stone_road",
      "aether_well_ruins",
      "bandit_hillfort",
      "ashen_outpost",
      "cinderfen_crossing",
      "cinderfen_watch"
    ]);
    expect(report.watchpoints.map((watchpoint) => watchpoint.watchpointId)).toEqual([
      "retinue_training_yard_ii",
      "greedy_economy",
      "fast_army",
      "early_defeats",
      "pressure_fairness",
      "cinderfen_crossing_fairness",
      "cinderfen_watch_fairness",
      "ashen_outpost_stability"
    ]);
    expect(report.strongestProfileId).toBeTruthy();
    expect(report.fastestProfileId).toBeTruthy();
    expect(report.metricsAvailability.some((metric) => metric.metric === "human noticeability" && metric.status === "unavailable")).toBe(true);
  });

  it("classifies current watchpoints conservatively without numeric tuning claims", () => {
    const report = runScenarioLab();
    const retinue = report.watchpoints.find((watchpoint) => watchpoint.watchpointId === "retinue_training_yard_ii");
    const greedy = report.watchpoints.find((watchpoint) => watchpoint.watchpointId === "greedy_economy");
    const fast = report.watchpoints.find((watchpoint) => watchpoint.watchpointId === "fast_army");
    const early = report.watchpoints.find((watchpoint) => watchpoint.watchpointId === "early_defeats");
    const pressure = report.watchpoints.find((watchpoint) => watchpoint.watchpointId === "pressure_fairness");

    expect(retinue?.action).toBe("needs human testing");
    expect(retinue?.automatedVerdict).toContain("earned-power");
    expect(greedy?.action).toBe("monitor");
    expect(greedy?.automatedVerdict).toContain("conversion risk");
    expect(fast?.action).toBe("monitor");
    expect(fast?.automatedVerdict).toContain("do not slow it just because it is fast");
    expect(early?.action).toBe("no change");
    expect(pressure?.action).toBe("needs human testing");
    expect(report.watchpoints.some((watchpoint) => watchpoint.action === "tiny tuning candidate")).toBe(false);
  });

  it("keeps per-run route markers tied to source telemetry in mixed profiles", () => {
    const report = runScenarioLab();
    const baselineRush = report.runMetrics.find((metric) => {
      return (
        metric.profileId === "objective_rush" &&
        metric.sourceStrongholdProfileId === "no_stronghold" &&
        metric.nodeId === "ashen_outpost"
      );
    });
    const stackedRush = report.runMetrics.find((metric) => {
      return (
        metric.profileId === "objective_rush" &&
        metric.sourceStrongholdProfileId === "retinue_training_yard_path" &&
        metric.nodeId === "ashen_outpost"
      );
    });

    expect(baselineRush?.retinueUsed).toBe(false);
    expect(baselineRush?.trainingYardIIActive).toBe(false);
    expect(baselineRush?.fastArmyMarker).toBe(true);
    expect(stackedRush?.retinueUsed).toBe(true);
    expect(stackedRush?.trainingYardIIActive).toBe(true);
  });

  it("renders required lab report sections and avoids claiming human feedback", () => {
    const report = runScenarioLab();
    const markdown = renderScenarioLabMarkdownReport(report);
    const watchpoints = renderWatchpointSummaryMarkdown(report);
    const catalog = renderScenarioProfileCatalogMarkdown();

    expect(markdown).toContain("# v0.13 Automated Playtest Scenario Lab");
    expect(markdown).toContain("## Profile Comparison");
    expect(markdown).toContain("## Node Risk Summary");
    expect(markdown).toContain("## Watchpoint Classifier");
    expect(markdown).toContain("## Metrics Availability");
    expect(markdown).toContain("automated deterministic simulator evidence only");
    expect(watchpoints).toContain("# v0.13 Playtest Watchpoint Summary");
    expect(watchpoints).toContain("No runtime tuning should be made from this summary alone.");
    expect(catalog).toContain("# v0.13 Automated Scenario Profile Catalog");
    [markdown, watchpoints, catalog].forEach((output) => {
      expect(output.toLowerCase()).not.toContain("tester said");
      expect(output.toLowerCase()).not.toContain("completed tester forms");
      expect(output.toLowerCase()).not.toContain("human feedback was used");
    });
  });

  it("keeps watchpoint human-testing helper aligned with classifications", () => {
    const report = runScenarioLab();
    const humanTestingWatchpoints = report.watchpoints.filter(watchpointSummaryRequiresHumanTesting);

    expect(humanTestingWatchpoints.length).toBeGreaterThan(0);
    expect(humanTestingWatchpoints.map((watchpoint) => watchpoint.watchpointId)).toEqual(
      expect.arrayContaining(["retinue_training_yard_ii", "pressure_fairness"])
    );
  });
});
