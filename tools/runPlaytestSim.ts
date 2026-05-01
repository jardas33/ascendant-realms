import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import {
  renderPlaytestMarkdownReport,
  runScriptedPlaytestSuite
} from "../src/game/playtest/ScriptedBattlePlaytest";

const report = runScriptedPlaytestSuite();
const jsonPath = resolve("PLAYTEST_TELEMETRY.json");
const markdownPath = resolve("PLAYTEST_TELEMETRY.md");

await writeFile(jsonPath, `${JSON.stringify(report, null, 2)}\n`, "utf-8");
await writeFile(markdownPath, renderPlaytestMarkdownReport(report), "utf-8");

console.log(`Wrote ${markdownPath}`);
console.log(`Wrote ${jsonPath}`);
console.log(
  `Simulated ${report.telemetry.length} runs across ${report.analysis.nodeSummaries.length} campaign battle nodes.`
);
