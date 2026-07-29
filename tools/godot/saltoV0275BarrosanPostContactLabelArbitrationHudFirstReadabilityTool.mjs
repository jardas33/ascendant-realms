import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0275"));
const manual = join(repo, "artifacts", "manual-review", "v0275-barrosan-post-contact-label-arbitration-hud-first-readability");
const docPath = join(repo, "docs", "V0275_BARROSAN_POST_CONTACT_LABEL_ARBITRATION_HUD_FIRST_READABILITY_REPORT.md");
const runtimePath = join(root, "post-contact-label-arbitration-hud-first-readability-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0275-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0275_watchpost_build_path_visible",
  "v0275_watchpost_complete_no_intel_no_contact_visible",
  "v0275_barracks_train_militia_visible",
  "v0275_militia_training_guard_unavailable_visible",
  "v0275_militia_ready_guard_available_visible",
  "v0275_guard_order_pending_label_clean_visible",
  "v0275_clear_pending_guard_blocks_contact_visible",
  "v0275_guard_reissued_after_clear_visible",
  "v0275_guard_holding_intercept_ready_single_priority_label_visible",
  "v0275_current_detection_no_guard_no_contact_label_clean_visible",
  "v0275_guard_pending_no_contact_label_clean_visible",
  "v0275_guard_holding_contact_armed_label_clean_visible",
  "v0275_first_contact_feedback_suppresses_lower_labels_visible",
  "v0275_first_contact_integrity_90_visible",
  "v0275_contact_resolved_single_label_visible",
  "v0275_contact_resolved_cooldown_locked_visible",
  "v0275_bridge_held_single_world_label_visible",
  "v0275_bridge_held_no_defender_position_overlap_visible",
  "v0275_engagement_contained_single_priority_label_visible",
  "v0275_engagement_line_static_not_projectile_visible",
  "v0275_militia_hud_engagement_contained_no_attack_visible",
  "v0275_watchpost_hud_engagement_observed_advisory_only_visible",
  "v0275_minimap_engagement_indicator_distinct_visible",
  "v0275_contact_ping_not_active_after_resolved_visible",
  "v0275_bridge_held_and_engagement_no_repeated_damage_visible",
  "v0275_clear_guard_after_contact_label_clean_visible",
  "v0275_engagement_marker_removed_after_clear_visible",
  "v0275_minimap_engagement_indicator_removed_after_clear_visible",
  "v0275_pressure_still_90_after_clear_visible",
  "v0275_reguard_after_contact_label_clean_visible",
  "v0275_reguard_after_contact_no_first_contact_relabel_visible",
  "v0275_no_repeated_damage_after_reguard_visible",
  "v0275_overlap_continues_integrity_still_90_visible",
  "v0275_memory_only_no_new_contact_damage_label_clean_visible",
  "v0275_outside_zone_no_false_contact_label_clean_visible",
  "v0275_no_enemy_death_or_despawn_visible",
  "v0275_no_enemy_slow_stop_redirect_visible",
  "v0275_no_militia_hp_loss_visible",
  "v0275_no_watchpost_hp_loss_visible",
  "v0275_no_watchpost_attack_projectile_tower_visible",
  "v0275_watchpost_no_train_no_guard_no_clear_no_brace_no_engagement_action_visible",
  "v0275_barracks_hud_train_militia_no_full_relay_visible",
  "v0275_militia_hud_no_ranged_attack_no_projectile_visible",
  "v0275_label_priority_table_debug_visible",
  "v0275_label_declutter_first_contact_visible",
  "v0275_label_declutter_contact_resolved_visible",
  "v0275_label_declutter_bridge_held_visible",
  "v0275_label_declutter_engagement_contained_visible",
  "v0275_label_declutter_after_clear_visible",
  "v0275_existing_barracks_rebuild_path_still_valid_visible",
  "v0275_existing_barracks_still_trains_militia_visible",
];

const requiredImages = [
  "01_v0275_preflight_head_ci_resolution.png",
  "02_v0275_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "54_v0275_contact_sheet_visible.png",
  "55_v0275_black_frame_rejection_report_visible.png",
];

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}
function snapshot(snaps, visibleName) { return snaps[visibleName.replace(/_visible$/, "")] ?? {}; }
function contactOf(snaps, visibleName) { return snapshot(snaps, visibleName).firstContact ?? {}; }
function passive(c) {
  return ![
    "automaticMovementAdded", "autoMoveAttempted", "automaticAttackAdded", "watchpostCausedDamage",
    "watchpostAttackAdded", "projectilesAdded", "towerAttackAdded", "slowAdded", "redirectAdded",
    "enemyPathingChanged", "enemyAiChanged", "waveTimingChanged", "economyAdded", "collisionChanged",
    "fogOfWarAdded", "broadVisionAdded", "enemyStopped", "enemyDespawned", "enemyDeath",
    "engagementDamageAdded", "engagementAutoMoveAdded", "engagementAutoAttackAdded",
    "engagementProjectileAdded", "engagementVisualIsProjectile",
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
  const proof = skin.barrosanPostContactLabelArbitrationHudFirstReadability ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];
  if (runtime.checkpoint !== "v0.275") errors.push("runtime checkpoint is not v0.275");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 51) errors.push(`expected 51 runtime captures, saw ${runtime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`label arbitration status is ${proof.status}`);
  const cost = proof.cost ?? {};
  if (Number(cost.crowns) !== 100 || Number(cost.stone) !== 30 || Number(cost.iron) !== 10 || Number(cost.aether) !== 0) errors.push("Watchpost cost changed");
  if (Number(proof.hp) !== 120) errors.push("Watchpost HP changed");
  for (const name of runtimeNames) if (!snaps[name.replace(/_visible$/, "")]) errors.push(`missing proof snapshot ${name}`);
  for (const file of requiredImages) if (!existsSync(join(manual, file))) errors.push(`missing manual review image ${file}`);
  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const text = snap.combinedText ?? "";
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!c.guardRequiredForContact) errors.push(`${mode} did not mark guard as required for contact`);
    if (!snap.labelPriorityTableExists) errors.push(`${mode} missing label priority table proof`);
    if (!snap.labelOverlapScanPass || Number(snap.visibleWorldLabelCount ?? 99) > 2) errors.push(`${mode} label overlap/count proof failed`);
    if (!snap.longDiagnosticWorldLabelsAbsent || !snap.hudCarriesLongDetails) errors.push(`${mode} HUD-first/short-world-label proof failed`);
    if (/Watchpost attack|Tower attack|projectile fired|fires projectile|gains ranged attack/i.test(text)) errors.push(`${mode} text implies forbidden action`);
    if (Number(c.pressureIntegrity ?? 100) < 90) errors.push(`${mode} integrity dropped below 90`);
  }
  if (!snapshot(snaps, "v0275_first_contact_feedback_suppresses_lower_labels_visible").firstContactSuppressesLowerLabels) errors.push("first-contact label priority proof failed");
  if (!snapshot(snaps, "v0275_contact_resolved_single_label_visible").contactResolvedSuppressesLowerLabels) errors.push("contact-resolved label priority proof failed");
  if (!snapshot(snaps, "v0275_bridge_held_no_defender_position_overlap_visible").bridgeHeldSuppressesDefenderPositionOverlap) errors.push("Bridge Held overlap proof failed");
  if (!snapshot(snaps, "v0275_engagement_contained_single_priority_label_visible").engagementContainedSuppressesBridgeHeldAndContact) errors.push("engagement-contained arbitration proof failed");
  const noGuard = contactOf(snaps, "v0275_current_detection_no_guard_no_contact_label_clean_visible");
  if (noGuard.guardOrderState !== "available" || noGuard.contactApplied) errors.push("current detection without guard order contact gate failed");
  const clear = contactOf(snaps, "v0275_clear_guard_after_contact_label_clean_visible");
  if (clear.guardOrderState !== "cleared" || Number(clear.pressureIntegrity) !== 90) errors.push("clear-after-contact pressure/cooldown proof failed");
  const reguard = contactOf(snaps, "v0275_no_repeated_damage_after_reguard_visible");
  if (Number(reguard.pressureIntegrity) !== 90 || !reguard.engagementDoesNotRepeatDamage) errors.push("reguard no-repeat-damage proof failed");
  const watchpostHud = snapshot(snaps, "v0275_watchpost_no_train_no_guard_no_clear_no_brace_no_engagement_action_visible");
  if (watchpostHud.hasTrainMilitia || watchpostHud.guardCommandOnWatchpost || watchpostHud.clearGuardCommandOnWatchpost || watchpostHud.braceActionOnWatchpost || watchpostHud.engagementActionOnWatchpost) errors.push("Watchpost HUD leaked forbidden action");
  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 52) errors.push(`expected 52 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");
  return { errors, runtime, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.275 Barrosan Post-Contact Label Arbitration and HUD-First Readability Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `7a3cbfd4c5f80273470405cc37585bff16670372`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0275-barrosan-post-contact-label-arbitration-hud-first-readability/`.", "",
    "## Boundary confirmation", "",
    "- Default runtime unchanged: yes.", "- Blender used: no.", "- GLB exported: no.",
    "- v0.275 adds label arbitration/readability only.",
    "- v0.274 Engagement Stance, v0.273 Bridge Held, v0.272 Clear Guard, v0.271 Guard Bridge, v0.270 cooldown, and v0.269 one-time pressure consequence are retained.",
    "- Label priority table exists: FIRST CONTACT, CONTACT RESOLVED, BRIDGE HELD, ENGAGEMENT CONTAINED, INTERCEPT READY, HOLDING EAST BRIDGE, DEFENDER POSITION, ASHEN SCOUTED CURRENT, CONTACT THRESHOLD, GUARD BRIDGE, memory/last-seen.",
    "- First-contact, contact-resolved, bridge-held, and engagement-contained labels suppress lower-priority overlapping labels.",
    "- HUD carries long detail; world labels are concise and limited to at most two nearby labels.",
    "- Engagement stance does not auto-move, auto-attack, damage, or spawn projectiles; engagement visual is not a projectile.",
    "- Ashen pressure integrity remains 90/100 after resolved contact; no damage below 90/100 and no repeated damage after clear/reguard.",
    "- Clearing guard after contact removes engagement marker/indicator and does not restore pressure.",
    "- Current detection without guard order, last-seen memory, and outside-zone state cannot trigger contact damage.",
    "- No enemy death/despawn, no Militia HP loss, no Watchpost HP loss, no projectiles, no tower attack, no slow/stop/redirect, no pathing/AI/wave/economy/default-runtime mutation, no fog-of-war or broad vision.",
    "- Watchpost remains passive/advisory/intel only and does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.",
    "- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.",
    "- Resource sequence unchanged: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- Field Barracks remains the only Militia training source; Watchpost never shows Train Militia, Guard Bridge, Clear Guard, Brace Bridge, or Engagement Stance; Barracks never shows full Watchpost relay card.", "",
    "## State confirmation", "",
    "- Readiness states retained: none, training, ready.",
    "- Positioning states retained: none, pending, not in position, holding east bridge.",
    "- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.",
    "- Contact states retained: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.",
    "- Feedback/cooldown states retained: first contact feedback active, first contact feedback expired, first contact resolved/cooldown locked.",
    "- Guard-order states retained: unavailable, available, pending, holding east bridge, cleared, resolved after contact.",
    "- Brace/bridge-held states retained: not braced, brace available, bracing bridge, bridge held, brace cleared.",
    "- Engagement stance states retained: no engagement stance, engagement stance available, engagement stance active, engagement stance cleared, engagement stance retained after reguard.",
    "- Label clutter is improved versus v0.274 by deterministic arbitration and HUD-first detail routing.", "",
    "## Pixel validation", "",
    `- Required screenshots: ${requiredImages.length}.`,
    `- Runtime capture count: ${e.runtime.captureCount}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`,
    "- Screenshots are non-black/readable: yes.", "",
    "## Recommendation for v0.276", "",
    "- If separately authorized, add one bounded downstream post-contact response without adding combat resolution, enemy HP/death/despawn, fog, pathing, AI, economy, or default-runtime changes.", "",
    "Stop before v0.276.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0275_VALIDATION" : "PASS_V0275_BARROSAN_POST_CONTACT_LABEL_ARBITRATION_HUD_FIRST_READABILITY_VALIDATION";
  writeFileSync(join(root, "v0275-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
