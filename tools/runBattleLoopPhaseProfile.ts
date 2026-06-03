import { chromium, type Page } from "@playwright/test";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import {
  V0110_ARTIFACT_DIR,
  V0110_BATTLE_LOOP_SCENARIOS,
  V0110_CHECKPOINT,
  V0110_TITLE,
  buildBattleLoopArtifactSet,
  createTrustedBrowserGateReport,
  normalizeBattleLoopDiagnostics,
  renderBattleLoopIsolationSpecMarkdown,
  renderBattleLoopPhaseProfilerSpecMarkdown,
  renderBeforeAfterDeltaMarkdown,
  renderControlledOptimizationReportMarkdown,
  renderDeferredArchitectureFindingsMarkdown,
  renderDensityScalingReportMarkdown,
  renderEmmanuelRetestMarkdown,
  renderImplementationReportMarkdown,
  renderPhaseProfilerSummaryMarkdown,
  renderProfilerCapabilityReport,
  renderRootCauseClassificationMarkdown,
  renderSubsystemIsolationMatrixMarkdown,
  renderTrustedBrowserGateMarkdown,
  renderVisualQaReportMarkdown,
  type BattleLoopBenchmarkResult,
  type BattleLoopDiagnostics,
  type BattleLoopPhaseSummary,
  type BattleLoopScenarioDefinition
} from "../src/game/playtest/BattleLoopPhaseProfiler";
import {
  TRUSTED_DEFAULT_SAMPLE_MS,
  TRUSTED_DEFAULT_WARMUP_MS,
  summarizeTrustedFrameIntervals,
  type TrustedFrameInterval
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
  rawPhaseSummaryArtifact: string;
}

const SAVE_KEY = "ascendant-realms-save-v1";
const OUTPUT_DIR = resolve(V0110_ARTIFACT_DIR);
const RAW_INTERVAL_DIR = resolve(OUTPUT_DIR, "raw-frame-intervals");
const RAW_PHASE_SAMPLE_DIR = resolve(OUTPUT_DIR, "raw-phase-samples");
const RAW_PHASE_SUMMARY_DIR = resolve(OUTPUT_DIR, "raw-phase-summaries");
const DEFAULT_PREVIEW_PORT = 5210;
const DEFAULT_DEV_PORT = 5211;

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  await mkdir(OUTPUT_DIR, { recursive: true });
  await mkdir(RAW_INTERVAL_DIR, { recursive: true });
  await mkdir(RAW_PHASE_SAMPLE_DIR, { recursive: true });
  await mkdir(RAW_PHASE_SUMMARY_DIR, { recursive: true });

  if (args.includes("--report-only")) {
    const results = await readExistingResults();
    await writeStaticArtifacts(results);
    console.log(`v0.110 battle-loop reports refreshed for ${results.length} row(s).`);
    return;
  }

  const serverMode = parseServerMode(args);
  const port = Number(argValue(args, "--port") ?? process.env.ASCENDANT_V0110_PERF_PORT ?? defaultPort(serverMode));
  const warmupMs = Number(argValue(args, "--warmup-ms") ?? process.env.ASCENDANT_V0110_WARMUP_MS ?? TRUSTED_DEFAULT_WARMUP_MS);
  const sampleMs = Number(argValue(args, "--sample-ms") ?? process.env.ASCENDANT_V0110_SAMPLE_MS ?? TRUSTED_DEFAULT_SAMPLE_MS);
  const cases = resolveCases(args);
  const baseUrl = `http://127.0.0.1:${port}`;

  const server = await startServer(serverMode, port);
  let browser: Awaited<ReturnType<typeof chromium.launch>> | undefined;
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
    const resultsById = new Map(existing.map((result) => [result.caseId, result]));
    for (const benchmarkCase of cases) {
      const result = await runCase(page, baseUrl, benchmarkCase, warmupMs, sampleMs);
      resultsById.set(result.caseId, result);
      console.log(`v0.110 battle-loop profile complete: ${result.caseId}`);
    }
    const results = [...resultsById.values()];
    await writeStaticArtifacts(results, { warmupMs, sampleMs });
    console.log(`v0.110 battle-loop artifacts: ${V0110_ARTIFACT_DIR}`);
  } finally {
    await browser?.close();
    server.kill();
  }
}

async function runCase(
  page: Page,
  baseUrl: string,
  benchmarkCase: BattleLoopScenarioDefinition,
  warmupMs: number,
  sampleMs: number
): Promise<BattleLoopBenchmarkResult> {
  await page.setViewportSize(viewportForCase(benchmarkCase));
  await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 45_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  const saveBefore = await readSaveSnapshot(page);

  await page.getByTestId(`playtest-scenario-${benchmarkCase.id}`).scrollIntoViewIfNeeded();
  await page.getByTestId(`playtest-scenario-${benchmarkCase.id}`).click();
  await expectBattleLoaded(page);
  await applyBattleLoopDiagnostics(page, benchmarkCase.diagnostics);
  await page.waitForLoadState("networkidle", { timeout: 5_000 }).catch(() => undefined);
  await page.waitForTimeout(warmupMs);

  const countersBefore = await getCounters(page);
  await resetPhaseProfiler(page);
  const sample = await collectFrameIntervals(page, sampleMs);
  const phaseSummary = await getPhaseSummary(page);
  const countersAfter = await getCounters(page, sample.memoryUsedMb);
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: sample.intervals,
    sampleDurationMs: sampleMs,
    countersBefore,
    countersAfter,
    longTasks: sample.longTasks,
    longTaskSupported: sample.longTaskSupported
  });
  const artifacts = await writeCaseArtifacts(benchmarkCase, sample.intervals, phaseSummary);

  const saveAfter = await readSaveSnapshot(page);
  if (saveBefore !== saveAfter) {
    throw new Error(`v0.110 battle-loop profile mutated save/localStorage: ${benchmarkCase.id}.`);
  }

  return {
    caseId: benchmarkCase.id,
    title: benchmarkCase.title,
    category: benchmarkCase.category,
    scenarioId: benchmarkCase.launchScenarioId,
    diagnostics: normalizeBattleLoopDiagnostics(benchmarkCase.diagnostics),
    viewport: viewportLabelForCase(benchmarkCase),
    warmupMs,
    sampleMs,
    generatedAtUtc: new Date().toISOString(),
    steadyState,
    phaseSummary,
    rawFrameIntervalArtifact: artifacts.rawFrameIntervalArtifact,
    rawPhaseSummaryArtifact: artifacts.rawPhaseSummaryArtifact
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

async function applyBattleLoopDiagnostics(page: Page, diagnostics: Partial<BattleLoopDiagnostics>): Promise<void> {
  const applied = await page.evaluate((nextDiagnostics) => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    return hooks?.setBattleLoopDiagnostics?.({ phaseProfiler: "on", ...nextDiagnostics }) ?? null;
  }, diagnostics);
  if (!applied) {
    throw new Error("v0.110 battle-loop diagnostics were not available in the private battle scene.");
  }
  await nextFrameLatency(page);
}

async function resetPhaseProfiler(page: Page): Promise<void> {
  await page.evaluate(() => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.resetBattleLoopPhaseProfiler?.()) {
      throw new Error("Missing v0.110 phase profiler reset hook.");
    }
  });
}

async function getPhaseSummary(page: Page): Promise<BattleLoopPhaseSummary> {
  const summary = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getBattleLoopPhaseSummary?.());
  if (!summary) {
    throw new Error("Missing v0.110 battle-loop phase summary.");
  }
  return summary as BattleLoopPhaseSummary;
}

async function getCounters(page: Page, memoryUsedMb?: number): Promise<PrivatePerformanceCounters> {
  const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getPrivatePerformanceCounters?.());
  if (!counters) {
    throw new Error("Missing private performance counters for v0.110 benchmark.");
  }
  return { ...defaultPerformanceCounters(), ...counters, memoryUsedMb };
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

async function nextFrameLatency(page: Page): Promise<number> {
  return page.evaluate(
    () =>
      new Promise<number>((resolveFrame) => {
        const started = performance.now();
        requestAnimationFrame(() => resolveFrame(Number((performance.now() - started).toFixed(2))));
      })
  );
}

async function writeCaseArtifacts(
  benchmarkCase: BattleLoopScenarioDefinition,
  intervals: TrustedFrameInterval[],
  phaseSummary: BattleLoopPhaseSummary
): Promise<CaseArtifacts> {
  const rawPath = resolve(RAW_INTERVAL_DIR, `${benchmarkCase.id}.json`);
  const phaseSamplePath = resolve(RAW_PHASE_SAMPLE_DIR, `${benchmarkCase.id}.json`);
  const phaseSummaryPath = resolve(RAW_PHASE_SUMMARY_DIR, `${benchmarkCase.id}.json`);
  const phasePayload = `${JSON.stringify({ caseId: benchmarkCase.id, phaseSummary }, null, 2)}\n`;
  await writeFile(rawPath, `${JSON.stringify({ caseId: benchmarkCase.id, intervals }, null, 2)}\n`, "utf8");
  await writeFile(phaseSamplePath, phasePayload, "utf8");
  await writeFile(phaseSummaryPath, phasePayload, "utf8");
  return {
    rawFrameIntervalArtifact: displayPath(rawPath),
    rawPhaseSummaryArtifact: displayPath(phaseSamplePath)
  };
}

async function writeStaticArtifacts(
  results: BattleLoopBenchmarkResult[],
  options: { warmupMs?: number; sampleMs?: number } = {}
): Promise<void> {
  const artifactSet = buildBattleLoopArtifactSet(results, options);
  const subsystemRows = results.filter((entry) => entry.category === "subsystem");
  const densityRows = results.filter((entry) => entry.category === "density" || entry.category === "static");
  const gate = createTrustedBrowserGateReport(results);
  const beforeAfterDelta = {
    schemaVersion: 1,
    checkpoint: V0110_CHECKPOINT,
    title: V0110_TITLE,
    gate,
    resultCount: results.length,
    controlledOptimization:
      "Phase profiler is off by default; binary isolation switches are private/session-only; no broad renderer, engine, art, save, or gameplay rewrite was started."
  };

  await writeFile(resolve(OUTPUT_DIR, "phase-profiler-summary.json"), `${JSON.stringify(artifactSet, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "phase-profiler-summary.md"), renderPhaseProfilerSummaryMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "subsystem-isolation-matrix.json"), `${JSON.stringify({ rows: subsystemRows }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "subsystem-isolation-matrix.md"), renderSubsystemIsolationMatrixMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "density-scaling-report.json"), `${JSON.stringify({ rows: densityRows }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "density-scaling-report.md"), renderDensityScalingReportMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "trusted-browser-gate.json"), `${JSON.stringify(gate, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "trusted-browser-gate.md"), renderTrustedBrowserGateMarkdown(gate), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.json"), `${JSON.stringify(beforeAfterDelta, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.md"), renderBeforeAfterDeltaMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "profiler-capability-report.json"), `${JSON.stringify(renderProfilerCapabilityReport(results), null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "README.md"), renderArtifactReadme(results.length), "utf8");

  await writeFile(resolve("docs", "V0110_BATTLE_LOOP_PHASE_PROFILER_SPEC.md"), renderBattleLoopPhaseProfilerSpecMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0110_SUBSYSTEM_ISOLATION_MATRIX_SPEC.md"), renderBattleLoopIsolationSpecMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0110_DENSITY_SCALING_REPORT.md"), renderDensityScalingReportMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0110_ROOT_CAUSE_CLASSIFICATION.md"), renderRootCauseClassificationMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0110_CONTROLLED_OPTIMIZATION_REPORT.md"), renderControlledOptimizationReportMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0110_BROWSER_PERFORMANCE_GATE.md"), renderTrustedBrowserGateMarkdown(gate), "utf8");
  await writeFile(resolve("docs", "V0110_VISUAL_QA_REPORT.md"), renderVisualQaReportMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0110_IMPLEMENTATION_REPORT.md"), renderImplementationReportMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0110_EMMANUEL_PHASE_PROFILE_RETEST.md"), renderEmmanuelRetestMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0110_DEFERRED_ARCHITECTURE_FINDINGS.md"), renderDeferredArchitectureFindingsMarkdown(results), "utf8");
}

async function readExistingResults(): Promise<BattleLoopBenchmarkResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "phase-profiler-summary.json"), "utf8")) as {
      results?: BattleLoopBenchmarkResult[];
    };
    return Array.isArray(parsed.results) ? parsed.results : [];
  } catch {
    return [];
  }
}

function resolveCases(args: string[]): BattleLoopScenarioDefinition[] {
  const caseArg = argValue(args, "--cases");
  if (caseArg) {
    return caseArg
      .split(",")
      .map((entry) => entry.trim())
      .filter((entry) => entry.length > 0)
      .map((caseId) => {
        const found = V0110_BATTLE_LOOP_SCENARIOS.find((entry) => entry.id === caseId);
        if (!found) {
          throw new Error(`Unknown v0.110 battle-loop case ${caseId}.`);
        }
        return found;
      });
  }

  const profile = argValue(args, "--profile") ?? "phase";
  if (profile === "subsystem") {
    return V0110_BATTLE_LOOP_SCENARIOS.filter((entry) => entry.category === "subsystem");
  }
  if (profile === "density") {
    return V0110_BATTLE_LOOP_SCENARIOS.filter((entry) => entry.category === "static" || entry.category === "density");
  }
  if (profile === "gate") {
    return V0110_BATTLE_LOOP_SCENARIOS.filter((entry) => entry.id === "v0110_tier_m_density");
  }
  if (profile === "all") {
    return V0110_BATTLE_LOOP_SCENARIOS;
  }
  return V0110_BATTLE_LOOP_SCENARIOS.filter((entry) =>
    ["v0110_empty_static", "v0110_tier_m_density", "v0110_hud_dom_paused"].includes(entry.id)
  );
}

function parseServerMode(args: string[]): ServerMode {
  const mode = argValue(args, "--mode") ?? "preview";
  if (mode === "preview" || mode === "dev") {
    return mode;
  }
  throw new Error(`Unknown v0.110 benchmark mode ${mode}. Use preview or dev.`);
}

function argValue(args: string[], name: string): string | undefined {
  return args.find((arg) => arg.startsWith(`${name}=`))?.slice(name.length + 1);
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
  child.stdout.on("data", (chunk) => process.stdout.write(`[v0110-${serverMode}] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[v0110-${serverMode}] ${chunk}`));
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
      // Retry while Vite boots.
    }
    await new Promise((resolveRetry) => setTimeout(resolveRetry, 500));
  }
  throw new Error(`Timed out waiting for ${baseUrl}.`);
}

async function readSaveSnapshot(page: Page): Promise<string | null> {
  return page.evaluate((key) => localStorage.getItem(key), SAVE_KEY);
}

function viewportForCase(benchmarkCase: BattleLoopScenarioDefinition): { width: number; height: number } {
  return viewportSize(viewportLabelForCase(benchmarkCase));
}

function viewportLabelForCase(benchmarkCase: BattleLoopScenarioDefinition): string {
  if (benchmarkCase.id === "v0110_tier_l_density") {
    return "1920x1080";
  }
  if (benchmarkCase.category === "static") {
    return "1366x768";
  }
  return "1600x900";
}

function viewportSize(label: string): { width: number; height: number } {
  const [width, height] = label.split("x").map((value) => Number(value));
  return { width, height };
}

function renderArtifactReadme(resultCount: number): string {
  return [
    "# v0.110 Battle-Loop Phase Profiler Artifacts",
    "",
    "This folder is ignored by git and can be regenerated from the v0.110 perf scripts.",
    "",
    `Result rows: ${resultCount}.`,
    "",
    "Key files:",
    "",
    "- phase-profiler-summary.json/md",
    "- subsystem-isolation-matrix.json/md",
    "- density-scaling-report.json/md",
    "- trusted-browser-gate.json/md",
    "- before-after-delta.json/md",
    "- profiler-capability-report.json",
    "- raw-frame-intervals/*.json",
    "- raw-phase-samples/*.json",
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
