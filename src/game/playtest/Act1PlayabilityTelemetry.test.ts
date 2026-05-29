import { describe, expect, it } from "vitest";
import {
  buildAct1PlayabilityTelemetryReport,
  renderAct1PlayabilityTelemetryMarkdownReport
} from "./Act1PlayabilityTelemetry";

describe("Act1PlayabilityTelemetry", () => {
  const report = buildAct1PlayabilityTelemetryReport();

  it("summarizes the intended Act 1 campaign battle route from deterministic simulator data", () => {
    expect(report.schemaVersion).toBe(1);
    expect(report.nodeSummaries.map((summary) => summary.nodeId)).toEqual([
      "border_village",
      "old_stone_road",
      "aether_well_ruins",
      "bandit_hillfort",
      "ashen_outpost"
    ]);
    expect(report.act1RunCount).toBe(180);
    expect(report.sourceRunCount).toBeGreaterThan(report.act1RunCount);
  });

  it("keeps Tutorial evidence fenced as no-save and no-reward", () => {
    expect(report.tutorialProtection).toMatchObject({
      label: "Tutorial / Proving Grounds",
      simulated: false
    });
    expect(report.tutorialProtection.policy).toContain("no-save");
    expect(report.tutorialProtection.policy).toContain("no-reward");
    expect(report.evidenceBoundary.notMeasured).toContain("human fun");
  });

  it("keeps Safe Beginner stable while separating strategy spread from numeric tuning", () => {
    expect(report.overallRead.safeBeginnerWinsAllAct1Nodes).toBe(true);
    expect(report.overallRead.numericTuningRecommendation).toContain("No numeric tuning");
    expect(report.nodeSummaries.find((summary) => summary.nodeId === "aether_well_ruins")?.verdict).toBe(
      "watch_strategy_spread"
    );
    expect(report.nodeSummaries.find((summary) => summary.nodeId === "bandit_hillfort")?.verdict).toBe(
      "watch_strategy_spread"
    );
    report.nodeSummaries.forEach((summary) => {
      const safe = summary.scriptSummaries.find((entry) => entry.scriptId === "safe_beginner")!;
      expect(safe.victories).toBe(safe.runs);
    });
  });

  it("renders a compact Markdown report for docs and package review", () => {
    const markdown = renderAct1PlayabilityTelemetryMarkdownReport(report);

    expect(markdown).toContain("# v0.48 Act 1 Playtest Telemetry Report");
    expect(markdown).toContain("Evidence Boundary");
    expect(markdown).toContain("Safe Beginner wins every Act 1 campaign node: yes");
    expect(markdown).toContain("Aether Well Ruins");
    expect(markdown).toContain("Bandit Hillfort");
    expect(markdown).toContain("Do not tune numerically yet");
  });
});
