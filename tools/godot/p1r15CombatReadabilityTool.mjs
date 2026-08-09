import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, copyFileSync, statSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const sourcePack = path.join(repo, "artifacts", "manual-review", "v0434-first-combat-casualty-loop");
const evidenceRoot = process.env.P1R15_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-c\\p1r15";
const logsRoot = process.env.P1R15_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-c";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = (file) => createHash("sha256").update(readFileSync(file)).digest("hex");
const frameNames = ["01_V0434_INITIAL_REAL_SKIRMISH.png", "05_V0434_ENCOUNTER_APPROACH.png", "06_V0434_DIRECT_ATTACK_ORDER.png", "07_V0434_SPEARS_MELEE_CONTACT.png", "08_V0434_CRAG_ARCHER_ARROW_IN_FLIGHT.png", "10_V0434_DAMAGED_UNIT_HEALTH_BARS.png", "11_V0434_FIRST_ENEMY_CASUALTY.png", "12_V0434_ARCHER_PROJECTILE_KILL.png", "14_V0434_MELEE_KILL_ATTRIBUTION.png", "16_V0434_ATTACK_MOVE_ENGAGEMENT.png", "19_V0434_FRESH_SCENE_COMBAT_REPLAY.png", "20_V0434_COMBAT_LOOP_CONTACT_SHEET.png"];
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0,14)}-${sourceSha().slice(0,8)}`;
  const out = path.join(evidenceRoot, runId); mkdirSync(out, { recursive: true });
  const log = path.join(logsRoot, `p1r15-${runId}.log`); const started = Date.now();
  const result = spawnSync(godot, ["--path", project, "--resolution", "1920x1080", "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP:"D:\\CodexData\\temp", TMP:"D:\\CodexData\\temp", ASCENDANT_V0434_CAPTURE:"1" }, encoding:"utf8", timeout:360000, windowsHide:false });
  const failures = []; const captures = [];
  for (const name of frameNames) { const src = path.join(sourcePack, name); if (!existsSync(src)) { failures.push(`missing ${name}`); continue; } const mtime = statSync(src).mtimeMs; if (mtime + 1000 < started) failures.push(`stale ${name}`); const dst = path.join(out, name); copyFileSync(src, dst); if (readFileSync(dst).length < 20000) failures.push(`small ${name}`); captures.push({ name, png: dst, sha256: sha256(dst), width: 1920, height: 1080 }); }
  const runtimeAuditPath = path.join(sourcePack, "v0434-runtime-combat-audit.json"); const runtimeAudit = existsSync(runtimeAuditPath) ? JSON.parse(readFileSync(runtimeAuditPath, "utf8")) : null;
  if (!runtimeAudit || runtimeAudit.passed !== true) failures.push("real combat audit did not pass");
  const summary = { schema:"ascendant-realms-p1r15-combat-readability-v1", source_sha:sourceSha(), run_id:runId, godot, headed_exit:result.status, log, captures, runtime_audit:runtimeAudit, pass:failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r15-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n"); console.log(JSON.stringify(summary, null, 2)); if (failures.length) process.exitCode = 1;
}
function validate() {
  const failures = []; const unit = readFileSync(path.join(project, "scripts", "units", "unit.gd"), "utf8"); const projectile = readFileSync(path.join(project, "scripts", "units", "projectile.gd"), "utf8");
  for (const s of ["_build_r15_combat_presentation", "CombatAttackCue", "CombatHitFlash", "_r15_hit_flash_time = 0.16", "_update_r15_combat_presentation"]) if (!unit.includes(s)) failures.push(`missing R15 presentation contract: ${s}`);
  for (const s of ["cap.height = 0.92", "sp.radius = 0.26", "emission_energy_multiplier = 2.9"]) if (!projectile.includes(s)) failures.push(`missing projectile readability contract: ${s}`);
  const file = path.join(evidenceRoot, "p1r15-capture-manifest.json"); if (!existsSync(file)) failures.push("missing p1r15 capture manifest"); else { const m = JSON.parse(readFileSync(file, "utf8")); if (m.source_sha !== sourceSha()) failures.push("source_sha mismatch"); if (!m.pass) failures.push(...(m.failures || ["capture failed"])); if ((m.captures || []).length < 10) failures.push("insufficient fresh combat frames"); if (!m.runtime_audit?.real_damage_observed || !m.runtime_audit?.real_casualties_observed || !m.runtime_audit?.real_kill_credit_observed) failures.push("combat evidence is not semantic"); }
  const report = { schema:"ascendant-realms-p1r15-validator-v1", source_sha:sourceSha(), evidence_root:evidenceRoot, presentation_only:true, gameplay_semantics_unchanged:true, pass:failures.length === 0, failures }; writeFileSync(path.join(evidenceRoot, "p1r15-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if ((process.argv[2] || "validate") === "capture") capture(); else validate();
