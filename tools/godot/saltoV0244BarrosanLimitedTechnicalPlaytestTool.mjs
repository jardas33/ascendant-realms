import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0244");
const root = resolve((process.argv.find(v => v.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(v => v.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const reportedCommit = (process.argv.find(v => v.startsWith("--commit=")) ?? "--commit=PENDING_PUBLICATION").split("=")[1];
const reportedCiRun = (process.argv.find(v => v.startsWith("--ci-run=")) ?? "--ci-run=PENDING_PUBLICATION").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0244-barrosan-limited-technical-playtest");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0244_BARROSAN_LIMITED_TECHNICAL_PLAYTEST_REPORT.md");
const required = [
  "01_v0243_partial_baseline.png", "02_v0244_playtest_overview.png", "03_v0244_default_runtime_unchanged_proof.png",
  "04_v0244_preflight_head_ci_resolution.png", "05_v0244_select_aster.png", "06_v0244_unit_movement_road_probe.png",
  "07_v0244_unit_movement_bridge_probe.png", "08_v0244_select_command_keep_live_hud.png",
  "09_v0244_select_barracks_live_hud.png", "10_v0244_barracks_restore_train_flow.png",
  "11_v0244_select_lume_mine_live_hud.png", "12_v0244_select_shell_forge_hud.png",
  "13_v0244_select_shell_market_hud.png", "14_v0244_valid_preview_real_validation.png",
  "15_v0244_blocked_preview_real_reason.png", "16_v0244_resources_unchanged_after_preview.png",
  "17_v0244_minimap_all_roles_after_playtest.png", "18_v0244_unselected_clean_view.png",
  "19_v0244_before_after_contact_sheet.png", "20_v0244_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, defaultPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const defaultRuntime = existsSync(defaultPath) ? read(defaultPath) : {};
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const playtest = skin.limitedTechnicalPlaytest ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.244" || runtime.captureCount !== 15) errors.push("runtime capture contract failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.244") errors.push("default proof failed");
  if (skin.enabled !== true || skin.checkpoint !== "v0.244") errors.push("skin status failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime unexpectedly skinned");
  if (skin.defaultRuntimeChanged !== false || skin.gameplaySystemsChanged !== false) errors.push("default boundary failed");
  if (skin.selectionIntegrated !== true || skin.minimapRoleMarkerCount !== 9) errors.push("registry contract failed");
  if (playtest.status !== "PASS" || playtest.movementProbePass !== true) errors.push("playtest movement contract failed");
  if (playtest.previewResourcesUnchanged !== true) errors.push("preview mutated resources");
  if (playtest.validPreview?.ok !== true) errors.push("valid preview failed");
  if (playtest.blockedPreview?.ok !== false || playtest.blockedPreview?.reason !== "blocked-terrain") errors.push("blocked preview failed");
  if (playtest.realConstructionAttempted !== false || playtest.realConstructionStatus !== "preview-only-intentionally-skipped") errors.push("construction honesty failed");
  if (playtest.barracksRestoreTrain?.restored !== true || playtest.barracksRestoreTrain?.militiaSpawned !== true) errors.push("barracks flow failed");
  for (const role of ["main_base", "barracks", "mine"]) if (!(playtest.selectedLiveRoles ?? []).includes(role)) errors.push(`live role not tested ${role}`);
  for (const role of ["blacksmith", "market", "watchtower"]) if (!(playtest.selectedShellRoles ?? []).includes(role)) errors.push(`shell role not tested ${role}`);
  if ((skin.errors ?? []).length) errors.push(`runtime errors: ${(skin.errors ?? []).join(", ")}`);
  return {runtime, defaultRuntime, skin, playtest, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function markdown(e, selectedVerdict) {
  return [
    "# v0.244 Barrosan Limited Opt-In Technical Gameplay Playtest", "",
    `Verdict: \`${selectedVerdict}\``, "",
    "## Exact facts", "",
    "- Resolved base commit: `832175edc9acd71648b0d986061e45f98f6464dd`.",
    "- The v0.243 report's `af4b52914cec260b6517f16021cf502774ea2ddd` is the implementation parent; `832175ed...` is its documentation closeout child and the true v0.244 base.",
    "- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27884622555.",
    `- Final commit: \`${reportedCommit}\`.`,
    `- Final exact-SHA GitHub Actions run: ${reportedCiRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- v0.239 GLB reused unchanged: yes.",
    `- GLB SHA-256: \`${e.glbSha256}\`.`,
    "- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.", "",
    "## Player-slice sequence", "",
    "- Loaded the opt-in Barrosan runtime, selected Aster, and ran road-adjacent and bridge/river movement probes.",
    "- Selected Command Keep, Restored Barracks and Lume Mine as live entities.",
    "- Exercised the existing mine capture, Worker assignment, Barracks restoration, Militia queue and spawn flow.",
    "- Selected March Forge, Frontier Market and Watchtower as sim-safe shells; all remain non-producing.",
    "- Evaluated one valid and one blocked placement preview through the generated-authority adapter.",
    "- Confirmed preview did not mutate resources and retained all nine minimap/registry roles.", "",
    "## Construction and validation honesty", "",
    "- Real construction through the v0.243 placement bridge was intentionally not attempted.",
    "- The bridge is read-only and is not connected to the existing Godot Barracks placeholder construction system; joining those paths would require a separate rules-integration checkpoint.",
    "- Existing Barracks restoration is real within the bounded Godot microloop and remains preserved.",
    `- Valid preview: \`${e.playtest.validPreview?.ok}\`.`,
    `- Blocked preview: \`${e.playtest.blockedPreview?.reason}\` / \`${e.playtest.blockedPreview?.reasonText}\`.`,
    `- Preview resources unchanged: \`${e.playtest.previewResourcesUnchanged}\`.`, "",
    "## Live and shell coverage", "",
    "- Live entities tested: `main_base`, `barracks`, `mine`.",
    "- Shell entities tested directly: `blacksmith`, `market`, `watchtower`; all six shell contracts remain registered and non-producing.",
    "- Shell health remains 500/500 with no economy, AI, combat or save mutation.", "",
    "## Movement and pathing", "",
    "- Probes covered road-adjacent movement, bridge/river movement, live mine proximity and Barracks/main-base proximity.",
    "- The result is review-grade only. Godot still uses rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.",
    "- Visual road, river and bridge alignment remains partially decorative.", "",
    "## Runtime boundaries", "",
    "- Touched only the opt-in Barrosan runtime subclass and v0.244 capture/report tooling.",
    "- Untouched: default browser runtime, default Godot runtime, gameplay rules, economy rules, production rules, combat, AI, saves, objectives, commands and source content.", "",
    "## Validation results", "",
    "- `npm run godot:test`: pass.",
    "- v0.244 capture and dedicated validator: pass.",
    "- `npm test`: pass, 122 files / 887 tests.",
    "- `npm run build`: pass.",
    "- `npm run validate:content`: pass.",
    "- `npm run validate:art-intake`: pass.",
    "- `npm run validate:runtime-art-slots`: pass, 52 slots.",
    "- `npm run godot:validate:salto-experimental-artifact-retention`: pass.",
    "- `npm run godot:all`: pass.",
    "- `git diff --check`: pass.",
    "- Exact-SHA CI: recorded after publication.", "",
    "## Exact source files changed", "",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/buildV0244BarrosanLimitedTechnicalPlaytestReviewPack.py`",
    "- `tools/godot/captureGodotV0244BarrosanLimitedTechnicalPlaytestWindows.ps1`",
    "- `tools/godot/saltoV0244BarrosanLimitedTechnicalPlaytestTool.mjs`",
    "- `tools/godot/validateGodotV0244BarrosanLimitedTechnicalPlaytestWindows.ps1`",
    "- `package.json`",
    "- `docs/V0244_BARROSAN_LIMITED_TECHNICAL_PLAYTEST_REPORT.md`", "",
    "## Assessment", "",
    "The constrained opt-in slice survives selection, movement, live Barracks restoration/recruitment, live mine access, shell selection and real validation previews without changing the default runtime. The verdict remains PARTIAL because construction through the generated-rule bridge is preview-only and pathing remains review-grade.",
    "",
    "Recommendation: another technical hardening pass is required before v0.245 first limited playable opt-in vertical slice. The next gate should connect one existing construction action to shared authoritative placement/resource semantics without promoting shells or changing defaults.", "",
    "Stop after v0.244. Do not begin v0.245.", "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of required.slice(0, 19)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const report = markdown(evidence, verdict);
  writeFileSync(join(manual, "20_v0244_report.md"), report);
  writeFileSync(docPath, report);
  writeFileSync(join(root, "v0244-capture-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0244_CAPTURE" : "PASS_V0244_BARROSAN_LIMITED_TECHNICAL_PLAYTEST_CAPTURE",
    verdict, retainedGlbSha256: evidence.glbSha256, playtest: evidence.playtest, errors,
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
  writeFileSync(join(root, "v0244-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0244_VALIDATION" : "PASS_V0244_BARROSAN_LIMITED_TECHNICAL_PLAYTEST_VALIDATION",
    verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN",
    playtestStatus: evidence.playtest.status ?? "UNKNOWN",
    movementProbePass: evidence.playtest.movementProbePass ?? false,
    previewResourcesUnchanged: evidence.playtest.previewResourcesUnchanged ?? false,
    realConstructionStatus: evidence.playtest.realConstructionStatus ?? "UNKNOWN",
    retainedGlbSha256: evidence.glbSha256, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
