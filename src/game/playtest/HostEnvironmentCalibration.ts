import { TRUSTED_DEFAULT_SAMPLE_MS, TRUSTED_DEFAULT_WARMUP_MS, type TrustedSteadyStateMetrics } from "./TrustedBrowserBenchmark";

export const V0111_CHECKPOINT = "v0.111";
export const V0111_TITLE = "Host Environment Calibration, Clean-Browser Reproducibility, and Machine-Pressure Gate";
export const V0111_ARTIFACT_DIR = "artifacts/performance/v0111";
export const V0111_HOST_SNAPSHOT_ROOT = "artifacts/performance/host-snapshots";

export type HostPressureClassification =
  | "HOST_PRESSURE_LIKELY"
  | "HOST_PRESSURE_CONTRIBUTES"
  | "HOST_PRESSURE_UNCLEAR"
  | "HOST_PRESSURE_UNLIKELY";

export type GameCostClassification =
  | "BROWSER_ENVIRONMENT_DOMINANT"
  | "PHASER_BASELINE_DOMINANT"
  | "BATTLE_CODE_DOMINANT"
  | "MIXED"
  | "UNRESOLVED";

export type BrowserControlBaselineId =
  | "blank-page-raf"
  | "simple-dom"
  | "simple-canvas"
  | "phaser-empty-scene"
  | "campaign-map"
  | "tier-m-representative-battle";

export type BrowserControlCategory = "outside-game" | "phaser" | "game-shell" | "battle";
export type BrowserControlRunMode = "preview-headless" | "preview-headed" | "clean-profile-headless" | "clean-profile-headed";
export type BrowserControlLaunchTarget =
  | { type: "blank-page" }
  | { type: "simple-dom" }
  | { type: "simple-canvas" }
  | { type: "phaser-empty-scene" }
  | { type: "private-scenario"; scenarioId: "perf_campaign_map_interaction"; sceneKind: "campaign" }
  | { type: "private-scenario"; scenarioId: "benchmark_battle_tier_m_representative"; sceneKind: "battle" };

export interface BrowserControlDefinition {
  id: BrowserControlBaselineId;
  title: string;
  category: BrowserControlCategory;
  interpretation: string;
  usesGameRuntime: boolean;
  launchTarget: BrowserControlLaunchTarget;
  saveIsolationRule: string;
}

export interface HostSnapshot {
  schemaVersion: 1;
  checkpoint: typeof V0111_CHECKPOINT;
  title: typeof V0111_TITLE;
  generatedAtUtc: string;
  platform: {
    platform: string;
    osRelease: string;
    architecture: string;
    uptimeSeconds: number;
  };
  cpu: {
    model: string;
    logicalCores: number;
  };
  memory: {
    totalMb: number;
    freeMb: number;
    usedPercent: number;
  };
  nodeProcess: {
    nodeVersion: string;
    rssMb: number;
    heapUsedMb: number;
  };
  loadAverage: number[] | "unsupported";
  git: {
    commit: string;
    shortCommit: string;
    workingTreeClean: boolean;
  };
  browser: {
    browserName: "chromium";
    browserVersion: string;
    userAgent: string;
    viewport: string;
    headed: boolean;
    headless: boolean;
    serverMode: "none" | "preview" | "dev";
    visibilityState: DocumentVisibilityState | "unknown";
    cleanProfileMode: "none" | "temporary";
    extensionsDisabled: boolean;
    hardwareAccelerationPosture: string;
    recordingStatus: "unknown";
  };
  profilerCapabilities: {
    requestAnimationFrame: boolean;
    longTaskObserver: boolean;
    performanceMemory: boolean;
  };
  privacy: {
    browserHistoryCollected: false;
    openTabsCollected: false;
    profileContentsCollected: false;
    processCommandLinesCollected: false;
    personalFileNamesCollected: false;
  };
}

export interface TemporaryCleanProfilePosture {
  mode: "temporary";
  userProfileTouched: false;
  extensionsDisabled: true;
  profilePath: "[temporary-profile-redacted]";
  deletionStatus: "pending" | "deleted" | "ignored";
}

export interface BrowserControlBaselineResult {
  id: BrowserControlBaselineId;
  title: string;
  category: BrowserControlCategory;
  runMode: BrowserControlRunMode;
  generatedAtUtc: string;
  warmupMs: number;
  sampleMs: number;
  viewport: string;
  browserVersion: string;
  userAgent: string;
  visibilityState: DocumentVisibilityState | "unknown";
  cleanProfile: boolean;
  extensionsDisabled: boolean;
  hardwareAccelerationPosture: string;
  domNodes: number;
  hostSnapshotArtifact: string;
  rawFrameIntervalArtifact: string;
  steadyState: TrustedSteadyStateMetrics;
  saveBefore: string | null;
  saveAfter: string | null;
  saveMutationDetected: boolean;
}

export interface EnvironmentClassificationReport {
  checkpoint: typeof V0111_CHECKPOINT;
  title: typeof V0111_TITLE;
  generatedAtUtc: string;
  hostClassification: HostPressureClassification;
  gameCostClassification: GameCostClassification;
  confidence: "low" | "medium" | "high";
  evidenceRows: BrowserControlBaselineResult[];
  notes: string[];
}

export interface V0111PrivateHubAction {
  id: "host-snapshot" | "control-baselines" | "clean-profile" | "export-comparison" | "post-restart";
  testId: string;
  label: string;
  command?: string;
  privateOnly: true;
  saveSafe: true;
  description: string;
}

const SAVE_ISOLATION_RULE =
  "Private v0.111 Performance Lab only. No save, reward, XP, progression, Retinue, relic, reputation, stable-ID, localStorage, art, desktop, engine, gameplay, AI, pathing, or balance mutation is kept.";

export const V0111_BROWSER_CONTROL_BASELINES: BrowserControlDefinition[] = [
  control(
    "blank-page-raf",
    "Blank-page rAF baseline",
    "outside-game",
    "If this is slow, host or browser environment pressure is likely.",
    false,
    { type: "blank-page" }
  ),
  control(
    "simple-dom",
    "Simple DOM baseline",
    "outside-game",
    "If this is slow while blank is healthy, DOM/browser profile overhead contributes.",
    false,
    { type: "simple-dom" }
  ),
  control(
    "simple-canvas",
    "Simple canvas baseline",
    "outside-game",
    "If this is slow while DOM is healthy, canvas/browser rendering overhead contributes.",
    false,
    { type: "simple-canvas" }
  ),
  control(
    "phaser-empty-scene",
    "Phaser empty-scene baseline",
    "phaser",
    "If this is slow while simple canvas is healthy, Phaser/browser scene posture contributes.",
    false,
    { type: "phaser-empty-scene" }
  ),
  control(
    "campaign-map",
    "Campaign-map baseline",
    "game-shell",
    "If this is healthy while Tier M is slow, battle code remains the likely dominant cost.",
    true,
    { type: "private-scenario", scenarioId: "perf_campaign_map_interaction", sceneKind: "campaign" }
  ),
  control(
    "tier-m-representative-battle",
    "Tier M representative battle",
    "battle",
    "Compares the existing battle-code path against outside-game and Phaser controls.",
    true,
    { type: "private-scenario", scenarioId: "benchmark_battle_tier_m_representative", sceneKind: "battle" }
  )
];

export const V0111_PRIVATE_HUB_ACTIONS: V0111PrivateHubAction[] = [
  {
    id: "host-snapshot",
    testId: "v0111-host-snapshot",
    label: "Capture Host Snapshot",
    command: "npm run perf:host-snapshot",
    privateOnly: true,
    saveSafe: true,
    description: "Records safe host, browser, and profiler capability metadata without process command lines or profile contents."
  },
  {
    id: "control-baselines",
    testId: "v0111-control-baselines",
    label: "Run Browser Control Baselines",
    command: "npm run perf:controls:preview",
    privateOnly: true,
    saveSafe: true,
    description: "Compares blank, DOM, canvas, Phaser-empty, campaign-map, and Tier M browser timing."
  },
  {
    id: "clean-profile",
    testId: "v0111-clean-profile",
    label: "Run Clean-Profile Trusted Benchmark",
    command: "npm run perf:trusted:clean-profile",
    privateOnly: true,
    saveSafe: true,
    description: "Uses a temporary Chromium profile with extensions disabled, never the user browser profile."
  },
  {
    id: "export-comparison",
    testId: "v0111-export-comparison",
    label: "Export Environment Comparison",
    command: "npm run perf:controls:report",
    privateOnly: true,
    saveSafe: true,
    description: "Refreshes the machine-pressure classification and comparison docs from ignored artifacts."
  },
  {
    id: "post-restart",
    testId: "v0111-post-restart",
    label: "View Post-Restart Instructions",
    privateOnly: true,
    saveSafe: true,
    description: "Shows Emmanuel's manual restart-and-retest sequence without changing the machine."
  }
];

export function createCleanProfilePosture(deletionStatus: TemporaryCleanProfilePosture["deletionStatus"]): TemporaryCleanProfilePosture {
  return {
    mode: "temporary",
    userProfileTouched: false,
    extensionsDisabled: true,
    profilePath: "[temporary-profile-redacted]",
    deletionStatus
  };
}

export function redactSensitiveValue(value: string): string {
  if (/[A-Z]:\\Users\\/iu.test(value) || /\/Users\//u.test(value) || /AppData|browser|profile|temp-profile/iu.test(value)) {
    return "[redacted]";
  }
  return value;
}

export function createEnvironmentComparisonTemplate(options: { activeAction?: string; exportedAtUtc?: string } = {}): string {
  return JSON.stringify(
    {
      checkpoint: V0111_CHECKPOINT,
      title: V0111_TITLE,
      activeAction: options.activeAction ?? "none",
      exportedAtUtc: options.exportedAtUtc ?? "not-exported",
      commands: V0111_PRIVATE_HUB_ACTIONS.filter((action) => action.command).map((action) => ({
        label: action.label,
        command: action.command,
        privateOnly: action.privateOnly,
        saveSafe: action.saveSafe
      })),
      artifactRoots: {
        hostSnapshots: V0111_HOST_SNAPSHOT_ROOT,
        controls: V0111_ARTIFACT_DIR
      },
      safety: {
        noUserBrowserProfileMutation: true,
        noProcessCommandLines: true,
        noBrowserHistory: true,
        noOpenTabs: true,
        noSaveWrites: true,
        noV0112: true
      }
    },
    null,
    2
  );
}

export function classifyEnvironment(results: BrowserControlBaselineResult[]): EnvironmentClassificationReport {
  const blank = resultById(results, "blank-page-raf");
  const dom = resultById(results, "simple-dom");
  const canvas = resultById(results, "simple-canvas");
  const phaser = resultById(results, "phaser-empty-scene");
  const campaign = resultById(results, "campaign-map");
  const battle = resultById(results, "tier-m-representative-battle");

  const hostClassification = classifyHostPressure(blank, dom, canvas);
  const gameCostClassification = classifyGameCost(blank, canvas, phaser, campaign, battle);
  const evidenceCount = [blank, dom, canvas, phaser, campaign, battle].filter(Boolean).length;
  return {
    checkpoint: V0111_CHECKPOINT,
    title: V0111_TITLE,
    generatedAtUtc: new Date().toISOString(),
    hostClassification,
    gameCostClassification,
    confidence: evidenceCount >= 6 ? "high" : evidenceCount >= 3 ? "medium" : "low",
    evidenceRows: results,
    notes: classificationNotes(hostClassification, gameCostClassification)
  };
}

export function renderHostSnapshotMarkdown(snapshot: HostSnapshot): string {
  return [
    "# v0.111 Host Snapshot",
    "",
    `Generated: ${snapshot.generatedAtUtc}`,
    `Commit: ${snapshot.git.commit}`,
    `Working tree clean: ${snapshot.git.workingTreeClean ? "yes" : "no"}`,
    "",
    "## Host",
    "",
    `- Platform: ${snapshot.platform.platform} ${snapshot.platform.osRelease} ${snapshot.platform.architecture}`,
    `- Uptime seconds: ${snapshot.platform.uptimeSeconds}`,
    `- CPU: ${snapshot.cpu.model} (${snapshot.cpu.logicalCores} logical cores)`,
    `- Memory: ${snapshot.memory.usedPercent}% used (${snapshot.memory.freeMb} MB free of ${snapshot.memory.totalMb} MB)`,
    `- Node: ${snapshot.nodeProcess.nodeVersion}, RSS ${snapshot.nodeProcess.rssMb} MB, heap ${snapshot.nodeProcess.heapUsedMb} MB`,
    "",
    "## Browser",
    "",
    `- Chromium: ${snapshot.browser.browserVersion}`,
    `- Mode: ${snapshot.browser.headless ? "headless" : "headed"}, server ${snapshot.browser.serverMode}`,
    `- Viewport: ${snapshot.browser.viewport}`,
    `- Visibility: ${snapshot.browser.visibilityState}`,
    `- Clean profile: ${snapshot.browser.cleanProfileMode}`,
    `- Extensions disabled: ${snapshot.browser.extensionsDisabled ? "yes" : "no"}`,
    `- Hardware acceleration posture: ${snapshot.browser.hardwareAccelerationPosture}`,
    `- Recording status: ${snapshot.browser.recordingStatus}`,
    "",
    "## Privacy Boundary",
    "",
    "- No browser history, open tabs, profile contents, personal filenames, private process command lines, OS settings, or user browser profile data collected.",
    ""
  ].join("\n");
}

export function renderBrowserControlBaselinesMarkdown(results: BrowserControlBaselineResult[]): string {
  const sorted = sortResults(results);
  return [
    "# v0.111 Browser Control Baselines",
    "",
    "Private reproducibility evidence. These controls compare host/browser overhead, simple rendering, Phaser baseline posture, campaign-map posture, and Tier M battle cost without changing saves or gameplay.",
    "",
    `Rows: ${sorted.length}. Warm-up: ${sorted[0]?.warmupMs ?? TRUSTED_DEFAULT_WARMUP_MS} ms. Sample: ${sorted[0]?.sampleMs ?? TRUSTED_DEFAULT_SAMPLE_MS} ms.`,
    "",
    "| Control | Mode | FPS avg | 1% low | p50 | p95 | p99 | max | long tasks | DOM | Save mutation |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |",
    ...sorted.map(
      (result) =>
        `| ${result.id} | ${result.runMode} | ${result.steadyState.fpsAverage} | ${result.steadyState.fpsOnePercentLow} | ${result.steadyState.frameTimeMs.p50} | ${result.steadyState.frameTimeMs.p95} | ${result.steadyState.frameTimeMs.p99} | ${result.steadyState.frameTimeMs.max} | ${result.steadyState.longTasks.count} | ${result.domNodes} | ${result.saveMutationDetected ? "yes" : "no"} |`
    ),
    "",
    "## Interpretation",
    "",
    "- Slow blank/simple controls point at host or browser environment contribution.",
    "- Healthy blank/simple/canvas but slow Phaser-empty points at Phaser/browser scene posture.",
    "- Healthy controls and Phaser-empty but slow Tier M points at battle-code cost.",
    ""
  ].join("\n");
}

export function renderCleanProfileBenchmarkMarkdown(results: BrowserControlBaselineResult[]): string {
  const cleanRows = sortResults(results.filter((result) => result.cleanProfile));
  return [
    "# v0.111 Clean-Profile Trusted Benchmark",
    "",
    "This benchmark uses a temporary Chromium profile with extensions disabled. It never touches the user's browser profile and never records profile contents.",
    "",
    `Rows: ${cleanRows.length}.`,
    "",
    "| Control | Mode | FPS avg | p95 | max | long tasks | DOM |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: |",
    ...cleanRows.map(
      (result) =>
        `| ${result.id} | ${result.runMode} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} | ${result.steadyState.frameTimeMs.max} | ${result.steadyState.longTasks.count} | ${result.domNodes} |`
    ),
    "",
    "Temporary profile posture: path redacted, extensions disabled only for the spawned temporary profile, user profile untouched.",
    ""
  ].join("\n");
}

export function renderMachinePressureClassificationMarkdown(report: EnvironmentClassificationReport): string {
  return [
    "# v0.111 Machine Pressure Classification",
    "",
    `Host classification: ${report.hostClassification}`,
    `Game-cost classification: ${report.gameCostClassification}`,
    `Confidence: ${report.confidence}`,
    "",
    "## Evidence",
    "",
    "| Control | Mode | FPS avg | p95 | max | long tasks |",
    "| --- | --- | ---: | ---: | ---: | ---: |",
    ...sortResults(report.evidenceRows).map(
      (result) =>
        `| ${result.id} | ${result.runMode} | ${result.steadyState.fpsAverage} | ${result.steadyState.frameTimeMs.p95} | ${result.steadyState.frameTimeMs.max} | ${result.steadyState.longTasks.count} |`
    ),
    "",
    "## Notes",
    "",
    ...report.notes.map((note) => `- ${note}`),
    "",
    "If the evidence is mixed or incomplete, keep the classification unresolved rather than blaming only the computer or only the game.",
    ""
  ].join("\n");
}

export function renderHostSnapshotSpecMarkdown(): string {
  return [
    "# v0.111 Host Snapshot Spec",
    "",
    "Captures safe, private QA metadata for host pressure and browser reproducibility. It records platform, OS release, architecture, uptime, CPU model/core count, memory, Node/process memory, load average when supported, git commit/cleanliness, viewport, Chromium version, user agent, headless/headed mode, server mode, visibility, profiler capabilities, clean-profile posture, extension-disable posture, hardware-acceleration flag posture, and recording status when detectable.",
    "",
    "Privacy boundary: no browser history, open tabs, profile contents, personal filenames, private process command lines, OS setting changes, process killing, rebooting, user profile mutation, save writes, gameplay changes, art generation/import, desktop work, or v0.112 work.",
    ""
  ].join("\n");
}

export function renderCleanProfileBenchmarkSpecMarkdown(): string {
  return [
    "# v0.111 Clean-Profile Benchmark Spec",
    "",
    "The clean-profile lane spawns a temporary Chromium profile, disables extensions only inside that temporary profile, runs production-preview controls first, redacts the temporary profile path from artifacts, and deletes or ignores only that temporary directory after the run.",
    "",
    "Required comparison rows: blank-page rAF, Phaser empty scene, campaign map, and Tier M representative battle. User browser profiles are never touched.",
    ""
  ].join("\n");
}

export function renderPostRestartRetestMarkdown(): string {
  return [
    "# v0.111 Emmanuel Post-Restart Retest",
    "",
    "1. Restart the computer manually.",
    "2. Wait for startup to settle.",
    "3. Avoid unnecessary apps.",
    "4. Launch the latest private package.",
    "5. Performance Lab -> Capture Host Snapshot.",
    "6. Run the clean-profile benchmark without recording.",
    "7. Run the trusted manual benchmark.",
    "8. Optionally repeat while recording.",
    "9. Export the report.",
    "10. Send the results.",
    "",
    "Do not reboot from automation, change OS settings, edit browser profiles, or start v0.112 from this checklist.",
    ""
  ].join("\n");
}

export function renderImplementationReportMarkdown(results: BrowserControlBaselineResult[]): string {
  return [
    "# v0.111 Implementation Report",
    "",
    "Status: implemented as private host-environment calibration, clean-browser reproducibility, and machine-pressure classification tooling.",
    "",
    "## Implemented",
    "",
    "- Safe host snapshot tool and ignored host-snapshot artifacts.",
    "- Browser control baselines for blank rAF, simple DOM, simple canvas, Phaser empty scene, campaign map, and Tier M representative battle.",
    "- Temporary clean Chromium profile benchmark with extensions disabled only for that profile.",
    "- Private Performance Lab buttons and export template for environment comparison and post-restart instructions.",
    "- Machine-pressure and game-cost classification reports.",
    "",
    "## Boundary",
    "",
    "No process killing beyond stopping this tool's own spawned preview server, reboot, OS setting change, user browser profile mutation, browser history collection, open-tab collection, private process command-line collection, save-version bump, save data change, stable-ID change, gameplay change, balance change, AI/pathing change, art generation/import, desktop work, engine posture change, or v0.112 work is included.",
    "",
    "## Current Result Count",
    "",
    `${results.length} v0.111 control row(s) are available.`,
    ""
  ].join("\n");
}

export function renderArtifactReadme(resultCount: number): string {
  return [
    "# v0.111 Host Environment Calibration Artifacts",
    "",
    "This folder is ignored by git and can be regenerated from the v0.111 perf scripts.",
    "",
    `Control rows: ${resultCount}.`,
    "",
    "Key files:",
    "",
    "- browser-control-baselines.json/md",
    "- clean-profile-benchmark.json/md",
    "- environment-comparison.json/md",
    "- raw-frame-intervals/*.json",
    "",
    `Host snapshots are written under ${V0111_HOST_SNAPSHOT_ROOT}/<timestamp>/.`,
    ""
  ].join("\n");
}

function control(
  id: BrowserControlBaselineId,
  title: string,
  category: BrowserControlCategory,
  interpretation: string,
  usesGameRuntime: boolean,
  launchTarget: BrowserControlLaunchTarget
): BrowserControlDefinition {
  return {
    id,
    title,
    category,
    interpretation,
    usesGameRuntime,
    launchTarget,
    saveIsolationRule: SAVE_ISOLATION_RULE
  };
}

function classifyHostPressure(
  blank: BrowserControlBaselineResult | undefined,
  dom: BrowserControlBaselineResult | undefined,
  canvas: BrowserControlBaselineResult | undefined
): HostPressureClassification {
  if (!blank || !dom || !canvas) {
    return "HOST_PRESSURE_UNCLEAR";
  }
  if (blank.steadyState.frameTimeMs.p95 > 120 || blank.steadyState.fpsAverage < 18) {
    return "HOST_PRESSURE_LIKELY";
  }
  if (
    dom.steadyState.frameTimeMs.p95 > 120 ||
    canvas.steadyState.frameTimeMs.p95 > 120 ||
    dom.steadyState.longTasks.count > 3 ||
    canvas.steadyState.longTasks.count > 3
  ) {
    return "HOST_PRESSURE_CONTRIBUTES";
  }
  return "HOST_PRESSURE_UNLIKELY";
}

function classifyGameCost(
  blank: BrowserControlBaselineResult | undefined,
  canvas: BrowserControlBaselineResult | undefined,
  phaser: BrowserControlBaselineResult | undefined,
  campaign: BrowserControlBaselineResult | undefined,
  battle: BrowserControlBaselineResult | undefined
): GameCostClassification {
  if (!blank || !canvas || !phaser || !campaign || !battle) {
    return "UNRESOLVED";
  }
  if (blank.steadyState.frameTimeMs.p95 > 120 || canvas.steadyState.frameTimeMs.p95 > 160) {
    return "BROWSER_ENVIRONMENT_DOMINANT";
  }
  if (phaser.steadyState.frameTimeMs.p95 > 160 && battle.steadyState.frameTimeMs.p95 <= phaser.steadyState.frameTimeMs.p95 + 80) {
    return "PHASER_BASELINE_DOMINANT";
  }
  if (
    battle.steadyState.frameTimeMs.p95 > Math.max(160, phaser.steadyState.frameTimeMs.p95 + 80) &&
    battle.steadyState.frameTimeMs.p95 > campaign.steadyState.frameTimeMs.p95 + 80
  ) {
    return "BATTLE_CODE_DOMINANT";
  }
  return "MIXED";
}

function classificationNotes(host: HostPressureClassification, game: GameCostClassification): string[] {
  return [
    `Host pressure result: ${host}.`,
    `Game-cost result: ${game}.`,
    "Classification is local browser QA evidence only, not desktop hardware certification.",
    "No v0.112 work may start automatically from this gate."
  ];
}

function resultById(
  results: BrowserControlBaselineResult[],
  id: BrowserControlBaselineId
): BrowserControlBaselineResult | undefined {
  return results.find((result) => result.id === id && !result.cleanProfile) ?? results.find((result) => result.id === id);
}

function sortResults(results: BrowserControlBaselineResult[]): BrowserControlBaselineResult[] {
  const order = new Map(V0111_BROWSER_CONTROL_BASELINES.map((entry, index) => [entry.id, index]));
  return [...results].sort((left, right) => {
    const modeCompare = left.runMode.localeCompare(right.runMode);
    if (modeCompare !== 0) {
      return modeCompare;
    }
    return (order.get(left.id) ?? 99) - (order.get(right.id) ?? 99);
  });
}
