import { describe, expect, it } from "vitest";
import { createDefaultBattleLoopDiagnostics, type BattleLoopPhaseSummary } from "./BattleLoopPhaseProfiler";
import {
  V0113_SPATIAL_QUERY_PROFILE_CASES,
  createV0113ParitySummary,
  renderPathRequestDedupSpecMarkdown,
  renderSpatialIndexDecisionMarkdown,
  renderSpatialQueryProfileMarkdown,
  spatialQueryRatesPerSecond,
  type SpatialQueryProfileResult
} from "./SpatialQueryPathingProfile";
import { createEmptySpatialQueryCounters } from "../systems/SpatialQueryMetrics";

describe("SpatialQueryPathingProfile", () => {
  it("covers the required v0.113 profile matrix", () => {
    expect(V0113_SPATIAL_QUERY_PROFILE_CASES.map((entry) => entry.posture)).toEqual([
      "hero-only",
      "hero-worker",
      "five-troops",
      "tier-s",
      "tier-m-idle",
      "tier-m-moving",
      "tier-m-combat",
      "tier-l-idle",
      "tier-l-moving",
      "tier-l-combat",
      "ai-paused",
      "path-requests-paused",
      "combat-paused",
      "static-entities"
    ]);
  });

  it("keeps the optimization reports scoped to exact-semantics reuse", () => {
    expect(renderPathRequestDedupSpecMarkdown()).toContain("exact same-frame");
    expect(renderPathRequestDedupSpecMarkdown()).toContain("No AI strategy");
    expect(renderSpatialIndexDecisionMarkdown([])).toContain("do not add a quadtree");
    expect(createV0113ParitySummary().targetPriorityChanged).toBe(false);
  });

  it("renders measured spatial query counters", () => {
    const counters = createEmptySpatialQueryCounters();
    counters.pathRequests = 2;
    counters.pathCacheHits = 1;
    counters.targetAcquisitionScans = 3;
    counters.entitiesVisited = 12;
    counters.distanceCalculations = 6;

    expect(spatialQueryRatesPerSecond(counters, 1000)).toMatchObject({
      pathRequests: 2,
      pathCacheHits: 1,
      targetAcquisitionScans: 3
    });
    expect(renderSpatialQueryProfileMarkdown([profileResult(counters)])).toContain("v0113_tier_m_combat");
    expect(renderSpatialQueryProfileMarkdown([profileResult(counters)])).toContain("| 2 | 1 | 3 | 12 | 6 |");
  });
});

function profileResult(counters = createEmptySpatialQueryCounters()): SpatialQueryProfileResult {
  return {
    caseId: "v0113_tier_m_combat",
    title: "Tier M combat",
    launchScenarioId: "benchmark_battle_tier_m_representative",
    posture: "tier-m-combat",
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
      counters: {
        displayObjects: 0,
        graphicsObjects: 0,
        units: 0,
        buildings: 0,
        captureSites: 0,
        labels: 0,
        captureRings: 0,
        lumeLinks: 0,
        lumeEndpoints: 0,
        fogRedraws: 0,
        fogVisibleCells: 0,
        minimapRefreshes: 0,
        hudUpdates: 0,
        notificationsEmitted: 0,
        notificationsVisible: 0,
        domNodes: 0
      },
      counterDeltas: {},
      ratesPerSecond: {
        fogRedraws: 0,
        minimapRefreshes: 0,
        hudUpdates: 0,
        notificationsEmitted: 0
      }
    },
    phaseSummary: phaseSummary(),
    spatialQueryCounters: counters,
    spatialRatesPerSecond: spatialQueryRatesPerSecond(counters, 1000),
    rawFrameIntervalArtifact: "raw-frame-intervals/v0113_tier_m_combat.json",
    rawPhaseSummaryArtifact: "raw-phase-summaries/v0113_tier_m_combat.json",
    rawSpatialQueryArtifact: "raw-spatial-query/v0113_tier_m_combat.json"
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
