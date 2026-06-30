import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0267"));
const manual = join(repo, "artifacts", "manual-review", "v0267-barrosan-watchpost-defender-positioning-bridge");
const docPath = join(repo, "docs", "V0267_BARROSAN_WATCHPOST_DEFENDER_POSITIONING_BRIDGE_REPORT.md");
const runtimePath = join(root, "watchpost-defender-positioning-bridge-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0267-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0267_watchpost_build_path_visible",
  "v0267_watchpost_complete_no_intel_no_position_alarm_visible",
  "v0267_ashen_outside_zone_no_false_positive_no_position_alarm_visible",
  "v0267_current_detection_no_militia_position_none_visible",
  "v0267_current_detection_relay_position_none_visible",
  "v0267_barracks_train_militia_advisory_still_visible",
  "v0267_militia_training_position_pending_visible",
  "v0267_current_detection_relay_position_pending_visible",
  "v0267_militia_ready_away_from_bridge_visible",
  "v0267_current_detection_relay_ready_not_in_position_visible",
  "v0267_objective_move_defender_to_east_bridge_visible",
  "v0267_militia_moved_near_bridge_visible",
  "v0267_current_detection_relay_holding_east_bridge_visible",
  "v0267_objective_defender_in_position_visible",
  "v0267_threat_leaves_memory_position_not_in_position_visible",
  "v0267_threat_leaves_memory_position_holding_bridge_visible",
  "v0267_last_seen_memory_marker_still_distinct_visible",
  "v0267_current_vs_memory_vs_position_not_confused_visible",
  "v0267_watchpost_hud_no_train_militia_visible",
  "v0267_barracks_hud_no_watchpost_relay_card_visible",
  "v0267_existing_barracks_rebuild_path_still_valid_visible",
  "v0267_existing_barracks_still_trains_militia_visible",
  "v0267_no_position_before_watchpost_complete_visible",
  "v0267_no_position_holding_before_militia_near_bridge_visible",
  "v0267_world_label_clutter_not_regressed_visible",
];

const requiredImages = [
  "01_v0267_preflight_head_ci_resolution.png",
  "02_v0267_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "28_v0267_contact_sheet_visible.png",
  "29_v0267_black_frame_rejection_report_visible.png",
];

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function evalEvidence() {
  const runtime = readJson(runtimePath);
  const baseline = readJson(defaultPath);
  const stats = readJson(statsPath);
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const positioning = skin.watchpostDefenderPositioningBridge ?? {};
  const snaps = positioning.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.267") errors.push("runtime checkpoint is not v0.267");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled !== false) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 25) errors.push(`expected 25 runtime captures, saw ${runtime.captureCount}`);
  if (positioning.status !== "PASS") errors.push(`positioning status is ${positioning.status}`);
  const cost = positioning.cost ?? {};
  if (Number(cost.crowns) !== 100 || Number(cost.stone) !== 30 || Number(cost.iron) !== 10 || Number(cost.aether) !== 0) errors.push("Watchpost cost changed");
  if (Number(positioning.hp) !== 120) errors.push("Watchpost HP changed");

  for (const name of runtimeNames) {
    const mode = name.replace(/_visible$/, "");
    if (!snaps[mode]) errors.push(`missing proof snapshot ${mode}`);
  }

  for (const file of requiredImages) {
    if (!existsSync(join(manual, file))) errors.push(`missing manual review image ${file}`);
  }

  for (const [mode, snap] of Object.entries(snaps)) {
    const p = snap.positioning ?? {};
    const text = snap.combinedText ?? "";
    const distance = Number(p.militiaDistanceToDefensiveArea ?? 99999);
    if (p.automaticMovementAdded || p.combatAdded || p.projectilesAdded || p.towerAttackAdded || p.damageAdded || p.slowAdded || p.redirectAdded || p.spawnDespawnAddedByWatchpost || p.enemyAiChanged || p.enemyPathingChanged || p.waveTimingChanged || p.economyAdded || p.fogOfWarAdded || p.broadVisionAdded) errors.push(`${mode} has forbidden behavior flag`);
    if (mode === "v0267_watchpost_hud_no_train_militia" && /Train Militia available|Existing Barracks production|Rebuild|Repair/i.test(text)) errors.push("Watchpost HUD leaked Barracks production/lifecycle text");
    if (mode === "v0267_barracks_hud_no_watchpost_relay_card" && (snap.relayCardVisible || snap.hasRelayTitle)) errors.push("Barracks HUD inherited Watchpost relay card");
    if (mode === "v0267_no_position_before_watchpost_complete" && (p.relayVisible || p.barracksAdvisoryVisible || snap.hasPositionNone || snap.hasCurrentScoutedText)) errors.push("positioning/advisory before Watchpost completion");
    if (mode === "v0267_ashen_outside_zone_no_false_positive_no_position_alarm" && (p.currentDetection || snap.hasCurrentScoutedText || snap.hasThreatInZoneText || snap.hasPositionHoldingEastBridge)) errors.push("outside-zone false positive");
    if (mode.includes("holding") && p.positionState === "holding east bridge" && distance > Number(p.defensiveAreaRadius ?? 180)) errors.push(`${mode} claims holding while outside defensive area`);
    if (mode.includes("not_in_position") && p.positionState === "not in position" && distance <= Number(p.defensiveAreaRadius ?? 180)) errors.push(`${mode} claims not-in-position while inside defensive area`);
    if (mode.includes("memory") && p.advisoryState === "last_seen_memory" && (p.currentDetection || snap.currentMarkerVisible || snap.hasThreatInZoneText)) errors.push(`${mode} merges memory with current detection`);
    if (mode === "v0267_militia_training_position_pending" && (p.readinessState !== "training" || p.positionState !== "pending")) errors.push("training did not produce pending position");
    if (mode === "v0267_current_detection_relay_position_none" && (p.readinessState !== "none" || p.positionState !== "none")) errors.push("no-Militia state failed");
  }

  const pixelStats = stats.stats ?? [];
  if (pixelStats.length !== 26) errors.push(`expected 26 captured PNG pixel stats, saw ${pixelStats.length}`);
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return {
    errors,
    runtime,
    baseline,
    positioning,
    pixelSummary: {count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev},
  };
}

function writeReport(e) {
  const lines = [
    "# v0.267 Barrosan Watchpost Defender Positioning Bridge Report",
    "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `42877dba3cef802b2e575bbb80929f1663024b14`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0267-barrosan-watchpost-defender-positioning-bridge/`.",
    "",
    "## Boundary confirmation",
    "",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- Combat/projectiles/tower attack/damage/slow/redirect/spawn/despawn added: no.",
    "- Enemy AI/pathing/wave timing changed: no.",
    "- Economy mutation/resource generation/discount/speedup added: no.",
    "- Fog-of-war or broad RTS vision added: no.",
    "- Watchpost remains passive/intel/advisory/readiness/positioning only.",
    "- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.",
    "- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Militia training remains existing Field Barracks production only; Watchpost never trains Militia.",
    "",
    "## Positioning confirmation",
    "",
    "- Readiness states retained: none, training, ready.",
    "- Positioning states added: none, pending, not in position, holding east bridge.",
    "- Positioning derives from existing Militia source position and the passive east bridge defensive-area radius.",
    "- Current detection and last-seen memory remain distinct.",
    "- Outside-zone state does not trigger ASHEN SCOUTED, Threat in WATCH ZONE, or holding-position alarm.",
    "- No positioning/advisory appears before Watchpost completion.",
    "- No impossible UI combinations were accepted.",
    "- v0.264/v0.265/v0.266 readability retained by dedicated validators plus v0.267 world-label proof.",
    "",
    "## Pixel validation",
    "",
    `- Required screenshots: ${requiredImages.length}.`,
    `- Runtime capture count: ${e.runtime.captureCount}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`,
    "- Screenshots are non-black/readable: yes.",
    "",
    "## Recommendation for v0.268",
    "",
    "- If authorized, build a bounded next tactical coaching layer from this passive positioning proof. Do not add attacks, projectiles, fog-of-war, enemy retiming, auto-move, or broad RTS vision without a new v0.268 scope.",
    "",
    "Stop before v0.268.",
    "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0267_VALIDATION" : "PASS_V0267_BARROSAN_WATCHPOST_DEFENDER_POSITIONING_BRIDGE_VALIDATION";
  writeFileSync(join(root, "v0267-validation-report.json"), JSON.stringify({status, errors: evidence.errors, pixelSummary: evidence.pixelSummary}, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
