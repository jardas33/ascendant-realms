import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const repo = process.cwd();
const pack = path.join(repo, "artifacts", "manual-review", "v0314-h3-directional-animation-micro-pilot");
const upload = path.join(pack, "UPLOAD_TO_CHAT");
const adapter = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "barrosan_h3_directional_animation_adapter_v0314.gd");
const skin = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_barrosan_playable_runtime_skin.gd");
const root = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd");
const errors = [];
const exists = (p) => fs.existsSync(p);
const read = (p) => fs.readFileSync(p, "utf8");
const json = (p) => JSON.parse(read(p));
const required = [
  "00_read_me_first.md", "v0313-preserved-decision.md", "hold-ui-contract-audit.md", "command-capability-matrix.json",
  "scale-lock-report.md", "animation-method-bakeoff.md", "asset-lineage.md", "worker-animation-contract.json",
  "militia-animation-contract.json", "directional-contract.json", "atlas-register.json", "frame-register.json",
  "runtime-event-register.json", "rejected-frame-register.md", "duplicate-frame-audit.md", "anchor-drift-report.md",
  "save-load-animation-report.md", "rollback-animation-report.md", "visual-scorecard.md", "runtime-method-assessment.md",
  "art-quality-assessment.md", "final-decision.md", "capture-manifest.json", "compact-evidence-summary.json",
  "worker_runtime_animation.gif", "militia_runtime_animation.gif", "worker_animation_frame_strip.png", "militia_animation_frame_strip.png",
];

function validate() {
  for (const file of required) if (!exists(path.join(pack, file))) errors.push(`missing review-pack file: ${file}`);
  if (!exists(upload)) errors.push("missing compact upload directory");
  else if (fs.readdirSync(upload).length !== 14) errors.push(`compact upload count is ${fs.readdirSync(upload).length}, expected 14`);
  const manifest = exists(path.join(pack, "capture-manifest.json")) ? json(path.join(pack, "capture-manifest.json")) : { records: [] };
  const frames = exists(path.join(pack, "frame-register.json")) ? json(path.join(pack, "frame-register.json")) : [];
  const summary = exists(path.join(pack, "compact-evidence-summary.json")) ? json(path.join(pack, "compact-evidence-summary.json")) : {};
  const directions = ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"];
  const adapterText = exists(adapter) ? read(adapter) : "";
  const skinText = exists(skin) ? read(skin) : "";
  const rootText = exists(root) ? read(root) : "";
  if (!read(path.join(pack, "v0313-preserved-decision.md")).includes("ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES")) errors.push("v0.313 accepted decision not preserved");
  if (!read(path.join(pack, "00_read_me_first.md")).includes("HOLD UI CONTRACT: HIDDEN_WHEN_UNSUPPORTED")) errors.push("Hold contract not recorded as hidden");
  if (!read(path.join(pack, "00_read_me_first.md")).includes("H3 PRESENTATION SCALE LOCK: CURRENT")) errors.push("scale lock is not CURRENT");
  if (!read(path.join(pack, "final-decision.md")).includes("EVIDENCE INVALID — H3 DIRECTIONAL ANIMATION PIPELINE REMAINS UNPROVEN")) errors.push("v0.314 historical classification is not honest invalid/unproven decision");
  if (!adapterText.includes("M3_AUTHORED_MULTI_FRAME_ATLAS") || !adapterText.includes('"Worker"') || !adapterText.includes('"Militia"')) errors.push("adapter is not a Worker/Militia M3 adapter");
  if (!adapterText.includes("rootMotion") || !adapterText.includes("gameplayProxy")) errors.push("root-motion boundary missing");
  if (!skinText.includes("barrosan_h3_directional_animation_requested") || !skinText.includes("set_v0314_h3_directional_animation_enabled")) errors.push("opt-in skin seam missing");
  if (!rootText.includes("HIDDEN_WHEN_UNSUPPORTED") || !rootText.includes("--h3-directional-animation-micro-pilot")) errors.push("truthful Hold opt-in boundary missing");
  if (!rootText.includes("data[\"holdUiContract\"] = \"HIDDEN_WHEN_UNSUPPORTED\"")) errors.push("v0.314 Hold capability filter missing");
  if (manifest.records.length !== 48) errors.push(`runtime event count is ${manifest.records.length}, expected 48`);
  const acceptedRecords = manifest.records.filter((row) => row.accepted !== false);
  if (new Set(acceptedRecords.map((row) => row.screenshotSha256)).size !== acceptedRecords.length) errors.push("accepted runtime records rely on duplicate screenshots");
  if (new Set(manifest.records.map((row) => row.mode)).size !== 2) errors.push("both PLAYER and DEBUG_REVIEW runtime captures are missing");
  if (frames.length !== 104) errors.push(`animation frame count is ${frames.length}, expected 104`);
  if (frames.filter((row) => row.role === "worker" && row.transparent).length < 64) errors.push("Worker atlas transparency audit incomplete");
  if (frames.filter((row) => row.role === "militia" && row.transparent).length < 40) errors.push("Militia atlas transparency audit incomplete");
  if (summary.compactUploadFiles && summary.compactUploadFiles > 14) errors.push("compact summary exceeds 14 files");
  if (!directions.every((direction) => read(path.join(pack, "directional-contract.json")).includes(direction))) errors.push("directional contract is incomplete");
  const worker = json(path.join(pack, "worker-animation-contract.json"));
  const militia = json(path.join(pack, "militia-animation-contract.json"));
  if (worker.states.idle !== 4 || worker.states.locomotion !== 6 || worker.states.work !== 6) errors.push("Worker frame targets incorrect");
  if (militia.states.idle !== 4 || militia.states.locomotion !== 6 || militia.states.ready !== 0) errors.push("Militia state contract incorrect");
  try {
    const workloadDiff = execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd"], { cwd: repo, encoding: "utf8" });
    if (workloadDiff.trim()) errors.push("authoritative workload runtime changed");
  } catch (error) { errors.push(`git diff check failed: ${error.message}`); }
  const status = errors.length ? "FAIL_V0314_H3_DIRECTIONAL_ANIMATION_VALIDATION" : "PASS_V0314_H3_DIRECTIONAL_ANIMATION_VALIDATION";
  const report = { status, errors, historicalClassification: "EVIDENCE INVALID — H3 DIRECTIONAL ANIMATION PIPELINE REMAINS UNPROVEN", v0313Decision: "ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES", holdUiContract: "HIDDEN_WHEN_UNSUPPORTED", scaleLock: "CURRENT", runtimeSemanticEvents: manifest.records.length, physicalAnimationFrames: frames.length, compactUploadFiles: exists(upload) ? fs.readdirSync(upload).length : 0, finalDecision: "EVIDENCE INVALID — H3 DIRECTIONAL ANIMATION PIPELINE REMAINS UNPROVEN" };
  fs.writeFileSync(path.join(pack, "v0314-validation-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(status);
  console.log(JSON.stringify(report));
  for (const error of errors) console.error(`- ${error}`);
  if (errors.length) process.exitCode = 1;
}

validate();
