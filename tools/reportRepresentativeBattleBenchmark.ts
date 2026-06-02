import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import {
  REPRESENTATIVE_BATTLE_BENCHMARK_CHECKPOINT,
  REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS,
  V0108_DESKTOP_ACCEPTANCE_PROFILE,
  buildBattleBenchmarkSummaryJson,
  renderAcceptanceProfileMarkdown,
  renderBattleBenchmarkSummaryMarkdown,
  renderBrowserBattleBenchmarkReport,
  renderPerformanceDeltaReport,
  type RepresentativeBattleScenarioResult
} from "../src/game/playtest/RepresentativeBattleBenchmark";
import type { PrivatePerformanceSummary } from "../src/game/playtest/PrivatePerformanceProfiler";

const OUTPUT_DIR = resolve("artifacts", "benchmarks", "v0108");

async function main(): Promise<void> {
  await mkdir(OUTPUT_DIR, { recursive: true });
  const results = await readScenarioResults();
  if (results.length === 0) {
    throw new Error(`No representative battle benchmark results found in ${OUTPUT_DIR}. Run npm run benchmark:battle:representative first.`);
  }
  const capability = {
    schemaVersion: 1,
    checkpoint: REPRESENTATIVE_BATTLE_BENCHMARK_CHECKPOINT,
    scenarioCount: results.length,
    longTaskObserverSupported: results.some((result) => result.summary.longTasks.supported),
    latencyProbes: ["battleLaunchLatencyMs", "representativeActionLatencyMs", "resultsTransitionLatencyMs"],
    privateOnly: true,
    stressScenarioIds: REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.filter((scenario) => scenario.localOnly).map((scenario) => scenario.id)
  };
  await writeFile(resolve(OUTPUT_DIR, "scenario-results.json"), `${JSON.stringify(results, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "battle-benchmark-summary.json"), `${JSON.stringify(buildBattleBenchmarkSummaryJson(results), null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "battle-benchmark-summary.md"), renderBattleBenchmarkSummaryMarkdown(results), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "acceptance-profile.json"), `${JSON.stringify(V0108_DESKTOP_ACCEPTANCE_PROFILE, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "capability-report.json"), `${JSON.stringify(capability, null, 2)}\n`, "utf8");
  await writeFile(resolve("docs", "V0108_BROWSER_BATTLE_BENCHMARK_REPORT.md"), renderBrowserBattleBenchmarkReport(results), "utf8");
  await writeFile(resolve("docs", "V0108_DESKTOP_ACCEPTANCE_PROFILE.md"), renderAcceptanceProfileMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0108_PERFORMANCE_DELTA_REPORT.md"), renderPerformanceDeltaReport(results, await readPrivatePerformanceBaselines()), "utf8");
  console.log(`Representative battle benchmark report refreshed for ${results.length} scenario(s).`);
  console.log(`Artifacts: ${OUTPUT_DIR}`);
}

async function readScenarioResults(): Promise<RepresentativeBattleScenarioResult[]> {
  const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "scenario-results.json"), "utf8")) as RepresentativeBattleScenarioResult[];
  if (!Array.isArray(parsed)) {
    throw new Error("scenario-results.json must be an array.");
  }
  const knownIds = new Set(REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.map((scenario) => scenario.id));
  return parsed.filter((result) => knownIds.has(result.scenarioId));
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

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : String(error));
  process.exitCode = 1;
});
