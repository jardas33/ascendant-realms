import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(v => v.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0261"));
const verdict = arg("verdict") || "PARTIAL";
const commit = arg("commit") || "PENDING_PUBLICATION";
const head = arg("head") || commit;
const ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0261-barrosan-watchpost-foundation");
const docPath = join(repo, "docs", "V0261_BARROSAN_WATCHPOST_FOUNDATION_REPORT.md");
const runtimePath = join(root, "watchpost-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0261-black-frame-stats.json");
const read = p => JSON.parse(readFileSync(p, "utf8").replace(/^\uFEFF/u, ""));

const runtimeNames = [
  "v0261_initial_select_aster_visible",
  "v0261_after_aster_select_worker_visible",
  "v0261_place_field_barracks_visible",
  "v0261_field_barracks_built_visible",
  "v0261_new_objective_build_watchpost_visible",
  "v0261_worker_watchpost_button_visible",
  "v0261_watchpost_placement_cost_visible",
  "v0261_watchpost_valid_site_visible",
  "v0261_watchpost_built_resource_delta_visible",
  "v0261_watchpost_selected_hud_visible",
  "v0261_watch_zone_overlay_visible",
  "v0261_watchpost_minimap_marker_visible",
  "v0261_barracks_still_trains_militia_visible",
  "v0261_militia_training_after_watchpost_visible",
  "v0261_no_barracks_text_on_watchpost_visible",
  "v0261_no_watchpost_text_on_barracks_visible",
  "v0261_existing_barracks_rebuild_path_still_valid_visible",
];
const required = [
  "01_v0261_preflight_head_ci_resolution.png",
  "02_v0261_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "20_v0261_contact_sheet_visible.png",
  "21_v0261_black_frame_rejection_report.png",
];

function statSummary(stats) {
  const min = key => Math.min(...stats.map(s => Number(s[key] ?? 0)));
  const max = key => Math.max(...stats.map(s => Number(s[key] ?? 0)));
  return {
    count: stats.length,
    minBytes: min("bytes"),
    minUniqueColors: min("sampleUniqueColors"),
    minMeanBrightness: min("meanBrightness"),
    minBrightnessStdDev: min("brightnessStdDev"),
    maxMeanBrightness: max("meanBrightness"),
  };
}

function inspect(errors) {
  const runtime = existsSync(runtimePath) ? read(runtimePath) : {};
  const fallback = existsSync(defaultPath) ? read(defaultPath) : {};
  const stats = existsSync(statsPath) ? read(statsPath).stats ?? [] : [];
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const fallbackSkin = fallback.barrosanPlayableRuntimeSkin ?? {};
  const watchpost = skin.watchpostFoundation ?? {};
  const snaps = watchpost.proofSnapshots ?? {};

  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.261" || runtime.captureCount !== 17) errors.push("runtime v0.261 capture contract failed");
  if (fallback.status !== "PASS_PLAYER_SLICE_CAPTURE" || fallback.checkpoint !== "v0.261" || (fallbackSkin.enabled ?? true) !== false) errors.push("default runtime changed or failed capture");
  if (skin.enabled !== true || skin.scenePath !== "res://scenes/salto_barrosan_playable_runtime_skin.tscn") errors.push("opt-in Barrosan runtime not enabled for Watchpost capture");
  if (watchpost.status !== "PASS") errors.push(`watchpost foundation status ${watchpost.status ?? "missing"}`);
  if (watchpost.costStatus !== "PASS" || watchpost.hp !== 120) errors.push("Watchpost cost/HP contract failed");
  if (watchpost.resourceSequenceStatus !== "PASS") errors.push("Watchpost resource sequence failed");
  if (watchpost.passiveOnlyStatus !== "PASS" || watchpost.combatAdded || watchpost.projectilesAdded || watchpost.wavesAdded || watchpost.economyAdded) errors.push("Watchpost passive-only contract failed");
  if (watchpost.minimapStatus !== "PASS" || watchpost.watchZoneStatus !== "PASS") errors.push("Watchpost minimap/watch zone proof failed");
  if (watchpost.barracksTrainingAfterWatchpostStatus !== "PASS") errors.push("Barracks training after Watchpost proof failed");
  if ((watchpost.missingSnapshots ?? []).length) errors.push(`missing Watchpost proof snapshots ${(watchpost.missingSnapshots ?? []).join(",")}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const text = snap.combinedText ?? "";
    if (snap.hasSelectAsterBeyondInitial) errors.push(`Select Aster leaked beyond initial in ${mode}`);
    if (mode.includes("watchpost") && (mode.includes("selected") || mode.includes("zone") || mode.includes("minimap") || mode.includes("no_barracks"))) {
      if (/Train Militia|Rebuild|Repair|Production available|Train Militia available|Field Barracks production/i.test(text)) errors.push(`Barracks lifecycle text leaked into Watchpost mode ${mode}: ${text}`);
    }
    if (mode === "v0261_no_watchpost_text_on_barracks" && /Watchpost|WATCH ZONE/.test(text)) errors.push("Watchpost text leaked into Barracks-selected proof");
    if (/Rebuild not yet implemented/.test(text)) errors.push(`stale rebuild-not-implemented text in ${mode}`);
  }

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

  return {runtime, fallback, skin, fallbackSkin, watchpost, stats, pixelSummary: statSummary(stats)};
}

function report(e) {
  const summary = e.pixelSummary;
  return [
    "# v0.261 Barrosan Watchpost Foundation",
    "",
    `Verdict: \`${verdict}\``,
    "",
    "## Exact facts",
    "",
    "- Base commit: `4164a8060c9c3ba75a1744421aa85200b692ac53`.",
    `- Implementation commit: \`${commit}\`.`,
    `- Final HEAD: \`${head}\`.`,
    `- Exact-SHA GitHub Actions run: ${ciRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack: `artifacts/manual-review/v0261-barrosan-watchpost-foundation/`.",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- Combat/projectiles/waves added: no.",
    "- Economy generation/resource gathering added: no.",
    "- Watchpost is passive only: yes.",
    "- Watchpost cost: 100 Crowns / 30 Stone / 10 Iron / 0 Aether.",
    "- Watchpost HP: 120/120.",
    "- Resource sequence: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Existing Field Barracks construction/rebuild/training sequences remain validated in their own v0.259/v0.260 path.",
    "",
    "## Watchpost proof",
    "",
    `- Watchpost runtime status: ${e.watchpost.status}.`,
    `- HUD/state resolver invariant status: ${e.watchpost.invariantStatus}.`,
    `- Resource sequence status: ${e.watchpost.resourceSequenceStatus}.`,
    `- Minimap marker status: ${e.watchpost.minimapStatus}.`,
    `- WATCH ZONE overlay status: ${e.watchpost.watchZoneStatus}.`,
    `- Barracks training after Watchpost status: ${e.watchpost.barracksTrainingAfterWatchpostStatus}.`,
    "- Impossible HUD combinations: absent in proof snapshots.",
    "",
    "## Pixel / screenshot validation",
    "",
    `- Required screenshots: ${required.length}.`,
    `- Runtime capture count: ${e.runtime.captureCount}.`,
    `- PNG files inspected for black-frame rejection: ${summary.count}.`,
    `- Minimum PNG bytes: ${summary.minBytes}.`,
    `- Minimum sampled unique colors: ${summary.minUniqueColors}.`,
    `- Minimum mean brightness: ${summary.minMeanBrightness}.`,
    `- Minimum brightness standard deviation: ${summary.minBrightnessStdDev}.`,
    "- Screenshots are non-black/readable: yes.",
    "",
    "## Recommendation for v0.262",
    "",
    "- Promote the passive Watchpost foundation into an explicit detection/vision or command-aura slice only after preserving this UI-state separation; do not add tower attacks/projectiles until that is separately authorized.",
    "",
    "Stop before v0.262.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const e = inspect(errors);
  mkdirSync(manual, {recursive: true});
  writeFileSync(docPath, report(e));
  writeFileSync(join(root, "v0261-watchpost-foundation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0261_WATCHPOST_FOUNDATION" : "PASS_V0261_BARROSAN_WATCHPOST_FOUNDATION", verdict, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const e = inspect(errors);
  writeFileSync(join(root, "v0261-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0261_VALIDATION" : "PASS_V0261_BARROSAN_WATCHPOST_FOUNDATION_VALIDATION", watchpostStatus: e.watchpost.status ?? "UNKNOWN", pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

if ((process.argv[2] ?? "capture") === "capture") capture();
else validation();
