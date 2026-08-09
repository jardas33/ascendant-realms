import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R10_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-b\\p1r10";
const logsRoot = process.env.P1R10_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-b";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = (f) => createHash("sha256").update(readFileSync(f)).digest("hex");
function withAutoload(fn) {
  const file = path.join(project, "project.godot"); const original = readFileSync(file, "utf8");
  const marker = 'P1R10Capture="*res://tests/p1r10_build_preview.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched); try { return fn(); } finally { writeFileSync(file, original); }
}
function run(width, height, output) {
  mkdirSync(output, { recursive: true });
  const log = path.join(logsRoot, `p1r10-${width}x${height}.log`);
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1R10_SOURCE_SHA: sourceSha(), ASCENDANT_P1R10_WIDTH: String(width), ASCENDANT_P1R10_HEIGHT: String(height), ASCENDANT_P1R10_OUTPUT: output }, encoding: "utf8", timeout: 300000, windowsHide: false });
  const mf = path.join(output, "build-preview-manifest.json");
  if (!existsSync(mf)) throw new Error(`missing ${mf}; exit=${result.status}`);
  return JSON.parse(readFileSync(mf, "utf8"));
}
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`;
  const dir = path.join(evidenceRoot, runId);
  const manifests = withAutoload(() => [run(1920, 1080, path.join(dir, "1920x1080")), run(1366, 768, path.join(dir, "1366x768"))]);
  const failures = manifests.flatMap((m) => m.pass ? [] : (m.failures || ["harness failed"]));
  const captures = manifests.flatMap((m) => (m.frames || []).map((f) => ({ ...f, sha256: sha256(f.png) })));
  const summary = { schema: "ascendant-realms-p1r10-capture-v1", source_sha: sourceSha(), run_dir: runId, godot, captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r10-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2)); if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = [];
  const script = readFileSync(path.join(project, "scripts", "world", "rts_controller.gd"), "utf8");
  for (const snippet of ["var torus := TorusMesh.new()", "torus.inner_radius", "torus.outer_radius", "ring.position.y = 0.06", "_is_build_spot_valid(g)"]) if (!script.includes(snippet)) failures.push(`missing placement preview contract: ${snippet}`);
  const config = readFileSync(path.join(project, "project.godot"), "utf8"); if (config.includes("P1R10Capture")) failures.push("capture autoload persisted");
  const file = path.join(evidenceRoot, "p1r10-capture-manifest.json");
  if (!existsSync(file)) failures.push("missing p1r10 capture manifest");
  else { const m = JSON.parse(readFileSync(file, "utf8")); if (m.source_sha !== sourceSha()) failures.push("capture source sha mismatch"); if (!m.pass) failures.push(...m.failures); if (m.captures?.length !== 8) failures.push(`expected 8 captures, got ${m.captures?.length ?? 0}`); for (const f of m.captures || []) if (!existsSync(f.png) || f.actual_valid !== f.expected_valid) failures.push(`${f.name}: capture contract`); }
  const report = { schema: "ascendant-realms-p1r10-validator-v1", source_sha: sourceSha(), evidence_root: evidenceRoot, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r10-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if (mode === "capture") capture(); else validate();
