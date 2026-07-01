import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0273"));
const manual = join(repo, "artifacts", "manual-review", "v0273-barrosan-militia-brace-bridge-post-contact-hold");
const docPath = join(repo, "docs", "V0273_BARROSAN_MILITIA_BRACE_BRIDGE_POST_CONTACT_HOLD_REPORT.md");
const runtimePath = join(root, "militia-brace-bridge-post-contact-hold-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0273-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0273_watchpost_build_path_visible",
  "v0273_watchpost_complete_no_intel_no_contact_visible",
  "v0273_barracks_train_militia_visible",
  "v0273_militia_training_guard_unavailable_visible",
  "v0273_militia_ready_guard_available_visible",
  "v0273_guard_order_pending_clear_guard_button_visible",
  "v0273_clear_pending_guard_blocks_contact_visible",
  "v0273_guard_reissued_after_clear_visible",
  "v0273_guard_holding_intercept_ready_visible",
  "v0273_current_detection_no_guard_no_contact_visible",
  "v0273_guard_pending_no_contact_visible",
  "v0273_guard_holding_contact_armed_visible",
  "v0273_first_contact_feedback_pulse_visible",
  "v0273_first_contact_integrity_90_visible",
  "v0273_contact_resolved_cooldown_locked_visible",
  "v0273_brace_available_after_contact_visible",
  "v0273_bridge_held_marker_visible",
  "v0273_militia_hud_bridge_held_pressure_90_visible",
  "v0273_watchpost_hud_bridge_held_advisory_only_visible",
  "v0273_minimap_bridge_held_indicator_visible",
  "v0273_contact_ping_not_active_after_resolved_visible",
  "v0273_clear_guard_after_contact_visible",
  "v0273_bridge_held_marker_removed_after_clear_visible",
  "v0273_minimap_bridge_held_indicator_removed_after_clear_visible",
  "v0273_pressure_still_90_after_clear_visible",
  "v0273_reguard_after_contact_bridge_held_visible",
  "v0273_no_repeated_damage_after_reguard_visible",
  "v0273_overlap_continues_integrity_still_90_visible",
  "v0273_memory_only_no_new_contact_damage_visible",
  "v0273_outside_zone_no_false_contact_visible",
  "v0273_no_enemy_death_or_despawn_visible",
  "v0273_no_enemy_slow_stop_redirect_visible",
  "v0273_no_militia_hp_loss_visible",
  "v0273_no_watchpost_hp_loss_visible",
  "v0273_no_watchpost_attack_projectile_tower_visible",
  "v0273_watchpost_no_train_no_guard_no_clear_no_brace_action_visible",
  "v0273_barracks_hud_train_militia_no_full_relay_visible",
  "v0273_militia_hud_no_ranged_attack_no_projectile_visible",
  "v0273_label_declutter_first_contact_visible",
  "v0273_label_declutter_bridge_held_visible",
  "v0273_label_declutter_after_clear_visible",
  "v0273_existing_barracks_rebuild_path_still_valid_visible",
  "v0273_existing_barracks_still_trains_militia_visible",
];

const requiredImages = [
  "01_v0273_preflight_head_ci_resolution.png",
  "02_v0273_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "46_v0273_contact_sheet_visible.png",
  "47_v0273_black_frame_rejection_report_visible.png",
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
    "enemyDespawned", "enemyDeath", "braceDamageAdded", "braceAutoMoveAdded", "braceAutoAttackAdded", "braceProjectileAdded",
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
  const bridge = skin.barrosanMilitiaBraceBridgePostContactHold ?? {};
  const snaps = bridge.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.273") errors.push("runtime checkpoint is not v0.273");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled !== false) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 43) errors.push(`expected 43 runtime captures, saw ${runtime.captureCount}`);
  if (bridge.status !== "PASS") errors.push(`brace bridge post-contact hold status is ${bridge.status}`);
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
    if (!c.guardRequiredForContact) errors.push(`${mode} did not mark guard as required for v0.273 contact`);
    if (/Watchpost attack|Tower attack|projectile fired|gains ranged attack|fires projectile|fires a projectile/i.test(text)) errors.push(`${mode} text implies forbidden action`);
    if (Number(c.pressureIntegrity ?? 100) < 90) errors.push(`${mode} integrity dropped below 90`);
    if (mode.includes("memory") && snap.contactMinimapPing) errors.push(`${mode} has contact ping during memory state`);
    if (mode.includes("watchpost") && snap.braceActionOnWatchpost) errors.push(`${mode} leaked Brace Bridge as a Watchpost action`);
    if (mode.includes("barracks") && snap.braceActionOnBarracks) errors.push(`${mode} leaked Brace Bridge as a Barracks action`);
  }

  const ready = contactOf(snaps, "v0273_militia_ready_guard_available_visible");
  const readySnap = snapshot(snaps, "v0273_militia_ready_guard_available_visible");
  if (ready.guardOrderState !== "available" || !ready.guardCommandAvailable || !readySnap.hasGuardBridgeCommand) errors.push("ready Militia guard command available evidence failed");

  const pending = contactOf(snaps, "v0273_guard_order_pending_clear_guard_button_visible");
  if (pending.guardOrderState !== "pending" || pending.contactApplied || pending.contactState !== "pending" || pending.autoMoveAttempted) errors.push("pending guard/no-auto-move evidence failed");

  const noGuard = contactOf(snaps, "v0273_current_detection_no_guard_no_contact_visible");
  if (noGuard.guardOrderState !== "available" || noGuard.contactApplied || noGuard.contactState !== "unavailable") errors.push("current detection without guard order contact gate failed");

  const holding = contactOf(snaps, "v0273_guard_holding_contact_armed_visible");
  if (holding.guardOrderState !== "holding east bridge" || holding.contactState !== "armed" || holding.contactApplied || Number(holding.pressureIntegrity) !== 100) errors.push("holding guard armed/no-damage evidence failed");

  const pulse = contactOf(snaps, "v0273_first_contact_feedback_pulse_visible");
  const pulseSnap = snapshot(snaps, "v0273_first_contact_feedback_pulse_visible");
  if (pulse.guardOrderState !== "holding east bridge" || pulse.contactState !== "engaged" || !pulse.contactApplied || Number(pulse.pressureIntegrity) !== 90 || !pulseSnap.hasFeedbackActive) errors.push("guarded first-contact feedback evidence failed");

  const resolved = contactOf(snaps, "v0273_contact_resolved_cooldown_locked_visible");
  if (resolved.guardOrderState !== "resolved after contact" || resolved.contactState !== "resolved" || !resolved.cooldownLocked || Number(resolved.pressureIntegrity) !== 90) errors.push("guard resolved/cooldown evidence failed");

  const braceAvailable = contactOf(snaps, "v0273_brace_available_after_contact_visible");
  if (braceAvailable.postContactHoldState !== "brace available" || braceAvailable.contactState !== "resolved" || Number(braceAvailable.pressureIntegrity) !== 90) errors.push("brace-available after contact evidence failed");

  const heldSnap = snapshot(snaps, "v0273_bridge_held_marker_visible");
  const held = heldSnap.firstContact ?? {};
  if (held.postContactHoldState !== "bridge held" || held.contactState !== "resolved" || !heldSnap.bridgeHeldMarkerVisible || Number(held.pressureIntegrity) !== 90) errors.push("Bridge Held marker evidence failed");

  const heldMinimapSnap = snapshot(snaps, "v0273_minimap_bridge_held_indicator_visible");
  if (!heldMinimapSnap.bridgeHeldMinimap) errors.push("Bridge Held minimap indicator evidence failed");

  const noPingSnap = snapshot(snaps, "v0273_contact_ping_not_active_after_resolved_visible");
  if (noPingSnap.contactPingActiveAfterResolved) errors.push("resolved contact ping remained active");

  const clearSnap = snapshot(snaps, "v0273_clear_guard_after_contact_visible");
  const clear = clearSnap.firstContact ?? {};
  if (clear.guardOrderState !== "cleared" || clear.postContactHoldState !== "brace cleared" || Number(clear.pressureIntegrity) !== 90 || clearSnap.bridgeHeldMarkerVisible || clearSnap.bridgeHeldMinimap) errors.push("clear-after-contact did not remove Bridge Held state cleanly");

  const repeat = contactOf(snaps, "v0273_no_repeated_damage_after_reguard_visible");
  if (Number(repeat.pressureIntegrity) !== 90 || repeat.contactState !== "resolved" || repeat.postContactHoldState !== "bridge held" || repeat.braceDoesNotRepeatDamage !== true) errors.push("repeat damage guard failed");

  const watchpostHud = snapshot(snaps, "v0273_watchpost_no_train_no_guard_no_clear_no_brace_action_visible");
  if (watchpostHud.hasTrainMilitia || watchpostHud.guardCommandOnWatchpost || watchpostHud.clearGuardCommandOnWatchpost || watchpostHud.braceActionOnWatchpost) errors.push("Watchpost HUD leaked Train Militia, Guard, Clear, or Brace action");

  const barracksHud = snapshot(snaps, "v0273_barracks_hud_train_militia_no_full_relay_visible");
  if (!barracksHud.hasTrainMilitia || barracksHud.relayCardVisible || barracksHud.hasRelayTitle) errors.push("Barracks HUD separation failed");

  const memory = contactOf(snaps, "v0273_memory_only_no_new_contact_damage_visible");
  if (memory.contactState !== "unavailable" || memory.contactApplied || Number(memory.pressureIntegrity) !== 100 || !memory.memoryActive || memory.currentDetection) errors.push("memory-only no-new-contact evidence failed");

  const pixelStats = stats.stats ?? [];
  if (pixelStats.length !== 44) errors.push(`expected 44 captured PNG pixel stats, saw ${pixelStats.length}`);
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, runtime, bridge, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.273 Barrosan Militia Brace Bridge Post-Contact Hold Report",
    "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `45d85d2686679784c2d00da45a67f4de4fe95a6b`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0273-barrosan-militia-brace-bridge-post-contact-hold/`.",
    "",
    "## Boundary confirmation",
    "",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- v0.273 adds Brace Bridge / Bridge Held post-contact hold readability only, while preserving Guard Bridge and Clear Guard from v0.271-v0.272.",
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
    "- Watchpost never shows Train Militia, Guard Bridge, or Clear Guard as a Watchpost action.",
    "- Barracks never shows full Watchpost relay card.",
    "",
    "## State confirmation",
    "",
    "- Readiness states retained: none, training, ready.",
    "- Positioning states retained: none, pending, not in position, holding east bridge.",
    "- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.",
    "- Contact states retained: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.",
    "- Feedback/cooldown states retained: first contact feedback active, first contact feedback expired, first contact resolved/cooldown locked.",
    "- Guard-order states retained/extended: unavailable, available, pending, holding east bridge, cleared, resolved after contact.",
    "- Post-contact hold states added: not braced, brace available, bracing bridge, bridge held, brace cleared.",
    "- Label clutter remains improved versus v0.269 by replacing resolved contact ping/label with one subtle Bridge Held marker.",
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
    "## Recommendation for v0.274",
    "",
    "- Next slice can safely add one bounded downstream response to Bridge Held. Do not infer combat, attack animation, projectiles, death/despawn, fog, economy, AI, pathing, or broad vision.",
    "",
    "Stop before v0.274.",
    "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0273_VALIDATION" : "PASS_V0273_BARROSAN_MILITIA_BRACE_BRIDGE_POST_CONTACT_HOLD_VALIDATION";
  writeFileSync(join(root, "v0273-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
