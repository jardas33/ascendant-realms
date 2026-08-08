import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1S1_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1s1-viewport-safearea";
const logsRoot = process.env.P1S1_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1s1-viewport-safearea";
const mode = process.argv[2] || "validate";

mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });

function runCapture(kind, width, height, fileStem) {
  const output = path.join(evidenceRoot, fileStem);
  const env = {
    ...process.env,
    TEMP: "D:\\CodexData\\temp",
    TMP: "D:\\CodexData\\temp",
    npm_config_cache: "D:\\CodexData\\cache\\npm",
    ASCENDANT_P1S1_CAPTURE: "1",
    ASCENDANT_P1S1_CAPTURE_KIND: kind,
    ASCENDANT_P1S1_WIDTH: String(width),
    ASCENDANT_P1S1_HEIGHT: String(height),
    ASCENDANT_P1S1_OUTPUT: output,
  };
  const logPath = path.join(logsRoot, `${fileStem}.log`);
  const args = ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20"];
  const result = spawnSync(godot, args, { cwd: repo, env, encoding: "utf8", timeout: 120000, windowsHide: false });
  writeFileSync(logPath, `${result.stdout || ""}\n${result.stderr || ""}`);
  if (result.error) throw new Error(`${kind} failed to launch: ${result.error.message}`);
  if (result.status !== 0) throw new Error(`${kind} exited ${result.status}; see ${logPath}`);
  const png = `${output}.png`;
  const json = `${output}.json`;
  if (!existsSync(png) || !existsSync(json)) throw new Error(`${kind} did not produce both ${png} and ${json}`);
  if (statSync(png).size < 20000) throw new Error(`${kind} produced a suspiciously small/blank image; see ${png}`);
  return { kind, width, height, output, png, json, logPath };
}

function sha256(file) { return createHash("sha256").update(readFileSync(file)).digest("hex"); }

function validateGeometry(paths) {
  const reports = paths.map((item) => JSON.parse(readFileSync(item.json, "utf8")));
  const failures = [];
  for (const report of reports) {
    if (!report.all_visible_surfaces_inside) failures.push(`${report.capture_kind}: surface outside viewport`);
    if (report.actual_viewport.width !== report.image_width || report.actual_viewport.height !== report.image_height) {
      failures.push(`${report.capture_kind}: viewport/image mismatch`);
    }
    if (report.window_size.width !== report.image_width || report.window_size.height !== report.image_height) {
      failures.push(`${report.capture_kind}: window/image mismatch`);
    }
    for (const [name, surface] of Object.entries(report.surfaces || {})) {
      if (surface.visible && !surface.inside) failures.push(`${report.capture_kind}: ${name} outside viewport`);
    }
  }
  return { pass: failures.length === 0, failures, reports };
}

function writeManifest(captures, result, command) {
  const manifest = {
    tool: "p1s1ViewportSafeAreaTool",
    mode,
    command,
    repository: repo,
    project,
    godot,
    captures: captures.map((capture) => ({ ...capture, sha256: sha256(capture.png) })),
    geometry: result.reports,
    pass: result.pass,
    failures: result.failures,
  };
  const out = path.join(evidenceRoot, `p1s1-${mode}-manifest.json`);
  writeFileSync(out, JSON.stringify(manifest, null, 2));
  return out;
}

const captures = [
  runCapture("menu", 1920, 1080, "01_1920_MAIN_MENU"),
  runCapture("live_idle", 1920, 1080, "02_1920_LIVE_HUD_IDLE"),
  runCapture("live_selected_unit", 1920, 1080, "03_1920_LIVE_HUD_SELECTED_UNIT"),
  runCapture("menu", 1366, 768, "04_1366_MAIN_MENU"),
  runCapture("live_idle", 1366, 768, "05_1366_LIVE_HUD_IDLE"),
  runCapture("live_selected_unit", 1366, 768, "06_1366_LIVE_HUD_SELECTED_UNIT"),
];
const result = validateGeometry(captures.filter((capture) => capture.kind !== "menu"));
const manifest = writeManifest(captures, result, process.argv.slice(2).join(" "));
console.log(JSON.stringify({ manifest, pass: result.pass, failures: result.failures }, null, 2));
if (!result.pass) process.exitCode = 1;
