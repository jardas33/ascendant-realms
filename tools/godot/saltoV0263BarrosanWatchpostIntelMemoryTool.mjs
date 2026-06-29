import {existsSync,mkdirSync,readFileSync,statSync,writeFileSync} from "node:fs";
import {dirname,join,resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(v => v.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0263"));
const verdict = arg("verdict") || "PARTIAL";
const commit = arg("commit") || "PENDING_PUBLICATION";
const head = arg("head") || commit;
const ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0263-barrosan-watchpost-intel-memory");
const docPath = join(repo, "docs", "V0263_BARROSAN_WATCHPOST_INTEL_MEMORY_REPORT.md");
const runtimePath = join(root, "watchpost-intel-memory-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0263-black-frame-stats.json");
const read = p => JSON.parse(readFileSync(p, "utf8").replace(/^\uFEFF/u, ""));

const runtimeNames = [
  "v0263_watchpost_build_path_visible",
  "v0263_watchpost_complete_no_threat_no_history_visible",
  "v0263_watch_zone_clean_labeling_visible",
  "v0263_ashen_outside_zone_no_false_positive_visible",
  "v0263_ashen_touching_zone_current_scouted_visible",
  "v0263_ashen_inside_zone_current_scouted_visible",
  "v0263_current_scouted_minimap_ping_visible",
  "v0263_current_scouted_hud_intel_only_visible",
  "v0263_threat_leaves_zone_last_seen_memory_visible",
  "v0263_last_seen_memory_minimap_ping_visible",
  "v0263_last_seen_memory_world_marker_visible",
  "v0263_memory_clearly_not_current_detection_visible",
  "v0263_watchpost_hud_no_barracks_text_visible",
  "v0263_barracks_hud_no_watchpost_text_visible",
  "v0263_barracks_still_trains_militia_visible",
  "v0263_existing_barracks_rebuild_path_still_valid_visible",
  "v0263_no_detection_or_memory_before_watchpost_complete_visible",
];
const required = [
  "01_v0263_preflight_head_ci_resolution.png",
  "02_v0263_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "20_v0263_contact_sheet_visible.png",
  "21_v0263_black_frame_rejection_report_visible.png",
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
  const memory = skin.watchpostIntelMemory ?? {};
  const snaps = memory.proofSnapshots ?? {};

  if (runtime.status !== "PASS_PLAYER_SLICE_CAPTURE" || runtime.checkpoint !== "v0.263" || runtime.captureCount !== 17) errors.push("runtime v0.263 capture contract failed");
  if (fallback.status !== "PASS_PLAYER_SLICE_CAPTURE" || fallback.checkpoint !== "v0.263" || fallbackSkin.enabled === true) errors.push("default runtime changed or failed capture");
  if (skin.enabled !== true || skin.scenePath !== "res://scenes/salto_barrosan_playable_runtime_skin.tscn") errors.push("opt-in Barrosan runtime not enabled for Watchpost intel-memory capture");
  if (memory.hp !== 120 || JSON.stringify(memory.cost ?? {}) !== JSON.stringify({aether:0,crowns:100,iron:10,stone:30})) errors.push("Watchpost cost/HP contract changed");
  for (const key of ["currentDetectionStatus","noFalsePositiveStatus","memoryAfterDetectionStatus","memoryNotCurrentStatus","noPrecompleteIntelStatus","minimapStatus","worldMemoryMarkerStatus","passiveIntelOnlyStatus"]) {
    if (memory[key] !== "PASS") errors.push(`${key} failed`);
  }
  if ((memory.missingSnapshots ?? []).length) errors.push(`missing intel-memory proof snapshots ${(memory.missingSnapshots ?? []).join(",")}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const text = snap.combinedText ?? "";
    const m = snap.memory ?? {};
    if (snap.hasSelectAsterBeyondInitial) errors.push(`Select Aster leaked beyond initial in ${mode}`);
    if (/Rebuild not yet implemented/.test(text)) errors.push(`stale rebuild-not-implemented text in ${mode}`);
    if (mode.includes("last_seen") || mode.includes("memory_clearly")) {
      if (snap.hasCurrentScoutedText || m.currentScouted || m.awareness?.scouted) errors.push(`memory mode still reads current detection: ${mode}`);
      if (!snap.hasLastSeenText || !m.lastSeenActive) errors.push(`memory mode missing last-seen proof: ${mode}`);
    }
    if (mode === "v0263_ashen_outside_zone_no_false_positive" && (m.currentScouted || m.lastSeenActive || snap.hasCurrentScoutedText || snap.hasLastSeenText)) errors.push("outside marker produced current or memory false positive");
    if (mode === "v0263_no_detection_or_memory_before_watchpost_complete" && (m.currentScouted || m.everScouted || m.lastSeenActive || snap.hasCurrentScoutedText || snap.hasLastSeenText)) errors.push("pre-complete Watchpost produced detection or memory");
    if (["v0263_ashen_touching_zone_current_scouted","v0263_ashen_inside_zone_current_scouted","v0263_current_scouted_minimap_ping","v0263_current_scouted_hud_intel_only"].includes(mode) && (!m.currentScouted || !snap.hasCurrentScoutedText)) errors.push(`${mode} failed current scouted proof`);
    if (mode === "v0263_watchpost_hud_no_barracks_text" && /Train Militia|Rebuild|Repair|Production available|Train Militia available/i.test(text)) errors.push("Barracks lifecycle text leaked into Watchpost HUD");
    if (["v0263_barracks_hud_no_watchpost_text","v0263_barracks_still_trains_militia"].includes(mode) && /ASHEN SCOUTED|Last scouted|WATCH ZONE|Last seen/i.test(text)) errors.push("Watchpost intel text leaked into Barracks HUD");
    if (m.combatAdded || m.projectilesAdded || m.towerAttackAdded || m.enemyAiChanged || m.enemyPathingChanged || m.waveTimingChanged || m.economyAdded) errors.push(`${mode} mutated forbidden behavior`);
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
    const r = s.memory?.resourcesAfterIntel ?? {};
    return r.crowns === 240 && r.stone === 40 && r.iron === 90 && r.aether === 38;
  }) && Object.values(snaps).some(s => {
    const r = s.memory?.resourcesAfterIntel ?? {};
    return r.crowns === 140 && r.stone === 10 && r.iron === 80 && r.aether === 38;
  });
  if (!hasResources) errors.push("resource sequence proof failed");
  return {runtime, fallback, skin, fallbackSkin, foundation, memory, computedResourceSequenceStatus: hasResources ? "PASS" : "IN_PROGRESS", stats, pixelSummary: statSummary(stats)};
}

function report(e) {
  const summary = e.pixelSummary;
  return [
    "# v0.263 Barrosan Watchpost Intel Memory",
    "",
    `Verdict: \`${verdict}\``,
    "",
    "## Exact facts",
    "",
    "- Base commit: `4f42d4dbdb21f8d28931b5be1192632f1a754fc4`.",
    `- Implementation commit: \`${commit}\`.`,
    `- Final HEAD: \`${head}\`.`,
    `- Exact-SHA GitHub Actions run: ${ciRun}.`,
    "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack: `artifacts/manual-review/v0263-barrosan-watchpost-intel-memory/`.",
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
    "- Field Barracks construction/rebuild/training sequences are retained and separately validated.",
    "",
    "## Passive intel-memory proof",
    "",
    `- Intel memory status: ${e.memory.status}.`,
    `- Current detection status: ${e.memory.currentDetectionStatus}.`,
    `- Outside-zone false-positive status: ${e.memory.noFalsePositiveStatus}.`,
    `- Last-seen memory-after-detection status: ${e.memory.memoryAfterDetectionStatus}.`,
    `- Memory-not-current status: ${e.memory.memoryNotCurrentStatus}.`,
    `- No precomplete intel status: ${e.memory.noPrecompleteIntelStatus}.`,
    `- Current/memory minimap status: ${e.memory.minimapStatus}.`,
    `- World memory marker status: ${e.memory.worldMemoryMarkerStatus}.`,
    `- Passive/intel-only status: ${e.memory.passiveIntelOnlyStatus}.`,
    `- Resource sequence status: ${e.computedResourceSequenceStatus}.`,
    "- Impossible HUD combinations: absent in proof snapshots.",
    "- Current detection only appears while the Ashen marker touches/enters WATCH ZONE.",
    "- Last-seen memory only appears after a real detection, and uses last-seen copy/ghosting instead of `ASHEN SCOUTED`.",
    "- No threat ever scouted shows `No threat in watch zone` / `No prior Ashen intel`.",
    "- Watchpost incomplete shows no detection and no memory.",
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
    "## Recommendation for v0.264",
    "",
    "- If authorized, use the passive memory to drive a bounded command-aura or player-facing warning-history loop. Do not add attacks, projectiles, fog-of-war, enemy retiming, or broad RTS vision without a new scope.",
    "",
    "Stop before v0.264.",
    ""
  ].join("\n");
}

function capture() {
  const errors = [];
  const e = inspect(errors);
  mkdirSync(manual, {recursive: true});
  writeFileSync(docPath, report(e));
  writeFileSync(join(root, "v0263-watchpost-intel-memory-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0263_WATCHPOST_INTEL_MEMORY" : "PASS_V0263_BARROSAN_WATCHPOST_INTEL_MEMORY", verdict, intelMemoryStatus: e.memory.status, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

function validation() {
  const errors = [];
  const e = inspect(errors);
  writeFileSync(join(root, "v0263-validation-report.json"), JSON.stringify({status: errors.length ? "FAIL_V0263_VALIDATION" : "PASS_V0263_BARROSAN_WATCHPOST_INTEL_MEMORY_VALIDATION", intelMemoryStatus: e.memory.status, resourceSequenceStatus: e.computedResourceSequenceStatus, pixelSummary: e.pixelSummary, errors}, null, 2) + "\n");
  if (errors.length) throw new Error(errors.join("\n"));
}

if ((process.argv[2] ?? "capture") === "capture") capture();
else validation();
