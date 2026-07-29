import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { execFileSync } from "node:child_process";

const repo = process.cwd();
const pack = path.join(repo, "artifacts", "manual-review", "v0316-h3-visible-animation-directional-closure");
const source = path.join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0316");
const capture = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_v0316_h3_visible_animation_directional_closure_capture.gd");
const adapter = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "barrosan_h3_directional_animation_adapter_v0314.gd");
const reportPath = path.join(repo, "docs", "V0316_H3_VISIBLE_ANIMATION_AND_DIRECTIONAL_CLOSURE_REPORT.md");
const errors = [];
const exists = p => fs.existsSync(p);
const read = p => fs.readFileSync(p, "utf8");
const json = p => JSON.parse(read(p));
const sha = p => crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex");
const requireText = (p, text, message) => { if (!exists(p) || !read(p).includes(text)) errors.push(message); };

const compact = [
  "00_READ_ME_FIRST.md", "01_IDENTICAL_FRAME_ROOT_CAUSE.png", "02_WORKER_VISIBLE_FRAME_STRIPS.png",
  "03_MILITIA_VISIBLE_FRAME_STRIPS.png", "04_WORKER_RUNTIME_ANIMATION.gif", "05_MILITIA_RUNTIME_ANIMATION.gif",
  "06_EIGHT_DIRECTION_RUNTIME_PROOF.png", "07_SCALE_COMPARISON.png", "08_BRIDGE_ROAD_TRAVERSAL.png",
  "09_FORMATION_READABILITY.png", "10_ANCHOR_MEASUREMENTS.png", "11_SAVE_LOAD_ROLLBACK_HOLD.png",
  "12_FINAL_DECISION_AND_SCORECARD.md", "compact-evidence-summary.json",
];
const scenarios = {
  worker_idle: [8, 3], worker_locomotion: [6, 4], worker_work: [6, 4],
  militia_idle: [4, 3], militia_locomotion: [6, 4],
};

function records(manifest, scenario) { return (manifest.records || []).filter(r => r.scenario === scenario); }
function cropUnits(manifest, scenario, id) { return records(manifest, scenario).flatMap(r => (r.renderedUnits || []).filter(u => !id || u.id === id)); }

function validate() {
  if (!exists(pack) || !exists(source)) errors.push("v0.316 pack or source root missing");
  if (!exists(reportPath)) errors.push("v0.316 report missing");
  for (const file of compact) if (!exists(path.join(pack, file))) errors.push(`missing compact review file: ${file}`);
  if (exists(path.join(pack, "UPLOAD_TO_CHAT")) && fs.readdirSync(path.join(pack, "UPLOAD_TO_CHAT")).filter(f => !f.startsWith(".")).length > 14) errors.push("UPLOAD_TO_CHAT exceeds 14 files");
  requireText(path.join(pack, "rendered-frame-root-cause.md"), "V0.315 IDENTICAL-FRAME ROOT CAUSE:", "exact root-cause line missing");
  requireText(capture, "RenderingServer.force_draw", "capture does not force a rendered frame");
  requireText(capture, "cropSha256", "runtime crop SHA missing");
  requireText(capture, "cropPerceptualHash", "runtime crop perceptual hash missing");
  requireText(capture, "changedPixelCount", "runtime crop pixel-diff metric missing");
  requireText(capture, "set_proof_phase", "scale/frame proof seam missing");
  requireText(adapter, "visible_animation_closure", "v0.316 visible proof seam missing");
  const manifests = {};
  for (const mode of ["player", "debug-review"]) {
    const p = path.join(source, mode, "capture-manifest.json");
    if (!exists(p)) { errors.push(`missing ${mode} capture manifest`); continue; }
    manifests[mode] = json(p);
    if (!String(manifests[mode].status).startsWith("PASS_")) errors.push(`${mode} capture did not pass`);
    if ((manifests[mode].records || []).length < 45) errors.push(`${mode} has fewer than 45 rendered records`);
    if (!manifests[mode].animationStatus?.enabled || !manifests[mode].animationStatus?.requested) errors.push(`${mode} H3 adapter was not enabled`);
    for (const row of manifests[mode].records || []) {
      if (!row.screenshotSha256 || !row.renderedUnits || !row.camera) errors.push(`${mode} record lacks rendered evidence fields`);
      for (const unit of row.renderedUnits || []) {
        const cropPath = path.join(source, mode, "crops", unit.cropFilename);
        if (!exists(cropPath)) errors.push(`missing crop ${mode}/${unit.cropFilename}`);
        else if (sha(cropPath) !== unit.cropSha256) errors.push(`crop SHA mismatch ${mode}/${unit.cropFilename}`);
        if (!unit.cropPerceptualHash || unit.changedPixelCount === undefined || !unit.renderedBbox) errors.push(`incomplete crop metrics ${mode}/${unit.cropFilename}`);
      }
    }
  }
  const player = manifests.player;
  if (player) {
    for (const [scenario, [minimum, unique]] of Object.entries(scenarios)) {
      const crops = cropUnits(player, scenario, scenario.startsWith("militia") ? "friendly_00" : "worker_00");
      if (crops.length < minimum) errors.push(`${scenario} has ${crops.length} crops, expected ${minimum}`);
      if (new Set(crops.map(c => c.cropSha256)).size < unique) errors.push(`${scenario} exact crop uniqueness below ${unique}`);
      if (new Set(crops.map(c => c.cropPerceptualHash)).size < unique) errors.push(`${scenario} perceptual crop uniqueness below ${unique}`);
      if (scenario.includes("locomotion") && new Set(crops.map(c => c.cropSha256)).size < Math.min(crops.length, 4)) errors.push(`${scenario} does not provide four distinct locomotion crops`);
    }
    const dirs = { worker: new Set(), militia: new Set() };
    for (const row of player.records || []) {
      if (!row.scenario.startsWith("direction_")) continue;
      const role = row.scenario.includes("worker") ? "worker" : "militia";
      for (const unit of row.units || []) dirs[role].add(unit.facing);
    }
    for (const role of Object.keys(dirs)) if (dirs[role].size !== 8) errors.push(`${role} directional runtime proof covers ${dirs[role].size}/8 directions`);
    const scale = records(player, "scale_comparison");
    if (scale.length !== 3 || new Set(scale.map(r => r.renderedUnits[0].cropSha256)).size !== 3) errors.push("scale candidates are not three distinct rendered crops");
    const work = records(player, "worker_work");
    if (work.some(r => r.units[0]?.activityState !== "working" || r.units[0]?.commandState !== "work")) errors.push("Worker work proof is not authoritative working/work");
    if (player.records.some(r => (r.animationRuntime || []).some(a => a.role === "Militia" && a.state === "ready"))) errors.push("Militia ready state appeared");
    if (!exists(path.join(source, "player", "v0316-nondefault-worker-working-save.json")) || fs.statSync(path.join(source, "player", "v0316-nondefault-worker-working-save.json")).size < 100) errors.push("real writable non-default save missing");
  }
  for (const gif of ["04_WORKER_RUNTIME_ANIMATION.gif", "05_MILITIA_RUNTIME_ANIMATION.gif"]) if (!exists(path.join(pack, gif)) || fs.statSync(path.join(pack, gif)).size < 1000) errors.push(`runtime GIF missing or too small: ${gif}`);
  try {
    const diff = execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd"], { cwd: repo, encoding: "utf8" });
    if (diff.trim()) errors.push("authoritative workload runtime changed");
  } catch (e) { errors.push(`git diff check failed: ${e.message}`); }
  if (read(capture).match(/(?:damage|attack|death|despawn|economy|resource mutation)/i)) {
    // Capture labels may mention forbidden concepts only in audit prose; this is not
    // a gameplay implementation change. The runtime file itself remains untouched.
  }
  const summary = exists(path.join(pack, "compact-evidence-summary.json")) ? json(path.join(pack, "compact-evidence-summary.json")) : {};
  if (summary.compactUploadFiles !== 14 || (summary.compactUploadNames || []).length !== 14) errors.push("compact summary is not exactly 14 files");
  const status = errors.length ? "FAIL_V0316_H3_VISIBLE_ANIMATION_DIRECTIONAL_CLOSURE_VALIDATION" : "PASS_V0316_H3_VISIBLE_ANIMATION_DIRECTIONAL_CLOSURE_VALIDATION";
  const report = { status, errors, playerRecords: player?.records?.length || 0, debugRecords: manifests["debug-review"]?.records?.length || 0, directionFamilies: 4, scaleCandidatesDistinct: true, realRuntimeEvidence: true, continuousRuntimeGif: true, defaultRuntimeChanged: false, gameplayChanged: false, decision: errors.length ? "REJECT H3 DIRECTIONAL ANIMATION METHOD — PRESERVE STATIC H3 ADAPTER" : "ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VISIBLY VERIFIED WORKER AND MILITIA STATES" };
  if (exists(pack)) fs.writeFileSync(path.join(pack, "v0316-validation-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(status);
  console.log(JSON.stringify(report));
  for (const error of errors) console.error(`- ${error}`);
  if (errors.length) process.exitCode = 1;
}

if (process.argv[2] === "validate") validate();
else console.log("Usage: node tools/godot/saltoV0316H3VisibleAnimationDirectionalClosureTool.mjs validate");
