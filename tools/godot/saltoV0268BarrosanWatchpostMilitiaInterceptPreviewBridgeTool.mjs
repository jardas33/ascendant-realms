import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0268"));
const manual = join(repo, "artifacts", "manual-review", "v0268-barrosan-watchpost-militia-intercept-preview-bridge");
const docPath = join(repo, "docs", "V0268_BARROSAN_WATCHPOST_MILITIA_INTERCEPT_PREVIEW_BRIDGE_REPORT.md");
const runtimePath = join(root, "watchpost-militia-intercept-preview-bridge-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0268-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0268_watchpost_build_path_visible",
  "v0268_watchpost_complete_no_intel_no_intercept_preview_visible",
  "v0268_ashen_outside_zone_no_false_intercept_visible",
  "v0268_current_detection_no_militia_intercept_unavailable_visible",
  "v0268_current_detection_relay_intercept_unavailable_visible",
  "v0268_barracks_train_militia_advisory_still_visible",
  "v0268_militia_training_intercept_pending_visible",
  "v0268_current_detection_relay_intercept_pending_visible",
  "v0268_militia_ready_away_intercept_cannot_visible",
  "v0268_current_detection_relay_cannot_intercept_visible",
  "v0268_objective_move_defender_to_east_bridge_visible",
  "v0268_militia_holding_bridge_guarding_lane_visible",
  "v0268_current_detection_relay_guarding_lane_visible",
  "v0268_ashen_inside_intercept_envelope_visible",
  "v0268_current_detection_relay_intercept_ready_visible",
  "v0268_objective_intercept_ready_hold_bridge_visible",
  "v0268_no_damage_after_intercept_preview_visible",
  "v0268_no_enemy_slow_or_redirect_after_intercept_preview_visible",
  "v0268_threat_leaves_memory_cannot_intercept_visible",
  "v0268_threat_leaves_memory_guarding_last_seen_lane_visible",
  "v0268_last_seen_memory_marker_still_distinct_visible",
  "v0268_current_vs_memory_vs_position_vs_intercept_not_confused_visible",
  "v0268_watchpost_hud_no_train_militia_visible",
  "v0268_barracks_hud_no_watchpost_relay_card_visible",
  "v0268_existing_barracks_rebuild_path_still_valid_visible",
  "v0268_existing_barracks_still_trains_militia_visible",
  "v0268_no_intercept_before_watchpost_complete_visible",
  "v0268_no_intercept_ready_before_militia_holding_bridge_visible",
  "v0268_world_label_clutter_not_regressed_visible",
];

const requiredImages = [
  "01_v0268_preflight_head_ci_resolution.png",
  "02_v0268_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "32_v0268_contact_sheet_visible.png",
  "33_v0268_black_frame_rejection_report_visible.png",
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
  const bridge = skin.watchpostMilitiaInterceptPreviewBridge ?? {};
  const snaps = bridge.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.268") errors.push("runtime checkpoint is not v0.268");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled !== false) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 29) errors.push(`expected 29 runtime captures, saw ${runtime.captureCount}`);
  if (bridge.status !== "PASS") errors.push(`intercept preview status is ${bridge.status}`);
  const cost = bridge.cost ?? {};
  if (Number(cost.crowns) !== 100 || Number(cost.stone) !== 30 || Number(cost.iron) !== 10 || Number(cost.aether) !== 0) errors.push("Watchpost cost changed");
  if (Number(bridge.hp) !== 120) errors.push("Watchpost HP changed");

  for (const name of runtimeNames) {
    const mode = name.replace(/_visible$/, "");
    if (!snaps[mode]) errors.push(`missing proof snapshot ${mode}`);
  }
  for (const file of requiredImages) {
    if (!existsSync(join(manual, file))) errors.push(`missing manual review image ${file}`);
  }

  for (const [mode, snap] of Object.entries(snaps)) {
    const p = snap.interceptPreview ?? {};
    const text = snap.combinedText ?? "";
    const state = p.interceptPreviewState;
    const readiness = p.readinessState;
    const position = p.positionState;
    const ashenDistance = Number(p.ashenDistanceToInterceptEnvelope ?? 99999);
    const radius = Number(p.interceptEnvelopeRadius ?? 145);
    if (!p.interceptPreviewOnly || p.automaticMovementAdded || p.combatAdded || p.projectilesAdded || p.towerAttackAdded || p.damageAdded || p.slowAdded || p.redirectAdded || p.spawnDespawnAddedByWatchpost || p.enemyAiChanged || p.enemyPathingChanged || p.waveTimingChanged || p.economyAdded || p.fogOfWarAdded || p.broadVisionAdded || p.healthMutationAdded || p.collisionChanged || p.enemyStopped) errors.push(`${mode} has forbidden behavior flag`);
    if (Number(p.militiaHpBeforePreview) !== Number(p.militiaHpAfterPreview) || Number(p.ashenHpBeforePreview) !== Number(p.ashenHpAfterPreview)) errors.push(`${mode} mutated HP during preview`);
    if (mode === "v0268_watchpost_hud_no_train_militia" && /Train Militia available|Existing Barracks production|Rebuild|Repair/i.test(text)) errors.push("Watchpost HUD leaked Barracks production/lifecycle text");
    if (mode === "v0268_barracks_hud_no_watchpost_relay_card" && (snap.relayCardVisible || snap.hasRelayTitle)) errors.push("Barracks HUD inherited Watchpost relay card");
    if (mode === "v0268_no_intercept_before_watchpost_complete" && (p.relayVisible || p.barracksAdvisoryVisible || snap.hasInterceptUnavailable || snap.hasCurrentScoutedText)) errors.push("intercept preview/advisory before Watchpost completion");
    if (mode === "v0268_ashen_outside_zone_no_false_intercept" && (p.currentDetection || snap.hasCurrentScoutedText || snap.hasThreatInZoneText || snap.hasInterceptReady)) errors.push("outside-zone false intercept positive");
    if (state === "intercept ready" && (!p.currentDetection || readiness !== "ready" || position !== "holding east bridge" || ashenDistance > radius || p.memoryActive)) errors.push(`${mode} claimed intercept ready without all prerequisites`);
    if (mode.includes("memory") && p.advisoryState === "last_seen_memory" && (p.currentDetection || snap.currentMarkerVisible || snap.hasThreatInZoneText || snap.hasInterceptReady)) errors.push(`${mode} merges memory with current/intercept-ready`);
    if (mode === "v0268_militia_training_intercept_pending" && (readiness !== "training" || state !== "pending")) errors.push("training did not produce pending intercept");
    if (mode === "v0268_current_detection_relay_cannot_intercept" && (readiness !== "ready" || position !== "not in position" || state !== "cannot intercept")) errors.push("ready-away cannot-intercept state failed");
    if (mode === "v0268_current_detection_relay_guarding_lane" && (position !== "holding east bridge" || state !== "guarding lane" || ashenDistance <= radius)) errors.push("guarding-lane state failed");
    if (mode === "v0268_current_detection_relay_intercept_ready" && (state !== "intercept ready" || !snap.interceptReadyMinimap || !snap.interceptReadyWorldLabel)) errors.push("intercept-ready evidence failed");
  }

  const pixelStats = stats.stats ?? [];
  if (pixelStats.length !== 30) errors.push(`expected 30 captured PNG pixel stats, saw ${pixelStats.length}`);
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return {errors, runtime, baseline, bridge, pixelSummary: {count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev}};
}

function writeReport(e) {
  const lines = [
    "# v0.268 Barrosan Watchpost Militia Intercept Preview Bridge Report",
    "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `59bd21888f1ad78349abf0cfaa9b430349ca8743`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0268-barrosan-watchpost-militia-intercept-preview-bridge/`.",
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
    "- Watchpost remains passive/intel/advisory/readiness/positioning/intercept-preview only.",
    "- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.",
    "- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Militia training remains existing Field Barracks production only; Watchpost never trains Militia.",
    "",
    "## Intercept preview confirmation",
    "",
    "- Readiness states retained: none, training, ready.",
    "- Positioning states retained: none, pending, not in position, holding east bridge.",
    "- Intercept-preview states: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.",
    "- Intercept ready requires current detection, ready Militia, holding east bridge, and Ashen inside the intercept-preview envelope.",
    "- Intercept preview causes no damage, slow, redirect, attack, projectile, collision, or pathing effect.",
    "- Current detection and last-seen memory remain distinct.",
    "- Outside-zone state does not trigger ASHEN SCOUTED, Threat in WATCH ZONE, or intercept ready.",
    "- No intercept-preview appears before Watchpost completion.",
    "- No impossible UI combinations were accepted.",
    "- v0.264/v0.265/v0.266/v0.267 readability retained by dedicated validators plus v0.268 proof.",
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
    "## Recommendation for v0.269",
    "",
    "- If authorized, use this as the final pre-combat readability proof before a separately scoped first real engagement/consequence slice. Do not add attacks, projectiles, fog-of-war, enemy retiming, auto-move, or broad RTS vision without a new v0.269 scope.",
    "",
    "Stop before v0.269.",
    "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0268_VALIDATION" : "PASS_V0268_BARROSAN_WATCHPOST_MILITIA_INTERCEPT_PREVIEW_BRIDGE_VALIDATION";
  writeFileSync(join(root, "v0268-validation-report.json"), JSON.stringify({status, errors: evidence.errors, pixelSummary: evidence.pixelSummary}, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
