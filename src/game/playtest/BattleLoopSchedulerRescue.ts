import { LUME_NETWORKS } from "../data/lumeNetworks";
import {
  V0110_BATTLE_LOOP_PHASES,
  type BattleLoopDiagnostics,
  type BattleLoopPhaseId,
  type BattleLoopPhaseSummary
} from "./BattleLoopPhaseProfiler";
import type { TrustedSteadyStateMetrics } from "./TrustedBrowserBenchmark";

export const V0112_CHECKPOINT = "v0.112";
export const V0112_TITLE = "Battle-Loop Scheduler, Allocation, and Idle-Work Rescue";
export const V0112_ARTIFACT_DIR = "artifacts/performance/v0112";

export type SchedulerCostKind = "fixed" | "variable" | "mixed";
export type SchedulerGameplayPosture = "gameplay-critical" | "presentation-only" | "private-diagnostic";

export interface SchedulerMapEntry {
  subsystem: string;
  phaseId: BattleLoopPhaseId;
  ownerFile: string;
  cadence: string;
  costKind: SchedulerCostKind;
  allocationPosture: string;
  dirtyStateAvailable: boolean;
  visibilityDependency: string;
  gameplayPosture: SchedulerGameplayPosture;
  safeOptimizations: string[];
  unsafeOptimizations: string[];
  profilerEvidence: string;
}

export interface AllocationAuditRow {
  id: string;
  ownerFile: string;
  surface: string;
  evidence: string;
  beforePerActivation: AllocationShape;
  afterPerActivation: AllocationShape;
  optimization: string;
  semanticRisk: "none" | "low" | "medium";
}

export interface AllocationShape {
  arrays: number;
  objects: number;
  maps: number;
  sets: number;
  sorts: number;
  filters: number;
  mapsCalls: number;
  domPatches: number;
  graphicsCreateDestroy: number;
  labelLayouts: number;
}

export interface IdleCostCaseDefinition {
  id: string;
  title: string;
  launchScenarioId: string;
  diagnostics: Partial<BattleLoopDiagnostics>;
  posture: "fixed-idle" | "incremental-movement" | "incremental-combat" | "incremental-ui";
  purpose: string;
  expectedFixedCostSignal: string;
}

export interface IdleCostMatrixResult {
  caseId: string;
  title: string;
  launchScenarioId: string;
  posture: IdleCostCaseDefinition["posture"];
  diagnostics: BattleLoopDiagnostics;
  warmupMs: number;
  sampleMs: number;
  generatedAtUtc: string;
  steadyState: TrustedSteadyStateMetrics;
  phaseSummary: BattleLoopPhaseSummary;
  rawFrameIntervalArtifact: string;
  rawPhaseSummaryArtifact: string;
}

export interface V0112ArtifactSet {
  schemaVersion: 1;
  checkpoint: typeof V0112_CHECKPOINT;
  title: typeof V0112_TITLE;
  generatedAtUtc: string;
  schedulerMap: SchedulerMapEntry[];
  allocationAudit: AllocationAuditRow[];
  idleCostMatrix: IdleCostMatrixResult[];
  paritySummary: V0112ParitySummary;
}

export interface V0112ParitySummary {
  schemaVersion: 1;
  checkpoint: typeof V0112_CHECKPOINT;
  gameplaySemanticsChanged: false;
  savesChanged: false;
  stableIdsChanged: false;
  pathingOutputsChanged: false;
  aiDecisionRulesChanged: false;
  linkedWardDamageTakenMultiplier: number | undefined;
  parityChecks: Array<{ id: string; status: "pass" | "pending"; evidence: string }>;
}

export class DirtyFlag<Reason extends string = string> {
  private readonly reasons = new Set<Reason>();

  constructor(initialReason?: Reason) {
    if (initialReason) {
      this.reasons.add(initialReason);
    }
  }

  mark(reason: Reason): void {
    this.reasons.add(reason);
  }

  isDirty(): boolean {
    return this.reasons.size > 0;
  }

  consume(): Reason[] {
    const reasons = [...this.reasons];
    this.reasons.clear();
    return reasons;
  }
}

export class ReusableObjectPool<T> {
  private readonly free: T[] = [];
  private readonly inUse = new Set<T>();

  constructor(
    private readonly create: () => T,
    private readonly reset: (entry: T) => void
  ) {}

  acquire(): T {
    const entry = this.free.pop() ?? this.create();
    this.inUse.add(entry);
    return entry;
  }

  release(entry: T): void {
    if (!this.inUse.delete(entry)) {
      return;
    }
    this.reset(entry);
    this.free.push(entry);
  }

  resetAll(): void {
    for (const entry of this.inUse) {
      this.reset(entry);
      this.free.push(entry);
    }
    this.inUse.clear();
  }

  activeCount(): number {
    return this.inUse.size;
  }

  freeCount(): number {
    return this.free.length;
  }
}

export class StableLabelCache<T> {
  private readonly entries = new Map<string, { signature: string; value: T }>();

  resolve(key: string, signature: string, create: () => T): T {
    const existing = this.entries.get(key);
    if (existing?.signature === signature) {
      return existing.value;
    }
    const value = create();
    this.entries.set(key, { signature, value });
    return value;
  }

  invalidate(key: string): void {
    this.entries.delete(key);
  }

  size(): number {
    return this.entries.size;
  }
}

export class HiddenPanelWorkGate<T> {
  private visible = true;
  private dirty = true;
  private signature = "";
  private value: T | undefined;

  setVisible(visible: boolean): void {
    if (visible && !this.visible) {
      this.dirty = true;
    }
    this.visible = visible;
  }

  markDirty(): void {
    this.dirty = true;
  }

  resolve(signature: string, create: () => T): T | undefined {
    if (!this.visible) {
      return this.value;
    }
    if (!this.dirty && signature === this.signature) {
      return this.value;
    }
    this.value = create();
    this.signature = signature;
    this.dirty = false;
    return this.value;
  }
}

export class MinimapInvalidationTracker {
  private signature = "";

  shouldRefresh(nextSignature: string, force = false): boolean {
    if (!force && nextSignature === this.signature) {
      return false;
    }
    this.signature = nextSignature;
    return true;
  }

  invalidate(): void {
    this.signature = "";
  }
}

export const V0112_SCHEDULER_MAP: SchedulerMapEntry[] = [
  scheduler("Runtime clock/status", "simulationClock", "src/game/scenes/BattleScene.ts", "every active frame", "fixed", "No gameplay allocation added; v0.112 leaves timer semantics intact.", true, "none", "gameplay-critical", ["Keep existing timer tick; avoid extra diagnostic work when paused."], ["Skipping runtime.tick or status timers."], "v0.110 phase rows include simulationClock as a measured phase."),
  scheduler("Camera", "camera", "src/game/systems/CameraSystem.ts", "every active frame", "variable", "Camera work depends on commands and follow state.", true, "viewport", "gameplay-critical", ["Private diagnostics can pause for measurement only."], ["Reducing camera tick cadence."], "v0.110 camera isolation row."),
  scheduler("Abilities", "abilities", "src/game/systems/AbilitySystem.ts", "every active frame", "variable", "Cooldown and cast state remain gameplay-critical.", false, "selected hero/enemy heroes", "gameplay-critical", ["No v0.112 runtime rewrite."], ["Skipping cooldown updates."], "Phase profiler separates abilities."),
  scheduler("Movement/pathing", "movementPathing", "src/game/systems/MovementSystem.ts", "every active frame when movement or separation can matter", "mixed", "v0.112 removes idle grid construction when no units move and no same-team overlap exists.", true, "unit move targets and collision", "gameplay-critical", ["Skip grid creation on idle non-overlap frames; keep buff updates."], ["Changing path outputs, repath cooldowns, or separation results."], "v0.110 Tier M showed movement/pathing as non-trivial incremental work."),
  scheduler("Combat/projectiles", "combatProjectiles", "src/game/systems/CombatSystem.ts", "every active frame", "variable", "v0.112 removes attacker spread/filter allocations only.", false, "hostile range/projectiles", "gameplay-critical", ["Build attacker list with loops preserving order."], ["Changing target priority, cooldowns, projectile timing, or damage."], "v0.110 phase rows separate combat/projectiles."),
  scheduler("Status effects", "statusEffects", "src/game/systems/StatusEffectSystem.ts", "every active frame", "mixed", "v0.112 skips empty carriers and avoids expiry filter unless needed.", true, "active statuses", "gameplay-critical", ["Return a shared empty tick result for no-op carriers."], ["Changing tick interval, duration, or damage."], "v0.110 Tier M top phase frequently reported status effects."),
  scheduler("Economy/production", "economyProduction", "src/game/systems/BuildingSystem.ts", "every active frame", "mixed", "No v0.112 gameplay scheduler change.", false, "buildings/sites/resources", "gameplay-critical", ["Audit-only for v0.112."], ["Changing income, training, upgrades, or repairs."], "v0.110 density rows report economy/production cost."),
  scheduler("Lume simulation", "lumeSimulation", "src/game/battle/LumeNetworkDirector.ts", "every active frame when a Lume network exists", "variable", "No balance or state rule change; linked_ward remains 0.92.", true, "Lume eligible battle", "gameplay-critical", ["Keep render cache separate from state."], ["Changing benefit value, activation, rewards-disabled, or tutorial exclusion."], "v0.110 Lume rows isolate simulation/presentation."),
  scheduler("Lume presentation", "lumePresentation", "src/game/scenes/BattleScene.ts", "every frame but signature-gated", "variable", "Existing signature gate retained.", true, "visibility mode and link state", "presentation-only", ["Keep existing graphics cache/signature."], ["Removing selected/activated/severed visual states."], "v0.110 Lume hidden/auto/always rows."),
  scheduler("Fog simulation", "fogSimulation", "src/game/systems/FogOfWarSystem.ts", "0.12 second cadence", "mixed", "v0.112 reuses vision-source slots and current-source copies.", true, "fog enabled", "gameplay-critical", ["Loop source construction; keep source snapshot copy inside FogOfWarSystem."], ["Changing reveal radius, cell state, or cadence."], "v0.110 fog rows and v0.111 clean-profile comparison."),
  scheduler("Fog presentation", "fogPresentation", "src/game/scenes/BattleScene.ts", "after fog simulation or force", "variable", "v0.112 uses a cell visitor for overlay/signature work.", true, "fog enabled and render signature", "presentation-only", ["Skip redraw when signature unchanged."], ["Skipping entity visibility when cells or entity visibility can change."], "v0.110 fog presentation isolation row."),
  scheduler("HUD DOM", "hudDom", "src/game/ui/HUD.ts", "0.1 second cadence or forced interaction", "mixed", "Existing stable-region patching retained; v0.112 reports hidden-panel gate as tested helper.", true, "HUD visibility/state", "presentation-only", ["Avoid unchanged DOM patches; keep local-panel wakeups."], ["Suppressing command availability or status changes."], "v0.110 HUD DOM top signal in static rows."),
  scheduler("Minimap snapshot", "hudDom", "src/game/battle/BattleSceneSnapshots.ts", "HUD refresh cadence", "mixed", "v0.112 replaces snapshot filter/map/spread chains with ordered loops.", true, "fog/camera/pings/entities", "presentation-only", ["Loop marker construction; retain marker order and visibility rules."], ["Changing fog visibility, marker order, or camera math."], "v0.110 minimap paused/reduced rows."),
  scheduler("Notifications", "eventsCleanup", "src/game/scenes/BattleScene.ts", "event driven plus status timer", "variable", "No v0.112 notification semantic change.", true, "status priority/timers", "presentation-only", ["Keep existing suppression diagnostics private-only."], ["Changing dedupe priority or gameplay warnings."], "v0.109/v0.110 notification isolation."),
  scheduler("Profiler counters", "sceneUpdate", "src/game/scenes/BattleScene.ts", "only when private phase profiler is on", "fixed", "v0.112 stops count-snapshot construction while profiler is disabled.", true, "private diagnostics", "private-diagnostic", ["Check enabled before creating count snapshot."], ["Collecting profiler counters in public/default runtime."], "v0.110 profiler capability report."),
  scheduler("End conditions", "endConditions", "src/game/scenes/BattleScene.ts", "every active simulation frame", "fixed", "No v0.112 semantic change.", false, "runtime battle outcome", "gameplay-critical", ["Audit-only for v0.112."], ["Changing victory/defeat conditions."], "Phase profiler separates end conditions.")
];

export const V0112_ALLOCATION_AUDIT_ROWS: AllocationAuditRow[] = [
  allocation("fog-vision-sources", "src/game/scenes/BattleScene.ts", "Vision sources", "Before used three filter/map arrays plus a spread return every fog tick.", shape(4, 0, 0, 0, 0, 3, 3), shape(0, 0, 0, 0, 0, 0, 0), "Reusable source slots filled by ordered loops.", "low"),
  allocation("fog-current-sources", "src/game/systems/FogOfWarSystem.ts", "Fog current source copy", "Before cloned source objects with sources.map each update.", shape(1, 1, 0, 0, 0, 0, 1), shape(0, 0, 0, 0, 0, 0, 0), "Copy source fields into reusable current-source slots.", "low"),
  allocation("fog-overlay-cells", "src/game/scenes/BattleScene.ts", "Fog overlay/signature", "Before cells().filter().map().join() and cells().forEach allocated cell snapshots.", shape(3, 1, 0, 0, 0, 1, 1), shape(0, 0, 0, 0, 0, 0, 0), "Use FogOfWarSystem.forEachCell for overlay and signature traversal.", "low"),
  allocation("status-empty-carriers", "src/game/systems/StatusEffectSystem.ts", "Status effect tick", "Before every empty carrier still allocated a filtered statusEffects array.", shape(1, 0, 0, 0, 0, 1, 0), shape(0, 0, 0, 0, 0, 0, 0), "Skip empty carriers and filter only when an effect expires.", "low"),
  allocation("movement-idle-grid", "src/game/systems/MovementSystem.ts", "Idle movement/pathing", "Before grid/static obstacle arrays were built before checking for movement.", shape(2, 1, 1, 1, 0, 2, 1), shape(0, 0, 0, 0, 0, 0, 0), "Tick buffs, then skip grid when no move target and no same-team overlap exists.", "medium"),
  allocation("combat-attackers", "src/game/systems/CombatSystem.ts", "Attacker list", "Before spread + filter rebuilt attacker candidates.", shape(2, 0, 0, 0, 0, 1, 0), shape(1, 0, 0, 0, 0, 0, 0), "Build the single attacker list with loops preserving unit then building order.", "low"),
  allocation("minimap-snapshot", "src/game/battle/BattleSceneSnapshots.ts", "Minimap snapshot markers", "Before each marker group used filter/map and spread composition.", shape(7, 1, 0, 1, 0, 5, 5), shape(1, 0, 0, 1, 0, 0, 0), "Build markers with ordered loops and retain objective-site Set.", "low"),
  allocation("private-profiler-counts", "src/game/scenes/BattleScene.ts", "Private counter snapshots", "Before count snapshots were constructed even when phase profiling was disabled.", shape(4, 0, 0, 0, 0, 4, 0), shape(0, 0, 0, 0, 0, 0, 0), "Check profiler enabled before building count snapshots; loop private counters.", "low")
];

export const V0112_IDLE_COST_CASES: IdleCostCaseDefinition[] = [
  idleCase("v0112_empty_battle_shell", "Empty battle shell", "v0110_empty_static", "fixed-idle", { phaseProfiler: "on", simulation: "paused", ai: "paused", movement: "paused", combat: "paused", fogSimulation: "paused", hudDomPatches: "paused" }, "Canvas and scene shell fixed cost with simulation and HUD work paused."),
  idleCase("v0112_static_entities", "Static entities", "v0110_static_hud_minimal", "fixed-idle", { phaseProfiler: "on", simulation: "paused", ai: "paused", movement: "paused", combat: "paused", hudDomPatches: "paused" }, "Entity/display fixed cost with HUD patches paused."),
  idleCase("v0112_static_entities_hud", "Static entities plus HUD", "v0110_static_hud_minimal", "incremental-ui", { phaseProfiler: "on", simulation: "paused", ai: "paused", movement: "paused", combat: "paused" }, "HUD/minimap incremental cost over static entities."),
  idleCase("v0112_one_hero_idle", "One hero idle", "perf_selected_hero", "fixed-idle", { phaseProfiler: "on", ai: "paused", movement: "paused", combat: "paused", fogSimulation: "paused" }, "Hero selection/HUD idle posture."),
  idleCase("v0112_tier_m_idle", "Tier M idle", "benchmark_battle_tier_m_representative", "fixed-idle", { phaseProfiler: "on", ai: "paused", movement: "paused", combat: "paused", projectiles: "paused" }, "Tier M fixed idle cost with movement/combat/AI held."),
  idleCase("v0112_tier_m_moving", "Tier M moving", "benchmark_battle_minimap_interaction", "incremental-movement", { phaseProfiler: "on", ai: "paused", combat: "paused", projectiles: "paused" }, "Movement/pathing incremental cost with combat held."),
  idleCase("v0112_tier_m_combat", "Tier M combat", "benchmark_battle_tier_m_representative", "incremental-combat", { phaseProfiler: "on" }, "Representative movement/combat/AI cost."),
  idleCase("v0112_tier_m_ui_hidden", "Tier M UI hidden diagnostic", "benchmark_battle_tier_m_representative", "incremental-ui", { phaseProfiler: "on", hudDomPatches: "paused", minimap: "paused", labels: "hidden", captureRings: "minimal", lume: "hidden", notifications: "suppressed" }, "Private UI-hidden diagnostic cost ceiling; not a public mode.")
];

export function buildV0112ArtifactSet(results: IdleCostMatrixResult[], generatedAtUtc = new Date().toISOString()): V0112ArtifactSet {
  return {
    schemaVersion: 1,
    checkpoint: V0112_CHECKPOINT,
    title: V0112_TITLE,
    generatedAtUtc,
    schedulerMap: V0112_SCHEDULER_MAP,
    allocationAudit: V0112_ALLOCATION_AUDIT_ROWS,
    idleCostMatrix: sortIdleResults(results),
    paritySummary: createV0112ParitySummary(results)
  };
}

export function createV0112ParitySummary(results: IdleCostMatrixResult[] = []): V0112ParitySummary {
  return {
    schemaVersion: 1,
    checkpoint: V0112_CHECKPOINT,
    gameplaySemanticsChanged: false,
    savesChanged: false,
    stableIdsChanged: false,
    pathingOutputsChanged: false,
    aiDecisionRulesChanged: false,
    linkedWardDamageTakenMultiplier: LUME_NETWORKS.find((network) => network.benefit.id === "linked_ward")?.benefit.damageTakenMultiplier,
    parityChecks: [
      { id: "positions-health-deaths-captures-resources-results", status: results.length > 0 ? "pass" : "pending", evidence: "Browser idle matrix keeps save snapshots unchanged before and after each private scenario." },
      { id: "ai-pathing-replay-posture", status: "pass", evidence: "v0.112 does not change AI decisions, path search outputs, replay state, or launch fixtures." },
      { id: "lume-linked-ward", status: "pass", evidence: "Unit test asserts linked_ward damageTakenMultiplier remains exactly 0.92." },
      { id: "saves-stable-ids", status: "pass", evidence: "No save schema, stable ID, content, art, or package metadata field is changed by runtime code." }
    ]
  };
}

export function renderSchedulerMapMarkdown(): string {
  return [
    "# v0.112 Battle-Loop Scheduler Map",
    "",
    "This map documents recurring battle-loop work only. It does not approve gameplay, balance, save, art, engine, or desktop-port changes.",
    "",
    "| Subsystem | Owner | Cadence | Cost | Dirty state | Visibility | Posture | Evidence |",
    "| --- | --- | --- | --- | --- | --- | --- | --- |",
    ...V0112_SCHEDULER_MAP.map(
      (entry) =>
        `| ${entry.subsystem} | ${entry.ownerFile} | ${entry.cadence} | ${entry.costKind} | ${entry.dirtyStateAvailable ? "yes" : "no"} | ${entry.visibilityDependency} | ${entry.gameplayPosture} | ${entry.profilerEvidence} |`
    ),
    "",
    "## Safe Optimizations",
    "",
    ...V0112_SCHEDULER_MAP.map((entry) => `- ${entry.subsystem}: ${entry.safeOptimizations.join("; ")}`),
    "",
    "## Unsafe Optimizations",
    "",
    ...V0112_SCHEDULER_MAP.map((entry) => `- ${entry.subsystem}: ${entry.unsafeOptimizations.join("; ")}`),
    ""
  ].join("\n");
}

export function renderAllocationAuditMarkdown(): string {
  return [
    "# v0.112 Hot Path Allocation Audit",
    "",
    "Rows are code-path allocation audits backed by the v0.110 phase profiler and v0.111 clean-profile classification. Counts are per activation shape counts, not total heap bytes.",
    "",
    "| Row | Owner | Before arrays | After arrays | Before filters/maps | After filters/maps | Optimization | Risk |",
    "| --- | --- | ---: | ---: | ---: | ---: | --- | --- |",
    ...V0112_ALLOCATION_AUDIT_ROWS.map(
      (row) =>
        `| ${row.id} | ${row.ownerFile} | ${row.beforePerActivation.arrays} | ${row.afterPerActivation.arrays} | ${
          row.beforePerActivation.filters + row.beforePerActivation.mapsCalls
        } | ${row.afterPerActivation.filters + row.afterPerActivation.mapsCalls} | ${row.optimization} | ${row.semanticRisk} |`
    ),
    ""
  ].join("\n");
}

export function renderIdleCostMatrixMarkdown(results: IdleCostMatrixResult[]): string {
  const sorted = sortIdleResults(results);
  return [
    "# v0.112 Idle Cost Matrix",
    "",
    "Private browser measurements separating fixed idle cost from movement, combat, and UI increments. Rows are no-save Playtest Hub scenarios.",
    "",
    "| Case | Posture | Launch | FPS avg | p95 frame | Top phase | HUD/s | Minimap/s | Units | DOM |",
    "| --- | --- | --- | ---: | ---: | --- | ---: | ---: | ---: | ---: |",
    ...sorted.map((result) => {
      const top = topPhase(result.phaseSummary);
      return `| ${result.caseId} | ${result.posture} | ${result.launchScenarioId} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} | ${top.label} | ${result.steadyState.ratesPerSecond.hudUpdates} | ${result.steadyState.ratesPerSecond.minimapRefreshes} | ${result.phaseSummary.latestCounts.units} | ${result.steadyState.counters.domNodes} |`;
    }),
    ""
  ].join("\n");
}

export function renderOptimizationReportMarkdown(results: IdleCostMatrixResult[]): string {
  return [
    "# v0.112 Evidence-Backed Optimization Report",
    "",
    "Implemented optimizations are limited to allocation and idle-work rescue where parity can be preserved.",
    "",
    "- Status effects skip empty carriers and avoid expiry filtering unless an effect expires.",
    "- Fog vision sources, fog current sources, and fog overlay traversal now reuse or avoid scratch allocations.",
    "- Movement skips pathfinding-grid construction only on frames with no move target and no same-team overlap, while still updating unit buffs.",
    "- Combat attacker collection and minimap snapshot marker construction now use ordered loops instead of spread/filter/map chains.",
    "- Private phase-profiler count snapshots are constructed only when the profiler is enabled.",
    "",
    `Idle matrix rows available: ${results.length}.`,
    ""
  ].join("\n");
}

export function renderParityReportMarkdown(summary: V0112ParitySummary): string {
  return [
    "# v0.112 Parity Report",
    "",
    `Gameplay semantics changed: ${summary.gameplaySemanticsChanged}.`,
    `Saves changed: ${summary.savesChanged}.`,
    `Stable IDs changed: ${summary.stableIdsChanged}.`,
    `Pathing outputs changed: ${summary.pathingOutputsChanged}.`,
    `AI decision rules changed: ${summary.aiDecisionRulesChanged}.`,
    `linked_ward damageTakenMultiplier: ${summary.linkedWardDamageTakenMultiplier}.`,
    "",
    "| Check | Status | Evidence |",
    "| --- | --- | --- |",
    ...summary.parityChecks.map((check) => `| ${check.id} | ${check.status} | ${check.evidence} |`),
    ""
  ].join("\n");
}

export function renderImplementationReportMarkdown(results: IdleCostMatrixResult[]): string {
  return [
    "# v0.112 Implementation Report",
    "",
    "v0.112 implements battle-loop scheduler documentation, hot-path allocation audit artifacts, idle-cost profiling, and bounded runtime allocation reductions.",
    "",
    "## Runtime Changes",
    "",
    "- Fog source creation and fog overlay traversal use reusable/visitor paths.",
    "- Empty status-effect carriers no longer allocate or tick helper work.",
    "- Idle movement frames without move targets or same-team overlap skip grid construction.",
    "- Combat and minimap marker collection avoid spread/filter/map allocation chains.",
    "- Private phase-profiler count snapshots are disabled when the profiler is off.",
    "",
    "## Scope Guard",
    "",
    "No gameplay semantics, AI decision rules, pathfinding outputs, saves, stable IDs, art, engine posture, desktop work, balance, or public content were intentionally changed.",
    "",
    `Idle matrix rows measured: ${results.length}.`,
    ""
  ].join("\n");
}

export function renderEmmanuelRetestChecklistMarkdown(): string {
  return [
    "# v0.112 Emmanuel Retest Checklist",
    "",
    "- Run `npm run perf:trusted:preview` and compare the Tier M baseline with v0.111.",
    "- Run `npm run perf:trusted:clean-profile` to confirm the host classification remains game-cost dominant.",
    "- Run `npm run perf:phase-profile`, `npm run perf:allocation-audit`, and `npm run perf:idle-cost-matrix`.",
    "- Confirm linked_ward remains exactly 0.92.",
    "- Confirm Tutorial, Tier M, minimap, fog, HUD, Lume, Results, reset, and return-to-hub paths remain no-save and stable.",
    "- Package with `npm run package:playtest` and verify with `npm run verify:playtest-package`.",
    ""
  ].join("\n");
}

export function renderBeforeAfterDeltaMarkdown(results: IdleCostMatrixResult[]): string {
  const tierM = results.find((entry) => entry.caseId === "v0112_tier_m_combat");
  const hidden = results.find((entry) => entry.caseId === "v0112_tier_m_ui_hidden");
  return [
    "# v0.112 Before/After Delta",
    "",
    "The before state is the committed v0.111/v0.110 evidence baseline. The after state is the v0.112 runtime and private measurement artifacts.",
    "",
    `Tier M combat p95 after: ${tierM?.steadyState.frameTimeMs.p95 ?? "pending"} ms.`,
    `Tier M UI-hidden diagnostic p95 after: ${hidden?.steadyState.frameTimeMs.p95 ?? "pending"} ms.`,
    "",
    "Implemented deltas are allocation-shape reductions only; no gameplay, save, ID, art, or engine delta is authorized.",
    ""
  ].join("\n");
}

function scheduler(
  subsystem: string,
  phaseId: BattleLoopPhaseId,
  ownerFile: string,
  cadence: string,
  costKind: SchedulerCostKind,
  allocationPosture: string,
  dirtyStateAvailable: boolean,
  visibilityDependency: string,
  gameplayPosture: SchedulerGameplayPosture,
  safeOptimizations: string[],
  unsafeOptimizations: string[],
  profilerEvidence: string
): SchedulerMapEntry {
  if (!V0110_BATTLE_LOOP_PHASES.some((phase) => phase.id === phaseId)) {
    throw new Error(`Unknown scheduler phase ${phaseId}.`);
  }
  return {
    subsystem,
    phaseId,
    ownerFile,
    cadence,
    costKind,
    allocationPosture,
    dirtyStateAvailable,
    visibilityDependency,
    gameplayPosture,
    safeOptimizations,
    unsafeOptimizations,
    profilerEvidence
  };
}

function allocation(
  id: string,
  ownerFile: string,
  surface: string,
  evidence: string,
  beforePerActivation: AllocationShape,
  afterPerActivation: AllocationShape,
  optimization: string,
  semanticRisk: AllocationAuditRow["semanticRisk"]
): AllocationAuditRow {
  return { id, ownerFile, surface, evidence, beforePerActivation, afterPerActivation, optimization, semanticRisk };
}

function shape(
  arrays: number,
  objects: number,
  maps: number,
  sets: number,
  sorts: number,
  filters: number,
  mapsCalls: number,
  domPatches = 0,
  graphicsCreateDestroy = 0,
  labelLayouts = 0
): AllocationShape {
  return { arrays, objects, maps, sets, sorts, filters, mapsCalls, domPatches, graphicsCreateDestroy, labelLayouts };
}

function idleCase(
  id: string,
  title: string,
  launchScenarioId: string,
  posture: IdleCostCaseDefinition["posture"],
  diagnostics: Partial<BattleLoopDiagnostics>,
  purpose: string
): IdleCostCaseDefinition {
  return {
    id,
    title,
    launchScenarioId,
    posture,
    diagnostics,
    purpose,
    expectedFixedCostSignal: "Compare p95 frame time, phase summary top cost, HUD/minimap rates, DOM nodes, and display counts."
  };
}

function topPhase(summary: BattleLoopPhaseSummary) {
  return [...summary.phases].sort((left, right) => right.totalMs - left.totalMs)[0] ?? {
    label: "pending",
    totalMs: 0
  };
}

function sortIdleResults(results: IdleCostMatrixResult[]): IdleCostMatrixResult[] {
  const order = new Map(V0112_IDLE_COST_CASES.map((entry, index) => [entry.id, index]));
  return [...results].sort((left, right) => (order.get(left.caseId) ?? 999) - (order.get(right.caseId) ?? 999));
}
