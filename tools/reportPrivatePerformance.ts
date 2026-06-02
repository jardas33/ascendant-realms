import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import {
  renderPerformanceDeltaMarkdown,
  renderPerformanceSummaryMarkdown,
  type PrivatePerformanceSummary
} from "../src/game/playtest/PrivatePerformanceProfiler";

const OUTPUT_DIR = resolve("artifacts", "performance", "v0104");
const BASELINE_DIR = resolve("artifacts", "performance", "v0103");

async function main(): Promise<void> {
  const summaryPath = resolve(OUTPUT_DIR, "performance-summary.json");
  const parsed = JSON.parse(await readFile(summaryPath, "utf8")) as { summaries?: PrivatePerformanceSummary[] };
  const summaries = parsed.summaries ?? [];
  if (summaries.length === 0) {
    throw new Error(`No performance summaries found in ${summaryPath}. Run npm run perf:profile:private first.`);
  }
  const baseline = await readBaselineSummaries();
  await writeFile(resolve(OUTPUT_DIR, "performance-summary.md"), renderPerformanceSummaryMarkdown(summaries, { checkpoint: "v0.104" }), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "performance-delta.md"), renderPerformanceDeltaMarkdown(summaries, baseline, { checkpoint: "v0.104", baselineCheckpoint: "v0.103" }), "utf8");
  console.log(`Private performance report refreshed for ${summaries.length} scenario(s).`);
  console.log(`Artifacts: ${OUTPUT_DIR}`);
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

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : String(error));
  process.exitCode = 1;
});
