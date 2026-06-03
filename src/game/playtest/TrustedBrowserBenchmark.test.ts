import { describe, expect, it } from "vitest";
import { LUME_NETWORKS } from "../data/lumeNetworks";
import { defaultPerformanceCounters } from "./PrivatePerformanceProfiler";
import {
  TRUSTED_DEFAULT_SAMPLE_MS,
  TRUSTED_DEFAULT_WARMUP_MS,
  TRUSTED_ROOT_CAUSE_CASES,
  createDefaultTrustedDiagnostics,
  createManualBenchmarkTemplate,
  createProfilerMethodAudit,
  renderExecutionModeComparisonMarkdown,
  renderRootCauseMatrixMarkdown,
  renderTrustedBenchmarkProtocolMarkdown,
  summarizeTrustedFrameIntervals,
  type TrustedBenchmarkResult
} from "./TrustedBrowserBenchmark";

describe("TrustedBrowserBenchmark", () => {
  it("documents why old 1200 ms profiler evidence is not treated as final benchmark proof", () => {
    const audit = createProfilerMethodAudit();
    const protocol = renderTrustedBenchmarkProtocolMarkdown();

    expect(audit.oldSampleWindowMs).toBe(1200);
    expect(audit.findings.map((finding) => finding.item)).toEqual(
      expect.arrayContaining(["1% low", "Launch contamination", "Dev vs production", "Profiler panel overhead"])
    );
    expect(audit.conclusion).toContain("mixed");
    expect(protocol).toContain(`${TRUSTED_DEFAULT_WARMUP_MS} ms`);
    expect(protocol).toContain(`${TRUSTED_DEFAULT_SAMPLE_MS} ms`);
    expect(protocol).toContain("screenshots");
    expect(protocol).toContain("visibilityState");
  });

  it("summarizes trusted frame intervals with long windows, raw-frame threshold counts, and clamped counter deltas", () => {
    const before = {
      ...defaultPerformanceCounters(),
      hudUpdates: 40,
      minimapRefreshes: 24,
      fogRedraws: 10,
      notificationsEmitted: 4,
      memoryUsedMb: 100
    };
    const after = {
      ...defaultPerformanceCounters(),
      hudUpdates: 10,
      minimapRefreshes: 42,
      fogRedraws: 20,
      notificationsEmitted: 5,
      labels: 12,
      totalLabels: 18,
      domNodes: 800,
      memoryUsedMb: 112
    };
    const summary = summarizeTrustedFrameIntervals({
      intervals: [
        { index: 0, atMs: 16, frameMs: 16 },
        { index: 1, atMs: 34, frameMs: 18 },
        { index: 2, atMs: 134, frameMs: 100 },
        { index: 3, atMs: 384, frameMs: 250 },
        { index: 4, atMs: 904, frameMs: 520 }
      ],
      sampleDurationMs: 1000,
      countersBefore: before,
      countersAfter: after,
      longTaskSupported: true,
      longTasks: [{ atMs: 360, durationMs: 64 }]
    });

    expect(summary.sampleCount).toBe(5);
    expect(summary.fpsAverage).toBe(5);
    expect(summary.frameTimeMs.over100).toBe(2);
    expect(summary.frameTimeMs.over250).toBe(1);
    expect(summary.frameTimeMs.over500).toBe(1);
    expect(summary.ratesPerSecond.hudUpdates).toBe(0);
    expect(summary.ratesPerSecond.minimapRefreshes).toBe(18);
    expect(summary.longTasks).toMatchObject({ supported: true, count: 1, totalDurationMs: 64 });
    expect(summary.memoryTrendMb).toBe(12);
    expect(summary.counters.totalLabels).toBe(18);
  });

  it("defines private root-cause isolation cases without touching gameplay or save posture", () => {
    const caseIds = TRUSTED_ROOT_CAUSE_CASES.map((entry) => entry.id);
    expect(caseIds).toEqual(
      expect.arrayContaining([
        "baseline",
        "labels-hidden",
        "rings-minimal",
        "lume-hidden",
        "lume-always",
        "minimap-reduced",
        "minimap-paused",
        "fog-reduced",
        "hud-minimal",
        "hud-standard",
        "hud-debug",
        "notifications-suppressed",
        "profiler-overlay-on",
        "overlays-minimized",
        "overlays-enabled",
        "tier-s",
        "tier-l",
        "results-transition",
        "campaign-map"
      ])
    );
    expect(TRUSTED_ROOT_CAUSE_CASES.find((entry) => entry.id === "tier-l")?.localOnly).toBe(true);
    const diagnosticKeys = Object.keys(createDefaultTrustedDiagnostics()).sort();
    TRUSTED_ROOT_CAUSE_CASES.forEach((entry) => {
      expect(entry.executionMode).toBe("production-preview-headless");
      expect(Object.keys(entry.diagnostics).sort()).toEqual(diagnosticKeys);
      expect(entry.compareFocus.length).toBeGreaterThan(10);
    });
  });

  it("keeps manual flow exportable without console-only work", () => {
    const template = createManualBenchmarkTemplate();

    expect(template.reportPath).toBe("artifacts/performance/v0109/manual-benchmark-template.json");
    expect(template.flow).toEqual(
      expect.arrayContaining(["Warm up for five seconds", "Sample for ten seconds", "Toggle Lume Hidden, Auto, Always"])
    );
    expect(template.saveIsolationRule).toContain("No save");
    expect(template.saveIsolationRule).toContain("localStorage");
  });

  it("renders comparison reports that classify earlier 2-3 FPS evidence from trusted data", () => {
    const baseline = trustedResult("baseline", 32, 48);
    const mode = trustedResult("mode-preview-headless", 31, 50);
    const rootCause = trustedResult("profiler-overlay-on", 12, 160);

    expect(renderExecutionModeComparisonMarkdown([baseline, mode])).toContain("production preview + headless Playwright");
    expect(renderRootCauseMatrixMarkdown([baseline, rootCause])).toContain("primarily distorted by harness methodology");
  });

  it("does not change the existing linked_ward balance value", () => {
    const linkedWard = LUME_NETWORKS.find((network) => network.benefit.id === "linked_ward")?.benefit;

    expect(linkedWard?.damageTakenMultiplier).toBe(0.92);
    expect(linkedWard?.nonStacking).toBe(true);
  });
});

function trustedResult(caseId: string, fpsAverage: number, p95: number): TrustedBenchmarkResult {
  return {
    id: `production-preview-headless:${caseId}`,
    caseId,
    title: caseId,
    scenarioId: "benchmark_battle_tier_m_representative",
    diagnostics: createDefaultTrustedDiagnostics(),
    environment: {
      executionMode: "production-preview-headless",
      visibilityState: "visible",
      viewport: "1600x900",
      userAgent: "test-user-agent",
      browserName: "chromium",
      headed: false,
      serverMode: "preview",
      profilerOverlayEnabled: false,
      screenshotsDuringSample: false,
      warmupMs: TRUSTED_DEFAULT_WARMUP_MS,
      sampleMs: TRUSTED_DEFAULT_SAMPLE_MS,
      longTaskObserverSupported: true,
      memorySupported: false
    },
    launch: {
      navigationStartToHubReadyMs: 100,
      scenarioClickToBattleHudMs: 200,
      scenarioClickToSceneReadyMs: 220,
      firstResponsiveInteractionMs: 12,
      firstRenderedFrameAfterReadyMs: 16
    },
    settle: {
      configuredWarmupMs: TRUSTED_DEFAULT_WARMUP_MS,
      actualWarmupMs: TRUSTED_DEFAULT_WARMUP_MS,
      visibilityState: "visible",
      sceneStable: true
    },
    steadyState: {
      sampleDurationMs: TRUSTED_DEFAULT_SAMPLE_MS,
      sampleCount: 600,
      fpsAverage,
      fpsOnePercentLow: Math.max(1, fpsAverage - 10),
      frameTimeMs: {
        p50: 24,
        p95,
        p99: p95 + 20,
        max: p95 + 40,
        over16_7: 500,
        over33_3: 120,
        over50: p95 >= 50 ? 40 : 0,
        over100: p95 >= 100 ? 10 : 0,
        over250: 0,
        over500: 0
      },
      longTasks: {
        supported: true,
        count: 0,
        totalDurationMs: 0,
        maxDurationMs: 0
      },
      counters: { ...defaultPerformanceCounters(), labels: 12, lumeLinks: 1, domNodes: 700 },
      counterDeltas: { hudUpdates: 30, minimapRefreshes: 10, fogRedraws: 8, notificationsEmitted: 1 },
      ratesPerSecond: { hudUpdates: 3, minimapRefreshes: 1, fogRedraws: 0.8, notificationsEmitted: 0.1 }
    },
    interactions: { selectHeroMs: 10, minimapClickMs: 14 },
    rawFrameIntervalArtifact: "artifacts/performance/v0109/raw-frame-intervals/test.json",
    interactionLatencyArtifact: "artifacts/performance/v0109/interaction-latency/test.json"
  };
}
