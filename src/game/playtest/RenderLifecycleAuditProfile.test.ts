import { describe, expect, it } from "vitest";
import { createDefaultBattleLoopDiagnostics, type BattleLoopPhaseSummary } from "./BattleLoopPhaseProfiler";
import {
  V0114_RENDER_LIFECYCLE_AUDIT_CASES,
  createVisualParitySummary,
  renderCanvasDomBoundaryReportMarkdown,
  renderEmmanuelRetestChecklistMarkdown,
  renderImplementationReportMarkdown,
  renderLifecycleAuditRates,
  renderProceduralBatchingSpecMarkdown,
  renderRenderLifecycleAuditMarkdown,
  type RenderLifecycleAuditResult
} from "./RenderLifecycleAuditProfile";
import { defaultPerformanceCounters } from "./PrivatePerformanceProfiler";
import { createEmptyRenderLifecycleCounters } from "../systems/RenderLifecycleMetrics";

describe("RenderLifecycleAuditProfile", () => {
  it("covers the required v0.114 render lifecycle matrix", () => {
    expect(V0114_RENDER_LIFECYCLE_AUDIT_CASES.map((entry) => entry.posture)).toEqual([
      "phaser-empty",
      "tier-s",
      "tier-m-idle",
      "tier-m-moving",
      "tier-m-combat",
      "tier-l-stress",
      "fog-heavy",
      "lume-auto",
      "lume-always",
      "label-heavy",
      "notification-heavy",
      "hud-minimal",
      "hud-standard",
      "results-transition",
      "campaign-map"
    ]);
  });

  it("keeps docs scoped to renderer lifecycle and DOM boundaries", () => {
    expect(renderProceduralBatchingSpecMarkdown()).toContain("presentation-only");
    expect(renderProceduralBatchingSpecMarkdown()).toContain("No art, gameplay");
    expect(renderCanvasDomBoundaryReportMarkdown([])).toContain("Canvas work remains in Phaser");
    expect(renderImplementationReportMarkdown([])).toContain("no-op guards");
    expect(renderEmmanuelRetestChecklistMarkdown()).toContain("perf:render-lifecycle-audit");
  });

  it("renders lifecycle counters and parity evidence", () => {
    const result = profileResult();

    expect(renderLifecycleAuditRates(result.renderLifecycleCounters, 1000).graphicsCreated).toBe(2);
    expect(renderRenderLifecycleAuditMarkdown([result])).toContain("v0114_label_heavy");
    expect(renderRenderLifecycleAuditMarkdown([result])).toContain("2/1");
    expect(createVisualParitySummary([result]).checks.some((check) => check.status === "pass")).toBe(true);
  });
});

function profileResult(): RenderLifecycleAuditResult {
  const counters = createEmptyRenderLifecycleCounters();
  counters.frames = 60;
  counters.graphicsCreated = 2;
  counters.graphicsDestroyed = 1;
  counters.textObjectsCreated = 1;
  counters.domPatches = 3;
  counters.minimapSnapshots = 2;
  counters.retainedObjectCount = 42;

  return {
    caseId: "v0114_label_heavy",
    title: "Label-heavy",
    launchScenarioId: "perf_label_heavy_site_cluster",
    surface: "battle",
    posture: "label-heavy",
    diagnostics: createDefaultBattleLoopDiagnostics(),
    stimulus: "none",
    warmupMs: 1000,
    sampleMs: 1000,
    generatedAtUtc: "2026-06-03T00:00:00.000Z",
    steadyState: {
      sampleDurationMs: 1000,
      sampleCount: 60,
      fpsAverage: 60,
      fpsOnePercentLow: 60,
      frameTimeMs: {
        p50: 16.7,
        p95: 16.7,
        p99: 16.7,
        max: 16.7,
        over16_7: 0,
        over33_3: 0,
        over50: 0,
        over100: 0,
        over250: 0,
        over500: 0
      },
      longTasks: { supported: true, count: 0, totalDurationMs: 0, maxDurationMs: 0 },
      counters: defaultPerformanceCounters(),
      counterDeltas: {},
      ratesPerSecond: {
        fogRedraws: 0,
        minimapRefreshes: 0,
        hudUpdates: 0,
        notificationsEmitted: 0
      }
    },
    phaseSummary: phaseSummary(),
    privateCounters: defaultPerformanceCounters(),
    renderLifecycleCounters: counters,
    renderLifecycleRates: renderLifecycleAuditRates(counters, 1000),
    rawFrameIntervalArtifact: "artifacts/performance/v0114/raw-frame-intervals/v0114_label_heavy.json",
    rawPhaseSummaryArtifact: "artifacts/performance/v0114/raw-phase-summaries/v0114_label_heavy.json",
    rawRenderLifecycleArtifact: "artifacts/performance/v0114/raw-render-lifecycle/v0114_label_heavy.json",
    screenshotArtifact: "artifacts/performance/v0114/screenshots/v0114_label_heavy.png"
  };
}

function phaseSummary(): BattleLoopPhaseSummary {
  return {
    checkpoint: "v0.110",
    sampleCount: 1,
    totalMeasuredMs: 1,
    latestCounts: {
      displayObjects: 0,
      graphicsObjects: 0,
      units: 0,
      buildings: 0,
      captureSites: 0,
      projectiles: 0,
      labels: 0,
      domNodes: 0
    },
    phases: []
  };
}
