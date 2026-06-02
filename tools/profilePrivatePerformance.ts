import { chromium, type Page } from "@playwright/test";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import {
  renderPerformanceDeltaMarkdown,
  renderPerformanceSummaryMarkdown,
  V0104_PERFORMANCE_SCENARIOS,
  type PrivatePerformanceSummary
} from "../src/game/playtest/PrivatePerformanceProfiler";

const OUTPUT_DIR = resolve("artifacts", "performance", "v0104");
const BASELINE_DIR = resolve("artifacts", "performance", "v0103");
const PORT = Number(process.env.ASCENDANT_PERF_PORT ?? "5193");
const BASE_URL = `http://127.0.0.1:${PORT}`;
const SAMPLE_MS = Number(process.env.ASCENDANT_PERF_SAMPLE_MS ?? "1200");

interface ScenarioResult {
  scenarioId: string;
  launchScenarioId: string;
  title: string;
  group: string;
  summary: PrivatePerformanceSummary;
}

async function main(): Promise<void> {
  await mkdir(OUTPUT_DIR, { recursive: true });
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
      const scenarioResults: ScenarioResult[] = [];
      for (const scenario of V0104_PERFORMANCE_SCENARIOS) {
        const summary = await profileScenario(page, scenario.id, scenario.launchScenarioId);
        scenarioResults.push({
          scenarioId: scenario.id,
          launchScenarioId: scenario.launchScenarioId,
          title: scenario.title,
          group: scenario.group,
          summary
        });
      }
      const summaries = scenarioResults.map((entry) => entry.summary);
      await writeArtifacts(scenarioResults, summaries, {
        longTaskObserverSupported: summaries.some((summary) => summary.longTasks.supported),
        sampleMs: SAMPLE_MS,
        scenarioCount: scenarioResults.length
      });
      console.log(`Private performance profile complete: ${scenarioResults.length} scenario(s).`);
      console.log(`Artifacts: ${OUTPUT_DIR}`);
    } finally {
      await browser.close();
    }
  } finally {
    server.kill();
  }
}

async function profileScenario(page: Page, scenarioId: string, launchScenarioId: string): Promise<PrivatePerformanceSummary> {
  await page.goto(BASE_URL, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 30_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 15_000 });
  await page.getByTestId(`playtest-scenario-${launchScenarioId}`).click();
  await page.waitForFunction(() => Boolean(window.__ASCENDANT_PERFORMANCE_PROFILER__), null, { timeout: 20_000 });
  await page.waitForLoadState("networkidle", { timeout: 5_000 }).catch(() => undefined);
  await page.waitForTimeout(250);
  await page.evaluate((id) => window.__ASCENDANT_PERFORMANCE_PROFILER__?.start(id), scenarioId);
  await page.waitForTimeout(SAMPLE_MS);
  const summary = await page.evaluate(() => window.__ASCENDANT_PERFORMANCE_PROFILER__?.stop());
  if (!summary) {
    throw new Error(`Missing profiler summary for ${scenarioId}.`);
  }
  return summary;
}

async function writeArtifacts(
  scenarioResults: ScenarioResult[],
  summaries: PrivatePerformanceSummary[],
  capability: Record<string, unknown>
): Promise<void> {
  const summary = {
    schemaVersion: 1,
    checkpoint: "v0.104",
    generatedAtUtc: "deterministic-v0104",
    note: "Private browser profiler evidence from local Playwright sampling. FPS varies by machine; compare scenario shape, not absolute numbers.",
    scenarioCount: summaries.length,
    summaries: summaries.sort((left, right) => left.scenarioId.localeCompare(right.scenarioId))
  };
  const baseline = await readBaselineSummaries();
  await writeFile(resolve(OUTPUT_DIR, "scenario-results.json"), `${JSON.stringify(scenarioResults, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "performance-summary.json"), `${JSON.stringify(summary, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "profiler-capability-report.json"), `${JSON.stringify({ schemaVersion: 1, checkpoint: "v0.104", baselineCheckpoint: "v0.103", ...capability }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "performance-summary.md"), renderPerformanceSummaryMarkdown(summaries, { checkpoint: "v0.104" }), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "performance-delta.md"), renderPerformanceDeltaMarkdown(summaries, baseline, { checkpoint: "v0.104", baselineCheckpoint: "v0.103" }), "utf8");
}

async function readBaselineSummaries(): Promise<PrivatePerformanceSummary[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(BASELINE_DIR, "performance-summary.json"), "utf8")) as {
      summaries?: PrivatePerformanceSummary[];
    };
    return parsed.summaries ?? [];
  } catch {
    return [];
  }
}

async function startServer(): Promise<ChildProcessWithoutNullStreams> {
  const child = spawn(process.execPath, ["node_modules/vite/bin/vite.js", "--host", "127.0.0.1", "--port", String(PORT), "--strictPort"], {
    cwd: process.cwd(),
    env: { ...process.env, ASCENDANT_PERF_PROFILE: "1" },
    stdio: "pipe"
  });
  child.stdout.on("data", (chunk) => process.stdout.write(`[perf-server] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[perf-server] ${chunk}`));
  child.on("exit", (code) => {
    if (code && code !== 0) {
      console.warn(`Private performance dev server exited with code ${code}.`);
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
