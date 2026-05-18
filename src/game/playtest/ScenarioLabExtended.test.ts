import { describe, expect, it } from "vitest";
import {
  renderBalanceRegressionDashboardMarkdown,
  renderExtendedScenarioLabMarkdownReport,
  renderExtendedWatchpointsMarkdown,
  renderProfileComparisonCsv,
  renderProfileComparisonMarkdown,
  validateScenarioLabOutputArtifacts,
  runExtendedScenarioLab,
  runScenarioLab
} from "./ScriptedBattlePlaytest";

describe("ScenarioLabExtended", () => {
  it("runs repeated deterministic batches with stable iteration and seed metadata", () => {
    const report = runExtendedScenarioLab({
      iterations: 2,
      seed: "test-seed",
      batchLabel: "test batch",
      generatedAt: "2026-05-18T00:00:00.000Z",
      buildCommit: "test-commit"
    });

    expect(report.schemaVersion).toBe(1);
    expect(report.iterationCount).toBe(2);
    expect(report.seed).toBe("test-seed");
    expect(report.buildCommit).toBe("test-commit");
    expect(report.sourceRunCountPerIteration).toBe(255);
    expect(report.totalSourceRuns).toBe(510);
    expect(report.totalDerivedMetrics).toBe(710);
    expect(report.uniqueDerivedMetricFingerprints).toBe(355);
    expect(report.metricsAvailability.some((metric) => metric.metric === "human noticeability" && metric.status === "unavailable")).toBe(true);
    expect(report.iterationSummaries.map((summary) => summary.seedId)).toEqual(["test-seed-iteration-1", "test-seed-iteration-2"]);
    expect(report.profileComparisons).toHaveLength(10);
    expect(report.profileNodeScriptComparisons.length).toBeGreaterThan(30);
    expect(report.nodeRiskDashboard.map((node) => node.nodeId)).toEqual([
      "border_village",
      "old_stone_road",
      "aether_well_ruins",
      "bandit_hillfort",
      "ashen_outpost",
      "cinderfen_crossing",
      "cinderfen_watch"
    ]);
  });

  it("calculates profile comparison and node risk metrics across repeated rows", () => {
    const report = runExtendedScenarioLab({ iterations: 2, generatedAt: "2026-05-18T00:00:00.000Z" });
    const greedy = report.profileComparisons.find((profile) => profile.profileId === "greedy_economy");
    const fastCinderfen = report.profileNodeScriptComparisons.find((entry) => {
      return entry.profileId === "fast_army" && entry.nodeId === "cinderfen_crossing" && entry.playerScript === "fast_army";
    });
    const bandit = report.nodeRiskDashboard.find((node) => node.nodeId === "bandit_hillfort");

    expect(report.strongestProfileId).toBe("mixed_veterans");
    expect(report.weakestProfileId).toBe("greedy_economy");
    expect(greedy?.totalRuns).toBe(170);
    expect(greedy?.timeoutRate).toBeGreaterThan(0.5);
    expect(greedy?.stabilityVerdict).toBe("unstable route");
    expect(fastCinderfen?.winRate).toBeGreaterThan(0.9);
    expect(bandit?.status).toBe("Warning");
    expect(bandit?.verdict).toContain("loss-risk");
  });

  it("classifies all extended regression watchpoints conservatively", () => {
    const report = runExtendedScenarioLab({ iterations: 2, generatedAt: "2026-05-18T00:00:00.000Z" });

    expect(report.watchpointRegressions.map((watchpoint) => watchpoint.watchpointId)).toEqual([
      "retinue_training_yard_ii",
      "greedy_economy",
      "fast_army",
      "early_defeats",
      "pressure_fairness",
      "cinderfen_crossing_fairness",
      "cinderfen_watch_fairness",
      "ashen_outpost_stability",
      "objective_completion_drop",
      "resource_starvation_spike"
    ]);
    expect(report.watchpointRegressions.find((watchpoint) => watchpoint.watchpointId === "retinue_training_yard_ii")?.status).toBe(
      "Human testing required"
    );
    expect(report.watchpointRegressions.find((watchpoint) => watchpoint.watchpointId === "greedy_economy")?.status).toBe("Monitor");
    expect(report.watchpointRegressions.find((watchpoint) => watchpoint.watchpointId === "fast_army")?.status).toBe("Monitor");
    expect(report.watchpointRegressions.find((watchpoint) => watchpoint.watchpointId === "early_defeats")?.status).toBe("OK");
    expect(report.watchpointRegressions.find((watchpoint) => watchpoint.watchpointId === "resource_starvation_spike")?.status).toBe("OK");
  });

  it("renders extended reports, dashboard, comparison, csv, and watchpoints without claiming human feedback", () => {
    const report = runExtendedScenarioLab({ iterations: 2, generatedAt: "2026-05-18T00:00:00.000Z" });
    const outputs = [
      renderExtendedScenarioLabMarkdownReport(report),
      renderBalanceRegressionDashboardMarkdown(report),
      renderProfileComparisonMarkdown(report),
      renderProfileComparisonCsv(report),
      renderExtendedWatchpointsMarkdown(report)
    ];

    expect(outputs[0]).toContain("# v0.13.1 Extended Automated Scenario Lab");
    expect(outputs[0]).toContain("## Profile x Node x Script Risk Rows");
    expect(outputs[0]).toContain("Unique deterministic metric fingerprints: 355.");
    expect(outputs[0]).toContain("The five default iterations are intentionally identical deterministic replays");
    expect(outputs[0]).toContain("## Metric Availability");
    expect(outputs[1]).toContain("# v0.13.1 Balance Regression Dashboard");
    expect(outputs[1]).toContain("## Do Not Tune Yet");
    expect(outputs[2]).toContain("# v0.13.1 Profile Comparison");
    expect(outputs[3]).toContain("profileId,profileName");
    expect(outputs[4]).toContain("# v0.13.1 Extended Watchpoints");
    outputs.forEach((output) => {
      expect(output.toLowerCase()).not.toContain("tester said");
      expect(output.toLowerCase()).not.toContain("completed tester forms");
      expect(output.toLowerCase()).not.toContain("human feedback was used");
    });
  });

  it("leaves quick scenario lab shape intact after extended runs", () => {
    const quickBefore = runScenarioLab();
    const extended = runExtendedScenarioLab({ iterations: 2, generatedAt: "2026-05-18T00:00:00.000Z" });
    const quickAfter = runScenarioLab();

    expect(extended.totalSourceRuns).toBe(quickBefore.sourceRunCount * 2);
    expect(quickAfter.sourceRunCount).toBe(quickBefore.sourceRunCount);
    expect(quickAfter.runMetrics.length).toBe(quickBefore.runMetrics.length);
    expect(quickAfter.watchpoints.map((watchpoint) => watchpoint.watchpointId)).toEqual(
      quickBefore.watchpoints.map((watchpoint) => watchpoint.watchpointId)
    );
  });

  it("validates generated JSON, Markdown, and CSV artifacts for consistency", () => {
    const report = runExtendedScenarioLab({
      iterations: 2,
      generatedAt: "2026-05-18T00:00:00.000Z",
      buildCommit: "test-commit"
    });
    const result = validateScenarioLabOutputArtifacts(
      {
        extendedJson: JSON.stringify(report, null, 2),
        extendedMarkdown: renderExtendedScenarioLabMarkdownReport(report),
        profileComparisonMarkdown: renderProfileComparisonMarkdown(report),
        profileComparisonCsv: renderProfileComparisonCsv(report),
        dashboardJson: JSON.stringify(report.dashboard, null, 2),
        dashboardMarkdown: renderBalanceRegressionDashboardMarkdown(report),
        watchpointsMarkdown: renderExtendedWatchpointsMarkdown(report)
      },
      { expectedIterationCount: 2 }
    );

    expect(result.errors).toEqual([]);
    expect(result.ok).toBe(true);
    expect(result.checks).toContain("CSV profile order matches computed ranking");
    expect(result.checks).toContain("Markdown profile order matches computed ranking");
  });
});
