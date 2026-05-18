import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { SCENARIO_LAB_PROFILES, renderScenarioProfileCatalogMarkdown } from "../src/game/playtest/ScriptedBattlePlaytest";

const jsonPath = resolve("PLAYTEST_SCENARIO_PROFILES.json");
const markdownPath = resolve("PLAYTEST_SCENARIO_PROFILES.md");

await writeFile(jsonPath, `${JSON.stringify({ schemaVersion: 1, profiles: SCENARIO_LAB_PROFILES }, null, 2)}\n`, "utf-8");
await writeFile(markdownPath, renderScenarioProfileCatalogMarkdown(), "utf-8");

console.log(`Wrote ${markdownPath}`);
console.log(`Wrote ${jsonPath}`);
console.log(`Scenario profiles: ${SCENARIO_LAB_PROFILES.length}`);
