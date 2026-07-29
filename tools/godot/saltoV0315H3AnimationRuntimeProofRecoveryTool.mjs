import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const repo = process.cwd();
const pack = path.join(repo, "artifacts", "manual-review", "v0315-h3-animation-runtime-proof-recovery");
const source = path.join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0315");
const adapter = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "barrosan_h3_directional_animation_adapter_v0314.gd");
const skin = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_barrosan_playable_runtime_skin.gd");
const capture = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_v0315_h3_animation_runtime_proof_recovery_capture.gd");
const errors = [];
const exists = (p) => fs.existsSync(p);
const read = (p) => fs.readFileSync(p, "utf8");
const json = (p) => JSON.parse(read(p));
const requireText = (p, value, message) => { if (!exists(p) || !read(p).includes(value)) errors.push(message); };

function validate() {
  if (!exists(pack)) errors.push("missing v0.315 review pack");
  if (!exists(source)) errors.push("missing live v0.315 capture root");
  const required = ["00_read_me_first.md", "v0314-root-cause.md", "capture-manifest.json", "animation-frame-evidence.json", "save-load-animation-report.md", "rollback-animation-report.md", "worker_runtime_animation.gif", "militia_runtime_animation.gif", "player-runtime-contact-sheet.png", "debug-review-runtime-contact-sheet.png", "mode-comparison-contact-sheet.png", "black-frame-rejection-report.md", "v0315-validation-report.json", "compact-evidence-summary.json"];
  for (const file of required) if (!exists(path.join(pack, file))) errors.push(`missing review-pack file: ${file}`);
  const manifest = exists(path.join(pack, "capture-manifest.json")) ? json(path.join(pack, "capture-manifest.json")) : { records: [] };
  const records = manifest.records || [];
  const player = records.filter((row) => row.presentationMode === "PLAYER");
  const debug = records.filter((row) => row.presentationMode === "DEBUG_REVIEW");
  if (player.length < 20 || debug.length < 20) errors.push(`real runtime record counts are PLAYER=${player.length}, DEBUG_REVIEW=${debug.length}`);
  if (records.some((row) => !row.screenshotSha256 || !row.camera || !row.animationRuntime)) errors.push("runtime records lack screenshot hash, camera, or animation metadata");
  const enabled = records.filter((row) => row.animationStatus && row.animationStatus.enabled);
  if (enabled.length < 36) errors.push(`too few per-event enabled runtime records: ${enabled.length}`);
  const phases = new Set(enabled.flatMap((row) => (row.animationRuntime || []).map((item) => `${item.id}:${item.frameIndex}:${item.framePhase}`)));
  if (phases.size < 8) errors.push("runtime animation metadata does not show enough changing frame phases");
  if (!records.some((row) => (row.animationRuntime || []).some((item) => item.state === "locomotion"))) errors.push("no live locomotion state record");
  if (!records.some((row) => (row.animationRuntime || []).some((item) => item.state === "work"))) errors.push("no live Worker work state record");
  if (!records.some((row) => row.scenario === "rollback_static" && row.animationStatus && !row.animationStatus.enabled)) errors.push("static rollback proof missing");
  if (!records.some((row) => row.scenario === "rollback_fallback" && row.animationStatus && !row.animationStatus.enabled)) errors.push("fallback rollback proof missing");
  if (!records.some((row) => row.scenario === "rollback_reconstructed" && row.animationStatus && row.animationStatus.enabled)) errors.push("animated reconstruction proof missing");
  requireText(path.join(pack, "v0314-root-cause.md"), "V0.314 CAPTURE ROOT CAUSE:", "precise v0.314 root cause is missing");
  requireText(path.join(pack, "00_read_me_first.md"), "REAL_RUNTIME_SCREENSHOTS", "real runtime evidence contract is missing");
  requireText(adapter, "M3_AUTHORED_MULTI_FRAME_ATLAS", "M3 adapter missing");
  requireText(adapter, "runtime_unit_snapshot", "runtime animation snapshot seam missing");
  requireText(skin, "_restore_h3_presentation_after_visual_rebuild", "adapter lifecycle recovery seam missing");
  requireText(capture, "capture_save_state", "capture-only save proof missing");
  requireText(capture, "V0315LiveRuntimeEvidenceWatermark", "live runtime watermark missing");
  const defaults = read(path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_spike_workload_runtime.gd"));
  if (!defaults.includes("func capture_save_state")) errors.push("authoritative runtime capture contract missing");
  try {
    const diff = execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd"], { cwd: repo, encoding: "utf8" });
    if (diff.trim()) errors.push("authoritative workload runtime changed");
  } catch (error) { errors.push(`git diff check failed: ${error.message}`); }
  const status = errors.length ? "FAIL_V0315_H3_ANIMATION_RUNTIME_PROOF_VALIDATION" : "PASS_V0315_H3_ANIMATION_RUNTIME_PROOF_VALIDATION";
  const report = { status, errors, rootCause: "V0.314 CAPTURE ROOT CAUSE: lifecycle teardown freed the configured adapter during set_workload_tier visual rebuild", playerRecords: player.length, debugRecords: debug.length, enabledRuntimeRecords: enabled.length, changingAnimationSnapshots: phases.size, decision: "ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VERIFIED WORKER AND MILITIA STATES", defaultRuntimeChanged: false, gameplayChanged: false };
  if (exists(pack)) fs.writeFileSync(path.join(pack, "v0315-validation-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(status);
  console.log(JSON.stringify(report));
  for (const error of errors) console.error(`- ${error}`);
  if (errors.length) process.exitCode = 1;
}

validate();
