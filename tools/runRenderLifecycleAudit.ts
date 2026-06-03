import { chromium, type Page } from "@playwright/test";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import {
  V0114_ARTIFACT_DIR,
  V0114_CHECKPOINT,
  V0114_RENDER_LIFECYCLE_AUDIT_CASES,
  V0114_TITLE,
  buildV0114ArtifactSet,
  createBeforeAfterDelta,
  createMemoryTrend,
  createVisualParitySummary,
  renderArtifactReadme,
  renderCanvasDomBoundaryReportMarkdown,
  renderEmmanuelRetestChecklistMarkdown,
  renderImplementationReportMarkdown,
  renderPerformanceDeltaReportMarkdown,
  renderProceduralBatchingSpecMarkdown,
  renderRenderLifecycleAuditMarkdown,
  renderVisualParityReportMarkdown,
  renderLifecycleAuditRates,
  type RenderLifecycleAuditCase,
  type RenderLifecycleAuditResult
} from "../src/game/playtest/RenderLifecycleAuditProfile";
import {
  normalizeBattleLoopDiagnostics,
  type BattleLoopDiagnostics,
  type BattleLoopPhaseSummary
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
import {
  cloneRenderLifecycleCounters,
  createEmptyRenderLifecycleCounters,
  type RenderLifecycleCounters
} from "../src/game/systems/RenderLifecycleMetrics";

type ServerMode = "preview" | "dev";

interface BrowserSample {
  intervals: TrustedFrameInterval[];
  longTasks: PrivatePerformanceLongTask[];
  longTaskSupported: boolean;
  memoryUsedMb?: number;
}

const SAVE_KEY = "ascendant-realms-save-v1";
const OUTPUT_DIR = resolve(V0114_ARTIFACT_DIR);
const RAW_INTERVAL_DIR = resolve(OUTPUT_DIR, "raw-frame-intervals");
const RAW_PHASE_SUMMARY_DIR = resolve(OUTPUT_DIR, "raw-phase-summaries");
const RAW_RENDER_LIFECYCLE_DIR = resolve(OUTPUT_DIR, "raw-render-lifecycle");
const SCREENSHOT_DIR = resolve(OUTPUT_DIR, "screenshots");
const DEFAULT_PREVIEW_PORT = 5250;
const DEFAULT_DEV_PORT = 5251;

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  await ensureOutputDirs();

  if (args.includes("--report-only")) {
    const results = await readExistingResults();
    await writeStaticArtifacts(results);
    console.log(`v0.114 render-lifecycle reports refreshed for ${results.length} row(s).`);
    return;
  }

  const serverMode = parseServerMode(args);
  const port = Number(argValue(args, "--port") ?? process.env.ASCENDANT_V0114_PERF_PORT ?? defaultPort(serverMode));
  const warmupMs = Number(argValue(args, "--warmup-ms") ?? process.env.ASCENDANT_V0114_WARMUP_MS ?? TRUSTED_DEFAULT_WARMUP_MS);
  const sampleMs = Number(argValue(args, "--sample-ms") ?? process.env.ASCENDANT_V0114_SAMPLE_MS ?? TRUSTED_DEFAULT_SAMPLE_MS);
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
    const page = await browser.newPage({ viewport: { width: 1600, height: 900 } });
    page.setDefaultTimeout(60_000);
    page.setDefaultNavigationTimeout(120_000);
    await page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });

    const existing = await readExistingResults();
    const resultsById = new Map(existing.map((result) => [result.caseId, result]));
    for (const auditCase of cases) {
      const result =
        auditCase.surface === "campaign"
          ? await runCampaignCase(page, baseUrl, auditCase, warmupMs, sampleMs)
          : await runBattleCase(page, baseUrl, auditCase, warmupMs, sampleMs);
      resultsById.set(result.caseId, result);
      console.log(`v0.114 render-lifecycle audit complete: ${result.caseId}`);
    }
    const results = [...resultsById.values()];
    await writeStaticArtifacts(results);
    console.log(`v0.114 render-lifecycle artifacts: ${V0114_ARTIFACT_DIR}`);
  } finally {
    await browser?.close();
    server.kill();
  }
}

async function ensureOutputDirs(): Promise<void> {
  await mkdir(OUTPUT_DIR, { recursive: true });
  await mkdir(RAW_INTERVAL_DIR, { recursive: true });
  await mkdir(RAW_PHASE_SUMMARY_DIR, { recursive: true });
  await mkdir(RAW_RENDER_LIFECYCLE_DIR, { recursive: true });
  await mkdir(SCREENSHOT_DIR, { recursive: true });
}

async function runBattleCase(
  page: Page,
  baseUrl: string,
  auditCase: RenderLifecycleAuditCase,
  warmupMs: number,
  sampleMs: number
): Promise<RenderLifecycleAuditResult> {
  await launchPrivateScenario(page, baseUrl, auditCase.launchScenarioId);
  await expectBattleLoaded(page);
  const diagnostics = await applyBattleLoopDiagnostics(page, auditCase.diagnostics);
  const saveBefore = await readSaveSnapshot(page);
  const sampleStimulus = auditCase.stimulus === "command-markers" || auditCase.stimulus === "notifications";
  if (!sampleStimulus) {
    await applyAuditStimulus(page, auditCase);
  }
  if (auditCase.surface === "results") {
    return runDomSurfaceCase(page, auditCase, diagnostics, saveBefore, warmupMs, sampleMs);
  }
  await page.waitForTimeout(warmupMs);

  const countersBefore = await getPrivateCounters(page);
  await resetPhaseProfiler(page);
  await resetRenderLifecycleMetrics(page);
  if (sampleStimulus) {
    await applyAuditStimulus(page, auditCase);
  }
  const sample = await collectFrameIntervals(page, sampleMs);
  const phaseSummary = await getPhaseSummary(page);
  const renderLifecycleCounters = await getRenderLifecycleMetrics(page, sample.memoryUsedMb);
  const countersAfter = await getPrivateCounters(page, sample.memoryUsedMb);
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: sample.intervals,
    sampleDurationMs: sampleMs,
    countersBefore,
    countersAfter,
    longTasks: sample.longTasks,
    longTaskSupported: sample.longTaskSupported
  });
  const screenshotArtifact = await captureCaseScreenshot(page, auditCase.id);
  const artifacts = await writeCaseArtifacts(auditCase, sample.intervals, phaseSummary, renderLifecycleCounters);

  const saveAfter = await readSaveSnapshot(page);
  if (saveBefore !== saveAfter) {
    throw new Error(`v0.114 render-lifecycle audit mutated save/localStorage: ${auditCase.id}.`);
  }

  return {
    caseId: auditCase.id,
    title: auditCase.title,
    launchScenarioId: auditCase.launchScenarioId,
    surface: auditCase.surface,
    posture: auditCase.posture,
    diagnostics,
    stimulus: auditCase.stimulus,
    warmupMs,
    sampleMs,
    generatedAtUtc: new Date().toISOString(),
    steadyState,
    phaseSummary,
    privateCounters: countersAfter,
    renderLifecycleCounters,
    renderLifecycleRates: renderLifecycleAuditRates(renderLifecycleCounters, sampleMs),
    rawFrameIntervalArtifact: artifacts.rawFrameIntervalArtifact,
    rawPhaseSummaryArtifact: artifacts.rawPhaseSummaryArtifact,
    rawRenderLifecycleArtifact: artifacts.rawRenderLifecycleArtifact,
    screenshotArtifact
  };
}

async function runCampaignCase(
  page: Page,
  baseUrl: string,
  auditCase: RenderLifecycleAuditCase,
  warmupMs: number,
  sampleMs: number
): Promise<RenderLifecycleAuditResult> {
  await launchPrivateScenario(page, baseUrl, auditCase.launchScenarioId);
  await page.getByTestId("campaign-map").waitFor({ timeout: 90_000 });
  await page.getByTestId("campaign-selected-panel").waitFor({ timeout: 90_000 });
  const saveBefore = await readSaveSnapshot(page);
  return runDomSurfaceCase(page, auditCase, normalizeBattleLoopDiagnostics(auditCase.diagnostics), saveBefore, warmupMs, sampleMs);
}

async function runDomSurfaceCase(
  page: Page,
  auditCase: RenderLifecycleAuditCase,
  diagnostics: BattleLoopDiagnostics,
  saveBefore: string | null,
  warmupMs: number,
  sampleMs: number
): Promise<RenderLifecycleAuditResult> {
  await page.waitForTimeout(warmupMs);

  const countersBefore = await getDomOnlyCounters(page);
  const sample = await collectFrameIntervals(page, sampleMs);
  const countersAfter = await getDomOnlyCounters(page, sample.memoryUsedMb);
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: sample.intervals,
    sampleDurationMs: sampleMs,
    countersBefore,
    countersAfter,
    longTasks: sample.longTasks,
    longTaskSupported: sample.longTaskSupported
  });
  const renderLifecycleCounters: RenderLifecycleCounters = {
    ...createEmptyRenderLifecycleCounters(),
    domNodesCreated: countersAfter.domNodes,
    retainedObjectCount: countersAfter.domNodes,
    detachedDomNodes: 0,
    memoryUsedMb: sample.memoryUsedMb
  };
  const screenshotArtifact = await captureCaseScreenshot(page, auditCase.id);
  const rawPath = resolve(RAW_RENDER_LIFECYCLE_DIR, `${auditCase.id}.json`);
  await writeFile(rawPath, `${JSON.stringify({ caseId: auditCase.id, renderLifecycleCounters }, null, 2)}\n`, "utf8");
  const rawIntervals = resolve(RAW_INTERVAL_DIR, `${auditCase.id}.json`);
  await writeFile(rawIntervals, `${JSON.stringify({ caseId: auditCase.id, intervals: sample.intervals }, null, 2)}\n`, "utf8");

  const saveAfter = await readSaveSnapshot(page);
  if (saveBefore !== saveAfter) {
    throw new Error(`v0.114 DOM-surface render-lifecycle audit mutated save/localStorage: ${auditCase.id}.`);
  }

  return {
    caseId: auditCase.id,
    title: auditCase.title,
    launchScenarioId: auditCase.launchScenarioId,
    surface: auditCase.surface,
    posture: auditCase.posture,
    diagnostics,
    stimulus: auditCase.stimulus,
    warmupMs,
    sampleMs,
    generatedAtUtc: new Date().toISOString(),
    steadyState,
    privateCounters: countersAfter,
    renderLifecycleCounters,
    renderLifecycleRates: renderLifecycleAuditRates(renderLifecycleCounters, sampleMs),
    rawFrameIntervalArtifact: displayPath(rawIntervals),
    rawRenderLifecycleArtifact: displayPath(rawPath),
    screenshotArtifact
  };
}

async function launchPrivateScenario(page: Page, baseUrl: string, scenarioId: string): Promise<void> {
  await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 45_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  await page.getByTestId(`playtest-scenario-${scenarioId}`).scrollIntoViewIfNeeded();
  await page.getByTestId(`playtest-scenario-${scenarioId}`).click();
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

async function applyBattleLoopDiagnostics(page: Page, diagnostics: Partial<BattleLoopDiagnostics>): Promise<BattleLoopDiagnostics> {
  const applied = await page.evaluate((nextDiagnostics) => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    return hooks?.setBattleLoopDiagnostics?.({ phaseProfiler: "on", ...nextDiagnostics }) ?? null;
  }, diagnostics);
  if (!applied) {
    throw new Error("v0.114 battle-loop diagnostics were not available in the private battle scene.");
  }
  await nextFrameLatency(page);
  return normalizeBattleLoopDiagnostics(applied as Partial<BattleLoopDiagnostics>);
}

async function applyAuditStimulus(page: Page, auditCase: RenderLifecycleAuditCase): Promise<void> {
  if (auditCase.stimulus === "move-player-units") {
    await page.evaluate(() => {
      const scene = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
      if (!scene?.units || !scene?.activeMap) {
        return;
      }
      const playerUnits = scene.units.filter((unit: any) => unit.alive && unit.team === "player").slice(0, 12);
      const target = {
        x: Math.round(scene.activeMap.width * 0.56),
        y: Math.round(scene.activeMap.height * 0.48)
      };
      playerUnits.forEach((unit: any, index: number) => {
        unit.attackTargetId = undefined;
        unit.attackMove = false;
        unit.moveOrderCombatSuppressionSeconds = 1.5;
        unit.moveTarget = { x: target.x + index * 6, y: target.y + index * 4 };
      });
      scene.selectionSystem?.setSelection?.(playerUnits);
      scene.showCommandFeedbackMarker?.({ kind: "move", point: target, count: playerUnits.length });
    });
  }
  if (auditCase.stimulus === "command-markers") {
    await page.evaluate(() => {
      const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
      for (let index = 0; index < 28; index += 1) {
        hooks?.showCommandFeedbackMarker?.("focus", 700 + index * 8, 560 + index * 4);
      }
    });
  }
  if (auditCase.stimulus === "notifications") {
    await page.evaluate(() => {
      const scene = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
      for (let index = 0; index < 8; index += 1) {
        scene?.showMessage?.(`v0.114 notification sample ${index + 1}`, scene.hero?.position?.x, (scene.hero?.position?.y ?? 0) - 64 - index * 4, "#74d3f2", {
          priority: index % 2 === 0 ? "command" : "pressure",
          durationSeconds: 4
        });
      }
    });
  }
  if (auditCase.stimulus === "results") {
    await page.evaluate(() => {
      const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
      hooks?.forceBattleVictory?.();
    });
    await page.waitForFunction(
      () => Boolean((window as any).ascendantRealmsGame?.scene.getScene("ResultsScene")?.scene?.isActive?.()),
      null,
      { timeout: 90_000 }
    );
    await page.locator(".results-panel").waitFor({ timeout: 90_000 });
  }
  await nextFrameLatency(page);
}

async function resetPhaseProfiler(page: Page): Promise<void> {
  await page.evaluate(() => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.resetBattleLoopPhaseProfiler?.()) {
      throw new Error("Missing v0.114 phase profiler reset hook.");
    }
  });
}

async function getPhaseSummary(page: Page): Promise<BattleLoopPhaseSummary> {
  const summary = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getBattleLoopPhaseSummary?.());
  if (!summary) {
    throw new Error("Missing v0.114 battle-loop phase summary.");
  }
  return summary as BattleLoopPhaseSummary;
}

async function resetRenderLifecycleMetrics(page: Page): Promise<void> {
  await page.evaluate(() => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.resetRenderLifecycleMetrics?.()) {
      throw new Error("Missing v0.114 render-lifecycle metrics reset hook.");
    }
  });
}

async function getRenderLifecycleMetrics(page: Page, memoryUsedMb?: number): Promise<RenderLifecycleCounters> {
  const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getRenderLifecycleMetrics?.());
  return { ...cloneRenderLifecycleCounters(counters ?? createEmptyRenderLifecycleCounters()), memoryUsedMb };
}

async function getPrivateCounters(page: Page, memoryUsedMb?: number): Promise<PrivatePerformanceCounters> {
  const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getPrivatePerformanceCounters?.());
  if (!counters) {
    throw new Error("Missing private performance counters for v0.114 audit.");
  }
  return { ...defaultPerformanceCounters(), ...counters, memoryUsedMb };
}

async function getDomOnlyCounters(page: Page, memoryUsedMb?: number): Promise<PrivatePerformanceCounters> {
  const domNodes = await page.evaluate(() => document.querySelectorAll("*").length);
  return { ...defaultPerformanceCounters(), domNodes, memoryUsedMb };
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

async function captureCaseScreenshot(page: Page, caseId: string): Promise<string> {
  const path = resolve(SCREENSHOT_DIR, `${caseId}.png`);
  await page.screenshot({ path, fullPage: true });
  return displayPath(path);
}

async function writeCaseArtifacts(
  auditCase: RenderLifecycleAuditCase,
  intervals: TrustedFrameInterval[],
  phaseSummary: BattleLoopPhaseSummary,
  renderLifecycleCounters: RenderLifecycleCounters
): Promise<{ rawFrameIntervalArtifact: string; rawPhaseSummaryArtifact: string; rawRenderLifecycleArtifact: string }> {
  const rawPath = resolve(RAW_INTERVAL_DIR, `${auditCase.id}.json`);
  const phaseSummaryPath = resolve(RAW_PHASE_SUMMARY_DIR, `${auditCase.id}.json`);
  const renderLifecyclePath = resolve(RAW_RENDER_LIFECYCLE_DIR, `${auditCase.id}.json`);
  await writeFile(rawPath, `${JSON.stringify({ caseId: auditCase.id, intervals }, null, 2)}\n`, "utf8");
  await writeFile(phaseSummaryPath, `${JSON.stringify({ caseId: auditCase.id, phaseSummary }, null, 2)}\n`, "utf8");
  await writeFile(renderLifecyclePath, `${JSON.stringify({ caseId: auditCase.id, renderLifecycleCounters }, null, 2)}\n`, "utf8");
  return {
    rawFrameIntervalArtifact: displayPath(rawPath),
    rawPhaseSummaryArtifact: displayPath(phaseSummaryPath),
    rawRenderLifecycleArtifact: displayPath(renderLifecyclePath)
  };
}

async function writeStaticArtifacts(results: RenderLifecycleAuditResult[]): Promise<void> {
  const sorted = sortExistingResults(results);
  const artifactSet = buildV0114ArtifactSet(sorted);
  const delta = createBeforeAfterDelta(sorted);
  const memoryTrend = createMemoryTrend(sorted);
  const visualParity = createVisualParitySummary(sorted);

  await writeFile(resolve(OUTPUT_DIR, "lifecycle-audit.json"), `${JSON.stringify({ rows: sorted }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.json"), `${JSON.stringify(delta, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.md"), renderPerformanceDeltaReportMarkdown(sorted), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "memory-trend.json"), `${JSON.stringify(memoryTrend, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "visual-parity.json"), `${JSON.stringify(visualParity, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "README.md"), renderArtifactReadme(sorted.length), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "v0114-artifact-set.json"), `${JSON.stringify(artifactSet, null, 2)}\n`, "utf8");

  await writeFile(resolve("docs", "V0114_RENDER_LIFECYCLE_AUDIT.md"), renderRenderLifecycleAuditMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0114_PROCEDURAL_BATCHING_SPEC.md"), renderProceduralBatchingSpecMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0114_CANVAS_DOM_BOUNDARY_REPORT.md"), renderCanvasDomBoundaryReportMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0114_VISUAL_PARITY_REPORT.md"), renderVisualParityReportMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0114_PERFORMANCE_DELTA_REPORT.md"), renderPerformanceDeltaReportMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0114_IMPLEMENTATION_REPORT.md"), renderImplementationReportMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0114_EMMANUEL_RETEST_CHECKLIST.md"), renderEmmanuelRetestChecklistMarkdown(), "utf8");
}

async function readExistingResults(): Promise<RenderLifecycleAuditResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "lifecycle-audit.json"), "utf8")) as {
      rows?: RenderLifecycleAuditResult[];
    };
    return Array.isArray(parsed.rows) ? parsed.rows : [];
  } catch {
    return [];
  }
}

function resolveCases(args: string[]): RenderLifecycleAuditCase[] {
  const caseArg = argValue(args, "--cases");
  if (!caseArg) {
    return V0114_RENDER_LIFECYCLE_AUDIT_CASES;
  }
  return caseArg
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0)
    .map((caseId) => {
      const found = V0114_RENDER_LIFECYCLE_AUDIT_CASES.find((entry) => entry.id === caseId);
      if (!found) {
        throw new Error(`Unknown v0.114 render-lifecycle case ${caseId}.`);
      }
      return found;
    });
}

function parseServerMode(args: string[]): ServerMode {
  const mode = argValue(args, "--mode") ?? "preview";
  if (mode === "preview" || mode === "dev") {
    return mode;
  }
  throw new Error(`Unknown v0.114 benchmark mode ${mode}. Use preview or dev.`);
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
  child.stdout.on("data", (chunk) => process.stdout.write(`[v0114-${serverMode}] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[v0114-${serverMode}] ${chunk}`));
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

function sortExistingResults(results: RenderLifecycleAuditResult[]): RenderLifecycleAuditResult[] {
  const order = new Map(V0114_RENDER_LIFECYCLE_AUDIT_CASES.map((entry, index) => [entry.id, index]));
  return [...results].sort((left, right) => (order.get(left.caseId) ?? 999) - (order.get(right.caseId) ?? 999));
}

function displayPath(path: string): string {
  return path.replaceAll("\\", "/").replace(`${process.cwd().replaceAll("\\", "/")}/`, "");
}

void V0114_CHECKPOINT;
void V0114_TITLE;

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
