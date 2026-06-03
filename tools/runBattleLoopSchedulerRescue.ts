import { chromium, type Page } from "@playwright/test";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import {
  V0112_ALLOCATION_AUDIT_ROWS,
  V0112_ARTIFACT_DIR,
  V0112_CHECKPOINT,
  V0112_IDLE_COST_CASES,
  V0112_SCHEDULER_MAP,
  V0112_TITLE,
  buildV0112ArtifactSet,
  createV0112ParitySummary,
  renderAllocationAuditMarkdown,
  renderBeforeAfterDeltaMarkdown,
  renderEmmanuelRetestChecklistMarkdown,
  renderIdleCostMatrixMarkdown,
  renderImplementationReportMarkdown,
  renderOptimizationReportMarkdown,
  renderParityReportMarkdown,
  renderSchedulerMapMarkdown,
  type IdleCostCaseDefinition,
  type IdleCostMatrixResult
} from "../src/game/playtest/BattleLoopSchedulerRescue";
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

type ServerMode = "preview" | "dev";

interface BrowserSample {
  intervals: TrustedFrameInterval[];
  longTasks: PrivatePerformanceLongTask[];
  longTaskSupported: boolean;
  memoryUsedMb?: number;
}

const SAVE_KEY = "ascendant-realms-save-v1";
const OUTPUT_DIR = resolve(V0112_ARTIFACT_DIR);
const RAW_INTERVAL_DIR = resolve(OUTPUT_DIR, "raw-frame-intervals");
const RAW_PHASE_SUMMARY_DIR = resolve(OUTPUT_DIR, "raw-phase-summaries");
const DEFAULT_PREVIEW_PORT = 5230;
const DEFAULT_DEV_PORT = 5231;

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  await mkdir(OUTPUT_DIR, { recursive: true });
  await mkdir(RAW_INTERVAL_DIR, { recursive: true });
  await mkdir(RAW_PHASE_SUMMARY_DIR, { recursive: true });

  if (args.includes("--allocation-audit") || args.includes("--report-only")) {
    const results = await readExistingResults();
    await writeStaticArtifacts(results);
    console.log(`v0.112 allocation/scheduler reports refreshed for ${results.length} idle row(s).`);
    return;
  }

  if (!args.includes("--idle-cost-matrix")) {
    await writeStaticArtifacts(await readExistingResults());
    console.log(`v0.112 reports refreshed: ${V0112_ARTIFACT_DIR}`);
    return;
  }

  const serverMode = parseServerMode(args);
  const port = Number(argValue(args, "--port") ?? process.env.ASCENDANT_V0112_PERF_PORT ?? defaultPort(serverMode));
  const warmupMs = Number(argValue(args, "--warmup-ms") ?? process.env.ASCENDANT_V0112_WARMUP_MS ?? TRUSTED_DEFAULT_WARMUP_MS);
  const sampleMs = Number(argValue(args, "--sample-ms") ?? process.env.ASCENDANT_V0112_SAMPLE_MS ?? TRUSTED_DEFAULT_SAMPLE_MS);
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
    for (const idleCase of cases) {
      const result = await runIdleCase(page, baseUrl, idleCase, warmupMs, sampleMs);
      resultsById.set(result.caseId, result);
      console.log(`v0.112 idle-cost profile complete: ${result.caseId}`);
    }
    const results = [...resultsById.values()];
    await writeStaticArtifacts(results);
    console.log(`v0.112 battle-loop scheduler artifacts: ${V0112_ARTIFACT_DIR}`);
  } finally {
    await browser?.close();
    server.kill();
  }
}

async function runIdleCase(
  page: Page,
  baseUrl: string,
  idleCase: IdleCostCaseDefinition,
  warmupMs: number,
  sampleMs: number
): Promise<IdleCostMatrixResult> {
  await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 45_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  const saveBefore = await readSaveSnapshot(page);

  await page.getByTestId(`playtest-scenario-${idleCase.launchScenarioId}`).scrollIntoViewIfNeeded();
  await page.getByTestId(`playtest-scenario-${idleCase.launchScenarioId}`).click();
  await expectBattleLoaded(page);
  const diagnostics = await applyBattleLoopDiagnostics(page, idleCase.diagnostics);
  await applyIdleCaseStimulus(page, idleCase);
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
  const artifacts = await writeCaseArtifacts(idleCase, sample.intervals, phaseSummary);

  const saveAfter = await readSaveSnapshot(page);
  if (saveBefore !== saveAfter) {
    throw new Error(`v0.112 idle-cost matrix mutated save/localStorage: ${idleCase.id}.`);
  }

  return {
    caseId: idleCase.id,
    title: idleCase.title,
    launchScenarioId: idleCase.launchScenarioId,
    posture: idleCase.posture,
    diagnostics,
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

async function applyBattleLoopDiagnostics(page: Page, diagnostics: Partial<BattleLoopDiagnostics>): Promise<BattleLoopDiagnostics> {
  const applied = await page.evaluate((nextDiagnostics) => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    return hooks?.setBattleLoopDiagnostics?.({ phaseProfiler: "on", ...nextDiagnostics }) ?? null;
  }, diagnostics);
  if (!applied) {
    throw new Error("v0.112 battle-loop diagnostics were not available in the private battle scene.");
  }
  await nextFrameLatency(page);
  return normalizeBattleLoopDiagnostics(applied as Partial<BattleLoopDiagnostics>);
}

async function applyIdleCaseStimulus(page: Page, idleCase: IdleCostCaseDefinition): Promise<void> {
  if (idleCase.id !== "v0112_tier_m_moving") {
    return;
  }
  await page.evaluate(() => {
    const scene = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
    if (!scene?.units || !scene?.activeMap) {
      return;
    }
    const playerUnits = scene.units.filter((unit: any) => unit.alive && unit.team === "player").slice(0, 8);
    const target = {
      x: Math.round(scene.activeMap.width * 0.54),
      y: Math.round(scene.activeMap.height * 0.48)
    };
    playerUnits.forEach((unit: any, index: number) => {
      unit.attackTargetId = undefined;
      unit.attackMove = false;
      unit.moveOrderCombatSuppressionSeconds = 1.5;
      unit.moveTarget = { x: target.x + index * 8, y: target.y + index * 5 };
    });
    scene.selectionSystem?.setSelection?.(playerUnits);
  });
  await nextFrameLatency(page);
}

async function resetPhaseProfiler(page: Page): Promise<void> {
  await page.evaluate(() => {
    const hooks = (window as any).__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.resetBattleLoopPhaseProfiler?.()) {
      throw new Error("Missing v0.112 phase profiler reset hook.");
    }
  });
}

async function getPhaseSummary(page: Page): Promise<BattleLoopPhaseSummary> {
  const summary = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getBattleLoopPhaseSummary?.());
  if (!summary) {
    throw new Error("Missing v0.112 battle-loop phase summary.");
  }
  return summary as BattleLoopPhaseSummary;
}

async function getCounters(page: Page, memoryUsedMb?: number): Promise<PrivatePerformanceCounters> {
  const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getPrivatePerformanceCounters?.());
  if (!counters) {
    throw new Error("Missing private performance counters for v0.112 benchmark.");
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
  idleCase: IdleCostCaseDefinition,
  intervals: TrustedFrameInterval[],
  phaseSummary: BattleLoopPhaseSummary
): Promise<{ rawFrameIntervalArtifact: string; rawPhaseSummaryArtifact: string }> {
  const rawPath = resolve(RAW_INTERVAL_DIR, `${idleCase.id}.json`);
  const phaseSummaryPath = resolve(RAW_PHASE_SUMMARY_DIR, `${idleCase.id}.json`);
  await writeFile(rawPath, `${JSON.stringify({ caseId: idleCase.id, intervals }, null, 2)}\n`, "utf8");
  await writeFile(phaseSummaryPath, `${JSON.stringify({ caseId: idleCase.id, phaseSummary }, null, 2)}\n`, "utf8");
  return {
    rawFrameIntervalArtifact: displayPath(rawPath),
    rawPhaseSummaryArtifact: displayPath(phaseSummaryPath)
  };
}

async function writeStaticArtifacts(results: IdleCostMatrixResult[]): Promise<void> {
  const artifactSet = buildV0112ArtifactSet(results);
  const parity = createV0112ParitySummary(results);
  const beforeAfterDelta = {
    schemaVersion: 1,
    checkpoint: V0112_CHECKPOINT,
    title: V0112_TITLE,
    beforeEvidence: ["docs/V0110_DENSITY_SCALING_REPORT.md", "docs/V0110_ROOT_CAUSE_CLASSIFICATION.md", "docs/V0111_CLEAN_PROFILE_BENCHMARK.md"],
    runtimeOptimizationIds: V0112_ALLOCATION_AUDIT_ROWS.map((row) => row.id),
    idleCaseCount: results.length,
    scopeGuard: "No gameplay, balance, save, stable-ID, art, engine, desktop, AI-decision, or path-output changes are authorized by v0.112."
  };

  await writeFile(resolve(OUTPUT_DIR, "scheduler-map.json"), `${JSON.stringify({ rows: V0112_SCHEDULER_MAP }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "allocation-audit.json"), `${JSON.stringify({ rows: V0112_ALLOCATION_AUDIT_ROWS }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "idle-cost-matrix.json"), `${JSON.stringify({ rows: results }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "parity-summary.json"), `${JSON.stringify(parity, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.json"), `${JSON.stringify(beforeAfterDelta, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "before-after-delta.md"), renderBeforeAfterDeltaMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "README.md"), renderArtifactReadme(results.length), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "v0112-artifact-set.json"), `${JSON.stringify(artifactSet, null, 2)}\n`, "utf8");

  await writeFile(resolve("docs", "V0112_BATTLE_LOOP_SCHEDULER_MAP.md"), renderSchedulerMapMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0112_HOT_PATH_ALLOCATION_AUDIT.md"), renderAllocationAuditMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0112_IDLE_COST_MATRIX.md"), renderIdleCostMatrixMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0112_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md"), renderOptimizationReportMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0112_PARITY_REPORT.md"), renderParityReportMarkdown(parity), "utf8");
  await writeFile(resolve("docs", "V0112_IMPLEMENTATION_REPORT.md"), renderImplementationReportMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0112_EMMANUEL_RETEST_CHECKLIST.md"), renderEmmanuelRetestChecklistMarkdown(), "utf8");
}

async function readExistingResults(): Promise<IdleCostMatrixResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "idle-cost-matrix.json"), "utf8")) as {
      rows?: IdleCostMatrixResult[];
    };
    return Array.isArray(parsed.rows) ? parsed.rows : [];
  } catch {
    return [];
  }
}

function resolveCases(args: string[]): IdleCostCaseDefinition[] {
  const caseArg = argValue(args, "--cases");
  if (!caseArg) {
    return V0112_IDLE_COST_CASES;
  }
  return caseArg
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0)
    .map((caseId) => {
      const found = V0112_IDLE_COST_CASES.find((entry) => entry.id === caseId);
      if (!found) {
        throw new Error(`Unknown v0.112 idle-cost case ${caseId}.`);
      }
      return found;
    });
}

function parseServerMode(args: string[]): ServerMode {
  const mode = argValue(args, "--mode") ?? "preview";
  if (mode === "preview" || mode === "dev") {
    return mode;
  }
  throw new Error(`Unknown v0.112 benchmark mode ${mode}. Use preview or dev.`);
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
  child.stdout.on("data", (chunk) => process.stdout.write(`[v0112-${serverMode}] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[v0112-${serverMode}] ${chunk}`));
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

function displayPath(path: string): string {
  return path.replaceAll("\\", "/").replace(`${process.cwd().replaceAll("\\", "/")}/`, "");
}

function renderArtifactReadme(resultCount: number): string {
  return [
    "# v0.112 Battle-Loop Scheduler Artifacts",
    "",
    "This folder is ignored by git and can be regenerated from the v0.112 perf scripts.",
    "",
    `Idle matrix rows: ${resultCount}.`,
    "",
    "Key files:",
    "",
    "- scheduler-map.json",
    "- allocation-audit.json",
    "- idle-cost-matrix.json",
    "- before-after-delta.json/md",
    "- parity-summary.json",
    ""
  ].join("\n");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
