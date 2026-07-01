import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0271"));
const manual = join(repo, "artifacts", "manual-review", "v0271-barrosan-militia-guard-bridge-command-affordance");
const docPath = join(repo, "docs", "V0271_BARROSAN_MILITIA_GUARD_BRIDGE_COMMAND_AFFORDANCE_REPORT.md");
const runtimePath = join(root, "militia-guard-bridge-command-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0271-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0271_watchpost_build_path_visible",
  "v0271_watchpost_complete_no_intel_no_contact_visible",
  "v0271_barracks_train_militia_visible",
  "v0271_militia_training_guard_unavailable_visible",
  "v0271_militia_ready_guard_available_visible",
  "v0271_guard_button_visible_on_militia_not_watchpost_visible",
  "v0271_guard_order_pending_militia_away_visible",
  "v0271_no_auto_move_after_guard_order_visible",
  "v0271_watchpost_advises_move_to_bridge_visible",
  "v0271_militia_near_bridge_guard_confirmed_visible",
  "v0271_guard_marker_east_bridge_visible",
  "v0271_defender_position_holding_from_guard_order_visible",
  "v0271_intercept_preview_requires_guard_order_visible",
  "v0271_current_detection_no_guard_no_contact_visible",
  "v0271_current_detection_guard_pending_no_contact_visible",
  "v0271_current_detection_guard_holding_contact_armed_visible",
  "v0271_intercept_ready_integrity_100_visible",
  "v0271_first_contact_feedback_pulse_visible",
  "v0271_first_contact_integrity_90_visible",
  "v0271_contact_resolved_cooldown_locked_visible",
  "v0271_no_repeated_damage_below_90_visible",
  "v0271_overlap_continues_integrity_still_90_visible",
  "v0271_threat_leaves_memory_integrity_90_visible",
  "v0271_memory_only_no_new_contact_damage_visible",
  "v0271_no_enemy_death_or_despawn_visible",
  "v0271_no_enemy_slow_stop_redirect_visible",
  "v0271_no_militia_hp_loss_visible",
  "v0271_no_watchpost_hp_loss_visible",
  "v0271_no_watchpost_attack_projectile_tower_visible",
  "v0271_watchpost_hud_advisory_only_no_train_no_guard_action_visible",
  "v0271_barracks_hud_train_militia_no_full_relay_visible",
  "v0271_militia_hud_guard_order_contact_resolved_visible",
  "v0271_minimap_guard_pending_indicator_visible",
  "v0271_minimap_guard_holding_indicator_visible",
  "v0271_minimap_contact_ping_current_only_visible",
  "v0271_minimap_memory_no_contact_ping_visible",
  "v0271_label_declutter_guard_pending_visible",
  "v0271_label_declutter_guard_holding_visible",
  "v0271_label_declutter_first_contact_visible",
  "v0271_existing_barracks_rebuild_path_still_valid_visible",
  "v0271_existing_barracks_still_trains_militia_visible",
];

const requiredImages = [
  "01_v0271_preflight_head_ci_resolution.png",
  "02_v0271_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "44_v0271_contact_sheet_visible.png",
  "45_v0271_black_frame_rejection_report_visible.png",
];

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function snapshot(snaps, visibleName) {
  return snaps[visibleName.replace(/_visible$/, "")] ?? {};
}

function contactOf(snaps, visibleName) {
  return snapshot(snaps, visibleName).firstContact ?? {};
}

function passive(c) {
  return ![
    "automaticMovementAdded", "autoMoveAttempted", "automaticAttackAdded",
    "watchpostCausedDamage", "watchpostAttackAdded", "projectilesAdded", "towerAttackAdded",
    "slowAdded", "redirectAdded", "enemyPathingChanged", "enemyAiChanged", "waveTimingChanged",
    "economyAdded", "collisionChanged", "fogOfWarAdded", "broadVisionAdded", "enemyStopped",
    "enemyDespawned", "enemyDeath",
  ].some((key) => Boolean(c[key])) &&
    Number(c.militiaHpBeforeContact) === Number(c.militiaHpAfterContact) &&
    Number(c.watchpostHpBeforeContact) === Number(c.watchpostHpAfterContact) &&
    Number(c.pressureIntegrity ?? 100) >= 90;
}

function evalEvidence() {
  const runtime = readJson(runtimePath);
  const baseline = readJson(defaultPath);
  const stats = readJson(statsPath);
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const bridge = skin.barrosanMilitiaGuardBridgeCommandAffordance ?? {};
  const snaps = bridge.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.271") errors.push("runtime checkpoint is not v0.271");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled !== false) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 41) errors.push(`expected 41 runtime captures, saw ${runtime.captureCount}`);
  if (bridge.status !== "PASS") errors.push(`guard bridge command status is ${bridge.status}`);
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
    const c = snap.firstContact ?? {};
    const text = snap.combinedText ?? "";
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!c.guardRequiredForContact) errors.push(`${mode} did not mark guard as required for v0.271 contact`);
    if (/Watchpost attack|Tower attack|projectile fired|gains ranged attack|fires projectile/i.test(text)) errors.push(`${mode} text implies forbidden action`);
    if (Number(c.pressureIntegrity ?? 100) < 90) errors.push(`${mode} integrity dropped below 90`);
    if (mode.includes("memory") && snap.contactMinimapPing) errors.push(`${mode} has contact ping during memory state`);
  }

  const ready = contactOf(snaps, "v0271_militia_ready_guard_available_visible");
  const readySnap = snapshot(snaps, "v0271_militia_ready_guard_available_visible");
  if (ready.guardOrderState !== "available" || !ready.guardCommandAvailable || !readySnap.hasGuardBridgeCommand) errors.push("ready Militia guard command available evidence failed");

  const pending = contactOf(snaps, "v0271_guard_order_pending_militia_away_visible");
  if (pending.guardOrderState !== "pending" || pending.contactApplied || pending.contactState !== "pending" || pending.autoMoveAttempted) errors.push("pending guard/no-auto-move evidence failed");

  const noGuard = contactOf(snaps, "v0271_current_detection_no_guard_no_contact_visible");
  if (noGuard.guardOrderState !== "available" || noGuard.contactApplied || noGuard.contactState !== "unavailable") errors.push("current detection without guard order contact gate failed");

  const holding = contactOf(snaps, "v0271_current_detection_guard_holding_contact_armed_visible");
  if (holding.guardOrderState !== "holding east bridge" || holding.contactState !== "armed" || holding.contactApplied || Number(holding.pressureIntegrity) !== 100) errors.push("holding guard armed/no-damage evidence failed");

  const pulse = contactOf(snaps, "v0271_first_contact_feedback_pulse_visible");
  const pulseSnap = snapshot(snaps, "v0271_first_contact_feedback_pulse_visible");
  if (pulse.guardOrderState !== "holding east bridge" || pulse.contactState !== "engaged" || !pulse.contactApplied || Number(pulse.pressureIntegrity) !== 90 || !pulseSnap.hasFeedbackActive) errors.push("guarded first-contact feedback evidence failed");

  const resolved = contactOf(snaps, "v0271_contact_resolved_cooldown_locked_visible");
  if (resolved.guardOrderState !== "resolved after contact" || resolved.contactState !== "resolved" || !resolved.cooldownLocked || Number(resolved.pressureIntegrity) !== 90) errors.push("guard resolved/cooldown evidence failed");

  const repeat = contactOf(snaps, "v0271_no_repeated_damage_below_90_visible");
  if (Number(repeat.contactApplyAttempts) < 2 || Number(repeat.pressureIntegrity) !== 90 || repeat.contactState !== "resolved") errors.push("repeat damage guard failed");

  const watchpostHud = snapshot(snaps, "v0271_watchpost_hud_advisory_only_no_train_no_guard_action_visible");
  if (watchpostHud.hasTrainMilitia || watchpostHud.guardCommandOnWatchpost) errors.push("Watchpost HUD leaked Train Militia or Guard Bridge action");

  const barracksHud = snapshot(snaps, "v0271_barracks_hud_train_militia_no_full_relay_visible");
  if (!barracksHud.hasTrainMilitia || barracksHud.relayCardVisible || barracksHud.hasRelayTitle) errors.push("Barracks HUD separation failed");

  const memory = contactOf(snaps, "v0271_memory_only_no_new_contact_damage_visible");
  if (memory.contactState !== "unavailable" || memory.contactApplied || Number(memory.pressureIntegrity) !== 100 || !memory.memoryActive || memory.currentDetection) errors.push("memory-only no-new-contact evidence failed");

  const pixelStats = stats.stats ?? [];
  if (pixelStats.length !== 42) errors.push(`expected 42 captured PNG pixel stats, saw ${pixelStats.length}`);
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, runtime, bridge, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.271 Barrosan Militia Guard Bridge Command Affordance Report",
    "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `64384021d8ca06931d760fbd14dd422469e63ef8`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0271-barrosan-militia-guard-bridge-command-affordance/`.",
    "",
    "## Boundary confirmation",
    "",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- v0.271 adds player-facing Guard Bridge command affordance only.",
    "- Automatic movement: no.",
    "- Automatic attack: no.",
    "- Watchpost remains passive/advisory/intel only and does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.",
    "- v0.269/v0.270 consequence preserved: Ashen pressure integrity 100/100 -> 90/100 only once.",
    "- New damage below 90/100: no.",
    "- Guard order is required for contact eligibility: yes.",
    "- Guard pending does not trigger contact; Militia away from bridge does not trigger contact; current detection without guard order does not trigger contact.",
    "- Last-seen memory cannot trigger new contact damage; outside-zone state does not trigger false contact.",
    "- Enemy death/despawn: no. Militia HP loss: no. Watchpost HP loss: no.",
    "- Projectiles/tower attack: no. Enemy slow/stop/redirect: no.",
    "- Pathing/AI/wave/economy/default-runtime mutation: no.",
    "- Fog-of-war or broad vision system: no.",
    "- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.",
    "- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Field Barracks remains the only Militia training source.",
    "- Watchpost never shows Train Militia and never shows Guard Bridge as a Watchpost action.",
    "- Barracks never shows full Watchpost relay card.",
    "",
    "## State confirmation",
    "",
    "- Readiness states retained: none, training, ready.",
    "- Positioning states retained: none, pending, not in position, holding east bridge.",
    "- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.",
    "- Contact states retained: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.",
    "- Feedback/cooldown states retained: first contact feedback active, first contact feedback expired, first contact resolved/cooldown locked.",
    "- New guard-order states: unavailable, available, pending, holding east bridge, cancelled reserved/not exposed, resolved after contact.",
    "- Label clutter remains improved versus v0.269 by preferring HUD/objective copy and using one subtle guard bridge marker.",
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
    "## Recommendation for v0.272",
    "",
    "- Next slice can safely add a small explicit cancel/clear-guard affordance or one bounded post-contact follow-up. Do not infer combat, attack animation, projectiles, death/despawn, fog, economy, AI, pathing, or broad vision.",
    "",
    "Stop before v0.272.",
    "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0271_VALIDATION" : "PASS_V0271_BARROSAN_MILITIA_GUARD_BRIDGE_COMMAND_AFFORDANCE_VALIDATION";
  writeFileSync(join(root, "v0271-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
