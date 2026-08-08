import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1S2_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1s2-camera-bounds";
const logsRoot = process.env.P1S2_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1s2-camera-bounds";
const mode = process.argv[2] || "validate";

mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });

function sourceSha() {
  return execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
}

function sha256(file) {
  return createHash("sha256").update(readFileSync(file)).digest("hex");
}

function withCaptureAutoload(fn) {
  const projectFile = path.join(project, "project.godot");
  const original = readFileSync(projectFile, "utf8");
  const marker = 'P1S2Capture="*res://tests/p1s2_camera_bounds.gd"';
  const patched = original.includes(marker)
    ? original
    : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(projectFile, patched);
  try {
    return fn();
  } finally {
    writeFileSync(projectFile, original);
  }
}

function runCapture(width, height) {
  const label = `candidate-${width}`;
  const output = path.join(evidenceRoot, label);
  const logPath = path.join(logsRoot, `${label}.log`);
  mkdirSync(output, { recursive: true });
  const env = {
    ...process.env,
    TEMP: "D:\\CodexData\\temp",
    TMP: "D:\\CodexData\\temp",
    npm_config_cache: "D:\\CodexData\\cache\\npm",
    ASCENDANT_P1S2_MODE: "candidate",
    ASCENDANT_P1S2_SOURCE_SHA: sourceSha(),
    ASCENDANT_P1S2_WIDTH: String(width),
    ASCENDANT_P1S2_HEIGHT: String(height),
    ASCENDANT_P1S2_OUTPUT: output,
  };
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", logPath], {
    cwd: repo,
    env,
    encoding: "utf8",
    timeout: 120000,
    windowsHide: false,
  });
  writeFileSync(logPath, `${result.stdout || ""}\n${result.stderr || ""}`);
  if (result.error) throw new Error(`P1-S2 ${label} launch failed: ${result.error.message}`);
  if (result.status !== 0) throw new Error(`P1-S2 ${label} exited ${result.status}; see ${logPath}`);
  const manifest = path.join(output, "camera-manifest.json");
  if (!existsSync(manifest)) throw new Error(`P1-S2 ${label} did not produce ${manifest}`);
  return JSON.parse(readFileSync(manifest, "utf8"));
}

function validateManifest(manifest, expectedWidth, expectedHeight) {
  const failures = [];
  if (manifest.mode !== "candidate") failures.push("capture mode is not candidate");
  if (manifest.map !== "hollowspan") failures.push("map is not hollowspan");
  if (manifest.frames?.length !== 10) failures.push(`expected 10 frames, received ${manifest.frames?.length ?? 0}`);
  if (manifest.failures?.length) failures.push(...manifest.failures);
  for (const frame of manifest.frames || []) {
    if (frame.width !== expectedWidth || frame.height !== expectedHeight) failures.push(`${frame.name}: rendered dimensions mismatch`);
    if (frame.requested_width !== expectedWidth || frame.requested_height !== expectedHeight) failures.push(`${frame.name}: requested dimensions mismatch`);
    if (frame.entities_unchanged !== true) failures.push(`${frame.name}: entity positions changed`);
    if (frame.state?.inside_safe_bounds !== true) failures.push(`${frame.name}: focus outside safe bounds`);
    if (frame.state?.safe_bounds?.source !== "GameWorld.playable_bounds_contract") failures.push(`${frame.name}: authoritative bounds source missing`);
    const png = frame.png.replaceAll("/", path.sep);
    if (!existsSync(png)) failures.push(`${frame.name}: missing rendered PNG`);
    else if (readFileSync(png).length < 20000) failures.push(`${frame.name}: suspiciously small PNG`);
  }
  return failures;
}

function validateProductionCameraContract() {
  const failures = [];
  const cameraScript = readFileSync(path.join(project, "scripts", "world", "rts_controller.gd"), "utf8");
  const projectConfig = readFileSync(path.join(project, "project.godot"), "utf8");
  const requiredCameraSnippets = [
    "const CAMERA_SAFE_FOCUS_MARGIN := 8.0",
    "cam_arm.collision_mask = 0",
    "func _camera_safe_bounds() -> Dictionary:",
    "func _clamp_camera_focus(pos: Vector3) -> Vector3:",
    "cam_pivot.global_position = _clamp_camera_focus(cam_pivot.global_position + dir * cam_speed * delta)",
    "cam_pivot.global_position = _clamp_camera_focus(pos)",
    '"source": "GameWorld.playable_bounds_contract"',
    "func get_camera_safe_bounds() -> Dictionary:",
    "func is_camera_focus_within_safe_bounds() -> bool:",
    "func get_camera_zoom_min() -> float:",
    "func get_camera_zoom_max() -> float:",
  ];
  for (const snippet of requiredCameraSnippets) {
    if (!cameraScript.includes(snippet)) failures.push(`missing production camera contract: ${snippet}`);
  }
  if (projectConfig.includes('P1S2Capture="*res://tests/p1s2_camera_bounds.gd"')) {
    failures.push("P1-S2 capture autoload persisted in project.godot");
  }
  return failures;
}

function capture() {
  const manifests = withCaptureAutoload(() => [runCapture(1920, 1080), runCapture(1366, 768)]);
  const out = {
    schema: "ascendant-realms-p1s2-camera-bounds-v1",
    source_sha: sourceSha(),
    godot,
    map: "hollowspan",
    capture_mode: "non-headless Godot runtime",
    manifests: ["candidate-1920/camera-manifest.json", "candidate-1366/camera-manifest.json"],
    pass: manifests.every((m, i) => validateManifest(m, i === 0 ? 1920 : 1366, i === 0 ? 1080 : 768).length === 0),
    captures: manifests.flatMap((m, i) => (m.frames || []).map((f) => ({
      name: f.name,
      resolution: `${i === 0 ? 1920 : 1366}x${i === 0 ? 1080 : 768}`,
      path: f.png,
      sha256: sha256(f.png.replaceAll("/", path.sep)),
    }))),
  };
  writeFileSync(path.join(evidenceRoot, "p1s2-capture-manifest.json"), JSON.stringify(out, null, 2) + "\n");
  if (!out.pass) process.exitCode = 1;
  console.log(JSON.stringify(out, null, 2));
}

function validate() {
  const failures = validateProductionCameraContract();
  const expected = [["candidate-1920/camera-manifest.json", 1920, 1080], ["candidate-1366/camera-manifest.json", 1366, 768]];
  for (const [relative, width, height] of expected) {
    const file = path.join(evidenceRoot, relative);
    if (!existsSync(file)) {
      failures.push(`missing ${relative}`);
      continue;
    }
    failures.push(...validateManifest(JSON.parse(readFileSync(file, "utf8")), width, height).map((f) => `${relative}: ${f}`));
  }
  const result = { schema: "ascendant-realms-p1s2-camera-bounds-validator-v1", source_sha: sourceSha(), godot, evidence_root: evidenceRoot, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1s2-validator-report.json"), JSON.stringify(result, null, 2) + "\n");
  console.log(JSON.stringify(result, null, 2));
  if (failures.length) process.exitCode = 1;
}

if (mode === "capture") capture();
else validate();
