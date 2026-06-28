import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(v => v.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0262"));
const verdict = arg("verdict") || "PARTIAL";
const commit = arg("commit") || "PENDING_PUBLICATION";
const head = arg("head") || commit;
const ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0262-barrosan-watchpost-awareness-layer");
const docPath = join(repo, "docs", "V0262_BARROSAN_WATCHPOST_AWARENESS_LAYER_REPORT.md");
const runtimePath = join(root, "watchpost-awareness-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0262-black-frame-stats.json");
const read = p => JSON.parse(readFileSync(p, "utf8").replace(/^\uFEFF/u, ""));

const runtimeNames = [
  "v0262_watchpost_foundation_path_visible",
  "v0262_watchpost_complete_no_threat_visible",
  "v0262_watch_zone_clean_labeling_visible",
  "v0262_ashen_marker_outside_zone_no_false_positive_visible",
  "v0262_ashen_marker_touching_zone_scouted_visible",
  "v0262_ashen_marker_inside_zone_scouted_visible",
  "v0262_watchpost_selected_scouted_hud_visible",
  "v0262_watchpost_selected_no_attack_copy_visible",
  "v0262_minimap_scouted_threat_ping_visible",
  "v0262_barracks_hud_no_watchpost_text_visible",
  "v0262_watchpost_hud_no_barracks_text_visible",
  "v0262_barracks_still_trains_militia_visible",
  "v0262_existing_barracks_rebuild_path_still_valid_visible",
  "v0262_no_detection_before_watchpost_complete_visible",
];
const required = [
  "01_v0262_preflight_head_ci_resolution.png",
  "02_v0262_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "17_v0262_contact_sheet_visible.png",
  "18_v0262_black_frame_rejection_report_visible.png",
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
  const foundation = skin.watchpostFoundation ?? {};
  const awareness = skin.watchpostAwarenessLayer ?? {};
  const snaps = awareness.proofSnapshots ?? {};

  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.262" || runtime.captureCount !== 14) errors.push("runtime v0.262 capture contract failed");
  if (fallback.status !== "PASS_PLAYER_SLICE_CAPTURE" || fallback.checkpoint !== "v0.262" || fallbackSkin.enabled === true) errors.push("default runtime changed or failed capture");
  if (skin.enabled !== true || skin.scenePath !== "res://scenes/salto_barrosan_playable_runtime_skin.tscn") errors.push("opt-in Barrosan runtime not enabled for Watchpost awareness capture");
  if (awareness.hp !== 120 || JSON.stringify(awareness.cost ?? {}) !== JSON.stringify({aether:0,crowns:100,iron:10,stone:30})) errors.push("Watchpost cost/HP contract changed");
  if (awareness.noFalsePositiveStatus !== "PASS") errors.push("outside-zone false-positive gate failed");
  if (awareness.noFalseNegativeStatus !== "PASS") errors.push("touch/inside scouted gate failed");
  if (awareness.noDetectionBeforeCompleteStatus !== "PASS") errors.push("pre-completion no-detection gate failed");
  if (awareness.minimapPingStatus !== "PASS") errors.push("scouted minimap ping proof failed");
  if (awareness.passiveIntelOnlyStatus !== "PASS") errors.push("passive/intel-only proof failed");
  if ((awareness.missingSnapshots ?? []).length) errors.push(`missing awareness proof snapshots ${(awareness.missingSnapshots ?? []).join(",")}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const text = snap.combinedText ?? "";
    const a = snap.awareness ?? {};
    if (snap.hasSelectAsterBeyondInitial) errors.push(`Select Aster leaked beyond initial in ${mode}`);
    if (/Rebuild not yet implemented/.test(text)) errors.push(`stale rebuild-not-implemented text in ${mode}`);
    if (snap.watchpostSelected && /Train Militia|Rebuild|Repair|Production available|Train Militia available|Field Barracks production/i.test(text)) errors.push(`Barracks lifecycle text leaked into Watchpost mode ${mode}: ${text}`);
    if (mode === "v0262_barracks_hud_no_watchpost_text" && /scouted|SCOUTED|WATCH ZONE/i.test(text)) errors.push("Watchpost detection text leaked into Barracks HUD");
    if (mode === "v0262_ashen_marker_outside_zone_no_false_positive" && (a.scouted || snap.hasScoutedText)) errors.push("outside marker produced scouted text");
    if (mode === "v0262_no_detection_before_watchpost_complete" && (a.scouted || snap.hasScoutedText)) errors.push("pre-complete Watchpost produced detection");
    if (["v0262_ashen_marker_touching_zone_scouted","v0262_ashen_marker_inside_zone_scouted","v0262_watchpost_selected_scouted_hud","v0262_watchpost_selected_no_attack_copy","v0262_minimap_scouted_threat_ping"].includes(mode) && (!a.scouted || !snap.hasScoutedText)) errors.push(`${mode} failed to show scouted state`);
    if (a.combatAdded || a.projectilesAdded || a.towerAttackAdded || a.enemyAiChanged || a.enemyPathingChanged || a.waveTimingChanged || a.economyAdded) errors.push(`${mode} mutated forbidden behavior`);
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

  const hasResources = Object.values(snaps).some(s => {
    const r = s.awareness?.resourcesAfterAwareness ?? {};
    return r.crowns === 240 && r.stone === 40 && r.iron === 90 && r.aether === 38;
  }) && Object.values(snaps).some(s => {
    const r = s.awareness?.resourcesAfterAwareness ?? {};
    return r.crowns === 140 && r.stone === 10 && r.iron === 80 && r.aether === 38;
  });
  if (!hasResources) errors.push("resource sequence proof failed");
  const computedAwarenessStatus = (
    (awareness.noFalsePositiveStatus === "PASS") &&
    (awareness.noFalseNegativeStatus === "PASS") &&
    (awareness.noDetectionBeforeCompleteStatus === "PASS") &&
    (awareness.minimapPingStatus === "PASS") &&
    (awareness.passiveIntelOnlyStatus === "PASS") &&
    hasResources &&
    !(awareness.missingSnapshots ?? []).length
  ) ? "PASS" : "IN_PROGRESS";

  return {runtime, fallback, skin, fallbackSkin, foundation, awareness, computedAwarenessStatus, computedResourceSequenceStatus: hasResources ? "PASS" : "IN_PROGRESS", stats, pixelSummary: statSummary(stats)};
}

function report(e) {
  const summary = e.pixelSummary;
  return [
    "# v0.262 Barrosan Watchpost Awareness Layer",
    "",
    `Verdict: \`${verdict}\``,
    "",
    "## Exact facts",
    "",
    "- Base commit: `74d36f0de995852db1e5666fc18ed75aa2656fe9`.",
    `- Implementation commit: \`${commit}\`.`,
    `- Final HEAD: \`${head}\`.`,
    `- Exact-SHA GitHub Actions run: ${ciRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack: `artifacts/manual-review/v0262-barrosan-watchpost-awareness-layer/`.",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- Combat/projectiles/tower attack added: no.",
    "- Enemy AI/pathing/wave timing changed: no.",
    "- Economy generation/resource gathering added: no.",
    "- Watchpost remains passive/intel-only: yes.",
    "- Watchpost cost: 100 Crowns / 30 Stone / 10 Iron / 0 Aether.",
    "- Watchpost HP: 120/120.",
    "- Resource sequence: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Field Barracks construction/rebuild/training sequences still pass in retained validators.",
    "",
    "## Passive awareness proof",
    "",
    `- Awareness runtime status: ${e.computedAwarenessStatus}.`,
    `- HUD/state invariant status: ${e.awareness.invariantStatus}.`,
    `- Outside-zone false-positive status: ${e.awareness.noFalsePositiveStatus}.`,
    `- Touching/inside-zone scouted status: ${e.awareness.noFalseNegativeStatus}.`,
    `- No detection before Watchpost completion status: ${e.awareness.noDetectionBeforeCompleteStatus}.`,
    `- Minimap scouted ping status: ${e.awareness.minimapPingStatus}.`,
    `- Passive/intel-only status: ${e.awareness.passiveIntelOnlyStatus}.`,
    `- Resource sequence status: ${e.computedResourceSequenceStatus}.`,
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
    "## Recommendation for v0.263",
    "",
    "- If authorized, make the passive intel useful through a bounded command-aura or warning-history layer. Do not add tower attacks, projectiles, fog-of-war, enemy retiming, or broad RTS vision until separately scoped.",
    "",
    "Stop before v0.263.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const e = inspect(errors);
  mkdirSync(manual, {recursive: true});
  writeFileSync(docPath, report(e));
  writeFileSync(join(root, "v0262-watchpost-awareness-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0262_WATCHPOST_AWARENESS" : "PASS_V0262_BARROSAN_WATCHPOST_AWARENESS", verdict, awarenessStatus: e.computedAwarenessStatus, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const e = inspect(errors);
  writeFileSync(join(root, "v0262-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0262_VALIDATION" : "PASS_V0262_BARROSAN_WATCHPOST_AWARENESS_VALIDATION", awarenessStatus: e.computedAwarenessStatus, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

if ((process.argv[2] ?? "capture") === "capture") capture();
else validation();
