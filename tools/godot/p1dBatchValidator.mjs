import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const repo = path.resolve(import.meta.dirname, "../..");
const evidence = "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-d";
const sourceSha = execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const failures = [];
const requiredFiles = [
  "production/ascendant-realms-godot/scripts/world/terrain_builder.gd",
  "production/ascendant-realms-godot/assets/shaders/ground_blend.gdshader",
  "production/ascendant-realms-godot/scripts/units/unit.gd",
  "production/ascendant-realms-godot/scripts/ui/hud.gd",
  "tools/godot/p1r19TacticalGroundTool.mjs",
  "tools/godot/p1r20CharacterSeparationTool.mjs",
  "tools/godot/p1r21MotionGroundingTool.mjs",
  "tools/godot/p1r22CommandCardTool.mjs",
  "tools/godot/p1r23SelectedGroupTool.mjs",
];
for (const file of requiredFiles) if (!existsSync(path.join(repo, file))) failures.push(`missing:${file}`);
for (const lane of ["p1r19", "p1r20", "p1r21", "p1r22", "p1r23"]) {
  const file = path.join(evidence, lane, `${lane}-capture-manifest.json`);
  if (!existsSync(file)) failures.push(`missing:${lane}:capture-manifest`);
  else {
    const manifest = JSON.parse(readFileSync(file, "utf8"));
    if (manifest.source_sha !== sourceSha) failures.push(`${lane}:source_sha`);
    if (!manifest.pass) failures.push(`${lane}:capture_failed`);
  }
}
const finalManifestPath = path.join(evidence, "FINAL", "final-manifest.json");
if (!existsSync(finalManifestPath)) failures.push("missing:FINAL/final-manifest.json");
else {
  const finalManifest = JSON.parse(readFileSync(finalManifestPath, "utf8"));
  if (finalManifest.source_sha !== sourceSha) failures.push("FINAL:source_sha");
  if (finalManifest.frames?.length !== 20) failures.push("FINAL:frame_count");
  if (!finalManifest.pass) failures.push("FINAL:failed_black_frame_gate");
}
const implementationText = requiredFiles.filter((file) => existsSync(path.join(repo, file))).map((file) => readFileSync(path.join(repo, file), "utf8")).join("\n");
for (const marker of ["P1R19", "P1R20", "P1R21", "P1R22", "P1R23"]) if (!implementationText.includes(marker)) failures.push(`missing:${marker}`);
const report = { schema: "ascendant-realms-p1-remediation-d-validator-v1", source_sha: sourceSha, evidence_root: evidence, pass: failures.length === 0, failures };
console.log(JSON.stringify(report, null, 2));
if (failures.length) process.exitCode = 1;
