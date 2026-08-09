import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R9_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-b\\p1r9";
const logsRoot = process.env.P1R9_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-b";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = (f) => createHash("sha256").update(readFileSync(f)).digest("hex");
function withAutoload(fn) {
  const file = path.join(project, "project.godot"); const original = readFileSync(file, "utf8");
  const marker = 'P1R9Capture="*res://tests/p1r9_space_readability.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched); try { return fn(); } finally { writeFileSync(file, original); }
}
function run(width, height, spec, output) {
  mkdirSync(output, { recursive: true });
  const log = path.join(logsRoot, `p1r9-${spec.case}-${width}x${height}.log`);
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1R9_SOURCE_SHA: sourceSha(), ASCENDANT_P1R9_WIDTH: String(width), ASCENDANT_P1R9_HEIGHT: String(height), ASCENDANT_P1R9_OUTPUT: output, ASCENDANT_P1R9_MAP: spec.map, ASCENDANT_P1R9_FOCUS: spec.focus, ASCENDANT_P1R9_CASE: spec.case }, encoding: "utf8", timeout: 300000, windowsHide: false });
  const mf = path.join(output, "space-readability-manifest.json");
  if (!existsSync(mf)) throw new Error(`missing ${mf}; exit=${result.status}`);
  return JSON.parse(readFileSync(mf, "utf8"));
}
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`;
  const dir = path.join(evidenceRoot, runId);
  const cases1920 = [
    { map: "hollowspan", focus: "base", case: "01_HOLLOWSPAN_BASE" },
    { map: "hollowspan", focus: "center", case: "02_HOLLOWSPAN_CENTRAL_ROUTE" },
    { map: "hollowspan", focus: "resource", case: "03_HOLLOWSPAN_RESOURCE_CLUSTER" },
    { map: "hollowspan", focus: "site", case: "04_HOLLOWSPAN_STRATEGIC_SITE" },
    { map: "emberfall_rift", focus: "base", case: "05_EMBERFALL_BASE" },
    { map: "scorched_expanse", focus: "base", case: "06_SCORCHED_EXPANSE_BASE" },
  ];
  const manifests = withAutoload(() => {
    const out = [];
    for (const spec of cases1920) out.push(run(1920, 1080, spec, path.join(dir, "1920x1080", spec.case)));
    out.push(run(1366, 768, cases1920[0], path.join(dir, "1366x768", cases1920[0].case)));
    return out;
  });
  const failures = manifests.flatMap((m) => m.pass ? [] : (m.failures || [m.case + ": harness failed"]));
  const captures = manifests.map((m) => ({ case: m.case, map: m.map, focus: m.focus, png: m.png, sha256: sha256(m.png), entity_positions_unchanged: m.entity_positions_unchanged }));
  const summary = { schema: "ascendant-realms-p1r9-capture-v1", source_sha: sourceSha(), run_dir: runId, godot, captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r9-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2)); if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = [];
  const script = readFileSync(path.join(project, "scripts", "world", "game_world.gd"), "utf8");
  for (const snippet of ["var interior_target: int = int(24 * density)", "pos.distance_to(s) < 42.0", "pos.distance_to(Vector3.ZERO) < 30.0", "pos.distance_to(c.get(\"pos\", Vector3.ZERO)) < 22.0"]) if (!script.includes(snippet)) failures.push(`missing declutter contract: ${snippet}`);
  const config = readFileSync(path.join(project, "project.godot"), "utf8"); if (config.includes("P1R9Capture")) failures.push("capture autoload persisted");
  const file = path.join(evidenceRoot, "p1r9-capture-manifest.json");
  if (!existsSync(file)) failures.push("missing p1r9 capture manifest");
  else { const m = JSON.parse(readFileSync(file, "utf8")); if (m.source_sha !== sourceSha()) failures.push("capture source sha mismatch"); if (!m.pass) failures.push(...m.failures); if (m.captures?.length !== 7) failures.push(`expected 7 captures, got ${m.captures?.length ?? 0}`); }
  const report = { schema: "ascendant-realms-p1r9-validator-v1", source_sha: sourceSha(), evidence_root: evidenceRoot, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r9-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if (mode === "capture") capture(); else validate();
