export interface PrivatePerformanceCounters {
  displayObjects: number;
  graphicsObjects: number;
  units: number;
  buildings: number;
  captureSites: number;
  labels: number;
  captureRings: number;
  lumeLinks: number;
  lumeEndpoints: number;
  fogRedraws: number;
  fogVisibleCells: number;
  minimapRefreshes: number;
  hudUpdates: number;
  notificationsEmitted: number;
  notificationsVisible: number;
  domNodes: number;
  memoryUsedMb?: number;
}

export interface PrivatePerformanceSample {
  atMs: number;
  frameMs: number;
  counters: PrivatePerformanceCounters;
}

export interface PrivatePerformanceLongTask {
  atMs: number;
  durationMs: number;
}

export interface PrivatePerformanceSummary {
  scenarioId: string;
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
  };
  longTasks: {
    supported: boolean;
    count: number;
    totalDurationMs: number;
    maxDurationMs: number;
  };
  latestCounters: PrivatePerformanceCounters;
  ratesPerSecond: {
    fogRedraws: number;
    minimapRefreshes: number;
    hudUpdates: number;
    notificationsEmitted: number;
  };
}

export interface PrivatePerformanceScenarioManifestEntry {
  id: string;
  title: string;
  group: "battle" | "lume" | "campaign" | "results";
  launchScenarioId: string;
  purpose: string;
  expectedVisibleUi: string[];
  evidenceFocus: string[];
  saveIsolationRule: string;
}

export const V0103_PERFORMANCE_SCENARIOS: PrivatePerformanceScenarioManifestEntry[] = [
  performanceScenario(
    "perf_battle_baseline",
    "Ordinary battle baseline",
    "battle",
    "perf_battle_baseline",
    "Measures the normal private battle opening without special selection pressure.",
    ["battle-hud", "battle-minimap"],
    ["frame timing", "HUD count", "minimap count"]
  ),
  performanceScenario("perf_campaign_map_interaction", "Campaign-map interaction", "campaign", "perf_campaign_map_interaction", "Measures campaign shell DOM posture using existing private hub campaign preview.", ["campaign-map", "campaign-selected-panel"], ["DOM nodes"]),
  performanceScenario("perf_fog_heavy_camera", "Fog-heavy camera", "battle", "perf_fog_heavy_camera", "Centers a fog-heavy battlefield view.", ["battle-minimap", "battle-objectives"], ["fog visible cells", "fog redraws"]),
  performanceScenario("perf_label_heavy_site_cluster", "Label-heavy site cluster", "battle", "perf_label_heavy_site_cluster", "Centers resource-site label and capture-ring pressure.", ["battle-resource-sites", "battle-minimap"], ["capture rings", "labels"]),
  performanceScenario("perf_large_unit_cluster", "Large existing unit cluster", "battle", "perf_large_unit_cluster", "Uses existing units only to measure a denser local cluster.", ["selection-side-panel"], ["units", "display objects"]),
  performanceScenario("perf_lume_activation_pulse", "Lume first activation pulse", "lume", "perf_lume_activation_pulse", "Measures short activation-pulse posture.", ["lume-links-progress"], ["lume links", "graphics objects"]),
  performanceScenario("perf_lume_always", "Lume Always", "lume", "perf_lume_always", "Measures explicit inspection overlay posture.", ["lume-visibility-controls"], ["lume links", "lume endpoints"]),
  performanceScenario("perf_lume_auto", "Lume Auto", "lume", "perf_lume_auto", "Measures conservative Auto Lume overlay posture.", ["lume-network-status"], ["lume links", "lume endpoints"]),
  performanceScenario("perf_lume_contested_severed", "Lume contested/severed transition", "lume", "perf_lume_contested_severed", "Measures Lume transition pulse posture.", ["lume-network-status"], ["lume links", "notifications"]),
  performanceScenario("perf_lume_hidden", "Lume Hidden", "lume", "perf_lume_hidden", "Measures hidden Lume overlay posture.", ["lume-visibility-controls"], ["lume links", "lume endpoints"]),
  performanceScenario("perf_minimap_interaction", "Minimap interaction sample", "battle", "perf_minimap_interaction", "Measures minimap marker and ping posture.", ["battle-minimap"], ["minimap refreshes", "DOM nodes"]),
  performanceScenario("perf_notification_heavy", "Notification-heavy sample", "battle", "perf_notification_heavy", "Measures deduped routine and important notification posture.", ["battle-status"], ["notifications emitted", "notifications visible"]),
  performanceScenario("perf_results_disclosure", "Results disclosure sample", "results", "perf_results_disclosure", "Measures compact Results and details disclosure posture.", ["results-overview", "results-full-details"], ["DOM nodes"]),
  performanceScenario("perf_selected_command_hall", "Selected Command Hall", "battle", "perf_selected_command_hall", "Measures selected building production/rally UI posture.", ["selection-side-panel", "command-panel"], ["HUD updates", "DOM nodes"]),
  performanceScenario("perf_selected_hero", "Selected hero", "battle", "perf_selected_hero", "Measures hero panel and ability summary posture.", ["battle-hero-panel", "selection-side-panel"], ["HUD updates", "labels"]),
  performanceScenario("perf_selected_squad", "Selected squad", "battle", "perf_selected_squad", "Measures multi-select panel and group summary posture.", ["selection-side-panel", "unit-order-summary"], ["display objects", "labels"]),
  performanceScenario("perf_selected_worker", "Selected Worker", "battle", "perf_selected_worker", "Measures Worker command and utility panel posture.", ["selection-side-panel", "command-panel"], ["HUD updates", "command panel"])
];

export const V0104_PERFORMANCE_SCENARIOS: PrivatePerformanceScenarioManifestEntry[] = sortPerformanceScenarios([
  ...V0103_PERFORMANCE_SCENARIOS,
  performanceScenario(
    "perf_hud_debug",
    "HUD Debug density",
    "battle",
    "perf_hud_debug",
    "Measures the private debug density with rendering counters visible.",
    ["battle-hud-density-debug", "battle-hud-debug-counters"],
    ["HUD updates", "DOM nodes", "debug counters"]
  ),
  performanceScenario(
    "perf_hud_minimal",
    "HUD Minimal density",
    "battle",
    "perf_hud_minimal",
    "Measures the public minimal battle HUD posture with optional detail copy hidden.",
    ["battle-hud-density-minimal", "battle-hud", "battle-minimap"],
    ["HUD updates", "DOM nodes", "command panel"]
  ),
  performanceScenario(
    "perf_hud_standard",
    "HUD Standard density",
    "battle",
    "perf_hud_standard",
    "Measures the private standard density used for full detail review.",
    ["battle-hud-density-standard", "hud-density-controls", "selection-side-panel"],
    ["HUD updates", "DOM nodes", "detail surfaces"]
  )
]);

type CounterProvider = () => Partial<PrivatePerformanceCounters>;

const DEFAULT_COUNTERS: PrivatePerformanceCounters = {
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
};

let counterProvider: CounterProvider | undefined;
let singleton: PrivatePerformanceProfiler | undefined;

declare global {
  interface Window {
    __ASCENDANT_PERFORMANCE_PROFILER__?: PrivatePerformanceProfilerPublicApi;
  }
}

export interface PrivatePerformanceProfilerPublicApi {
  start: (scenarioId?: string) => void;
  stop: () => PrivatePerformanceSummary;
  toggle: () => boolean;
  exportSummary: () => PrivatePerformanceSummary;
  isActive: () => boolean;
  sampleCount: () => number;
}

export function defaultPerformanceCounters(): PrivatePerformanceCounters {
  return { ...DEFAULT_COUNTERS };
}

export function registerPrivatePerformanceCounterProvider(provider: CounterProvider | undefined): void {
  counterProvider = provider;
}

export function installPrivatePerformanceProfiler(options: { enabled: boolean; defaultScenarioId?: string }):
  | PrivatePerformanceProfiler
  | undefined {
  if (!options.enabled || typeof document === "undefined") {
    return undefined;
  }
  if (!singleton) {
    singleton = new PrivatePerformanceProfiler(options.defaultScenarioId ?? "manual_private_review");
  }
  return singleton;
}

export function summarizePerformanceSamples(options: {
  scenarioId: string;
  samples: PrivatePerformanceSample[];
  longTasks?: PrivatePerformanceLongTask[];
  longTaskSupported?: boolean;
}): PrivatePerformanceSummary {
  const samples = [...options.samples].sort((left, right) => left.atMs - right.atMs);
  const frameTimes = samples.map((sample) => sample.frameMs).filter((value) => Number.isFinite(value) && value >= 0);
  const sampleDurationMs = samples.length > 1 ? samples.at(-1)!.atMs - samples[0].atMs : 0;
  const latestCounters = samples.at(-1)?.counters ?? defaultPerformanceCounters();
  const firstCounters = samples[0]?.counters ?? latestCounters;
  const durationSeconds = Math.max(0.001, sampleDurationMs / 1000);
  const longTasks = options.longTasks ?? [];
  const sortedFrameTimes = [...frameTimes].sort((left, right) => left - right);
  return {
    scenarioId: options.scenarioId,
    sampleDurationMs: roundMetric(sampleDurationMs),
    sampleCount: samples.length,
    fpsAverage: roundMetric(averageFps(frameTimes)),
    fpsOnePercentLow: roundMetric(onePercentLowFps(frameTimes)),
    frameTimeMs: {
      p50: roundMetric(percentile(sortedFrameTimes, 0.5)),
      p95: roundMetric(percentile(sortedFrameTimes, 0.95)),
      p99: roundMetric(percentile(sortedFrameTimes, 0.99)),
      max: roundMetric(sortedFrameTimes.at(-1) ?? 0),
      over16_7: frameTimes.filter((value) => value > 16.7).length,
      over33_3: frameTimes.filter((value) => value > 33.3).length,
      over50: frameTimes.filter((value) => value > 50).length
    },
    longTasks: {
      supported: Boolean(options.longTaskSupported),
      count: longTasks.length,
      totalDurationMs: roundMetric(longTasks.reduce((total, task) => total + task.durationMs, 0)),
      maxDurationMs: roundMetric(Math.max(0, ...longTasks.map((task) => task.durationMs)))
    },
    latestCounters,
    ratesPerSecond: {
      fogRedraws: roundMetric((latestCounters.fogRedraws - firstCounters.fogRedraws) / durationSeconds),
      minimapRefreshes: roundMetric((latestCounters.minimapRefreshes - firstCounters.minimapRefreshes) / durationSeconds),
      hudUpdates: roundMetric((latestCounters.hudUpdates - firstCounters.hudUpdates) / durationSeconds),
      notificationsEmitted: roundMetric((latestCounters.notificationsEmitted - firstCounters.notificationsEmitted) / durationSeconds)
    }
  };
}

export function renderPerformanceSummaryMarkdown(
  summaries: PrivatePerformanceSummary[],
  options: { checkpoint?: string; title?: string } = {}
): string {
  const checkpoint = options.checkpoint ?? "v0.104";
  const sorted = [...summaries].sort((left, right) => left.scenarioId.localeCompare(right.scenarioId));
  const slowest = [...sorted].sort((left, right) => right.frameTimeMs.p95 - left.frameTimeMs.p95).slice(0, 3);
  const lines = [
    `# ${options.title ?? `${checkpoint} Private Performance Summary`}`,
    "",
    "This report is deterministic private-QA evidence. It is not cross-machine benchmark proof and does not claim human fun data.",
    "",
    "## Top Cost Signals",
    "",
    ...slowest.map(
      (summary, index) =>
        `${index + 1}. ${summary.scenarioId}: p95 ${summary.frameTimeMs.p95} ms, max ${summary.frameTimeMs.max} ms, HUD ${summary.ratesPerSecond.hudUpdates}/s, minimap ${summary.ratesPerSecond.minimapRefreshes}/s.`
    ),
    "",
    "## Scenario Results",
    "",
    "| Scenario | Samples | FPS avg | 1% low | p95 ms | >33.3ms | Long tasks | HUD/s | Minimap/s | Lume links | DOM nodes |",
    "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...sorted.map(
      (summary) =>
        `| ${summary.scenarioId} | ${summary.sampleCount} | ${summary.fpsAverage} | ${summary.fpsOnePercentLow} | ${summary.frameTimeMs.p95} | ${summary.frameTimeMs.over33_3} | ${summary.longTasks.count} | ${summary.ratesPerSecond.hudUpdates} | ${summary.ratesPerSecond.minimapRefreshes} | ${summary.latestCounters.lumeLinks} | ${summary.latestCounters.domNodes} |`
    ),
    ""
  ];
  return `${lines.join("\n")}\n`;
}

export function renderPerformanceDeltaMarkdown(
  currentSummaries: PrivatePerformanceSummary[],
  baselineSummaries: PrivatePerformanceSummary[],
  options: { checkpoint?: string; baselineCheckpoint?: string } = {}
): string {
  const checkpoint = options.checkpoint ?? "v0.104";
  const baselineCheckpoint = options.baselineCheckpoint ?? "v0.103";
  const baselineById = new Map(baselineSummaries.map((summary) => [summary.scenarioId, summary]));
  const sorted = [...currentSummaries].sort((left, right) => left.scenarioId.localeCompare(right.scenarioId));
  const matched = sorted.filter((summary) => baselineById.has(summary.scenarioId));
  const newOnly = sorted.filter((summary) => !baselineById.has(summary.scenarioId));
  const lines = [
    `# ${checkpoint} Private Performance Delta`,
    "",
    `Compares ${checkpoint} private profiler output against the committed ${baselineCheckpoint} artifacts when scenario IDs match. This is local deterministic QA evidence, not cross-machine benchmark proof.`,
    "",
    "## Matching Scenarios",
    "",
    "| Scenario | v0.103 p95 ms | v0.104 p95 ms | Delta ms | v0.103 DOM | v0.104 DOM | HUD/s delta | Minimap/s delta |",
    "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...matched.map((current) => {
      const baseline = baselineById.get(current.scenarioId)!;
      return `| ${current.scenarioId} | ${baseline.frameTimeMs.p95} | ${current.frameTimeMs.p95} | ${roundMetric(
        current.frameTimeMs.p95 - baseline.frameTimeMs.p95
      )} | ${baseline.latestCounters.domNodes} | ${current.latestCounters.domNodes} | ${roundMetric(
        current.ratesPerSecond.hudUpdates - baseline.ratesPerSecond.hudUpdates
      )} | ${roundMetric(current.ratesPerSecond.minimapRefreshes - baseline.ratesPerSecond.minimapRefreshes)} |`;
    }),
    "",
    "## v0.104-Only Scenarios",
    "",
    newOnly.length > 0
      ? newOnly
          .map(
            (summary) =>
              `- ${summary.scenarioId}: p95 ${summary.frameTimeMs.p95} ms, HUD ${summary.ratesPerSecond.hudUpdates}/s, minimap ${summary.ratesPerSecond.minimapRefreshes}/s, DOM ${summary.latestCounters.domNodes}.`
          )
          .join("\n")
      : "- None.",
    ""
  ];
  return `${lines.join("\n")}\n`;
}

export class PrivatePerformanceProfiler implements PrivatePerformanceProfilerPublicApi {
  private readonly button: HTMLButtonElement;
  private readonly panel: HTMLElement;
  private active = false;
  private scenarioId: string;
  private samples: PrivatePerformanceSample[] = [];
  private longTasks: PrivatePerformanceLongTask[] = [];
  private longTaskSupported = false;
  private frameRequest = 0;
  private startedAt = 0;
  private lastFrameAt = 0;
  private lastPanelRefreshAt = 0;
  private observer?: PerformanceObserver;
  private readonly keyHandler: (event: KeyboardEvent) => void;

  constructor(defaultScenarioId: string) {
    this.scenarioId = defaultScenarioId;
    this.button = document.createElement("button");
    this.button.type = "button";
    this.button.className = "private-performance-toggle";
    this.button.dataset.testid = "private-performance-toggle";
    this.button.textContent = "Perf F8";
    this.button.addEventListener("click", () => this.toggle());

    this.panel = document.createElement("aside");
    this.panel.className = "private-performance-panel";
    this.panel.dataset.testid = "private-performance-panel";
    this.panel.hidden = true;

    document.body.append(this.button, this.panel);
    this.keyHandler = (event) => {
      if (event.key !== "F8") {
        return;
      }
      event.preventDefault();
      this.toggle();
    };
    window.addEventListener("keydown", this.keyHandler);
    window.__ASCENDANT_PERFORMANCE_PROFILER__ = this;
  }

  start(scenarioId = this.scenarioId): void {
    this.scenarioId = scenarioId;
    this.samples = [];
    this.longTasks = [];
    this.startedAt = performance.now();
    this.lastFrameAt = this.startedAt;
    this.lastPanelRefreshAt = this.startedAt;
    this.active = true;
    this.panel.hidden = false;
    this.button.textContent = "Perf On";
    this.installLongTaskObserver();
    this.frameRequest = requestAnimationFrame((time) => this.recordFrame(time));
    this.renderPanel();
  }

  stop(): PrivatePerformanceSummary {
    this.active = false;
    this.button.textContent = "Perf F8";
    if (this.frameRequest) {
      cancelAnimationFrame(this.frameRequest);
      this.frameRequest = 0;
    }
    this.observer?.disconnect();
    this.observer = undefined;
    const summary = this.exportSummary();
    this.renderPanel(summary);
    return summary;
  }

  toggle(): boolean {
    if (this.active) {
      this.stop();
      return false;
    }
    this.start(this.scenarioId);
    return true;
  }

  exportSummary(): PrivatePerformanceSummary {
    return summarizePerformanceSamples({
      scenarioId: this.scenarioId,
      samples: this.samples,
      longTasks: this.longTasks,
      longTaskSupported: this.longTaskSupported
    });
  }

  isActive(): boolean {
    return this.active;
  }

  sampleCount(): number {
    return this.samples.length;
  }

  destroy(): void {
    this.stop();
    this.button.remove();
    this.panel.remove();
    window.removeEventListener("keydown", this.keyHandler);
    if (window.__ASCENDANT_PERFORMANCE_PROFILER__ === this) {
      delete window.__ASCENDANT_PERFORMANCE_PROFILER__;
    }
  }

  private recordFrame(time: number): void {
    if (!this.active) {
      return;
    }
    const frameMs = time - this.lastFrameAt;
    this.lastFrameAt = time;
    this.samples.push({
      atMs: roundMetric(time - this.startedAt),
      frameMs: roundMetric(frameMs),
      counters: collectCounters()
    });
    if (this.samples.length > 900) {
      this.samples.shift();
    }
    if (time - this.lastPanelRefreshAt >= 500) {
      this.lastPanelRefreshAt = time;
      this.renderPanel();
    }
    this.frameRequest = requestAnimationFrame((nextTime) => this.recordFrame(nextTime));
  }

  private installLongTaskObserver(): void {
    this.longTaskSupported = false;
    this.observer?.disconnect();
    if (typeof PerformanceObserver === "undefined") {
      return;
    }
    try {
      this.observer = new PerformanceObserver((list) => {
        list.getEntries().forEach((entry) => {
          this.longTasks.push({
            atMs: roundMetric(entry.startTime - this.startedAt),
            durationMs: roundMetric(entry.duration)
          });
        });
      });
      this.observer.observe({ entryTypes: ["longtask"] });
      this.longTaskSupported = true;
    } catch {
      this.longTaskSupported = false;
    }
  }

  private renderPanel(summary = this.exportSummary()): void {
    this.panel.innerHTML = `
      <div class="private-performance-header">
        <strong>Private Profiler</strong>
        <span>${escapeHtml(summary.scenarioId)}</span>
      </div>
      <div class="private-performance-grid">
        <span>FPS</span><b>${summary.fpsAverage}</b>
        <span>1% low</span><b>${summary.fpsOnePercentLow}</b>
        <span>p95</span><b>${summary.frameTimeMs.p95} ms</b>
        <span>>33ms</span><b>${summary.frameTimeMs.over33_3}</b>
        <span>HUD/s</span><b>${summary.ratesPerSecond.hudUpdates}</b>
        <span>Minimap/s</span><b>${summary.ratesPerSecond.minimapRefreshes}</b>
        <span>Lume</span><b>${summary.latestCounters.lumeLinks}/${summary.latestCounters.lumeEndpoints}</b>
        <span>DOM</span><b>${summary.latestCounters.domNodes}</b>
      </div>
      <small>F8 toggles. Private/dev only. Off means no rAF samples or long-task observer.</small>
    `;
  }
}

function collectCounters(): PrivatePerformanceCounters {
  const domNodes = typeof document === "undefined" ? 0 : document.querySelectorAll("*").length;
  const memory = readMemoryUsedMb();
  return {
    ...DEFAULT_COUNTERS,
    ...counterProvider?.(),
    domNodes,
    ...(memory === undefined ? {} : { memoryUsedMb: memory })
  };
}

function readMemoryUsedMb(): number | undefined {
  const perf = performance as Performance & { memory?: { usedJSHeapSize?: number } };
  const used = perf.memory?.usedJSHeapSize;
  return typeof used === "number" ? roundMetric(used / 1024 / 1024) : undefined;
}

function performanceScenario(
  id: string,
  title: string,
  group: PrivatePerformanceScenarioManifestEntry["group"],
  launchScenarioId: string,
  purpose: string,
  expectedVisibleUi: string[],
  evidenceFocus: string[]
): PrivatePerformanceScenarioManifestEntry {
  return {
    id,
    title,
    group,
    launchScenarioId,
    purpose,
    expectedVisibleUi,
    evidenceFocus,
    saveIsolationRule:
      "Private Performance Lab only. Rewards, XP, campaign progress, Retinue, relics, reputation, saves, and localStorage are not mutated by the scenario launcher."
  };
}

function sortPerformanceScenarios(
  scenarios: PrivatePerformanceScenarioManifestEntry[]
): PrivatePerformanceScenarioManifestEntry[] {
  return [...scenarios].sort((left, right) => left.id.localeCompare(right.id));
}

function averageFps(frameTimes: number[]): number {
  if (frameTimes.length === 0) {
    return 0;
  }
  const averageFrame = frameTimes.reduce((total, value) => total + value, 0) / frameTimes.length;
  return averageFrame > 0 ? 1000 / averageFrame : 0;
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

function percentile(sortedValues: number[], percentileValue: number): number {
  if (sortedValues.length === 0) {
    return 0;
  }
  const index = Math.min(sortedValues.length - 1, Math.max(0, Math.ceil(sortedValues.length * percentileValue) - 1));
  return sortedValues[index];
}

function roundMetric(value: number): number {
  return Number((Number.isFinite(value) ? value : 0).toFixed(2));
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
