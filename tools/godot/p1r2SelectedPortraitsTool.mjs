import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { runBounded } from "../codex/runBounded.mjs";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R2_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-a\\p1r2";
const logsRoot = process.env.P1R2_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-a";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sha256 = (f) => createHash("sha256").update(readFileSync(f)).digest("hex");
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
async function withAutoload(fn) {
  const file = path.join(project, "project.godot"); const original = readFileSync(file, "utf8");
  const marker = 'P1R2Capture="*res://tests/p1r2_selected_portraits.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched); try { return await fn(); } finally { writeFileSync(file, original); }
}
async function run(width, height, output) {
  mkdirSync(output, { recursive: true });
  const log = path.join(logsRoot, `p1r2-${width}x${height}.log`);
  const bounded = await runBounded({
    command: godot,
    args: ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log],
    cwd: repo,
    env: { TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1R2_SOURCE_SHA: sourceSha(), ASCENDANT_P1R2_WIDTH: String(width), ASCENDANT_P1R2_HEIGHT: String(height), ASCENDANT_P1R2_OUTPUT: output },
    hardTimeoutMs: 600_000,
    noProgressTimeoutMs: 180_000,
    progressSources: [output, log],
    label: `p1r2-${width}x${height}`,
  });
  const mf = path.join(output, "selected-portraits-manifest.json");
  if (!existsSync(mf)) throw new Error(`missing ${mf}; classification=${bounded.classification}; exit=${bounded.exit_code}; stderr=${bounded.stderr_tail}`);
  return JSON.parse(readFileSync(mf, "utf8"));
}
function check(m, width) {
  const failures = [];
  if (m.schema !== "ascendant-realms-p1r2-selected-portraits-v1") failures.push("schema");
  if (m.source_sha !== sourceSha()) failures.push("source sha");
  if (!m.pass) failures.push(...(m.failures || ["harness failed"]));
  if (m.resolution?.width !== width) failures.push("resolution");
  for (const name of ["worker", "military", "hero", "small_building", "hq"]) {
    const frame = (m.frames || []).find((f) => f.name === name);
    if (!frame) failures.push(`missing ${name}`);
    else if (!existsSync(frame.png) || readFileSync(frame.png).length < 20000) failures.push(`suspicious ${name}`);
    else if (frame.portrait_probe?.lit_pixels < 180) failures.push(`empty ${name}`);
  }
  if (JSON.stringify(m.positions_before) !== JSON.stringify(m.positions_after)) failures.push("positions changed");
  return failures;
}
async function capture() {
  const original = readFileSync(path.join(project, "project.godot"), "utf8");
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`;
  const dir = path.join(evidenceRoot, runId);
  const out = await withAutoload(async () => [await run(1920, 1080, path.join(dir, "1920x1080")), await run(1366, 768, path.join(dir, "1366x768"))]);
  const failures = [...check(out[0], 1920), ...check(out[1], 1366)];
  const captures = out.flatMap((m) => (m.frames || []).map((f) => ({ name: f.name, png: f.png, sha256: sha256(f.png), probe: f.portrait_probe })));
  writeFileSync(path.join(evidenceRoot, "p1r2-capture-manifest.json"), JSON.stringify({ schema: "ascendant-realms-p1r2-capture-v1", source_sha: sourceSha(), run_dir: runId, godot, captures, pass: failures.length === 0, failures }, null, 2) + "\n");
  if (failures.length) process.exitCode = 1;
  console.log(JSON.stringify({ source_sha: sourceSha(), run_dir: runId, captures, pass: failures.length === 0, failures }, null, 2));
}
function validate() {
  const failures = []; const file = path.join(evidenceRoot, "p1r2-capture-manifest.json");
  if (!existsSync(file)) failures.push("missing capture manifest");
  let summary = null;
  if (!failures.length) { summary = JSON.parse(readFileSync(file, "utf8")); if (summary.source_sha !== sourceSha()) failures.push("source sha mismatch"); if (!summary.pass) failures.push(...summary.failures); }
  const config = readFileSync(path.join(project, "project.godot"), "utf8"); if (config.includes("P1R2Capture")) failures.push("capture autoload persisted");
  const allowed = new Set(["package.json", "production/ascendant-realms-godot/scripts/ui/hud.gd", "production/ascendant-realms-godot/scripts/ui/entity_portrait_view.gd", "production/ascendant-realms-godot/tests/p1r2_selected_portraits.gd", "tools/godot/p1r2SelectedPortraitsTool.mjs"]);
  const preExisting = new Set(["artifacts/manual-review/v0431-gameplay-readability-construction-loop/v0431-driver-started.txt", "artifacts/manual-review/v0432-war-hall-clan-levy-production-loop/v0432-driver-started.txt"]);
  for (const f of execFileSync("git", ["diff", "--name-only"], { cwd: repo, encoding: "utf8" }).split(/\r?\n/).filter(Boolean)) {
    if (f === "production/ascendant-realms-godot/project.godot" && !config.includes("P1R2Capture")) continue;
    if (!allowed.has(f) && !f.endsWith(".import") && !preExisting.has(f)) failures.push(`scope contamination: ${f}`);
  }
  const report = { schema: "ascendant-realms-p1r2-validator-v1", source_sha: sourceSha(), summary, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r2-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if (mode === "capture") await capture(); else validate();
