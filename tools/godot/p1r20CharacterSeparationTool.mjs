import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R20_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-d\\p1r20";
const logsRoot = process.env.P1R20_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-d";
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = (file) => createHash("sha256").update(readFileSync(file)).digest("hex");
function withAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const marker = 'P1R20Capture="*res://tests/p1r20_character_separation.gd"';
  const patched = original.includes(marker) ? original : original.replace('P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"', 'P1S1Capture="*res://tests/p1s1_viewport_safe_area.gd"\n' + marker);
  writeFileSync(file, patched);
  try { return fn(); } finally { writeFileSync(file, original); }
}
function run(name, race, view, out) {
  mkdirSync(out, { recursive: true });
  const log = path.join(logsRoot, `p1r20-${name}.log`);
  const result = spawnSync(godot, ["--path", project, "--resolution", "1920x1080", "--windowed", "--position", "20,20", "--log-file", log], { cwd: repo, env: { ...process.env, TEMP:"D:\\CodexData\\temp", TMP:"D:\\CodexData\\temp", ASCENDANT_P1R20_SOURCE_SHA:sourceSha(), ASCENDANT_P1R20_NAME:name, ASCENDANT_P1R20_RACE:race, ASCENDANT_P1R20_VIEW:view, ASCENDANT_P1R20_WIDTH:"1920", ASCENDANT_P1R20_HEIGHT:"1080", ASCENDANT_P1R20_OUTPUT:out }, encoding:"utf8", timeout:300000, windowsHide:false });
  const manifest = path.join(out, "character-separation-manifest.json");
  if (!existsSync(manifest)) throw new Error(`R20 ${name} produced no manifest; exit=${result.status}`);
  return JSON.parse(readFileSync(manifest, "utf8"));
}
function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0,14)}-${sourceSha().slice(0,8)}`;
  const dir = path.join(evidenceRoot, runId);
  const jobs = [["01_R20_LIORAEN_MIXED","lioraen","default"],["02_R20_BARROSAN_MIXED","barrosan","default"],["03_R20_VORTHAK_MIXED","vorthak","default"],["04_R20_HERO_DEFAULT","barrosan","hero"],["05_R20_WORKER_DEFAULT","barrosan","worker"],["06_R20_NEAR_MODELS","barrosan","near"]];
  const manifests = withAutoload(() => jobs.map(([name,race,view]) => run(name,race,view,path.join(dir,name))));
  const failures = [];
  for (const m of manifests) { if (m.source_sha !== sourceSha()) failures.push(`${m.race}:${m.view}:source_sha`); if (!m.pass) failures.push(...(m.failures||["capture_failed"])); for (const f of m.frames||[]) if (!existsSync(f.png) || readFileSync(f.png).length < 20000) failures.push(`${m.race}:${m.view}:image`); }
  const captures = manifests.flatMap(m => (m.frames||[]).map(f => ({...f, sha256:sha256(f.png)})));
  const summary = {schema:"ascendant-realms-p1r20-capture-v1",source_sha:sourceSha(),run_dir:runId,godot,jobs,manifests,captures,pass:failures.length===0,failures};
  writeFileSync(path.join(evidenceRoot,"p1r20-capture-manifest.json"),JSON.stringify(summary,null,2)+"\n"); console.log(JSON.stringify(summary,null,2)); if(failures.length) process.exitCode=1;
}
function validate() {
  const failures=[]; const unit=readFileSync(path.join(project,"scripts","units","unit.gd"),"utf8");
  for(const marker of ["P1R20_WORKER_VALUE_LIFT","P1R20_MILITARY_VALUE_LIFT","P1R20_HERO_VALUE_LIFT","_apply_p1r20_model_materials","set_surface_override_material","TeamPip"]) if(!unit.includes(marker)) failures.push(`missing R20 contract: ${marker}`);
  const file=path.join(evidenceRoot,"p1r20-capture-manifest.json"); if(!existsSync(file)) failures.push("missing capture manifest"); else { const m=JSON.parse(readFileSync(file,"utf8")); if(m.source_sha!==sourceSha()) failures.push("source_sha"); if(!m.pass) failures.push(...(m.failures||["capture_failed"])); for(const name of ["01_R20_LIORAEN_MIXED","02_R20_BARROSAN_MIXED","03_R20_VORTHAK_MIXED","04_R20_HERO_DEFAULT","05_R20_WORKER_DEFAULT","06_R20_NEAR_MODELS"]) if(!(m.captures||[]).some(f=>f.name===name)) failures.push(`missing ${name}`); }
  const cfg=readFileSync(path.join(project,"project.godot"),"utf8"); if(cfg.includes("P1R20Capture")) failures.push("capture autoload persisted");
  const report={schema:"ascendant-realms-p1r20-validator-v1",source_sha:sourceSha(),evidence_root:evidenceRoot,pass:failures.length===0,failures}; writeFileSync(path.join(evidenceRoot,"p1r20-validator-report.json"),JSON.stringify(report,null,2)+"\n"); console.log(JSON.stringify(report,null,2)); if(failures.length) process.exitCode=1;
}
if((process.argv[2]||"validate")==="capture") capture(); else validate();
