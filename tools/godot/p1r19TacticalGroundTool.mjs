import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R19_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-d\\p1r19";
const logsRoot = process.env.P1R19_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-d";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = (file) => createHash("sha256").update(readFileSync(file)).digest("hex");
function withAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const marker = 'P1R19Capture="*res://tests/p1r19_tactical_ground.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched);
  try { return fn(); } finally { writeFileSync(file, original); }
}
function run(name, map, view, width, height, out) {
  mkdirSync(out, { recursive: true });
  const log = path.join(logsRoot, `p1r19-${name}-${width}x${height}.log`);
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log], {
    cwd: repo, env: { ...process.env, TEMP:"D:\\CodexData\\temp", TMP:"D:\\CodexData\\temp", ASCENDANT_P1R19_SOURCE_SHA:sourceSha(), ASCENDANT_P1R19_NAME:name, ASCENDANT_P1R19_MAP:map, ASCENDANT_P1R19_VIEW:view, ASCENDANT_P1R19_WIDTH:String(width), ASCENDANT_P1R19_HEIGHT:String(height), ASCENDANT_P1R19_OUTPUT:out }, encoding:"utf8", timeout:300000, windowsHide:false
  });
  const manifest = path.join(out, "tactical-ground-manifest.json");
  if (!existsSync(manifest)) throw new Error(`R19 ${name} produced no manifest; exit=${result.status}`);
  return JSON.parse(readFileSync(manifest, "utf8"));
}
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0,14)}-${sourceSha().slice(0,8)}`;
  const dir = path.join(evidenceRoot, runId);
  const jobs = [
    ["01_R19_HOLLOWSPAN_ARMY", "hollowspan", "army", 1920, 1080],
    ["02_R19_HOLLOWSPAN_RESOURCE", "hollowspan", "resource", 1920, 1080],
    ["03_R19_EMBERFALL_ARMY", "emberfall_rift", "army", 1920, 1080],
    ["04_R19_EMBERFALL_RESOURCE", "emberfall_rift", "resource", 1920, 1080],
    ["05_R19_ASHEN_ARMY", "ashen_vale", "army", 1920, 1080],
    ["06_R19_COMBAT_GROUND", "hollowspan", "combat", 1920, 1080],
    ["07_R19_1366", "hollowspan", "army", 1366, 768]
  ];
  const manifests = withAutoload(() => jobs.map(([name,map,view,w,h]) => run(name,map,view,w,h,path.join(dir,name))));
  const failures = [];
  for (const m of manifests) {
    if (m.source_sha !== sourceSha()) failures.push(`${m.map}:${m.view}:source_sha`);
    if (!m.pass) failures.push(...(m.failures || [`${m.map}:${m.view}:capture_failed` ]));
    for (const frame of m.frames || []) if (!existsSync(frame.png) || readFileSync(frame.png).length < 20000) failures.push(`${m.map}:${m.view}:image`);
  }
  const captures = manifests.flatMap(m => (m.frames || []).map(f => ({ ...f, sha256: sha256(f.png) })));
  const summary = { schema:"ascendant-realms-p1r19-capture-v1", source_sha:sourceSha(), run_dir:runId, godot, jobs, manifests, captures, pass:failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r19-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2));
  if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = [];
  const shader = readFileSync(path.join(project, "assets", "shaders", "ground_blend.gdshader"), "utf8");
  const terrain = readFileSync(path.join(project, "scripts", "world", "terrain_builder.gd"), "utf8");
  for (const marker of ["ground_base", "surface_detail", "road_edge_strength", "calm the walkable plane first", "_r19_ground_grade"]) if (!shader.includes(marker) && !terrain.includes(marker)) failures.push(`missing R19 material contract: ${marker}`);
  const manifestFile = path.join(evidenceRoot, "p1r19-capture-manifest.json");
  if (!existsSync(manifestFile)) failures.push("missing capture manifest");
  else {
    const m = JSON.parse(readFileSync(manifestFile, "utf8"));
    if (m.source_sha !== sourceSha()) failures.push("source_sha");
    if (!m.pass) failures.push(...(m.failures || ["capture_failed"]));
    for (const name of ["01_R19_HOLLOWSPAN_ARMY","02_R19_HOLLOWSPAN_RESOURCE","03_R19_EMBERFALL_ARMY","04_R19_EMBERFALL_RESOURCE","05_R19_ASHEN_ARMY","06_R19_COMBAT_GROUND","07_R19_1366"]) if (!(m.captures || []).some(f => f.name === name)) failures.push(`missing ${name}`);
  }
  const cfg = readFileSync(path.join(project, "project.godot"), "utf8");
  if (cfg.includes("P1R19Capture")) failures.push("capture autoload persisted");
  const report = { schema:"ascendant-realms-p1r19-validator-v1", source_sha:sourceSha(), evidence_root:evidenceRoot, maps:["hollowspan","emberfall_rift","ashen_vale"], pass:failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r19-validator-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  if (failures.length) process.exitCode = 1;
}
if ((process.argv[2] || "validate") === "capture") capture(); else validate();
