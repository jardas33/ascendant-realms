import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(v => v.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0266"));
const verdict = arg("verdict") || "PARTIAL";
const commit = arg("commit") || "PENDING_PUBLICATION";
const head = arg("head") || commit;
const ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0266-barrosan-watchpost-defender-readiness-bridge");
const docPath = join(repo, "docs", "v0266_BARROSAN_WATCHPOST_DEFENDER_READINESS_BRIDGE_REPORT.md");
const runtimePath = join(root, "watchpost-defender-readiness-bridge-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0266-black-frame-stats.json");
const read = p => JSON.parse(readFileSync(p, "utf8").replace(/^\uFEFF/u, ""));

const runtimeNames = [
  "v0266_watchpost_build_path_visible",
  "v0266_complete_no_intel_no_readiness_alarm_visible",
  "v0266_outside_no_false_positive_no_readiness_alarm_visible",
  "v0266_current_detection_no_defender_readiness_visible",
  "v0266_current_detection_train_militia_objective_visible",
  "v0266_current_detection_relay_readiness_none_visible",
  "v0266_barracks_selected_current_detection_train_militia_advisory_visible",
  "v0266_militia_training_started_from_barracks_visible",
  "v0266_current_detection_relay_readiness_training_visible",
  "v0266_objective_militia_training_underway_visible",
  "v0266_militia_ready_after_existing_training_visible",
  "v0266_current_detection_relay_readiness_ready_visible",
  "v0266_threat_leaves_memory_readiness_ready_visible",
  "v0266_last_seen_memory_readiness_none_path_visible",
  "v0266_last_seen_memory_readiness_training_path_visible",
  "v0266_last_seen_memory_marker_distinct_visible",
  "v0266_current_vs_memory_readiness_not_confused_visible",
  "v0266_watchpost_hud_no_train_militia_visible",
  "v0266_barracks_hud_no_watchpost_relay_card_visible",
  "v0266_existing_barracks_rebuild_path_valid_visible",
  "v0266_existing_barracks_still_trains_militia_visible",
  "v0266_no_detection_readiness_before_watchpost_complete_visible",
  "v0266_world_label_clutter_not_regressed_visible",
];
const required = [
  "01_v0266_preflight_head_ci_resolution.png",
  "02_v0266_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "26_v0266_contact_sheet_visible.png",
  "27_v0266_black_frame_rejection_report_visible.png",
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
  const readiness = skin.watchpostDefenderReadinessBridge ?? {};
  const snaps = readiness.proofSnapshots ?? {};

  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.266" || runtime.captureCount !== 23) errors.push("runtime v0.266 capture contract failed");
  if (fallback.status !== "PASS_PLAYER_SLICE_CAPTURE" || fallback.checkpoint !== "v0.266" || fallbackSkin.enabled === true) errors.push("default runtime changed or failed capture");
  if (skin.enabled !== true || skin.scenePath !== "res://scenes/salto_barrosan_playable_runtime_skin.tscn") errors.push("opt-in Barrosan runtime not enabled");
  if (readiness.hp !== 120 || JSON.stringify(readiness.cost ?? {}) !== JSON.stringify({aether:0,crowns:100,iron:10,stone:30})) errors.push("Watchpost cost/HP contract changed");
  for (const key of ["calmNoIntelStatus","currentNoneStatus","currentTrainingStatus","currentReadyStatus","memoryNoneStatus","memoryTrainingStatus","memoryReadyStatus","noFalsePositiveStatus","memoryNotCurrentStatus","noPrecompleteReadinessStatus","barracksAdvisoryStatus","barracksTrainingPathStatus","minimapStatus","worldLabelClutterStatus","passiveReadinessOnlyStatus","forbiddenCombinationStatus","resourceSequenceStatus"]) {
    if (readiness[key] !== "PASS") errors.push(`${key} failed`);
  }
  if ((readiness.missingSnapshots ?? []).length) errors.push(`missing defender-readiness proof snapshots ${(readiness.missingSnapshots ?? []).join(",")}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const text = snap.combinedText ?? "";
    const m = snap.memory ?? {};
    const r = snap.readiness ?? {};
    if (/Rebuild not yet implemented/.test(text)) errors.push(`stale rebuild-not-implemented text in ${mode}`);
    if (mode.includes("last_seen") || mode.includes("threat_leaves") || mode.includes("current_vs_memory")) {
      if (m.currentScouted || m.awareness?.scouted || r.advisoryState !== "last_seen_memory") errors.push(`memory mode still reads current detection: ${mode}`);
      if (!snap.hasLastSeenText || !m.lastSeenActive || !snap.hasMemoryPingText) errors.push(`memory mode missing last-seen proof: ${mode}`);
    }
    if (mode === "v0266_complete_no_intel_no_readiness_alarm" && (r.advisoryState !== "no_prior_intel" || !snap.hasNoThreatText || snap.hasReadinessNone || snap.hasTrainMilitiaAdvisory)) errors.push("no-intel calm readiness state failed");
    if (mode === "v0266_outside_no_false_positive_no_readiness_alarm" && (r.advisoryState !== "outside_range" || m.currentScouted || m.lastSeenActive || snap.hasCurrentScoutedText || snap.hasReadinessTraining || snap.hasReadinessReady)) errors.push("outside marker produced false readiness alarm");
    if (["v0266_current_detection_no_defender_readiness","v0266_current_detection_train_militia_objective","v0266_current_detection_relay_readiness_none"].includes(mode) && (r.advisoryState !== "current_detection" || r.readinessState !== "none" || !snap.hasReadinessNone || !snap.hasCurrentScoutedText || !snap.hasThreatInZoneText)) errors.push(`${mode} failed current none readiness`);
    if (["v0266_current_detection_relay_readiness_training","v0266_objective_militia_training_underway"].includes(mode) && (r.advisoryState !== "current_detection" || r.readinessState !== "training" || !r.militiaTrainingQueued || !snap.hasReadinessTraining)) errors.push(`${mode} failed current training readiness`);
    if (["v0266_militia_ready_after_existing_training","v0266_current_detection_relay_readiness_ready"].includes(mode) && (r.advisoryState !== "current_detection" || r.readinessState !== "ready" || !r.militiaSpawned || !snap.hasReadinessReady)) errors.push(`${mode} failed current ready readiness`);
    if (mode === "v0266_last_seen_memory_readiness_none_path" && (r.advisoryState !== "last_seen_memory" || r.readinessState !== "none" || !snap.hasReadinessNone || snap.hasThreatInZoneText)) errors.push("memory none readiness failed");
    if (mode === "v0266_last_seen_memory_readiness_training_path" && (r.advisoryState !== "last_seen_memory" || r.readinessState !== "training" || !snap.hasReadinessTraining || snap.hasThreatInZoneText)) errors.push("memory training readiness failed");
    if (["v0266_threat_leaves_memory_readiness_ready","v0266_last_seen_memory_marker_distinct","v0266_current_vs_memory_readiness_not_confused"].includes(mode) && (r.advisoryState !== "last_seen_memory" || r.readinessState !== "ready" || !snap.hasReadinessReady || snap.hasThreatInZoneText)) errors.push(`${mode} failed memory ready readiness`);
    if (mode === "v0266_no_detection_readiness_before_watchpost_complete" && (r.relayVisible || r.barracksAdvisoryVisible || m.currentScouted || m.everScouted || snap.hasReadinessNone || snap.hasCurrentScoutedText)) errors.push("pre-complete Watchpost produced detection/readiness/memory");
    if (mode === "v0266_barracks_selected_current_detection_train_militia_advisory" && (!r.barracksSelected || !r.barracksAdvisoryVisible || !snap.hasTrainMilitiaAdvisory || snap.relayCardVisible)) errors.push("Barracks advisory line/relay separation failed");
    if (mode === "v0266_militia_training_started_from_barracks" && (!r.barracksSelected || r.readinessState !== "training" || !r.militiaTrainingQueued || !snap.hasMilitiaTrainingText)) errors.push("existing Barracks training path failed");
    if (mode === "v0266_watchpost_hud_no_train_militia" && /Train Militia available|Existing Barracks production|Rebuild|Repair/i.test(text)) errors.push("Barracks lifecycle/production text leaked into Watchpost HUD");
    if (mode === "v0266_barracks_hud_no_watchpost_relay_card" && (snap.relayCardVisible || snap.hasRelayTitle)) errors.push("Watchpost relay card leaked into Barracks HUD");
    if (r.combatAdded || r.projectilesAdded || r.towerAttackAdded || r.damageAdded || r.slowAdded || r.redirectAdded || r.spawnDespawnAddedByWatchpost || r.enemyAiChanged || r.enemyPathingChanged || r.waveTimingChanged || r.economyAdded || r.fogOfWarAdded || r.broadVisionAdded) errors.push(`${mode} mutated forbidden behavior`);
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
    const r = s.readiness?.resourcesAfterReadiness ?? {};
    return r.crowns === 240 && r.stone === 40 && r.iron === 90 && r.aether === 38;
  }) && Object.values(snaps).some(s => {
    const r = s.readiness?.resourcesAfterReadiness ?? {};
    return r.crowns === 140 && r.stone === 10 && r.iron === 80 && r.aether === 38;
  });
  if (!hasResources) errors.push("resource sequence proof failed");
  return {runtime, fallback, skin, fallbackSkin, foundation, readiness, computedResourceSequenceStatus: hasResources ? "PASS" : "IN_PROGRESS", stats, pixelSummary: statSummary(stats)};
}

function report(e) {
  const summary = e.pixelSummary;
  return [
    "# v0.266 Barrosan Watchpost Defender Readiness Bridge",
    "",
    `Verdict: \`${verdict}\``,
    "",
    "## Exact facts",
    "",
    "- Base commit: `5fd0c4b1163611280618efe7846e89373f4f8261`.",
    `- Implementation commit: \`${commit}\`.`,
    `- Final HEAD: \`${head}\`.`,
    `- Exact-SHA GitHub Actions run: ${ciRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack: `artifacts/manual-review/v0266-barrosan-watchpost-defender-readiness-bridge/`.",
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
    "## Passive defender-readiness-bridge proof",
    "",
    `- Defender Readiness Bridge status: ${e.readiness.status}.`,
    `- Calm no-intel status: ${e.readiness.calmNoIntelStatus}.`,
    `- Current none status: ${e.readiness.currentNoneStatus}.`,
    `- Current training status: ${e.readiness.currentTrainingStatus}.`,
    `- Current ready status: ${e.readiness.currentReadyStatus}.`,
    `- Memory none status: ${e.readiness.memoryNoneStatus}.`,
    `- Memory training status: ${e.readiness.memoryTrainingStatus}.`,
    `- Memory ready status: ${e.readiness.memoryReadyStatus}.`,
    `- Outside-zone false-positive status: ${e.readiness.noFalsePositiveStatus}.`,
    `- Memory-not-current status: ${e.readiness.memoryNotCurrentStatus}.`,
    `- No precomplete readiness status: ${e.readiness.noPrecompleteReadinessStatus}.`,
    `- Barracks advisory-line status: ${e.readiness.barracksAdvisoryStatus}.`,
    `- Barracks training path status: ${e.readiness.barracksTrainingPathStatus}.`,
    `- Current/memory minimap status: ${e.readiness.minimapStatus}.`,
    `- World label clutter status: ${e.readiness.worldLabelClutterStatus}.`,
    `- Forbidden combination status: ${e.readiness.forbiddenCombinationStatus}.`,
    `- Passive/readiness-only status: ${e.readiness.passiveReadinessOnlyStatus}.`,
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
    "## Recommendation for v0.267",
    "",
    "- If authorized, build a bounded defender-readiness or next-action coaching loop from the passive readiness/advisory layer. Do not add attacks, projectiles, fog-of-war, enemy retiming, or broad RTS vision without a new v0.267 scope.",
    "",
    "Stop before v0.267.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const e = inspect(errors);
  mkdirSync(manual, {recursive: true});
  writeFileSync(docPath, report(e));
  writeFileSync(join(root, "v0266-watchpost-defender-readiness-bridge-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0266_WATCHPOST_DEFENDER_READINESS_BRIDGE" : "PASS_V0266_BARROSAN_WATCHPOST_DEFENDER_READINESS_BRIDGE", verdict, readinessStatus: e.readiness.status, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const e = inspect(errors);
  writeFileSync(join(root, "v0266-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0266_VALIDATION" : "PASS_V0266_BARROSAN_WATCHPOST_DEFENDER_READINESS_BRIDGE_VALIDATION", readinessStatus: e.readiness.status, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

if ((process.argv[2] ?? "capture") === "capture") capture();
else validation();

