import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1S4_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1s4-command-feedback";
const logsRoot = process.env.P1S4_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1s4-command-feedback";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });

function sourceSha() { return execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim(); }
function sha256(file) { return createHash("sha256").update(readFileSync(file)).digest("hex"); }
function stamp() { return process.env.P1S4_CAPTURE_TIMESTAMP || new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14); }

function withCaptureAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const marker = 'P1S4Capture="*res://tests/p1s4_command_feedback.gd"';
  const patched = original.includes(marker) ? original : original.replace(
    'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"',
    'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker,
  );
  writeFileSync(file, patched);
  try { return fn(); } finally { writeFileSync(file, original); }
}

function expectedNames(width) {
  return width === 1920
    ? ["01_MOVE_ACK", "02_ATTACK_ACK", "03_GATHER_ACK", "04_BUILD_CONTINUE_ACK", "05_RALLY_ACK", "06_ATTACK_MOVE_ACK", "07_BUILD_VALID_CURSOR_CONTEXT", "08_BUILD_INVALID_CURSOR_CONTEXT", "09_UI_HOVER_SAFE", "10_STOP_ACK", "11_HOLD_ACK", "12_PATROL_ACK", "13_GUARD_UNAVAILABLE", "14_BUILD_REJECTED_ACK", "15_BUILD_VALID_ACK"]
    : ["10_1366_MOVE_ACK", "11_1366_ATTACK_ACK", "12_1366_GATHER_OR_BUILD_ACK"];
}

function runCapture(width, height, output, runDir) {
  const logPath = path.join(logsRoot, `p1s4-${width}x${height}.log`);
  mkdirSync(output, { recursive: true });
  const env = {
    ...process.env,
    TEMP: "D:\\CodexData\\temp",
    TMP: "D:\\CodexData\\temp",
    npm_config_cache: "D:\\CodexData\\cache\\npm",
    ASCENDANT_P1S4_SOURCE_SHA: sourceSha(),
    ASCENDANT_P1S4_WIDTH: String(width),
    ASCENDANT_P1S4_HEIGHT: String(height),
    ASCENDANT_P1S4_OUTPUT: output,
  };
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", logPath], {
    cwd: repo, env, encoding: "utf8", timeout: 240000, windowsHide: false,
  });
  writeFileSync(logPath, `${result.stdout || ""}\n${result.stderr || ""}`);
  if (result.error) throw new Error(`P1-S4 ${width}x${height} launch failed: ${result.error.message}`);
  const manifest = path.join(output, "command-feedback-manifest.json");
  if (!existsSync(manifest)) throw new Error(`P1-S4 ${width}x${height} did not produce ${manifest}`);
  return { manifest: JSON.parse(readFileSync(manifest, "utf8")), relative: path.relative(evidenceRoot, manifest).replaceAll(path.sep, "/"), runDir, exit_code: result.status };
}

function validateManifest(manifest, width, height, label) {
  const failures = [];
  if (manifest.schema !== "ascendant-realms-p1s4-command-feedback-v1") failures.push(`${label}: schema mismatch`);
  if (manifest.source_sha !== sourceSha()) failures.push(`${label}: source SHA mismatch`);
  if (manifest.map !== "hollowspan" || manifest.match !== "Barrosan vs Lioraen Easy") failures.push(`${label}: fixture identity mismatch`);
  if (manifest.resolution?.width !== width || manifest.resolution?.height !== height) failures.push(`${label}: resolution mismatch`);
  if (manifest.pass !== true || manifest.failures?.length) failures.push(`${label}: harness failures ${JSON.stringify(manifest.failures || [])}`);
  const frames = new Map((manifest.frames || []).map((frame) => [frame.name, frame]));
  for (const name of expectedNames(width)) {
    const frame = frames.get(name);
    if (!frame) { failures.push(`${label}: missing frame ${name}`); continue; }
    if (frame.width !== width || frame.height !== height) failures.push(`${label}: ${name} rendered size mismatch`);
    if (readFileSync(frame.png.replaceAll("/", path.sep)).length < 20000) failures.push(`${label}: ${name} suspiciously small`);
    if (name.includes("ACK") && !frame.command_accepted) failures.push(`${label}: ${name} lacks accepted command`);
    if (name.includes("BUILD_VALID") && frame.cursor_intent !== "BUILD_VALID") failures.push(`${label}: valid build cursor mismatch`);
    if (name.includes("BUILD_INVALID") && frame.cursor_intent !== "INVALID") failures.push(`${label}: invalid build cursor mismatch`);
    if (name.includes("UI_HOVER") && frame.cursor_intent !== "DEFAULT") failures.push(`${label}: UI hover did not reset cursor`);
  }
  for (const item of manifest.intent_cases || []) if (!item.pass) failures.push(`${label}: intent case ${item.case} failed`);
  for (const item of manifest.acknowledgement_cases || []) if (!item.accepted) failures.push(`${label}: acknowledgement ${item.name} not accepted`);
  if (manifest.review_fixture_metadata?.commander_roster_membership !== false) failures.push(`${label}: fixture roster leak metadata`);
  return failures;
}

function capture() {
  const runDir = `run-${stamp()}-${sourceSha().slice(0, 8)}`;
  const dir = path.join(evidenceRoot, runDir);
  const manifests = withCaptureAutoload(() => [
    runCapture(1920, 1080, path.join(dir, "1920x1080"), runDir),
    runCapture(1366, 768, path.join(dir, "1366x768"), runDir),
  ]);
  const failures = [
    ...validateManifest(manifests[0].manifest, 1920, 1080, "1920x1080"),
    ...validateManifest(manifests[1].manifest, 1366, 768, "1366x768"),
  ];
  const captures = manifests.flatMap(({ manifest }) => (manifest.frames || []).map((frame) => ({ name: frame.name, path: frame.png, sha256: sha256(frame.png.replaceAll("/", path.sep)) })));
  const summary = { schema: "ascendant-realms-p1s4-command-feedback-capture-v1", source_sha: sourceSha(), godot, run_dir: runDir, godot_exit_codes: manifests.map((item) => item.exit_code), manifests: manifests.map((item) => item.relative), captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1s4-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2));
  if (failures.length) process.exitCode = 1;
}

function validate() {
  const failures = [];
  const captureFile = path.join(evidenceRoot, "p1s4-capture-manifest.json");
  if (!existsSync(captureFile)) failures.push("missing p1s4-capture-manifest.json");
  let summary = null;
  if (!failures.length) {
    summary = JSON.parse(readFileSync(captureFile, "utf8"));
    if (summary.source_sha !== sourceSha()) failures.push("capture summary source SHA mismatch");
    if (summary.pass !== true) failures.push(...(summary.failures || ["capture summary is not passing"]));
    const selectedRun = summary.run_dir ? path.join(evidenceRoot, summary.run_dir) : evidenceRoot;
    for (const [relative, width, height] of [["1920x1080/command-feedback-manifest.json", 1920, 1080], ["1366x768/command-feedback-manifest.json", 1366, 768]]) {
      const file = path.join(selectedRun, relative);
      if (!existsSync(file)) failures.push(`missing ${relative}`); else failures.push(...validateManifest(JSON.parse(readFileSync(file, "utf8")), width, height, relative));
    }
  }
  const projectConfig = readFileSync(path.join(project, "project.godot"), "utf8");
  if (projectConfig.includes("P1S4Capture")) failures.push("P1S4 capture autoload persisted in project.godot");
  const result = { schema: "ascendant-realms-p1s4-command-feedback-validator-v1", source_sha: sourceSha(), godot, evidence_root: evidenceRoot, summary, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1s4-validator-report.json"), JSON.stringify(result, null, 2) + "\n");
  console.log(JSON.stringify(result, null, 2));
  if (failures.length) process.exitCode = 1;
}

if (mode === "capture") capture(); else validate();
