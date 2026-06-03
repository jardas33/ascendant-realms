import type { HudDensityMode } from "../ui/hudPanels/HudTypes";
import type { LumeNetworkVisibilityMode } from "../core/GameTypes";
import type { PrivatePerformanceCounters, PrivatePerformanceLongTask } from "./PrivatePerformanceProfiler";

export const V0109_CHECKPOINT = "v0.109";
export const V0109_TITLE = "Browser Benchmark Integrity Audit and Performance Root-Cause Isolation";
export const V0109_ARTIFACT_DIR = "artifacts/performance/v0109";

export type TrustedExecutionMode =
  | "production-preview-headless"
  | "production-preview-headed"
  | "dev-server-headless"
  | "manual-in-app";

export type TrustedBenchmarkScenarioId =
  | "benchmark_battle_tier_s_smoke"
  | "benchmark_battle_tier_m_representative"
  | "benchmark_battle_tier_l_stress"
  | "benchmark_battle_results_transition"
  | "perf_campaign_map_interaction";

export type TrustedDiagnosticLabels = "normal" | "hidden";
export type TrustedDiagnosticCaptureRings = "normal" | "minimal";
export type TrustedDiagnosticMinimapRefresh = "normal" | "reduced" | "paused";
export type TrustedDiagnosticFogRedraw = "normal" | "reduced";
export type TrustedDiagnosticNotifications = "normal" | "suppressed";
export type TrustedDiagnosticProfilerOverlay = "off" | "on";

export interface TrustedBenchmarkDiagnostics {
  labels: TrustedDiagnosticLabels;
  captureRings: TrustedDiagnosticCaptureRings;
  lume: LumeNetworkVisibilityMode;
  minimapRefresh: TrustedDiagnosticMinimapRefresh;
  fogRedraw: TrustedDiagnosticFogRedraw;
  hudDensity: HudDensityMode;
  notifications: TrustedDiagnosticNotifications;
  profilerOverlay: TrustedDiagnosticProfilerOverlay;
}

export interface TrustedRootCauseCase {
  id: string;
  title: string;
  scenarioId: TrustedBenchmarkScenarioId;
  executionMode: TrustedExecutionMode;
  viewport: string;
  diagnostics: TrustedBenchmarkDiagnostics;
  compareFocus: string;
  localOnly: boolean;
}

export interface TrustedFrameInterval {
  index: number;
  atMs: number;
  frameMs: number;
}

export interface TrustedLaunchPhaseMetrics {
  navigationStartToHubReadyMs: number;
  scenarioClickToBattleHudMs: number;
  scenarioClickToSceneReadyMs: number;
  firstResponsiveInteractionMs: number;
  firstRenderedFrameAfterReadyMs: number;
}

export interface TrustedInteractionLatencyMetrics {
  selectHeroMs?: number;
  selectWorkerMs?: number;
  selectBuildingMs?: number;
  minimapClickMs?: number;
  lumeHiddenMs?: number;
  lumeAutoMs?: number;
  lumeAlwaysMs?: number;
  resultsDisclosureMs?: number;
  scenarioResetMs?: number;
  returnToHubMs?: number;
}

export interface TrustedSteadyStateMetrics {
  sampleDurationMs: number;
  sampleCount: number;
  fpsAverage: number;
  fpsOnePercentLow: number;
  frameTimeMs: {
    p50: number;
    p95: number;
    p99: number;
    max: number;
    over16_7: number;
    over33_3: number;
    over50: number;
    over100: number;
    over250: number;
    over500: number;
  };
  longTasks: {
    supported: boolean;
    count: number;
    totalDurationMs: number;
    maxDurationMs: number;
  };
  counters: PrivatePerformanceCounters & { totalLabels?: number };
  counterDeltas: Partial<PrivatePerformanceCounters>;
  ratesPerSecond: {
    fogRedraws: number;
    minimapRefreshes: number;
    hudUpdates: number;
    notificationsEmitted: number;
  };
  memoryTrendMb?: number;
}

export interface TrustedBenchmarkEnvironment {
  executionMode: TrustedExecutionMode;
  visibilityState: DocumentVisibilityState | "unknown";
  viewport: string;
  userAgent: string;
  browserName: string;
  headed: boolean;
  serverMode: "preview" | "dev" | "manual";
  profilerOverlayEnabled: boolean;
  screenshotsDuringSample: boolean;
  warmupMs: number;
  sampleMs: number;
  longTaskObserverSupported: boolean;
  memorySupported: boolean;
}

export interface TrustedBenchmarkResult {
  id: string;
  caseId: string;
  title: string;
  scenarioId: TrustedBenchmarkScenarioId;
  diagnostics: TrustedBenchmarkDiagnostics;
  environment: TrustedBenchmarkEnvironment;
  launch: TrustedLaunchPhaseMetrics;
  settle: {
    configuredWarmupMs: number;
    actualWarmupMs: number;
    visibilityState: DocumentVisibilityState | "unknown";
    sceneStable: boolean;
  };
  steadyState: TrustedSteadyStateMetrics;
  interactions: TrustedInteractionLatencyMetrics;
  rawFrameIntervalArtifact: string;
  interactionLatencyArtifact: string;
}

export interface TrustedBenchmarkArtifactSet {
  checkpoint: typeof V0109_CHECKPOINT;
  title: typeof V0109_TITLE;
  generatedAtUtc: string;
  warmupMs: number;
  sampleMs: number;
  results: TrustedBenchmarkResult[];
}

export interface ProfilerMethodAuditFinding {
  item: string;
  finding: string;
  risk: "low" | "medium" | "high";
  v0109Response: string;
}

export interface ProfilerMethodAudit {
  checkpoint: typeof V0109_CHECKPOINT;
  title: string;
  oldSampleWindowMs: number;
  oldExecutionMode: string;
  oldProfilerOverlay: string;
  findings: ProfilerMethodAuditFinding[];
  conclusion: string;
}

export const TRUSTED_DEFAULT_WARMUP_MS = 5000;
export const TRUSTED_DEFAULT_SAMPLE_MS = 10000;
export const TRUSTED_BENCHMARK_VIEWPORTS = ["1920x1080", "1600x900", "1366x768"] as const;

export const TRUSTED_BENCHMARK_DEFAULT_DIAGNOSTICS: TrustedBenchmarkDiagnostics = {
  labels: "normal",
  captureRings: "normal",
  lume: "auto",
  minimapRefresh: "normal",
  fogRedraw: "normal",
  hudDensity: "minimal",
  notifications: "normal",
  profilerOverlay: "off"
};

export const TRUSTED_EXECUTION_MODE_LABELS: Record<TrustedExecutionMode, string> = {
  "production-preview-headless": "production preview + headless Playwright",
  "production-preview-headed": "production preview + headed Playwright",
  "dev-server-headless": "dev server + headless Playwright",
  "manual-in-app": "private in-app manual profiler mode"
};

export const TRUSTED_ROOT_CAUSE_CASES: TrustedRootCauseCase[] = [
  rootCauseCase("baseline", "Tier M baseline", "benchmark_battle_tier_m_representative", {
    compareFocus: "baseline composed representative battle"
  }),
  rootCauseCase("labels-hidden", "Labels hidden", "benchmark_battle_tier_m_representative", {
    diagnostics: { labels: "hidden" },
    compareFocus: "label text/display cost"
  }),
  rootCauseCase("rings-minimal", "Capture rings minimal", "benchmark_battle_tier_m_representative", {
    diagnostics: { captureRings: "minimal" },
    compareFocus: "capture-ring graphics cost"
  }),
  rootCauseCase("lume-hidden", "Lume hidden", "benchmark_battle_tier_m_representative", {
    diagnostics: { lume: "hidden" },
    compareFocus: "hidden Lume render cost"
  }),
  rootCauseCase("lume-always", "Lume always", "benchmark_battle_tier_m_representative", {
    diagnostics: { lume: "always" },
    compareFocus: "max Lume overlay cost"
  }),
  rootCauseCase("minimap-reduced", "Minimap reduced", "benchmark_battle_tier_m_representative", {
    diagnostics: { minimapRefresh: "reduced" },
    compareFocus: "reduced minimap DOM/SVG refresh"
  }),
  rootCauseCase("minimap-paused", "Minimap paused", "benchmark_battle_tier_m_representative", {
    diagnostics: { minimapRefresh: "paused" },
    compareFocus: "minimap snapshot/render cost ceiling"
  }),
  rootCauseCase("fog-reduced", "Fog redraw reduced", "benchmark_battle_tier_m_representative", {
    diagnostics: { fogRedraw: "reduced" },
    compareFocus: "fog visual redraw cost without changing fog simulation"
  }),
  rootCauseCase("hud-minimal", "HUD Minimal", "benchmark_battle_tier_m_representative", {
    diagnostics: { hudDensity: "minimal" },
    compareFocus: "minimal HUD baseline"
  }),
  rootCauseCase("hud-standard", "HUD Standard", "benchmark_battle_tier_m_representative", {
    diagnostics: { hudDensity: "standard" },
    compareFocus: "standard HUD detail surface cost"
  }),
  rootCauseCase("hud-debug", "HUD Debug", "benchmark_battle_tier_m_representative", {
    diagnostics: { hudDensity: "debug" },
    compareFocus: "debug counter surface cost"
  }),
  rootCauseCase("notifications-suppressed", "Notifications suppressed", "benchmark_battle_tier_m_representative", {
    diagnostics: { notifications: "suppressed" },
    compareFocus: "status/floating notification cost"
  }),
  rootCauseCase("profiler-overlay-on", "Profiler overlay on", "benchmark_battle_tier_m_representative", {
    diagnostics: { profilerOverlay: "on" },
    compareFocus: "old profiler overlay/panel distortion"
  }),
  rootCauseCase("overlays-minimized", "All non-essential overlays minimized", "benchmark_battle_tier_m_representative", {
    diagnostics: {
      labels: "hidden",
      captureRings: "minimal",
      lume: "hidden",
      minimapRefresh: "reduced",
      fogRedraw: "reduced",
      hudDensity: "minimal",
      notifications: "suppressed",
      profilerOverlay: "off"
    },
    compareFocus: "minimum private visual overlay posture"
  }),
  rootCauseCase("overlays-enabled", "All review overlays enabled", "benchmark_battle_tier_m_representative", {
    diagnostics: {
      labels: "normal",
      captureRings: "normal",
      lume: "always",
      minimapRefresh: "normal",
      fogRedraw: "normal",
      hudDensity: "debug",
      notifications: "normal",
      profilerOverlay: "on"
    },
    compareFocus: "maximum private review overlay posture"
  }),
  rootCauseCase("tier-s", "Tier S smoke", "benchmark_battle_tier_s_smoke", {
    viewport: "1366x768",
    compareFocus: "small-tier density"
  }),
  rootCauseCase("tier-l", "Tier L local-only stress", "benchmark_battle_tier_l_stress", {
    viewport: "1920x1080",
    compareFocus: "local-only high-density stress",
    localOnly: true
  }),
  rootCauseCase("results-transition", "Results transition", "benchmark_battle_results_transition", {
    viewport: "1366x768",
    compareFocus: "transition separated from steady-state frame score"
  }),
  rootCauseCase("campaign-map", "Campaign-map interaction", "perf_campaign_map_interaction", {
    compareFocus: "non-battle campaign map DOM posture"
  })
];

export function createDefaultTrustedDiagnostics(): TrustedBenchmarkDiagnostics {
  return { ...TRUSTED_BENCHMARK_DEFAULT_DIAGNOSTICS };
}

export function normalizeTrustedDiagnostics(
  diagnostics: Partial<TrustedBenchmarkDiagnostics> = {}
): TrustedBenchmarkDiagnostics {
  return {
    ...TRUSTED_BENCHMARK_DEFAULT_DIAGNOSTICS,
    ...diagnostics
  };
}

export function createProfilerMethodAudit(): ProfilerMethodAudit {
  return {
    checkpoint: V0109_CHECKPOINT,
    title: "v0.109 Profiler Method Audit",
    oldSampleWindowMs: 1200,
    oldExecutionMode: "dev-server headless Playwright with SwiftShader args",
    oldProfilerOverlay: "visible profiler panel updates every ~500 ms while sampling",
    findings: [
      finding("FPS average", "Computed as 1000 divided by mean rAF delta from the collected frame list.", "medium", "Keep the calculation, but use a longer warm sample and retain raw intervals."),
      finding("1% low", "Computed from the slowest 1% of frame deltas, with tiny samples often reducing to one frame.", "high", "Use a 10 second default sample so 1% low is not just one launch/settle stall."),
      finding("Frame percentiles", "p50/p95/p99/max use sorted rAF deltas from the active profiler window.", "medium", "Keep percentile math but separate launch, warm-up, steady-state, and transitions."),
      finding("Sample duration", "The v0.103/v0.104/v0.108 automated lanes used 1200 ms by default.", "high", "Default v0.109 warm-up is 5000 ms and steady-state sample is 10000 ms."),
      finding("Launch contamination", "The v0.108 runner starts the profiler after battle load plus a short 250 ms wait, then immediately performs an action and sometimes a Results transition inside the same sample.", "high", "Measure launch, settle, steady-state, interaction, and transition as separate phases."),
      finding("rAF source", "Frame deltas are collected inside the page with requestAnimationFrame.", "low", "Keep in-page rAF sampling and retain raw intervals under ignored artifacts."),
      finding("Headless mode", "Automated v0.108 evidence uses headless Chromium.", "medium", "Record execution mode and compare preview headless, dev headless, optional headed, and manual mode."),
      finding("Visibility state", "The old reports do not record document.visibilityState.", "medium", "Require and report visibilityState for every trusted sample."),
      finding("Dev vs production", "v0.108 benchmark runs against a Vite dev server.", "high", "Use production preview as the primary automated lane and dev server as secondary evidence."),
      finding("Screenshots", "The benchmark runner does not screenshot, but visual QA separately captures screenshots for scenario review.", "low", "Report screenshotsDuringSample=false for benchmark lanes and keep visual QA outside timing windows."),
      finding("Profiler panel overhead", "The old profiler panel is visible and updates while it samples.", "high", "Default trusted samples run with profiler overlay off and compare overlay on as a root-cause case."),
      finding("Debug counters", "Debug HUD counters can add DOM/layout work when HUD Debug is active.", "medium", "Treat HUD Debug as a separate diagnostic comparison."),
      finding("Settle time", "The old 250 ms settle wait is too short for a composed battle after launch.", "high", "Use a configurable warm-up, default 5000 ms, with no FPS score during warm-up."),
      finding("Sample size", "A one-frame stall can dominate a 1200 ms sample and make FPS appear implausibly low.", "high", "Use raw intervals plus threshold counts to distinguish single stalls from sustained low cadence."),
      finding("Machine/load effects", "Local Playwright, SwiftShader, browser install, and concurrent local load can distort absolute metrics.", "medium", "Report mode, browser, user agent, capabilities, and compare relative root-cause cases.")
    ],
    conclusion:
      "The earlier 2-3 FPS evidence should be treated as mixed and methodologically weak until v0.109 trusted samples separate launch/settle/transition work from steady-state frame timing."
  };
}

export function summarizeTrustedFrameIntervals(options: {
  intervals: TrustedFrameInterval[];
  sampleDurationMs: number;
  countersBefore: PrivatePerformanceCounters;
  countersAfter: PrivatePerformanceCounters;
  longTasks?: PrivatePerformanceLongTask[];
  longTaskSupported?: boolean;
}): TrustedSteadyStateMetrics {
  const frameTimes = options.intervals.map((entry) => entry.frameMs).filter((value) => Number.isFinite(value) && value >= 0);
  const sorted = [...frameTimes].sort((left, right) => left - right);
  const durationSeconds = Math.max(0.001, options.sampleDurationMs / 1000);
  const deltas = counterDeltas(options.countersAfter, options.countersBefore);
  const longTasks = options.longTasks ?? [];
  return {
    sampleDurationMs: roundMetric(options.sampleDurationMs),
    sampleCount: frameTimes.length,
    fpsAverage: roundMetric(frameTimes.length / durationSeconds),
    fpsOnePercentLow: roundMetric(onePercentLowFps(frameTimes)),
    frameTimeMs: {
      p50: roundMetric(percentile(sorted, 0.5)),
      p95: roundMetric(percentile(sorted, 0.95)),
      p99: roundMetric(percentile(sorted, 0.99)),
      max: roundMetric(sorted.at(-1) ?? 0),
      over16_7: countOver(frameTimes, 16.7),
      over33_3: countOver(frameTimes, 33.3),
      over50: countOver(frameTimes, 50),
      over100: countOver(frameTimes, 100),
      over250: countOver(frameTimes, 250),
      over500: countOver(frameTimes, 500)
    },
    longTasks: {
      supported: Boolean(options.longTaskSupported),
      count: longTasks.length,
      totalDurationMs: roundMetric(longTasks.reduce((total, task) => total + task.durationMs, 0)),
      maxDurationMs: roundMetric(Math.max(0, ...longTasks.map((task) => task.durationMs)))
    },
    counters: options.countersAfter,
    counterDeltas: deltas,
    ratesPerSecond: {
      fogRedraws: counterRate(deltas.fogRedraws, durationSeconds),
      minimapRefreshes: counterRate(deltas.minimapRefreshes, durationSeconds),
      hudUpdates: counterRate(deltas.hudUpdates, durationSeconds),
      notificationsEmitted: counterRate(deltas.notificationsEmitted, durationSeconds)
    },
    memoryTrendMb:
      options.countersBefore.memoryUsedMb !== undefined && options.countersAfter.memoryUsedMb !== undefined
        ? roundMetric(options.countersAfter.memoryUsedMb - options.countersBefore.memoryUsedMb)
        : undefined
  };
}

export function renderProfilerMethodAuditMarkdown(audit = createProfilerMethodAudit()): string {
  return [
    "# v0.109 Profiler Method Audit",
    "",
    `Old sample window: ${audit.oldSampleWindowMs} ms.`,
    `Old execution mode: ${audit.oldExecutionMode}.`,
    `Old profiler overlay: ${audit.oldProfilerOverlay}.`,
    "",
    "## Findings",
    "",
    "| Item | Finding | Risk | v0.109 Response |",
    "| --- | --- | --- | --- |",
    ...audit.findings.map((entry) => `| ${entry.item} | ${entry.finding} | ${entry.risk} | ${entry.v0109Response} |`),
    "",
    "## Conclusion",
    "",
    audit.conclusion,
    ""
  ].join("\n");
}

export function renderTrustedBenchmarkProtocolMarkdown(): string {
  return [
    "# v0.109 Trusted Browser Benchmark Protocol",
    "",
    "Status: private benchmark methodology only. It does not choose an engine, start a port, add art, change saves, alter stable IDs, change combat, or change campaign progression.",
    "",
    "## Phase 1 - Launch",
    "",
    "- Measure navigation start, hub ready, battle HUD ready, scene ready, first rendered frame, and first responsive interaction separately.",
    "",
    "## Phase 2 - Settle",
    "",
    `- Warm up for ${TRUSTED_DEFAULT_WARMUP_MS} ms by default.`,
    "- No FPS score is produced during warm-up.",
    "- visibilityState, viewport, browser user agent, server mode, overlay state, and screenshot state are recorded.",
    "- screenshotsDuringSample=false is recorded for trusted timing lanes; visual QA screenshots happen outside the sample window.",
    "",
    "## Phase 3 - Steady-State Sample",
    "",
    `- Sample for ${TRUSTED_DEFAULT_SAMPLE_MS} ms by default.`,
    "- requestAnimationFrame deltas are collected inside the page and retained in ignored raw-frame artifacts.",
    "- Report FPS average, 1% low, p50/p95/p99/max, thresholds above 16.7/33.3/50/100/250/500 ms, long tasks, counters, rates, DOM nodes, and memory when supported.",
    "",
    "## Phase 4 - Interaction Sample",
    "",
    "- Measure hero selection, Worker selection, building selection, minimap click, Lume visibility toggles, Results disclosure, reset, and return-to-hub separately.",
    "",
    "## Phase 5 - Report",
    "",
    "- Keep launch latency, settle duration, steady-state metrics, interaction latency, and transition latency in separate report sections.",
    ""
  ].join("\n");
}

export function renderTrustedBenchmarkSummaryMarkdown(results: TrustedBenchmarkResult[]): string {
  const sorted = [...results].sort((left, right) => left.caseId.localeCompare(right.caseId));
  return [
    "# v0.109 Trusted Browser Benchmark Summary",
    "",
    `Scenario count: ${sorted.length}.`,
    "",
    "## Results",
    "",
    "| Case | Mode | Viewport | FPS avg | 1% low | p95 ms | >100ms | Long tasks | HUD/s | Minimap/s | Fog/s | Labels | Lume | DOM |",
    "| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...sorted.map((result) => {
      const metrics = result.steadyState;
      return `| ${result.caseId} | ${result.environment.executionMode} | ${result.environment.viewport} | ${metrics.fpsAverage} | ${metrics.fpsOnePercentLow} | ${metrics.frameTimeMs.p95} | ${metrics.frameTimeMs.over100} | ${metrics.longTasks.count} | ${metrics.ratesPerSecond.hudUpdates} | ${metrics.ratesPerSecond.minimapRefreshes} | ${metrics.ratesPerSecond.fogRedraws} | ${metrics.counters.labels} | ${metrics.counters.lumeLinks} | ${metrics.counters.domNodes} |`;
    }),
    ""
  ].join("\n");
}

export function renderExecutionModeComparisonMarkdown(results: TrustedBenchmarkResult[]): string {
  const rows = results.filter((result) => result.caseId.includes("mode") || result.caseId === "baseline");
  return [
    "# v0.109 Execution Mode Comparison",
    "",
    "Production preview is the primary automated evidence lane. Dev-server results are secondary; headed/manual evidence is local-only when available.",
    "",
    "| Case | Mode | Visibility | Viewport | User agent | Overlay | Warm-up | Sample | FPS avg | p95 ms |",
    "| --- | --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |",
    ...rows.map(
      (result) =>
        `| ${result.caseId} | ${TRUSTED_EXECUTION_MODE_LABELS[result.environment.executionMode]} | ${result.environment.visibilityState} | ${result.environment.viewport} | ${compactUserAgent(result.environment.userAgent)} | ${result.environment.profilerOverlayEnabled ? "on" : "off"} | ${result.environment.warmupMs} | ${result.environment.sampleMs} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} |`
    ),
    ""
  ].join("\n");
}

export function renderRootCauseMatrixMarkdown(results: TrustedBenchmarkResult[]): string {
  const baseline = results.find((result) => result.caseId === "baseline");
  return [
    "# v0.109 Root-Cause Matrix Report",
    "",
    "All rows are private/session-only diagnostic comparisons. They do not change saves, gameplay rules, combat balance, fog simulation, capture logic, stable IDs, art, or public posture.",
    "",
    "| Case | Focus | FPS avg | p95 ms | p95 delta | HUD/s | Minimap/s | Fog/s | Notifications/s | DOM | Note |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |",
    ...results.map((result) => {
      const definition = TRUSTED_ROOT_CAUSE_CASES.find((entry) => entry.id === result.caseId);
      const p95Delta = baseline ? roundMetric(result.steadyState.frameTimeMs.p95 - baseline.steadyState.frameTimeMs.p95) : 0;
      return `| ${result.caseId} | ${definition?.compareFocus ?? result.title} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} | ${p95Delta} | ${result.steadyState.ratesPerSecond.hudUpdates} | ${result.steadyState.ratesPerSecond.minimapRefreshes} | ${result.steadyState.ratesPerSecond.fogRedraws} | ${result.steadyState.ratesPerSecond.notificationsEmitted} | ${result.steadyState.counters.domNodes} | ${diagnosticNote(result, baseline)} |`;
    }),
    "",
    "## Interpretation",
    "",
    classifyEarlierEvidence(results),
    ""
  ].join("\n");
}

export function renderEvidenceBackedOptimizationMarkdown(results: TrustedBenchmarkResult[]): string {
  const sortedCosts = [...results]
    .filter((result) => result.caseId !== "overlays-enabled")
    .sort((left, right) => right.steadyState.frameTimeMs.p95 - left.steadyState.frameTimeMs.p95)
    .slice(0, 3);
  return [
    "# v0.109 Evidence-Backed Optimization Report",
    "",
    "## Top Genuine Cost Signals",
    "",
    ...sortedCosts.map(
      (result, index) =>
        `${index + 1}. ${result.caseId}: p95 ${result.steadyState.frameTimeMs.p95} ms, FPS avg ${result.steadyState.fpsAverage}, DOM ${result.steadyState.counters.domNodes}, HUD ${result.steadyState.ratesPerSecond.hudUpdates}/s, minimap ${result.steadyState.ratesPerSecond.minimapRefreshes}/s.`
    ),
    "",
    "## Probable Harness Artifacts",
    "",
    "- The previous 1200 ms window was too short for stable FPS claims.",
    "- The previous v0.108 lane used dev-server headless sampling and a visible profiler panel.",
    "- Launch, action, and Results transition work are now separated from steady-state frame scoring.",
    "",
    "## Optimizations Applied",
    "",
    "- Replaced the automated benchmark protocol with production-preview-first warm-up plus steady-state sampling.",
    "- Kept profiler overlay off by default during trusted samples and measured overlay-on separately.",
    "- Added private session-only diagnostic reductions for labels, rings, Lume visibility, minimap refresh, fog redraw, HUD density, notifications, and profiler overlay so costs can be isolated without changing gameplay.",
    "",
    "## Deferred",
    "",
    "- Broader rendering or engine work remains deferred for a separate reviewed goal.",
    ""
  ].join("\n");
}

export function renderManualBenchmarkGuideMarkdown(): string {
  return [
    "# v0.109 Manual Benchmark Guide",
    "",
    "Open the private Playtest Hub, scroll to Performance Lab, and use RUN TRUSTED MANUAL BENCHMARK.",
    "",
    "The flow is private-only and no-save. It guides Tier M representative launch, five-second warm-up, ten-second sample, hero selection, minimap click, Lume Hidden/Auto/Always toggles, Results transition, export, and return to hub.",
    "",
    "The in-app export is a copyable/downloadable local report. It does not require console usage.",
    ""
  ].join("\n");
}

export function renderImplementationReportMarkdown(results: TrustedBenchmarkResult[]): string {
  return [
    "# v0.109 Implementation Report",
    "",
    "Status: implemented as a private benchmark-integrity and root-cause isolation checkpoint.",
    "",
    "## Implemented",
    "",
    "- Added a trusted benchmark protocol with launch, settle, steady-state, interaction, and report phases.",
    "- Added production-preview and dev-server trusted benchmark scripts.",
    "- Added private Playtest Hub manual benchmark flow.",
    "- Added private battle-session diagnostic toggles for root-cause isolation.",
    "- Added ignored v0.109 artifact outputs under artifacts/performance/v0109/.",
    "",
    "## Boundary",
    "",
    "No save-version bump, save fields, localStorage keys, stable IDs, gameplay rules, rewards, XP, Retinue state, campaign progression, balance, AI/pathing rules, maps, factions, generated/imported art, runtime asset paths, engine choice, desktop port, multiplayer, PvP, or co-op are added.",
    "",
    "## Current Result Count",
    "",
    `Trusted result rows available: ${results.length}.`,
    ""
  ].join("\n");
}

export function renderVisualQaReportMarkdown(): string {
  return [
    "# v0.109 Visual QA Report",
    "",
    "Visual QA adds trusted manual benchmark and private diagnostic-toggle screenshots. The captures are private QA evidence only and do not introduce public controls.",
    "",
    "Required states: intro, warm-up, steady-state, interaction, export summary, diagnostic collapsed/expanded, labels hidden, rings minimal, Lume Hidden/Auto/Always, minimap reduced/paused, fog redraw reduced, HUD Minimal/Standard/Debug, notifications suppressed, overlay off/on, root-cause baseline, overlays minimized/enabled, and 1920x1080/1600x900/1366x768.",
    ""
  ].join("\n");
}

export function renderEmmanuelRetestChecklistMarkdown(): string {
  return [
    "# v0.109 Emmanuel Retest Checklist",
    "",
    "1. Open the private playtest package through the included local server.",
    "2. Enter Playtest Hub -> Performance Lab.",
    "3. Run TRUSTED MANUAL BENCHMARK.",
    "4. Confirm the flow states no save, reward, or progression changes.",
    "5. Confirm warm-up, steady-state sample, interaction, Lume toggles, Results transition, export summary, and return-to-hub all work without console usage.",
    "6. In a representative battle, expand Diagnostic Toggles and confirm every toggle is labeled non-production/private.",
    "7. Confirm ordinary campaign and Tutorial play remain unchanged.",
    "8. Confirm v0.110, desktop engine selection, art generation/import, and engine porting have not started.",
    ""
  ].join("\n");
}

export function renderDeferredEngineSpikePreparationMarkdown(): string {
  return [
    "# v0.109 Deferred Engine Spike Preparation",
    "",
    "This checkpoint does not choose an engine, start a desktop port, create a wrapper project, generate art, import art, or begin v0.110.",
    "",
    "Future engine-spike preparation must wait for Emmanuel's review and a separately supplied goal.",
    ""
  ].join("\n");
}

export function createManualBenchmarkTemplate() {
  return {
    schemaVersion: 1,
    checkpoint: V0109_CHECKPOINT,
    title: V0109_TITLE,
    flow: [
      "Launch Tier M representative scenario",
      "Warm up for five seconds",
      "Sample for ten seconds",
      "Select hero",
      "Click minimap",
      "Toggle Lume Hidden, Auto, Always",
      "Open Results transition sample",
      "Export report",
      "Return to hub"
    ],
    saveIsolationRule: "Private manual benchmark only. No save, reward, progression, localStorage, stable-ID, XP, Retinue, relic, or campaign mutation.",
    reportPath: `${V0109_ARTIFACT_DIR}/manual-benchmark-template.json`
  };
}

function rootCauseCase(
  id: string,
  title: string,
  scenarioId: TrustedBenchmarkScenarioId,
  options: {
    diagnostics?: Partial<TrustedBenchmarkDiagnostics>;
    executionMode?: TrustedExecutionMode;
    viewport?: string;
    compareFocus: string;
    localOnly?: boolean;
  }
): TrustedRootCauseCase {
  return {
    id,
    title,
    scenarioId,
    executionMode: options.executionMode ?? "production-preview-headless",
    viewport: options.viewport ?? "1600x900",
    diagnostics: normalizeTrustedDiagnostics(options.diagnostics),
    compareFocus: options.compareFocus,
    localOnly: Boolean(options.localOnly)
  };
}

function finding(
  item: string,
  findingText: string,
  risk: ProfilerMethodAuditFinding["risk"],
  v0109Response: string
): ProfilerMethodAuditFinding {
  return { item, finding: findingText, risk, v0109Response };
}

function percentile(sortedValues: number[], percentileValue: number): number {
  if (sortedValues.length === 0) {
    return 0;
  }
  const index = Math.min(sortedValues.length - 1, Math.max(0, Math.ceil(sortedValues.length * percentileValue) - 1));
  return sortedValues[index];
}

function onePercentLowFps(frameTimes: number[]): number {
  if (frameTimes.length === 0) {
    return 0;
  }
  const sorted = [...frameTimes].sort((left, right) => right - left);
  const count = Math.max(1, Math.ceil(sorted.length * 0.01));
  const slowestAverage = sorted.slice(0, count).reduce((total, value) => total + value, 0) / count;
  return slowestAverage > 0 ? 1000 / slowestAverage : 0;
}

function countOver(values: number[], threshold: number): number {
  return values.filter((value) => value > threshold).length;
}

function counterDeltas(
  after: PrivatePerformanceCounters,
  before: PrivatePerformanceCounters
): Partial<PrivatePerformanceCounters> {
  return {
    fogRedraws: Math.max(0, after.fogRedraws - before.fogRedraws),
    minimapRefreshes: Math.max(0, after.minimapRefreshes - before.minimapRefreshes),
    hudUpdates: Math.max(0, after.hudUpdates - before.hudUpdates),
    notificationsEmitted: Math.max(0, after.notificationsEmitted - before.notificationsEmitted)
  };
}

function counterRate(value: number | undefined, durationSeconds: number): number {
  return roundMetric(Math.max(0, value ?? 0) / durationSeconds);
}

function diagnosticNote(result: TrustedBenchmarkResult, baseline?: TrustedBenchmarkResult): string {
  if (!baseline || result.caseId === baseline.caseId) {
    return "baseline";
  }
  const delta = result.steadyState.frameTimeMs.p95 - baseline.steadyState.frameTimeMs.p95;
  if (delta <= -50) {
    return "lower p95 than baseline";
  }
  if (delta >= 50) {
    return "higher p95 than baseline";
  }
  return "similar p95";
}

function classifyEarlierEvidence(results: TrustedBenchmarkResult[]): string {
  const baseline = results.find((result) => result.caseId === "baseline");
  if (!baseline) {
    return "No trusted baseline is available yet; earlier 2-3 FPS evidence remains unresolved.";
  }
  if (baseline.steadyState.fpsAverage >= 20 && baseline.steadyState.frameTimeMs.p95 < 100) {
    return "Earlier 2-3 FPS evidence is primarily distorted by harness methodology for the trusted baseline, though root-cause rows should still be used for relative cost signals.";
  }
  if (baseline.steadyState.fpsAverage < 10 || baseline.steadyState.frameTimeMs.p95 >= 250) {
    return "Trusted evidence still shows serious browser lag in the baseline; treat the earlier evidence as mixed with real runtime cost, not merely artifact.";
  }
  return "Trusted evidence improves on the 2-3 FPS report but still shows measurable browser cost; treat the earlier evidence as mixed.";
}

function compactUserAgent(userAgent: string): string {
  return userAgent.length > 68 ? `${userAgent.slice(0, 65)}...` : userAgent;
}

function roundMetric(value: number): number {
  return Number((Number.isFinite(value) ? value : 0).toFixed(2));
}
