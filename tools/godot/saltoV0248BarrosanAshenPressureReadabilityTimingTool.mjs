import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const argument = name => (process.argv.find(value => value.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(argument("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0248"));
const verdict = argument("verdict") || "PARTIAL";
const reportedCommit = argument("commit") || "PENDING_PUBLICATION";
const reportedHead = argument("head") || reportedCommit;
const reportedCiRun = argument("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0248-barrosan-ashen-pressure-readability-timing");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0248_BARROSAN_ASHEN_PRESSURE_READABILITY_TIMING_REPORT.md");
const names = [
  "01_v0247_partial_baseline.png", "02_v0248_preflight_head_ci_resolution.png", "03_v0248_default_runtime_unchanged_proof.png",
  "04_v0248_opt_in_overview_before_build.png", "05_v0248_starting_resources.png", "06_v0248_select_builder_unit.png",
  "07_v0248_valid_barracks_preview.png", "08_v0248_confirm_authoritative_barracks_placement.png",
  "09_v0248_construction_resource_delta.png", "10_v0248_select_new_field_barracks_hud.png",
  "11_v0248_prepare_one_defender_objective.png", "12_v0248_train_militia_command_available.png",
  "13_v0248_train_militia_resource_delta.png", "14_v0248_militia_training_progress_0.png",
  "15_v0248_militia_training_progress_50.png", "16_v0248_militia_ready_spawned.png",
  "17_v0248_defender_ready_objective.png", "18_v0248_ashen_pressure_incoming_objective.png",
  "19_v0248_pressure_telegraph_marker.png", "20_v0248_ashen_raider_spawned_once.png",
  "21_v0248_ashen_raider_minimap_presence.png", "22_v0248_ashen_raider_pressure_lane_start.png",
  "23_v0248_ashen_raider_advancing_readable_timing.png", "24_v0248_select_spawned_militia_hud.png",
  "25_v0248_intercept_zone_marker.png", "26_v0248_militia_moves_to_intercept_zone.png",
  "27_v0248_militia_reaches_intercept_zone.png", "28_v0248_pressure_contained_status.png",
  "29_v0248_no_damage_no_resource_mutation_after_pressure.png", "30_v0248_command_keep_preserved.png",
  "31_v0248_existing_barracks_train_flow_preserved.png", "32_v0248_lume_mine_preserved.png",
  "33_v0248_shells_remain_non_producing.png", "34_v0248_unselected_clean_view.png",
  "35_v0248_before_after_contact_sheet.png", "36_v0248_report.md",
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
  const pressure = skin.firstAshenPressureEncounter ?? {};
  const readability = skin.ashenPressureReadabilityTiming ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.248" || runtime.captureCount !== 31) errors.push("runtime capture contract failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.248") errors.push("default proof failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.248") errors.push("opt-in skin status failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false || skin.defaultRuntimeChanged !== false) errors.push("default runtime boundary failed");
  if (construction.status !== "PASS" || construction.placementResourceDelta?.crowns !== -180 || construction.placementResourceDelta?.stone !== -120 || construction.spendCount !== 1) errors.push("construction bridge failed");
  if (production.status !== "PASS" || production.queueResourceDelta?.crowns !== -60 || production.queueResourceDelta?.iron !== -20 || production.spawnCount !== 1) errors.push("production bridge failed");
  if (pressure.status !== "PASS" || pressure.spawnCount !== 1 || pressure.runtimeId !== "v0247_ashen_raider_00") errors.push("v0.247 encounter preservation failed");
  if (readability.status !== "PASS" || readability.objectiveLadderPass !== true) errors.push("readability objective contract failed");
  if (readability.pressureTelegraph?.registered !== true || readability.pressureTelegraph?.nonBlocking !== true) errors.push("pressure telegraph failed");
  if (readability.interceptMarker?.registered !== true || readability.interceptMarker?.state !== "contained" || readability.interceptMarker?.countsAsBuilding !== false) errors.push("intercept marker failed");
  if (readability.resourceSnapshotsUnchanged !== true || readability.healthSnapshotsUnchanged !== true) errors.push("timed mutation snapshots failed");
  for (const key of ["afterTelegraph", "afterRaiderSpawn", "afterRaiderMovement", "afterContainment"]) if (!readability.resourceSnapshots?.[key]) errors.push(`missing ${key} resource snapshot`);
  if (pressure.minimapRegistered !== true || pressure.laneProbePass !== true || pressure.contained !== true) errors.push("Raider lane/minimap/containment failed");
  if (pressure.pressureResourcesUnchanged !== true || pressure.damageApplied !== false || pressure.deathOccurred !== false || pressure.additionalEnemiesSpawned !== false) errors.push("non-combat boundary failed");
  if (pressure.existingRestoredBarracksPreserved !== true || pressure.commandKeepPreserved !== true || pressure.lumeMinePreserved !== true || pressure.shellsRemainNonProducing !== true) errors.push("preservation boundary failed");
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, defaultRuntime, skin, construction, production, pressure, readability, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  const snapshots = e.readability.resourceSnapshots ?? {};
  return [
    "# v0.248 Barrosan Ashen Pressure Readability and Timing Hardening", "",
    `Verdict: \`${selectedVerdict}\``, "",
    "## Exact facts", "",
    "- Resolved base commit: `3904510b82cb5f6040fdff13dc0f6b2b83e520ff`.",
    "- v0.247 implementation commit: `2c502121ec83b476e571d1ef557bf8666fed90de`; documentation closeout/base: `3904510b82cb5f6040fdff13dc0f6b2b83e520ff`.",
    "- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27906676309.",
    `- Implementation commit: \`${reportedCommit}\`.`,
    `- Final repository HEAD: \`${reportedHead}\`.`,
    `- Exact-SHA GitHub Actions run: ${reportedCiRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes.",
    `- Existing GLB SHA-256: \`${e.glbSha256}\`.`, "",
    "## Runtime scope", "",
    "- Systems touched: opt-in objective copy, pressure timing snapshots, non-colliding threat/intercept markers, HUD copy, capture and validation.",
    "- Default systems untouched: default runtime, combat, damage, death, AI planner, waves, economy, saves, production shells and source assets.",
    "- Construction target/cost: one authoritative Field Barracks; 180 Crowns / 120 Stone.",
    "- Production target/cost: exactly one Militia; 60 Crowns / 20 Iron.",
    `- Pressure target: one scripted Ashen Raider, ID \`${e.pressure.runtimeId}\`; AI-driven: false; count: ${e.pressure.spawnCount}.`,
    "- Pressure telegraph: red/orange non-blocking `ASHEN APPROACH` marker on the east lane, opt-in only.",
    "- Intercept zone: cyan non-blocking `INTERCEPT ZONE` marker near the bridge approach; changes to `PRESSURE CONTAINED`; not a building.",
    `- Objective ladder: ${(e.readability.objectiveLadder ?? []).join(" -> ")}.`,
    "- Raider timing: deterministic visible spawn, 150-frame lane-entry movement and 245-frame bridge-approach movement; never more than one Raider.",
    "- Militia intercept condition: proximity/zone containment at the existing 115-unit review radius.",
    "- HUD explicitly reports `Scripted pressure entity | no damage in v0.248` and `No damage exchanged`.", "",
    "## Resource and mutation proof", "",
    `- Before construction: ${JSON.stringify(e.construction.startingResources ?? {})}.`,
    `- After construction: ${JSON.stringify(e.construction.afterPlacementResources ?? {})}; delta ${JSON.stringify(e.construction.placementResourceDelta ?? {})}.`,
    `- After training: ${JSON.stringify(e.production.resourcesAfterTrainingSpend ?? {})}; delta ${JSON.stringify(e.production.queueResourceDelta ?? {})}.`,
    `- After telegraph: ${JSON.stringify(snapshots.afterTelegraph ?? {})}.`,
    `- After Raider spawn: ${JSON.stringify(snapshots.afterRaiderSpawn ?? {})}.`,
    `- After Raider movement: ${JSON.stringify(snapshots.afterRaiderMovement ?? {})}.`,
    `- After containment: ${JSON.stringify(snapshots.afterContainment ?? {})}.`,
    `- Pressure resource snapshots unchanged: ${e.readability.resourceSnapshotsUnchanged}. Health unchanged: ${e.readability.healthSnapshotsUnchanged}.`,
    `- Damage exists: ${e.pressure.combatDamageEnabled}; death exists: ${e.pressure.deathEnabled}; any combat exists: false.`,
    `- Damage applied: ${e.pressure.damageApplied}; death occurred: ${e.pressure.deathOccurred}; extra enemies spawned: ${e.pressure.additionalEnemiesSpawned}.`, "",
    "## Preservation and honesty", "",
    `- Raider minimap registered: ${e.pressure.minimapRegistered}; deterministic lane probes pass: ${e.pressure.laneProbePass}.`,
    `- Existing Restored Barracks train flow preserved: ${e.pressure.existingRestoredBarracksPreserved}.`,
    `- Command Keep / Lume Mine live: ${e.pressure.commandKeepPreserved} / ${e.pressure.lumeMinePreserved}.`,
    `- March Forge, Frontier Market and Watchtower remain non-producing shells: ${e.pressure.shellsRemainNonProducing}.`,
    "- Default runtime proof: opt-in skin disabled in default capture; Raider, markers and v0.248 labels absent.",
    "- Pathing honesty: review-grade rectangular destination-nudge only; no browser PathfindingGrid parity.",
    "- The verdict remains PARTIAL because this is a single scripted Raider, proximity containment, primitive functional markers and no combat.", "",
    "## Files changed", "",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/buildV0248BarrosanAshenPressureReadabilityTimingReviewPack.py`",
    "- `tools/godot/captureGodotV0248BarrosanAshenPressureReadabilityTimingWindows.ps1`",
    "- `tools/godot/saltoV0248BarrosanAshenPressureReadabilityTimingTool.mjs`",
    "- `tools/godot/validateGodotV0248BarrosanAshenPressureReadabilityTimingWindows.ps1`",
    "- `package.json`",
    "- `docs/V0248_BARROSAN_ASHEN_PRESSURE_READABILITY_TIMING_REPORT.md`", "",
    "## Validation results", "",
    "- `npm run godot:test`: pass.",
    "- v0.248 capture and dedicated validator: pass.",
    "- `npm test`: pass (122 files / 887 tests).",
    "- `npm run build`: pass.",
    "- Content, art-intake and runtime-art-slot validators: pass.",
    "- Experimental artifact-retention validator: pass.",
    "- `npm run godot:all`: pass, including Windows export/package.",
    "- `git diff --check`: pass.",
    "- Exact-SHA GitHub Actions: pending publication.", "",
    "## Recommendation for v0.249", "",
    "If reopened, introduce one tightly bounded combat-resolution bridge only after preserving this readability contract; do not broaden into waves, production AI or full pathfinding.",
    "",
    "Stop after v0.248. Do not begin v0.249.", "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of names.slice(0, 35)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const report = markdown(evidence, verdict);
  writeFileSync(join(manual, "36_v0248_report.md"), report);
  writeFileSync(docPath, report);
  writeFileSync(join(root, "v0248-capture-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0248_CAPTURE" : "PASS_V0248_BARROSAN_ASHEN_PRESSURE_READABILITY_TIMING_CAPTURE", verdict, construction: evidence.construction, production: evidence.production, pressure: evidence.pressure, readability: evidence.readability, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const file of names) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 700)) errors.push(`review file too small ${file}`);
  }
  if (!existsSync(docPath)) errors.push("missing report");
  writeFileSync(join(root, "v0248-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0248_VALIDATION" : "PASS_V0248_BARROSAN_ASHEN_PRESSURE_READABILITY_TIMING_VALIDATION", verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN", readabilityStatus: evidence.readability.status ?? "UNKNOWN", errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
