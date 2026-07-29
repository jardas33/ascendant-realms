import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const repo = process.cwd();
const pack = path.join(repo, "artifacts", "manual-review", "v0313-h3-supported-state-contract-closure");
const upload = path.join(pack, "UPLOAD_TO_CHAT");
const v0312 = path.join(repo, "artifacts", "manual-review", "v0312-h3-runtime-evidence-integrity-recovery");
const v0313Runtime = path.join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0313");
const requiredPack = [
  "00_read_me_first.md", "v0311-corrected-status.md", "v0312-evidence-recovery-status.md",
  "militia-command-contract.md", "militia-state-contract.md", "worker-supported-state-matrix.md",
  "militia-supported-state-matrix.md", "hold-command-audit.md", "evidence-count-reconciliation.md",
  "physical-file-register.json", "unique-image-register.json", "perceptual-image-register.json",
  "player-debug-pair-register.json", "semantic-record-register.json", "semantic-event-register.json",
  "accepted-duplicate-register.md", "rejected-evidence-register.md", "scale-lock-report.md",
  "runtime-method-assessment.md", "visual-art-assessment.md", "final-decision.md", "capture-manifest.json",
  "hold-command-audit.json", "evidence-count-summary.json"
];
const compactRequired = [
  "00_READ_ME_FIRST.md", "01_EXECUTIVE_DECISION.png", "02_STATE_CONTRACT_MATRIX.png",
  "03_MILITIA_HOLD_AUDIT.png", "04_WORKER_SUPPORTED_STATES.png", "05_MILITIA_SUPPORTED_STATES.png",
  "06_SAVE_ROLLBACK_PROOF.png", "07_SCALE_COMPARISON.png", "08_CLEAN_GAMEPLAY_OVERVIEW.png",
  "09_REMAINING_VISUAL_LIMITATIONS.png", "evidence-count-summary.json", "supported-state-contract.json",
  "compact-capture-manifest.json", "final-decision.md"
];

const exists = (p) => fs.existsSync(p);
const readJson = (p) => JSON.parse(fs.readFileSync(p, "utf8"));
const errors = [];
const requireFile = (name) => { if (!exists(path.join(pack, name))) errors.push(`missing pack file: ${name}`); };
const requireText = (p, token) => { if (!exists(p) || !fs.readFileSync(p, "utf8").includes(token)) errors.push(`missing text ${token} in ${p}`); };

function validateV0312Accounting() {
  const rows = readJson(path.join(v0312, "semantic-capture-register.json"));
  const perceptual = readJson(path.join(v0312, "perceptual-hash-register.json"));
  const groups = new Map();
  for (const row of rows) {
    if (!groups.has(row.pairedMomentId)) groups.set(row.pairedMomentId, []);
    groups.get(row.pairedMomentId).push(row);
  }
  const accepted = rows.filter((row) => row.semanticAccepted !== false);
  const acceptedGroups = [...groups.values()].filter((group) => group.every((row) => row.semanticAccepted !== false));
  const infoGroups = acceptedGroups.filter((group) => ["preflight", "clean_gameplay"].includes(group[0].scenarioName));
  const allHashes = new Set(rows.map((row) => row.screenshotSha256));
  if (rows.length !== 154) errors.push(`v0.312 physical count mismatch: ${rows.length}`);
  if (rows.filter((row) => row.presentationMode === "PLAYER").length !== 77) errors.push("v0.312 PLAYER count mismatch");
  if (rows.filter((row) => row.presentationMode === "DEBUG_REVIEW").length !== 77) errors.push("v0.312 DEBUG_REVIEW count mismatch");
  if (groups.size !== 77) errors.push(`v0.312 paired moment mismatch: ${groups.size}`);
  if (allHashes.size !== 127) errors.push(`v0.312 SHA count mismatch: ${allHashes.size}`);
  if (new Set(perceptual.map((row) => row.perceptualHash)).size !== 48) errors.push("v0.312 perceptual count mismatch");
  if (accepted.length !== 128) errors.push(`v0.312 accepted record mismatch: ${accepted.length}`);
  if (acceptedGroups.length - infoGroups.length !== 62) errors.push("v0.312 gameplay event mismatch");
  if (rows.filter((row) => row.semanticAccepted === false).length !== 26) errors.push("v0.312 rejected exact duplicate mismatch");
  if (infoGroups.length !== 2 || infoGroups.reduce((count, group) => count + group.length, 0) !== 4) errors.push("v0.312 informational count mismatch");
  const acceptedHashGroups = new Map();
  for (const row of accepted) {
    if (!acceptedHashGroups.has(row.screenshotSha256)) acceptedHashGroups.set(row.screenshotSha256, []);
    acceptedHashGroups.get(row.screenshotSha256).push(row);
  }
  const acceptedDuplicates = [...acceptedHashGroups.values()].filter((group) => group.length > 1);
  if (acceptedDuplicates.length !== 1 || acceptedDuplicates[0].length !== 2 || new Set(acceptedDuplicates[0].map((row) => row.pairedMomentId)).size !== 2 || !acceptedDuplicates[0].some((row) => row.pairedMomentId === "scale_comparison_74") || !acceptedDuplicates[0].some((row) => row.pairedMomentId === "clean_gameplay_77")) errors.push("accepted duplicate classification mismatch");
  return { rows, groups, accepted, acceptedGroups, infoGroups };
}

function validateFocusedCapture() {
  const manifests = ["player", "debug-review"].map((id) => readJson(path.join(v0313Runtime, id, "semantic-capture-manifest.json")));
  if (manifests.some((manifest) => manifest.status !== "PASS_V0313_SUPPORTED_STATE_CAPTURE")) errors.push("focused capture manifest is not passing");
  const rows = manifests.flatMap((manifest) => manifest.records);
  if (rows.length !== 34) errors.push(`focused physical record mismatch: ${rows.length}`);
  const groups = new Map();
  for (const row of rows) {
    if (!groups.has(row.pairedViewId)) groups.set(row.pairedViewId, []);
    groups.get(row.pairedViewId).push(row);
    const sidecar = path.join(pack, `${row.captureFilename.replace(/\.png$/i, ".json")}`);
    const image = path.join(pack, row.captureFilename);
    if (!exists(sidecar) || !exists(image)) errors.push(`missing focused evidence for ${row.captureFilename}`);
    if (row.accepted !== true || row.rejected !== false) errors.push(`focused record not accepted: ${row.captureFilename}`);
    for (const key of ["semanticEventId", "pairedViewId", "runtimeTimestampMs", "frameNumber", "scenario", "stableUnitIds", "units", "selectedIds", "cameraCoordinates", "cameraZoom", "h3Flag", "fallbackFlag", "screenshotSha256", "perceptualHash"]) if (!(key in row)) errors.push(`focused sidecar missing ${key}`);
  }
  if (groups.size !== 17) errors.push(`focused paired moment mismatch: ${groups.size}`);
  for (const [id, group] of groups) if (group.length !== 2 || new Set(group.map((row) => row.presentationMode)).size !== 2) errors.push(`focused pair incomplete: ${id}`);
  const hashOwners = new Map();
  for (const row of rows) {
    if (!hashOwners.has(row.screenshotSha256)) hashOwners.set(row.screenshotSha256, new Set());
    hashOwners.get(row.screenshotSha256).add(row.pairedViewId);
  }
  for (const [hash, owners] of hashOwners) if (owners.size > 1) errors.push(`two focused semantic events rely on screenshot ${hash}`);
  return { manifests, rows, groups };
}

function validate() {
  for (const file of requiredPack) requireFile(file);
  for (const file of compactRequired) if (!exists(path.join(upload, file))) errors.push(`missing compact upload file: ${file}`);
  if (exists(upload) && fs.readdirSync(upload).length > 15) errors.push(`compact upload has ${fs.readdirSync(upload).length} files`);
  requireText(path.join(pack, "v0311-corrected-status.md"), "EVIDENCE INVALID");
  requireText(path.join(pack, "v0312-evidence-recovery-status.md"), "Distinct runtime evidence");
  requireText(path.join(pack, "militia-state-contract.md"), "MILITIA READY VISUAL STATE: NOT APPLICABLE");
  if (!exists(path.join(pack, "scale-lock-report.md")) || !/H3 PRESENTATION SCALE LOCK:\s*CURRENT/.test(fs.readFileSync(path.join(pack, "scale-lock-report.md"), "utf8"))) errors.push("scale lock is not CURRENT");
  requireText(path.join(pack, "final-decision.md"), "ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES");
  const hold = readJson(path.join(pack, "hold-command-audit.json"));
  if (hold.uiCommandPresent !== true || hold.uiCallbackReached !== true || hold.authoritativeRuntimeMethod !== "issue_move_order") errors.push("Hold command path audit incomplete");
  if (hold.distinctReadyStateExists !== false || hold.adapterDefect !== false || hold.classification !== "not applicable") errors.push("Hold classification is incorrect");
  const accounting = validateV0312Accounting();
  const focused = validateFocusedCapture();
  const reportPath = path.join(repo, "docs", "V0313_H3_SUPPORTED_STATE_CONTRACT_CLOSURE_REPORT.md");
  requireText(reportPath, "ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES");
  requireText(reportPath, "62");
  requireText(reportPath, "H3 PRESENTATION SCALE LOCK: CURRENT");
  const report = fs.readFileSync(reportPath, "utf8");
  if (report.includes("REMAINS UNPROVEN DUE TO ADAPTER DEFECT")) errors.push("report contains forbidden adapter-defect decision");
  const workloadDiff = execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd"], { cwd: repo, encoding: "utf8" });
  if (workloadDiff.trim()) errors.push("gameplay workload runtime changed");
  const v0312Diff = execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_v0312_h3_semantic_evidence_capture.gd", "tools/godot/saltoV0312H3RuntimeEvidenceIntegrityTool.mjs"], { cwd: repo, encoding: "utf8" });
  if (v0312Diff.trim()) errors.push("v0.312 implementation changed");
  const status = errors.length ? "FAIL_V0313_H3_SUPPORTED_STATE_CONTRACT_VALIDATION" : "PASS_V0313_H3_SUPPORTED_STATE_CONTRACT_VALIDATION";
  const out = {
    status,
    errors,
    v0312: { physical: accounting.rows.length, player: accounting.rows.filter((row) => row.presentationMode === "PLAYER").length, debug: accounting.rows.filter((row) => row.presentationMode === "DEBUG_REVIEW").length, paired: accounting.groups.size, uniqueSha256: new Set(accounting.rows.map((row) => row.screenshotSha256)).size, acceptedRecords: accounting.accepted.length, acceptedGameplayEvents: accounting.acceptedGroups.length - accounting.infoGroups.length, rejectedExactDuplicates: accounting.rows.filter((row) => row.semanticAccepted === false).length, perceptuallyUnique: 48 },
    focusedV0313: { physical: focused.rows.length, paired: focused.groups.size, semanticEvents: focused.groups.size, compactUploadFiles: exists(upload) ? fs.readdirSync(upload).length : 0 },
    holdClassification: "not applicable",
    finalDecision: "ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES",
    scaleLock: "CURRENT"
  };
  fs.writeFileSync(path.join(pack, "v0313-validation-report.json"), JSON.stringify(out, null, 2) + "\n");
  console.log(status);
  console.log(JSON.stringify(out));
  if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode = 1; }
}

if (process.argv[2] === "validate") validate();
else validate();
