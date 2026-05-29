import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import {
  buildAct1PlayabilityTelemetryReport,
  renderAct1PlayabilityTelemetryMarkdownReport
} from "../src/game/playtest/Act1PlayabilityTelemetry";

const report = buildAct1PlayabilityTelemetryReport();
const jsonPath = resolve("ACT1_PLAYABILITY_TELEMETRY.json");
const markdownPath = resolve("ACT1_PLAYABILITY_TELEMETRY.md");

await writeFile(jsonPath, `${JSON.stringify(report, null, 2)}\n`, "utf-8");
await writeFile(markdownPath, renderAct1PlayabilityTelemetryMarkdownReport(report), "utf-8");

console.log(`Wrote ${markdownPath}`);
console.log(`Wrote ${jsonPath}`);
console.log(`Summarized ${report.act1RunCount} Act 1 runs from ${report.sourceRunCount} deterministic simulator runs.`);
