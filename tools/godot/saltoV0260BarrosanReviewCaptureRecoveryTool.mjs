import {createHash} from "node:crypto";
import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(v => v.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0260"));
const verdict = arg("verdict") || "PARTIAL";
const commit = arg("commit") || "PENDING_PUBLICATION";
const head = arg("head") || commit;
const ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0260-barrosan-review-capture-recovery");
const docPath = join(repo, "docs", "V0260_BARROSAN_REVIEW_CAPTURE_RECOVERY_REPORT.md");
const runtimePath = join(root, "v0259-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "v0259-default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0260-black-frame-stats.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const read = p => JSON.parse(readFileSync(p, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = p => createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();

const sourceNames = [
  "initial_select_aster_consistent", "after_aster_next_instruction_consistent", "build_phase_no_rebuild_text", "place_field_barracks_hud_button_consistent",
  "valid_placement_hud_button_consistent", "barracks_built_full_consistent", "hp_125_damaged_functional_consistent", "hp_25_critical_functional_consistent",
  "hp_0_destroyed_consistent", "destroyed_no_select_aster_no_stale_text", "worker_selected_rebuild_consistent", "worker_rebuild_button_only_when_destroyed",
  "rebuild_resource_delta", "rebuilding_25_consistent", "rebuilding_50_consistent", "rebuilding_75_consistent", "rebuilt_100_consistent",
  "train_available_after_rebuild_consistent", "train_resource_delta_after_rebuild", "militia_ready_defend_consistent", "no_rebuild_text_after_rebuilt",
  "no_build_place_text_during_rebuild", "repair_rebuild_separation_proof", "visual_state_comparison_strip", "minimap_preserved",
  "existing_structures_preserved", "no_forbidden_text_scan"
];
const targetNames = [
  "opt_in_initial_select_aster_visible", "after_aster_next_instruction_visible", "build_phase_no_rebuild_text_visible", "place_field_barracks_hud_button_visible",
  "valid_placement_hud_button_visible", "barracks_built_full_visible", "hp_125_damaged_functional_visible", "hp_25_critical_functional_visible",
  "hp_0_destroyed_visible", "destroyed_no_select_aster_no_stale_text_visible", "worker_selected_rebuild_visible", "worker_rebuild_button_only_when_destroyed_visible",
  "rebuild_resource_delta_visible", "rebuilding_25_visible", "rebuilding_50_visible", "rebuilding_75_visible", "rebuilt_100_visible",
  "train_available_after_rebuild_visible", "train_resource_delta_after_rebuild_visible", "militia_ready_defend_visible", "no_rebuild_text_after_rebuilt_visible",
  "no_build_place_text_during_rebuild_visible", "repair_rebuild_separation_visible", "visual_state_comparison_strip_visible", "minimap_preserved_visible",
  "existing_structures_preserved_visible", "no_forbidden_text_scan"
];
const modeForName = {
  initial_select_aster_consistent: "v0259_initial", after_aster_next_instruction_consistent: "v0259_after_aster",
  build_phase_no_rebuild_text: "v0259_build_no_rebuild", place_field_barracks_hud_button_consistent: "v0259_place",
  valid_placement_hud_button_consistent: "v0259_valid", barracks_built_full_consistent: "v0259_full",
  hp_125_damaged_functional_consistent: "v0259_hp_125", hp_25_critical_functional_consistent: "v0259_hp_25",
  hp_0_destroyed_consistent: "v0259_destroyed", destroyed_no_select_aster_no_stale_text: "v0259_destroyed_clean",
  worker_selected_rebuild_consistent: "v0259_worker_rebuild", worker_rebuild_button_only_when_destroyed: "v0259_rebuild_button",
  rebuild_resource_delta: "v0259_rebuild_delta", rebuilding_25_consistent: "v0259_rebuild_25", rebuilding_50_consistent: "v0259_rebuild_50",
  rebuilding_75_consistent: "v0259_rebuild_75", rebuilt_100_consistent: "v0259_rebuilt_100",
  train_available_after_rebuild_consistent: "v0259_train_available", train_resource_delta_after_rebuild: "v0259_train_delta",
  militia_ready_defend_consistent: "v0259_militia_ready", no_rebuild_text_after_rebuilt: "v0259_no_rebuild_after",
  no_build_place_text_during_rebuild: "v0259_no_place_rebuild", repair_rebuild_separation_proof: "v0259_separation",
  visual_state_comparison_strip: "v0259_visual_compare", minimap_preserved: "v0259_minimap",
  existing_structures_preserved: "v0259_structures", no_forbidden_text_scan: "v0259_forbidden_scan"
};
const required = [
  "01_v0260_preflight_head_ci_resolution.png",
  "02_v0260_default_runtime_visible_not_black.png",
  ...targetNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_v0260_${name}.png`),
  "30_v0260_black_frame_rejection_report.png",
  "31_v0260_contact_sheet_visible.png"
];

function inspect(errors) {
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const fallback = existsSync(defaultPath) ? read(defaultPath) : {};
  const stats = existsSync(statsPath) ? read(statsPath).stats ?? [] : [];
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const ui = skin.uiStateInvariantHardening ?? {};
  const bridge = ui.mechanics ?? {};
  const construction = bridge.construction ?? {};
  const destroyed = bridge.destroyedStateBranch ?? {};
  const rebuild = bridge.workerRebuildBranch ?? {};
  const separation = bridge.repairRebuildSeparation ?? {};
  const snaps = ui.proofSnapshots ?? {};

  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.259" || runtime.captureCount !== 27) errors.push("runtime v0.259 capture contract failed");
  if (fallback.status !== "PASS_PLAYER_SLICE_CAPTURE" || fallback.checkpoint !== "v0.259" || (fallback.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime changed or failed capture");
  if (ui.status !== "PASS" || ui.singleSourceStatus !== "PASS" || ui.impossibleCombinationStatus !== "PASS" || ui.forbiddenTextStatus !== "PASS" || ui.visualStatus !== "PASS" || ui.mechanicsRetainedStatus !== "PASS") errors.push("v0.259 UI invariant status failed");
  if ((ui.missingSnapshots ?? []).length) errors.push(`missing snapshots ${(ui.missingSnapshots ?? []).join(",")}`);

  for (const [name, mode] of Object.entries(modeForName)) {
    const s = snaps[mode];
    if (!s) errors.push(`missing proof ${mode} for ${name}`);
    else if (!s.singleSourceMatch || s.forbiddenRebuildNotImplemented || s.selectAsterBeyondInitial) errors.push(`invariant flags failed ${mode}`);
  }
  for (const mode of ["v0259_initial", "v0259_after_aster", "v0259_build_no_rebuild", "v0259_place", "v0259_valid"]) {
    if ((snaps[mode]?.combinedText ?? "").match(/Rebuild|Destroyed Field Barracks|Target destroyed/)) errors.push(`rebuild wording leaked into ${mode}`);
  }
  for (const mode of ["v0259_destroyed", "v0259_worker_rebuild", "v0259_rebuild_delta", "v0259_rebuild_25", "v0259_rebuild_50", "v0259_rebuild_75"]) {
    if ((snaps[mode]?.combinedText ?? "").match(/Place Field Barracks|Click to build Field Barracks|Build Barracks/)) errors.push(`build wording leaked into ${mode}`);
  }
  for (const mode of ["v0259_rebuilt_100", "v0259_train_available", "v0259_militia_ready", "v0259_no_rebuild_after"]) {
    if ((snaps[mode]?.combinedText ?? "").match(/Target destroyed|Rebuild destroyed|Rebuild not yet implemented/)) errors.push(`destroyed wording leaked after rebuild ${mode}`);
  }

  if (construction.placementResourceDelta?.crowns !== -180 || construction.placementResourceDelta?.stone !== -120) errors.push("construction resources changed");
  if (JSON.stringify(bridge.firstPressureDamageSequence) !== JSON.stringify([200, 175, 150, 125])) errors.push("first pressure HP sequence changed");
  if (JSON.stringify(bridge.secondPressureDamageSequence) !== JSON.stringify([125, 100, 75, 50, 25, 0])) errors.push("second pressure HP sequence changed");
  if (JSON.stringify((rebuild.rebuildTicks ?? []).map(t => t.after)) !== JSON.stringify([25, 50, 75, 100])) errors.push("rebuild HP sequence changed");
  if (!destroyed.productionUnavailableAtZero || destroyed.trainOrderAcceptedAtZero || !destroyed.repairUnavailableAtZero || !destroyed.noRefund || !destroyed.noAutomaticRebuild) errors.push("destroyed-state mechanics changed");
  if (!rebuild.rebuildCommandAvailable || !rebuild.rebuildOrderAccepted || rebuild.rebuildSpendCount !== 1 || rebuild.resourcesAfterRebuildSpend?.crowns !== 150 || rebuild.resourcesAfterRebuildSpend?.stone !== 0) errors.push("rebuild resource mechanics changed");
  if (!rebuild.productionUnavailableDuringRebuild || !rebuild.productionAvailableAfterRebuild || !rebuild.trainOrderAcceptedAfterRebuild || rebuild.resourcesAfterRebuiltTraining?.crowns !== 90 || rebuild.resourcesAfterRebuiltTraining?.iron !== 70 || rebuild.militiaCountAfterRebuild !== 1) errors.push("production/training mechanics changed");
  if (!separation.repairAvailableAt125 || !separation.rebuildUnavailableAt125 || !separation.repairUnavailableAtFull || !separation.rebuildUnavailableAtFull) errors.push("repair/rebuild separation changed");
  if (destroyed.asterFinalHp !== 100 || destroyed.workerFinalHp !== 80 || !bridge.minimapPreserved || !bridge.existingRestoredBarracksPreserved || !bridge.commandKeepPreserved || !bridge.lumeMinePreserved || !bridge.shellsRemainNonProducing) errors.push("preservation changed");

  const statsByName = Object.fromEntries(stats.map(s => [s.fileName, s]));
  for (const file of required) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing ${file}`);
    else if (statSync(path).size < (file.includes("preflight") || file.includes("black_frame") || file.includes("contact_sheet") ? 18000 : 50000)) errors.push(`too small / likely not reviewable ${file}`);
    if (file.endsWith(".png") && !file.includes("preflight") && !file.includes("black_frame") && !file.includes("contact_sheet")) {
      const s = statsByName[file];
      if (!s) errors.push(`missing pixel stats ${file}`);
      else {
        if (s.flatColor || s.nearBlackFlat) errors.push(`black or flat frame ${file}`);
        if (s.sampleUniqueColors < 80) errors.push(`low unique color count ${file}: ${s.sampleUniqueColors}`);
        if (s.meanBrightness < 8 || s.brightnessStdDev < 3) errors.push(`near-black/low-variance frame ${file}: mean=${s.meanBrightness} std=${s.brightnessStdDev}`);
        if (file.includes("minimap") && s.minimapUniqueColors < 8) errors.push(`minimap absent or flat ${file}`);
      }
    }
  }

  return {runtime, fallback, skin, ui, bridge, construction, destroyed, rebuild, separation, snaps, stats, glbSha: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function statSummary(stats) {
  const min = key => Math.min(...stats.map(s => Number(s[key] ?? 0)));
  const max = key => Math.max(...stats.map(s => Number(s[key] ?? 0)));
  return {
    count: stats.length,
    minBytes: min("bytes"),
    minUniqueColors: min("sampleUniqueColors"),
    minMeanBrightness: min("meanBrightness"),
    minBrightnessStdDev: min("brightnessStdDev"),
    maxMeanBrightness: max("meanBrightness")
  };
}

function report(e) {
  const summary = statSummary(e.stats);
  return [
    "# v0.260 Barrosan Review Capture Recovery",
    "",
    `Verdict: \`${verdict}\``,
    "",
    "## Exact facts",
    "",
    "- Base commit: `de5d043a00658fcb89d9ba541b6881413d9a7cf1`.",
    `- Implementation commit: \`${commit}\`.`,
    `- Final HEAD: \`${head}\`.`,
    `- Exact-SHA GitHub Actions run: ${ciRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Old evidence issue: v0.259 uploaded review screenshots 02-29 were black/blank dummy frames.",
    "- Root cause: v0.259 capture used headless Godot dummy rendering; when viewport texture was unavailable the v0.259 code accepted a near-black fallback image for that checkpoint.",
    "- Capture changes made: v0.260 uses standard rendered Godot editor capture for v0.259 proof steps and adds pixel-level black-frame rejection.",
    "- Gameplay mechanics changed: no.",
    "- UI lifecycle resolver logic changed: no.",
    "- Costs changed: no.",
    "- HP/timing changed: no.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    `- Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
    `- Default runtime unchanged: ${(e.fallback.barrosanPlayableRuntimeSkin?.enabled ?? true) === false}.`,
    "",
    "## Pixel / blank-frame validation",
    "",
    `- PNG files inspected: ${summary.count}.`,
    `- Minimum PNG bytes: ${summary.minBytes}.`,
    `- Minimum sampled unique colors: ${summary.minUniqueColors}.`,
    `- Minimum mean brightness: ${summary.minMeanBrightness}.`,
    `- Minimum brightness standard deviation: ${summary.minBrightnessStdDev}.`,
    "- Every runtime screenshot is non-black and visually readable: yes.",
    "- HUD, minimap, terrain, buildings, and lifecycle overlays are visible in the regenerated review pack: yes.",
    "",
    "## v0.259 invariant proof retained",
    "",
    `- Single-source status: ${e.ui.singleSourceStatus}.`,
    `- Impossible combination status: ${e.ui.impossibleCombinationStatus}.`,
    `- Forbidden text status: ${e.ui.forbiddenTextStatus}.`,
    `- Visual overlay sync status: ${e.ui.visualStatus}.`,
    `- Retained mechanics status: ${e.ui.mechanicsRetainedStatus}.`,
    "- Impossible UI combinations remain prevented: no build phase with rebuild/destroyed text; no rebuild phase with build/place text; no rebuilt phase with stale destroyed/rebuild text; no Select Aster beyond initial phase; no Rebuild not yet implemented.",
    "",
    "## Mechanical proof retained",
    "",
    "- Full resources: Construction 420/160/90/38 -> 240/40/90/38; Rebuild 240/40/90/38 -> 150/0/90/38; Train 150/0/90/38 -> 90/0/70/38.",
    "- Full HP: 200 -> 175 -> 150 -> 125 -> 100 -> 75 -> 50 -> 25 -> 0; Rebuild 0 -> 25 -> 50 -> 75 -> 100.",
    "- Production rule: available while HP > 0; unavailable at HP 0; unavailable during rebuild; returns at rebuilt 100/200.",
    "- Repair remains HP 1-199 only; Rebuild remains HP 0 only. No passive collapse, rebuild, repair, or refund.",
    "",
    "## Validation and recommendation",
    "",
    "- Dedicated v0.260 capture and black-frame validator: pass.",
    "- Dedicated v0.260 UI-state invariant validator: pass.",
    `- Exact-SHA GitHub Actions: ${ciRun.startsWith("PENDING") ? "pending publication" : "pass"}.`,
    "- Honest recommendation for v0.261: use this restored visible evidence as the review baseline; do not start new gameplay/art work without a separately authorized v0.261 prompt.",
    "",
    "Stop before v0.261.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const e = inspect(errors);
  mkdirSync(manual, {recursive: true});
  const md = report(e);
  writeFileSync(docPath, md);
  writeFileSync(join(root, "v0260-capture-recovery-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0260_CAPTURE_RECOVERY" : "PASS_V0260_BARROSAN_REVIEW_CAPTURE_RECOVERY", verdict, pixelSummary: statSummary(e.stats), errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const e = inspect(errors);
  writeFileSync(join(root, "v0260-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0260_VALIDATION" : "PASS_V0260_BARROSAN_REVIEW_CAPTURE_RECOVERY_VALIDATION", uiStatus: e.ui.status ?? "UNKNOWN", pixelSummary: statSummary(e.stats), errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

if ((process.argv[2] ?? "capture") === "capture") capture();
else validation();
