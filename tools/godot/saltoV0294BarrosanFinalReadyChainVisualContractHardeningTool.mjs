import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { join, resolve } from "node:path";

const repo = resolve(".");
const pack = join(repo, "artifacts/manual-review/v0294-barrosan-final-ready-chain-visual-contract-hardening");
const runtime = join(repo, "artifacts/desktop-spikes/godot-salto/v0293/reserve-final-release-ready-static-gate-runtime/screenshot-runtime-manifest.json");
const skin = join(repo, "desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd");
const expected = [
  "PRESSURE CHECKED", "ASHEN BRACED", "LINE HELD", "ASHEN CONTAINED", "RESERVE READY", "RESERVE ASSIGNED",
  "BRIDGE SIGNAL SENT", "SIGNAL SENT", "RESERVE ACK", "SUPPORT ORDER READY", "ORDER READY",
  "DEPLOYMENT APPROVED", "APPROVED", "LAUNCH ORDER STAGED", "LAUNCH STAGED", "FINAL RELEASE READY", "RELEASE READY"
];
const requiredV293 = [
  "v0293_release_ready_available", "v0293_release_ready_clicked", "v0293_final_release_ready_top_strip",
  "v0293_release_ready_marker_exactly_once", "v0293_defender_after_final_release_ready",
  "v0293_barracks_after_final_release_ready", "v0293_repeat_release_ready_idempotent",
  "v0293_no_global_prompt_inside_selected_card", "v0293_no_selected_card_button_overlap",
  "v0293_no_deployment_movement_pathing_route_preview"
];
const errors = [];
const packFiles = Array.from({ length: 47 }, (_, index) => join(pack, `${String(index + 1).padStart(2, "0")}_v0294_`));
for (const prefix of packFiles) if (!existsSync(pack) || !readdirSync(pack).some((name) => join(pack, name).startsWith(prefix))) errors.push(`missing review capture ${prefix.split("/").pop()}`);
if (!existsSync(runtime)) errors.push("missing retained v0.293 runtime manifest");
else {
  const manifest = JSON.parse(readFileSync(runtime, "utf8"));
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE" || manifest.captureCount < 13) errors.push("v0.293 capture manifest is not passing");
  for (const action of requiredV293) if (!manifest.captures?.some((capture) => capture.action === action)) errors.push(`missing v0.293 action ${action}`);
}
const source = readFileSync(skin, "utf8");
for (const label of expected) if (!source.includes(label)) errors.push(`accepted label missing: ${label}`);
for (const forbidden of ["Select Aster", "deployment", "movement", "pathing", "route preview"]) {
  if (forbidden === "Select Aster" && source.includes('hud_onboarding_label.text = "Select Aster')) errors.push("stale global onboarding prompt remains in selected-card contract");
}
if (!source.includes('snap["selectedCardTextOverlap"] = false') || !source.includes('snap["buttonRowBelowText"] = true') || !source.includes('snap["rawValidatorParagraphAbsent"] = true')) errors.push("selected-card layout contract incomplete");
if (!source.includes('snap["noDeploymentMovementPathingRoutePreview"] = true') || !source.includes('snap["noTrueDefaultRuntimeMutation"] = true')) errors.push("static/default-runtime boundary contract incomplete");
const changed = execFileSync("git", ["diff", "--name-only", "561611b7c6ef3f92fd1b0d0d3aafc2fd49ba5c5b", "91d250132c3a911a5cf5d86004f211d896e2fa64"], { cwd: repo, encoding: "utf8" }).trim().split(/\r?\n/).filter(Boolean);
const allowed = ["package.json", "tools/godot/validateGodotV0294BarrosanFinalReadyChainVisualContractHardeningWindows.ps1", "tools/godot/saltoV0294BarrosanFinalReadyChainVisualContractHardeningTool.mjs", "tools/godot/buildV0294BarrosanFinalReadyChainVisualContractHardeningPack.py", "docs/V0294_BARROSAN_FINAL_READY_CHAIN_VISUAL_CONTRACT_HARDENING_REPORT.md"];
for (const file of changed) if (!allowed.includes(file) && !file.startsWith("artifacts/manual-review/v0294-barrosan-final-ready-chain-visual-contract-hardening/")) errors.push(`out-of-scope runtime or gameplay change: ${file}`);
const report = { status: errors.length ? "FAIL_v0294_VALIDATION" : "PASS_v0294_BARROSAN_FINAL_READY_CHAIN_VISUAL_CONTRACT_HARDENING_VALIDATION", errors, baseHead: "561611b7c6ef3f92fd1b0d0d3aafc2fd49ba5c5b", acceptedLabels: expected, requiredCaptureCount: 47, runtimeChanged: changed.some((file) => file.startsWith("desktop-spikes/")) };
writeFileSync(join(pack, "v0294-validation-report.json"), JSON.stringify(report, null, 2) + "\n");
console.log(report.status);
if (errors.length) process.exit(1);
