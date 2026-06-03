import { chromium, type Browser, type Page } from "@playwright/test";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import {
  TRUSTED_BENCHMARK_DEFAULT_DIAGNOSTICS,
  TRUSTED_DEFAULT_SAMPLE_MS,
  TRUSTED_DEFAULT_WARMUP_MS,
  TRUSTED_ROOT_CAUSE_CASES,
  V0109_ARTIFACT_DIR,
  V0109_CHECKPOINT,
  V0109_TITLE,
  createManualBenchmarkTemplate,
  createProfilerMethodAudit,
  renderDeferredEngineSpikePreparationMarkdown,
  renderEmmanuelRetestChecklistMarkdown,
  renderEvidenceBackedOptimizationMarkdown,
  renderExecutionModeComparisonMarkdown,
  renderImplementationReportMarkdown,
  renderManualBenchmarkGuideMarkdown,
  renderProfilerMethodAuditMarkdown,
  renderRootCauseMatrixMarkdown,
  renderTrustedBenchmarkProtocolMarkdown,
  renderTrustedBenchmarkSummaryMarkdown,
  renderVisualQaReportMarkdown,
  summarizeTrustedFrameIntervals,
  type TrustedBenchmarkDiagnostics,
  type TrustedBenchmarkResult,
  type TrustedExecutionMode,
  type TrustedFrameInterval,
  type TrustedInteractionLatencyMetrics,
  type TrustedRootCauseCase
} from "../src/game/playtest/TrustedBrowserBenchmark";
import {
  defaultPerformanceCounters,
  type PrivatePerformanceCounters,
  type PrivatePerformanceLongTask
} from "../src/game/playtest/PrivatePerformanceProfiler";

type ServerMode = "preview" | "dev";

interface BrowserSample {
  intervals: TrustedFrameInterval[];
  longTasks: PrivatePerformanceLongTask[];
  longTaskSupported: boolean;
  memoryUsedMb?: number;
}

interface CaseArtifacts {
  rawFrameIntervalArtifact: string;
  interactionLatencyArtifact: string;
}

const SAVE_KEY = "ascendant-realms-save-v1";
const OUTPUT_DIR = resolve(V0109_ARTIFACT_DIR);
const RAW_INTERVAL_DIR = resolve(OUTPUT_DIR, "raw-frame-intervals");
const INTERACTION_DIR = resolve(OUTPUT_DIR, "interaction-latency");
const DEFAULT_PREVIEW_PORT = 5199;
const DEFAULT_DEV_PORT = 5200;

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  await mkdir(OUTPUT_DIR, { recursive: true });
  await mkdir(RAW_INTERVAL_DIR, { recursive: true });
  await mkdir(INTERACTION_DIR, { recursive: true });

  if (args.includes("--manual-template")) {
    await writeStaticArtifacts(await readExistingResults());
    console.log(`Trusted manual benchmark template refreshed: ${V0109_ARTIFACT_DIR}/manual-benchmark-template.json`);
    return;
  }

  if (args.includes("--report-only")) {
    const results = await readExistingResults();
    await writeStaticArtifacts(results);
    console.log(`Trusted browser benchmark report refreshed for ${results.length} result row(s).`);
    return;
  }

  const serverMode = parseServerMode(args);
  const port = Number(argValue(args, "--port") ?? process.env.ASCENDANT_TRUSTED_BENCHMARK_PORT ?? defaultPort(serverMode));
  const baseUrl = `http://127.0.0.1:${port}`;
  const warmupMs = Number(argValue(args, "--warmup-ms") ?? process.env.ASCENDANT_TRUSTED_WARMUP_MS ?? TRUSTED_DEFAULT_WARMUP_MS);
  const sampleMs = Number(argValue(args, "--sample-ms") ?? process.env.ASCENDANT_TRUSTED_SAMPLE_MS ?? TRUSTED_DEFAULT_SAMPLE_MS);
  const cases = resolveCases(args, serverMode);

  const server = await startServer(serverMode, port);
  let browser: Browser | undefined;
  try {
    await waitForServer(baseUrl);
    browser = await chromium.launch({
      headless: true,
      args: ["--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"]
    });
    const page = await browser.newPage({ viewport: viewportSize("1600x900") });
    page.setDefaultTimeout(60_000);
    page.setDefaultNavigationTimeout(120_000);
    await page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });

    const existing = await readExistingResults();
    const resultsById = new Map(existing.map((result) => [`${result.environment.executionMode}:${result.caseId}`, result]));
    for (const benchmarkCase of cases) {
      const result = await runCase(page, baseUrl, benchmarkCase, serverMode, warmupMs, sampleMs);
      resultsById.set(`${result.environment.executionMode}:${result.caseId}`, result);
      console.log(
        `Trusted browser benchmark complete: ${result.caseId} ${result.environment.executionMode} ${result.environment.viewport}`
      );
    }
    const results = [...resultsById.values()].sort((left, right) =>
      `${left.environment.executionMode}:${left.caseId}`.localeCompare(`${right.environment.executionMode}:${right.caseId}`)
    );
    await writeStaticArtifacts(results);
    console.log(`Trusted browser benchmark artifacts: ${V0109_ARTIFACT_DIR}`);
  } finally {
    await browser?.close();
    server.kill();
  }
}

async function runCase(
  page: Page,
  baseUrl: string,
  benchmarkCase: TrustedRootCauseCase,
  serverMode: ServerMode,
  warmupMs: number,
  sampleMs: number
): Promise<TrustedBenchmarkResult> {
  await page.setViewportSize(viewportSize(benchmarkCase.viewport));
  const navigationStarted = Date.now();
  await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 45_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  const hubReadyMs = Date.now() - navigationStarted;
  const saveBefore = await readSaveSnapshot(page);

  const launchStarted = Date.now();
  await page.getByTestId(`playtest-scenario-${benchmarkCase.scenarioId}`).scrollIntoViewIfNeeded();
  await page.getByTestId(`playtest-scenario-${benchmarkCase.scenarioId}`).click();

  const isCampaign = benchmarkCase.scenarioId === "perf_campaign_map_interaction";
  if (isCampaign) {
    await page.getByTestId("campaign-map").waitFor({ timeout: 90_000 });
  } else {
    await expectBattleLoaded(page);
  }
  const battleHudReadyMs = isCampaign ? 0 : Date.now() - launchStarted;
  const sceneReadyMs = Date.now() - launchStarted;
  const firstFrameMs = await nextFrameLatency(page);
  const firstInteractionMs = isCampaign ? 0 : await measureTargetInteraction(page, "hero");

  if (!isCampaign) {
    await applyDiagnostics(page, benchmarkCase.diagnostics);
  }
  await page.waitForLoadState("networkidle", { timeout: 5_000 }).catch(() => undefined);
  const warmStarted = Date.now();
  await page.waitForTimeout(warmupMs);
  const actualWarmupMs = Date.now() - warmStarted;
  const visibilityState = await page.evaluate(() => document.visibilityState);
  const countersBefore = await getCounters(page, isCampaign);
  const sample = await collectFrameIntervals(page, sampleMs);
  const countersAfter = await getCounters(page, isCampaign, sample.memoryUsedMb);
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: sample.intervals,
    sampleDurationMs: sampleMs,
    countersBefore,
    countersAfter,
    longTasks: sample.longTasks,
    longTaskSupported: sample.longTaskSupported
  });
  const interactions = isCampaign
    ? await measureCampaignInteractions(page)
    : await measureBattleInteractions(page, benchmarkCase.scenarioId === "benchmark_battle_results_transition");

  if (isCampaign) {
    interactions.returnToHubMs = await returnFromCampaignToHub(page);
  } else if (benchmarkCase.scenarioId === "benchmark_battle_results_transition") {
    const started = Date.now();
    await page.getByTestId("results-playtest-hub").click();
    await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
    interactions.returnToHubMs = Date.now() - started;
  } else {
    interactions.returnToHubMs = await returnFromBattleToHub(page);
  }
  interactions.scenarioResetMs = await resetPrivateHub(page);
  const artifacts = await writeCaseArtifacts(benchmarkCase, sample.intervals, interactions);

  const saveAfter = await readSaveSnapshot(page);
  if (saveBefore !== saveAfter) {
    throw new Error(`Trusted benchmark case mutated save/localStorage: ${benchmarkCase.id}.`);
  }

  return {
    id: `${benchmarkCase.executionMode}:${benchmarkCase.id}`,
    caseId: benchmarkCase.id,
    title: benchmarkCase.title,
    scenarioId: benchmarkCase.scenarioId,
    diagnostics: benchmarkCase.diagnostics,
    environment: {
      executionMode: executionModeFor(serverMode),
      visibilityState,
      viewport: benchmarkCase.viewport,
      userAgent: await page.evaluate(() => navigator.userAgent),
      browserName: "chromium",
      headed: false,
      serverMode,
      profilerOverlayEnabled: benchmarkCase.diagnostics.profilerOverlay === "on",
      screenshotsDuringSample: false,
      warmupMs,
      sampleMs,
      longTaskObserverSupported: sample.longTaskSupported,
      memorySupported: sample.memoryUsedMb !== undefined
    },
    launch: {
      navigationStartToHubReadyMs: hubReadyMs,
      scenarioClickToBattleHudMs: battleHudReadyMs,
      scenarioClickToSceneReadyMs: sceneReadyMs,
      firstResponsiveInteractionMs: firstInteractionMs,
      firstRenderedFrameAfterReadyMs: firstFrameMs
    },
    settle: {
      configuredWarmupMs: warmupMs,
      actualWarmupMs,
      visibilityState,
      sceneStable: true
    },
    steadyState,
    interactions,
    rawFrameIntervalArtifact: artifacts.rawFrameIntervalArtifact,
    interactionLatencyArtifact: artifacts.interactionLatencyArtifact
  };
}

async function expectBattleLoaded(page: Page): Promise<void> {
  await page.getByTestId("battle-hud").waitFor({ timeout: 90_000 });
  await page.getByTestId("battle-minimap").waitFor({ timeout: 90_000 });
  await page.waitForFunction(
    () => {
      const scene = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
      return Boolean(scene?.scene?.isActive?.() && scene.hero && scene.activeMap && scene.runtime && scene.game?.canvas);
    },
    null,
    { timeout: 90_000 }
  );
}

async function applyDiagnostics(page: Page, diagnostics: TrustedBenchmarkDiagnostics): Promise<void> {
  const applied = await page.evaluate((nextDiagnostics) => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    return hooks?.setTrustedBenchmarkDiagnostics?.(nextDiagnostics) ?? null;
  }, diagnostics);
  if (!applied) {
    throw new Error("Trusted benchmark diagnostics were not available in the private battle scene.");
  }
  await nextFrameLatency(page);
}

async function measureBattleInteractions(page: Page, includeResults: boolean): Promise<TrustedInteractionLatencyMetrics> {
  const interactions: TrustedInteractionLatencyMetrics = {};
  interactions.selectHeroMs = await measureTargetInteraction(page, "hero");
  interactions.selectWorkerMs = await measureTargetInteraction(page, "worker");
  interactions.selectBuildingMs = await measureTargetInteraction(page, "building");
  interactions.minimapClickMs = await measureMinimapClick(page);
  interactions.lumeHiddenMs = await measureDiagnosticUpdate(page, { lume: "hidden" });
  interactions.lumeAutoMs = await measureDiagnosticUpdate(page, { lume: "auto" });
  interactions.lumeAlwaysMs = await measureDiagnosticUpdate(page, { lume: "always" });
  interactions.lumeAutoMs = await measureDiagnosticUpdate(page, { lume: "auto" });
  if (includeResults) {
    const started = Date.now();
    const transitioned = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.forceBattleVictory?.() ?? false);
    if (!transitioned) {
      throw new Error("Trusted benchmark could not force the no-save Results transition.");
    }
    await page.getByTestId("private-demo-lume-summary").waitFor({ timeout: 30_000 });
    interactions.resultsDisclosureMs = Date.now() - started;
  }
  return interactions;
}

async function measureCampaignInteractions(page: Page): Promise<TrustedInteractionLatencyMetrics> {
  const started = Date.now();
  await page.getByTestId("campaign-tab-stronghold").click();
  await page.getByTestId("campaign-tab-panel-stronghold").waitFor({ timeout: 10_000 });
  return { selectHeroMs: Date.now() - started };
}

async function measureTargetInteraction(page: Page, target: "hero" | "worker" | "building"): Promise<number> {
  return page.evaluate(async (targetName) => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.selectTrustedBenchmarkTarget) {
      throw new Error("Missing trusted benchmark target hook.");
    }
    const started = performance.now();
    const selected = hooks.selectTrustedBenchmarkTarget(targetName);
    await new Promise<void>((resolveFrame) => requestAnimationFrame(() => resolveFrame()));
    if (!selected) {
      throw new Error(`Could not select trusted benchmark target ${targetName}.`);
    }
    return Number((performance.now() - started).toFixed(2));
  }, target);
}

async function measureMinimapClick(page: Page): Promise<number> {
  const box = await page.getByTestId("minimap").boundingBox();
  if (!box) {
    throw new Error("Minimap was not visible for trusted interaction timing.");
  }
  const started = Date.now();
  await page.getByTestId("minimap").click({ position: { x: Math.max(4, box.width / 2), y: Math.max(4, box.height / 2) } });
  await nextFrameLatency(page);
  return Date.now() - started;
}

async function measureDiagnosticUpdate(page: Page, diagnostics: Partial<TrustedBenchmarkDiagnostics>): Promise<number> {
  const started = Date.now();
  await page.evaluate((nextDiagnostics) => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.setTrustedBenchmarkDiagnostics?.(nextDiagnostics)) {
      throw new Error("Could not update trusted diagnostics.");
    }
  }, diagnostics);
  await nextFrameLatency(page);
  return Date.now() - started;
}

async function returnFromBattleToHub(page: Page): Promise<number> {
  const started = Date.now();
  await page.getByTestId("private-hub-exit").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  return Date.now() - started;
}

async function returnFromCampaignToHub(page: Page): Promise<number> {
  const started = Date.now();
  await page.getByTestId("campaign-playtest-hub-return").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  return Date.now() - started;
}

async function resetPrivateHub(page: Page): Promise<number> {
  const started = Date.now();
  await page.getByTestId("playtest-reset").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  return Date.now() - started;
}

async function nextFrameLatency(page: Page): Promise<number> {
  return page.evaluate(
    () =>
      new Promise<number>((resolveFrame) => {
        const started = performance.now();
        requestAnimationFrame(() => resolveFrame(Number((performance.now() - started).toFixed(2))));
      })
  );
}

async function collectFrameIntervals(page: Page, sampleMs: number): Promise<BrowserSample> {
  return page.evaluate(`(async () => {
    const durationMs = ${JSON.stringify(sampleMs)};
    const intervals = [];
    const longTasks = [];
    const supportedEntryTypes = PerformanceObserver.supportedEntryTypes || [];
    const longTaskSupported = supportedEntryTypes.includes("longtask");
    let observer;
    if (longTaskSupported) {
      observer = new PerformanceObserver((list) => {
        list.getEntries().forEach((entry) => {
          longTasks.push({
            atMs: Number(entry.startTime.toFixed(2)),
            durationMs: Number(entry.duration.toFixed(2))
          });
        });
      });
      observer.observe({ type: "longtask", buffered: true });
    }

    const sampleStartedAt = performance.now();
    let previousFrame;
    await new Promise((resolveSample) => {
      const tick = (now) => {
        if (previousFrame !== undefined) {
          intervals.push({
            index: intervals.length,
            atMs: Number((now - sampleStartedAt).toFixed(2)),
            frameMs: Number((now - previousFrame).toFixed(2))
          });
        }
        previousFrame = now;
        if (now - sampleStartedAt < durationMs) {
          requestAnimationFrame(tick);
        } else {
          resolveSample();
        }
      };
      requestAnimationFrame(tick);
    });
    if (observer) {
      observer.disconnect();
    }
    const memory = performance.memory;
    return {
      intervals,
      longTasks,
      longTaskSupported,
      memoryUsedMb: memory && memory.usedJSHeapSize !== undefined ? Number((memory.usedJSHeapSize / 1024 / 1024).toFixed(2)) : undefined
    };
  })()`) as Promise<BrowserSample>;
}

async function getCounters(page: Page, isCampaign: boolean, memoryUsedMb?: number): Promise<PrivatePerformanceCounters> {
  if (!isCampaign) {
    const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getPrivatePerformanceCounters?.());
    if (!counters) {
      throw new Error("Missing private performance counters for trusted benchmark.");
    }
    return { ...defaultPerformanceCounters(), ...counters, memoryUsedMb };
  }
  const domCounters = await page.evaluate(() => ({
    domNodes: document.querySelectorAll("*").length,
    memoryUsedMb: (performance as Performance & { memory?: { usedJSHeapSize?: number } }).memory?.usedJSHeapSize
      ? Number((((performance as Performance & { memory?: { usedJSHeapSize?: number } }).memory?.usedJSHeapSize ?? 0) / 1024 / 1024).toFixed(2))
      : undefined
  }));
  return { ...defaultPerformanceCounters(), ...domCounters, memoryUsedMb: memoryUsedMb ?? domCounters.memoryUsedMb };
}

async function writeCaseArtifacts(
  benchmarkCase: TrustedRootCauseCase,
  intervals: TrustedFrameInterval[],
  interactions: TrustedInteractionLatencyMetrics
): Promise<CaseArtifacts> {
  const safeId = `${benchmarkCase.executionMode}-${benchmarkCase.id}`;
  const rawPath = resolve(RAW_INTERVAL_DIR, `${safeId}.json`);
  const interactionPath = resolve(INTERACTION_DIR, `${safeId}.json`);
  await writeFile(rawPath, `${JSON.stringify({ caseId: benchmarkCase.id, intervals }, null, 2)}\n`, "utf8");
  await writeFile(interactionPath, `${JSON.stringify({ caseId: benchmarkCase.id, interactions }, null, 2)}\n`, "utf8");
  return {
    rawFrameIntervalArtifact: displayPath(rawPath),
    interactionLatencyArtifact: displayPath(interactionPath)
  };
}

async function writeStaticArtifacts(results: TrustedBenchmarkResult[]): Promise<void> {
  const audit = createProfilerMethodAudit();
  const artifactSet = {
    checkpoint: V0109_CHECKPOINT,
    title: V0109_TITLE,
    generatedAtUtc: new Date().toISOString(),
    warmupMs: results[0]?.environment.warmupMs ?? TRUSTED_DEFAULT_WARMUP_MS,
    sampleMs: results[0]?.environment.sampleMs ?? TRUSTED_DEFAULT_SAMPLE_MS,
    results
  };
  const rootCauseRows = results.filter((result) => TRUSTED_ROOT_CAUSE_CASES.some((entry) => entry.id === result.caseId));
  const modeRows = results.filter((result) => result.caseId.includes("mode") || result.caseId === "baseline");
  const capabilityReport = {
    schemaVersion: 1,
    checkpoint: V0109_CHECKPOINT,
    productionPreviewPrimary: true,
    devServerComparison: results.some((result) => result.environment.executionMode === "dev-server-headless"),
    headedAutomated: false,
    manualInApp: true,
    screenshotsDuringSample: false,
    oldProfilerOverlayDefault: "off",
    warmupMs: artifactSet.warmupMs,
    sampleMs: artifactSet.sampleMs,
    resultCount: results.length,
    longTaskObserverSupported: results.some((result) => result.environment.longTaskObserverSupported)
  };
  const beforeAfterDelta = {
    schemaVersion: 1,
    checkpoint: V0109_CHECKPOINT,
    oldMethod: {
      sampleWindowMs: audit.oldSampleWindowMs,
      executionMode: audit.oldExecutionMode,
      conclusion: audit.conclusion
    },
    trustedMethod: {
      warmupMs: artifactSet.warmupMs,
      sampleMs: artifactSet.sampleMs,
      productionPreviewPrimary: true,
      rawIntervalsRetained: true,
      launchSettleInteractionSeparated: true
    },
    classification: rootCauseRows.length > 0 ? "trusted evidence available" : "trusted evidence pending"
  };

  await writeFile(resolve(OUTPUT_DIR, "profiler-method-audit.json"), `${JSON.stringify(audit, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "trusted-benchmark-summary.json"), `${JSON.stringify(artifactSet, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "trusted-benchmark-summary.md"), renderTrustedBenchmarkSummaryMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "execution-mode-comparison.json"), `${JSON.stringify({ rows: modeRows }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "root-cause-matrix.json"), `${JSON.stringify({ cases: TRUSTED_ROOT_CAUSE_CASES, rows: rootCauseRows }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.json"), `${JSON.stringify(beforeAfterDelta, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.md"), renderEvidenceBackedOptimizationMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "manual-benchmark-template.json"), `${JSON.stringify(createManualBenchmarkTemplate(), null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "profiler-capability-report.json"), `${JSON.stringify(capabilityReport, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "README.md"), renderArtifactReadme(capabilityReport.resultCount), "utf8");

  await writeFile(resolve("docs", "V0109_PROFILER_METHOD_AUDIT.md"), renderProfilerMethodAuditMarkdown(audit), "utf8");
  await writeFile(resolve("docs", "V0109_TRUSTED_BROWSER_BENCHMARK_PROTOCOL.md"), renderTrustedBenchmarkProtocolMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0109_EXECUTION_MODE_COMPARISON.md"), renderExecutionModeComparisonMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0109_ROOT_CAUSE_MATRIX_REPORT.md"), renderRootCauseMatrixMarkdown(rootCauseRows), "utf8");
  await writeFile(resolve("docs", "V0109_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md"), renderEvidenceBackedOptimizationMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0109_MANUAL_BENCHMARK_GUIDE.md"), renderManualBenchmarkGuideMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0109_VISUAL_QA_REPORT.md"), renderVisualQaReportMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0109_IMPLEMENTATION_REPORT.md"), renderImplementationReportMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0109_EMMANUEL_RETEST_CHECKLIST.md"), renderEmmanuelRetestChecklistMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0109_DEFERRED_ENGINE_SPIKE_PREPARATION.md"), renderDeferredEngineSpikePreparationMarkdown(), "utf8");
}

async function readExistingResults(): Promise<TrustedBenchmarkResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "trusted-benchmark-summary.json"), "utf8")) as {
      results?: TrustedBenchmarkResult[];
    };
    return Array.isArray(parsed.results) ? parsed.results : [];
  } catch {
    return [];
  }
}

function resolveCases(args: string[], serverMode: ServerMode): TrustedRootCauseCase[] {
  const profile = argValue(args, "--profile");
  if (profile === "root-cause") {
    return TRUSTED_ROOT_CAUSE_CASES.map((entry) => ({ ...entry, executionMode: executionModeFor(serverMode) }));
  }

  const caseArg = argValue(args, "--cases");
  const requestedCases =
    caseArg?.split(",").map((entry) => entry.trim()).filter((entry) => entry.length > 0) ??
    (serverMode === "dev" ? ["mode-dev-headless"] : ["mode-preview-headless", "baseline"]);

  return requestedCases.map((caseId) => {
    if (caseId === "mode-preview-headless" || caseId === "mode-dev-headless") {
      return modeCase(caseId, serverMode);
    }
    const found = TRUSTED_ROOT_CAUSE_CASES.find((entry) => entry.id === caseId);
    if (!found) {
      throw new Error(`Unknown trusted benchmark case ${caseId}.`);
    }
    return { ...found, executionMode: executionModeFor(serverMode) };
  });
}

function modeCase(caseId: string, serverMode: ServerMode): TrustedRootCauseCase {
  return {
    id: caseId,
    title: serverMode === "dev" ? "Dev server headless mode" : "Production preview headless mode",
    scenarioId: "benchmark_battle_tier_m_representative",
    executionMode: executionModeFor(serverMode),
    viewport: "1600x900",
    diagnostics: { ...TRUSTED_BENCHMARK_DEFAULT_DIAGNOSTICS },
    compareFocus: "execution-mode comparison",
    localOnly: false
  };
}

function parseServerMode(args: string[]): ServerMode {
  const mode = argValue(args, "--mode") ?? "preview";
  if (mode === "preview" || mode === "dev") {
    return mode;
  }
  throw new Error(`Unknown trusted benchmark mode ${mode}. Use preview or dev.`);
}

function argValue(args: string[], name: string): string | undefined {
  return args.find((arg) => arg.startsWith(`${name}=`))?.slice(name.length + 1);
}

function executionModeFor(serverMode: ServerMode): TrustedExecutionMode {
  return serverMode === "dev" ? "dev-server-headless" : "production-preview-headless";
}

function defaultPort(serverMode: ServerMode): number {
  return serverMode === "dev" ? DEFAULT_DEV_PORT : DEFAULT_PREVIEW_PORT;
}

async function startServer(serverMode: ServerMode, port: number): Promise<ChildProcessWithoutNullStreams> {
  const viteArgs =
    serverMode === "dev"
      ? ["node_modules/vite/bin/vite.js", "--host", "127.0.0.1", "--port", String(port), "--strictPort"]
      : ["node_modules/vite/bin/vite.js", "preview", "--host", "127.0.0.1", "--port", String(port), "--strictPort"];
  const child = spawn(process.execPath, viteArgs, {
    cwd: process.cwd(),
    env: { ...process.env, ASCENDANT_TRUSTED_BROWSER_BENCHMARK: "1" },
    stdio: "pipe"
  });
  child.stdout.on("data", (chunk) => process.stdout.write(`[trusted-${serverMode}] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[trusted-${serverMode}] ${chunk}`));
  child.on("exit", (code) => {
    if (code && code !== 0) {
      console.warn(`Trusted ${serverMode} server exited with code ${code}.`);
    }
  });
  return child;
}

async function waitForServer(baseUrl: string): Promise<void> {
  const startedAt = Date.now();
  while (Date.now() - startedAt < 120_000) {
    try {
      const response = await fetch(baseUrl);
      if (response.ok) {
        return;
      }
    } catch {
      // Retry until Vite finishes booting.
    }
    await new Promise((resolveRetry) => setTimeout(resolveRetry, 500));
  }
  throw new Error(`Timed out waiting for ${baseUrl}.`);
}

async function readSaveSnapshot(page: Page): Promise<string | null> {
  return page.evaluate((key) => localStorage.getItem(key), SAVE_KEY);
}

function viewportSize(label: string): { width: number; height: number } {
  const [width, height] = label.split("x").map((value) => Number(value));
  return { width, height };
}

function renderArtifactReadme(resultCount: number): string {
  return [
    "# v0.109 Trusted Browser Benchmark Artifacts",
    "",
    "This folder is ignored by git and can be regenerated from the v0.109 perf scripts.",
    "",
    `Result rows: ${resultCount}.`,
    "",
    "Key files:",
    "",
    "- profiler-method-audit.json",
    "- execution-mode-comparison.json",
    "- root-cause-matrix.json",
    "- trusted-benchmark-summary.json",
    "- before-after-delta.json",
    "- manual-benchmark-template.json",
    "- profiler-capability-report.json",
    "- raw-frame-intervals/*.json",
    "- interaction-latency/*.json",
    ""
  ].join("\n");
}

function displayPath(path: string): string {
  return path.replace(resolve(process.cwd()), "").replace(/^[/\\]/u, "").replace(/\\/gu, "/");
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : String(error));
  process.exitCode = 1;
});
