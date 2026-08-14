import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1_RESOURCES_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-resources-01";
const logsRoot = process.env.P1_RESOURCES_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-resources-01";
mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = file => createHash("sha256").update(readFileSync(file)).digest("hex");

function withAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const marker = 'P1Resources01Capture="*res://tests/p1_resources_01_readability.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', `P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n${marker}`);
  writeFileSync(file, patched);
  try { return fn(); } finally { writeFileSync(file, original); }
}

function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`;
  const output = path.join(evidenceRoot, runId);
  mkdirSync(output, { recursive: true });
  const log = path.join(logsRoot, `${runId}.log`);
  const result = withAutoload(() => spawnSync(godot, ["--path", project, "--resolution", "1920x1080", "--windowed", "--position", "20,20", "--log-file", log], {
    cwd: repo,
    env: { ...process.env, TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1_RESOURCES_SOURCE_SHA: sourceSha(), ASCENDANT_P1_RESOURCES_WIDTH: "1920", ASCENDANT_P1_RESOURCES_HEIGHT: "1080", ASCENDANT_P1_RESOURCES_OUTPUT: output },
    encoding: "utf8",
    timeout: 300000,
    windowsHide: false
  }));
  const manifestFile = path.join(output, "resource-readability-manifest.json");
  if (!existsSync(manifestFile)) throw new Error(`P1 RESOURCES-01 produced no manifest; exit=${result.status}`);
  const manifest = JSON.parse(readFileSync(manifestFile, "utf8"));
  const failures = [...(manifest.failures || [])];
  if (manifest.source_sha !== sourceSha()) failures.push("source_sha");
  for (const frame of manifest.frames || []) {
    if (!existsSync(frame.png) || readFileSync(frame.png).length < 20000) failures.push(`invalid_frame:${frame.label}`);
    else frame.sha256 = sha256(frame.png);
  }
  const summary = { schema: "ascendant-realms-p1-resources-01-capture-v1", source_sha: sourceSha(), run_dir: runId, godot, manifest, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1-resources-01-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2));
  if (failures.length) process.exitCode = 1;
}

function validate() {
  const failures = [];
  const source = readFileSync(path.join(project, "scripts", "world", "resource_node.gd"), "utf8");
  for (const contract of ["_apply_p1r14_resource_readability", "_add_p1r14_resource_accent", "resource_kind", "ResourceReadabilityAccent"]) if (!source.includes(contract)) failures.push(`missing_resource_contract:${contract}`);
  const manifestFile = path.join(evidenceRoot, "p1-resources-01-capture-manifest.json");
  if (!existsSync(manifestFile)) failures.push("missing_capture_manifest");
  else {
    const summary = JSON.parse(readFileSync(manifestFile, "utf8"));
    if (summary.source_sha !== sourceSha()) failures.push("source_sha");
    if (!summary.pass) failures.push(...(summary.failures || ["capture_failed"]));
    const labels = new Set((summary.manifest.frames || []).map(frame => frame.label));
    for (const label of ["resource_stone", "resource_timber", "resource_gold", "resource_food", "mixed_resource_area"]) if (!labels.has(label)) failures.push(`missing_frame:${label}`);
  }
  const cfg = readFileSync(path.join(project, "project.godot"), "utf8");
  if (cfg.includes("P1Resources01Capture")) failures.push("capture_autoload_persisted");
  const report = { schema: "ascendant-realms-p1-resources-01-validator-v1", source_sha: sourceSha(), evidence_root: evidenceRoot, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1-resources-01-validator-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  if (failures.length) process.exitCode = 1;
}

if ((process.argv[2] || "validate") === "capture") capture(); else validate();
