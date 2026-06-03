import { chromium, type Page } from "@playwright/test";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import {
  V0113_ARTIFACT_DIR,
  V0113_CHECKPOINT,
  V0113_SPATIAL_QUERY_PROFILE_CASES,
  V0113_TITLE,
  buildV0113ArtifactSet,
  createDensityMatrix,
  createOldNewComparison,
  createV0113ParitySummary,
  renderArtifactReadme,
  renderBeforeAfterDeltaMarkdown,
  renderEmmanuelRetestChecklistMarkdown,
  renderEvidenceBackedOptimizationMarkdown,
  renderImplementationReportMarkdown,
  renderPathRequestDedupSpecMarkdown,
  renderRollbackPostureMarkdown,
  renderSpatialIndexDecisionMarkdown,
  renderSpatialQueryProfileMarkdown,
  renderTargetAcquisitionParityMarkdown,
  spatialQueryRatesPerSecond,
  type SpatialQueryProfileCase,
  type SpatialQueryProfileResult
} from "../src/game/playtest/SpatialQueryPathingProfile";
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
import { createEmptySpatialQueryCounters, type SpatialQueryCounters } from "../src/game/systems/SpatialQueryMetrics";

type ServerMode = "preview" | "dev";

interface BrowserSample {
  intervals: TrustedFrameInterval[];
  longTasks: PrivatePerformanceLongTask[];
  longTaskSupported: boolean;
  memoryUsedMb?: number;
}

const SAVE_KEY = "ascendant-realms-save-v1";
const OUTPUT_DIR = resolve(V0113_ARTIFACT_DIR);
const RAW_INTERVAL_DIR = resolve(OUTPUT_DIR, "raw-frame-intervals");
const RAW_PHASE_SUMMARY_DIR = resolve(OUTPUT_DIR, "raw-phase-summaries");
const RAW_SPATIAL_QUERY_DIR = resolve(OUTPUT_DIR, "raw-spatial-query");
const DEFAULT_PREVIEW_PORT = 5240;
const DEFAULT_DEV_PORT = 5241;

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  await mkdir(OUTPUT_DIR, { recursive: true });
  await mkdir(RAW_INTERVAL_DIR, { recursive: true });
  await mkdir(RAW_PHASE_SUMMARY_DIR, { recursive: true });
  await mkdir(RAW_SPATIAL_QUERY_DIR, { recursive: true });

  if (args.includes("--report-only")) {
    const results = await readExistingResults();
    await writeStaticArtifacts(results);
    console.log(`v0.113 spatial-query reports refreshed for ${results.length} row(s).`);
    return;
  }

  const serverMode = parseServerMode(args);
  const port = Number(argValue(args, "--port") ?? process.env.ASCENDANT_V0113_PERF_PORT ?? defaultPort(serverMode));
  const warmupMs = Number(argValue(args, "--warmup-ms") ?? process.env.ASCENDANT_V0113_WARMUP_MS ?? TRUSTED_DEFAULT_WARMUP_MS);
  const sampleMs = Number(argValue(args, "--sample-ms") ?? process.env.ASCENDANT_V0113_SAMPLE_MS ?? TRUSTED_DEFAULT_SAMPLE_MS);
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
    for (const profileCase of cases) {
      const result = await runProfileCase(page, baseUrl, profileCase, warmupMs, sampleMs);
      resultsById.set(result.caseId, result);
      console.log(`v0.113 spatial-query profile complete: ${result.caseId}`);
    }
    const results = [...resultsById.values()];
    await writeStaticArtifacts(results);
    console.log(`v0.113 spatial-query artifacts: ${V0113_ARTIFACT_DIR}`);
  } finally {
    await browser?.close();
    server.kill();
  }
}

async function runProfileCase(
  page: Page,
  baseUrl: string,
  profileCase: SpatialQueryProfileCase,
  warmupMs: number,
  sampleMs: number
): Promise<SpatialQueryProfileResult> {
  await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 45_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  const saveBefore = await readSaveSnapshot(page);

  await page.getByTestId(`playtest-scenario-${profileCase.launchScenarioId}`).scrollIntoViewIfNeeded();
  await page.getByTestId(`playtest-scenario-${profileCase.launchScenarioId}`).click();
  await expectBattleLoaded(page);
  const diagnostics = await applyBattleLoopDiagnostics(page, profileCase.diagnostics);
  await applyProfileStimulus(page, profileCase);
  await page.waitForTimeout(warmupMs);

  const countersBefore = await getCounters(page);
  await resetPhaseProfiler(page);
  await resetSpatialMetrics(page);
  const sample = await collectFrameIntervals(page, sampleMs);
  const phaseSummary = await getPhaseSummary(page);
  const spatialQueryCounters = await getSpatialMetrics(page);
  const countersAfter = await getCounters(page, sample.memoryUsedMb);
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: sample.intervals,
    sampleDurationMs: sampleMs,
    countersBefore,
    countersAfter,
    longTasks: sample.longTasks,
    longTaskSupported: sample.longTaskSupported
  });
  const artifacts = await writeCaseArtifacts(profileCase, sample.intervals, phaseSummary, spatialQueryCounters);

  const saveAfter = await readSaveSnapshot(page);
  if (saveBefore !== saveAfter) {
    throw new Error(`v0.113 spatial-query profile mutated save/localStorage: ${profileCase.id}.`);
  }

  return {
    caseId: profileCase.id,
    title: profileCase.title,
    launchScenarioId: profileCase.launchScenarioId,
    posture: profileCase.posture,
    diagnostics,
    stimulus: profileCase.stimulus,
    warmupMs,
    sampleMs,
    generatedAtUtc: new Date().toISOString(),
    steadyState,
    phaseSummary,
    spatialQueryCounters,
    spatialRatesPerSecond: spatialQueryRatesPerSecond(spatialQueryCounters, sampleMs),
    rawFrameIntervalArtifact: artifacts.rawFrameIntervalArtifact,
    rawPhaseSummaryArtifact: artifacts.rawPhaseSummaryArtifact,
    rawSpatialQueryArtifact: artifacts.rawSpatialQueryArtifact
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

async function applyBattleLoopDiagnostics(page: Page, diagnostics: Partial<BattleLoopDiagnostics>): Promise<BattleLoopDiagnostics> {
  const applied = await page.evaluate((nextDiagnostics) => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    return hooks?.setBattleLoopDiagnostics?.({ phaseProfiler: "on", ...nextDiagnostics }) ?? null;
  }, diagnostics);
  if (!applied) {
    throw new Error("v0.113 battle-loop diagnostics were not available in the private battle scene.");
  }
  await nextFrameLatency(page);
  return normalizeBattleLoopDiagnostics(applied as Partial<BattleLoopDiagnostics>);
}

async function applyProfileStimulus(page: Page, profileCase: SpatialQueryProfileCase): Promise<void> {
  if (profileCase.posture === "hero-only" || profileCase.posture === "hero-worker" || profileCase.posture === "five-troops") {
    await applyUnitCountProfileStimulus(page, profileCase.posture);
  }
  if (profileCase.stimulus !== "move-player-units") {
    return;
  }
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
  });
  await nextFrameLatency(page);
}

async function applyUnitCountProfileStimulus(page: Page, posture: SpatialQueryProfileCase["posture"]): Promise<void> {
  await page.evaluate((profilePosture) => {
    const scene = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.units || !scene?.hero) {
      return;
    }
    const hero = scene.hero;
    const alivePlayerUnits = scene.units.filter((unit: any) => unit.alive && unit.team === "player");
    const worker = alivePlayerUnits.find((unit: any) => unit !== hero && unit.definition?.id === "worker");
    const combatTroops = alivePlayerUnits.filter((unit: any) => unit !== hero && unit.definition?.id !== "worker");
    const keepUnits =
      profilePosture === "hero-only"
        ? [hero]
        : profilePosture === "hero-worker"
          ? [hero, worker].filter(Boolean)
          : [hero, ...combatTroops].filter(Boolean).slice(0, 5);
    const keepIds = new Set(keepUnits.map((unit: any) => unit.id));
    scene.units.forEach((unit: any) => {
      if (keepIds.has(unit.id)) {
        unit.attackTargetId = undefined;
        unit.attackMove = false;
        unit.moveTarget = undefined;
        unit.moveOrderCombatSuppressionSeconds = 1.5;
        return;
      }
      unit.alive = false;
      unit.destroyView?.();
    });
    scene.units = scene.units.filter((unit: any) => keepIds.has(unit.id));
    scene.projectiles?.forEach((projectile: any) => projectile.destroyView?.());
    scene.projectiles = [];
    scene.selectionSystem?.setSelection?.(keepUnits);
    scene.refreshBattleHud?.(0);
  }, posture);
  await nextFrameLatency(page);
}

async function resetPhaseProfiler(page: Page): Promise<void> {
  await page.evaluate(() => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.resetBattleLoopPhaseProfiler?.()) {
      throw new Error("Missing v0.113 phase profiler reset hook.");
    }
  });
}

async function getPhaseSummary(page: Page): Promise<BattleLoopPhaseSummary> {
  const summary = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getBattleLoopPhaseSummary?.());
  if (!summary) {
    throw new Error("Missing v0.113 battle-loop phase summary.");
  }
  return summary as BattleLoopPhaseSummary;
}

async function resetSpatialMetrics(page: Page): Promise<void> {
  await page.evaluate(() => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.resetSpatialQueryMetrics?.()) {
      throw new Error("Missing v0.113 spatial-query metrics reset hook.");
    }
  });
}

async function getSpatialMetrics(page: Page): Promise<SpatialQueryCounters> {
  const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getSpatialQueryMetrics?.());
  return { ...createEmptySpatialQueryCounters(), ...(counters ?? {}) };
}

async function getCounters(page: Page, memoryUsedMb?: number): Promise<PrivatePerformanceCounters> {
  const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getPrivatePerformanceCounters?.());
  if (!counters) {
    throw new Error("Missing private performance counters for v0.113 profile.");
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
  profileCase: SpatialQueryProfileCase,
  intervals: TrustedFrameInterval[],
  phaseSummary: BattleLoopPhaseSummary,
  spatialQueryCounters: SpatialQueryCounters
): Promise<{ rawFrameIntervalArtifact: string; rawPhaseSummaryArtifact: string; rawSpatialQueryArtifact: string }> {
  const rawPath = resolve(RAW_INTERVAL_DIR, `${profileCase.id}.json`);
  const phaseSummaryPath = resolve(RAW_PHASE_SUMMARY_DIR, `${profileCase.id}.json`);
  const spatialPath = resolve(RAW_SPATIAL_QUERY_DIR, `${profileCase.id}.json`);
  await writeFile(rawPath, `${JSON.stringify({ caseId: profileCase.id, intervals }, null, 2)}\n`, "utf8");
  await writeFile(phaseSummaryPath, `${JSON.stringify({ caseId: profileCase.id, phaseSummary }, null, 2)}\n`, "utf8");
  await writeFile(spatialPath, `${JSON.stringify({ caseId: profileCase.id, spatialQueryCounters }, null, 2)}\n`, "utf8");
  return {
    rawFrameIntervalArtifact: displayPath(rawPath),
    rawPhaseSummaryArtifact: displayPath(phaseSummaryPath),
    rawSpatialQueryArtifact: displayPath(spatialPath)
  };
}

async function writeStaticArtifacts(results: SpatialQueryProfileResult[]): Promise<void> {
  const sorted = sortExistingResults(results);
  const artifactSet = buildV0113ArtifactSet(sorted);
  const densityMatrix = createDensityMatrix(sorted);
  const oldNewComparison = createOldNewComparison(sorted);
  const parity = createV0113ParitySummary(sorted);

  await writeFile(resolve(OUTPUT_DIR, "query-profile.json"), `${JSON.stringify({ rows: sorted }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "density-matrix.json"), `${JSON.stringify(densityMatrix, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "old-new-comparison.json"), `${JSON.stringify(oldNewComparison, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "parity-summary.json"), `${JSON.stringify(parity, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.md"), renderBeforeAfterDeltaMarkdown(sorted), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "rollback-posture.md"), renderRollbackPostureMarkdown(), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "README.md"), renderArtifactReadme(sorted.length), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "v0113-artifact-set.json"), `${JSON.stringify(artifactSet, null, 2)}\n`, "utf8");

  await writeFile(resolve("docs", "V0113_SPATIAL_QUERY_PROFILE.md"), renderSpatialQueryProfileMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0113_PATH_REQUEST_DEDUP_SPEC.md"), renderPathRequestDedupSpecMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0113_TARGET_ACQUISITION_PARITY_REPORT.md"), renderTargetAcquisitionParityMarkdown(parity), "utf8");
  await writeFile(resolve("docs", "V0113_SPATIAL_INDEX_DECISION_REPORT.md"), renderSpatialIndexDecisionMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0113_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md"), renderEvidenceBackedOptimizationMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0113_IMPLEMENTATION_REPORT.md"), renderImplementationReportMarkdown(sorted), "utf8");
  await writeFile(resolve("docs", "V0113_EMMANUEL_RETEST_CHECKLIST.md"), renderEmmanuelRetestChecklistMarkdown(), "utf8");
}

async function readExistingResults(): Promise<SpatialQueryProfileResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "query-profile.json"), "utf8")) as {
      rows?: SpatialQueryProfileResult[];
    };
    return Array.isArray(parsed.rows) ? parsed.rows : [];
  } catch {
    return [];
  }
}

function resolveCases(args: string[]): SpatialQueryProfileCase[] {
  const caseArg = argValue(args, "--cases");
  if (!caseArg) {
    return V0113_SPATIAL_QUERY_PROFILE_CASES;
  }
  return caseArg
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0)
    .map((caseId) => {
      const found = V0113_SPATIAL_QUERY_PROFILE_CASES.find((entry) => entry.id === caseId);
      if (!found) {
        throw new Error(`Unknown v0.113 spatial-query case ${caseId}.`);
      }
      return found;
    });
}

function parseServerMode(args: string[]): ServerMode {
  const mode = argValue(args, "--mode") ?? "preview";
  if (mode === "preview" || mode === "dev") {
    return mode;
  }
  throw new Error(`Unknown v0.113 benchmark mode ${mode}. Use preview or dev.`);
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
  child.stdout.on("data", (chunk) => process.stdout.write(`[v0113-${serverMode}] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[v0113-${serverMode}] ${chunk}`));
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

function sortExistingResults(results: SpatialQueryProfileResult[]): SpatialQueryProfileResult[] {
  const order = new Map(V0113_SPATIAL_QUERY_PROFILE_CASES.map((entry, index) => [entry.id, index]));
  return [...results].sort((left, right) => (order.get(left.caseId) ?? 999) - (order.get(right.caseId) ?? 999));
}

function displayPath(path: string): string {
  return path.replaceAll("\\", "/").replace(`${process.cwd().replaceAll("\\", "/")}/`, "");
}

void V0113_CHECKPOINT;
void V0113_TITLE;

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
