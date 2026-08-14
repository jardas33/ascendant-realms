import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { runBounded } from "../codex/runBounded.mjs";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R1_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-a\\p1r1";
const logsRoot = process.env.P1R1_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-a";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });
function sha256(file) { return createHash("sha256").update(readFileSync(file)).digest("hex"); }
function currentHeadSha() { return execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim(); }
function sourceSha() { return process.env.P1R1_SOURCE_SHA_OVERRIDE || currentHeadSha(); }
function gitNames(args) { return execFileSync("git", args, { cwd: repo, encoding: "utf8" }).split(/\r?\n/).filter(Boolean); }
function stamp() { return process.env.P1R1_CAPTURE_TIMESTAMP || new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14); }
async function withAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const marker = 'P1R1Capture="*res://tests/p1r1_unit_readability.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched);
  try { return await fn(); } finally { writeFileSync(file, original); }
}
async function captureOne(width, height, output) {
  mkdirSync(output, { recursive: true });
  const log = path.join(logsRoot, `p1r1-${width}x${height}.log`);
  const bounded = await runBounded({
    command: godot,
    args: ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log],
    cwd: repo,
    env: { TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1R1_SOURCE_SHA: sourceSha(), ASCENDANT_P1R1_WIDTH: String(width), ASCENDANT_P1R1_HEIGHT: String(height), ASCENDANT_P1R1_OUTPUT: output },
    hardTimeoutMs: 540_000,
    noProgressTimeoutMs: 240_000,
    progressSources: [output, log],
    label: `p1r1-${width}x${height}`,
  });
  const manifest = path.join(output, "unit-readability-manifest.json");
  if (!existsSync(manifest)) throw new Error(`missing ${manifest}; classification=${bounded.classification}; exit=${bounded.exit_code}; stderr=${bounded.stderr_tail}`);
  return { manifest: JSON.parse(readFileSync(manifest, "utf8")), exit: bounded.exit_code, classification: bounded.classification };
}
function expected(width) { return width === 1920 ? ["01_LIORAEN_DEFAULT", "02_LIORAEN_NEAR", "03_LIORAEN_GROUP", "04_LIORAEN_MIXED", "05_BARROSAN_MIXED", "06_VORTHAK_MIXED"] : ["01_LIORAEN_DEFAULT", "05_BARROSAN_MIXED", "06_VORTHAK_MIXED"]; }
function check(item, width, label) {
  const failures = [];
  if (item.schema !== "ascendant-realms-p1r1-unit-readability-v1") failures.push(`${label}: schema`);
  if (item.source_sha !== sourceSha()) failures.push(`${label}: source sha`);
  if (!item.pass) failures.push(...(item.failures || [`${label}: harness failed`]));
  if (item.resolution?.width !== width) failures.push(`${label}: resolution`);
  for (const name of expected(width)) {
    const frame = (item.frames || []).find((f) => f.name === name);
    if (!frame) { failures.push(`${label}: missing ${name}`); continue; }
    if (!existsSync(frame.png) || readFileSync(frame.png).length < 20000) failures.push(`${label}: suspicious ${name}`);
  }
  for (const role of ["worker", "military", "hero"]) if (!(item.role_measurements || []).some((m) => m.role === role && Number(m.pixels) > 8)) failures.push(`${label}: no measurable ${role}`);
  if (JSON.stringify(item.positions_before) !== JSON.stringify(item.positions_after)) failures.push(`${label}: positions changed`);
  return failures;
}
async function capture() {
  const run = `run-${stamp()}-${sourceSha().slice(0, 8)}`;
  const dir = path.join(evidenceRoot, run);
  const outputs = await withAutoload(async () => [await captureOne(1920, 1080, path.join(dir, "1920x1080")), await captureOne(1366, 768, path.join(dir, "1366x768"))]);
  const failures = [...check(outputs[0].manifest, 1920, "1920"), ...check(outputs[1].manifest, 1366, "1366")];
  const captures = outputs.flatMap((o) => o.manifest.frames.map((f) => ({ name: f.name, png: f.png, sha256: sha256(f.png) })));
  const summary = { schema: "ascendant-realms-p1r1-capture-v1", source_sha: sourceSha(), run_dir: run, godot, captures, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r1-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2));
  if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = [];
  const file = path.join(evidenceRoot, "p1r1-capture-manifest.json");
  if (!existsSync(file)) failures.push("missing p1r1 capture manifest");
  let summary = null;
  const validationInputSha = currentHeadSha();
  if (!failures.length) { summary = JSON.parse(readFileSync(file, "utf8")); if (summary.source_sha !== sourceSha()) failures.push("source sha mismatch"); if (!summary.pass) failures.push(...summary.failures); }
  const config = readFileSync(path.join(project, "project.godot"), "utf8");
  if (config.includes("P1R1Capture")) failures.push("capture autoload persisted");
  const allowedProduction = new Set([
    "docs/P1_UNITS_01_UNIT_MODEL_SILHOUETTE_MOTION_READABILITY_REPORT.md",
    "package.json",
    "production/ascendant-realms-godot/scripts/units/unit.gd",
    "tools/godot/p1Units01Tool.mjs",
  ]);
  const allowedTooling = new Set(["tools/godot/p1Units01Tool.mjs", "tools/godot/p1r1UnitReadabilityTool.mjs"]);
  const captureSourceSha = summary?.source_sha || null;
  if (captureSourceSha) {
    try { execFileSync("git", ["cat-file", "-e", `${captureSourceSha}^{commit}`], { cwd: repo, stdio: "ignore" }); }
    catch { failures.push("capture source commit unavailable"); }
    if (failures.length === 0) {
      for (const f of gitNames(["diff-tree", "--no-commit-id", "--name-only", "-r", `${captureSourceSha}^`, captureSourceSha])) if (!allowedProduction.has(f)) failures.push(`captured source scope contamination: ${f}`);
      for (const commit of gitNames(["rev-list", "--ancestry-path", "--reverse", `${captureSourceSha}..${validationInputSha}`])) {
        for (const f of gitNames(["diff-tree", "--no-commit-id", "--name-only", "-r", commit])) if (!allowedTooling.has(f)) failures.push(`validator child scope contamination: ${commit}:${f}`);
      }
    }
  }
  const ambientDirtyPaths = gitNames(["diff", "--name-only"]);
  const report = { schema: "ascendant-realms-p1r1-validator-v1", source_sha: captureSourceSha, validation_input_sha: validationInputSha, ambient_dirty_paths: ambientDirtyPaths, summary, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r1-validator-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  if (failures.length) process.exitCode = 1;
}
if (mode === "capture") await capture(); else validate();
