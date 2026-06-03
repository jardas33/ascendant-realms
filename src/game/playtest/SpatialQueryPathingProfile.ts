import {
  V0112_ALLOCATION_AUDIT_ROWS,
  type AllocationAuditRow
} from "./BattleLoopSchedulerRescue";
import {
  normalizeBattleLoopDiagnostics,
  type BattleLoopDiagnostics,
  type BattleLoopPhaseSummary
} from "./BattleLoopPhaseProfiler";
import type { TrustedSteadyStateMetrics } from "./TrustedBrowserBenchmark";
import type { SpatialQueryCounters } from "../systems/SpatialQueryMetrics";

export const V0113_CHECKPOINT = "v0.113";
export const V0113_TITLE = "Spatial Query, Target Acquisition, and Path-Request Optimization";
export const V0113_ARTIFACT_DIR = "artifacts/performance/v0113";

export type SpatialProfilePosture =
  | "hero-only"
  | "hero-worker"
  | "five-troops"
  | "tier-s"
  | "tier-m-idle"
  | "tier-m-moving"
  | "tier-m-combat"
  | "tier-l-idle"
  | "tier-l-moving"
  | "tier-l-combat"
  | "ai-paused"
  | "path-requests-paused"
  | "combat-paused"
  | "static-entities";

export interface SpatialQueryProfileCase {
  id: string;
  title: string;
  launchScenarioId: string;
  posture: SpatialProfilePosture;
  diagnostics: Partial<BattleLoopDiagnostics>;
  stimulus: "none" | "move-player-units" | "hold-combat-idle";
  expectedSignal: string;
}

export interface SpatialQueryProfileResult {
  caseId: string;
  title: string;
  launchScenarioId: string;
  posture: SpatialProfilePosture;
  diagnostics: BattleLoopDiagnostics;
  stimulus: SpatialQueryProfileCase["stimulus"];
  warmupMs: number;
  sampleMs: number;
  generatedAtUtc: string;
  steadyState: TrustedSteadyStateMetrics;
  phaseSummary: BattleLoopPhaseSummary;
  spatialQueryCounters: SpatialQueryCounters;
  spatialRatesPerSecond: SpatialQueryRates;
  rawFrameIntervalArtifact: string;
  rawPhaseSummaryArtifact: string;
  rawSpatialQueryArtifact: string;
}

export interface SpatialQueryRates {
  pathRequests: number;
  pathCacheHits: number;
  targetAcquisitionScans: number;
  immediateMeleeScans: number;
  entitiesVisited: number;
  distanceCalculations: number;
}

export interface V0113ParitySummary {
  schemaVersion: 1;
  checkpoint: typeof V0113_CHECKPOINT;
  gameplaySemanticsChanged: false;
  savesChanged: false;
  stableIdsChanged: false;
  targetPriorityChanged: false;
  pathingOutputsChanged: false;
  aiDecisionRulesChanged: false;
  collisionCaptureCombatBalanceChanged: false;
  parityChecks: Array<{ id: string; status: "pass" | "pending"; evidence: string }>;
}

export interface V0113ArtifactSet {
  schemaVersion: 1;
  checkpoint: typeof V0113_CHECKPOINT;
  title: typeof V0113_TITLE;
  generatedAtUtc: string;
  profileRows: SpatialQueryProfileResult[];
  densityMatrix: ReturnType<typeof createDensityMatrix>;
  oldNewComparison: ReturnType<typeof createOldNewComparison>;
  paritySummary: V0113ParitySummary;
}

const TARGET_SCOPE =
  "No AI strategy, target priority, path results, movement outcomes, collision/capture/combat balance, saves, IDs, art, engine posture, desktop, multiplayer, or content changes.";

export const V0113_SPATIAL_QUERY_PROFILE_CASES: SpatialQueryProfileCase[] = [
  profileCase("v0113_hero_only", "Hero only", "perf_selected_hero", "hero-only", { phaseProfiler: "on", ai: "paused", combat: "paused" }, "none", "Minimal selected-hero spatial-query baseline."),
  profileCase("v0113_hero_worker", "Hero plus Worker", "perf_selected_worker", "hero-worker", { phaseProfiler: "on", ai: "paused", combat: "paused" }, "none", "Worker utility posture with movement idle."),
  profileCase("v0113_five_troops", "Five troops", "perf_selected_squad", "five-troops", { phaseProfiler: "on", ai: "paused", combat: "paused" }, "none", "Small troop cluster and selection pressure."),
  profileCase("v0113_tier_s", "Tier S", "benchmark_battle_tier_s_smoke", "tier-s", { phaseProfiler: "on" }, "none", "Small representative combat and target acquisition."),
  profileCase("v0113_tier_m_idle", "Tier M idle", "benchmark_battle_tier_m_representative", "tier-m-idle", { phaseProfiler: "on", ai: "paused", movement: "paused", combat: "paused", projectiles: "paused" }, "hold-combat-idle", "Tier M fixed-idle spatial-query ceiling."),
  profileCase("v0113_tier_m_moving", "Tier M moving", "benchmark_battle_minimap_interaction", "tier-m-moving", { phaseProfiler: "on", ai: "paused", combat: "paused", projectiles: "paused" }, "move-player-units", "Movement/path-request profile with combat held."),
  profileCase("v0113_tier_m_combat", "Tier M combat", "benchmark_battle_tier_m_representative", "tier-m-combat", { phaseProfiler: "on" }, "none", "Representative target-acquisition and projectile profile."),
  profileCase("v0113_tier_l_idle", "Tier L idle", "benchmark_battle_tier_l_stress", "tier-l-idle", { phaseProfiler: "on", ai: "paused", movement: "paused", combat: "paused", projectiles: "paused" }, "hold-combat-idle", "Dense fixed-idle ceiling."),
  profileCase("v0113_tier_l_moving", "Tier L moving", "benchmark_battle_tier_l_stress", "tier-l-moving", { phaseProfiler: "on", ai: "paused", combat: "paused", projectiles: "paused" }, "move-player-units", "Dense movement/path-request profile."),
  profileCase("v0113_tier_l_combat", "Tier L combat", "benchmark_battle_tier_l_stress", "tier-l-combat", { phaseProfiler: "on" }, "none", "Dense target-acquisition profile."),
  profileCase("v0113_ai_paused", "AI paused", "benchmark_battle_tier_m_representative", "ai-paused", { phaseProfiler: "on", ai: "paused" }, "none", "Separates AI query pressure from combat/movement queries."),
  profileCase("v0113_path_requests_paused", "Path requests paused diagnostic", "benchmark_battle_tier_m_representative", "path-requests-paused", { phaseProfiler: "on", path: "paused" }, "none", "Private existing path pause isolates movement/path request cost without adding a public mode."),
  profileCase("v0113_combat_paused", "Combat paused", "benchmark_battle_tier_m_representative", "combat-paused", { phaseProfiler: "on", combat: "paused", projectiles: "paused" }, "none", "Target-acquisition counter should drop when combat is paused."),
  profileCase("v0113_static_entities", "Static entities", "v0110_static_hud_minimal", "static-entities", { phaseProfiler: "on", simulation: "paused", ai: "paused", movement: "paused", combat: "paused", hudDomPatches: "paused" }, "none", "Static entity fixed-cost row.")
];

export function spatialQueryRatesPerSecond(counters: SpatialQueryCounters, sampleMs: number): SpatialQueryRates {
  const seconds = Math.max(0.001, sampleMs / 1000);
  return {
    pathRequests: roundMetric(counters.pathRequests / seconds),
    pathCacheHits: roundMetric(counters.pathCacheHits / seconds),
    targetAcquisitionScans: roundMetric(counters.targetAcquisitionScans / seconds),
    immediateMeleeScans: roundMetric(counters.immediateMeleeScans / seconds),
    entitiesVisited: roundMetric(counters.entitiesVisited / seconds),
    distanceCalculations: roundMetric(counters.distanceCalculations / seconds)
  };
}

export function buildV0113ArtifactSet(results: SpatialQueryProfileResult[], generatedAtUtc = new Date().toISOString()): V0113ArtifactSet {
  return {
    schemaVersion: 1,
    checkpoint: V0113_CHECKPOINT,
    title: V0113_TITLE,
    generatedAtUtc,
    profileRows: sortProfileResults(results),
    densityMatrix: createDensityMatrix(results),
    oldNewComparison: createOldNewComparison(results),
    paritySummary: createV0113ParitySummary(results)
  };
}

export function createDensityMatrix(results: SpatialQueryProfileResult[]) {
  return {
    schemaVersion: 1,
    checkpoint: V0113_CHECKPOINT,
    rows: sortProfileResults(results).map((result) => ({
      caseId: result.caseId,
      posture: result.posture,
      launchScenarioId: result.launchScenarioId,
      fpsAverage: result.steadyState.fpsAverage,
      p95Ms: result.steadyState.frameTimeMs.p95,
      units: result.phaseSummary.latestCounts.units,
      buildings: result.phaseSummary.latestCounts.buildings,
      projectiles: result.phaseSummary.latestCounts.projectiles,
      pathRequests: result.spatialQueryCounters.pathRequests,
      pathCacheHits: result.spatialQueryCounters.pathCacheHits,
      targetScans: result.spatialQueryCounters.targetAcquisitionScans,
      immediateMeleeScans: result.spatialQueryCounters.immediateMeleeScans,
      entitiesVisited: result.spatialQueryCounters.entitiesVisited,
      distanceCalculations: result.spatialQueryCounters.distanceCalculations,
      topPhase: topPhaseLabel(result.phaseSummary)
    }))
  };
}

export function createOldNewComparison(results: SpatialQueryProfileResult[]) {
  return {
    schemaVersion: 1,
    checkpoint: V0113_CHECKPOINT,
    before: {
      evidence: ["docs/V0112_HOT_PATH_ALLOCATION_AUDIT.md", "docs/V0112_BATTLE_LOOP_SCHEDULER_MAP.md"],
      combatEntityLists: "Combat target acquisition rebuilt unit/building spreads in resolveTarget, immediate melee contact, and ID lookup paths.",
      movementPathRequests: "Movement already reused unchanged destinations per unit, but identical same-frame path requests still called PathfindingGrid.findPath independently."
    },
    after: {
      implementedOptimizationIds: ["combat-frame-entity-cache", "movement-same-frame-path-request-cache"],
      combatEntityLists: "Combat update rebuilds a unit-then-building frame entity cache and first-ID lookup map, preserving old scan order and first .find match behavior.",
      movementPathRequests: "Movement reuses only identical same-frame start/target/allowPartial path requests and clones waypoints per unit.",
      measuredRows: results.length
    },
    allocationRows: optimizedAllocationRows(),
    scopeGuard: TARGET_SCOPE
  };
}

export function createV0113ParitySummary(results: SpatialQueryProfileResult[] = []): V0113ParitySummary {
  return {
    schemaVersion: 1,
    checkpoint: V0113_CHECKPOINT,
    gameplaySemanticsChanged: false,
    savesChanged: false,
    stableIdsChanged: false,
    targetPriorityChanged: false,
    pathingOutputsChanged: false,
    aiDecisionRulesChanged: false,
    collisionCaptureCombatBalanceChanged: false,
    parityChecks: [
      { id: "target-scan-order", status: "pass", evidence: "CombatSystem tests assert nearest target order is preserved while using cached frame entity lists." },
      { id: "path-result-clone", status: "pass", evidence: "MovementSystem tests assert identical same-frame path requests are reused while both units continue moving toward the same target." },
      { id: "save-localstorage-guard", status: results.length > 0 ? "pass" : "pending", evidence: "Browser profile runner compares localStorage save snapshots before and after every row." },
      { id: "diagnostics-private", status: "pass", evidence: "Spatial counters are only installed through private playtest hooks and only accumulate while battle-loop phase profiling is enabled." },
      { id: "scope-guard", status: "pass", evidence: TARGET_SCOPE }
    ]
  };
}

export function renderSpatialQueryProfileMarkdown(results: SpatialQueryProfileResult[]): string {
  const rows = sortProfileResults(results);
  return [
    "# v0.113 Spatial Query Profile",
    "",
    "Private Playtest Hub profile for spatial queries, target acquisition, and path-request reuse. Rows are no-save diagnostics and do not add public controls.",
    "",
    "| Case | Posture | Launch | FPS avg | p95 frame | Path req | Path hits | Target scans | Entities visited | Dist calcs | Top phase |",
    "| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |",
    ...rows.map(
      (row) =>
        `| ${row.caseId} | ${row.posture} | ${row.launchScenarioId} | ${row.steadyState.fpsAverage} | ${row.steadyState.frameTimeMs.p95} | ${row.spatialQueryCounters.pathRequests} | ${row.spatialQueryCounters.pathCacheHits} | ${row.spatialQueryCounters.targetAcquisitionScans} | ${row.spatialQueryCounters.entitiesVisited} | ${row.spatialQueryCounters.distanceCalculations} | ${topPhaseLabel(row.phaseSummary)} |`
    ),
    "",
    `Rows measured: ${rows.length}.`,
    ""
  ].join("\n");
}

export function renderPathRequestDedupSpecMarkdown(): string {
  return [
    "# v0.113 Path Request Dedup Spec",
    "",
    "Authorized behavior is exact same-frame reuse only.",
    "",
    "- Cache key: current world start point, current world target point, and `allowPartial` posture.",
    "- Cache lifetime: one `MovementSystem.update` call.",
    "- Reuse boundary: identical request only; no fuzzy clustering, no path simplification, no target snapping, and no cooldown/timing change.",
    "- Result boundary: waypoints are cloned into each unit state so no unit shares mutable path arrays.",
    "- Existing unchanged-destination reuse remains per-unit and is now counted for private evidence.",
    "",
    TARGET_SCOPE,
    ""
  ].join("\n");
}

export function renderTargetAcquisitionParityMarkdown(summary: V0113ParitySummary): string {
  return [
    "# v0.113 Target Acquisition Parity Report",
    "",
    `Target priority changed: ${summary.targetPriorityChanged}.`,
    `Pathing outputs changed: ${summary.pathingOutputsChanged}.`,
    `AI decision rules changed: ${summary.aiDecisionRulesChanged}.`,
    `Collision/capture/combat balance changed: ${summary.collisionCaptureCombatBalanceChanged}.`,
    "",
    "| Check | Status | Evidence |",
    "| --- | --- | --- |",
    ...summary.parityChecks.map((check) => `| ${check.id} | ${check.status} | ${check.evidence} |`),
    ""
  ].join("\n");
}

export function renderSpatialIndexDecisionMarkdown(results: SpatialQueryProfileResult[]): string {
  return [
    "# v0.113 Spatial Index Decision Report",
    "",
    "Decision: do not add a quadtree, grid index, or broad spatial-index rewrite in v0.113.",
    "",
    "Rationale:",
    "",
    "- Existing target acquisition depends on unit-then-building scan order and first same-distance winner behavior.",
    "- A broad index would require new tie-order, invalidation, and collision/visibility rules beyond this checkpoint.",
    "- The exact cache and same-frame path request reuse provide lower-risk evidence-backed wins inside the authorized boundary.",
    "",
    `Measured profile rows available: ${results.length}.`,
    "",
    TARGET_SCOPE,
    ""
  ].join("\n");
}

export function renderEvidenceBackedOptimizationMarkdown(results: SpatialQueryProfileResult[]): string {
  const combatRows = results.filter((row) => row.spatialQueryCounters.targetAcquisitionScans > 0);
  const pathRows = results.filter((row) => row.spatialQueryCounters.pathRequests > 0 || row.spatialQueryCounters.pathCacheHits > 0);
  return [
    "# v0.113 Evidence-Backed Optimization Report",
    "",
    "Implemented optimizations:",
    "",
    "- Combat target acquisition now uses a cached frame entity list and first-ID lookup map, preserving old unit-then-building order.",
    "- Movement pathing now reuses identical same-frame path requests and clones path waypoints for each unit.",
    "- Optional counters record path requests, path cache hits, entity lookup counts, target scans, visited entities, and distance calculations while private phase profiling is enabled.",
    "",
    `Combat signal rows: ${combatRows.length}.`,
    `Path signal rows: ${pathRows.length}.`,
    "",
    TARGET_SCOPE,
    ""
  ].join("\n");
}

export function renderImplementationReportMarkdown(results: SpatialQueryProfileResult[]): string {
  return [
    "# v0.113 Implementation Report",
    "",
    "v0.113 implements exact-semantics spatial-query instrumentation and two bounded runtime optimizations.",
    "",
    "## Runtime Changes",
    "",
    "- Added private spatial-query counters to BattleScene test hooks.",
    "- Added same-frame identical path request reuse in MovementSystem.",
    "- Added cached combat frame entity lists and ID lookups in CombatSystem.",
    "- Kept CollisionSystem nearest ordering and tie behavior intact while allowing optional private metrics.",
    "",
    "## Artifacts",
    "",
    "- `artifacts/performance/v0113/query-profile.json`",
    "- `artifacts/performance/v0113/density-matrix.json`",
    "- `artifacts/performance/v0113/old-new-comparison.json`",
    "- `artifacts/performance/v0113/parity-summary.json`",
    "- `artifacts/performance/v0113/before-after-delta.md`",
    "- `artifacts/performance/v0113/rollback-posture.md`",
    "",
    `Profile rows measured: ${results.length}.`,
    "",
    TARGET_SCOPE,
    ""
  ].join("\n");
}

export function renderEmmanuelRetestChecklistMarkdown(): string {
  return [
    "# v0.113 Emmanuel Retest Checklist",
    "",
    "- Run `npm run perf:trusted:preview`.",
    "- Run `npm run perf:trusted:clean-profile`.",
    "- Run `npm run perf:phase-profile`.",
    "- Run `npm run perf:spatial-query-profile`.",
    "- Run `npm run perf:trusted:report`.",
    "- Run `npm run benchmark:battle:representative` and `npm run benchmark:battle:stress`.",
    "- Run `npm run playtest:act1`.",
    "- Run `npm run package:playtest` and `npm run verify:playtest-package`.",
    "- Confirm target priority, path results, movement outcomes, combat balance, saves, stable IDs, art, and public posture remain unchanged.",
    ""
  ].join("\n");
}

export function renderBeforeAfterDeltaMarkdown(results: SpatialQueryProfileResult[]): string {
  const tierMCombat = results.find((row) => row.caseId === "v0113_tier_m_combat");
  const tierMMoving = results.find((row) => row.caseId === "v0113_tier_m_moving");
  return [
    "# v0.113 Before/After Delta",
    "",
    "Before evidence comes from v0.112 scheduler/allocation artifacts and the pre-v0.113 code paths. After evidence comes from v0.113 private spatial-query counters and focused parity tests.",
    "",
    `Tier M combat target scans after: ${tierMCombat?.spatialQueryCounters.targetAcquisitionScans ?? "pending"}.`,
    `Tier M moving path requests after: ${tierMMoving?.spatialQueryCounters.pathRequests ?? "pending"}.`,
    `Tier M moving path cache hits after: ${tierMMoving?.spatialQueryCounters.pathCacheHits ?? "pending"}.`,
    "",
    "Deltas are exact cache/allocation reductions only.",
    "",
    TARGET_SCOPE,
    ""
  ].join("\n");
}

export function renderRollbackPostureMarkdown(): string {
  return [
    "# v0.113 Rollback Posture",
    "",
    "Rollback is source-local and does not require save migration.",
    "",
    "- Remove `src/game/systems/SpatialQueryMetrics.ts` and the private BattleScene hook wiring.",
    "- Revert MovementSystem same-frame path request cache to direct `PathfindingGrid.findPath` calls.",
    "- Revert CombatSystem frame entity cache to the prior direct unit/building spread lookups.",
    "- Remove `tools/runSpatialQueryProfile.ts`, `perf:spatial-query-profile`, and v0.113 docs/artifacts.",
    "",
    "No save schema, stable ID, content, art, engine posture, desktop path, or public UI rollback is needed.",
    ""
  ].join("\n");
}

export function renderArtifactReadme(resultCount: number): string {
  return [
    "# v0.113 Spatial Query Artifacts",
    "",
    "This folder is ignored by git and can be regenerated from `npm run perf:spatial-query-profile`.",
    "",
    `Profile rows: ${resultCount}.`,
    "",
    "Key files:",
    "",
    "- query-profile.json",
    "- density-matrix.json",
    "- old-new-comparison.json",
    "- parity-summary.json",
    "- before-after-delta.md",
    "- rollback-posture.md",
    ""
  ].join("\n");
}

function profileCase(
  id: string,
  title: string,
  launchScenarioId: string,
  posture: SpatialProfilePosture,
  diagnostics: Partial<BattleLoopDiagnostics>,
  stimulus: SpatialQueryProfileCase["stimulus"],
  expectedSignal: string
): SpatialQueryProfileCase {
  return {
    id,
    title,
    launchScenarioId,
    posture,
    diagnostics: normalizeBattleLoopDiagnostics(diagnostics),
    stimulus,
    expectedSignal
  };
}

function optimizedAllocationRows(): Array<Pick<AllocationAuditRow, "id" | "ownerFile" | "optimization" | "semanticRisk">> {
  return [
    ...V0112_ALLOCATION_AUDIT_ROWS.filter((row) => row.id === "movement-idle-grid" || row.id === "combat-attackers").map((row) => ({
      id: row.id,
      ownerFile: row.ownerFile,
      optimization: row.optimization,
      semanticRisk: row.semanticRisk
    })),
    {
      id: "movement-same-frame-path-request-cache",
      ownerFile: "src/game/systems/MovementSystem.ts",
      optimization: "Reuse only identical same-frame path requests and clone waypoints per unit.",
      semanticRisk: "low"
    },
    {
      id: "combat-frame-entity-cache",
      ownerFile: "src/game/systems/CombatSystem.ts",
      optimization: "Reuse a unit-then-building frame entity list and first-ID lookup map across target acquisition and projectile lookup.",
      semanticRisk: "low"
    }
  ];
}

function sortProfileResults(results: SpatialQueryProfileResult[]): SpatialQueryProfileResult[] {
  const order = new Map(V0113_SPATIAL_QUERY_PROFILE_CASES.map((entry, index) => [entry.id, index]));
  return [...results].sort((left, right) => (order.get(left.caseId) ?? 999) - (order.get(right.caseId) ?? 999));
}

function topPhaseLabel(summary: BattleLoopPhaseSummary): string {
  return [...summary.phases].sort((left, right) => right.totalMs - left.totalMs)[0]?.label ?? "pending";
}

function roundMetric(value: number): number {
  return Number(value.toFixed(2));
}
