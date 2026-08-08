import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1S5_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1s5-match-identity";
const logsRoot = process.env.P1S5_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1s5-match-identity";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });

function sourceSha() { return execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim(); }
function sha256(file) { return createHash("sha256").update(readFileSync(file)).digest("hex"); }
function stamp() { return process.env.P1S5_CAPTURE_TIMESTAMP || new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14); }

function withCaptureAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const marker = 'P1S5Capture="*res://tests/p1s5_match_identity.gd"';
  const patched = original.includes(marker) ? original : original.replace(
    'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"',
    'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker,
  );
  writeFileSync(file, patched);
  try { return fn(); } finally { writeFileSync(file, original); }
}

function expectedNames(width) {
  return width === 1920
    ? ["01_SETUP_BARROSAN_IDENTITY", "02_SETUP_LIORAEN_IDENTITY", "03_SETUP_NONDEFAULT_MAP", "04_RUNTIME_BARROSAN_HOLLOWSPAN", "05_RUNTIME_LIORAEN_NONDEFAULT_MAP", "06_RUNTIME_NONDEFAULT_MAP_ALERT"]
    : ["09_1366_SETUP_IDENTITY", "10_1366_RUNTIME_IDENTITY"];
}

function runCapture(width, height, output, runDir) {
  const logPath = path.join(logsRoot, `p1s5-${width}x${height}.log`);
  mkdirSync(output, { recursive: true });
  const env = {
    ...process.env,
    TEMP: "D:\\CodexData\\temp",
    TMP: "D:\\CodexData\\temp",
    npm_config_cache: "D:\\CodexData\\cache\\npm",
    ASCENDANT_P1S5_SOURCE_SHA: sourceSha(),
    ASCENDANT_P1S5_WIDTH: String(width),
    ASCENDANT_P1S5_HEIGHT: String(height),
    ASCENDANT_P1S5_OUTPUT: output,
  };
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", logPath], {
    cwd: repo, env, encoding: "utf8", timeout: 300000, windowsHide: false,
  });
  writeFileSync(logPath, `${result.stdout || ""}\n${result.stderr || ""}`);
  if (result.error) throw new Error(`P1-S5 ${width}x${height} launch failed: ${result.error.message}`);
  const manifest = path.join(output, "match-identity-manifest.json");
  if (!existsSync(manifest)) throw new Error(`P1-S5 ${width}x${height} did not produce ${manifest}`);
  return { manifest: JSON.parse(readFileSync(manifest, "utf8")), relative: path.relative(evidenceRoot, manifest).replaceAll(path.sep, "/"), runDir, exit_code: result.status };
}

function validateManifest(manifest, width, height, label) {
  const failures = [];
  if (manifest.schema !== "ascendant-realms-p1s5-match-identity-v1") failures.push(`${label}: schema mismatch`);
  if (manifest.source_sha !== sourceSha()) failures.push(`${label}: source SHA mismatch`);
  if (manifest.resolution?.width !== width || manifest.resolution?.height !== height) failures.push(`${label}: resolution mismatch`);
  if (manifest.pass !== true || manifest.failures?.length) failures.push(`${label}: harness failures ${JSON.stringify(manifest.failures || [])}`);
  if (manifest.profile_before && JSON.stringify(manifest.profile_before) !== JSON.stringify(manifest.profile_after)) failures.push(`${label}: profile mutation`);
  for (const proof of manifest.setup_proofs || []) {
    if (!proof.pass || !String(proof.note).includes("Skirmish faction:")) failures.push(`${label}: setup identity proof failed for ${proof.race}`);
  }
  if (manifest.setup_proofs?.length < 2) failures.push(`${label}: missing setup faction proofs`);
  const random = manifest.random_map || {};
  if (random.requested_map_choice !== "__random__" || !random.resolved_map_id || random.resolved_map_id === "__random__" || !random.resolved_once_before_scene_transition) failures.push(`${label}: random map was not resolved exactly once before transition`);
  for (const scenario of manifest.scenarios || []) {
    if (!scenario.pass) failures.push(`${label}: scenario ${scenario.label} failed`);
    const runtime = scenario.runtime || {};
    const requested = scenario.requested || {};
    if (runtime.runtime_map_id !== requested.map) failures.push(`${label}: scenario ${scenario.label} map identity mismatch`);
    if (runtime.runtime_player_race !== requested.player_race) failures.push(`${label}: scenario ${scenario.label} player identity mismatch`);
    const expectedAlert = `The battle for ${runtime.runtime_map_name} begins!`;
    if (!(scenario.alerts || []).includes(expectedAlert)) failures.push(`${label}: scenario ${scenario.label} alert mismatch`);
  }
  const frames = new Map((manifest.frames || []).map((frame) => [frame.name, frame]));
  for (const name of expectedNames(width)) {
    const frame = frames.get(name);
    if (!frame) { failures.push(`${label}: missing frame ${name}`); continue; }
    if (frame.width !== width || frame.height !== height) failures.push(`${label}: ${name} rendered size mismatch`);
    const file = frame.png.replaceAll("/", path.sep);
    if (!existsSync(file) || readFileSync(file).length < 20000) failures.push(`${label}: ${name} missing or suspiciously small`);
    if (frame.nonblank_bytes <= 0) failures.push(`${label}: ${name} blank image metadata`);
  }
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
  const summary = { schema: "ascendant-realms-p1s5-match-identity-capture-v1", source_sha: sourceSha(), godot, run_dir: runDir, godot_exit_codes: manifests.map((item) => item.exit_code), manifests: manifests.map((item) => item.relative), captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1s5-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2));
  if (failures.length) process.exitCode = 1;
}

function validate() {
  const failures = [];
  const captureFile = path.join(evidenceRoot, "p1s5-capture-manifest.json");
  if (!existsSync(captureFile)) failures.push("missing p1s5-capture-manifest.json");
  let summary = null;
  if (!failures.length) {
    summary = JSON.parse(readFileSync(captureFile, "utf8"));
    if (summary.source_sha !== sourceSha()) failures.push("capture summary source SHA mismatch");
    if (summary.pass !== true) failures.push(...(summary.failures || ["capture summary is not passing"]));
    const selectedRun = summary.run_dir ? path.join(evidenceRoot, summary.run_dir) : evidenceRoot;
    for (const [relative, width, height] of [["1920x1080/match-identity-manifest.json", 1920, 1080], ["1366x768/match-identity-manifest.json", 1366, 768]]) {
      const file = path.join(selectedRun, relative);
      if (!existsSync(file)) failures.push(`missing ${relative}`); else failures.push(...validateManifest(JSON.parse(readFileSync(file, "utf8")), width, height, relative));
    }
  }
  const projectConfig = readFileSync(path.join(project, "project.godot"), "utf8");
  if (projectConfig.includes("P1S5Capture")) failures.push("P1S5 capture autoload persisted in project.godot");
  const allowed = new Set([
    "package.json",
    "production/ascendant-realms-godot/scripts/autoloads/match_config.gd",
    "production/ascendant-realms-godot/scripts/ui/skirmish_setup.gd",
    "production/ascendant-realms-godot/scripts/world/game_world.gd",
    "production/ascendant-realms-godot/tests/p1s5_match_identity.gd",
    "tools/godot/p1s5MatchIdentityTool.mjs",
  ]);
  const changed = execFileSync("git", ["diff", "--name-only"], { cwd: repo, encoding: "utf8" }).trim().split(/\r?\n/).filter(Boolean);
  const untracked = execFileSync("git", ["ls-files", "--others", "--exclude-standard"], { cwd: repo, encoding: "utf8" }).trim().split(/\r?\n/).filter(Boolean);
  for (const file of [...changed, ...untracked]) if (!allowed.has(file)) failures.push(`scope contamination: ${file}`);
  const result = { schema: "ascendant-realms-p1s5-match-identity-validator-v1", source_sha: sourceSha(), godot, evidence_root: evidenceRoot, summary, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1s5-validator-report.json"), JSON.stringify(result, null, 2) + "\n");
  console.log(JSON.stringify(result, null, 2));
  if (failures.length) process.exitCode = 1;
}

if (mode === "capture") capture(); else validate();
