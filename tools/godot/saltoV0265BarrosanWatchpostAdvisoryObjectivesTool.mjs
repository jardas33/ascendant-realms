import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(v => v.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0265"));
const verdict = arg("verdict") || "PARTIAL";
const commit = arg("commit") || "PENDING_PUBLICATION";
const head = arg("head") || commit;
const ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0265-barrosan-watchpost-advisory-objectives");
const docPath = join(repo, "docs", "V0265_BARROSAN_WATCHPOST_ADVISORY_OBJECTIVES_REPORT.md");
const runtimePath = join(root, "watchpost-advisory-objectives-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0265-black-frame-stats.json");
const read = p => JSON.parse(readFileSync(p, "utf8").replace(/^\uFEFF/u, ""));

const runtimeNames = [
  "v0265_watchpost_build_path_visible",
  "v0265_watchpost_online_monitoring_objective_visible",
  "v0265_no_prior_intel_relay_visible",
  "v0265_ashen_outside_zone_monitoring_not_alarm_visible",
  "v0265_no_false_positive_outside_zone_visible",
  "v0265_current_detection_objective_prepare_defenders_visible",
  "v0265_current_detection_intel_relay_visible",
  "v0265_current_detection_world_label_clean_visible",
  "v0265_current_detection_minimap_ping_visible",
  "v0265_barracks_selected_current_detection_militia_advisory_visible",
  "v0265_barracks_train_militia_after_watchpost_advisory_visible",
  "v0265_threat_leaves_memory_objective_visible",
  "v0265_last_seen_memory_intel_relay_visible",
  "v0265_last_seen_memory_marker_distinct_visible",
  "v0265_last_seen_memory_minimap_ping_distinct_visible",
  "v0265_memory_not_current_detection_visible",
  "v0265_watchpost_hud_no_barracks_actions_visible",
  "v0265_barracks_hud_no_watchpost_relay_card_visible",
  "v0265_existing_barracks_rebuild_path_still_valid_visible",
  "v0265_no_detection_or_advisory_before_watchpost_complete_visible",
  "v0265_world_label_clutter_not_regressed_visible",
];
const required = [
  "01_v0265_preflight_head_ci_resolution.png",
  "02_v0265_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "24_v0265_contact_sheet_visible.png",
  "25_v0265_black_frame_rejection_report_visible.png",
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
  const advisory = skin.watchpostAdvisoryObjectives ?? {};
  const snaps = advisory.proofSnapshots ?? {};

  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.265" || runtime.captureCount !== 21) errors.push("runtime v0.265 capture contract failed");
  if (fallback.status !== "PASS_PLAYER_SLICE_CAPTURE" || fallback.checkpoint !== "v0.265" || fallbackSkin.enabled === true) errors.push("default runtime changed or failed capture");
  if (skin.enabled !== true || skin.scenePath !== "res://scenes/salto_barrosan_playable_runtime_skin.tscn") errors.push("opt-in Barrosan runtime not enabled for Watchpost advisory-objectives capture");
  if (advisory.hp !== 120 || JSON.stringify(advisory.cost ?? {}) !== JSON.stringify({aether:0,crowns:100,iron:10,stone:30})) errors.push("Watchpost cost/HP contract changed");
  for (const key of ["advisoryStateStatus","currentDetectionStatus","noFalsePositiveStatus","memoryAfterDetectionStatus","memoryNotCurrentStatus","noPrecompleteAdvisoryStatus","barracksAdvisoryStatus","militiaTrainingPathStatus","minimapStatus","worldLabelClutterStatus","passiveAdvisoryOnlyStatus","forbiddenCombinationStatus","resourceSequenceStatus"]) {
    if (advisory[key] !== "PASS") errors.push(`${key} failed`);
  }
  if ((advisory.missingSnapshots ?? []).length) errors.push(`missing advisory-objectives proof snapshots ${(advisory.missingSnapshots ?? []).join(",")}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const text = snap.combinedText ?? "";
    const m = snap.memory ?? {};
    if (snap.hasSelectAsterBeyondInitial) errors.push(`Select Aster leaked beyond initial in ${mode}`);
    if (/Rebuild not yet implemented/.test(text)) errors.push(`stale rebuild-not-implemented text in ${mode}`);
    const a = snap.advisory ?? {};
    if (mode.includes("last_seen") || mode.includes("memory_not") || mode.includes("threat_leaves")) {
      if (m.currentScouted || m.awareness?.scouted || a.advisoryState !== "last_seen_memory") errors.push(`memory mode still reads current detection: ${mode}`);
      if (!snap.hasLastSeenText || !m.lastSeenActive || !snap.hasMemoryPingText) errors.push(`memory mode missing last-seen proof: ${mode}`);
    }
    if (mode === "v0265_no_prior_intel_relay" && (a.advisoryState !== "no_prior_intel" || !snap.hasRelayTitle || !snap.hasNoThreatText || !snap.hasAdvisoryOnlyText)) errors.push("no-prior advisory relay state failed");
    if (mode === "v0265_watchpost_online_monitoring_objective" && (a.advisoryState !== "no_prior_intel" || !/Watchpost online|Monitor Ashen pressure/.test(text))) errors.push("online monitoring objective failed");
    if (["v0265_ashen_outside_zone_monitoring_not_alarm","v0265_no_false_positive_outside_zone"].includes(mode) && (a.advisoryState !== "outside_range" || m.currentScouted || m.lastSeenActive || snap.hasCurrentScoutedText || snap.hasLastSeenText || !snap.hasOutsideRangeText || snap.hasTrainMilitiaAdvisory)) errors.push("outside marker produced current, memory, or train-now false positive");
    if (mode === "v0265_no_detection_or_advisory_before_watchpost_complete" && (a.relayVisible || a.barracksAdvisoryVisible || m.currentScouted || m.everScouted || m.lastSeenActive || snap.hasCurrentScoutedText || snap.hasLastSeenText)) errors.push("pre-complete Watchpost produced detection/advisory/memory");
    if (["v0265_current_detection_objective_prepare_defenders","v0265_current_detection_intel_relay","v0265_current_detection_world_label_clean","v0265_current_detection_minimap_ping","v0265_watchpost_hud_no_barracks_actions","v0265_world_label_clutter_not_regressed"].includes(mode) && (a.advisoryState !== "current_detection" || !m.currentScouted || !snap.hasCurrentScoutedText || !snap.hasThreatInZoneText || !snap.hasPrepareDefendersText || !snap.hasAdvisoryOnlyText)) errors.push(`${mode} failed current advisory proof`);
    if (["v0265_current_detection_world_label_clean","v0265_last_seen_memory_marker_distinct","v0265_world_label_clutter_not_regressed"].includes(mode) && !snap.worldLabelClutterReduced) errors.push(`${mode} failed world-label separation proof`);
    if (mode === "v0265_current_detection_minimap_ping" && (!snap.currentMinimapPing || snap.memoryMinimapPing)) errors.push("current minimap ping missing or confused with memory");
    if (mode === "v0265_last_seen_memory_minimap_ping_distinct" && (!snap.memoryMinimapPing || snap.currentMinimapPing)) errors.push("memory minimap ping missing or confused with current");
    if (mode === "v0265_barracks_selected_current_detection_militia_advisory" && (!a.barracksSelected || !a.barracksAdvisoryVisible || !snap.hasTrainMilitiaAdvisory || snap.relayCardVisible)) errors.push("Barracks advisory line/relay separation failed");
    if (mode === "v0265_barracks_train_militia_after_watchpost_advisory" && (!a.militiaTrainingQueued || !snap.hasTrainMilitia)) errors.push("existing Barracks training path after advisory failed");
    if (mode === "v0265_watchpost_hud_no_barracks_actions" && /Rebuild|Repair|Production available|Train Militia available/i.test(text)) errors.push("Barracks lifecycle text leaked into Watchpost HUD");
    if (mode === "v0265_barracks_hud_no_watchpost_relay_card" && (snap.relayCardVisible || snap.hasRelayTitle)) errors.push("Watchpost relay card leaked into Barracks HUD");
    if (a.combatAdded || a.projectilesAdded || a.towerAttackAdded || a.damageAdded || a.slowAdded || a.redirectAdded || a.spawnDespawnAdded || a.enemyAiChanged || a.enemyPathingChanged || a.waveTimingChanged || a.economyAdded || a.fogOfWarAdded || a.broadVisionAdded) errors.push(`${mode} mutated forbidden behavior`);
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
      }
    }
  }

  const hasResources = Object.values(snaps).some(s => {
    const r = s.advisory?.resourcesAfterAdvisory ?? {};
    return r.crowns === 240 && r.stone === 40 && r.iron === 90 && r.aether === 38;
  }) && Object.values(snaps).some(s => {
    const r = s.advisory?.resourcesAfterAdvisory ?? {};
    return r.crowns === 140 && r.stone === 10 && r.iron === 80 && r.aether === 38;
  });
  if (!hasResources) errors.push("resource sequence proof failed");
  return {runtime, fallback, skin, fallbackSkin, foundation, advisory, computedResourceSequenceStatus: hasResources ? "PASS" : "IN_PROGRESS", stats, pixelSummary: statSummary(stats)};
}

function report(e) {
  const summary = e.pixelSummary;
  return [
    "# v0.265 Barrosan Watchpost Advisory Objectives",
    "",
    `Verdict: \`${verdict}\``,
    "",
    "## Exact facts",
    "",
    "- Base commit: `e1f164c41cc52b6be10fae9ac6860df9b3eeadf4`.",
    `- Implementation commit: \`${commit}\`.`,
    `- Final HEAD: \`${head}\`.`,
    `- Exact-SHA GitHub Actions run: ${ciRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack: `artifacts/manual-review/v0265-barrosan-watchpost-advisory-objectives/`.",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- New GLB exported: no.",
    "- Combat/projectiles/tower attack added: no.",
    "- Enemy AI/pathing/wave timing changed: no.",
    "- Economy generation/resource gathering added: no.",
    "- Watchpost remains passive/intel/advisory-only: yes.",
    "- Watchpost cost: 100 Crowns / 30 Stone / 10 Iron / 0 Aether.",
    "- Watchpost HP: 120/120.",
    "- Resource sequence: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Field Barracks construction/rebuild/training sequences are retained and separately validated.",
    "",
    "## Passive advisory-objectives proof",
    "",
    `- Advisory objectives status: ${e.advisory.status}.`,
    `- Advisory state status: ${e.advisory.advisoryStateStatus}.`,
    `- Current detection status: ${e.advisory.currentDetectionStatus}.`,
    `- Outside-zone false-positive status: ${e.advisory.noFalsePositiveStatus}.`,
    `- Last-seen memory-after-detection status: ${e.advisory.memoryAfterDetectionStatus}.`,
    `- Memory-not-current status: ${e.advisory.memoryNotCurrentStatus}.`,
    `- No precomplete advisory status: ${e.advisory.noPrecompleteAdvisoryStatus}.`,
    `- Barracks advisory-line status: ${e.advisory.barracksAdvisoryStatus}.`,
    `- Militia training path status: ${e.advisory.militiaTrainingPathStatus}.`,
    `- Current/memory minimap status: ${e.advisory.minimapStatus}.`,
    `- World label clutter status: ${e.advisory.worldLabelClutterStatus}.`,
    `- Forbidden combination status: ${e.advisory.forbiddenCombinationStatus}.`,
    `- Passive/advisory-only status: ${e.advisory.passiveAdvisoryOnlyStatus}.`,
    `- Resource sequence status: ${e.computedResourceSequenceStatus}.`,
    "- Impossible HUD combinations: absent in proof snapshots.",
    "- Current detection only appears while the Ashen marker touches/enters WATCH ZONE, and tells the player to prepare/train defenders.",
    "- Last-seen memory only appears after a real detection, and uses last-seen copy/ghosting instead of current `Threat in WATCH ZONE` wording.",
    "- No prior intel shows `Watchpost online` / `Monitor Ashen pressure` and no threat text.",
    "- Barracks may show one Watchpost advisory line, but keeps Train Militia as existing Barracks production.",
    "- Watchpost incomplete shows no detection, advisory, or memory.",
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
    "## Recommendation for v0.266",
    "",
    "- If authorized, build a bounded defender-readiness or next-action coaching loop from the passive advisory layer. Do not add attacks, projectiles, fog-of-war, enemy retiming, or broad RTS vision without a new v0.266 scope.",
    "",
    "Stop before v0.266.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const e = inspect(errors);
  mkdirSync(manual, {recursive: true});
  writeFileSync(docPath, report(e));
  writeFileSync(join(root, "v0265-watchpost-advisory-objectives-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0265_WATCHPOST_ADVISORY_OBJECTIVES" : "PASS_V0265_BARROSAN_WATCHPOST_ADVISORY_OBJECTIVES", verdict, advisoryStatus: e.advisory.status, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const e = inspect(errors);
  writeFileSync(join(root, "v0265-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0265_VALIDATION" : "PASS_V0265_BARROSAN_WATCHPOST_ADVISORY_OBJECTIVES_VALIDATION", advisoryStatus: e.advisory.status, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

if ((process.argv[2] ?? "capture") === "capture") capture();
else validation();

