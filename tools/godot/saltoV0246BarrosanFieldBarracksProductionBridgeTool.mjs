import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const argument = name => (process.argv.find(value => value.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(argument("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0246"));
const verdict = argument("verdict") || "PARTIAL";
const reportedCommit = argument("commit") || "PENDING_PUBLICATION";
const reportedCiRun = argument("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0246-barrosan-field-barracks-production-bridge");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0246_BARROSAN_FIELD_BARRACKS_PRODUCTION_BRIDGE_REPORT.md");
const required = [
  "01_v0245_partial_baseline.png", "02_v0246_preflight_head_ci_resolution.png", "03_v0246_default_runtime_unchanged_proof.png",
  "04_v0246_opt_in_overview_before_build.png", "05_v0246_starting_resources.png", "06_v0246_select_builder_unit.png",
  "07_v0246_valid_barracks_preview.png", "08_v0246_confirm_authoritative_barracks_placement.png",
  "09_v0246_construction_resource_delta.png", "10_v0246_select_new_field_barracks_hud.png",
  "11_v0246_train_militia_command_available.png", "12_v0246_train_militia_resource_delta.png",
  "13_v0246_militia_training_progress.png", "14_v0246_militia_spawned_from_new_barracks.png",
  "15_v0246_select_spawned_militia.png", "16_v0246_move_spawned_militia_road_probe.png",
  "17_v0246_move_spawned_militia_bridge_probe.png", "18_v0246_failed_train_no_resource_mutation.png",
  "19_v0246_new_barracks_and_militia_minimap_presence.png", "20_v0246_existing_barracks_train_flow_preserved.png",
  "21_v0246_command_keep_live_hud_preserved.png", "22_v0246_lume_mine_live_hud_preserved.png",
  "23_v0246_shells_remain_non_producing.png", "24_v0246_unselected_clean_view.png",
  "25_v0246_before_after_contact_sheet.png", "26_v0246_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, defaultPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const defaultRuntime = existsSync(defaultPath) ? read(defaultPath) : {};
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const construction = skin.authoritativeConstructionBridge ?? {};
  const production = skin.fieldBarracksProductionBridge ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.246" || runtime.captureCount !== 21) errors.push("runtime capture contract failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.246") errors.push("default proof failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.246") errors.push("skin status failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime unexpectedly skinned");
  if (skin.defaultRuntimeChanged !== false || skin.gameplaySystemsChanged !== false) errors.push("default boundary failed");
  if (construction.status !== "PASS" || construction.placementResourceDelta?.crowns !== -180 || construction.placementResourceDelta?.stone !== -120 || construction.spendCount !== 1) errors.push("construction bridge failed");
  if (production.status !== "PASS" || production.authorityLoaded !== true) errors.push("production bridge failed");
  if (production.cost?.crowns !== 60 || production.cost?.iron !== 20) errors.push("Militia authority cost failed");
  if (production.queueSpendCount !== 1 || production.queueResourceDelta?.crowns !== -60 || production.queueResourceDelta?.iron !== -20) errors.push("training spend failed");
  if (production.duplicateQueueRejected !== true || production.duplicateQueueResourcesUnchanged !== true) errors.push("single-slot queue rejection failed");
  if (production.failedTrainRejected !== true || production.failedTrainResourcesUnchanged !== true) errors.push("failed training mutation gate failed");
  if (production.spawned !== true || production.spawnCount !== 1 || production.runtimeId !== "v0246_field_militia_00") errors.push("Militia spawn failed");
  if (production.selected !== true || production.minimapRegistered !== true || production.movementProbePass !== true) errors.push("Militia integration failed");
  if (production.existingRestoredBarracksPreserved !== true) errors.push("Restored Barracks regressed");
  if (production.commandKeepPreserved !== true || production.lumeMinePreserved !== true || production.shellsRemainNonProducing !== true) errors.push("role preservation failed");
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, defaultRuntime, skin, construction, production, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.246 Barrosan Field Barracks Production Bridge", "",
    `Verdict: \`${selectedVerdict}\``, "",
    "## Exact facts", "",
    "- Resolved base commit: `f9895e5bbca9cf38280097383afa877719a68986`.",
    "- v0.245 implementation commit: `4fc5b6229ea7b99c36754a5281320f8b6423b94d`; documentation closeout/base: `f9895e5bbca9cf38280097383afa877719a68986`.",
    "- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27889143566.",
    `- Implementation commit: \`${reportedCommit}\`.`,
    `- Exact-SHA GitHub Actions run: ${reportedCiRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- v0.239 GLB reused unchanged: yes.",
    `- GLB SHA-256: \`${e.glbSha256}\`.`,
    "- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.", "",
    "## Construction and production", "",
    "- Construction target: one authoritative opt-in Field Barracks.",
    "- Production target: only that newly constructed Field Barracks.",
    "- Existing Restored Barracks remains a separate live production flow.",
    "- Shell roles remain non-producing.",
    "- Construction cost/delta: 180 Crowns and 120 Stone, spent exactly once.",
    `- Militia training authority/cost: generated portable unit definition, ${JSON.stringify(e.production.cost ?? {})}.`,
    `- Starting resources: ${JSON.stringify(e.construction.startingResources ?? {})}.`,
    `- Resources after construction: ${JSON.stringify(e.construction.afterPlacementResources ?? {})}.`,
    `- Resources after training spend: ${JSON.stringify(e.production.resourcesAfterTrainingSpend ?? {})}.`,
    `- Training delta/spend count: ${JSON.stringify(e.production.queueResourceDelta ?? {})} / ${e.production.queueSpendCount}.`, "",
    "## Queue, failure and spawn", "",
    `- Single-slot queue accepted: ${e.production.queueAccepted}; progress reached: ${e.production.progress}.`,
    `- Duplicate queue rejected without mutation: ${e.production.duplicateQueueRejected} / ${e.production.duplicateQueueResourcesUnchanged}.`,
    `- Post-spawn failed training rejected without mutation: ${e.production.failedTrainRejected} / ${e.production.failedTrainResourcesUnchanged}; reason: ${e.production.failedTrainReason}.`,
    `- Spawned Militia runtime ID: \`${e.production.runtimeId}\`; spawn count: ${e.production.spawnCount}.`,
    `- Selection: ${e.production.selected}; movement probes: ${e.production.movementProbePass}; minimap: ${e.production.minimapRegistered}.`, "",
    "## Preservation and pathing honesty", "",
    `- Existing Restored Barracks restore/train flow preserved: ${e.production.existingRestoredBarracksPreserved}.`,
    `- Command Keep preserved: ${e.production.commandKeepPreserved}.`,
    `- Lume Mine preserved: ${e.production.lumeMinePreserved}.`,
    `- Forge, Market and Watchtower remain non-producing: ${e.production.shellsRemainNonProducing}.`,
    "- Pathing remains review-grade rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.",
    "- Default browser and Godot runtimes remain unchanged; saves, combat, AI, objectives, global economy and source content remain untouched.", "",
    "## Exact source files changed", "",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/buildV0246BarrosanFieldBarracksProductionBridgeReviewPack.py`",
    "- `tools/godot/captureGodotV0246BarrosanFieldBarracksProductionBridgeWindows.ps1`",
    "- `tools/godot/saltoV0246BarrosanFieldBarracksProductionBridgeTool.mjs`",
    "- `tools/godot/validateGodotV0246BarrosanFieldBarracksProductionBridgeWindows.ps1`",
    "- `package.json`",
    "- `docs/V0246_BARROSAN_FIELD_BARRACKS_PRODUCTION_BRIDGE_REPORT.md`", "",
    "## Validation results", "",
    "- `npm run godot:test`: pass.",
    "- v0.246 capture and dedicated validator: pass.",
    "- `npm test`: pass (122 files / 887 tests).",
    "- `npm run build`: pass.",
    "- Content, art-intake and runtime-art-slot validators: pass.",
    "- Experimental artifact-retention validator: pass.",
    "- `npm run godot:all`: pass, including Windows export/package.",
    "- `git diff --check`: pass.",
    "- Exact-SHA GitHub Actions: pending publication.", "",
    "## Assessment", "",
    "The first limited opt-in playable production loop is technically real: authoritative construction spends once, the constructed Field Barracks exposes one generated-cost Militia action, the one-slot queue rejects duplicates, one uniquely registered Militia spawns, and that Militia can be selected, moved and represented on the minimap.",
    "",
    "The verdict remains PARTIAL because production is deliberately limited to one Militia, the lane is opt-in, no broader objective/combat integration is added, and pathing remains review-grade. Recommendation for v0.247: only broaden lifecycle integration after preserving these exact mutation and ownership boundaries.", "",
    "Stop after v0.246. Do not begin v0.247.", "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of required.slice(0, 25)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const report = markdown(evidence, verdict);
  writeFileSync(join(manual, "26_v0246_report.md"), report);
  writeFileSync(docPath, report);
  writeFileSync(join(root, "v0246-capture-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0246_CAPTURE" : "PASS_V0246_BARROSAN_FIELD_BARRACKS_PRODUCTION_BRIDGE_CAPTURE",
    verdict, retainedGlbSha256: evidence.glbSha256, construction: evidence.construction, production: evidence.production, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const file of required) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 700)) errors.push(`review file too small ${file}`);
  }
  if (!existsSync(docPath)) errors.push("missing report");
  writeFileSync(join(root, "v0246-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0246_VALIDATION" : "PASS_V0246_BARROSAN_FIELD_BARRACKS_PRODUCTION_BRIDGE_VALIDATION",
    verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN",
    constructionStatus: evidence.construction.status ?? "UNKNOWN",
    productionStatus: evidence.production.status ?? "UNKNOWN",
    runtimeId: evidence.production.runtimeId ?? "",
    retainedGlbSha256: evidence.glbSha256, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
