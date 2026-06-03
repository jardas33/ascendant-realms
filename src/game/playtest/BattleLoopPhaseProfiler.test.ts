import { describe, expect, it } from "vitest";
import { LUME_NETWORKS } from "../data/lumeNetworks";
import { defaultPerformanceCounters } from "./PrivatePerformanceProfiler";
import { TRUSTED_DEFAULT_SAMPLE_MS, TRUSTED_DEFAULT_WARMUP_MS, summarizeTrustedFrameIntervals } from "./TrustedBrowserBenchmark";
import {
  BattleLoopPhaseProfiler,
  V0110_BATTLE_LOOP_SCENARIOS,
  createDefaultBattleLoopDiagnostics,
  createTrustedBrowserGateReport,
  frameIntervalsFromNumbers,
  normalizeBattleLoopDiagnostics,
  renderBattleLoopIsolationSpecMarkdown,
  renderBeforeAfterDeltaMarkdown,
  renderPhaseProfilerSummaryMarkdown,
  type BattleLoopBenchmarkResult
} from "./BattleLoopPhaseProfiler";

describe("BattleLoopPhaseProfiler", () => {
  it("keeps diagnostics private, normalized, and off by default", () => {
    const defaults = createDefaultBattleLoopDiagnostics();
    const normalized = normalizeBattleLoopDiagnostics({
      phaseProfiler: "on",
      simulation: "paused",
      labels: "hidden",
      minimap: "paused",
      profilerOverlay: "on",
      combat: "invalid" as "normal"
    });

    expect(defaults.phaseProfiler).toBe("off");
    expect(defaults.simulation).toBe("normal");
    expect(normalized.phaseProfiler).toBe("on");
    expect(normalized.simulation).toBe("paused");
    expect(normalized.labels).toBe("hidden");
    expect(normalized.minimap).toBe("paused");
    expect(normalized.profilerOverlay).toBe("on");
    expect(normalized.combat).toBe("normal");
  });

  it("summarizes phase totals, percent share, p50, and p95", () => {
    const profiler = new BattleLoopPhaseProfiler();
    profiler.setEnabled(true);
    profiler.beginFrame(counts());
    profiler.record("movementPathing", 2);
    profiler.record("movementPathing", 6);
    profiler.record("hudDom", 4);
    profiler.endFrame();

    const summary = profiler.summary();
    const movement = summary.phases.find((entry) => entry.phaseId === "movementPathing");
    const hud = summary.phases.find((entry) => entry.phaseId === "hudDom");

    expect(summary.sampleCount).toBe(1);
    expect(summary.latestCounts.units).toBe(10);
    expect(movement?.totalMs).toBe(8);
    expect(movement?.averageMs).toBe(4);
    expect(movement?.p95Ms).toBe(6);
    expect(hud?.percentOfMeasuredFrame ?? 0).toBeGreaterThan(0);
  });

  it("defines the requested 22-row private Performance Lab ladder", () => {
    expect(V0110_BATTLE_LOOP_SCENARIOS).toHaveLength(22);
    expect(new Set(V0110_BATTLE_LOOP_SCENARIOS.map((entry) => entry.id)).size).toBe(22);
    expect(V0110_BATTLE_LOOP_SCENARIOS.map((entry) => entry.category)).toEqual(
      expect.arrayContaining(["static", "density", "subsystem"])
    );
    expect(V0110_BATTLE_LOOP_SCENARIOS.map((entry) => entry.id)).toEqual(
      expect.arrayContaining([
        "v0110_simulation_paused",
        "v0110_ai_paused",
        "v0110_path_paused",
        "v0110_fog_presentation_paused",
        "v0110_hud_dom_paused",
        "v0110_profiler_overlay_on"
      ])
    );
    V0110_BATTLE_LOOP_SCENARIOS.forEach((entry) => {
      expect(entry.saveIsolationRule).toContain("No save");
      expect(entry.saveIsolationRule).toContain("stable-ID");
    });
  });

  it("renders gate and report text without implying v0.111 or broad architecture work", () => {
    const result = benchmarkResult("v0110_tier_m_density", 24, 80);
    const gate = createTrustedBrowserGateReport([result]);

    expect(gate.status).toBe("AMBER");
    expect(renderPhaseProfilerSummaryMarkdown([result])).toContain("HUD DOM");
    expect(renderBattleLoopIsolationSpecMarkdown()).toContain("linked_ward");
    expect(renderBeforeAfterDeltaMarkdown([result])).toContain("No broad render rewrite");
    expect(renderBeforeAfterDeltaMarkdown([result])).toContain("v0.111");
  });

  it("does not change the existing linked_ward balance lock", () => {
    const linkedWard = LUME_NETWORKS.find((network) => network.benefit.id === "linked_ward")?.benefit;

    expect(linkedWard?.damageTakenMultiplier).toBe(0.92);
    expect(linkedWard?.nonStacking).toBe(true);
  });
});

function benchmarkResult(caseId: string, fpsAverage: number, p95: number): BattleLoopBenchmarkResult {
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: frameIntervalsFromNumbers([16, 24, p95, 32, 40]),
    sampleDurationMs: TRUSTED_DEFAULT_SAMPLE_MS,
    countersBefore: defaultPerformanceCounters(),
    countersAfter: { ...defaultPerformanceCounters(), units: 12, domNodes: 760, hudUpdates: 20 },
    longTaskSupported: true,
    longTasks: []
  });
  return {
    caseId,
    title: caseId,
    category: "density",
    scenarioId: "benchmark_battle_tier_m_representative",
    diagnostics: createDefaultBattleLoopDiagnostics(),
    viewport: "1600x900",
    warmupMs: TRUSTED_DEFAULT_WARMUP_MS,
    sampleMs: TRUSTED_DEFAULT_SAMPLE_MS,
    generatedAtUtc: "deterministic-v0110-test",
    steadyState: { ...steadyState, fpsAverage, frameTimeMs: { ...steadyState.frameTimeMs, p95 } },
    phaseSummary: {
      checkpoint: "v0.110",
      sampleCount: 1,
      totalMeasuredMs: 12,
      latestCounts: counts(),
      phases: [
        {
          phaseId: "sceneUpdate",
          label: "Scene/update total",
          description: "test",
          totalMs: 12,
          averageMs: 12,
          maxMs: 12,
          count: 1,
          percentOfMeasuredFrame: 100,
          p50Ms: 12,
          p95Ms: 12
        },
        {
          phaseId: "hudDom",
          label: "HUD DOM",
          description: "test",
          totalMs: 5,
          averageMs: 5,
          maxMs: 5,
          count: 1,
          percentOfMeasuredFrame: 41.67,
          p50Ms: 5,
          p95Ms: 5
        }
      ]
    },
    rawFrameIntervalArtifact: "artifacts/performance/v0110/raw-frame-intervals/test.json",
    rawPhaseSummaryArtifact: "artifacts/performance/v0110/raw-phase-samples/test.json"
  };
}

function counts() {
  return {
    displayObjects: 80,
    graphicsObjects: 10,
    units: 10,
    buildings: 4,
    captureSites: 3,
    projectiles: 1,
    labels: 12,
    domNodes: 700
  };
}
