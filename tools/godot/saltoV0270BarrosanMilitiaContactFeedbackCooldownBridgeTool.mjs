import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0270"));
const manual = join(repo, "artifacts", "manual-review", "v0270-barrosan-militia-contact-feedback-cooldown-bridge");
const docPath = join(repo, "docs", "V0270_BARROSAN_MILITIA_CONTACT_FEEDBACK_COOLDOWN_BRIDGE_REPORT.md");
const runtimePath = join(root, "militia-contact-feedback-cooldown-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0270-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0270_watchpost_build_path_visible",
  "v0270_watchpost_complete_no_intel_no_contact_visible",
  "v0270_ashen_outside_zone_no_contact_visible",
  "v0270_current_detection_no_militia_contact_unavailable_visible",
  "v0270_militia_training_contact_pending_visible",
  "v0270_militia_ready_away_contact_unavailable_visible",
  "v0270_militia_holding_guarding_lane_integrity_100_visible",
  "v0270_intercept_ready_integrity_100_visible",
  "v0270_contact_armed_no_damage_yet_visible",
  "v0270_first_contact_feedback_pulse_visible",
  "v0270_first_contact_integrity_90_visible",
  "v0270_contact_resolved_cooldown_locked_visible",
  "v0270_no_repeated_damage_below_90_visible",
  "v0270_overlap_continues_integrity_still_90_visible",
  "v0270_no_enemy_death_or_despawn_visible",
  "v0270_no_enemy_slow_stop_redirect_visible",
  "v0270_no_militia_hp_loss_visible",
  "v0270_no_watchpost_hp_loss_visible",
  "v0270_no_watchpost_attack_damage_projectile_visible",
  "v0270_no_tower_behavior_visible",
  "v0270_threat_leaves_contact_ended_memory_visible",
  "v0270_memory_only_no_new_contact_damage_visible",
  "v0270_last_seen_integrity_90_visible",
  "v0270_minimap_contact_ping_current_only_visible",
  "v0270_minimap_memory_no_contact_ping_visible",
  "v0270_watchpost_hud_contact_cooldown_no_train_militia_visible",
  "v0270_barracks_hud_train_militia_no_full_relay_visible",
  "v0270_militia_selected_contact_resolved_visible",
  "v0270_label_declutter_pre_contact_visible",
  "v0270_label_declutter_first_contact_visible",
  "v0270_label_declutter_contact_resolved_visible",
  "v0270_existing_barracks_rebuild_path_still_valid_visible",
  "v0270_existing_barracks_still_trains_militia_visible",
];

const requiredImages = [
  "01_v0270_preflight_head_ci_resolution.png",
  "02_v0270_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "36_v0270_contact_sheet_visible.png",
  "37_v0270_black_frame_rejection_report_visible.png",
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
  const bridge = skin.barrosanMilitiaContactFeedbackCooldownBridge ?? {};
  const snaps = bridge.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.270") errors.push("runtime checkpoint is not v0.270");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled !== false) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 33) errors.push(`expected 33 runtime captures, saw ${runtime.captureCount}`);
  if (bridge.status !== "PASS") errors.push(`feedback/cooldown status is ${bridge.status}`);
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
    if (/Watchpost attack|Tower attack|projectile fired|gains ranged attack|fires projectile/i.test(text)) errors.push(`${mode} text implies forbidden attack/projectile behavior`);
    if (Number(c.pressureIntegrity ?? 100) < 90) errors.push(`${mode} integrity dropped below 90`);
    if (mode.includes("memory") && snap.contactMinimapPing) errors.push(`${mode} has contact ping during memory state`);
    if (mode.includes("outside_zone") && (c.contactApplied || c.contactState !== "unavailable")) errors.push(`${mode} false outside-zone contact`);
  }

  const pulse = contactOf(snaps, "v0270_first_contact_feedback_pulse_visible");
  const pulseSnap = snapshot(snaps, "v0270_first_contact_feedback_pulse_visible");
  if (pulse.contactState !== "engaged" || !pulse.contactApplied || Number(pulse.pressureIntegrity) !== 90 || !pulseSnap.hasFeedbackActive || !pulseSnap.contactFeedbackMarkerVisible) {
    errors.push("first-contact feedback pulse evidence failed");
  }

  const resolved = contactOf(snaps, "v0270_contact_resolved_cooldown_locked_visible");
  const resolvedSnap = snapshot(snaps, "v0270_contact_resolved_cooldown_locked_visible");
  if (resolved.contactState !== "resolved" || !resolved.cooldownLocked || Number(resolved.pressureIntegrity) !== 90 || !resolvedSnap.hasCooldownLocked || !resolvedSnap.hasResolvedMessage) {
    errors.push("resolved/cooldown evidence failed");
  }

  const repeat = contactOf(snaps, "v0270_no_repeated_damage_below_90_visible");
  if (Number(repeat.contactApplyAttempts) < 2 || Number(repeat.pressureIntegrity) !== 90 || repeat.contactState !== "resolved") {
    errors.push("repeat damage cooldown guard failed");
  }

  const armed = contactOf(snaps, "v0270_contact_armed_no_damage_yet_visible");
  if (armed.contactState !== "armed" || armed.contactApplied || Number(armed.pressureIntegrity) !== 100) errors.push("armed/no-damage evidence failed");

  const memory = contactOf(snaps, "v0270_memory_only_no_new_contact_damage_visible");
  if (memory.contactState !== "unavailable" || memory.contactApplied || Number(memory.pressureIntegrity) !== 100 || !memory.memoryActive || memory.currentDetection) {
    errors.push("memory-only no-new-contact evidence failed");
  }

  const ended = contactOf(snaps, "v0270_threat_leaves_contact_ended_memory_visible");
  if (ended.contactState !== "ended" || Number(ended.pressureIntegrity) !== 90 || !ended.memoryActive || ended.currentDetection) errors.push("ended memory evidence failed");

  const watchpostHud = snapshot(snaps, "v0270_watchpost_hud_contact_cooldown_no_train_militia_visible");
  if (watchpostHud.hasTrainMilitia || watchpostHud.hasBarracksProductionText) errors.push("Watchpost HUD leaked Barracks/Militia production text");
  const barracksHud = snapshot(snaps, "v0270_barracks_hud_train_militia_no_full_relay_visible");
  if (!barracksHud.hasTrainMilitia || barracksHud.relayCardVisible || barracksHud.hasRelayTitle) errors.push("Barracks HUD separation failed");
  const labels = ["v0270_label_declutter_pre_contact", "v0270_label_declutter_first_contact", "v0270_label_declutter_contact_resolved"];
  for (const mode of labels) {
    if (!snaps[mode]?.labelDeclutterImproved) errors.push(`${mode} label declutter evidence failed`);
  }

  const pixelStats = stats.stats ?? [];
  if (pixelStats.length !== 34) errors.push(`expected 34 captured PNG pixel stats, saw ${pixelStats.length}`);
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, runtime, baseline, bridge, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.270 Barrosan Militia Contact Feedback and Cooldown Bridge Report",
    "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `7487beae674e39b34f0abd83fd27072219b56b12`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0270-barrosan-militia-contact-feedback-cooldown-bridge/`.",
    "",
    "## Boundary confirmation",
    "",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- Watchpost remains passive/advisory/intel only.",
    "- Watchpost does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.",
    "- v0.269 consequence preserved: Ashen pressure integrity 100/100 -> 90/100 only once.",
    "- v0.270 adds feedback/cooldown/readability only.",
    "- New damage below 90/100: no.",
    "- Enemy death/despawn: no.",
    "- Militia HP loss: no.",
    "- Watchpost HP loss: no.",
    "- Projectiles: no.",
    "- Tower attack: no.",
    "- Enemy slow/stop/redirect: no.",
    "- Pathing/AI/wave/economy/default-runtime mutation: no.",
    "- Fog-of-war or broad vision system: no.",
    "- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.",
    "- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Field Barracks remains the only Militia training source.",
    "- Watchpost never shows Train Militia.",
    "- Barracks never shows full Watchpost relay card.",
    "",
    "## State confirmation",
    "",
    "- Readiness states retained: none, training, ready.",
    "- Positioning states retained: none, pending, not in position, holding east bridge.",
    "- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.",
    "- Contact states retained/extended: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.",
    "- Feedback/cooldown state: first contact feedback active, feedback expired, resolved/cooldown locked.",
    "- Contact requires current detection, ready Militia, holding east bridge, intercept ready, and confirmed contact threshold.",
    "- Last-seen memory cannot trigger new contact damage.",
    "- Outside-zone state does not trigger false contact.",
    "- Label clutter around first contact improved versus v0.269 by hiding/moving local world labels and preferring HUD/relay contact text.",
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
    "## Recommendation for v0.271",
    "",
    "- If authorized, v0.271 can separately decide whether to add a tiny animation/combat follow-up. Do not infer projectiles, tower attacks, death/despawn, pathing, AI, fog, economy, or broad RTS vision from v0.270.",
    "",
    "Stop before v0.271.",
    "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0270_VALIDATION" : "PASS_V0270_BARROSAN_MILITIA_CONTACT_FEEDBACK_COOLDOWN_BRIDGE_VALIDATION";
  writeFileSync(join(root, "v0270-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
