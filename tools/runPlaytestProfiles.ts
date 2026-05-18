import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import {
  SCENARIO_LAB_PROFILES,
  renderProfileComparisonCsv,
  renderProfileComparisonMarkdown,
  renderScenarioProfileCatalogMarkdown,
  runExtendedScenarioLab
} from "../src/game/playtest/ScriptedBattlePlaytest";

const args = process.argv.slice(2);
const compare = args.includes("--compare") || args.includes("--profiles=compare");

if (compare) {
  const report = runExtendedScenarioLab({
    iterations: numericOption(args, "--runs"),
    seed: stringOption(args, "--seed"),
    buildCommit: readGitCommit()
  });
  const markdownPath = resolve("PLAYTEST_PROFILE_COMPARISON.md");
  const csvPath = resolve("PLAYTEST_PROFILE_COMPARISON.csv");
  await writeFile(markdownPath, renderProfileComparisonMarkdown(report), "utf-8");
  await writeFile(csvPath, renderProfileComparisonCsv(report), "utf-8");
  console.log(`Wrote ${markdownPath}`);
  console.log(`Wrote ${csvPath}`);
  console.log(`Scenario profile comparisons: ${report.profileComparisons.length}`);
  console.log(`Extended profile-run metrics: ${report.totalDerivedMetrics}`);
} else {
  const jsonPath = resolve("PLAYTEST_SCENARIO_PROFILES.json");
  const markdownPath = resolve("PLAYTEST_SCENARIO_PROFILES.md");

  await writeFile(jsonPath, `${JSON.stringify({ schemaVersion: 1, profiles: SCENARIO_LAB_PROFILES }, null, 2)}\n`, "utf-8");
  await writeFile(markdownPath, renderScenarioProfileCatalogMarkdown(), "utf-8");

  console.log(`Wrote ${markdownPath}`);
  console.log(`Wrote ${jsonPath}`);
  console.log(`Scenario profiles: ${SCENARIO_LAB_PROFILES.length}`);
}

function numericOption(args: string[], name: string): number | undefined {
  const value = stringOption(args, name);
  if (!value) {
    return undefined;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
}

function stringOption(args: string[], name: string): string | undefined {
  const equalPrefix = `${name}=`;
  const equalValue = args.find((arg) => arg.startsWith(equalPrefix));
  if (equalValue) {
    return equalValue.slice(equalPrefix.length);
  }
  const index = args.indexOf(name);
  if (index >= 0) {
    return args[index + 1];
  }
  return undefined;
}

function readGitCommit(): string {
  try {
    return execFileSync("git", ["rev-parse", "--short", "HEAD"], { encoding: "utf-8" }).trim();
  } catch {
    return "unavailable";
  }
}
