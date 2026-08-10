import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R4_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-a\\p1r4";
const logsRoot = process.env.P1R4_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-a";
const mode = process.argv[2] || "validate";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = (f) => createHash("sha256").update(readFileSync(f)).digest("hex");
function withAutoload(fn) {
  const file = path.join(project, "project.godot"); const original = readFileSync(file, "utf8");
  const marker = 'P1R4Capture="*res://tests/p1r4_worker_interaction.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched); try { return fn(); } finally { writeFileSync(file, original); }
}
function run(width, height, output) {
  mkdirSync(output, { recursive: true }); const log = path.join(logsRoot, `p1r4-${width}x${height}.log`);
  const r = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP: "D:\\CodexData\\temp", TMP: "D:\\CodexData\\temp", ASCENDANT_P1R4_SOURCE_SHA: sourceSha(), ASCENDANT_P1R4_WIDTH: String(width), ASCENDANT_P1R4_HEIGHT: String(height), ASCENDANT_P1R4_OUTPUT: output }, encoding: "utf8", timeout: 300000, windowsHide: false });
  const mf = path.join(output, "worker-interaction-manifest.json"); if (!existsSync(mf)) throw new Error(`missing ${mf}; exit=${r.status}`); return JSON.parse(readFileSync(mf, "utf8"));
}
function check(m, width) {
  const failures = []; if (m.schema !== "ascendant-realms-p1r4-worker-interaction-v1") failures.push("schema"); if (m.source_sha !== sourceSha()) failures.push("source sha"); if (!m.pass) failures.push(...(m.failures || ["harness failed"])); if (m.resolution?.width !== width) failures.push("resolution");
  for (const kind of ["gather", "build"]) { const f = (m.frames || []).find((x) => x.name === kind); const metric = m.metrics?.[kind]; if (!f) failures.push(`missing ${kind}`); else if (!existsSync(f.png) || readFileSync(f.png).length < 20000) failures.push(`suspicious ${kind}`); if (!metric || metric.sample_count < 20) failures.push(`insufficient ${kind} samples`); }
  return failures;
}
function capture() {
  const id = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`; const dir = path.join(evidenceRoot, id);
  const out = withAutoload(() => [run(1920, 1080, path.join(dir, "1920x1080")), run(1366, 768, path.join(dir, "1366x768"))]); const failures = [...check(out[0], 1920), ...check(out[1], 1366)];
  const captures = out.flatMap((m) => (m.frames || []).map((f) => ({ name: f.name, png: f.png, sha256: sha256(f.png), samples: f.sample_count, final_state: f.final_state })));
  const summary = { schema: "ascendant-realms-p1r4-capture-v1", source_sha: sourceSha(), run_dir: id, godot, captures, metrics: out.map((m) => m.metrics), pass: failures.length === 0, failures }; writeFileSync(path.join(evidenceRoot, "p1r4-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n"); console.log(JSON.stringify(summary, null, 2)); if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = []; const file = path.join(evidenceRoot, "p1r4-capture-manifest.json"); if (!existsSync(file)) failures.push("missing capture manifest"); let summary = null; if (!failures.length) { summary = JSON.parse(readFileSync(file, "utf8")); if (summary.source_sha !== sourceSha()) failures.push("source sha mismatch"); if (!summary.pass) failures.push(...summary.failures); }
  const config = readFileSync(path.join(project, "project.godot"), "utf8"); if (config.includes("P1R4Capture")) failures.push("capture autoload persisted"); const allowed = new Set(["package.json", "production/ascendant-realms-godot/scripts/units/unit.gd", "production/ascendant-realms-godot/scripts/ui/hud.gd", "production/ascendant-realms-godot/scripts/world/map_defs.gd", "production/ascendant-realms-godot/tests/p1r4_worker_interaction.gd", "tools/godot/p1r3MinimapTerrainTool.mjs", "tools/godot/p1r4WorkerInteractionTool.mjs"]); const preExisting = new Set(["artifacts/manual-review/v0431-gameplay-readability-construction-loop/v0431-driver-started.txt", "artifacts/manual-review/v0432-war-hall-clan-levy-production-loop/v0432-driver-started.txt"]);
  for (const f of execFileSync("git", ["diff", "--name-only"], { cwd: repo, encoding: "utf8" }).split(/\r?\n/).filter(Boolean)) { if (f === "production/ascendant-realms-godot/project.godot" && !config.includes("P1R4Capture")) continue; if (!allowed.has(f) && !f.endsWith(".import") && !preExisting.has(f)) failures.push(`scope contamination: ${f}`); }
  const report = { schema: "ascendant-realms-p1r4-validator-v1", source_sha: sourceSha(), summary, pass: failures.length === 0, failures }; writeFileSync(path.join(evidenceRoot, "p1r4-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if (mode === "capture") capture(); else validate();
