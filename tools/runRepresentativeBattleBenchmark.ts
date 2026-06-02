import { chromium, type Page } from "@playwright/test";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import {
  REPRESENTATIVE_BATTLE_BENCHMARK_CHECKPOINT,
  REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS,
  buildBattleBenchmarkSummaryJson,
  representativeBattleScenarioById,
  representativeBattleScenarioIdsForProfile,
  renderAcceptanceProfileMarkdown,
  renderBattleBenchmarkSummaryMarkdown,
  renderBrowserBattleBenchmarkReport,
  renderPerformanceDeltaReport,
  V0108_DESKTOP_ACCEPTANCE_PROFILE,
  type RepresentativeBattleBenchmarkProfile,
  type RepresentativeBattleScenarioResult
} from "../src/game/playtest/RepresentativeBattleBenchmark";
import type { PrivatePerformanceSummary } from "../src/game/playtest/PrivatePerformanceProfiler";

const OUTPUT_DIR = resolve("artifacts", "benchmarks", "v0108");
const PORT = Number(process.env.ASCENDANT_BATTLE_BENCHMARK_PORT ?? "5198");
const BASE_URL = `http://127.0.0.1:${PORT}`;
const SAMPLE_MS = Number(process.env.ASCENDANT_BATTLE_BENCHMARK_SAMPLE_MS ?? "1200");
const SAVE_KEY = "ascendant-realms-save-v1";

async function main(): Promise<void> {
  const profile = parseProfile(process.argv.slice(2));
  await mkdir(OUTPUT_DIR, { recursive: true });
  const scenarioIds = representativeBattleScenarioIdsForProfile(profile);
  if (scenarioIds.length === 0) {
    throw new Error(`No representative battle benchmark scenarios found for profile ${profile}.`);
  }

  const server = await startServer();
  try {
    await waitForServer();
    const browser = await chromium.launch({
      args: ["--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"]
    });
    try {
      const page = await browser.newPage({ viewport: { width: 1600, height: 900 } });
      page.setDefaultTimeout(60_000);
      page.setDefaultNavigationTimeout(120_000);
      const currentResults = profile === "smoke" ? [] : await readExistingResults();
      const resultsById = new Map(currentResults.map((result) => [result.scenarioId, result]));

      for (const scenarioId of scenarioIds) {
        const scenario = representativeBattleScenarioById(scenarioId);
        if (!scenario) {
          throw new Error(`Unknown representative benchmark scenario ${scenarioId}.`);
        }
        const result = await profileScenario(page, scenarioId);
        resultsById.set(scenarioId, result);
        console.log(`Representative battle benchmark complete: ${scenarioId}.`);
      }

      const merged = REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.map((scenario) => resultsById.get(scenario.id)).filter(
        (result): result is RepresentativeBattleScenarioResult => Boolean(result)
      );
      await writeArtifacts(merged);
      console.log(`Representative battle benchmark profile complete: ${profile}, ${scenarioIds.length} scenario(s).`);
      console.log(`Artifacts: ${OUTPUT_DIR}`);
    } finally {
      await browser.close();
    }
  } finally {
    server.kill();
  }
}

async function profileScenario(page: Page, scenarioId: string): Promise<RepresentativeBattleScenarioResult> {
  const scenario = representativeBattleScenarioById(scenarioId);
  if (!scenario) {
    throw new Error(`Unknown representative benchmark scenario ${scenarioId}.`);
  }

  await page.setViewportSize(viewportSize(scenario.viewport));
  await page.goto(BASE_URL, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 30_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 15_000 });
  const saveBefore = await readSaveSnapshot(page);

  const launchStarted = Date.now();
  await page.getByTestId(`playtest-scenario-${scenario.launchScenarioId}`).scrollIntoViewIfNeeded();
  await page.getByTestId(`playtest-scenario-${scenario.launchScenarioId}`).click();
  await expectBattleLoaded(page);
  const battleLaunchLatencyMs = Date.now() - launchStarted;

  await page.waitForFunction(() => Boolean(window.__ASCENDANT_PERFORMANCE_PROFILER__), null, { timeout: 20_000 });
  await page.waitForLoadState("networkidle", { timeout: 5_000 }).catch(() => undefined);
  await page.waitForTimeout(250);
  await page.evaluate((id) => window.__ASCENDANT_PERFORMANCE_PROFILER__?.start(id), scenario.id);
  const representativeActionLatencyMs = await measureRepresentativeActionLatency(page);

  let resultsTransitionLatencyMs: number | undefined;
  if (scenario.variant === "results-transition") {
    await page.waitForTimeout(Math.max(250, Math.floor(SAMPLE_MS / 2)));
    const transitionStarted = Date.now();
    const transitioned = await page.evaluate(() => window.__ASCENDANT_TEST_HOOKS__?.forceBattleVictory?.() ?? false);
    if (!transitioned) {
      throw new Error("Representative benchmark could not force no-save Results transition.");
    }
    await page.getByTestId("private-demo-lume-summary").waitFor({ timeout: 30_000 });
    resultsTransitionLatencyMs = Date.now() - transitionStarted;
    await page.waitForTimeout(250);
  } else {
    await page.waitForTimeout(SAMPLE_MS);
  }

  const summary = await page.evaluate(() => window.__ASCENDANT_PERFORMANCE_PROFILER__?.stop());
  if (!summary) {
    throw new Error(`Missing profiler summary for ${scenario.id}.`);
  }

  if (scenario.variant === "results-transition") {
    await page.getByTestId("results-playtest-hub").click();
  } else {
    await page.getByTestId("private-hub-exit").click();
  }
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  const saveAfter = await readSaveSnapshot(page);
  const saveMutationDetected = saveBefore !== saveAfter;
  if (saveMutationDetected) {
    throw new Error(`Representative benchmark scenario mutated save/localStorage: ${scenario.id}.`);
  }

  return {
    scenarioId: scenario.id,
    launchScenarioId: scenario.launchScenarioId,
    title: scenario.title,
    profile: scenario.profile,
    tier: scenario.tier,
    variant: scenario.variant,
    viewport: scenario.viewport,
    localOnly: scenario.localOnly,
    includeInCiSmoke: scenario.includeInCiSmoke,
    summary,
    latency: {
      battleLaunchLatencyMs,
      representativeActionLatencyMs,
      resultsTransitionLatencyMs,
      saveMutationDetected
    }
  };
}

async function expectBattleLoaded(page: Page): Promise<void> {
  await page.getByTestId("battle-hud").waitFor({ timeout: 90_000 });
  await page.getByTestId("battle-minimap").waitFor({ timeout: 90_000 });
  await page.waitForFunction(
    () => {
      const scene = window.ascendantRealmsGame?.scene.getScene("BattleScene") as
        | {
            scene?: { isActive?: () => boolean };
            hero?: unknown;
            activeMap?: unknown;
            runtime?: unknown;
            game?: { canvas?: unknown };
          }
        | undefined;
      return Boolean(scene?.scene?.isActive?.() && scene.hero && scene.activeMap && scene.runtime && scene.game?.canvas);
    },
    null,
    { timeout: 90_000 }
  );
}

async function measureRepresentativeActionLatency(page: Page): Promise<number> {
  const result = await page.evaluate(async () => {
    const hooks = window.__ASCENDANT_TEST_HOOKS__;
    if (!hooks?.focusSelectedOrHero) {
      throw new Error("Missing representative action hook.");
    }
    const before = hooks.getCommandFeedbackMarkerCount?.() ?? 0;
    const started = performance.now();
    hooks.focusSelectedOrHero();
    await new Promise<void>((resolveFrame) => requestAnimationFrame(() => resolveFrame()));
    const after = hooks.getCommandFeedbackMarkerCount?.() ?? before;
    return {
      latencyMs: Number((performance.now() - started).toFixed(2)),
      markerCountChanged: after > before
    };
  });
  if (!result.markerCountChanged) {
    throw new Error("Representative action did not leave command-marker evidence.");
  }
  return result.latencyMs;
}

async function writeArtifacts(results: RepresentativeBattleScenarioResult[]): Promise<void> {
  const summaryJson = buildBattleBenchmarkSummaryJson(results);
  const capability = {
    schemaVersion: 1,
    checkpoint: REPRESENTATIVE_BATTLE_BENCHMARK_CHECKPOINT,
    sampleMs: SAMPLE_MS,
    scenarioCount: results.length,
    longTaskObserverSupported: results.some((result) => result.summary.longTasks.supported),
    latencyProbes: ["battleLaunchLatencyMs", "representativeActionLatencyMs", "resultsTransitionLatencyMs"],
    privateOnly: true,
    stressScenarioIds: REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.filter((scenario) => scenario.localOnly).map((scenario) => scenario.id)
  };

  await writeFile(resolve(OUTPUT_DIR, "scenario-results.json"), `${JSON.stringify(results, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "battle-benchmark-summary.json"), `${JSON.stringify(summaryJson, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "battle-benchmark-summary.md"), renderBattleBenchmarkSummaryMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "acceptance-profile.json"), `${JSON.stringify(V0108_DESKTOP_ACCEPTANCE_PROFILE, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "capability-report.json"), `${JSON.stringify(capability, null, 2)}\n`, "utf8");
  await writeFile(resolve("docs", "V0108_BROWSER_BATTLE_BENCHMARK_REPORT.md"), renderBrowserBattleBenchmarkReport(results), "utf8");
  await writeFile(resolve("docs", "V0108_DESKTOP_ACCEPTANCE_PROFILE.md"), renderAcceptanceProfileMarkdown(), "utf8");
  await writeFile(
    resolve("docs", "V0108_PERFORMANCE_DELTA_REPORT.md"),
    renderPerformanceDeltaReport(results, await readPrivatePerformanceBaselines()),
    "utf8"
  );
}

async function readExistingResults(): Promise<RepresentativeBattleScenarioResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "scenario-results.json"), "utf8")) as RepresentativeBattleScenarioResult[];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

async function readPrivatePerformanceBaselines(): Promise<
  { checkpoint: "v0.103" | "v0.104"; summaries: PrivatePerformanceSummary[] }[]
> {
  return [
    { checkpoint: "v0.103", summaries: await readBaseline(resolve("artifacts", "performance", "v0103", "performance-summary.json")) },
    { checkpoint: "v0.104", summaries: await readBaseline(resolve("artifacts", "performance", "v0104", "performance-summary.json")) }
  ];
}

async function readBaseline(path: string): Promise<PrivatePerformanceSummary[]> {
  try {
    const parsed = JSON.parse(await readFile(path, "utf8")) as { summaries?: PrivatePerformanceSummary[] };
    return parsed.summaries ?? [];
  } catch {
    return [];
  }
}

async function readSaveSnapshot(page: Page): Promise<string | null> {
  return page.evaluate((key) => localStorage.getItem(key), SAVE_KEY);
}

function parseProfile(args: string[]): RepresentativeBattleBenchmarkProfile {
  const profileArg = args.find((arg) => arg.startsWith("--profile="))?.split("=")[1] ?? "representative";
  if (profileArg === "smoke" || profileArg === "representative" || profileArg === "stress") {
    return profileArg;
  }
  throw new Error(`Unknown benchmark profile ${profileArg}. Use smoke, representative, or stress.`);
}

function viewportSize(label: string): { width: number; height: number } {
  const [width, height] = label.split("x").map((value) => Number(value));
  return { width, height };
}

async function startServer(): Promise<ChildProcessWithoutNullStreams> {
  const child = spawn(process.execPath, ["node_modules/vite/bin/vite.js", "--host", "127.0.0.1", "--port", String(PORT), "--strictPort"], {
    cwd: process.cwd(),
    env: { ...process.env, ASCENDANT_BATTLE_BENCHMARK: "1" },
    stdio: "pipe"
  });
  child.stdout.on("data", (chunk) => process.stdout.write(`[benchmark-server] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[benchmark-server] ${chunk}`));
  child.on("exit", (code) => {
    if (code && code !== 0) {
      console.warn(`Representative battle benchmark dev server exited with code ${code}.`);
    }
  });
  return child;
}

async function waitForServer(): Promise<void> {
  const startedAt = Date.now();
  while (Date.now() - startedAt < 120_000) {
    try {
      const response = await fetch(BASE_URL);
      if (response.ok) {
        return;
      }
    } catch {
      // Retry until Vite finishes booting.
    }
    await new Promise((resolveRetry) => setTimeout(resolveRetry, 500));
  }
  throw new Error(`Timed out waiting for ${BASE_URL}.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : String(error));
  process.exitCode = 1;
});
