import {
  normalizeBattleLoopDiagnostics,
  type BattleLoopDiagnostics,
  type BattleLoopPhaseSummary
} from "./BattleLoopPhaseProfiler";
import type { PrivatePerformanceCounters } from "./PrivatePerformanceProfiler";
import type { TrustedSteadyStateMetrics } from "./TrustedBrowserBenchmark";
import type { RenderLifecycleCounters } from "../systems/RenderLifecycleMetrics";
import { renderLifecycleRatesPerSecond } from "../systems/RenderLifecycleMetrics";

export const V0114_CHECKPOINT = "v0.114";
export const V0114_TITLE = "Renderer Lifecycle, Procedural Batching, and Canvas-DOM Boundary Rescue";
export const V0114_ARTIFACT_DIR = "artifacts/performance/v0114";

export type RenderLifecycleSurface = "battle" | "results" | "campaign";
export type RenderLifecyclePosture =
  | "phaser-empty"
  | "tier-s"
  | "tier-m-idle"
  | "tier-m-moving"
  | "tier-m-combat"
  | "tier-l-stress"
  | "fog-heavy"
  | "lume-auto"
  | "lume-always"
  | "label-heavy"
  | "notification-heavy"
  | "hud-minimal"
  | "hud-standard"
  | "results-transition"
  | "campaign-map";

export interface RenderLifecycleAuditCase {
  id: string;
  title: string;
  launchScenarioId: string;
  surface: RenderLifecycleSurface;
  posture: RenderLifecyclePosture;
  diagnostics: Partial<BattleLoopDiagnostics>;
  stimulus: "none" | "move-player-units" | "command-markers" | "notifications" | "results" | "campaign-dom";
  expectedSignal: string;
}

export interface RenderLifecycleAuditResult {
  caseId: string;
  title: string;
  launchScenarioId: string;
  surface: RenderLifecycleSurface;
  posture: RenderLifecyclePosture;
  diagnostics: BattleLoopDiagnostics;
  stimulus: RenderLifecycleAuditCase["stimulus"];
  warmupMs: number;
  sampleMs: number;
  generatedAtUtc: string;
  steadyState: TrustedSteadyStateMetrics;
  phaseSummary?: BattleLoopPhaseSummary;
  privateCounters: Partial<PrivatePerformanceCounters>;
  renderLifecycleCounters: RenderLifecycleCounters;
  renderLifecycleRates: RenderLifecycleRates;
  rawFrameIntervalArtifact: string;
  rawPhaseSummaryArtifact?: string;
  rawRenderLifecycleArtifact: string;
  screenshotArtifact?: string;
}

export type RenderLifecycleRates = ReturnType<typeof renderLifecycleRatesPerSecond>;

export interface RenderLifecycleVisualParityCheck {
  id: string;
  surface: RenderLifecycleSurface;
  status: "pass" | "pending";
  evidence: string;
}

export interface RenderLifecycleArtifactSet {
  schemaVersion: 1;
  checkpoint: typeof V0114_CHECKPOINT;
  title: typeof V0114_TITLE;
  generatedAtUtc: string;
  rows: RenderLifecycleAuditResult[];
  beforeAfterDelta: ReturnType<typeof createBeforeAfterDelta>;
  memoryTrend: ReturnType<typeof createMemoryTrend>;
  visualParity: ReturnType<typeof createVisualParitySummary>;
}

const SCOPE_GUARD =
  "No art, gameplay, balance, AI, pathing, fog simulation, saves, stable IDs, engine posture, desktop, multiplayer, content, public benchmark posture, or v0.115 work changed.";

export const V0114_RENDER_LIFECYCLE_AUDIT_CASES: RenderLifecycleAuditCase[] = [
  auditCase("v0114_phaser_empty", "Phaser empty/static scene", "v0110_empty_static", "battle", "phaser-empty", { phaseProfiler: "on", simulation: "paused", ai: "paused", movement: "paused", combat: "paused", fogSimulation: "paused" }, "none", "Baseline renderer/display-list retention with simulation paused."),
  auditCase("v0114_tier_s", "Tier S", "benchmark_battle_tier_s_smoke", "battle", "tier-s", { phaseProfiler: "on" }, "none", "Small representative battle renderer lifecycle."),
  auditCase("v0114_tier_m_idle", "Tier M idle", "benchmark_battle_tier_m_representative", "battle", "tier-m-idle", { phaseProfiler: "on", ai: "paused", movement: "paused", combat: "paused", projectiles: "paused" }, "none", "Representative fixed-idle canvas and HUD cost."),
  auditCase("v0114_tier_m_moving", "Tier M moving", "benchmark_battle_minimap_interaction", "battle", "tier-m-moving", { phaseProfiler: "on", ai: "paused", combat: "paused", projectiles: "paused" }, "move-player-units", "Movement plus command marker and minimap invalidation pressure."),
  auditCase("v0114_tier_m_combat", "Tier M combat", "benchmark_battle_tier_m_representative", "battle", "tier-m-combat", { phaseProfiler: "on" }, "none", "Representative combat canvas/HUD pressure."),
  auditCase("v0114_tier_l_stress", "Tier L stress", "benchmark_battle_tier_l_stress", "battle", "tier-l-stress", { phaseProfiler: "on" }, "none", "High-density local-only renderer lifecycle stress."),
  auditCase("v0114_fog_heavy", "Fog-heavy", "benchmark_battle_fog_heavy", "battle", "fog-heavy", { phaseProfiler: "on" }, "none", "Fog presentation redraw and minimap cache invalidation pressure."),
  auditCase("v0114_lume_auto", "Lume Auto", "benchmark_battle_lume_auto", "battle", "lume-auto", { phaseProfiler: "on", lume: "auto" }, "none", "Default Lume renderer cache behavior."),
  auditCase("v0114_lume_always", "Lume Always", "benchmark_battle_lume_always", "battle", "lume-always", { phaseProfiler: "on", lume: "always" }, "none", "Always-visible Lume renderer cache behavior."),
  auditCase("v0114_label_heavy", "Label-heavy", "perf_label_heavy_site_cluster", "battle", "label-heavy", { phaseProfiler: "on", labels: "normal" }, "command-markers", "Site labels, capture rings, command marker pool, and text reuse pressure."),
  auditCase("v0114_notification_heavy", "Notification-heavy", "benchmark_battle_notification_heavy", "battle", "notification-heavy", { phaseProfiler: "on", notifications: "normal" }, "notifications", "Status/floating notification churn and HUD patch boundary."),
  auditCase("v0114_hud_minimal", "HUD Minimal", "perf_hud_minimal", "battle", "hud-minimal", { phaseProfiler: "on", hudDomPatches: "normal" }, "none", "Minimal HUD DOM view-model and patch cost."),
  auditCase("v0114_hud_standard", "HUD Standard", "perf_hud_standard", "battle", "hud-standard", { phaseProfiler: "on", hudDomPatches: "normal" }, "none", "Standard HUD DOM view-model and patch cost."),
  auditCase("v0114_results_transition", "Results transition", "benchmark_battle_results_transition", "results", "results-transition", { phaseProfiler: "on" }, "results", "Battle-to-results transition safety and DOM cleanup."),
  auditCase("v0114_campaign_map", "Campaign map", "perf_campaign_map_interaction", "campaign", "campaign-map", { phaseProfiler: "off" }, "campaign-dom", "Campaign-map DOM shell parity and no-save preview.")
];

export function renderLifecycleAuditRates(counters: RenderLifecycleCounters, sampleMs: number): RenderLifecycleRates {
  return renderLifecycleRatesPerSecond(counters, sampleMs);
}

export function buildV0114ArtifactSet(results: RenderLifecycleAuditResult[], generatedAtUtc = new Date().toISOString()): RenderLifecycleArtifactSet {
  const rows = sortAuditResults(results);
  return {
    schemaVersion: 1,
    checkpoint: V0114_CHECKPOINT,
    title: V0114_TITLE,
    generatedAtUtc,
    rows,
    beforeAfterDelta: createBeforeAfterDelta(rows),
    memoryTrend: createMemoryTrend(rows),
    visualParity: createVisualParitySummary(rows)
  };
}

export function createBeforeAfterDelta(results: RenderLifecycleAuditResult[]) {
  return {
    schemaVersion: 1,
    checkpoint: V0114_CHECKPOINT,
    beforeEvidence: [
      "docs/V0110_DENSITY_SCALING_REPORT.md",
      "docs/V0110_DEFERRED_ARCHITECTURE_FINDINGS.md",
      "docs/V0112_HOT_PATH_ALLOCATION_AUDIT.md",
      "docs/V0112_BATTLE_LOOP_SCHEDULER_MAP.md"
    ],
    afterRows: sortAuditResults(results).map((row) => ({
      caseId: row.caseId,
      fpsAverage: row.steadyState.fpsAverage,
      p95Ms: row.steadyState.frameTimeMs.p95,
      graphicsCreated: row.renderLifecycleCounters.graphicsCreated,
      graphicsDestroyed: row.renderLifecycleCounters.graphicsDestroyed,
      textObjectsCreated: row.renderLifecycleCounters.textObjectsCreated,
      textObjectsDestroyed: row.renderLifecycleCounters.textObjectsDestroyed,
      domPatches: row.renderLifecycleCounters.domPatches,
      minimapSnapshots: row.renderLifecycleCounters.minimapSnapshots,
      retainedObjectCount: row.renderLifecycleCounters.retainedObjectCount,
      memoryUsedMb: row.renderLifecycleCounters.memoryUsedMb
    })),
    implementedOptimizationIds: [
      "static-terrain-geometry-cache",
      "volatile-hud-dom-diff",
      "command-marker-graphics-text-pool",
      "capture-ring-label-no-op-guard",
      "health-bar-no-op-guard",
      "minimap-due-or-dirty-cache"
    ],
    scopeGuard: SCOPE_GUARD
  };
}

export function createMemoryTrend(results: RenderLifecycleAuditResult[]) {
  return {
    schemaVersion: 1,
    checkpoint: V0114_CHECKPOINT,
    rows: sortAuditResults(results).map((row) => ({
      caseId: row.caseId,
      memoryUsedMb: row.renderLifecycleCounters.memoryUsedMb,
      steadyStateTrendMb: row.steadyState.memoryTrendMb,
      retainedObjectCount: row.renderLifecycleCounters.retainedObjectCount,
      detachedDomNodes: row.renderLifecycleCounters.detachedDomNodes
    }))
  };
}

export function createVisualParitySummary(results: RenderLifecycleAuditResult[]) {
  const resultByCase = new Map(results.map((row) => [row.caseId, row]));
  const screenshotEvidence = (caseId: string, label: string): RenderLifecycleVisualParityCheck => {
    const result = resultByCase.get(caseId);
    return {
      id: label,
      surface: result?.surface ?? "battle",
      status: result?.screenshotArtifact ? "pass" : "pending",
      evidence: result?.screenshotArtifact ?? `Pending screenshot from ${caseId}.`
    };
  };
  return {
    schemaVersion: 1,
    checkpoint: V0114_CHECKPOINT,
    checks: [
      screenshotEvidence("v0114_phaser_empty", "phaser-empty-canvas"),
      screenshotEvidence("v0114_fog_heavy", "terrain-fog-roads-water-sites-minimap"),
      screenshotEvidence("v0114_label_heavy", "selected-hero-worker-building-rings-labels-markers"),
      screenshotEvidence("v0114_lume_auto", "lume-auto"),
      screenshotEvidence("v0114_lume_always", "lume-always"),
      screenshotEvidence("v0114_notification_heavy", "notifications-hud"),
      screenshotEvidence("v0114_results_transition", "results-transition"),
      screenshotEvidence("v0114_campaign_map", "campaign-map")
    ],
    scopeGuard: SCOPE_GUARD
  };
}

export function renderRenderLifecycleAuditMarkdown(results: RenderLifecycleAuditResult[]): string {
  const rows = sortAuditResults(results);
  return [
    "# v0.114 Render Lifecycle Audit",
    "",
    "Private Playtest Hub audit for renderer object churn, procedural geometry rebuilds, fog/Lume/minimap/HUD redraws, DOM patches, retained objects, and memory trend.",
    "",
    "| Case | Surface | FPS avg | p95 frame | Graphics +/- | Text +/- | DOM patches | Minimap snapshots | Retained | Memory MB |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...rows.map(
      (row) =>
        `| ${row.caseId} | ${row.surface} | ${row.steadyState.fpsAverage} | ${row.steadyState.frameTimeMs.p95} | ${row.renderLifecycleCounters.graphicsCreated}/${row.renderLifecycleCounters.graphicsDestroyed} | ${row.renderLifecycleCounters.textObjectsCreated}/${row.renderLifecycleCounters.textObjectsDestroyed} | ${row.renderLifecycleCounters.domPatches} | ${row.renderLifecycleCounters.minimapSnapshots} | ${row.renderLifecycleCounters.retainedObjectCount} | ${row.renderLifecycleCounters.memoryUsedMb ?? "n/a"} |`
    ),
    "",
    `Rows measured: ${rows.length}.`,
    "",
    SCOPE_GUARD,
    ""
  ].join("\n");
}

export function renderProceduralBatchingSpecMarkdown(): string {
  return [
    "# v0.114 Procedural Batching Spec",
    "",
    "Allowed batching and caching are presentation-only and deterministic.",
    "",
    "- Static battlefield terrain flecks, shadow patches, grass strokes, and pebbles are cached by map identity/size/count signature before being drawn into the existing Phaser Graphics surface.",
    "- Road, water, blocked-ground, buildable-ground, and capture-site placeholder geometry keeps the same draw order and colors; polyline strokes avoid transient sliced arrays.",
    "- Capture rings, labels, health bars, fog overlay, Lume links, command markers, minimap snapshots, and HUD markup use no-op guards or due/dirty caches only where the incoming presentation state is unchanged.",
    "- Command feedback markers reuse one Graphics plus one Text child per pooled container and clear state before reuse.",
    "",
    SCOPE_GUARD,
    ""
  ].join("\n");
}

export function renderCanvasDomBoundaryReportMarkdown(results: RenderLifecycleAuditResult[]): string {
  const rows = sortAuditResults(results);
  return [
    "# v0.114 Canvas-DOM Boundary Report",
    "",
    "Canvas work remains in Phaser scenes and entity views. DOM work remains in HUD/minimap/status/result/campaign shells.",
    "",
    "| Case | HUD view models | DOM patches | DOM created | DOM destroyed | Detached DOM |",
    "| --- | ---: | ---: | ---: | ---: | ---: |",
    ...rows.map(
      (row) =>
        `| ${row.caseId} | ${row.renderLifecycleCounters.hudViewModels} | ${row.renderLifecycleCounters.domPatches} | ${row.renderLifecycleCounters.domNodesCreated} | ${row.renderLifecycleCounters.domNodesDestroyed} | ${row.renderLifecycleCounters.detachedDomNodes} |`
    ),
    "",
    "HUD volatile regions now skip identical attribute/body replacements; full stable markup changes still use the existing replacement path with scroll-state restore.",
    "",
    SCOPE_GUARD,
    ""
  ].join("\n");
}

export function renderVisualParityReportMarkdown(results: RenderLifecycleAuditResult[]): string {
  const parity = createVisualParitySummary(results);
  return [
    "# v0.114 Visual Parity Report",
    "",
    "Visual parity is screenshot-backed by the private audit runner and remains scoped to existing placeholder/runtime presentation.",
    "",
    "| Check | Surface | Status | Evidence |",
    "| --- | --- | --- | --- |",
    ...parity.checks.map((check) => `| ${check.id} | ${check.surface} | ${check.status} | ${check.evidence} |`),
    "",
    SCOPE_GUARD,
    ""
  ].join("\n");
}

export function renderPerformanceDeltaReportMarkdown(results: RenderLifecycleAuditResult[]): string {
  const delta = createBeforeAfterDelta(results);
  return [
    "# v0.114 Performance Delta Report",
    "",
    "Before evidence comes from v0.110/v0.112 renderer/HUD/fog/minimap hot-path findings. After evidence comes from v0.114 private render-lifecycle counters.",
    "",
    "| Case | FPS avg | p95 frame | Graphics created | Text created | DOM patches | Minimap snapshots | Retained |",
    "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...delta.afterRows.map(
      (row) =>
        `| ${row.caseId} | ${row.fpsAverage} | ${row.p95Ms} | ${row.graphicsCreated} | ${row.textObjectsCreated} | ${row.domPatches} | ${row.minimapSnapshots} | ${row.retainedObjectCount} |`
    ),
    "",
    `Implemented optimizations: ${delta.implementedOptimizationIds.join(", ")}.`,
    "",
    SCOPE_GUARD,
    ""
  ].join("\n");
}

export function renderImplementationReportMarkdown(results: RenderLifecycleAuditResult[]): string {
  return [
    "# v0.114 Implementation Report",
    "",
    "v0.114 adds private render-lifecycle counters and bounded presentation optimizations for existing Phaser Graphics/Text and HUD DOM surfaces.",
    "",
    "## Runtime Changes",
    "",
    "- Added private render-lifecycle metrics and BattleScene hooks.",
    "- Cached deterministic static terrain geometry and removed transient polyline slicing.",
    "- Added no-op guards for capture site visuals, label visibility, health-bar width changes, HUD volatile patches, and local HUD panel state.",
    "- Added command feedback marker Graphics/Text pooling with reset-on-release.",
    "- Added minimap due-or-dirty snapshot reuse without changing minimap contents or visibility rules.",
    "",
    "## Artifacts",
    "",
    "- `artifacts/performance/v0114/lifecycle-audit.json`",
    "- `artifacts/performance/v0114/before-after-delta.json`",
    "- `artifacts/performance/v0114/before-after-delta.md`",
    "- `artifacts/performance/v0114/memory-trend.json`",
    "- `artifacts/performance/v0114/visual-parity.json`",
    "",
    `Audit rows measured: ${results.length}.`,
    "",
    SCOPE_GUARD,
    ""
  ].join("\n");
}

export function renderEmmanuelRetestChecklistMarkdown(): string {
  return [
    "# v0.114 Emmanuel Retest Checklist",
    "",
    "- Run `npm run perf:trusted:preview`.",
    "- Run `npm run perf:trusted:clean-profile`.",
    "- Run `npm run perf:phase-profile`.",
    "- Run `npm run perf:render-lifecycle-audit`.",
    "- Run `npm run perf:trusted:report`.",
    "- Run `npm run benchmark:battle:representative` and `npm run benchmark:battle:stress`.",
    "- Run `npm run visual:qa` and `npm run visual:review-pack`.",
    "- Run `npm run package:playtest` and `npm run verify:playtest-package`.",
    "- Confirm terrain, fog, roads/water, sites, selected hero, Worker, building, rings, Lume, labels, command markers, minimap, HUD, Results, and campaign map still match existing placeholder intent.",
    "- Confirm no save, stable-ID, gameplay, pathing, AI, balance, art, engine, desktop, multiplayer, content, public benchmark, or v0.115 work changed.",
    ""
  ].join("\n");
}

export function renderArtifactReadme(resultCount: number): string {
  return [
    "# v0.114 Render Lifecycle Artifacts",
    "",
    "This folder is ignored by git and can be regenerated from `npm run perf:render-lifecycle-audit`.",
    "",
    `Rows: ${resultCount}.`,
    "",
    "Key files:",
    "",
    "- lifecycle-audit.json",
    "- before-after-delta.json",
    "- before-after-delta.md",
    "- memory-trend.json",
    "- visual-parity.json",
    ""
  ].join("\n");
}

function auditCase(
  id: string,
  title: string,
  launchScenarioId: string,
  surface: RenderLifecycleSurface,
  posture: RenderLifecyclePosture,
  diagnostics: Partial<BattleLoopDiagnostics>,
  stimulus: RenderLifecycleAuditCase["stimulus"],
  expectedSignal: string
): RenderLifecycleAuditCase {
  return {
    id,
    title,
    launchScenarioId,
    surface,
    posture,
    diagnostics: normalizeBattleLoopDiagnostics(diagnostics),
    stimulus,
    expectedSignal
  };
}

function sortAuditResults(results: RenderLifecycleAuditResult[]): RenderLifecycleAuditResult[] {
  const order = new Map(V0114_RENDER_LIFECYCLE_AUDIT_CASES.map((entry, index) => [entry.id, index]));
  return [...results].sort((left, right) => (order.get(left.caseId) ?? 999) - (order.get(right.caseId) ?? 999));
}
