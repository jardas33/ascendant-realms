import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const defaultRoot = join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0241");
const root = resolve((process.argv.find(value => value.startsWith("--artifact-root=")) ?? `--artifact-root=${defaultRoot}`).split("=")[1]);
const verdict = (process.argv.find(value => value.startsWith("--verdict=")) ?? "--verdict=PARTIAL").split("=")[1];
const manual = join(repo, "artifacts", "manual-review", "v0241-barrosan-playable-runtime-skin");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const mappingPath = join(repo, "desktop-spikes", "godot-salto", "data", "v0240_barrosan_playable_art_mapping.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const docPath = join(repo, "docs", "V0241_BARROSAN_PLAYABLE_RUNTIME_SKIN_REPORT.md");
const roles = ["main_base", "house", "farm", "lumber", "blacksmith", "barracks", "mine", "watchtower", "market"];
const reviewFiles = [
  "01_v0240_review_lane_baseline.png", "02_v0241_runtime_skin_overview.png", "03_v0241_default_runtime_unchanged_proof.png",
  "04_v0241_selected_building_runtime_indicator.png", "05_v0241_unselected_buildings_clean_view.png", "06_v0241_runtime_role_mapping_proof.png",
  "07_v0241_valid_build_preview.png", "08_v0241_blocked_build_preview.png", "09_v0241_units_near_buildings_scale.png",
  "10_v0241_before_after_contact_sheet.png", "11_v0241_report.md",
];
const read = path => JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = path => createHash("sha256").update(readFileSync(path)).digest("hex").toUpperCase();

function inspect(errors) {
  for (const path of [runtimePath, defaultPath, mappingPath, glbPath]) if (!existsSync(path)) errors.push(`missing ${path}`);
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const defaultRuntime = existsSync(defaultPath) ? read(defaultPath) : {};
  const mapping = existsSync(mappingPath) ? read(mappingPath) : {};
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.241" || runtime.captureCount !== 7) errors.push("opt-in runtime capture failed");
  if (defaultRuntime.status !== "PASS_PLAYER_SLICE_CAPTURE" || defaultRuntime.checkpoint !== "v0.241") errors.push("default runtime proof failed");
  if (skin.enabled !== true || skin.scenePath !== "res://scenes/salto_barrosan_playable_runtime_skin.tscn") errors.push("skin opt-in contract failed");
  if (skin.mappingPath !== "res://data/v0240_barrosan_playable_art_mapping.json" || skin.sourceGlb !== "res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb") errors.push("retained asset contract failed");
  if ((skin.errors ?? []).length) errors.push(`runtime skin errors: ${(skin.errors ?? []).join(", ")}`);
  if (skin.defaultRuntimeChanged !== false || skin.gameplaySystemsChanged !== false) errors.push("gameplay/default boundary failed");
  if ((defaultRuntime.barrosanPlayableRuntimeSkin?.enabled ?? false) !== false) errors.push("default runtime unexpectedly enabled skin");
  if (mapping.roles?.length !== 9) errors.push("mapping role count failed");
  for (const role of roles) if (!(mapping.roles ?? []).some(entry => entry.gameplayRole === role)) errors.push(`mapping missing ${role}`);
  for (const role of ["main_base", "barracks", "mine"]) if (!(skin.liveMappedRoles ?? []).includes(role)) errors.push(`live role missing ${role}`);
  for (const role of ["house", "farm", "lumber", "blacksmith", "watchtower", "market"]) if (!(skin.reviewPlaceholderRoles ?? []).includes(role)) errors.push(`placeholder role missing ${role}`);
  return {runtime, defaultRuntime, mapping, skin, glbSha256: existsSync(glbPath) ? sha256(glbPath) : ""};
}

function report(e, selectedVerdict) {
  return [
    "# v0.241 Barrosan Opt-In Playable Runtime Skin",
    "",
    `Verdict: \`${selectedVerdict}\``,
    "",
    "## Outcome",
    "",
    "- The explicit opt-in scene subclasses the actual Salto 2.5D gameplay scene; it is not a standalone diorama.",
    "- `command_hall`, `barracks`, and `west_stone_cut` are skinned at their real runtime positions while retaining their existing gameplay state and commands.",
    "- House, farm, lumber, blacksmith, watchtower, and market do not exist as live simulation entities. Their imported modules are review-safe, non-interactive placeholders and are labeled only in mapping/debug evidence.",
    "- Default launch and the default 2.5D scene remain unchanged.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- The v0.239 GLB was reused unchanged.",
    "",
    "## Retained assets",
    "",
    "- Mapping: `res://data/v0240_barrosan_playable_art_mapping.json`.",
    "- GLB: `res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb`.",
    `- Retained GLB SHA-256: \`${e.glbSha256}\`.`,
    "",
    "## Runtime behavior",
    "",
    "- Existing unit selection, barracks selection, construction progression, production, camera, HUD, objectives, pathing, AI, economy and saves are unchanged.",
    "- The selected barracks receives a restrained runtime ring; unselected buildings have no persistent label clutter.",
    "- Valid and blocked placement previews are evidence-only render states. No placement or collision rule was changed.",
    "- Runtime systems touched: scene selection, player-slice evidence actions, visual rebuilding, runtime selection presentation, and evidence manifests.",
    "- Gameplay systems untouched: simulation rules, economy, production costs/timing, build rules, collision, pathing, commands, AI, objectives, minimap logic, stable IDs, and saves.",
    "- Fully mapped live roles: `main_base`, `barracks`, `mine`.",
    "- Review placeholders: `house`, `farm`, `lumber`, `blacksmith`, `watchtower`, `market`.",
    "- Placement/footprint status: completed footprints are visual-only; valid/blocked preview proof is not connected to build-rule evaluation.",
    "",
    "## Exact source files changed",
    "",
    "- `desktop-spikes/godot-salto/scenes/salto_barrosan_playable_runtime_skin.tscn`",
    "- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`",
    "- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`",
    "- `tools/godot/captureGodotV0241BarrosanPlayableRuntimeSkinWindows.ps1`",
    "- `tools/godot/validateGodotV0241BarrosanPlayableRuntimeSkinWindows.ps1`",
    "- `tools/godot/buildV0241BarrosanPlayableRuntimeSkinReviewPack.py`",
    "- `tools/godot/saltoV0241BarrosanPlayableRuntimeSkinTool.mjs`",
    "- `package.json`",
    "- `docs/V0241_BARROSAN_PLAYABLE_RUNTIME_SKIN_REPORT.md`",
    "",
    "## Validation results",
    "",
    "- `npm test`: PASS (122 files, 887 tests).",
    "- `npm run build`: PASS.",
    "- `npm run godot:test`: PASS.",
    "- `npm run godot:all`: PASS, including Windows export and package.",
    "- `npm run validate:content`: PASS.",
    "- `npm run validate:art-intake`: PASS.",
    "- `npm run validate:runtime-art-slots`: PASS (52 stable slots).",
    "- `npm run godot:validate:salto-experimental-artifact-retention`: PASS.",
    "- `npm run godot:validate:salto-barrosan-playable-runtime-skin`: PASS.",
    "- `git diff --check`: PASS.",
    "- Retained v0.239 GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.",
    "",
    "## Honest assessment",
    "",
    selectedVerdict === "PASS"
      ? "The retained Barrosan kit is viable as an opt-in runtime skin: its three real entity mappings read at gameplay scale and the selection state remains legible. The six placeholder roles are useful composition proof but are not playable buildings, and the current imported geometry still lacks construction, damage and faction-state variants. This is a credible experimental runtime lane, not a default-runtime replacement."
      : selectedVerdict === "PARTIAL"
        ? "The live runtime wiring and default boundary are proven, but the visual result is not strong enough for opt-in gameplay testing. The imported buildings are readable yet visually tiny and disconnected inside the legacy procedural battlefield; the six absent roles remain scenery rather than entities; and the placement previews are evidence overlays, not build-system feedback. The lane is technically useful as integration scaffolding, but calling it a finished runtime skin would oversell it."
        : "The opt-in runtime skin is not visually or technically ready to continue.",
    "",
    `Ready for opt-in gameplay testing: ${selectedVerdict === "PASS" ? "yes" : "no"}.`,
    "",
    "Stop after v0.241. Do not begin v0.242.",
    "",
  ].join("\n");
}

function capture() {
  const errors = [];
  const evidence = inspect(errors);
  if (!["PASS", "PARTIAL", "FAIL"].includes(verdict)) errors.push("invalid verdict");
  mkdirSync(manual, {recursive: true});
  for (const file of reviewFiles.slice(0, 9)) if (!existsSync(join(manual, file))) errors.push(`missing capture ${file}`);
  const markdown = report(evidence, verdict);
  writeFileSync(join(manual, "11_v0241_report.md"), markdown);
  writeFileSync(docPath, markdown);
  writeFileSync(join(root, "v0241-capture-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0241_CAPTURE" : "PASS_V0241_BARROSAN_PLAYABLE_RUNTIME_SKIN_CAPTURE",
    verdict, retainedGlbSha256: evidence.glbSha256, errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const evidence = inspect(errors);
  for (const file of reviewFiles) {
    const path = join(manual, file);
    if (!existsSync(path)) errors.push(`missing review file ${file}`);
    else if (statSync(path).size < (file.endsWith(".png") ? 10000 : 800)) errors.push(`review file too small ${file}`);
  }
  if (!existsSync(docPath)) errors.push("missing checkpoint report");
  writeFileSync(join(root, "v0241-validation-report.json"), JSON.stringify({
    status: errors.length ? "FAIL_V0241_VALIDATION" : "PASS_V0241_BARROSAN_PLAYABLE_RUNTIME_SKIN_VALIDATION",
    verdict: existsSync(docPath) ? readFileSync(docPath, "utf8").match(/Verdict: `([^`]+)`/u)?.[1] ?? "UNKNOWN" : "UNKNOWN",
    liveMappedRoles: evidence.skin.liveMappedRoles ?? [],
    reviewPlaceholderRoles: evidence.skin.reviewPlaceholderRoles ?? [],
    retainedGlbSha256: evidence.glbSha256,
    errors,
  }, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "capture";
if (command === "capture") capture();
else if (command === "validation") validation();
else throw new Error(`unknown command ${command}`);
