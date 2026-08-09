import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R21_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-d\\p1r21";
const logsRoot = process.env.P1R21_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-d";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = (file) => createHash("sha256").update(readFileSync(file)).digest("hex");
function withAutoload(fn) {
  const file = path.join(project, "project.godot"); const original = readFileSync(file, "utf8");
  const marker = 'P1R21Capture="*res://tests/p1r21_motion_grounding.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched); try { return fn(); } finally { writeFileSync(file, original); }
}
function run(name, role, out) {
  mkdirSync(out, { recursive: true }); const log = path.join(logsRoot, `p1r21-${name}.log`);
  const result = spawnSync(godot, ["--path", project, "--resolution", "1920x1080", "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP:"D:\\CodexData\\temp", TMP:"D:\\CodexData\\temp", ASCENDANT_P1R21_SOURCE_SHA:sourceSha(), ASCENDANT_P1R21_NAME:name, ASCENDANT_P1R21_ROLE:role, ASCENDANT_P1R21_WIDTH:"1920", ASCENDANT_P1R21_HEIGHT:"1080", ASCENDANT_P1R21_OUTPUT:out }, encoding:"utf8", timeout:300000, windowsHide:false });
  const manifest = path.join(out, "motion-grounding-manifest.json"); if (!existsSync(manifest)) throw new Error(`R21 ${name} produced no manifest; exit=${result.status}`);
  return JSON.parse(readFileSync(manifest, "utf8"));
}
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0,14)}-${sourceSha().slice(0,8)}`; const dir = path.join(evidenceRoot, runId);
  const jobs = [["01_R21_WORKER_TRAVEL","worker"],["02_R21_MILITARY_TRAVEL","military"],["03_R21_HERO_TRAVEL","hero"]];
  const manifests = withAutoload(() => jobs.map(([name,role]) => run(name,role,path.join(dir,name)))); const failures=[];
  for (const m of manifests) { if (m.source_sha !== sourceSha()) failures.push(`${m.role}:source_sha`); if (!m.pass) failures.push(...(m.failures||["capture_failed"])); for (const f of m.frames||[]) if (!existsSync(f.png) || readFileSync(f.png).length < 20000) failures.push(`${m.role}:image`); }
  const captures = manifests.flatMap(m => (m.frames||[]).map(f => ({...f, sha256:sha256(f.png)})));
  const summary = {schema:"ascendant-realms-p1r21-capture-v1",source_sha:sourceSha(),run_dir:runId,godot,jobs,manifests,captures,pass:failures.length===0,failures};
  writeFileSync(path.join(evidenceRoot,"p1r21-capture-manifest.json"),JSON.stringify(summary,null,2)+"\n"); console.log(JSON.stringify(summary,null,2)); if(failures.length) process.exitCode=1;
}
function validate() {
  const failures=[]; const unit=readFileSync(path.join(project,"scripts","units","unit.gd"),"utf8");
  for(const marker of ["P1R21_MIN_WALK_ANIMATION_SCALE","P1R21_MAX_WALK_ANIMATION_SCALE","_update_p1r21_animation_speed","anim.speed_scale","velocity.x","command_stop"]) if(!unit.includes(marker)) failures.push(`missing R21 contract: ${marker}`);
  const file=path.join(evidenceRoot,"p1r21-capture-manifest.json"); if(!existsSync(file)) failures.push("missing capture manifest"); else { const m=JSON.parse(readFileSync(file,"utf8")); if(m.source_sha!==sourceSha()) failures.push("source_sha"); if(!m.pass) failures.push(...(m.failures||["capture_failed"])); for(const name of ["01_R21_WORKER_TRAVEL","02_R21_MILITARY_TRAVEL","03_R21_HERO_TRAVEL"]) if(!(m.captures||[]).some(f=>f.name===name)) failures.push(`missing ${name}`); for(const f of (m.captures||[])) { if(f.simulation_speed_before!==1 || f.simulation_speed_after!==1) failures.push(`${f.role}:simulation_speed_changed`); if(f.final_velocity && Math.hypot(f.final_velocity.x,f.final_velocity.z)>0.2) failures.push(`${f.role}:did_not_settle`); if(f.endpoint_displacement<=0.5) failures.push(`${f.role}:no_travel`); } }
  const cfg=readFileSync(path.join(project,"project.godot"),"utf8"); if(cfg.includes("P1R21Capture")) failures.push("capture autoload persisted");
  const report={schema:"ascendant-realms-p1r21-validator-v1",source_sha:sourceSha(),evidence_root:evidenceRoot,pass:failures.length===0,failures}; writeFileSync(path.join(evidenceRoot,"p1r21-validator-report.json"),JSON.stringify(report,null,2)+"\n"); console.log(JSON.stringify(report,null,2)); if(failures.length) process.exitCode=1;
}
if((process.argv[2]||"validate")==="capture") capture(); else validate();
