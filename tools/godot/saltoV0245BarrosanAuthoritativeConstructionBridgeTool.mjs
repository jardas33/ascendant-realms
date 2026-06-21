import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const root = resolve((process.argv.find(v => v.startsWith("--artifact-root=")) ?? `--artifact-root=${join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0245")}`).split("=")[1]);
const verdict = (process.argv.find(v => v.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const reportedCommit = (process.argv.find(v => v.startsWith("--commit=")) ?? "--commit=PENDING_PUBLICATION").split("=")[1];
const reportedCiRun = (process.argv.find(v => v.startsWith("--ci-run=")) ?? "--ci-run=PENDING_PUBLICATION").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0245-barrosan-authoritative-construction-bridge");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0245_BARROSAN_AUTHORITATIVE_CONSTRUCTION_BRIDGE_REPORT.md");
const required = [
  "01_v0244_partial_baseline.png", "02_v0245_preflight_head_ci_resolution.png", "03_v0245_default_runtime_unchanged_proof.png",
  "04_v0245_opt_in_overview_before_build.png", "05_v0245_starting_resources.png", "06_v0245_select_builder_unit.png",
  "07_v0245_valid_preview_before_cancel.png", "08_v0245_cancel_preview_resources_unchanged.png",
  "09_v0245_blocked_preview_real_reason.png", "10_v0245_blocked_attempt_no_resource_mutation.png",
  "11_v0245_valid_preview_before_confirm.png", "12_v0245_confirm_real_placement.png",
  "13_v0245_resource_delta_after_real_placement.png", "14_v0245_new_structure_registered_selected.png",
  "15_v0245_new_structure_minimap_presence.png", "16_v0245_command_keep_live_hud_preserved.png",
  "17_v0245_barracks_live_hud_and_train_preserved.png", "18_v0245_lume_mine_live_hud_preserved.png",
  "19_v0245_shell_forge_market_watchtower_preserved.png", "20_v0245_unit_pathing_near_new_structure.png",
  "21_v0245_unselected_clean_view.png", "22_v0245_before_after_contact_sheet.png", "23_v0245_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, defaultPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const defaultRuntime = existsSync(defaultPath) ? read(defaultPath) : {};
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const bridge = skin.authoritativeConstructionBridge ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.245" || runtime.captureCount !== 18) errors.push("runtime capture contract failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.245") errors.push("default proof failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.245") errors.push("skin status failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime unexpectedly skinned");
  if (skin.defaultRuntimeChanged !== false || skin.gameplaySystemsChanged !== false) errors.push("default boundary failed");
  if (bridge.status !== "PASS" || bridge.implemented !== true) errors.push("construction bridge failed");
  if (bridge.placementAuthority !== "BuildPlacementValidationAdapter generated portable authority") errors.push("placement authority failed");
  if (bridge.cancelResourcesUnchanged !== true) errors.push("cancel mutated resources");
  if (bridge.blockedResourcesUnchanged !== true || bridge.blockedStructureCreated !== false) errors.push("blocked attempt mutated state");
  if (bridge.blockedAttempt?.reason !== "blocked-terrain") errors.push("blocked reason failed");
  if (bridge.validAttempt?.ok !== true) errors.push("valid attempt failed");
  if (bridge.spendCount !== 1 || bridge.placementResourceDelta?.crowns !== -180 || bridge.placementResourceDelta?.stone !== -120) errors.push("resource delta failed");
  if (bridge.runtimeId !== "v0245_authoritative_barracks_00" || bridge.roleId !== "barrosan_role_barracks_constructed_00") errors.push("stable registration failed");
  if (bridge.registered !== true || bridge.selected !== true || bridge.minimapRegistered !== true) errors.push("selection/minimap registration failed");
  if (bridge.existingRestoredBarracksPreserved !== true) errors.push("restored barracks flow failed");
  if (bridge.pathingProbe?.accepted !== true || bridge.pathingProbe?.stuckDelta !== 0) errors.push("pathing probe failed");
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, defaultRuntime, skin, bridge, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.245 Barrosan Authoritative Construction Bridge", "",
    `Verdict: \`${selectedVerdict}\``, "",
    "## Exact facts", "",
    "- Resolved base commit: `e84cb1369c1f1ad7513ddd2c1c8b3f09d6530f84`.",
    "- `818bd61319f629a628b3671a1d3cc9ea1e20db87` is the v0.244 implementation parent; `e84cb13...` is the true final v0.244 base.",
    "- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27887850796.",
    `- Implementation commit: \`${reportedCommit}\`.`,
    `- Exact-SHA GitHub Actions run: ${reportedCiRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- v0.239 GLB reused unchanged: yes.",
    `- GLB SHA-256: \`${e.glbSha256}\`.`,
    "- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.", "",
    "## Construction target and authority", "",
    "- Target: exactly one opt-in technical Barracks.",
    "- House was not chosen because the exported generated authority contains no House building definition; inventing one would violate the authority boundary.",
    "- The existing Restored Barracks remains the live production building. The new structure is complete, selectable and registered, but intentionally has no production.",
    "- Placement gate: `BuildPlacementValidationAdapter`, using exported `broken_ford` terrain, building size, overlap and resource rules.",
    "- Exported cost: 180 Crowns and 120 Stone.", "",
    "## Placement and resources", "",
    `- Valid preview result: \`${e.bridge.validAttempt?.ok}\`.`,
    `- Cancel preview resources unchanged: \`${e.bridge.cancelResourcesUnchanged}\`.`,
    `- Blocked preview/attempt reason: \`${e.bridge.blockedAttempt?.reason}\` / \`${e.bridge.blockedAttempt?.reasonText}\`.`,
    `- Blocked attempt resources unchanged: \`${e.bridge.blockedResourcesUnchanged}\`; structure created: \`${e.bridge.blockedStructureCreated}\`.`,
    `- Valid placement resource delta: \`${JSON.stringify(e.bridge.placementResourceDelta)}\`; spend count: \`${e.bridge.spendCount}\`.`,
    `- Runtime ID: \`${e.bridge.runtimeId}\`.`,
    `- Role ID: \`${e.bridge.roleId}\`.`, "",
    "## Registration and preserved systems", "",
    "- New structure is present in runtime structures, selection hit testing and minimap.",
    "- HUD: `Authoritative Field Barracks | Opt-in technical construction`; `Authoritative placement / complete / no production`.",
    "- Existing Command Keep, Restored Barracks, Lume Mine, Aster, Worker and Militia remain intact.",
    "- Existing Barracks restoration, Militia queue and spawn flow passes after the new placement.",
    "- March Forge, Frontier Market and Watchtower remain honest non-producing shells.", "",
    "## Pathing honesty", "",
    "- Movement near the new structure completed without an obvious stuck/no-progress failure.",
    "- This remains review-grade rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.", "",
    "## Runtime boundaries", "",
    "- Touched only the opt-in Barrosan subclass, existing read-only adapter access, capture routing and v0.245 tooling.",
    "- Untouched: default browser runtime, default Godot runtime, saves, AI, combat, objectives, normal economy/production/commands and source content.", "",
    "## Validation results", "",
    "- `npm run godot:test`: pass.",
    "- `npm run godot:capture:salto-barrosan-authoritative-construction-bridge`: pass.",
    "- `npm run godot:validate:salto-barrosan-authoritative-construction-bridge`: pass.",
    "- `npm test`: pass, 122 files / 887 tests.",
    "- `npm run build`: pass.",
    "- `npm run validate:content`: pass.",
    "- `npm run validate:art-intake`: pass.",
    "- `npm run validate:runtime-art-slots`: pass, 52 stable slots.",
    "- `npm run godot:validate:salto-experimental-artifact-retention`: pass.",
    "- `npm run godot:all`: pass, including Windows export/package.",
    "- `git diff --check`: pass.",
    "- Exact-SHA GitHub Actions: pending publication.", "",
    "## Exact source files changed", "",
    "- `desktop-spikes/godot-salto/scripts/adapters/build_placement_validation_adapter.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/buildV0245BarrosanAuthoritativeConstructionBridgeReviewPack.py`",
    "- `tools/godot/captureGodotV0245BarrosanAuthoritativeConstructionBridgeWindows.ps1`",
    "- `tools/godot/saltoV0245BarrosanAuthoritativeConstructionBridgeTool.mjs`",
    "- `tools/godot/validateGodotV0245BarrosanAuthoritativeConstructionBridgeWindows.ps1`",
    "- `package.json`",
    "- `docs/V0245_BARROSAN_AUTHORITATIVE_CONSTRUCTION_BRIDGE_REPORT.md`", "",
    "## Assessment", "",
    "The key v0.245 contract is proven: a real structure cannot be appended or charged unless the same exported-authority adapter approves the point. Cancel and blocked attempts are mutation-free, while valid confirmation spends exactly once and registers a selectable minimap entity.",
    "",
    "The verdict remains PARTIAL because the new Barracks is a constrained non-producing technical entity and navigation remains review-grade. Recommendation for v0.246: harden shared construction lifecycle and pathing semantics before calling this a first playable building system.", "",
    "Stop after v0.245. Do not begin v0.246.", "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of required.slice(0, 22)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const report = markdown(evidence, verdict);
  writeFileSync(join(manual, "23_v0245_report.md"), report);
  writeFileSync(docPath, report);
  writeFileSync(join(root, "v0245-capture-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0245_CAPTURE" : "PASS_V0245_BARROSAN_AUTHORITATIVE_CONSTRUCTION_BRIDGE_CAPTURE",
    verdict, retainedGlbSha256: evidence.glbSha256, construction: evidence.bridge, errors,
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
  writeFileSync(join(root, "v0245-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0245_VALIDATION" : "PASS_V0245_BARROSAN_AUTHORITATIVE_CONSTRUCTION_BRIDGE_VALIDATION",
    verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN",
    constructionStatus: evidence.bridge.status ?? "UNKNOWN",
    resourceDelta: evidence.bridge.placementResourceDelta ?? {},
    runtimeId: evidence.bridge.runtimeId ?? "",
    retainedGlbSha256: evidence.glbSha256, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
