import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = resolve(".");
const runtimeRoot = join(repo, "artifacts/desktop-spikes/godot-salto/v0295/static-deployment-route-preview-gate-runtime");
const manualRoot = join(repo, "artifacts/manual-review/v0295-barrosan-static-deployment-route-preview-gate");
const manifestPath = join(runtimeRoot, "screenshot-runtime-manifest.json");
const skinPath = join(repo, "desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd");
const errors = [];
const requiredActions = ["v0295_preview_route_available", "v0295_preview_route_clicked", "v0295_route_preview_locked_top_strip", "v0295_route_preview_marker_exactly_once", "v0295_static_route_preview_visual", "v0295_barracks_after_route_preview_locked", "v0295_defender_after_route_preview_locked", "v0295_repeat_preview_route_idempotent", "v0295_no_duplicate_route_visual", "v0295_no_duplicate_route_marker", "v0295_no_deployment", "v0295_no_movement", "v0295_no_pathfinding_pathing", "v0295_no_economy_resource_mutation", "v0295_no_true_default_runtime_mutation"];
const requiredLabels = ["ROUTE PREVIEW LOCKED", "ROUTE PREVIEW", "Route preview available", "Route preview locked", "Awaiting explicit deployment order", "Bridge held | Route preview locked"];
if (!existsSync(manifestPath)) errors.push("missing v0.295 runtime manifest");
else {
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE" || manifest.captureCount !== 27) errors.push("v0.295 runtime capture did not produce 27 passing actions");
  for (const action of requiredActions) if (!manifest.captures?.some((capture) => capture.action === action)) errors.push(`missing action ${action}`);
  const proof = manifest.barrosanPlayableRuntimeSkin?.barrosanStaticDeploymentRoutePreviewGate?.proofSnapshots ?? {};
  const locked = proof.v0295_route_preview_locked_top_strip ?? {};
  for (const [key, expected] of [["routePreviewLockedStatusCount", 1], ["routePreviewMarkerCount", 1], ["routePreviewStaticSegmentCount", 5]]) if (locked[key] !== expected) errors.push(`static route proof failed: ${key}`);
  for (const key of ["routePreviewAuthoredStaticNotPathfinding", "noDeploymentMovementPathingRouteFollowing", "noCombatDamageHpLossProjectilesDeathDespawnAiWavesFogEconomyMutation", "noTrueDefaultRuntimeMutation", "asterStatic", "reserveMilitiaStatic", "defenderStatic", "v0292MessageFormatRetained", "buttonRowBelowText", "rawValidatorParagraphAbsent"]) if (locked[key] !== true) errors.push(`boundary proof failed: ${key}`);
}
const skin = readFileSync(skinPath, "utf8");
for (const label of requiredLabels) if (!skin.includes(label)) errors.push(`missing required label: ${label}`);
for (const forbidden of ["NavigationAgent", "AStar", "move_toward", "route_follow", "deploy_unit", "spawn_deployed"]) if (skin.slice(skin.indexOf("func _v0295_review_modes()"), skin.indexOf("func _v0264_reset_intel_relay()")).includes(forbidden)) errors.push(`forbidden dynamic system in v0.295 gate: ${forbidden}`);
if (skin.includes('hud_onboarding_label.text = "Select Aster')) errors.push("stale global Select Aster prompt remains");
if (!existsSync(manualRoot) || readdirSync(manualRoot).filter((name) => /^\d\d_v0295_.*\.png$/.test(name)).length !== 33) errors.push("v0.295 review pack is incomplete");
const report = {status: errors.length ? "FAIL_v0295_VALIDATION" : "PASS_v0295_BARROSAN_STATIC_DEPLOYMENT_ROUTE_PREVIEW_GATE_VALIDATION", errors, requiredActions, routeVisual: "five authored static segments", trueDefaultRuntimeChanged: false};
if (existsSync(manualRoot)) writeFileSync(join(manualRoot, "v0295-validation-report.json"), JSON.stringify(report, null, 2) + "\n");
console.log(report.status);
if (errors.length) process.exit(1);
