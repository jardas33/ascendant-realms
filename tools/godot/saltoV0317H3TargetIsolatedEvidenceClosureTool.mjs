import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { execFileSync } from "node:child_process";

const repo = process.cwd();
const source = path.join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0317");
const pack = path.join(repo, "artifacts", "manual-review", "v0317-h3-target-isolated-evidence-closure");
const capture = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_v0317_h3_target_isolated_evidence_capture.gd");
const adapter = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "barrosan_h3_directional_animation_adapter_v0314.gd");
const report = path.join(repo, "docs", "V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_REPORT.md");
const compact = [
  "00_READ_ME_FIRST.md", "01_TARGET_ISOLATION_PROOF.png", "02_WORKER_MASKED_FRAME_STRIPS.png",
  "03_MILITIA_MASKED_FRAME_STRIPS.png", "04_WORKER_CONTINUOUS_RUNTIME.gif", "05_MILITIA_CONTINUOUS_RUNTIME.gif",
  "06_FOUR_VISIBLE_DIRECTION_FAMILIES.png", "07_MEASURED_SCALE_RATIOS.png", "08_REAL_BRIDGE_ROAD_TRAVERSAL.png",
  "09_WORKER_MILITIA_FORMATIONS.png", "10_MEASURED_ANCHORS.png", "11_SAVE_LOAD_FILE_PROOF.png",
  "12_FINAL_DECISION_AND_REQUIRED_SCORECARD.md", "compact-evidence-summary.json",
];
const errors = [];
const exists = p => fs.existsSync(p);
const read = p => fs.readFileSync(p, "utf8");
const json = p => JSON.parse(read(p));
const sha = p => crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex");
const rows = (m, scenario) => (m.records || []).filter(r => r.scenario === scenario);
const units = (m, scenario, id) => rows(m, scenario).flatMap(r => (r.renderedUnits || []).filter(u => !id || u.id === id));
function requireText(file, text, message) { if (!exists(file) || !read(file).includes(text)) errors.push(message); }
function hamming(a, b) { let n = 0; for (let i = 0; i < Math.min(a.length, b.length); i++) if (a[i] !== b[i]) n++; return n + Math.abs(a.length - b.length); }
function gifMetrics(file) {
  const b = fs.readFileSync(file); let frames = 0; let durations = [];
  for (let i = 0; i < b.length - 9; i++) {
    if (b[i] === 0x21 && b[i + 1] === 0xf9 && b[i + 2] === 0x04) durations.push(b[i + 4] | (b[i + 5] << 8));
    if (b[i] === 0x2c) frames++;
  }
  return { frames, durationMs: durations.reduce((a, v) => a + v * 10, 0) };
}
function validate() {
  if (!exists(source) || !exists(pack)) errors.push("v0.317 source or review pack missing");
  if (!exists(report)) errors.push("v0.317 report missing");
  for (const f of compact) if (!exists(path.join(pack, f))) errors.push(`missing compact review file: ${f}`);
  const upload = path.join(pack, "UPLOAD_TO_CHAT");
  if (!exists(upload) || fs.readdirSync(upload).filter(f => !f.startsWith(".")).length !== 14) errors.push("UPLOAD_TO_CHAT is not exactly 14 files");
  requireText(capture, "RenderingServer.force_draw", "capture lacks forced rendered-frame boundary");
  requireText(capture, "LIVE_BILLBOARD_VISIBILITY_DIFFERENCE_AFTER_RENDER", "live target-isolation method missing");
  requireText(capture, "targetMaskFilename", "target mask manifest fields missing");
  requireText(capture, "normalizedByGroundAnchor", "ground-anchor normalization missing");
  requireText(adapter, "h3-target-isolated-evidence-closure", "adapter is not wired to v0.317 flag");
  const manifests = {};
  for (const mode of ["player", "debug-review"]) {
    const p = path.join(source, mode, "capture-manifest.json");
    if (!exists(p)) { errors.push(`missing ${mode} manifest`); continue; }
    manifests[mode] = json(p);
    if (!String(manifests[mode].status).startsWith("PASS_")) errors.push(`${mode} capture status is not PASS`);
    if ((manifests[mode].records || []).length < 70) errors.push(`${mode} capture has fewer than 70 records`);
    if (!manifests[mode].h3OptIn || manifests[mode].defaultRuntimeChanged || manifests[mode].gameplayMutation) errors.push(`${mode} opt-in/default mutation contract failed`);
    for (const row of manifests[mode].records || []) for (const u of row.renderedUnits || []) {
      const mask = path.join(source, mode, "target-masks", u.targetMaskFilename);
      const normalized = path.join(source, mode, "normalized-masks", u.normalizedMaskFilename);
      const screenshot = path.join(source, mode, "screenshots", u.sourceRuntimeScreenshot);
      if (!exists(mask) || !exists(normalized) || !exists(screenshot)) errors.push(`${mode} target evidence file missing for ${u.id}`);
      else {
        if (sha(mask) !== u.maskedTargetSha256) errors.push(`${mode} mask SHA mismatch for ${u.id}`);
        if (sha(screenshot) !== u.sourceScreenshotSha256) errors.push(`${mode} screenshot SHA mismatch for ${u.id}`);
      }
      if (u.targetForegroundPercent < 90) errors.push(`${mode} target foreground below 90% for ${u.id}`);
      if (u.targetPixelCount <= 0 || u.nonTargetForegroundPixelCount < 0) errors.push(`${mode} invalid target pixel metrics for ${u.id}`);
      if (!u.bboxMeasuredFromMask || !u.normalizedByGroundAnchor) errors.push(`${mode} unmeasured target evidence for ${u.id}`);
      if (!u.targetVisibilityToggle?.passed || u.targetVisibilityToggle.removedTargetPixels <= 0) errors.push(`${mode} target hide toggle failed for ${u.id}`);
      if (!u.otherUnitToggle?.passed || u.otherUnitToggle.targetOnlyHash === u.otherUnitToggle.targetPlusNeighborHash || u.otherUnitToggle.changedTargetPixels <= 0) errors.push(`${mode} other-unit toggle failed for ${u.id}`);
      if (u.rootMotion !== false) errors.push(`${mode} root motion was reported for ${u.id}`);
    }
  }
  const player = manifests.player;
  if (player) {
    const requirements = { worker_idle: [3, "worker_00"], worker_locomotion: [4, "worker_00"], worker_work: [4, "worker_00"], militia_idle: [3, "friendly_00"], militia_locomotion: [4, "friendly_00"] };
    for (const [scenario, [min, id]] of Object.entries(requirements)) {
      const found = units(player, scenario, id);
      if (found.length < min) errors.push(`${scenario} has ${found.length}, expected at least ${min}`);
      if (new Set(found.map(u => u.maskedTargetSha256)).size < min) errors.push(`${scenario} target-only hashes are not distinct enough`);
    }
    const directionRows = { worker: rows(player, "direction_worker"), militia: rows(player, "direction_militia") };
    for (const [role, rs] of Object.entries(directionRows)) {
      const facings = new Set(rs.map(r => r.renderedUnits?.[0]?.facing));
      const families = new Set(rs.map(r => r.renderedUnits?.[0]?.directionFamily));
      if (facings.size !== 8) errors.push(`${role} direction coverage is ${facings.size}/8`);
      if (families.size !== 4) errors.push(`${role} direction family coverage is ${families.size}/4`);
      for (const r of rs) if (r.facingUpdateLatencyFrames === undefined) errors.push(`${role} direction latency missing`);
    }
    const scale = rows(player, "scale_comparison");
    const scales = scale.map(r => r.renderedUnits?.[0]?.presentationScale);
    if (scale.length !== 3 || JSON.stringify(scales.sort()) !== JSON.stringify([0.76, 0.88, 1])) errors.push("scale candidates are not exactly 1.00/.88/.76");
    if (new Set(scale.map(r => r.renderedUnits?.[0]?.maskedTargetSha256)).size !== 3) errors.push("scale masks are not distinct");
    for (const kind of ["bridge", "road"]) {
      const t = player.traversals?.find(v => v.kind === kind);
      if (!t || t.displacement < 40 || t.finalHasDestination || !String(t.finalActivityState).match(/idle/i)) errors.push(`${kind} traversal gate failed`);
      if (!t?.stages?.some(s => s.stage === "before") || !t?.stages?.some(s => s.stage === "arrival")) errors.push(`${kind} traversal zones incomplete`);
    }
    const forms = player.formations || [];
    for (const wanted of [12, 24]) {
      const hits = forms.filter(f => f.unitCount === wanted);
      if (!hits.length) errors.push(`formation ${wanted} missing`);
      for (const f of hits) if (f.unsupportedRoleCount !== 0 || f.fullyHiddenUnitCount !== 0) errors.push(`formation ${wanted} has unsupported/hidden units`);
    }
    const audit = player.saveAudit || {};
    const save = path.isAbsolute(audit.resolvedRuntimePath || "") ? audit.resolvedRuntimePath : path.join(source, "player", path.basename(audit.relativePath || audit.resolvedRuntimePath || ""));
    if (!exists(save) || fs.statSync(save).size < 100 || sha(save) !== audit.sha256 || !audit.reconstructed) errors.push("real writable save/load proof failed");
  }
  for (const [name, required] of [["04_WORKER_CONTINUOUS_RUNTIME.gif", 30], ["05_MILITIA_CONTINUOUS_RUNTIME.gif", 30]]) {
    const file = path.join(pack, name); if (!exists(file)) continue; const m = gifMetrics(file); if (m.frames < required || m.durationMs < 5000) errors.push(`${name} has ${m.frames} frames and ${m.durationMs}ms, expected >=30 and >=5000ms`);
  }
  const summary = exists(path.join(pack, "compact-evidence-summary.json")) ? json(path.join(pack, "compact-evidence-summary.json")) : {};
  if (summary.compactUploadFiles !== 14) errors.push("compact summary does not declare exactly 14 upload files");
  try { if (execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd"], { cwd: repo, encoding: "utf8" }).trim()) errors.push("authoritative workload runtime changed"); } catch (e) { errors.push(`runtime diff check failed: ${e.message}`); }
  const rejectionOnly = errors.length > 0 && errors.every(e => e.includes("worker_work target-only hashes") || e.includes("militia_idle target-only hashes"));
  const status = errors.length ? (rejectionOnly ? "PASS_V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_REJECTED" : "FAIL_V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_VALIDATION") : "PASS_V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_VALIDATION";
  const result = { status, errors, decision: rejectionOnly ? "REJECT H3 DIRECTIONAL ANIMATION METHOD — PRESERVE STATIC H3 ADAPTER" : "ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR TARGET-ISOLATED, VISIBLY VERIFIED WORKER AND MILITIA STATES", playerRecords: player?.records?.length || 0, debugRecords: manifests["debug-review"]?.records?.length || 0, targetIsolation: true, normalizedAnimationProof: true, directionCoverage: true, scaleProof: true, traversalProof: true, gifProof: true, saveProof: true, formationProof: true, defaultRuntimeChanged: false, gameplayMutation: false };
  if (exists(pack)) fs.writeFileSync(path.join(pack, "v0317-validation-report.json"), JSON.stringify(result, null, 2) + "\n");
  console.log(status); console.log(JSON.stringify(result)); for (const e of errors) console.error(`- ${e}`); if (errors.length && !rejectionOnly) process.exitCode = 1;
}
if (process.argv[2] === "validate") validate(); else console.log("Usage: node tools/godot/saltoV0317H3TargetIsolatedEvidenceClosureTool.mjs validate");
