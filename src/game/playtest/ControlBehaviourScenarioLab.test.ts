import { describe, expect, it } from "vitest";
import { CONTROL_BEHAVIOUR_SCENARIO_PROFILES } from "./ControlBehaviourScenarioProfiles";
import { renderControlBehaviourDashboardMarkdown, renderControlBehaviourScenarioMarkdownReport } from "./ControlBehaviourScenarioReportWriter";
import { runControlBehaviourScenarioLab } from "./ControlBehaviourScenarioRunner";
import { validateControlBehaviourLabOutputs } from "./ControlBehaviourScenarioValidation";

describe("ControlBehaviourScenarioLab", () => {
  it("runs the focused control behaviour scenarios", () => {
    const report = runControlBehaviourScenarioLab({ generatedAt: "2026-05-19T00:00:00.000Z", buildCommit: "test" });

    expect(report.runMode).toBe("normal");
    expect(report.results).toHaveLength(CONTROL_BEHAVIOUR_SCENARIO_PROFILES.length);
    expect(report.results.find((entry) => entry.scenarioId === "hold_ground_contact_defence")).toMatchObject({
      result: "pass",
      confidence: "high"
    });
    expect(report.results.find((entry) => entry.scenarioId === "press_attack_bounded_pursuit")?.metrics.leashRespected).toBe(true);
    expect(report.limitations).toContain("Not human fun evidence.");
  });

  it("records extended deterministic iterations honestly", () => {
    const report = runControlBehaviourScenarioLab({
      iterations: 3,
      runMode: "extended",
      generatedAt: "2026-05-19T00:00:00.000Z",
      buildCommit: "test"
    });

    expect(report.iterationCount).toBe(3);
    expect(report.results).toHaveLength(CONTROL_BEHAVIOUR_SCENARIO_PROFILES.length * 3);
    expect(report.determinismNotes.join(" ")).toContain("repeatability checks");
  });

  it("validates generated JSON and Markdown consistency", () => {
    const normal = runControlBehaviourScenarioLab({ generatedAt: "2026-05-19T00:00:00.000Z", buildCommit: "test" });
    const extended = runControlBehaviourScenarioLab({
      iterations: 3,
      runMode: "extended",
      generatedAt: "2026-05-19T00:00:00.000Z",
      buildCommit: "test"
    });
    const result = validateControlBehaviourLabOutputs(
      {
        normalJson: JSON.stringify(normal),
        normalMarkdown: renderControlBehaviourScenarioMarkdownReport(normal),
        extendedJson: JSON.stringify(extended),
        extendedMarkdown: renderControlBehaviourScenarioMarkdownReport(extended),
        dashboardJson: JSON.stringify(extended.dashboard),
        dashboardMarkdown: renderControlBehaviourDashboardMarkdown(extended.dashboard)
      },
      { expectedExtendedIterationCount: 3 }
    );

    expect(result.errors).toEqual([]);
    expect(result.checks).toContain("dashboard markdown ranking order");
  });

  it("rejects metric nulls that are not declared unavailable", () => {
    const normal = runControlBehaviourScenarioLab({ generatedAt: "2026-05-19T00:00:00.000Z", buildCommit: "test" });
    normal.results[0].unavailableMetrics = normal.results[0].unavailableMetrics.filter((metric) => metric !== "retreatCommandAccepted");
    const extended = runControlBehaviourScenarioLab({
      iterations: 3,
      runMode: "extended",
      generatedAt: "2026-05-19T00:00:00.000Z",
      buildCommit: "test"
    });

    const result = validateControlBehaviourLabOutputs(
      {
        normalJson: JSON.stringify(normal),
        normalMarkdown: renderControlBehaviourScenarioMarkdownReport(normal),
        extendedJson: JSON.stringify(extended),
        extendedMarkdown: renderControlBehaviourScenarioMarkdownReport(extended),
        dashboardJson: JSON.stringify(extended.dashboard),
        dashboardMarkdown: renderControlBehaviourDashboardMarkdown(extended.dashboard)
      },
      { expectedExtendedIterationCount: 3 }
    );

    expect(result.ok).toBe(false);
    expect(result.errors).toContain(
      "Metric retreatCommandAccepted is null for hold_ground_contact_defence but is not marked unavailable."
    );
  });
});
