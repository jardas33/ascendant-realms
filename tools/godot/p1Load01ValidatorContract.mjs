import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const read = (file) => readFileSync(path.join(repo, file), "utf8");

export function validateLoad01Contract() {
  const loading = read("production/ascendant-realms-godot/scripts/autoloads/loading_screen.gd");
  const observer = read("production/ascendant-realms-godot/tests/p1_load_01_observer.gd");
  const packageJson = JSON.parse(readFileSync(path.join(repo, "package.json"), "utf8"));
  const failures = [];
  for (const token of ["_run_preload_sequence_threaded", "ResourceLoader.load_threaded_request", "if not OS.has_feature(\"web\")", "_load01_flush"]) if (!loading.includes(token)) failures.push(`missing loader token ${token}`);
  for (const token of ["ASCENDANT_P1_LOAD01", "T0_PLAYER_INITIATED_SKIRMISH", "T9_BATTLEFIELD_PLAYABLE", '"prototype_runtime": false']) if (!observer.includes(token)) failures.push(`missing observer token ${token}`);
  if (packageJson.scripts["godot:capture:p1-load-01"] !== "node tools/godot/p1Load01Tool.mjs capture") failures.push("capture package command missing");
  if (packageJson.scripts["godot:validate:p1-load-01"] !== "node tools/godot/p1Load01Tool.mjs validate") failures.push("validate package command missing");
  if (!existsSync(path.join(repo, "docs/P1_LOAD_01_SKIRMISH_LOADING_FIRST_FIX_REPORT.md"))) failures.push("LOAD-01 report missing");
  return failures;
}
