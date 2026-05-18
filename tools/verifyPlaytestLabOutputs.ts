import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { assertScenarioLabOutputArtifacts } from "../src/game/playtest/ScriptedBattlePlaytest";

const artifacts = {
  extendedJson: await readText("PLAYTEST_SCENARIO_LAB_EXTENDED.json"),
  extendedMarkdown: await readText("PLAYTEST_SCENARIO_LAB_EXTENDED.md"),
  profileComparisonMarkdown: await readText("PLAYTEST_PROFILE_COMPARISON.md"),
  profileComparisonCsv: await readText("PLAYTEST_PROFILE_COMPARISON.csv"),
  dashboardJson: await readText("PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json"),
  dashboardMarkdown: await readText("PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md"),
  watchpointsMarkdown: await readText("PLAYTEST_WATCHPOINTS_EXTENDED.md")
};

const result = assertScenarioLabOutputArtifacts(artifacts, { expectedIterationCount: 5 });

console.log(`Scenario lab output verification passed (${result.checks.length} checks).`);
result.checks.forEach((check) => console.log(`- ${check}`));

async function readText(path: string): Promise<string> {
  return readFile(resolve(path), "utf-8");
}
