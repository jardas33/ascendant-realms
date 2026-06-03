import type { PrivatePerformanceCounters, PrivatePerformanceLongTask } from "./PrivatePerformanceProfiler";
import type { TrustedFrameInterval, TrustedSteadyStateMetrics } from "./TrustedBrowserBenchmark";

export const V0110_CHECKPOINT = "v0.110";
export const V0110_TITLE = "Battle-Loop Phase Profiler, Runtime Bottleneck Isolation, and Controlled Performance Rescue";
export const V0110_ARTIFACT_DIR = "artifacts/performance/v0110";

export type BattleLoopPhaseId =
  | "sceneUpdate"
  | "input"
  | "simulationClock"
  | "camera"
  | "abilities"
  | "movementPathing"
  | "combatProjectiles"
  | "statusEffects"
  | "economyProduction"
  | "lumeSimulation"
  | "lumePresentation"
  | "aiStrategy"
  | "eventsCleanup"
  | "fogSimulation"
  | "fogPresentation"
  | "hudDom"
  | "endConditions";

export type BattleLoopBinaryMode = "normal" | "paused";
export type BattleLoopEntityGraphicsMode = "normal" | "hidden";
export type BattleLoopLabelsMode = "normal" | "hidden";
export type BattleLoopCaptureRingsMode = "normal" | "minimal";
export type BattleLoopLumeMode = "hidden" | "auto" | "always";
export type BattleLoopMinimapMode = "normal" | "paused";
export type BattleLoopNotificationsMode = "normal" | "suppressed";
export type BattleLoopProfilerOverlayMode = "off" | "on";
export type BattleLoopPhaseProfilerMode = "off" | "on";

export interface BattleLoopDiagnostics {
  phaseProfiler: BattleLoopPhaseProfilerMode;
  simulation: BattleLoopBinaryMode;
  ai: BattleLoopBinaryMode;
  path: BattleLoopBinaryMode;
  movement: BattleLoopBinaryMode;
  combat: BattleLoopBinaryMode;
  projectiles: BattleLoopBinaryMode;
  fogSimulation: BattleLoopBinaryMode;
  fogPresentation: BattleLoopBinaryMode;
  entityGraphics: BattleLoopEntityGraphicsMode;
  labels: BattleLoopLabelsMode;
  captureRings: BattleLoopCaptureRingsMode;
  lume: BattleLoopLumeMode;
  minimap: BattleLoopMinimapMode;
  hudDomPatches: BattleLoopBinaryMode;
  notifications: BattleLoopNotificationsMode;
  camera: BattleLoopBinaryMode;
  profilerOverlay: BattleLoopProfilerOverlayMode;
}

export interface BattleLoopPhaseDefinition {
  id: BattleLoopPhaseId;
  label: string;
  description: string;
}

export interface BattleLoopCountSnapshot {
  displayObjects: number;
  graphicsObjects: number;
  units: number;
  buildings: number;
  captureSites: number;
  projectiles: number;
  labels: number;
  domNodes: number;
}

export interface BattleLoopPhaseMetric {
  phaseId: BattleLoopPhaseId;
  label: string;
  description: string;
  totalMs: number;
  averageMs: number;
  maxMs: number;
  count: number;
  percentOfMeasuredFrame: number;
  p50Ms: number;
  p95Ms: number;
}

export interface BattleLoopPhaseSummary {
  checkpoint: typeof V0110_CHECKPOINT;
  sampleCount: number;
  totalMeasuredMs: number;
  phases: BattleLoopPhaseMetric[];
  latestCounts: BattleLoopCountSnapshot;
}

export type BattleLoopScenarioCategory = "static" | "density" | "subsystem";

export interface BattleLoopScenarioDefinition {
  id: string;
  title: string;
  category: BattleLoopScenarioCategory;
  launchKind: "battle" | "lume_battle";
  launchScenarioId: string;
  purpose: string;
  expectedVisibleUi: string[];
  evidenceFocus: string[];
  diagnostics: Partial<BattleLoopDiagnostics>;
  saveIsolationRule: string;
  localOnly: boolean;
}

export interface BattleLoopBenchmarkResult {
  caseId: string;
  title: string;
  category: BattleLoopScenarioCategory;
  scenarioId: string;
  diagnostics: BattleLoopDiagnostics;
  viewport: string;
  warmupMs: number;
  sampleMs: number;
  generatedAtUtc: string;
  steadyState: TrustedSteadyStateMetrics;
  phaseSummary: BattleLoopPhaseSummary;
  rawFrameIntervalArtifact: string;
  rawPhaseSummaryArtifact: string;
}

export interface BattleLoopArtifactSet {
  schemaVersion: 1;
  checkpoint: typeof V0110_CHECKPOINT;
  title: typeof V0110_TITLE;
  generatedAtUtc: string;
  warmupMs: number;
  sampleMs: number;
  results: BattleLoopBenchmarkResult[];
}

export interface BattleLoopGateReport {
  schemaVersion: 1;
  checkpoint: typeof V0110_CHECKPOINT;
  status: "GREEN" | "AMBER" | "RED" | "PENDING";
  baselineCaseId?: string;
  fpsAverage?: number;
  p95Ms?: number;
  maxMs?: number;
  longTasks?: number;
  reason: string;
}

export const V0110_BATTLE_LOOP_PHASES: BattleLoopPhaseDefinition[] = [
  phase("sceneUpdate", "Scene/update total", "Whole BattleScene.update frame envelope while private phase profiling is on."),
  phase("input", "Input", "Input-facing state changes and minimap/status timers that precede simulation work."),
  phase("simulationClock", "Simulation clock", "Runtime clock, status timers, and battle-time counters."),
  phase("camera", "Camera", "Camera tracking and camera command processing."),
  phase("abilities", "Abilities", "Player and enemy ability update surfaces."),
  phase("movementPathing", "Movement/pathing", "MovementSystem path and unit-position update work."),
  phase("combatProjectiles", "Combat/projectiles", "CombatSystem, targeting, hit resolution, and projectile-facing work."),
  phase("statusEffects", "Status effects", "Timed buffs, debuffs, and veteran/status upkeep."),
  phase("economyProduction", "Economy/production", "Building, repair, resource, training, and upgrade updates."),
  phase("lumeSimulation", "Lume simulation", "Lume network state update using existing Linked Ward rules."),
  phase("lumePresentation", "Lume presentation", "Private Lume link and endpoint graphics rendering."),
  phase("aiStrategy", "AI/strategy", "Enemy pressure, Act 1 finale, battle event, and AI controller work."),
  phase("eventsCleanup", "Events/cleanup", "Dead entity cleanup, wave tracking, tutorial hint, and status bookkeeping."),
  phase("fogSimulation", "Fog simulation", "Fog-of-war visibility source evaluation and cell-state update."),
  phase("fogPresentation", "Fog presentation", "Fog overlay redraw and entity visibility application."),
  phase("hudDom", "HUD DOM", "Battle HUD, minimap snapshot, objective, and debug counter DOM patch work."),
  phase("endConditions", "End conditions", "Victory/defeat condition checks.")
];

export const V0110_DEFAULT_BATTLE_LOOP_DIAGNOSTICS: BattleLoopDiagnostics = {
  phaseProfiler: "off",
  simulation: "normal",
  ai: "normal",
  path: "normal",
  movement: "normal",
  combat: "normal",
  projectiles: "normal",
  fogSimulation: "normal",
  fogPresentation: "normal",
  entityGraphics: "normal",
  labels: "normal",
  captureRings: "normal",
  lume: "auto",
  minimap: "normal",
  hudDomPatches: "normal",
  notifications: "normal",
  camera: "normal",
  profilerOverlay: "off"
};

const NO_SAVE_RULE =
  "Private v0.110 Performance Lab only. No save, reward, XP, progression, Retinue, relic, reputation, stable-ID, localStorage, art, engine, or balance mutation is kept.";

export const V0110_BATTLE_LOOP_SCENARIOS: BattleLoopScenarioDefinition[] = [
  scenario("v0110_empty_static", "Empty/static battle shell", "static", "battle", "salto_outskirts_start", "Static private baseline with only the existing safe launch posture.", ["battle-hud", "battle-minimap"], ["scene/update", "HUD DOM"], { phaseProfiler: "on", simulation: "paused", ai: "paused", movement: "paused", combat: "paused", fogSimulation: "paused" }),
  scenario("v0110_static_hud_minimal", "Static HUD minimal", "static", "battle", "perf_hud_minimal", "Static HUD DOM pressure sample with the public-compatible minimal HUD posture.", ["battle-hud-density-minimal", "battle-minimap"], ["HUD DOM", "minimap"], { phaseProfiler: "on", simulation: "paused", ai: "paused", movement: "paused", combat: "paused" }),
  scenario("v0110_tier_s_density", "Tier S density", "density", "battle", "benchmark_battle_tier_s_smoke", "Small representative density sample.", ["battle-hud", "lume-network-status"], ["density", "movement/pathing"], { phaseProfiler: "on" }),
  scenario("v0110_tier_m_density", "Tier M density", "density", "battle", "benchmark_battle_tier_m_representative", "Default representative density sample.", ["battle-hud", "unit-order-summary"], ["density", "AI", "HUD DOM"], { phaseProfiler: "on" }),
  scenario("v0110_tier_l_density", "Tier L density", "density", "battle", "benchmark_battle_tier_l_stress", "Private/local-only high-density stress sample.", ["battle-hud", "unit-order-summary"], ["density scaling", "long tasks"], { phaseProfiler: "on" }, true),
  scenario("v0110_simulation_paused", "Simulation paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation with simulation work paused after a normal launch.", ["battle-hud", "trusted-diagnostic-toggles"], ["simulation ceiling"], { phaseProfiler: "on", simulation: "paused" }),
  scenario("v0110_ai_paused", "AI paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for AI and pressure update cost.", ["battle-hud", "trusted-diagnostic-toggles"], ["AI/strategy"], { phaseProfiler: "on", ai: "paused" }),
  scenario("v0110_path_paused", "Path paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for movement/path request cost.", ["battle-hud", "trusted-diagnostic-toggles"], ["movement/pathing"], { phaseProfiler: "on", path: "paused" }),
  scenario("v0110_movement_paused", "Movement paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for unit movement update cost.", ["battle-hud", "trusted-diagnostic-toggles"], ["movement"], { phaseProfiler: "on", movement: "paused" }),
  scenario("v0110_combat_paused", "Combat paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for combat resolution cost.", ["battle-hud", "trusted-diagnostic-toggles"], ["combat"], { phaseProfiler: "on", combat: "paused" }),
  scenario("v0110_projectiles_paused", "Projectiles paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for projectile-facing combat work.", ["battle-hud", "trusted-diagnostic-toggles"], ["projectiles"], { phaseProfiler: "on", projectiles: "paused" }),
  scenario("v0110_fog_simulation_paused", "Fog simulation paused", "subsystem", "battle", "benchmark_battle_fog_heavy", "Binary isolation for fog cell update work.", ["battle-minimap", "battle-objectives"], ["fog simulation"], { phaseProfiler: "on", fogSimulation: "paused" }),
  scenario("v0110_fog_presentation_paused", "Fog presentation paused", "subsystem", "battle", "benchmark_battle_fog_heavy", "Binary isolation for fog overlay redraw and entity visibility presentation.", ["battle-minimap", "battle-objectives"], ["fog presentation"], { phaseProfiler: "on", fogPresentation: "paused" }),
  scenario("v0110_entity_graphics_hidden", "Entity graphics hidden", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for entity display-object presentation.", ["battle-hud", "trusted-diagnostic-toggles"], ["entity graphics"], { phaseProfiler: "on", entityGraphics: "hidden" }),
  scenario("v0110_labels_hidden", "Labels hidden", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for text labels.", ["battle-hud", "trusted-diagnostic-toggles"], ["labels"], { phaseProfiler: "on", labels: "hidden" }),
  scenario("v0110_capture_rings_minimal", "Capture rings minimal", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for capture ring graphics.", ["battle-hud", "trusted-diagnostic-toggles"], ["capture rings"], { phaseProfiler: "on", captureRings: "minimal" }),
  scenario("v0110_lume_hidden", "Lume hidden", "subsystem", "lume_battle", "benchmark_battle_tier_m_representative", "Binary isolation for Lume presentation cost.", ["lume-network-status", "trusted-diagnostic-toggles"], ["Lume presentation"], { phaseProfiler: "on", lume: "hidden" }),
  scenario("v0110_minimap_paused", "Minimap paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for minimap snapshot/DOM refresh cost.", ["battle-minimap", "trusted-diagnostic-toggles"], ["minimap"], { phaseProfiler: "on", minimap: "paused" }),
  scenario("v0110_hud_dom_paused", "HUD DOM paused", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Binary isolation for HUD DOM patch cost.", ["battle-hud", "trusted-diagnostic-toggles"], ["HUD DOM"], { phaseProfiler: "on", hudDomPatches: "paused" }),
  scenario("v0110_notifications_suppressed", "Notifications suppressed", "subsystem", "battle", "benchmark_battle_notification_heavy", "Binary isolation for status/floating notification cost.", ["battle-status", "trusted-diagnostic-toggles"], ["notifications"], { phaseProfiler: "on", notifications: "suppressed" }),
  scenario("v0110_camera_paused", "Camera paused", "subsystem", "battle", "benchmark_battle_minimap_interaction", "Binary isolation for camera update cost.", ["battle-minimap", "trusted-diagnostic-toggles"], ["camera"], { phaseProfiler: "on", camera: "paused" }),
  scenario("v0110_profiler_overlay_on", "Profiler overlay on", "subsystem", "battle", "benchmark_battle_tier_m_representative", "Measures the old profiler overlay as a known distortion case.", ["private-performance-panel", "trusted-diagnostic-toggles"], ["profiler overlay"], { phaseProfiler: "on", profilerOverlay: "on" })
];

export class BattleLoopPhaseProfiler {
  private enabled = false;
  private readonly durations = new Map<BattleLoopPhaseId, number[]>();
  private frameStartedAt = 0;
  private sampleCount = 0;
  private latestCounts: BattleLoopCountSnapshot = emptyCounts();

  setEnabled(enabled: boolean): void {
    this.enabled = enabled;
  }

  isEnabled(): boolean {
    return this.enabled;
  }

  reset(): BattleLoopPhaseSummary {
    this.durations.clear();
    this.frameStartedAt = 0;
    this.sampleCount = 0;
    this.latestCounts = emptyCounts();
    return this.summary();
  }

  beginFrame(counts: BattleLoopCountSnapshot): void {
    if (!this.enabled) {
      return;
    }
    this.frameStartedAt = now();
    this.latestCounts = { ...counts };
  }

  measure<T>(phaseId: BattleLoopPhaseId, work: () => T): T {
    if (!this.enabled) {
      return work();
    }
    const startedAt = now();
    try {
      return work();
    } finally {
      this.record(phaseId, now() - startedAt);
    }
  }

  record(phaseId: BattleLoopPhaseId, durationMs: number): void {
    if (!this.enabled || !Number.isFinite(durationMs) || durationMs < 0) {
      return;
    }
    const values = this.durations.get(phaseId) ?? [];
    values.push(roundMetric(durationMs));
    if (values.length > 6000) {
      values.shift();
    }
    this.durations.set(phaseId, values);
  }

  endFrame(): void {
    if (!this.enabled || this.frameStartedAt <= 0) {
      return;
    }
    this.record("sceneUpdate", now() - this.frameStartedAt);
    this.sampleCount += 1;
    this.frameStartedAt = 0;
  }

  summary(): BattleLoopPhaseSummary {
    const sceneTotal = sum(this.durations.get("sceneUpdate") ?? []);
    const totalMeasuredMs = sceneTotal > 0 ? sceneTotal : sum([...this.durations.values()].flat());
    return {
      checkpoint: V0110_CHECKPOINT,
      sampleCount: this.sampleCount,
      totalMeasuredMs: roundMetric(totalMeasuredMs),
      phases: V0110_BATTLE_LOOP_PHASES.map((definition) => phaseMetric(definition, this.durations.get(definition.id) ?? [], totalMeasuredMs)),
      latestCounts: { ...this.latestCounts }
    };
  }
}

export function createDefaultBattleLoopDiagnostics(): BattleLoopDiagnostics {
  return { ...V0110_DEFAULT_BATTLE_LOOP_DIAGNOSTICS };
}

export function normalizeBattleLoopDiagnostics(diagnostics: Partial<BattleLoopDiagnostics> = {}): BattleLoopDiagnostics {
  const merged = { ...V0110_DEFAULT_BATTLE_LOOP_DIAGNOSTICS, ...diagnostics };
  return {
    phaseProfiler: valueIn(merged.phaseProfiler, ["off", "on"], "off"),
    simulation: valueIn(merged.simulation, ["normal", "paused"], "normal"),
    ai: valueIn(merged.ai, ["normal", "paused"], "normal"),
    path: valueIn(merged.path, ["normal", "paused"], "normal"),
    movement: valueIn(merged.movement, ["normal", "paused"], "normal"),
    combat: valueIn(merged.combat, ["normal", "paused"], "normal"),
    projectiles: valueIn(merged.projectiles, ["normal", "paused"], "normal"),
    fogSimulation: valueIn(merged.fogSimulation, ["normal", "paused"], "normal"),
    fogPresentation: valueIn(merged.fogPresentation, ["normal", "paused"], "normal"),
    entityGraphics: valueIn(merged.entityGraphics, ["normal", "hidden"], "normal"),
    labels: valueIn(merged.labels, ["normal", "hidden"], "normal"),
    captureRings: valueIn(merged.captureRings, ["normal", "minimal"], "normal"),
    lume: valueIn(merged.lume, ["hidden", "auto", "always"], "auto"),
    minimap: valueIn(merged.minimap, ["normal", "paused"], "normal"),
    hudDomPatches: valueIn(merged.hudDomPatches, ["normal", "paused"], "normal"),
    notifications: valueIn(merged.notifications, ["normal", "suppressed"], "normal"),
    camera: valueIn(merged.camera, ["normal", "paused"], "normal"),
    profilerOverlay: valueIn(merged.profilerOverlay, ["off", "on"], "off")
  };
}

export function battleLoopDiagnosticsForScenario(scenarioId: string | undefined): BattleLoopDiagnostics | undefined {
  const scenarioDefinition = V0110_BATTLE_LOOP_SCENARIOS.find((entry) => entry.id === scenarioId);
  return scenarioDefinition ? normalizeBattleLoopDiagnostics(scenarioDefinition.diagnostics) : undefined;
}

export function buildBattleLoopArtifactSet(results: BattleLoopBenchmarkResult[], options: { generatedAtUtc?: string; warmupMs?: number; sampleMs?: number } = {}): BattleLoopArtifactSet {
  return {
    schemaVersion: 1,
    checkpoint: V0110_CHECKPOINT,
    title: V0110_TITLE,
    generatedAtUtc: options.generatedAtUtc ?? new Date().toISOString(),
    warmupMs: options.warmupMs ?? results[0]?.warmupMs ?? 5000,
    sampleMs: options.sampleMs ?? results[0]?.sampleMs ?? 10000,
    results: sortResults(results)
  };
}

export function createTrustedBrowserGateReport(results: BattleLoopBenchmarkResult[]): BattleLoopGateReport {
  const baseline =
    results.find((entry) => entry.caseId === "v0110_tier_m_density") ??
    results.find((entry) => entry.caseId === "v0110_phase_baseline") ??
    results.find((entry) => entry.category === "density") ??
    results[0];
  if (!baseline) {
    return {
      schemaVersion: 1,
      checkpoint: V0110_CHECKPOINT,
      status: "PENDING",
      reason: "No v0.110 trusted browser result is available yet."
    };
  }
  const fps = baseline.steadyState.fpsAverage;
  const p95 = baseline.steadyState.frameTimeMs.p95;
  const max = baseline.steadyState.frameTimeMs.max;
  const longTasks = baseline.steadyState.longTasks.count;
  const status = fps >= 30 && p95 <= 50 && longTasks <= 1 ? "GREEN" : fps >= 18 && p95 <= 120 && max <= 500 ? "AMBER" : "RED";
  return {
    schemaVersion: 1,
    checkpoint: V0110_CHECKPOINT,
    status,
    baselineCaseId: baseline.caseId,
    fpsAverage: fps,
    p95Ms: p95,
    maxMs: max,
    longTasks,
    reason:
      status === "GREEN"
        ? "Tier M representative battle meets the private v0.110 trusted browser gate."
        : status === "AMBER"
          ? "Tier M representative battle is playable enough for evidence review but remains below green performance confidence."
          : "Tier M representative battle remains below the trusted browser gate; defer broad rescue/engine work to a separately approved goal."
  };
}

export function renderPhaseProfilerSummaryMarkdown(results: BattleLoopBenchmarkResult[]): string {
  const sorted = sortResults(results);
  const lines = [
    "# v0.110 Phase Profiler Summary",
    "",
    "Private/session-only phase profiler evidence. The profiler is off by default and does not change public gameplay, saves, rewards, stable IDs, art, or engine posture.",
    "",
    "## Case Summary",
    "",
    "| Case | FPS avg | p95 frame | Top phase | Top phase avg | Units | Objects | DOM |",
    "| --- | ---: | ---: | --- | ---: | ---: | ---: | ---: |",
    ...sorted.map((result) => {
      const top = topPhase(result.phaseSummary);
      return `| ${result.caseId} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} | ${top.label} | ${top.averageMs} | ${result.phaseSummary.latestCounts.units} | ${result.phaseSummary.latestCounts.displayObjects} | ${result.phaseSummary.latestCounts.domNodes} |`;
    }),
    "",
    "## Phase Totals",
    "",
    ...sorted.map((result) => renderPhaseBullets(result)),
    ""
  ];
  return `${lines.join("\n")}\n`;
}

export function renderSubsystemIsolationMatrixMarkdown(results: BattleLoopBenchmarkResult[]): string {
  const rows = sortResults(results).filter((entry) => entry.category === "subsystem");
  const baseline = sortResults(results).find((entry) => entry.caseId === "v0110_tier_m_density") ?? sortResults(results)[0];
  return [
    "# v0.110 Subsystem Isolation Matrix",
    "",
    "Every row is private/session-only. Paused/hidden modes are diagnostic switches, not gameplay rules or public options.",
    "",
    "| Case | Focus | FPS avg | p95 frame | p95 delta | Top phase | Phase avg | Note |",
    "| --- | --- | ---: | ---: | ---: | --- | ---: | --- |",
    ...rows.map((result) => {
      const definition = V0110_BATTLE_LOOP_SCENARIOS.find((entry) => entry.id === result.caseId);
      const top = topPhase(result.phaseSummary);
      const delta = baseline ? roundMetric(result.steadyState.frameTimeMs.p95 - baseline.steadyState.frameTimeMs.p95) : 0;
      return `| ${result.caseId} | ${(definition?.evidenceFocus ?? []).join(", ")} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} | ${delta} | ${top.label} | ${top.averageMs} | ${isolationNote(result, baseline)} |`;
    }),
    ""
  ].join("\n");
}

export function renderDensityScalingReportMarkdown(results: BattleLoopBenchmarkResult[]): string {
  const rows = sortResults(results).filter((entry) => entry.category === "density" || entry.category === "static");
  return [
    "# v0.110 Density Scaling Report",
    "",
    "Density rows reuse existing private Playtest Hub/representative battle fixtures. No new units, maps, factions, balance values, stable IDs, saves, or art are added.",
    "",
    "| Case | Category | FPS avg | p95 frame | Units | Buildings | Display objects | Labels | DOM | Top phase |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |",
    ...rows.map((result) => {
      const counts = result.phaseSummary.latestCounts;
      return `| ${result.caseId} | ${result.category} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} | ${counts.units} | ${counts.buildings} | ${counts.displayObjects} | ${counts.labels} | ${counts.domNodes} | ${topPhase(result.phaseSummary).label} |`;
    }),
    ""
  ].join("\n");
}

export function renderTrustedBrowserGateMarkdown(report: BattleLoopGateReport): string {
  return [
    "# v0.110 Browser Performance Gate",
    "",
    `Status: ${report.status}.`,
    "",
    report.baselineCaseId ? `Baseline case: ${report.baselineCaseId}.` : "Baseline case: pending.",
    report.fpsAverage === undefined ? "FPS average: pending." : `FPS average: ${report.fpsAverage}.`,
    report.p95Ms === undefined ? "p95 frame: pending." : `p95 frame: ${report.p95Ms} ms.`,
    report.maxMs === undefined ? "Max frame: pending." : `Max frame: ${report.maxMs} ms.`,
    report.longTasks === undefined ? "Long tasks: pending." : `Long tasks: ${report.longTasks}.`,
    "",
    "## Gate Rule",
    "",
    "- GREEN: Tier M FPS average at least 30, p95 at or below 50 ms, and no more than one long task.",
    "- AMBER: Tier M FPS average at least 18, p95 at or below 120 ms, and max frame at or below 500 ms.",
    "- RED: Anything below AMBER remains a performance rescue blocker for future work.",
    "",
    "## Reason",
    "",
    report.reason,
    ""
  ].join("\n");
}

export function renderBeforeAfterDeltaMarkdown(results: BattleLoopBenchmarkResult[]): string {
  const gate = createTrustedBrowserGateReport(results);
  const baseline = results.find((entry) => entry.caseId === gate.baselineCaseId);
  return [
    "# v0.110 Before/After Delta",
    "",
    "v0.110 adds private phase measurement and subsystem isolation before attempting broad optimization. It intentionally avoids save, combat, AI balance, map, faction, art, desktop, network, or public UI changes.",
    "",
    "## Controlled Optimization",
    "",
    "- Phase profiling is off by default and does no per-phase timing work unless private diagnostics explicitly enable it.",
    "- Existing v0.109 diagnostic reductions remain private/session-only and are extended with binary battle-loop isolation switches.",
    "- No broad render rewrite or engine/desktop rescue was started.",
    "",
    "## Latest Gate",
    "",
    `- Status: ${gate.status}.`,
    `- Baseline: ${gate.baselineCaseId ?? "pending"}.`,
    `- Tier M p95: ${baseline?.steadyState.frameTimeMs.p95 ?? "pending"} ms.`,
    `- Tier M top phase: ${baseline ? topPhase(baseline.phaseSummary).label : "pending"}.`,
    "",
    "## Deferred",
    "",
    "- Any architecture-level renderer rescue, engine spike, art replacement, or v0.111 work requires a separately approved goal.",
    ""
  ].join("\n");
}

export function renderProfilerCapabilityReport(results: BattleLoopBenchmarkResult[]) {
  return {
    schemaVersion: 1,
    checkpoint: V0110_CHECKPOINT,
    title: V0110_TITLE,
    phaseProfilerPrivateOnly: true,
    profilerOffByDefault: true,
    scenarioCount: V0110_BATTLE_LOOP_SCENARIOS.length,
    resultCount: results.length,
    phaseCount: V0110_BATTLE_LOOP_PHASES.length,
    rawFrameIntervalsRetained: true,
    rawPhaseSamplesRetained: true,
    rawPhaseSummariesRetained: true,
    binaryIsolationSwitches: [
      "simulation",
      "ai",
      "path",
      "movement",
      "combat",
      "projectiles",
      "fogSimulation",
      "fogPresentation",
      "entityGraphics",
      "labels",
      "captureRings",
      "lume",
      "minimap",
      "hudDomPatches",
      "notifications",
      "camera",
      "profilerOverlay"
    ],
    boundary:
      "No save version, save data, stable IDs, maps, factions, races, units, buildings, combat values, campaign progression, art assets, desktop engine, network, multiplayer, PvP, or co-op change."
  };
}

export function renderBattleLoopPhaseProfilerSpecMarkdown(): string {
  return [
    "# v0.110 Battle-Loop Phase Profiler Spec",
    "",
    "The phase profiler is private Playtest Hub instrumentation. It records BattleScene.update phase timings only when v0.110 diagnostics enable `phaseProfiler=on`; the default runtime mode is off.",
    "",
    "## Phases",
    "",
    ...V0110_BATTLE_LOOP_PHASES.map((entry) => `- ${entry.label}: ${entry.description}`),
    "",
    "## Boundary",
    "",
    "- Session-only diagnostics, no persistence.",
    "- Public battle behavior and save format remain unchanged.",
    "- Results include total, average, max, count, percent, p50, p95, and entity/count snapshots.",
    ""
  ].join("\n");
}

export function renderBattleLoopIsolationSpecMarkdown(): string {
  return [
    "# v0.110 Subsystem Isolation Matrix Spec",
    "",
    `The v0.110 Performance Lab ladder contains ${V0110_BATTLE_LOOP_SCENARIOS.length} private scenarios covering static, density, and subsystem rows.`,
    "",
    "## Scenarios",
    "",
    "| Scenario | Category | Focus | Local only |",
    "| --- | --- | --- | --- |",
    ...V0110_BATTLE_LOOP_SCENARIOS.map((entry) => `| ${entry.id} | ${entry.category} | ${entry.evidenceFocus.join(", ")} | ${entry.localOnly ? "yes" : "no"} |`),
    "",
    "## Rules",
    "",
    "- Every pause/hidden mode is private, session-only, and diagnostic.",
    "- Paused modes isolate cost ceilings; they are not design decisions or balance changes.",
    "- `linked_ward` remains unchanged at its existing 0.92 damage-taken multiplier.",
    ""
  ].join("\n");
}

export function renderRootCauseClassificationMarkdown(results: BattleLoopBenchmarkResult[]): string {
  const slowest = [...sortResults(results)].sort((left, right) => right.steadyState.frameTimeMs.p95 - left.steadyState.frameTimeMs.p95).slice(0, 5);
  return [
    "# v0.110 Root Cause Classification",
    "",
    "Classification is evidence-backed only for rows present in the latest artifact set. Missing rows remain unresolved rather than guessed.",
    "",
    "## Slowest Rows",
    "",
    ...slowest.map((result, index) => `${index + 1}. ${result.caseId}: p95 ${result.steadyState.frameTimeMs.p95} ms, top phase ${topPhase(result.phaseSummary).label}.`),
    "",
    "## Current Finding",
    "",
    slowest.length > 0
      ? "Use subsystem deltas and phase summaries to target a later approved optimization goal. v0.110 does not start a broad renderer or engine rewrite."
      : "No trusted v0.110 rows are available yet.",
    ""
  ].join("\n");
}

export function renderControlledOptimizationReportMarkdown(results: BattleLoopBenchmarkResult[]): string {
  return [
    "# v0.110 Controlled Optimization Report",
    "",
    "v0.110 applies only instrumentation-safe rescue work: the phase profiler is disabled by default, existing private diagnostics remain session-only, and subsystem switches are isolated from public play.",
    "",
    "## Applied",
    "",
    "- Added no-op-by-default phase timing around existing BattleScene phases.",
    "- Added private binary isolation switches without persistence.",
    "- Added trusted artifact and gate generation under `artifacts/performance/v0110/`.",
    "",
    "## Not Applied",
    "",
    "- No combat, AI, pathing, economy, Lume balance, save, map, stable-ID, art, desktop, network, or public UI rewrite.",
    "- No v0.111 work.",
    "",
    "## Result Count",
    "",
    `${results.length} trusted row(s) are present in the latest v0.110 artifact set.`,
    ""
  ].join("\n");
}

export function renderVisualQaReportMarkdown(): string {
  return [
    "# v0.110 Visual QA Report",
    "",
    "Visual QA adds a small private phase-profiler review slice: the Performance Lab ladder, a Tier M phase panel, and one isolated HUD/DOM pause state.",
    "",
    "Required states remain private-only and do not expose public benchmark controls.",
    ""
  ].join("\n");
}

export function renderImplementationReportMarkdown(results: BattleLoopBenchmarkResult[]): string {
  return [
    "# v0.110 Implementation Report",
    "",
    "Status: implemented as private battle-loop phase profiling, subsystem isolation, and trusted performance gate evidence.",
    "",
    "## Implemented",
    "",
    "- Private BattleScene phase profiler with per-phase total, average, max, count, percent, p50, and p95.",
    "- Session-only Performance Lab diagnostics for simulation, AI, path, movement, combat, projectiles, fog simulation/presentation, entity graphics, labels, capture rings, Lume, minimap, HUD DOM patches, notifications, camera, and profiler overlay.",
    "- 22-row v0.110 Performance Lab ladder.",
    "- v0.110 scripts and artifact writers for phase profile, subsystem matrix, density ladder, browser gate, and report refresh.",
    "",
    "## Boundary",
    "",
    "No save-version bump, save data, stable IDs, gameplay balance, campaign progression, maps, factions, races, units, buildings, Living Mines, art assets, desktop engine, runtime title, multiplayer, PvP, co-op, public UI redesign, or v0.111 work is included.",
    "",
    "## Current Result Count",
    "",
    `${results.length} trusted v0.110 row(s) are available.`,
    ""
  ].join("\n");
}

export function renderEmmanuelRetestMarkdown(): string {
  return [
    "# v0.110 Emmanuel Phase Profile Retest",
    "",
    "1. Open the private playtest package through the included local server.",
    "2. Enter Playtest Hub and scroll to Performance Lab.",
    "3. Confirm the v0.110 phase-profiler cards are private and no-save.",
    "4. Launch Tier M density and expand Trusted Diagnostics.",
    "5. Confirm Phase Profiler can be toggled on/off and that subsystem switches are labeled diagnostic/private.",
    "6. Confirm ordinary campaign, Tutorial, and normal battle routes remain unchanged.",
    "7. Confirm no v0.111, desktop engine, art generation/import, save migration, or public UI redesign has started.",
    ""
  ].join("\n");
}

export function renderDeferredArchitectureFindingsMarkdown(results: BattleLoopBenchmarkResult[]): string {
  const gate = createTrustedBrowserGateReport(results);
  return [
    "# v0.110 Deferred Architecture Findings",
    "",
    "v0.110 does not start architecture rescue work. It creates evidence so a future approved goal can decide whether renderer batching, DOM/HUD reduction, pathing partitioning, or engine/desktop work is justified.",
    "",
    `Current gate status: ${gate.status}.`,
    "",
    "Deferred until a separate goal:",
    "",
    "- Renderer batching or entity presentation rewrite.",
    "- Desktop engine or wrapper spike.",
    "- Runtime art import/generation.",
    "- Stable-ID, save, campaign, unit, building, faction, or map changes.",
    ""
  ].join("\n");
}

export function frameIntervalsFromNumbers(values: number[]): TrustedFrameInterval[] {
  let atMs = 0;
  return values.map((frameMs, index) => {
    atMs += frameMs;
    return { index, atMs: roundMetric(atMs), frameMs };
  });
}

function phase(id: BattleLoopPhaseId, label: string, description: string): BattleLoopPhaseDefinition {
  return { id, label, description };
}

function scenario(
  id: string,
  title: string,
  category: BattleLoopScenarioCategory,
  launchKind: "battle" | "lume_battle",
  launchScenarioId: string,
  purpose: string,
  expectedVisibleUi: string[],
  evidenceFocus: string[],
  diagnostics: Partial<BattleLoopDiagnostics>,
  localOnly = false
): BattleLoopScenarioDefinition {
  return {
    id,
    title,
    category,
    launchKind,
    launchScenarioId,
    purpose,
    expectedVisibleUi,
    evidenceFocus,
    diagnostics,
    saveIsolationRule: NO_SAVE_RULE,
    localOnly
  };
}

function phaseMetric(definition: BattleLoopPhaseDefinition, values: number[], frameTotalMs: number): BattleLoopPhaseMetric {
  const sorted = [...values].sort((left, right) => left - right);
  const total = sum(values);
  return {
    phaseId: definition.id,
    label: definition.label,
    description: definition.description,
    totalMs: roundMetric(total),
    averageMs: roundMetric(values.length > 0 ? total / values.length : 0),
    maxMs: roundMetric(sorted.at(-1) ?? 0),
    count: values.length,
    percentOfMeasuredFrame: roundMetric(frameTotalMs > 0 ? (total / frameTotalMs) * 100 : 0),
    p50Ms: roundMetric(percentile(sorted, 0.5)),
    p95Ms: roundMetric(percentile(sorted, 0.95))
  };
}

function topPhase(summary: BattleLoopPhaseSummary): BattleLoopPhaseMetric {
  return (
    summary.phases
      .filter((entry) => entry.phaseId !== "sceneUpdate")
      .sort((left, right) => right.totalMs - left.totalMs)[0] ?? summary.phases[0] ?? phaseMetric(V0110_BATTLE_LOOP_PHASES[0], [], 0)
  );
}

function renderPhaseBullets(result: BattleLoopBenchmarkResult): string {
  const top = result.phaseSummary.phases
    .filter((entry) => entry.phaseId !== "sceneUpdate")
    .sort((left, right) => right.totalMs - left.totalMs)
    .slice(0, 4);
  return [
    `### ${result.caseId}`,
    "",
    ...top.map((entry) => `- ${entry.label}: total ${entry.totalMs} ms, avg ${entry.averageMs} ms, p95 ${entry.p95Ms} ms, ${entry.percentOfMeasuredFrame}% of measured frame.`),
    ""
  ].join("\n");
}

function isolationNote(result: BattleLoopBenchmarkResult, baseline?: BattleLoopBenchmarkResult): string {
  if (!baseline || result.caseId === baseline.caseId) {
    return "baseline";
  }
  const delta = result.steadyState.frameTimeMs.p95 - baseline.steadyState.frameTimeMs.p95;
  if (delta <= -20) {
    return "lower p95 than Tier M baseline";
  }
  if (delta >= 20) {
    return "higher p95 than Tier M baseline";
  }
  return "similar p95 to Tier M baseline";
}

function sortResults(results: BattleLoopBenchmarkResult[]): BattleLoopBenchmarkResult[] {
  const order = new Map(V0110_BATTLE_LOOP_SCENARIOS.map((entry, index) => [entry.id, index]));
  return [...results].sort((left, right) => (order.get(left.caseId) ?? 999) - (order.get(right.caseId) ?? 999));
}

function emptyCounts(): BattleLoopCountSnapshot {
  return {
    displayObjects: 0,
    graphicsObjects: 0,
    units: 0,
    buildings: 0,
    captureSites: 0,
    projectiles: 0,
    labels: 0,
    domNodes: 0
  };
}

function valueIn<T extends string>(value: unknown, allowed: readonly T[], fallback: T): T {
  return typeof value === "string" && allowed.includes(value as T) ? (value as T) : fallback;
}

function now(): number {
  return typeof performance === "undefined" ? Date.now() : performance.now();
}

function percentile(sortedValues: number[], percentileValue: number): number {
  if (sortedValues.length === 0) {
    return 0;
  }
  const index = Math.min(sortedValues.length - 1, Math.max(0, Math.ceil(sortedValues.length * percentileValue) - 1));
  return sortedValues[index];
}

function sum(values: number[]): number {
  return values.reduce((total, value) => total + value, 0);
}

function roundMetric(value: number): number {
  return Number((Number.isFinite(value) ? value : 0).toFixed(2));
}
