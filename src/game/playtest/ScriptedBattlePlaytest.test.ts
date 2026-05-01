import { describe, expect, it } from "vitest";
import {
  analyzePlaytestTelemetry,
  renderPlaytestMarkdownReport,
  runScriptedPlaytestSuite
} from "./ScriptedBattlePlaytest";

describe("ScriptedBattlePlaytest", () => {
  it("runs every current campaign battle node with the three core scripts", () => {
    const report = runScriptedPlaytestSuite();

    expect(report.telemetry).toHaveLength(15);
    expect(new Set(report.telemetry.map((run) => run.nodeId))).toEqual(
      new Set(["border_village", "old_stone_road", "aether_well_ruins", "bandit_hillfort", "ashen_outpost"])
    );
    expect(new Set(report.telemetry.map((run) => run.playerScript))).toEqual(
      new Set(["safe_beginner", "greedy_economy", "fast_army"])
    );
  });

  it("captures opening timing and command telemetry for the tutorial battles", () => {
    const report = runScriptedPlaytestSuite({
      scenarios: [
        { nodeId: "border_village", expectedDifficulty: "easy" },
        { nodeId: "old_stone_road", expectedDifficulty: "easy" }
      ],
      scripts: ["safe_beginner", "greedy_economy", "fast_army"]
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
      scripts: ["safe_beginner", "greedy_economy", "fast_army"]
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
      scripts: ["safe_beginner", "greedy_economy", "fast_army"]
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
      scripts: ["safe_beginner", "greedy_economy", "fast_army"]
    });
    const summary = report.analysis.nodeSummaries.find((entry) => entry.nodeId === "old_stone_road");

    expect(summary?.victories).toBe(3);
    expect(summary?.verdict).toBe("reasonable");
  });
});
