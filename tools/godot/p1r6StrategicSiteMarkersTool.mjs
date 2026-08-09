import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R6_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-a\\p1r6";
const logsRoot = process.env.P1R6_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-a";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sha256 = (f) => createHash("sha256").update(readFileSync(f)).digest("hex");
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
function withAutoload(fn) {
  const file = path.join(project, "project.godot"); const original = readFileSync(file, "utf8");
  const marker = 'P1R6Capture="*res://tests/p1r6_strategic_site_markers.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched); try { return fn(); } finally { writeFileSync(file, original); }
}
function run(width, height, output) {
  mkdirSync(output, { recursive: true });
  const log = path.join(logsRoot, `p1r6-${width}x${height}.log`);
  const r = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1R6_SOURCE_SHA: sourceSha(), ASCENDANT_P1R6_WIDTH: String(width), ASCENDANT_P1R6_HEIGHT: String(height), ASCENDANT_P1R6_OUTPUT: output }, encoding: "utf8", timeout: 300000, windowsHide: false });
  const mf = path.join(output, "strategic-site-markers-manifest.json");
  if (!existsSync(mf)) throw new Error(`missing ${mf}; exit=${r.status}`);
  return JSON.parse(readFileSync(mf, "utf8"));
}
const required = ["neutral", "contested", "owned", "near"];
function check(m, width) {
  const failures = [];
  if (m.schema !== "ascendant-realms-p1r6-strategic-site-markers-v1") failures.push("schema");
  if (m.source_sha !== sourceSha()) failures.push("source sha");
  if (!m.pass) failures.push(...(m.failures || ["harness failed"]));
  if (m.resolution?.width !== width) failures.push("resolution");
  if (m.capture_semantics !== "visual fixtures only; ownership and benefit logic are not changed") failures.push("semantics declaration");
  for (const name of required) {
    const frame = (m.frames || []).find((f) => f.name === name);
    if (!frame) failures.push(`missing ${name}`);
    else if (!existsSync(frame.png) || readFileSync(frame.png).length < 20000) failures.push(`suspicious ${name}`);
    else if (frame.width !== width) failures.push(`${name}:width`);
  }
  return failures;
}
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`;
  const dir = path.join(evidenceRoot, runId);
  const manifests = withAutoload(() => [run(1920, 1080, path.join(dir, "1920x1080")), run(1366, 768, path.join(dir, "1366x768"))]);
  const failures = [...check(manifests[0], 1920), ...check(manifests[1], 1366)];
  const captures = manifests.flatMap((m) => (m.frames || []).map((f) => ({ name: f.name, png: f.png, sha256: sha256(f.png), width: f.width, height: f.height, probe: f.probe })));
  const summary = { schema: "ascendant-realms-p1r6-capture-v1", source_sha: sourceSha(), run_dir: runId, godot, captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r6-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2)); if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = []; const file = path.join(evidenceRoot, "p1r6-capture-manifest.json");
  if (!existsSync(file)) failures.push("missing capture manifest");
  let summary = null;
  if (!failures.length) { summary = JSON.parse(readFileSync(file, "utf8")); if (summary.source_sha !== sourceSha()) failures.push("source sha mismatch"); if (!summary.pass) failures.push(...summary.failures); if (summary.captures.length !== 8) failures.push("capture count"); }
  const config = readFileSync(path.join(project, "project.godot"), "utf8"); if (config.includes("P1R6Capture")) failures.push("capture autoload persisted");
  const allowed = new Set(["package.json", "production/ascendant-realms-godot/scripts/world/capture_point.gd", "production/ascendant-realms-godot/tests/p1r6_strategic_site_markers.gd", "tools/godot/p1r6StrategicSiteMarkersTool.mjs"]);
  const preExisting = new Set(["artifacts/manual-review/v0431-gameplay-readability-construction-loop/v0431-driver-started.txt", "artifacts/manual-review/v0432-war-hall-clan-levy-production-loop/v0432-driver-started.txt"]);
  for (const f of execFileSync("git", ["diff", "--name-only"], { cwd: repo, encoding: "utf8" }).split(/\r?\n/).filter(Boolean)) if (!allowed.has(f) && !f.endsWith(".import") && !preExisting.has(f) && f !== "production/ascendant-realms-godot/project.godot") failures.push(`scope contamination: ${f}`);
  const report = { schema: "ascendant-realms-p1r6-validator-v1", source_sha: sourceSha(), summary, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r6-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if (mode === "capture") capture(); else validate();
