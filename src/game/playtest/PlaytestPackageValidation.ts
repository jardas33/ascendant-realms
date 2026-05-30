export interface PlaytestPackageFileSnapshot {
  path: string;
  sizeBytes: number;
  textContent?: string;
}

export interface PlaytestPackageSnapshot {
  packageName: string;
  files: PlaytestPackageFileSnapshot[];
}

export interface PlaytestPackageValidationResult {
  ok: boolean;
  checks: string[];
  errors: string[];
}

export const REQUIRED_PLAYTEST_PACKAGE_FILES = [
  "game/index.html",
  "README_FOR_TESTERS.md",
  "PLAYTEST_BUILD_INFO.md",
  "playtest-build-info.json",
  "FEEDBACK_SUBMISSION_PACKET.md",
  "TESTER_QUICK_START.md",
  "ROUTE_ASSIGNMENT_PLAN.md",
  "CONTROL_RETEST_SCRIPT.md",
  "PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md",
  "BEHAVIOUR_MODE_TESTER_CHECKLIST.md",
  "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md",
  "CONTROL_REGRESSION_TRIAGE_GUIDE.md",
  "RELEASE_CANDIDATE_NOTES.md",
  "EMMANUEL_MANUAL_RETEST_CHECKLIST.md",
  "FIRST_TESTER_MESSAGE.md",
  "TESTER_FEEDBACK_FORM_SHORT.md",
  "ROUTE_ASSIGNMENTS_SMALL_BATCH.md",
  "TESTER_LAUNCH_PACKET_INDEX.md",
  "V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md",
  "V01613_BD26DE3_RETEST_INTAKE.md",
  "V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md",
  "V017_SOLO_PLAYTEST_INTAKE.md",
  "V017_WORKER_ECONOMY_DESIGN_SPEC.md",
  "V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md",
  "V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md",
  "V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md",
  "V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md",
  "V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md",
  "V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md",
  "V018_IMPLEMENTATION_REPORT.md",
  "V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md",
  "V0182_IMPLEMENTATION_REPORT.md",
  "V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md",
  "V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md",
  "V019_PRODUCTION_ARCHITECTURE_SPEC.md",
  "V019_IMPLEMENTATION_REPORT.md",
  "V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md",
  "V0191_REMOTE_CI_STATUS.md",
  "V0191_PRODUCTION_ROLE_POLISH_REPORT.md",
  "V020_TECH_TREE_FOUNDATION_SPEC.md",
  "V020_IMPLEMENTATION_REPORT.md",
  "V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md",
  "V021_WORKER_REPAIR_FOUNDATION_SPEC.md",
  "V021_IMPLEMENTATION_REPORT.md",
  "V0211_WORKER_REPAIR_CLOSEOUT.md",
  "V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md",
  "V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md",
  "V0213_WORKER_INTENT_CLOSEOUT.md",
  "V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md",
  "V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md",
  "V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md",
  "V022_IMPLEMENTATION_REPORT.md",
  "V022_EMMANUEL_RETEST_CHECKLIST.md",
  "V023_RESOURCE_SITE_UPGRADES_SPEC.md",
  "V023_IMPLEMENTATION_REPORT.md",
  "V023_EMMANUEL_RETEST_CHECKLIST.md",
  "V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md",
  "V024_IMPLEMENTATION_REPORT.md",
  "V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md",
  "V025_IMPLEMENTATION_REPORT.md",
  "V025_EMMANUEL_RETEST_CHECKLIST.md",
  "V026_ENEMY_BASE_DEVELOPMENT_SPEC.md",
  "V026_IMPLEMENTATION_REPORT.md",
  "V027_ENEMY_TECH_ESCALATION_SPEC.md",
  "V027_IMPLEMENTATION_REPORT.md",
  "V027_EMMANUEL_RETEST_CHECKLIST.md",
  "V028_HERO_PROGRESSION_SPEC.md",
  "V028_IMPLEMENTATION_REPORT.md",
  "V029_HERO_ABILITIES_AND_REWARDS_SPEC.md",
  "V029_IMPLEMENTATION_REPORT.md",
  "V029_EMMANUEL_RETEST_CHECKLIST.md",
  "V0291_BLOCKED_REMOTE_CI_STATUS.md",
  "V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md",
  "V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md",
  "V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md",
  "V0292_RELEASE_MATRIX_CLOSEOUT.md",
  "V0292_EMMANUEL_RETEST_CHECKLIST.md",
  "V0292_LONG_SOAK_REPORT.md",
  "V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md",
  "V031_RELIC_REWARD_FOUNDATION_SPEC.md",
  "V030_IMPLEMENTATION_REPORT.md",
  "V031_IMPLEMENTATION_REPORT.md",
  "V031_EMMANUEL_RETEST_CHECKLIST.md",
  "V032_PERSISTENT_RELIC_INVENTORY_SPEC.md",
  "V033_HERO_RELIC_LOADOUT_SPEC.md",
  "V032_IMPLEMENTATION_REPORT.md",
  "V033_IMPLEMENTATION_REPORT.md",
  "V033_EMMANUEL_RETEST_CHECKLIST.md",
  "V034_RELIC_REWARD_CHOICE_SPEC.md",
  "V035_HERO_BUILD_IDENTITY_SPEC.md",
  "V034_IMPLEMENTATION_REPORT.md",
  "V035_IMPLEMENTATION_REPORT.md",
  "V035_EMMANUEL_RETEST_CHECKLIST.md",
  "V036_HERO_SKILL_TREE_FOUNDATION_SPEC.md",
  "V037_ABILITY_UPGRADE_FOUNDATION_SPEC.md",
  "V038_RELIC_BUILD_SYNERGY_SPEC.md",
  "V036_IMPLEMENTATION_REPORT.md",
  "V037_IMPLEMENTATION_REPORT.md",
  "V038_IMPLEMENTATION_REPORT.md",
  "V038_EMMANUEL_RETEST_CHECKLIST.md",
  "V039_CAMPAIGN_PROGRESSION_FOUNDATION_SPEC.md",
  "V040_MISSION_REWARD_STRUCTURE_SPEC.md",
  "V041_REPLAY_AND_OBJECTIVE_STATE_SPEC.md",
  "V039_IMPLEMENTATION_REPORT.md",
  "V040_IMPLEMENTATION_REPORT.md",
  "V041_IMPLEMENTATION_REPORT.md",
  "V041_EMMANUEL_RETEST_CHECKLIST.md",
  "V042_MISSION_VARIETY_FOUNDATION_SPEC.md",
  "V043_SCENARIO_MODIFIERS_SPEC.md",
  "V044_CAMPAIGN_PACING_AND_BRIEFING_SPEC.md",
  "V042_IMPLEMENTATION_REPORT.md",
  "V043_IMPLEMENTATION_REPORT.md",
  "V044_IMPLEMENTATION_REPORT.md",
  "V044_EMMANUEL_RETEST_CHECKLIST.md",
  "V045_ACT1_CAMPAIGN_SPINE_SPEC.md",
  "V046_DIFFICULTY_PACING_FOUNDATION_SPEC.md",
  "V047_ONBOARDING_AND_PLAYER_GUIDANCE_SPEC.md",
  "V045_IMPLEMENTATION_REPORT.md",
  "V046_IMPLEMENTATION_REPORT.md",
  "V047_IMPLEMENTATION_REPORT.md",
  "V047_EMMANUEL_RETEST_CHECKLIST.md",
  "V048_ACT1_PLAYABILITY_AUDIT_PLAN.md",
  "V048_ACT1_PLAYTEST_TELEMETRY_REPORT.md",
  "V048_IMPLEMENTATION_REPORT.md",
  "V049_ACT1_BALANCE_AND_TELEMETRY_REPORT.md",
  "V050_ACT1_RELEASE_CANDIDATE_NOTES.md",
  "V050_IMPLEMENTATION_REPORT.md",
  "V050_EMMANUEL_RETEST_CHECKLIST.md",
  "V051_PLAYER_UX_AUDIT_PLAN.md",
  "V051_PLAYER_UX_AUDIT_REPORT.md",
  "V051_IMPLEMENTATION_REPORT.md",
  "V052_COMMAND_AND_CURSOR_READABILITY_REPORT.md",
  "V053_COMBAT_AND_RESULTS_READABILITY_REPORT.md",
  "V053_EMMANUEL_RETEST_CHECKLIST.md",
  "V054_CONTROL_GROUPS_FOUNDATION_SPEC.md",
  "V055_FORMATION_AWARE_MOVEMENT_SPEC.md",
  "V056_PATROL_FOUNDATION_SPEC.md",
  "V054_IMPLEMENTATION_REPORT.md",
  "V055_IMPLEMENTATION_REPORT.md",
  "V056_IMPLEMENTATION_REPORT.md",
  "V056_EMMANUEL_RETEST_CHECKLIST.md",
  "V057_ARMY_VETERANCY_FOUNDATION_SPEC.md",
  "V058_UNIT_ROLE_IDENTITY_SPEC.md",
  "V059_TACTICAL_COMBAT_FEEDBACK_SPEC.md",
  "V057_IMPLEMENTATION_REPORT.md",
  "V058_IMPLEMENTATION_REPORT.md",
  "V059_IMPLEMENTATION_REPORT.md",
  "V059_EMMANUEL_RETEST_CHECKLIST.md",
  "V060_RETINUE_PERSISTENCE_FOUNDATION_SPEC.md",
  "V061_PRE_BATTLE_DEPLOYMENT_SPEC.md",
  "V062_SURVIVOR_CONTINUITY_AND_RESULTS_SPEC.md",
  "V060_IMPLEMENTATION_REPORT.md",
  "V061_IMPLEMENTATION_REPORT.md",
  "V062_IMPLEMENTATION_REPORT.md",
  "V062_EMMANUEL_RETEST_CHECKLIST.md",
  "V063_RETINUE_RECOVERY_SPEC.md",
  "V064_RESERVE_MANAGEMENT_SPEC.md",
  "V065_BATTLEFIELD_REINFORCEMENT_SPEC.md",
  "V063_IMPLEMENTATION_REPORT.md",
  "V064_IMPLEMENTATION_REPORT.md",
  "V065_IMPLEMENTATION_REPORT.md",
  "V065_EMMANUEL_RETEST_CHECKLIST.md",
  "V066_ENEMY_TACTICAL_DOCTRINES_SPEC.md",
  "V067_ELITE_SQUAD_FOUNDATION_SPEC.md",
  "V068_COUNTERPLAY_READABILITY_SPEC.md",
  "V066_IMPLEMENTATION_REPORT.md",
  "V067_IMPLEMENTATION_REPORT.md",
  "V068_IMPLEMENTATION_REPORT.md",
  "V068_EMMANUEL_RETEST_CHECKLIST.md",
  "V069_PRE_BATTLE_INTELLIGENCE_SPEC.md",
  "V070_TACTICAL_PLAN_SELECTION_SPEC.md",
  "V071_COUNTER_DOCTRINE_PREPARATION_SPEC.md",
  "V069_IMPLEMENTATION_REPORT.md",
  "V070_IMPLEMENTATION_REPORT.md",
  "V071_IMPLEMENTATION_REPORT.md",
  "V071_EMMANUEL_RETEST_CHECKLIST.md",
  "V072_BATTLEFIELD_EVENT_DIRECTOR_SPEC.md",
  "V073_DYNAMIC_TACTICAL_OBJECTIVES_SPEC.md",
  "V074_ADAPTIVE_PRESSURE_AND_READABILITY_SPEC.md",
  "V072_IMPLEMENTATION_REPORT.md",
  "V073_IMPLEMENTATION_REPORT.md",
  "V074_IMPLEMENTATION_REPORT.md",
  "V074_EMMANUEL_RETEST_CHECKLIST.md",
  "V075_ACT1_FINALE_ENCOUNTER_SPEC.md",
  "V076_RIVAL_COMMANDER_PHASES_SPEC.md",
  "V077_MILESTONE_REWARD_AND_DEBRIEF_SPEC.md",
  "V075_IMPLEMENTATION_REPORT.md",
  "V076_IMPLEMENTATION_REPORT.md",
  "V077_IMPLEMENTATION_REPORT.md",
  "V077_EMMANUEL_RETEST_CHECKLIST.md",
  "V078_CREATIVE_IDENTITY_LOCK_PLAN.md",
  "V078_PUBLIC_TITLE_AND_BRAND_OPTIONS.md",
  "V078_WORLD_AND_LORE_BIBLE_DRAFT.md",
  "V078_RACE_AND_FACTION_MASTER_MATRIX.md",
  "V078_HERO_RACE_CLASS_ORIGIN_OATH_ARCHITECTURE.md",
  "V078_SIGNATURE_GAMEPLAY_PILLARS.md",
  "V078_LONG_CAMPAIGN_MASTER_OUTLINE.md",
  "V078_BROWSER_TO_DESKTOP_TRANSITION_GATE.md",
  "V078_VISUAL_DIRECTION_AND_AI_ART_GOVERNANCE.md",
  "V078_VISUAL_VERTICAL_SLICE_BRIEF.md",
  "V078_DISPLAY_NAME_MIGRATION_MAP.md",
  "V078_ORIGINAL_IP_SEPARATION_LEDGER.md",
  "V078_FUTURE_IMPLEMENTATION_SEQUENCE.md",
  "V078_EMMANUEL_REVIEW_PACKET.md",
  "V078_IMPLEMENTATION_REPORT.md",
  "V079_EMMANUEL_APPROVAL_LEDGER.md",
  "V079_DIRECTION_LOCK_SUMMARY.md",
  "V079_VERTICAL_SLICE_PRIORITY_LOCK.md",
  "V079_FIRST_SIGNATURE_SYSTEM_PRIORITY.md",
  "V079_DEFERRED_DECISIONS_REGISTER.md",
  "V079_SAFE_NEXT_MILESTONE_SEQUENCE.md",
  "V079_IMPLEMENTATION_REPORT.md",
  "V080_RUNTIME_FACING_STRING_INVENTORY.json",
  "V080_TERMINOLOGY_TAXONOMY.md",
  "V080_DISPLAY_COPY_MIGRATION_MAP.md",
  "V080_SAFE_COPY_BATCHES.md",
  "V080_TEST_AND_ROLLBACK_PLAN.md",
  "V080_EMMANUEL_REVIEW_PACKET.md",
  "V080_IMPLEMENTATION_REPORT.md",
  "V081_EXISTING_SITE_SYSTEM_AUDIT.md",
  "V081_LUME_NETWORK_DESIGN_PRINCIPLES.md",
  "V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md",
  "V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md",
  "V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md",
  "V081_DATA_MODEL_AND_INTEGRATION_PLAN.md",
  "V081_UI_READABILITY_AND_TEACHING_SPEC.md",
  "V081_RACE_EXTENSIBILITY_MATRIX.md",
  "V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md",
  "V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md",
  "V081_FUTURE_IMPLEMENTATION_SEQUENCE.md",
  "V081_EMMANUEL_REVIEW_PACKET.md",
  "V081_IMPLEMENTATION_REPORT.md",
  "V082_LUME_NETWORK_RUNTIME_PROTOTYPE_SPEC.md",
  "V082_LINKED_WARD_BALANCE_AND_READABILITY_REPORT.md",
  "V082_LUME_NETWORK_TEST_AND_SAFETY_REPORT.md",
  "V082_IMPLEMENTATION_REPORT.md",
  "V082_EMMANUEL_RETEST_CHECKLIST.md",
  "ACT1_PLAYABILITY_TELEMETRY.md",
  "ACT1_PLAYABILITY_TELEMETRY.json",
  "start-playtest-server.mjs",
  "START_GAME_WINDOWS.bat",
  "START_GAME_MAC_LINUX.sh"
] as const;

const FORBIDDEN_PATH_PARTS = [
  "node_modules",
  ".git",
  "docs/playtest-feedback",
  "playtest-feedback/raw",
  "private-feedback",
  "raw-private-feedback",
  "tester-private-feedback"
];

const FORBIDDEN_FILE_NAMES = [".env", ".env.local", ".env.production", "id_rsa", "id_ed25519"];

const SECRET_PATTERNS: Array<{ label: string; pattern: RegExp }> = [
  { label: "private key block", pattern: /-----BEGIN [A-Z ]*PRIVATE KEY-----/u },
  { label: "OpenAI API key assignment", pattern: /OPENAI_API_KEY\s*=/iu },
  { label: "GitHub token assignment", pattern: /GITHUB_TOKEN\s*=/iu },
  { label: "AWS secret assignment", pattern: /AWS_SECRET_ACCESS_KEY\s*=/iu },
  { label: "service role key assignment", pattern: /SERVICE_ROLE_KEY\s*=/iu },
  { label: "Vite secret assignment", pattern: /VITE_[A-Z0-9_]*SECRET\s*=/iu }
];

export function validatePlaytestPackageSnapshot(snapshot: PlaytestPackageSnapshot): PlaytestPackageValidationResult {
  const checks: string[] = [];
  const errors: string[] = [];
  const files = snapshot.files.map((file) => ({ ...file, path: normalizePackagePath(file.path) }));
  const fileSet = new Set(files.map((file) => file.path.toLowerCase()));

  REQUIRED_PLAYTEST_PACKAGE_FILES.forEach((requiredPath) => {
    if (fileSet.has(requiredPath.toLowerCase())) {
      checks.push(`required file present: ${requiredPath}`);
    } else {
      errors.push(`Missing required package file: ${requiredPath}.`);
    }
  });

  if (files.some((file) => file.path.startsWith("game/assets/") && file.sizeBytes > 0)) {
    checks.push("built game assets present");
  } else {
    errors.push("Missing built game assets under game/assets/.");
  }

  files.forEach((file) => {
    const lowerPath = file.path.toLowerCase();
    FORBIDDEN_PATH_PARTS.forEach((part) => {
      if (lowerPath === part || lowerPath.includes(`/${part}/`) || lowerPath.startsWith(`${part}/`)) {
        errors.push(`Forbidden package path included: ${file.path}.`);
      }
    });

    const fileName = lowerPath.split("/").at(-1) ?? lowerPath;
    if (FORBIDDEN_FILE_NAMES.includes(fileName)) {
      errors.push(`Forbidden secret-like file included: ${file.path}.`);
    }

    if (file.textContent !== undefined) {
      SECRET_PATTERNS.forEach(({ label, pattern }) => {
        if (pattern.test(file.textContent ?? "")) {
          errors.push(`Possible secret detected in ${file.path}: ${label}.`);
        }
      });
    }
  });

  if (errors.length === 0) {
    checks.push("no forbidden paths or obvious secrets detected");
  }

  const indexHtml = files.find((file) => file.path.toLowerCase() === "game/index.html")?.textContent ?? "";
  if (indexHtml.includes('src="/assets/') || indexHtml.includes('href="/assets/')) {
    errors.push("game/index.html uses absolute /assets/ URLs; playtest builds should use relative assets.");
  } else if (indexHtml.length > 0) {
    checks.push("game/index.html uses package-safe relative asset URLs");
  }

  const buildInfoText = files.find((file) => file.path.toLowerCase() === "playtest-build-info.json")?.textContent;
  if (buildInfoText) {
    validateBuildInfo(buildInfoText, checks, errors);
  }

  return { ok: errors.length === 0, checks, errors };
}

export function assertPlaytestPackageSnapshot(snapshot: PlaytestPackageSnapshot): PlaytestPackageValidationResult {
  const result = validatePlaytestPackageSnapshot(snapshot);
  if (!result.ok) {
    throw new Error(`Playtest package validation failed:\n${result.errors.map((error) => `- ${error}`).join("\n")}`);
  }
  return result;
}

function validateBuildInfo(buildInfoText: string, checks: string[], errors: string[]): void {
  try {
    const parsed = JSON.parse(buildInfoText) as Record<string, unknown>;
    expectString(parsed.commit, "build info commit", checks, errors);
    expectString(parsed.shortCommit, "build info shortCommit", checks, errors);
    expectString(parsed.generatedAtUtc, "build info generatedAtUtc", checks, errors);
    expectEqual(
      parsed.checkpoint,
      "v0.82 mission-local Lume Network runtime prototype",
      "build info checkpoint",
      checks,
      errors
    );
    expectEqual(parsed.packagePurpose, "private human playtest distribution", "build info package purpose", checks, errors);
    expectEqual(parsed.requiresLocalServer, true, "build info local server requirement", checks, errors);
  } catch (error) {
    errors.push(`playtest-build-info.json is not valid JSON: ${String(error)}.`);
  }
}

function expectString(value: unknown, label: string, checks: string[], errors: string[]): void {
  if (typeof value === "string" && value.trim().length > 0) {
    checks.push(label);
  } else {
    errors.push(`${label} is missing or empty.`);
  }
}

function expectEqual(actual: unknown, expected: unknown, label: string, checks: string[], errors: string[]): void {
  if (Object.is(actual, expected)) {
    checks.push(label);
  } else {
    errors.push(`${label} mismatch: expected ${String(expected)}, got ${String(actual)}.`);
  }
}

function normalizePackagePath(path: string): string {
  return path.replaceAll("\\", "/").replace(/^\.?\//u, "");
}
