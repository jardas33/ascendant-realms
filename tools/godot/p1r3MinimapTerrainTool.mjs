import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R3_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-a\\p1r3";
const logsRoot = process.env.P1R3_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-a";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const gitNames = (args) => execFileSync("git", args, { cwd: repo, encoding: "utf8" }).split(/\r?\n/).filter(Boolean);
const sha256 = (f) => createHash("sha256").update(readFileSync(f)).digest("hex");
function withAutoload(fn) {
  const file = path.join(project, "project.godot"); const original = readFileSync(file, "utf8");
  const marker = 'P1R3Capture="*res://tests/p1r3_minimap_terrain.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched); try { return fn(); } finally { writeFileSync(file, original); }
}
function run(width, height, output) {
  mkdirSync(output, { recursive: true });
  const log = path.join(logsRoot, `p1r3-${width}x${height}.log`);
  const r = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1R3_SOURCE_SHA: sourceSha(), ASCENDANT_P1R3_WIDTH: String(width), ASCENDANT_P1R3_HEIGHT: String(height), ASCENDANT_P1R3_OUTPUT: output }, encoding: "utf8", timeout: 300000, windowsHide: false });
  const mf = path.join(output, "minimap-terrain-manifest.json"); if (!existsSync(mf)) throw new Error(`missing ${mf}; exit=${r.status}`);
  return JSON.parse(readFileSync(mf, "utf8"));
}
function check(m, width) {
  const failures = [];
  if (m.schema !== "ascendant-realms-p1r3-minimap-terrain-v1") failures.push("schema");
  if (m.source_sha !== sourceSha()) failures.push("source sha");
  if (!m.pass) failures.push(...(m.failures || ["harness failed"]));
  if (m.resolution?.width !== width) failures.push("resolution");
  for (const id of ["HOLLOWSPAN", "EMBERFALL_RIFT", "FROSTMERE_BASIN"]) {
    const f = (m.frames || []).find((x) => x.name === id);
    if (!f) failures.push(`missing ${id}`); else if (!existsSync(f.png) || readFileSync(f.png).length < 20000) failures.push(`suspicious ${id}`); else if (f.minimap_probe?.lit_pixels < 9000) failures.push(`empty ${id}`);
  }
  return failures;
}
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`;
  const dir = path.join(evidenceRoot, runId); const out = withAutoload(() => [run(1920, 1080, path.join(dir, "1920x1080")), run(1366, 768, path.join(dir, "1366x768"))]);
  const failures = [...check(out[0], 1920), ...check(out[1], 1366)];
  const captures = out.flatMap((m) => (m.frames || []).map((f) => ({ name: f.name, map: f.map, png: f.png, sha256: sha256(f.png), probe: f.minimap_probe })));
  const summary = { schema: "ascendant-realms-p1r3-capture-v1", source_sha: sourceSha(), run_dir: runId, godot, captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r3-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n"); console.log(JSON.stringify(summary, null, 2)); if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = []; const file = path.join(evidenceRoot, "p1r3-capture-manifest.json"); if (!existsSync(file)) failures.push("missing capture manifest");
  let summary = null; const validationInputSha = sourceSha();
  if (!failures.length) {
    summary = JSON.parse(readFileSync(file, "utf8"));
    if (!summary.source_sha) failures.push("missing capture source sha");
    if (!summary.pass) failures.push(...summary.failures);
    try { execFileSync("git", ["cat-file", "-e", `${summary.source_sha}^{commit}`], { cwd: repo, stdio: "ignore" }); }
    catch { failures.push("capture source commit unavailable"); }
    if (summary.source_sha !== validationInputSha) {
      const parent = execFileSync("git", ["rev-parse", "HEAD^"], { cwd: repo, encoding: "utf8" }).trim();
      const validatorOnly = new Set(["tools/godot/p1r3MinimapTerrainTool.mjs", "tools/godot/p1Minimap01Tool.mjs"]);
      if (parent !== summary.source_sha) failures.push("validation input is not the captured production source or its validator-only child");
      for (const f of gitNames(["diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD^", "HEAD"])) if (!validatorOnly.has(f)) failures.push(`validator child scope contamination: ${f}`);
    }
  }
  const config = readFileSync(path.join(project, "project.godot"), "utf8"); if (config.includes("P1R3Capture")) failures.push("capture autoload persisted");
  const allowedSource = new Set(["package.json", "docs/P1_MINIMAP_01_TACTICAL_READABILITY_VISUAL_QUALITY_REPORT.md", "production/ascendant-realms-godot/scripts/ui/hud.gd", "production/ascendant-realms-godot/scripts/world/map_defs.gd", "production/ascendant-realms-godot/tests/p1r3_minimap_terrain.gd", "tools/godot/p1r3MinimapTerrainTool.mjs", "tools/godot/p1Minimap01Tool.mjs", "tools/godot/p1r4WorkerInteractionTool.mjs"]);
  if (summary?.source_sha) for (const f of gitNames(["diff-tree", "--no-commit-id", "--name-only", "-r", `${summary.source_sha}^`, summary.source_sha])) if (!allowedSource.has(f)) failures.push(`captured source scope contamination: ${f}`);
  const ambientDirtyPaths = gitNames(["diff", "--name-only"]);
  const report = { schema: "ascendant-realms-p1r3-validator-v1", source_sha: summary?.source_sha || null, validation_input_sha: validationInputSha, ambient_dirty_paths: ambientDirtyPaths, summary, pass: failures.length === 0, failures }; writeFileSync(path.join(evidenceRoot, "p1r3-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if (mode === "capture") capture(); else validate();
