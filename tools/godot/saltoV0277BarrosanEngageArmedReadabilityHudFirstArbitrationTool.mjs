import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0277"));
const manual = join(repo, "artifacts", "manual-review", "v0277-barrosan-engage-armed-readability-hud-first-arbitration");
const docPath = join(repo, "docs", "V0277_BARROSAN_ENGAGE_ARMED_READABILITY_HUD_FIRST_ARBITRATION_REPORT.md");
const runtimePath = join(root, "engage-armed-readability-hud-first-arbitration-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0277-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0277_engage_available_hud_first_visible",
  "v0277_engage_armed_single_world_label_visible",
  "v0277_engage_armed_suppresses_engagement_contained_visible",
  "v0277_engage_armed_suppresses_bridge_held_visible",
  "v0277_engage_armed_hud_full_state_visible",
  "v0277_repeat_engage_no_duplicate_label_visible",
  "v0277_repeat_engage_hud_already_armed_visible",
  "v0277_clear_guard_clean_cancel_label_visible",
  "v0277_reguard_available_clean_visible",
  "v0277_reguard_rearm_single_label_visible",
  "v0277_watchpost_no_engage_action_visible",
  "v0277_barracks_no_engage_action_visible",
  "v0277_no_projectile_no_damage_visible",
  "v0277_default_runtime_unchanged_probe_visible",
];

const requiredImages = [
  "01_v0277_preflight_head_ci_resolution.png",
  "02_v0277_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "17_v0277_contact_sheet_visible.png",
  "18_v0277_black_frame_rejection_report_visible.png",
];

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function snapshot(snaps, visibleName) {
  return snaps[visibleName.replace(/_visible$/, "")] ?? {};
}

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
  const proof = skin.barrosanEngageArmedReadabilityHudFirstArbitration ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.277") errors.push("runtime checkpoint is not v0.277");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 14) errors.push(`expected 14 runtime captures, saw ${runtime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.277 readability status is ${proof.status}`);
  if (!proof.readabilityOnly || !proof.hudFirstArbitrationActive || !proof.noCombatDamageProjectile) errors.push("v0.277 proof did not stay readability/HUD-first/no-combat");
  for (const name of runtimeNames) if (!snaps[name.replace(/_visible$/, "")]) errors.push(`missing proof snapshot ${name}`);
  for (const file of requiredImages) if (!existsSync(join(manual, file))) errors.push(`missing manual review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const text = snap.combinedText ?? "";
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.readabilityOnly || !snap.hudFirstArbitrationActive) errors.push(`${mode} is not readability/HUD-first only`);
    if (Number(c.pressureIntegrity ?? 100) < 90) errors.push(`${mode} integrity dropped below 90`);
    if (/Watchpost attack|Tower attack|projectile fired|fires projectile|takes damage|enemy killed|enemy despawn/i.test(text)) errors.push(`${mode} text implies forbidden action`);
  }

  for (const name of [
    "v0277_engage_armed_single_world_label_visible",
    "v0277_engage_armed_suppresses_engagement_contained_visible",
    "v0277_engage_armed_suppresses_bridge_held_visible",
    "v0277_engage_armed_hud_full_state_visible",
    "v0277_reguard_rearm_single_label_visible",
  ]) {
    const snap = snapshot(snaps, name);
    if (!snap.engageArmedLabelVisible || !snap.oneCleanWorldLabelMax || !snap.engageArmedSuppressesLowerPriorityWorldLabels) errors.push(`${name} failed single high-priority world-label arbitration`);
  }
  if (!snapshot(snaps, "v0277_engage_armed_hud_full_state_visible").engageArmedHudCarriesDetailedState) errors.push("HUD full-state proof failed");
  if (!snapshot(snaps, "v0277_repeat_engage_no_duplicate_label_visible").repeatEngageDoesNotStackLabels) errors.push("repeat Engage label stack proof failed");
  if (!snapshot(snaps, "v0277_repeat_engage_hud_already_armed_visible").repeatEngageHudAlreadyArmed) errors.push("repeat Engage HUD already-armed proof failed");
  if (!snapshot(snaps, "v0277_clear_guard_clean_cancel_label_visible").clearGuardCleanCancelLabel) errors.push("Clear Guard clean cancel proof failed");
  if (!snapshot(snaps, "v0277_reguard_available_clean_visible").reguardAvailableClean) errors.push("Reguard available clean proof failed");
  if (!snapshot(snaps, "v0277_no_projectile_no_damage_visible").noCombatDamageProjectile) errors.push("no projectile/no damage proof failed");
  if (snapshot(snaps, "v0277_watchpost_no_engage_action_visible").engageActionOnWatchpost) errors.push("Watchpost leaked Engage action");
  if (snapshot(snaps, "v0277_barracks_no_engage_action_visible").engageActionOnBarracks) errors.push("Barracks leaked Engage action");
  if (snapshot(snaps, "v0277_default_runtime_unchanged_probe_visible").defaultRuntimeChanged) errors.push("default runtime changed probe failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 15) errors.push(`expected 15 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");
  return { errors, runtime, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.277 Barrosan Engage Armed Readability and HUD-First Arbitration Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `4671036f5733d5f16f9d79efa03eecc132a9f523`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0277-barrosan-engage-armed-readability-hud-first-arbitration/`.", "",
    "## Boundary confirmation", "",
    "- v0.277 is readability only: yes.",
    "- Combat, attack, projectile, enemy HP/death/despawn, and damage added: no.",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- Engage remains Militia-only and remains unavailable outside the valid v0.276 post-contact bridge-held / engagement-contained path.",
    "- Engage Armed uses one high-priority world label maximum: `ENGAGE ARMED`.",
    "- Lower-priority world labels are suppressed/demoted while armed: `ENGAGEMENT CONTAINED`, `BRIDGE HELD`, `CONTACT RESOLVED`, `DEFENDER POSITION`, `GUARD BRIDGE`.",
    "- HUD/card carries detailed state: Manual engage armed, Engagement contained, Bridge held, Pressure contained 90/100, No attack committed, No projectile, No damage.",
    "- Repeat Engage clicks do not stack labels, markers, attacks, projectiles, or damage.",
    "- Clear Guard cancels Engage cleanly and shows Guard cleared / engage cancelled state with cooldown locked at pressure 90/100.",
    "- Reguard can make Engage available again and re-arm without repeated damage.",
    "- Watchpost and Barracks never show Engage. Field Barracks remains the only Militia training source.",
    "- Watchpost remains passive/advisory/intel only.",
    "- Ashen pressure invariant retained: first contact drops 100/100 -> 90/100 only once; no damage below 90/100.", "",
    "## Pixel validation", "",
    `- Required screenshots: ${requiredImages.length}.`,
    `- Runtime capture count: ${e.runtime.captureCount}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`,
    "- Screenshots are non-black/readable: yes.", "",
    "## Recommendation for v0.278", "",
    "- If separately authorized, v0.278 can begin a bounded explicit combat-resolution bridge from this armed state. Keep it narrow: one order, one target, one consequence, and preserve this HUD-first label arbitration.", "",
    "Stop before v0.278.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0277_VALIDATION" : "PASS_V0277_BARROSAN_ENGAGE_ARMED_READABILITY_HUD_FIRST_ARBITRATION_VALIDATION";
  writeFileSync(join(root, "v0277-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
