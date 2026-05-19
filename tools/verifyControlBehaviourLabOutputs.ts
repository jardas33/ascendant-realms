import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { assertControlBehaviourLabOutputs } from "../src/game/playtest/ScriptedBattlePlaytest";

const artifacts = {
  normalJson: await readText("PLAYTEST_CONTROL_BEHAVIOUR_LAB.json"),
  normalMarkdown: await readText("PLAYTEST_CONTROL_BEHAVIOUR_LAB.md"),
  extendedJson: await readText("PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json"),
  extendedMarkdown: await readText("PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md"),
  dashboardJson: await readText("PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json"),
  dashboardMarkdown: await readText("PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md")
};

const result = assertControlBehaviourLabOutputs(artifacts, { expectedExtendedIterationCount: 5 });

console.log(`Control behaviour lab output verification passed (${result.checks.length} checks).`);
result.checks.forEach((check) => console.log(`- ${check}`));

async function readText(path: string): Promise<string> {
  return readFile(resolve(path), "utf-8");
}
