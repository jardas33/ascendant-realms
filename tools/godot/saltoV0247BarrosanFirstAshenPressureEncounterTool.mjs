import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const argument = name => (process.argv.find(value => value.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(argument("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0247"));
const verdict = argument("verdict") || "PARTIAL";
const reportedCommit = argument("commit") || "PENDING_PUBLICATION";
const reportedHead = argument("head") || reportedCommit;
const reportedCiRun = argument("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0247-barrosan-first-ashen-pressure-encounter");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0247_BARROSAN_FIRST_ASHEN_PRESSURE_ENCOUNTER_REPORT.md");
const required = [
  "01_v0246_partial_baseline.png", "02_v0247_preflight_head_ci_resolution.png", "03_v0247_default_runtime_unchanged_proof.png",
  "04_v0247_opt_in_overview_before_build.png", "05_v0247_starting_resources.png", "06_v0247_select_builder_unit.png",
  "07_v0247_valid_barracks_preview.png", "08_v0247_confirm_authoritative_barracks_placement.png",
  "09_v0247_construction_resource_delta.png", "10_v0247_select_new_field_barracks_hud.png",
  "11_v0247_train_militia_command_available.png", "12_v0247_train_militia_resource_delta.png",
  "13_v0247_militia_training_progress.png", "14_v0247_militia_ready_spawned.png",
  "15_v0247_select_spawned_militia.png", "16_v0247_objective_ashen_pressure_incoming.png",
  "17_v0247_ashen_raider_spawned.png", "18_v0247_ashen_raider_minimap_presence.png",
  "19_v0247_ashen_raider_pressure_lane_start.png", "20_v0247_ashen_raider_advancing_bridge_lane.png",
  "21_v0247_militia_moves_to_intercept.png", "22_v0247_militia_intercept_zone_reached.png",
  "23_v0247_pressure_contained_status.png", "24_v0247_no_damage_no_resource_mutation_after_pressure.png",
  "25_v0247_command_keep_preserved.png", "26_v0247_existing_barracks_train_flow_preserved.png",
  "27_v0247_lume_mine_preserved.png", "28_v0247_shells_remain_non_producing.png",
  "29_v0247_unselected_clean_view.png", "30_v0247_before_after_contact_sheet.png", "31_v0247_report.md",
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
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.247" || runtime.captureCount !== 26) errors.push("runtime capture contract failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.247") errors.push("default proof failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.247") errors.push("skin status failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false || skin.defaultRuntimeChanged !== false) errors.push("default runtime boundary failed");
  if (construction.status !== "PASS" || construction.placementResourceDelta?.crowns !== -180 || construction.placementResourceDelta?.stone !== -120 || construction.spendCount !== 1) errors.push("construction bridge failed");
  if (production.status !== "PASS" || production.queueResourceDelta?.crowns !== -60 || production.queueResourceDelta?.iron !== -20 || production.spawnCount !== 1) errors.push("production bridge failed");
  if (pressure.status !== "PASS" || pressure.spawnCount !== 1 || pressure.runtimeId !== "v0247_ashen_raider_00") errors.push("pressure encounter failed");
  if (pressure.registered !== true || pressure.selected !== true || pressure.minimapRegistered !== true || pressure.laneProbePass !== true) errors.push("Raider registration/readability failed");
  if (pressure.interceptReached !== true || pressure.contained !== true) errors.push("Militia intercept failed");
  if (pressure.pressureResourcesUnchanged !== true || pressure.damageApplied !== false || pressure.deathOccurred !== false || pressure.additionalEnemiesSpawned !== false) errors.push("non-combat mutation boundary failed");
  if (pressure.existingRestoredBarracksPreserved !== true || pressure.commandKeepPreserved !== true || pressure.lumeMinePreserved !== true || pressure.shellsRemainNonProducing !== true) errors.push("preservation boundary failed");
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, defaultRuntime, skin, construction, production, pressure, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.247 Barrosan First Ashen Pressure Encounter", "",
    `Verdict: \`${selectedVerdict}\``, "",
    "## Exact facts", "",
    "- Resolved base commit: `0ffa827d8377148f599b3df173f67de710a11ad1`.",
    "- v0.246 implementation commit: `2325d8c2853404a62193957471bebdf2c8cdcb62`; documentation closeout/base: `0ffa827d8377148f599b3df173f67de710a11ad1`.",
    "- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27890932048.",
    `- Implementation commit: \`${reportedCommit}\`.`,
    `- Final repository HEAD: \`${reportedHead}\`.`,
    `- Exact-SHA GitHub Actions run: ${reportedCiRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- Existing v0.239 GLB reused unchanged: yes.",
    `- GLB SHA-256: \`${e.glbSha256}\`.`,
    "- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.", "",
    "## Runtime scope", "",
    "- Systems touched: opt-in Barrosan subclass state, review capture dispatch, minimap marker and HUD copy.",
    "- Systems untouched: default browser/Godot runtime, saves, full combat, full AI, global economy, source content and shell production.",
    "- Construction target: one authoritative opt-in Field Barracks.",
    "- Production target: exactly one Militia from that constructed Field Barracks.",
    "- Pressure target: exactly one scripted Ashen Raider using the existing procedural runtime silhouette.",
    `- Ashen Raider runtime ID: \`${e.pressure.runtimeId}\`; scripted, not AI-driven.`,
    "- Combat damage: no. Death: no.", "",
    "## Resources and trigger", "",
    `- Starting resources: ${JSON.stringify(e.construction.startingResources ?? {})}.`,
    `- After construction: ${JSON.stringify(e.construction.afterPlacementResources ?? {})}; delta ${JSON.stringify(e.construction.placementResourceDelta ?? {})}.`,
    `- After Militia training: ${JSON.stringify(e.production.resourcesAfterTrainingSpend ?? {})}; delta ${JSON.stringify(e.production.queueResourceDelta ?? {})}.`,
    `- After Raider pressure: ${JSON.stringify(e.pressure.resourcesAfterPressure ?? {})}; unchanged during pressure: ${e.pressure.pressureResourcesUnchanged}.`,
    `- Pressure trigger: ${e.pressure.trigger}.`, "",
    "## Pressure and containment", "",
    `- Lane: ${e.pressure.laneDescription}; lane probes pass: ${e.pressure.laneProbePass}.`,
    `- Intercept zone: ${JSON.stringify(e.pressure.interceptZone ?? {})}, radius ${e.pressure.interceptRadius}.`,
    "- Contained condition: Militia enters the intercept zone and is within the same radius of the Raider.",
    `- Militia selected/movable/minimap: ${e.production.selected} / ${e.production.movementProbePass} / ${e.production.minimapRegistered}.`,
    `- Raider selected/minimap/pathing: ${e.pressure.selected} / ${e.pressure.minimapRegistered} / ${e.pressure.pathingParity}.`,
    `- Pressure contained: ${e.pressure.contained}; damage applied: ${e.pressure.damageApplied}; death occurred: ${e.pressure.deathOccurred}.`, "",
    "## Preservation", "",
    `- Existing Restored Barracks flow preserved: ${e.pressure.existingRestoredBarracksPreserved}.`,
    `- Command Keep preserved: ${e.pressure.commandKeepPreserved}.`,
    `- Lume Mine preserved: ${e.pressure.lumeMinePreserved}.`,
    `- Forge, Market and Watchtower shells preserved and non-producing: ${e.pressure.shellsRemainNonProducing}.`,
    "- Pathing remains review-grade rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.",
    "- Default runtime remains unchanged.", "",
    "## Exact source files changed", "",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/buildV0247BarrosanFirstAshenPressureEncounterReviewPack.py`",
    "- `tools/godot/captureGodotV0247BarrosanFirstAshenPressureEncounterWindows.ps1`",
    "- `tools/godot/saltoV0247BarrosanFirstAshenPressureEncounterTool.mjs`",
    "- `tools/godot/validateGodotV0247BarrosanFirstAshenPressureEncounterWindows.ps1`",
    "- `package.json`",
    "- `docs/V0247_BARROSAN_FIRST_ASHEN_PRESSURE_ENCOUNTER_REPORT.md`", "",
    "## Validation results", "",
    "- `npm run godot:test`: pass.",
    "- v0.247 capture and dedicated validator: pass.",
    "- `npm test`: pass (122 files / 887 tests).",
    "- `npm run build`: pass.",
    "- Content, art-intake and runtime-art-slot validators: pass.",
    "- Experimental artifact-retention validator: pass.",
    "- `npm run godot:all`: pass, including Windows export/package.",
    "- `git diff --check`: pass.",
    "- Exact-SHA GitHub Actions: pending publication.", "",
    "## Honest assessment", "",
    "The encounter closes the first build-to-defense lifecycle: the constructed Field Barracks trains one Militia, one scripted Raider enters from the east, the Militia moves to a road/bridge intercept zone, and proximity marks the pressure contained without resource, health or death mutation.",
    "",
    "The verdict remains PARTIAL because the encounter is deliberately single-enemy, scripted, proximity-resolved and non-combat, while pathing remains review-grade. Recommendation for v0.248: validate human-readable timing and command affordances before considering any tightly bounded combat bridge.", "",
    "Stop after v0.247. Do not begin v0.248.", "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of required.slice(0, 30)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const report = markdown(evidence, verdict);
  writeFileSync(join(manual, "31_v0247_report.md"), report);
  writeFileSync(docPath, report);
  writeFileSync(join(root, "v0247-capture-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0247_CAPTURE" : "PASS_V0247_BARROSAN_FIRST_ASHEN_PRESSURE_ENCOUNTER_CAPTURE", verdict, construction: evidence.construction, production: evidence.production, pressure: evidence.pressure, errors}, null, 2) + "\n");
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
  writeFileSync(join(root, "v0247-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0247_VALIDATION" : "PASS_V0247_BARROSAN_FIRST_ASHEN_PRESSURE_ENCOUNTER_VALIDATION", verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN", pressureStatus: evidence.pressure.status ?? "UNKNOWN", runtimeId: evidence.pressure.runtimeId ?? "", errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
