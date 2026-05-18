import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import {
  renderScenarioLabMarkdownReport,
  renderWatchpointSummaryMarkdown,
  runScenarioLab
} from "../src/game/playtest/ScriptedBattlePlaytest";

const report = runScenarioLab();

const jsonPath = resolve("PLAYTEST_SCENARIO_LAB.json");
const markdownPath = resolve("PLAYTEST_SCENARIO_LAB.md");
const watchpointPath = resolve("PLAYTEST_WATCHPOINT_SUMMARY.md");

await writeFile(jsonPath, `${JSON.stringify(report, null, 2)}\n`, "utf-8");
await writeFile(markdownPath, renderScenarioLabMarkdownReport(report), "utf-8");
await writeFile(watchpointPath, renderWatchpointSummaryMarkdown(report), "utf-8");

console.log(`Wrote ${markdownPath}`);
console.log(`Wrote ${jsonPath}`);
console.log(`Wrote ${watchpointPath}`);
console.log(`Scenario lab profiles: ${report.profiles.length}`);
console.log(`Derived profile-run metrics: ${report.runMetrics.length}`);
console.log(`Watchpoints classified: ${report.watchpoints.length}`);
