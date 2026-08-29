import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1S3_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1s3-selection-readability";
const logsRoot = process.env.P1S3_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1s3-selection-readability";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });

function sourceSha() { return execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim(); }
function sha256(file) { return createHash("sha256").update(readFileSync(file)).digest("hex"); }
function runStamp() { return process.env.P1S3_CAPTURE_TIMESTAMP || new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14); }

function withCaptureAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const marker = 'P1S3Capture="*res://tests/p1s3_selection_readability.gd"';
  const patched = original.includes(marker) ? original : original.includes("[autoload]\n")
    ? original.replace("[autoload]\n", "[autoload]\n" + marker + "\n")
    : (() => { throw new Error("project.godot has no [autoload] section"); })();
  writeFileSync(file, patched);
  try { return fn(); } finally { writeFileSync(file, original); }
}

function runCapture(width, height, output, runDir) {
  const logPath = path.join(logsRoot, `p1s3-${width}x${height}.log`);
  mkdirSync(output, { recursive: true });
  const env = {
    ...process.env,
    TEMP: "D:\\CodexData\\temp",
    TMP: "D:\\CodexData\\temp",
    npm_config_cache: "D:\\CodexData\\cache\\npm",
    ASCENDANT_P1S3_SOURCE_SHA: sourceSha(),
    ASCENDANT_P1S3_WIDTH: String(width),
    ASCENDANT_P1S3_HEIGHT: String(height),
    ASCENDANT_P1S3_OUTPUT: output,
  };
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", logPath], {
    cwd: repo, env, encoding: "utf8", timeout: 240000, windowsHide: false,
  });
  writeFileSync(logPath, `${result.stdout || ""}\n${result.stderr || ""}`);
  if (result.error) throw new Error(`P1-S3 ${width}x${height} launch failed: ${result.error.message}`);
  const manifest = path.join(output, "selection-manifest.json");
  if (!existsSync(manifest)) throw new Error(`P1-S3 ${width}x${height} did not produce ${manifest}`);
  return { manifest: JSON.parse(readFileSync(manifest, "utf8")), relative: path.relative(evidenceRoot, manifest).replaceAll(path.sep, "/"), runDir, exit_code: result.status };
}

function expectedNames(width) { return width === 1920
  ? ["01_WORKER_UNSELECTED", "02_WORKER_SELECTED", "03_MILITARY_SELECTED", "04_HERO_SELECTED", "05_SMALL_BUILDING_SELECTED", "06_HQ_SELECTED", "07_TWO_UNITS_NEARBY_ONE_SELECTED", "08_MULTISELECT_GROUP", "09_HERO_SELECTED_NEAR_ZOOM", "10_HQ_SELECTED_FAR_ZOOM"]
  : ["11_1366_UNIT_SELECTED", "12_1366_BUILDING_SELECTED"]; }

function validateManifest(manifest, width, height, label) {
  const failures = [];
  if (manifest.schema !== "ascendant-realms-p1s3-selection-readability-v1") failures.push(`${label}: schema mismatch`);
  if (manifest.source_sha !== sourceSha()) failures.push(`${label}: source SHA mismatch`);
  if (manifest.map !== "hollowspan" || manifest.match !== "Barrosan vs Lioraen Easy") failures.push(`${label}: fixture identity mismatch`);
  if (manifest.resolution?.width !== width || manifest.resolution?.height !== height) failures.push(`${label}: resolution mismatch`);
  if (manifest.pass !== true || manifest.failures?.length) failures.push(`${label}: harness failures ${JSON.stringify(manifest.failures || [])}`);
  const names = new Set((manifest.frames || []).map((frame) => frame.name));
  for (const name of expectedNames(width)) if (!names.has(name)) failures.push(`${label}: missing frame ${name}`);
  const proof = manifest.hitbox_proof || [];
  for (const entity of ["worker", "military", "hero", "small_building", "hq"]) {
    for (const probe of ["center", "near_edge", "outside"]) {
      const hit = proof.find((item) => item.entity === entity && item.probe === probe);
      if (!hit?.pass) failures.push(`${label}: ${entity} ${probe} hitbox proof missing or failed`);
    }
  }
  if (!proof.some((item) => item.entity === "two_unit_ambiguity" && item.pass === true)) failures.push(`${label}: two-unit ambiguity proof missing`);
  if (JSON.stringify(manifest.before_positions) !== JSON.stringify(manifest.after_positions)) failures.push(`${label}: entity positions changed`);
  if (JSON.stringify(manifest.before_physics) !== JSON.stringify(manifest.after_physics)) failures.push(`${label}: gameplay physics changed`);
  for (const frame of manifest.frames || []) {
    if (frame.width !== width || frame.height !== height) failures.push(`${label}: ${frame.name} rendered size mismatch`);
    const file = frame.png.replaceAll("/", path.sep);
    if (!existsSync(file)) failures.push(`${label}: ${frame.name} PNG missing`);
    else if (readFileSync(file).length < 20000) failures.push(`${label}: ${frame.name} PNG suspiciously small`);
    if (!frame.entity_definition_id || !frame.entity_type || !frame.selection_geometry) failures.push(`${label}: ${frame.name} incomplete geometry metadata`);
  }
  return failures;
}

function capture() {
  const runDir = `run-${runStamp()}-${sourceSha().slice(0, 8)}`;
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
  const summary = { schema: "ascendant-realms-p1s3-selection-readability-capture-v1", source_sha: sourceSha(), godot, run_dir: runDir, godot_exit_codes: manifests.map((item) => item.exit_code), manifests: manifests.map((item) => item.relative), captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1s3-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2));
  if (failures.length) process.exitCode = 1;
}

function validate() {
  const failures = [];
  const captureFile = path.join(evidenceRoot, "p1s3-capture-manifest.json");
  if (!existsSync(captureFile)) failures.push("missing p1s3-capture-manifest.json");
  let summary = null;
  if (!failures.length) {
    summary = JSON.parse(readFileSync(captureFile, "utf8"));
    if (summary.source_sha !== sourceSha()) failures.push("capture summary source SHA mismatch");
    if (summary.pass !== true) failures.push(...(summary.failures || ["capture summary is not passing"]));
    for (const [relative, width, height] of [["1920x1080/selection-manifest.json", 1920, 1080], ["1366x768/selection-manifest.json", 1366, 768]]) {
      const candidates = readdirSync(evidenceRoot, { withFileTypes: true }).filter((entry) => entry.isDirectory() && entry.name.startsWith("run-"));
      const selected = summary.run_dir ? path.join(evidenceRoot, summary.run_dir, relative) : path.join(evidenceRoot, relative);
      const file = existsSync(selected) ? selected : candidates.map((entry) => path.join(evidenceRoot, entry.name, relative)).find(existsSync);
      if (!file) failures.push(`missing ${relative}`); else failures.push(...validateManifest(JSON.parse(readFileSync(file, "utf8")), width, height, relative));
    }
  }
  const projectConfig = readFileSync(path.join(project, "project.godot"), "utf8");
  if (projectConfig.includes("P1S3Capture")) failures.push("P1S3 capture autoload persisted in project.godot");
  const result = { schema: "ascendant-realms-p1s3-selection-readability-validator-v1", source_sha: sourceSha(), godot, evidence_root: evidenceRoot, summary, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1s3-validator-report.json"), JSON.stringify(result, null, 2) + "\n");
  console.log(JSON.stringify(result, null, 2));
  if (failures.length) process.exitCode = 1;
}

if (mode === "capture") capture(); else validate();
