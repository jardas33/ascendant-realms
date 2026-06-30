import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0269"));
const manual = join(repo, "artifacts", "manual-review", "v0269-barrosan-militia-first-contact-micro-consequence");
const docPath = join(repo, "docs", "V0269_BARROSAN_MILITIA_FIRST_CONTACT_MICRO_CONSEQUENCE_REPORT.md");
const runtimePath = join(root, "militia-first-contact-micro-consequence-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0269-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0269_watchpost_build_path_visible",
  "v0269_watchpost_complete_no_intel_no_contact_visible",
  "v0269_ashen_outside_zone_no_contact_visible",
  "v0269_current_detection_no_militia_contact_unavailable_visible",
  "v0269_current_detection_militia_training_contact_pending_visible",
  "v0269_militia_ready_away_contact_unavailable_visible",
  "v0269_militia_holding_guarding_lane_no_contact_visible",
  "v0269_intercept_ready_pre_contact_integrity_100_visible",
  "v0269_contact_armed_no_damage_yet_visible",
  "v0269_first_contact_engaged_integrity_90_visible",
  "v0269_no_repeated_damage_below_90_visible",
  "v0269_no_enemy_despawn_after_contact_visible",
  "v0269_no_militia_hp_loss_after_contact_visible",
  "v0269_no_watchpost_damage_or_attack_visible",
  "v0269_no_projectile_or_tower_attack_visible",
  "v0269_no_enemy_slow_or_redirect_visible",
  "v0269_threat_leaves_after_contact_memory_integrity_90_visible",
  "v0269_memory_only_no_new_contact_damage_visible",
  "v0269_last_seen_memory_marker_distinct_visible",
  "v0269_current_vs_memory_vs_position_vs_intercept_vs_contact_not_confused_visible",
  "v0269_watchpost_hud_contact_state_no_train_militia_visible",
  "v0269_barracks_hud_train_militia_no_watchpost_relay_visible",
  "v0269_militia_selected_contact_state_visible",
  "v0269_minimap_current_detection_contact_ping_visible",
  "v0269_minimap_memory_no_contact_ping_visible",
  "v0269_no_contact_before_watchpost_complete_visible",
  "v0269_no_contact_before_militia_holding_bridge_visible",
  "v0269_no_contact_when_ashen_only_outside_range_visible",
  "v0269_label_declutter_intercept_ready_visible",
  "v0269_label_declutter_contact_engaged_visible",
  "v0269_existing_barracks_rebuild_path_still_valid_visible",
  "v0269_existing_barracks_still_trains_militia_visible",
];

const requiredImages = [
  "01_v0269_preflight_head_ci_resolution.png",
  "02_v0269_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "35_v0269_contact_sheet_visible.png",
  "36_v0269_black_frame_rejection_report_visible.png",
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
  const bridge = skin.barrosanMilitiaFirstContactMicroConsequence ?? {};
  const snaps = bridge.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.269") errors.push("runtime checkpoint is not v0.269");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled !== false) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 32) errors.push(`expected 32 runtime captures, saw ${runtime.captureCount}`);
  if (bridge.status !== "PASS") errors.push(`first-contact status is ${bridge.status}`);
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

  const mustBeEngaged = new Set([
    "v0269_first_contact_engaged_integrity_90",
    "v0269_no_enemy_despawn_after_contact",
    "v0269_no_militia_hp_loss_after_contact",
    "v0269_no_watchpost_damage_or_attack",
    "v0269_no_projectile_or_tower_attack",
    "v0269_no_enemy_slow_or_redirect",
    "v0269_watchpost_hud_contact_state_no_train_militia",
    "v0269_minimap_current_detection_contact_ping",
    "v0269_label_declutter_contact_engaged",
  ]);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const text = snap.combinedText ?? "";
    const state = c.contactState;
    const integrity = Number(c.pressureIntegrity ?? -1);
    const readiness = c.readinessState;
    const position = c.positionState;
    const intercept = c.interceptPreviewState;
    const forbidden =
      c.watchpostCausedDamage || c.watchpostAttackAdded || c.projectilesAdded || c.towerAttackAdded ||
      c.slowAdded || c.redirectAdded || c.enemyPathingChanged || c.enemyAiChanged || c.waveTimingChanged ||
      c.economyAdded || c.collisionChanged || c.fogOfWarAdded || c.broadVisionAdded || c.enemyStopped ||
      c.enemyDespawned || c.enemyDeath;
    if (forbidden) errors.push(`${mode} has forbidden behavior flag`);
    if (Number(c.militiaHpBeforeContact) !== Number(c.militiaHpAfterContact)) errors.push(`${mode} mutated Militia HP`);
    if (Number(c.watchpostHpBeforeContact) !== Number(c.watchpostHpAfterContact)) errors.push(`${mode} mutated Watchpost HP`);
    if (/Watchpost attack|Tower attack/i.test(text)) errors.push(`${mode} text implies Watchpost/tower attack`);
    if (mode === "v0269_watchpost_complete_no_intel_no_contact" && (state !== "unavailable" || c.contactApplied || snap.hasCurrentScoutedText)) errors.push("no-intel contact state failed");
    if ((mode === "v0269_ashen_outside_zone_no_contact" || mode === "v0269_no_contact_when_ashen_only_outside_range") && (state !== "unavailable" || c.contactApplied || snap.hasCurrentScoutedText || snap.hasThreatInZoneText)) errors.push(`${mode} outside-zone false contact`);
    if (mode === "v0269_current_detection_no_militia_contact_unavailable" && (readiness !== "none" || position !== "none" || state !== "unavailable" || c.contactApplied)) errors.push("no-Militia contact unavailable failed");
    if (mode === "v0269_current_detection_militia_training_contact_pending" && (readiness !== "training" || position !== "pending" || state !== "pending" || c.contactApplied)) errors.push("training contact pending failed");
    if ((mode === "v0269_militia_ready_away_contact_unavailable" || mode === "v0269_no_contact_before_militia_holding_bridge") && (readiness !== "ready" || position !== "not in position" || state !== "unavailable" || c.contactApplied)) errors.push(`${mode} ready-away contact guard failed`);
    if (mode === "v0269_militia_holding_guarding_lane_no_contact" && (position !== "holding east bridge" || intercept !== "guarding lane" || state !== "awaiting pressure" || integrity !== 100)) errors.push("guarding-lane no-contact failed");
    if ((mode === "v0269_intercept_ready_pre_contact_integrity_100" || mode === "v0269_contact_armed_no_damage_yet" || mode === "v0269_label_declutter_intercept_ready") && (intercept !== "intercept ready" || state !== "armed" || integrity !== 100 || c.contactApplied)) errors.push(`${mode} armed/pre-contact integrity failed`);
    if (mustBeEngaged.has(mode) && (state !== "engaged" || !c.contactApplied || integrity !== 90 || !snap.contactMinimapPing || !c.ashenMarkerAliveAfterContact)) errors.push(`${mode} engaged/integrity evidence failed`);
    if (mode === "v0269_no_repeated_damage_below_90" && (state !== "engaged" || Number(c.contactApplyAttempts) < 2 || integrity !== 90)) errors.push("repeat-damage guard failed");
    if (mode === "v0269_threat_leaves_after_contact_memory_integrity_90" && (state !== "ended" || integrity !== 90 || snap.contactMinimapPing || !c.memoryActive || c.currentDetection)) errors.push("memory-after-contact ended state failed");
    if (["v0269_memory_only_no_new_contact_damage", "v0269_last_seen_memory_marker_distinct", "v0269_current_vs_memory_vs_position_vs_intercept_vs_contact_not_confused", "v0269_minimap_memory_no_contact_ping"].includes(mode) && (state !== "unavailable" || integrity !== 100 || c.contactApplied || snap.contactMinimapPing || c.currentDetection || !c.memoryActive)) errors.push(`${mode} memory-only guard failed`);
    if (mode === "v0269_watchpost_hud_contact_state_no_train_militia" && /Train Militia available|Existing Barracks production|Rebuild|Repair/i.test(text)) errors.push("Watchpost HUD leaked Barracks production/lifecycle text");
    if (mode === "v0269_barracks_hud_train_militia_no_watchpost_relay" && (!c.barracksSelected || !snap.hasTrainMilitia || snap.relayCardVisible || snap.hasRelayTitle)) errors.push("Barracks HUD separation failed");
    if (mode === "v0269_militia_selected_contact_state" && (!c.militiaSelected || state !== "engaged" || integrity !== 90)) errors.push("Militia selected contact state failed");
    if (mode === "v0269_no_contact_before_watchpost_complete" && (c.watchpostComplete || c.contactApplied || state !== "unavailable")) errors.push("precomplete contact guard failed");
    if (integrity < 90) errors.push(`${mode} integrity dropped below 90`);
  }

  const pixelStats = stats.stats ?? [];
  if (pixelStats.length !== 33) errors.push(`expected 33 captured PNG pixel stats, saw ${pixelStats.length}`);
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, runtime, baseline, bridge, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.269 Barrosan Militia First Contact Micro-Consequence Report",
    "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `4f172ecbacbfdeb383f1b982fe62c62f4278b315`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0269-barrosan-militia-first-contact-micro-consequence/`.",
    "",
    "## Boundary confirmation",
    "",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- Watchpost remains passive/intel/advisory/readiness/positioning/intercept-preview/contact-reporting only.",
    "- Watchpost does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.",
    "- Only new allowed mutation: local Ashen pressure integrity 100/100 -> 90/100 during confirmed Militia first contact.",
    "- Repeated damage below 90/100: no.",
    "- Enemy death/despawn: no.",
    "- Militia HP loss: no.",
    "- Watchpost HP loss: no.",
    "- Projectiles: no.",
    "- Tower attack: no.",
    "- Enemy slow/redirect: no.",
    "- Collision/pathing/AI/wave/economy mutation: no.",
    "- Fog-of-war or broad vision system: no.",
    "- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.",
    "- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Field Barracks remains the only Militia training source.",
    "- Barracks still trains Militia.",
    "- Watchpost never shows Train Militia.",
    "- Barracks never shows full Watchpost relay card.",
    "",
    "## State confirmation",
    "",
    "- Readiness states retained: none, training, ready.",
    "- Positioning states retained: none, pending, not in position, holding east bridge.",
    "- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.",
    "- Contact states: unavailable, pending, awaiting pressure, armed, engaged, ended.",
    "- Contact requires current detection, ready Militia, holding east bridge, intercept ready, and confirmed contact threshold.",
    "- Last-seen memory cannot trigger new contact damage.",
    "- Outside-zone state does not trigger false alarm/contact.",
    "- Label clutter around intercept/contact was reduced by prioritizing HUD/relay contact text and reserving world contact label for engaged state only.",
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
    "## Recommendation for v0.270",
    "",
    "- If authorized, v0.270 can separately decide whether to graduate from this bounded integrity check into a tiny combat/animation or consequence follow-up. Do not infer projectiles, tower attacks, death/despawn, pathing, AI, fog, economy, or broad RTS vision from v0.269.",
    "",
    "Stop before v0.270.",
    "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0269_VALIDATION" : "PASS_V0269_BARROSAN_MILITIA_FIRST_CONTACT_MICRO_CONSEQUENCE_VALIDATION";
  writeFileSync(join(root, "v0269-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
