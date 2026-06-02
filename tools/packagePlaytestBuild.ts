import { execFileSync } from "node:child_process";
import { cp, mkdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import { dirname, join, relative, resolve, sep } from "node:path";
import process from "node:process";

const PACKAGE_ROOT = resolve("artifacts", "playtest");
const DIST_DIR = resolve("dist");
const CHECKPOINT = "v0.103 Battlefield Clutter Reduction and Private Performance Profiler";
const PACKAGE_PURPOSE = "private human playtest distribution";

interface PlaytestBuildInfo {
  packageName: string;
  checkpoint: string;
  packagePurpose: string;
  commit: string;
  shortCommit: string;
  workingTreeDirty: boolean;
  generatedAtUtc: string;
  gameDirectory: string;
  startCommand: string;
  requiresLocalServer: boolean;
  feedbackFile: string;
  knownWarnings: string[];
  notForJudging: string[];
}

async function main(): Promise<void> {
  await assertDirectoryExists(DIST_DIR, "dist");

  const commit = gitOutput(["rev-parse", "HEAD"]);
  const shortCommit = gitOutput(["rev-parse", "--short=7", "HEAD"]);
  const dirty = gitOutput(["status", "--short"]).trim().length > 0;
  const packageName = `ascendant-realms-private-playtest-${shortCommit}${dirty ? "-dirty" : ""}`;
  const packageDir = resolve(PACKAGE_ROOT, packageName);
  assertInside(PACKAGE_ROOT, packageDir);

  await rm(packageDir, { recursive: true, force: true });
  await mkdir(packageDir, { recursive: true });
  await cp(DIST_DIR, join(packageDir, "game"), { recursive: true });
  await injectPrivatePlaytestToolsFlag(join(packageDir, "game", "index.html"));

  await copyMarkdown("docs/V014_PRIVATE_PLAYTEST_TESTER_README.md", join(packageDir, "README_FOR_TESTERS.md"));
  await copyMarkdown("docs/V0126_TESTER_QUICK_START.md", join(packageDir, "TESTER_QUICK_START.md"));
  await copyMarkdown("docs/V0126_FEEDBACK_SUBMISSION_PACKET.md", join(packageDir, "FEEDBACK_SUBMISSION_PACKET.md"));
  await copyMarkdown("docs/V0126_ROUTE_ASSIGNMENT_PLAN.md", join(packageDir, "ROUTE_ASSIGNMENT_PLAN.md"));
  await copyMarkdown("docs/V014_READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md", join(packageDir, "READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md"));
  await copyMarkdown("docs/V016_EMMANUEL_CONTROL_RETEST_SCRIPT.md", join(packageDir, "CONTROL_RETEST_SCRIPT.md"));
  await copyMarkdown("docs/V016_PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md", join(packageDir, "PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md"));
  await copyMarkdown("docs/V016_BEHAVIOUR_MODE_TESTER_CHECKLIST.md", join(packageDir, "BEHAVIOUR_MODE_TESTER_CHECKLIST.md"));
  await copyMarkdown("docs/V016_CONTROL_FEEDBACK_INTAKE_TEMPLATE.md", join(packageDir, "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md"));
  await copyMarkdown("docs/V016_CONTROL_REGRESSION_TRIAGE_GUIDE.md", join(packageDir, "CONTROL_REGRESSION_TRIAGE_GUIDE.md"));
  await copyMarkdown("docs/V01610_RELEASE_CANDIDATE_DECISION.md", join(packageDir, "RELEASE_CANDIDATE_NOTES.md"));
  await copyMarkdown("docs/V01610_EMMANUEL_MANUAL_RETEST_CHECKLIST.md", join(packageDir, "EMMANUEL_MANUAL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V01610_TESTER_MESSAGE_SHORT.md", join(packageDir, "FIRST_TESTER_MESSAGE.md"));
  await copyMarkdown("docs/V01610_TESTER_FEEDBACK_FORM_SHORT.md", join(packageDir, "TESTER_FEEDBACK_FORM_SHORT.md"));
  await copyMarkdown("docs/V01610_ROUTE_ASSIGNMENTS_SMALL_BATCH.md", join(packageDir, "ROUTE_ASSIGNMENTS_SMALL_BATCH.md"));
  await copyMarkdown("docs/V01611_TESTER_LAUNCH_PACKET_INDEX.md", join(packageDir, "TESTER_LAUNCH_PACKET_INDEX.md"));
  await copyMarkdown("docs/V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md", join(packageDir, "V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V01613_BD26DE3_RETEST_INTAKE.md", join(packageDir, "V01613_BD26DE3_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md", join(packageDir, "V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md"));
  await copyMarkdown("docs/V017_SOLO_PLAYTEST_INTAKE.md", join(packageDir, "V017_SOLO_PLAYTEST_INTAKE.md"));
  await copyMarkdown("docs/V017_WORKER_ECONOMY_DESIGN_SPEC.md", join(packageDir, "V017_WORKER_ECONOMY_DESIGN_SPEC.md"));
  await copyMarkdown("docs/V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md", join(packageDir, "V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V018_IMPLEMENTATION_REPORT.md", join(packageDir, "V018_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md", join(packageDir, "V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md"));
  await copyMarkdown("docs/V0182_IMPLEMENTATION_REPORT.md", join(packageDir, "V0182_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md", join(packageDir, "V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md", join(packageDir, "V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md"));
  await copyMarkdown("docs/V019_PRODUCTION_ARCHITECTURE_SPEC.md", join(packageDir, "V019_PRODUCTION_ARCHITECTURE_SPEC.md"));
  await copyMarkdown("docs/V019_IMPLEMENTATION_REPORT.md", join(packageDir, "V019_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md", join(packageDir, "V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md"));
  await copyMarkdown("docs/V0191_REMOTE_CI_STATUS.md", join(packageDir, "V0191_REMOTE_CI_STATUS.md"));
  await copyMarkdown("docs/V0191_PRODUCTION_ROLE_POLISH_REPORT.md", join(packageDir, "V0191_PRODUCTION_ROLE_POLISH_REPORT.md"));
  await copyMarkdown("docs/V020_TECH_TREE_FOUNDATION_SPEC.md", join(packageDir, "V020_TECH_TREE_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V020_IMPLEMENTATION_REPORT.md", join(packageDir, "V020_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md", join(packageDir, "V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md"));
  await copyMarkdown("docs/V021_WORKER_REPAIR_FOUNDATION_SPEC.md", join(packageDir, "V021_WORKER_REPAIR_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V021_IMPLEMENTATION_REPORT.md", join(packageDir, "V021_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0211_WORKER_REPAIR_CLOSEOUT.md", join(packageDir, "V0211_WORKER_REPAIR_CLOSEOUT.md"));
  await copyMarkdown("docs/V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md", join(packageDir, "V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md", join(packageDir, "V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md"));
  await copyMarkdown("docs/V0213_WORKER_INTENT_CLOSEOUT.md", join(packageDir, "V0213_WORKER_INTENT_CLOSEOUT.md"));
  await copyMarkdown("docs/V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md", join(packageDir, "V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md", join(packageDir, "V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md"));
  await copyMarkdown("docs/V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md", join(packageDir, "V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md"));
  await copyMarkdown("docs/V022_IMPLEMENTATION_REPORT.md", join(packageDir, "V022_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V022_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V022_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V023_RESOURCE_SITE_UPGRADES_SPEC.md", join(packageDir, "V023_RESOURCE_SITE_UPGRADES_SPEC.md"));
  await copyMarkdown("docs/V023_IMPLEMENTATION_REPORT.md", join(packageDir, "V023_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V023_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V023_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md", join(packageDir, "V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md"));
  await copyMarkdown("docs/V024_IMPLEMENTATION_REPORT.md", join(packageDir, "V024_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md", join(packageDir, "V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md"));
  await copyMarkdown("docs/V025_IMPLEMENTATION_REPORT.md", join(packageDir, "V025_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V025_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V025_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V026_ENEMY_BASE_DEVELOPMENT_SPEC.md", join(packageDir, "V026_ENEMY_BASE_DEVELOPMENT_SPEC.md"));
  await copyMarkdown("docs/V026_IMPLEMENTATION_REPORT.md", join(packageDir, "V026_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V027_ENEMY_TECH_ESCALATION_SPEC.md", join(packageDir, "V027_ENEMY_TECH_ESCALATION_SPEC.md"));
  await copyMarkdown("docs/V027_IMPLEMENTATION_REPORT.md", join(packageDir, "V027_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V027_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V027_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V028_HERO_PROGRESSION_SPEC.md", join(packageDir, "V028_HERO_PROGRESSION_SPEC.md"));
  await copyMarkdown("docs/V028_IMPLEMENTATION_REPORT.md", join(packageDir, "V028_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V029_HERO_ABILITIES_AND_REWARDS_SPEC.md", join(packageDir, "V029_HERO_ABILITIES_AND_REWARDS_SPEC.md"));
  await copyMarkdown("docs/V029_IMPLEMENTATION_REPORT.md", join(packageDir, "V029_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V029_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V029_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V0291_BLOCKED_REMOTE_CI_STATUS.md", join(packageDir, "V0291_BLOCKED_REMOTE_CI_STATUS.md"));
  await copyMarkdown(
    "docs/V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md",
    join(packageDir, "V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md")
  );
  await copyMarkdown("docs/V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md", join(packageDir, "V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md"));
  await copyMarkdown("docs/V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md", join(packageDir, "V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md"));
  await copyMarkdown("docs/V0292_RELEASE_MATRIX_CLOSEOUT.md", join(packageDir, "V0292_RELEASE_MATRIX_CLOSEOUT.md"));
  await copyMarkdown("docs/V0292_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V0292_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V0292_LONG_SOAK_REPORT.md", join(packageDir, "V0292_LONG_SOAK_REPORT.md"));
  await copyMarkdown("docs/V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md", join(packageDir, "V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V031_RELIC_REWARD_FOUNDATION_SPEC.md", join(packageDir, "V031_RELIC_REWARD_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V030_IMPLEMENTATION_REPORT.md", join(packageDir, "V030_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V031_IMPLEMENTATION_REPORT.md", join(packageDir, "V031_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V031_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V031_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V032_PERSISTENT_RELIC_INVENTORY_SPEC.md", join(packageDir, "V032_PERSISTENT_RELIC_INVENTORY_SPEC.md"));
  await copyMarkdown("docs/V033_HERO_RELIC_LOADOUT_SPEC.md", join(packageDir, "V033_HERO_RELIC_LOADOUT_SPEC.md"));
  await copyMarkdown("docs/V032_IMPLEMENTATION_REPORT.md", join(packageDir, "V032_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V033_IMPLEMENTATION_REPORT.md", join(packageDir, "V033_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V033_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V033_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V034_RELIC_REWARD_CHOICE_SPEC.md", join(packageDir, "V034_RELIC_REWARD_CHOICE_SPEC.md"));
  await copyMarkdown("docs/V035_HERO_BUILD_IDENTITY_SPEC.md", join(packageDir, "V035_HERO_BUILD_IDENTITY_SPEC.md"));
  await copyMarkdown("docs/V034_IMPLEMENTATION_REPORT.md", join(packageDir, "V034_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V035_IMPLEMENTATION_REPORT.md", join(packageDir, "V035_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V035_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V035_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V036_HERO_SKILL_TREE_FOUNDATION_SPEC.md", join(packageDir, "V036_HERO_SKILL_TREE_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V037_ABILITY_UPGRADE_FOUNDATION_SPEC.md", join(packageDir, "V037_ABILITY_UPGRADE_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V038_RELIC_BUILD_SYNERGY_SPEC.md", join(packageDir, "V038_RELIC_BUILD_SYNERGY_SPEC.md"));
  await copyMarkdown("docs/V036_IMPLEMENTATION_REPORT.md", join(packageDir, "V036_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V037_IMPLEMENTATION_REPORT.md", join(packageDir, "V037_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V038_IMPLEMENTATION_REPORT.md", join(packageDir, "V038_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V038_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V038_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V039_CAMPAIGN_PROGRESSION_FOUNDATION_SPEC.md", join(packageDir, "V039_CAMPAIGN_PROGRESSION_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V040_MISSION_REWARD_STRUCTURE_SPEC.md", join(packageDir, "V040_MISSION_REWARD_STRUCTURE_SPEC.md"));
  await copyMarkdown("docs/V041_REPLAY_AND_OBJECTIVE_STATE_SPEC.md", join(packageDir, "V041_REPLAY_AND_OBJECTIVE_STATE_SPEC.md"));
  await copyMarkdown("docs/V039_IMPLEMENTATION_REPORT.md", join(packageDir, "V039_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V040_IMPLEMENTATION_REPORT.md", join(packageDir, "V040_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V041_IMPLEMENTATION_REPORT.md", join(packageDir, "V041_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V041_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V041_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V042_MISSION_VARIETY_FOUNDATION_SPEC.md", join(packageDir, "V042_MISSION_VARIETY_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V043_SCENARIO_MODIFIERS_SPEC.md", join(packageDir, "V043_SCENARIO_MODIFIERS_SPEC.md"));
  await copyMarkdown("docs/V044_CAMPAIGN_PACING_AND_BRIEFING_SPEC.md", join(packageDir, "V044_CAMPAIGN_PACING_AND_BRIEFING_SPEC.md"));
  await copyMarkdown("docs/V042_IMPLEMENTATION_REPORT.md", join(packageDir, "V042_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V043_IMPLEMENTATION_REPORT.md", join(packageDir, "V043_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V044_IMPLEMENTATION_REPORT.md", join(packageDir, "V044_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V044_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V044_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V045_ACT1_CAMPAIGN_SPINE_SPEC.md", join(packageDir, "V045_ACT1_CAMPAIGN_SPINE_SPEC.md"));
  await copyMarkdown("docs/V046_DIFFICULTY_PACING_FOUNDATION_SPEC.md", join(packageDir, "V046_DIFFICULTY_PACING_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V047_ONBOARDING_AND_PLAYER_GUIDANCE_SPEC.md", join(packageDir, "V047_ONBOARDING_AND_PLAYER_GUIDANCE_SPEC.md"));
  await copyMarkdown("docs/V045_IMPLEMENTATION_REPORT.md", join(packageDir, "V045_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V046_IMPLEMENTATION_REPORT.md", join(packageDir, "V046_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V047_IMPLEMENTATION_REPORT.md", join(packageDir, "V047_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V047_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V047_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V048_ACT1_PLAYABILITY_AUDIT_PLAN.md", join(packageDir, "V048_ACT1_PLAYABILITY_AUDIT_PLAN.md"));
  await copyMarkdown("docs/V048_ACT1_PLAYTEST_TELEMETRY_REPORT.md", join(packageDir, "V048_ACT1_PLAYTEST_TELEMETRY_REPORT.md"));
  await copyMarkdown("docs/V048_IMPLEMENTATION_REPORT.md", join(packageDir, "V048_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V049_ACT1_BALANCE_AND_TELEMETRY_REPORT.md", join(packageDir, "V049_ACT1_BALANCE_AND_TELEMETRY_REPORT.md"));
  await copyMarkdown("docs/V050_ACT1_RELEASE_CANDIDATE_NOTES.md", join(packageDir, "V050_ACT1_RELEASE_CANDIDATE_NOTES.md"));
  await copyMarkdown("docs/V050_IMPLEMENTATION_REPORT.md", join(packageDir, "V050_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V050_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V050_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V051_PLAYER_UX_AUDIT_PLAN.md", join(packageDir, "V051_PLAYER_UX_AUDIT_PLAN.md"));
  await copyMarkdown("docs/V051_PLAYER_UX_AUDIT_REPORT.md", join(packageDir, "V051_PLAYER_UX_AUDIT_REPORT.md"));
  await copyMarkdown("docs/V051_IMPLEMENTATION_REPORT.md", join(packageDir, "V051_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V052_COMMAND_AND_CURSOR_READABILITY_REPORT.md", join(packageDir, "V052_COMMAND_AND_CURSOR_READABILITY_REPORT.md"));
  await copyMarkdown("docs/V053_COMBAT_AND_RESULTS_READABILITY_REPORT.md", join(packageDir, "V053_COMBAT_AND_RESULTS_READABILITY_REPORT.md"));
  await copyMarkdown("docs/V053_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V053_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V054_CONTROL_GROUPS_FOUNDATION_SPEC.md", join(packageDir, "V054_CONTROL_GROUPS_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V055_FORMATION_AWARE_MOVEMENT_SPEC.md", join(packageDir, "V055_FORMATION_AWARE_MOVEMENT_SPEC.md"));
  await copyMarkdown("docs/V056_PATROL_FOUNDATION_SPEC.md", join(packageDir, "V056_PATROL_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V054_IMPLEMENTATION_REPORT.md", join(packageDir, "V054_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V055_IMPLEMENTATION_REPORT.md", join(packageDir, "V055_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V056_IMPLEMENTATION_REPORT.md", join(packageDir, "V056_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V056_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V056_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V057_ARMY_VETERANCY_FOUNDATION_SPEC.md", join(packageDir, "V057_ARMY_VETERANCY_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V058_UNIT_ROLE_IDENTITY_SPEC.md", join(packageDir, "V058_UNIT_ROLE_IDENTITY_SPEC.md"));
  await copyMarkdown("docs/V059_TACTICAL_COMBAT_FEEDBACK_SPEC.md", join(packageDir, "V059_TACTICAL_COMBAT_FEEDBACK_SPEC.md"));
  await copyMarkdown("docs/V057_IMPLEMENTATION_REPORT.md", join(packageDir, "V057_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V058_IMPLEMENTATION_REPORT.md", join(packageDir, "V058_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V059_IMPLEMENTATION_REPORT.md", join(packageDir, "V059_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V059_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V059_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V060_RETINUE_PERSISTENCE_FOUNDATION_SPEC.md", join(packageDir, "V060_RETINUE_PERSISTENCE_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V061_PRE_BATTLE_DEPLOYMENT_SPEC.md", join(packageDir, "V061_PRE_BATTLE_DEPLOYMENT_SPEC.md"));
  await copyMarkdown("docs/V062_SURVIVOR_CONTINUITY_AND_RESULTS_SPEC.md", join(packageDir, "V062_SURVIVOR_CONTINUITY_AND_RESULTS_SPEC.md"));
  await copyMarkdown("docs/V060_IMPLEMENTATION_REPORT.md", join(packageDir, "V060_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V061_IMPLEMENTATION_REPORT.md", join(packageDir, "V061_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V062_IMPLEMENTATION_REPORT.md", join(packageDir, "V062_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V062_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V062_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V063_RETINUE_RECOVERY_SPEC.md", join(packageDir, "V063_RETINUE_RECOVERY_SPEC.md"));
  await copyMarkdown("docs/V064_RESERVE_MANAGEMENT_SPEC.md", join(packageDir, "V064_RESERVE_MANAGEMENT_SPEC.md"));
  await copyMarkdown("docs/V065_BATTLEFIELD_REINFORCEMENT_SPEC.md", join(packageDir, "V065_BATTLEFIELD_REINFORCEMENT_SPEC.md"));
  await copyMarkdown("docs/V063_IMPLEMENTATION_REPORT.md", join(packageDir, "V063_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V064_IMPLEMENTATION_REPORT.md", join(packageDir, "V064_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V065_IMPLEMENTATION_REPORT.md", join(packageDir, "V065_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V065_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V065_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V066_ENEMY_TACTICAL_DOCTRINES_SPEC.md", join(packageDir, "V066_ENEMY_TACTICAL_DOCTRINES_SPEC.md"));
  await copyMarkdown("docs/V067_ELITE_SQUAD_FOUNDATION_SPEC.md", join(packageDir, "V067_ELITE_SQUAD_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V068_COUNTERPLAY_READABILITY_SPEC.md", join(packageDir, "V068_COUNTERPLAY_READABILITY_SPEC.md"));
  await copyMarkdown("docs/V066_IMPLEMENTATION_REPORT.md", join(packageDir, "V066_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V067_IMPLEMENTATION_REPORT.md", join(packageDir, "V067_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V068_IMPLEMENTATION_REPORT.md", join(packageDir, "V068_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V068_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V068_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V069_PRE_BATTLE_INTELLIGENCE_SPEC.md", join(packageDir, "V069_PRE_BATTLE_INTELLIGENCE_SPEC.md"));
  await copyMarkdown("docs/V070_TACTICAL_PLAN_SELECTION_SPEC.md", join(packageDir, "V070_TACTICAL_PLAN_SELECTION_SPEC.md"));
  await copyMarkdown("docs/V071_COUNTER_DOCTRINE_PREPARATION_SPEC.md", join(packageDir, "V071_COUNTER_DOCTRINE_PREPARATION_SPEC.md"));
  await copyMarkdown("docs/V069_IMPLEMENTATION_REPORT.md", join(packageDir, "V069_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V070_IMPLEMENTATION_REPORT.md", join(packageDir, "V070_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V071_IMPLEMENTATION_REPORT.md", join(packageDir, "V071_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V071_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V071_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V072_BATTLEFIELD_EVENT_DIRECTOR_SPEC.md", join(packageDir, "V072_BATTLEFIELD_EVENT_DIRECTOR_SPEC.md"));
  await copyMarkdown("docs/V073_DYNAMIC_TACTICAL_OBJECTIVES_SPEC.md", join(packageDir, "V073_DYNAMIC_TACTICAL_OBJECTIVES_SPEC.md"));
  await copyMarkdown("docs/V074_ADAPTIVE_PRESSURE_AND_READABILITY_SPEC.md", join(packageDir, "V074_ADAPTIVE_PRESSURE_AND_READABILITY_SPEC.md"));
  await copyMarkdown("docs/V072_IMPLEMENTATION_REPORT.md", join(packageDir, "V072_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V073_IMPLEMENTATION_REPORT.md", join(packageDir, "V073_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V074_IMPLEMENTATION_REPORT.md", join(packageDir, "V074_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V074_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V074_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V075_ACT1_FINALE_ENCOUNTER_SPEC.md", join(packageDir, "V075_ACT1_FINALE_ENCOUNTER_SPEC.md"));
  await copyMarkdown("docs/V076_RIVAL_COMMANDER_PHASES_SPEC.md", join(packageDir, "V076_RIVAL_COMMANDER_PHASES_SPEC.md"));
  await copyMarkdown("docs/V077_MILESTONE_REWARD_AND_DEBRIEF_SPEC.md", join(packageDir, "V077_MILESTONE_REWARD_AND_DEBRIEF_SPEC.md"));
  await copyMarkdown("docs/V075_IMPLEMENTATION_REPORT.md", join(packageDir, "V075_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V076_IMPLEMENTATION_REPORT.md", join(packageDir, "V076_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V077_IMPLEMENTATION_REPORT.md", join(packageDir, "V077_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V077_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V077_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V078_CREATIVE_IDENTITY_LOCK_PLAN.md", join(packageDir, "V078_CREATIVE_IDENTITY_LOCK_PLAN.md"));
  await copyMarkdown("docs/V078_PUBLIC_TITLE_AND_BRAND_OPTIONS.md", join(packageDir, "V078_PUBLIC_TITLE_AND_BRAND_OPTIONS.md"));
  await copyMarkdown("docs/V078_WORLD_AND_LORE_BIBLE_DRAFT.md", join(packageDir, "V078_WORLD_AND_LORE_BIBLE_DRAFT.md"));
  await copyMarkdown("docs/V078_RACE_AND_FACTION_MASTER_MATRIX.md", join(packageDir, "V078_RACE_AND_FACTION_MASTER_MATRIX.md"));
  await copyMarkdown("docs/V078_HERO_RACE_CLASS_ORIGIN_OATH_ARCHITECTURE.md", join(packageDir, "V078_HERO_RACE_CLASS_ORIGIN_OATH_ARCHITECTURE.md"));
  await copyMarkdown("docs/V078_SIGNATURE_GAMEPLAY_PILLARS.md", join(packageDir, "V078_SIGNATURE_GAMEPLAY_PILLARS.md"));
  await copyMarkdown("docs/V078_LONG_CAMPAIGN_MASTER_OUTLINE.md", join(packageDir, "V078_LONG_CAMPAIGN_MASTER_OUTLINE.md"));
  await copyMarkdown("docs/V078_BROWSER_TO_DESKTOP_TRANSITION_GATE.md", join(packageDir, "V078_BROWSER_TO_DESKTOP_TRANSITION_GATE.md"));
  await copyMarkdown("docs/V078_VISUAL_DIRECTION_AND_AI_ART_GOVERNANCE.md", join(packageDir, "V078_VISUAL_DIRECTION_AND_AI_ART_GOVERNANCE.md"));
  await copyMarkdown("docs/V078_VISUAL_VERTICAL_SLICE_BRIEF.md", join(packageDir, "V078_VISUAL_VERTICAL_SLICE_BRIEF.md"));
  await copyMarkdown("docs/V078_DISPLAY_NAME_MIGRATION_MAP.md", join(packageDir, "V078_DISPLAY_NAME_MIGRATION_MAP.md"));
  await copyMarkdown("docs/V078_ORIGINAL_IP_SEPARATION_LEDGER.md", join(packageDir, "V078_ORIGINAL_IP_SEPARATION_LEDGER.md"));
  await copyMarkdown("docs/V078_FUTURE_IMPLEMENTATION_SEQUENCE.md", join(packageDir, "V078_FUTURE_IMPLEMENTATION_SEQUENCE.md"));
  await copyMarkdown("docs/V078_EMMANUEL_REVIEW_PACKET.md", join(packageDir, "V078_EMMANUEL_REVIEW_PACKET.md"));
  await copyMarkdown("docs/V078_IMPLEMENTATION_REPORT.md", join(packageDir, "V078_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V079_EMMANUEL_APPROVAL_LEDGER.md", join(packageDir, "V079_EMMANUEL_APPROVAL_LEDGER.md"));
  await copyMarkdown("docs/V079_DIRECTION_LOCK_SUMMARY.md", join(packageDir, "V079_DIRECTION_LOCK_SUMMARY.md"));
  await copyMarkdown("docs/V079_VERTICAL_SLICE_PRIORITY_LOCK.md", join(packageDir, "V079_VERTICAL_SLICE_PRIORITY_LOCK.md"));
  await copyMarkdown("docs/V079_FIRST_SIGNATURE_SYSTEM_PRIORITY.md", join(packageDir, "V079_FIRST_SIGNATURE_SYSTEM_PRIORITY.md"));
  await copyMarkdown("docs/V079_DEFERRED_DECISIONS_REGISTER.md", join(packageDir, "V079_DEFERRED_DECISIONS_REGISTER.md"));
  await copyMarkdown("docs/V079_SAFE_NEXT_MILESTONE_SEQUENCE.md", join(packageDir, "V079_SAFE_NEXT_MILESTONE_SEQUENCE.md"));
  await copyMarkdown("docs/V079_IMPLEMENTATION_REPORT.md", join(packageDir, "V079_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V080_RUNTIME_FACING_STRING_INVENTORY.json", join(packageDir, "V080_RUNTIME_FACING_STRING_INVENTORY.json"));
  await copyMarkdown("docs/V080_TERMINOLOGY_TAXONOMY.md", join(packageDir, "V080_TERMINOLOGY_TAXONOMY.md"));
  await copyMarkdown("docs/V080_DISPLAY_COPY_MIGRATION_MAP.md", join(packageDir, "V080_DISPLAY_COPY_MIGRATION_MAP.md"));
  await copyMarkdown("docs/V080_SAFE_COPY_BATCHES.md", join(packageDir, "V080_SAFE_COPY_BATCHES.md"));
  await copyMarkdown("docs/V080_TEST_AND_ROLLBACK_PLAN.md", join(packageDir, "V080_TEST_AND_ROLLBACK_PLAN.md"));
  await copyMarkdown("docs/V080_EMMANUEL_REVIEW_PACKET.md", join(packageDir, "V080_EMMANUEL_REVIEW_PACKET.md"));
  await copyMarkdown("docs/V080_IMPLEMENTATION_REPORT.md", join(packageDir, "V080_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V081_EXISTING_SITE_SYSTEM_AUDIT.md", join(packageDir, "V081_EXISTING_SITE_SYSTEM_AUDIT.md"));
  await copyMarkdown("docs/V081_LUME_NETWORK_DESIGN_PRINCIPLES.md", join(packageDir, "V081_LUME_NETWORK_DESIGN_PRINCIPLES.md"));
  await copyMarkdown("docs/V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md", join(packageDir, "V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md"));
  await copyMarkdown("docs/V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md", join(packageDir, "V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md"));
  await copyMarkdown("docs/V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md", join(packageDir, "V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md"));
  await copyMarkdown("docs/V081_DATA_MODEL_AND_INTEGRATION_PLAN.md", join(packageDir, "V081_DATA_MODEL_AND_INTEGRATION_PLAN.md"));
  await copyMarkdown("docs/V081_UI_READABILITY_AND_TEACHING_SPEC.md", join(packageDir, "V081_UI_READABILITY_AND_TEACHING_SPEC.md"));
  await copyMarkdown("docs/V081_RACE_EXTENSIBILITY_MATRIX.md", join(packageDir, "V081_RACE_EXTENSIBILITY_MATRIX.md"));
  await copyMarkdown("docs/V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md", join(packageDir, "V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md"));
  await copyMarkdown("docs/V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md", join(packageDir, "V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md"));
  await copyMarkdown("docs/V081_FUTURE_IMPLEMENTATION_SEQUENCE.md", join(packageDir, "V081_FUTURE_IMPLEMENTATION_SEQUENCE.md"));
  await copyMarkdown("docs/V081_EMMANUEL_REVIEW_PACKET.md", join(packageDir, "V081_EMMANUEL_REVIEW_PACKET.md"));
  await copyMarkdown("docs/V081_IMPLEMENTATION_REPORT.md", join(packageDir, "V081_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V082_LUME_NETWORK_RUNTIME_PROTOTYPE_SPEC.md", join(packageDir, "V082_LUME_NETWORK_RUNTIME_PROTOTYPE_SPEC.md"));
  await copyMarkdown(
    "docs/V082_LINKED_WARD_BALANCE_AND_READABILITY_REPORT.md",
    join(packageDir, "V082_LINKED_WARD_BALANCE_AND_READABILITY_REPORT.md")
  );
  await copyMarkdown("docs/V082_LUME_NETWORK_TEST_AND_SAFETY_REPORT.md", join(packageDir, "V082_LUME_NETWORK_TEST_AND_SAFETY_REPORT.md"));
  await copyMarkdown("docs/V082_IMPLEMENTATION_REPORT.md", join(packageDir, "V082_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V082_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V082_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V083_CAMPAIGN_MAP_UX_RESCUE_SPEC.md", join(packageDir, "V083_CAMPAIGN_MAP_UX_RESCUE_SPEC.md"));
  await copyMarkdown("docs/V083_PRIVATE_PLAYTEST_QUICK_LAUNCH_SPEC.md", join(packageDir, "V083_PRIVATE_PLAYTEST_QUICK_LAUNCH_SPEC.md"));
  await copyMarkdown("docs/V083_IMPLEMENTATION_REPORT.md", join(packageDir, "V083_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V083_VISUAL_QA_REPORT.md", join(packageDir, "V083_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V083_PRIVATE_PLAYTEST_LAUNCH_NOTES.md", join(packageDir, "V083_PRIVATE_PLAYTEST_LAUNCH_NOTES.md"));
  await copyMarkdown("docs/V083_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V083_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V084_GUIDED_LUME_DEMO_READABILITY_SPEC.md", join(packageDir, "V084_GUIDED_LUME_DEMO_READABILITY_SPEC.md"));
  await copyMarkdown("docs/V084_LUME_LINK_RENDERING_SPEC.md", join(packageDir, "V084_LUME_LINK_RENDERING_SPEC.md"));
  await copyMarkdown("docs/V084_PRIVATE_DEMO_FAST_RETEST_SPEC.md", join(packageDir, "V084_PRIVATE_DEMO_FAST_RETEST_SPEC.md"));
  await copyMarkdown("docs/V084_VISUAL_QA_REPORT.md", join(packageDir, "V084_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V084_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V084_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V084_IMPLEMENTATION_REPORT.md", join(packageDir, "V084_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V084_DEFERRED_BATTLEFIELD_UX_FINDINGS.md", join(packageDir, "V084_DEFERRED_BATTLEFIELD_UX_FINDINGS.md"));
  await copyMarkdown("docs/V085_CONTEXTUAL_LUME_OVERLAY_SPEC.md", join(packageDir, "V085_CONTEXTUAL_LUME_OVERLAY_SPEC.md"));
  await copyMarkdown("docs/V085_LUME_VISIBILITY_CONTROL_SPEC.md", join(packageDir, "V085_LUME_VISIBILITY_CONTROL_SPEC.md"));
  await copyMarkdown("docs/V085_PRIVATE_DEMO_RESULTS_UX_SPEC.md", join(packageDir, "V085_PRIVATE_DEMO_RESULTS_UX_SPEC.md"));
  await copyMarkdown("docs/V085_IMPLEMENTATION_REPORT.md", join(packageDir, "V085_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V085_VISUAL_QA_REPORT.md", join(packageDir, "V085_VISUAL_QA_REPORT.md"));
  await copyMarkdown(
    "docs/V085_DEFERRED_RESULTS_AND_BATTLEFIELD_UX_FINDINGS.md",
    join(packageDir, "V085_DEFERRED_RESULTS_AND_BATTLEFIELD_UX_FINDINGS.md")
  );
  await copyMarkdown("docs/V085_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V085_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V086_BATTLEFIELD_SHELL_UX_RESCUE_SPEC.md", join(packageDir, "V086_BATTLEFIELD_SHELL_UX_RESCUE_SPEC.md"));
  await copyMarkdown("docs/V086_NOTIFICATION_PRIORITY_SPEC.md", join(packageDir, "V086_NOTIFICATION_PRIORITY_SPEC.md"));
  await copyMarkdown("docs/V086_OBJECTIVE_TRACKER_PRESENTATION_SPEC.md", join(packageDir, "V086_OBJECTIVE_TRACKER_PRESENTATION_SPEC.md"));
  await copyMarkdown("docs/V086_VISUAL_QA_REPORT.md", join(packageDir, "V086_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V086_IMPLEMENTATION_REPORT.md", join(packageDir, "V086_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V086_DEFERRED_UX_FINDINGS.md", join(packageDir, "V086_DEFERRED_UX_FINDINGS.md"));
  await copyMarkdown("docs/V086_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V086_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V087_CAMPAIGN_SHELL_SECOND_POLISH_SPEC.md", join(packageDir, "V087_CAMPAIGN_SHELL_SECOND_POLISH_SPEC.md"));
  await copyMarkdown("docs/V087_RESULTS_INFORMATION_ARCHITECTURE_SPEC.md", join(packageDir, "V087_RESULTS_INFORMATION_ARCHITECTURE_SPEC.md"));
  await copyMarkdown("docs/V087_VISUAL_QA_REPORT.md", join(packageDir, "V087_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V087_IMPLEMENTATION_REPORT.md", join(packageDir, "V087_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V087_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V087_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V087_DEFERRED_CAMPAIGN_AND_RESULTS_FINDINGS.md", join(packageDir, "V087_DEFERRED_CAMPAIGN_AND_RESULTS_FINDINGS.md"));
  await copyMarkdown("docs/V088_SCREEN_BY_SCREEN_VISUAL_FOUNDATION.md", join(packageDir, "V088_SCREEN_BY_SCREEN_VISUAL_FOUNDATION.md"));
  await copyMarkdown("docs/V088_UI_DESIGN_TOKEN_PROPOSAL.md", join(packageDir, "V088_UI_DESIGN_TOKEN_PROPOSAL.md"));
  await copyMarkdown("docs/V088_BARROSAN_STYLE_FRAME_BRIEF.md", join(packageDir, "V088_BARROSAN_STYLE_FRAME_BRIEF.md"));
  await copyMarkdown("docs/V088_ASHEN_STYLE_FRAME_BRIEF.md", join(packageDir, "V088_ASHEN_STYLE_FRAME_BRIEF.md"));
  await copyMarkdown("docs/V088_WOLFVEIL_SILHOUETTE_BRIEF.md", join(packageDir, "V088_WOLFVEIL_SILHOUETTE_BRIEF.md"));
  await copyMarkdown("docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md", join(packageDir, "V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md"));
  await copyMarkdown("docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json", join(packageDir, "V088_VERTICAL_SLICE_ASSET_MANIFEST.json"));
  await copyMarkdown("docs/V088_ART_INTAKE_AND_REVIEW_GATE.md", join(packageDir, "V088_ART_INTAKE_AND_REVIEW_GATE.md"));
  await copyMarkdown("docs/V088_EMMANUEL_VISUAL_REVIEW_PACKET.md", join(packageDir, "V088_EMMANUEL_VISUAL_REVIEW_PACKET.md"));
  await copyMarkdown("docs/V088_IMPLEMENTATION_REPORT.md", join(packageDir, "V088_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V089_APPLIED_COPY_MIGRATION_LEDGER.md", join(packageDir, "V089_APPLIED_COPY_MIGRATION_LEDGER.md"));
  await copyMarkdown("docs/V089_DEFERRED_AMBIGUOUS_TERMS.md", join(packageDir, "V089_DEFERRED_AMBIGUOUS_TERMS.md"));
  await copyMarkdown("docs/V089_COPY_ONLY_TEST_AND_ROLLBACK_REPORT.md", join(packageDir, "V089_COPY_ONLY_TEST_AND_ROLLBACK_REPORT.md"));
  await copyMarkdown("docs/V089_VISUAL_QA_REPORT.md", join(packageDir, "V089_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V089_IMPLEMENTATION_REPORT.md", join(packageDir, "V089_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V089_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V089_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V090_VISUAL_REGRESSION_MATRIX.json", join(packageDir, "V090_VISUAL_REGRESSION_MATRIX.json"));
  await copyMarkdown("docs/V090_DESKTOP_VIEWPORT_ACCEPTANCE_SPEC.md", join(packageDir, "V090_DESKTOP_VIEWPORT_ACCEPTANCE_SPEC.md"));
  await copyMarkdown("docs/V090_LAYOUT_ASSERTION_COVERAGE.md", join(packageDir, "V090_LAYOUT_ASSERTION_COVERAGE.md"));
  await copyMarkdown("docs/V090_LIGHTWEIGHT_PERFORMANCE_BASELINE.md", join(packageDir, "V090_LIGHTWEIGHT_PERFORMANCE_BASELINE.md"));
  await copyMarkdown("docs/V090_VISUAL_QA_REVIEW_RULES.md", join(packageDir, "V090_VISUAL_QA_REVIEW_RULES.md"));
  await copyMarkdown("docs/V090_IMPLEMENTATION_REPORT.md", join(packageDir, "V090_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V093_RUNTIME_UI_TOKEN_IMPLEMENTATION_SPEC.md", join(packageDir, "V093_RUNTIME_UI_TOKEN_IMPLEMENTATION_SPEC.md"));
  await copyMarkdown("docs/V093_SALTO_MISSION_PANEL_STATE_RESET_REPORT.md", join(packageDir, "V093_SALTO_MISSION_PANEL_STATE_RESET_REPORT.md"));
  await copyMarkdown("docs/V093_DESKTOP_TYPOGRAPHY_READABILITY_REPORT.md", join(packageDir, "V093_DESKTOP_TYPOGRAPHY_READABILITY_REPORT.md"));
  await copyMarkdown("docs/V093_VISUAL_QA_REPORT.md", join(packageDir, "V093_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V093_IMPLEMENTATION_REPORT.md", join(packageDir, "V093_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V093_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V093_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V094_MAIN_MENU_RESCUE_SPEC.md", join(packageDir, "V094_MAIN_MENU_RESCUE_SPEC.md"));
  await copyMarkdown("docs/V094_ASCENDANT_CREATION_UX_SPEC.md", join(packageDir, "V094_ASCENDANT_CREATION_UX_SPEC.md"));
  await copyMarkdown("docs/V094_CAMPAIGN_DENSITY_RESCUE_SPEC.md", join(packageDir, "V094_CAMPAIGN_DENSITY_RESCUE_SPEC.md"));
  await copyMarkdown("docs/V094_RESULTS_DETAILS_COMPACTION_REPORT.md", join(packageDir, "V094_RESULTS_DETAILS_COMPACTION_REPORT.md"));
  await copyMarkdown("docs/V094_VISUAL_QA_REPORT.md", join(packageDir, "V094_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V094_IMPLEMENTATION_REPORT.md", join(packageDir, "V094_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V094_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V094_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V095_PROCEDURAL_BATTLEFIELD_READABILITY_SPEC.md", join(packageDir, "V095_PROCEDURAL_BATTLEFIELD_READABILITY_SPEC.md"));
  await copyMarkdown("docs/V095_FOG_AND_TERRAIN_PLACEHOLDER_RESCUE_REPORT.md", join(packageDir, "V095_FOG_AND_TERRAIN_PLACEHOLDER_RESCUE_REPORT.md"));
  await copyMarkdown("docs/V095_ENTITY_SILHOUETTE_PLACEHOLDER_SPEC.md", join(packageDir, "V095_ENTITY_SILHOUETTE_PLACEHOLDER_SPEC.md"));
  await copyMarkdown("docs/V095_CAPTURE_SITE_AND_LABEL_DENSITY_REPORT.md", join(packageDir, "V095_CAPTURE_SITE_AND_LABEL_DENSITY_REPORT.md"));
  await copyMarkdown("docs/V095_VISUAL_QA_REPORT.md", join(packageDir, "V095_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V095_IMPLEMENTATION_REPORT.md", join(packageDir, "V095_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V095_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V095_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V095_DEFERRED_FINAL_ART_REQUIREMENTS.md", join(packageDir, "V095_DEFERRED_FINAL_ART_REQUIREMENTS.md"));
  await copyMarkdown("docs/V096_FIRST_SESSION_AUDIT.md", join(packageDir, "V096_FIRST_SESSION_AUDIT.md"));
  await copyMarkdown("docs/V096_CONTEXTUAL_ONBOARDING_SPEC.md", join(packageDir, "V096_CONTEXTUAL_ONBOARDING_SPEC.md"));
  await copyMarkdown("docs/V096_TUTORIAL_UX_RESCUE_REPORT.md", join(packageDir, "V096_TUTORIAL_UX_RESCUE_REPORT.md"));
  await copyMarkdown("docs/V096_HELP_SURFACE_SPEC.md", join(packageDir, "V096_HELP_SURFACE_SPEC.md"));
  await copyMarkdown("docs/V096_VISUAL_QA_REPORT.md", join(packageDir, "V096_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V096_IMPLEMENTATION_REPORT.md", join(packageDir, "V096_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V096_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V096_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V097_SELECTION_FEEDBACK_SPEC.md", join(packageDir, "V097_SELECTION_FEEDBACK_SPEC.md"));
  await copyMarkdown("docs/V097_COMMAND_MARKER_SPEC.md", join(packageDir, "V097_COMMAND_MARKER_SPEC.md"));
  await copyMarkdown("docs/V097_CAMERA_USABILITY_REPORT.md", join(packageDir, "V097_CAMERA_USABILITY_REPORT.md"));
  await copyMarkdown("docs/V097_COMMAND_PANEL_FOLLOWUP_REPORT.md", join(packageDir, "V097_COMMAND_PANEL_FOLLOWUP_REPORT.md"));
  await copyMarkdown("docs/V097_VISUAL_QA_REPORT.md", join(packageDir, "V097_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V097_IMPLEMENTATION_REPORT.md", join(packageDir, "V097_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V097_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V097_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V098_HERO_OVERVIEW_UX_SPEC.md", join(packageDir, "V098_HERO_OVERVIEW_UX_SPEC.md"));
  await copyMarkdown("docs/V098_SKILLS_AND_EQUIPMENT_UX_SPEC.md", join(packageDir, "V098_SKILLS_AND_EQUIPMENT_UX_SPEC.md"));
  await copyMarkdown("docs/V098_RETINUE_UX_RESCUE_SPEC.md", join(packageDir, "V098_RETINUE_UX_RESCUE_SPEC.md"));
  await copyMarkdown("docs/V098_STRONGHOLD_UX_RESCUE_SPEC.md", join(packageDir, "V098_STRONGHOLD_UX_RESCUE_SPEC.md"));
  await copyMarkdown("docs/V098_RESULTS_TO_META_FLOW_REPORT.md", join(packageDir, "V098_RESULTS_TO_META_FLOW_REPORT.md"));
  await copyMarkdown("docs/V098_VISUAL_QA_REPORT.md", join(packageDir, "V098_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V098_IMPLEMENTATION_REPORT.md", join(packageDir, "V098_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V098_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V098_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V099_ACT1_PRESENTATION_AUDIT.md", join(packageDir, "V099_ACT1_PRESENTATION_AUDIT.md"));
  await copyMarkdown("docs/V099_MISSION_CARD_AND_OBJECTIVE_SPEC.md", join(packageDir, "V099_MISSION_CARD_AND_OBJECTIVE_SPEC.md"));
  await copyMarkdown("docs/V099_WORLD_COPY_APPLIED_LEDGER.md", join(packageDir, "V099_WORLD_COPY_APPLIED_LEDGER.md"));
  await copyMarkdown("docs/V099_ACT1_RESULTS_AND_NEXT_STEP_REPORT.md", join(packageDir, "V099_ACT1_RESULTS_AND_NEXT_STEP_REPORT.md"));
  await copyMarkdown("docs/V099_VISUAL_QA_REPORT.md", join(packageDir, "V099_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V099_IMPLEMENTATION_REPORT.md", join(packageDir, "V099_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V099_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V099_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V0100_PRIVATE_PLAYTEST_HUB_SPEC.md", join(packageDir, "V0100_PRIVATE_PLAYTEST_HUB_SPEC.md"));
  await copyMarkdown("docs/V0100_SCENARIO_GALLERY_MANIFEST.json", join(packageDir, "V0100_SCENARIO_GALLERY_MANIFEST.json"));
  await copyMarkdown("docs/V0100_SAVE_ISOLATION_REPORT.md", join(packageDir, "V0100_SAVE_ISOLATION_REPORT.md"));
  await copyMarkdown("docs/V0100_EMMANUEL_FAST_REVIEW_GUIDE.md", join(packageDir, "V0100_EMMANUEL_FAST_REVIEW_GUIDE.md"));
  await copyMarkdown("docs/V0100_VISUAL_QA_REPORT.md", join(packageDir, "V0100_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V0100_IMPLEMENTATION_REPORT.md", join(packageDir, "V0100_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0103_BATTLEFIELD_CLUTTER_REDUCTION_SPEC.md", join(packageDir, "V0103_BATTLEFIELD_CLUTTER_REDUCTION_SPEC.md"));
  await copyMarkdown("docs/V0103_PRIVATE_PERFORMANCE_PROFILER_SPEC.md", join(packageDir, "V0103_PRIVATE_PERFORMANCE_PROFILER_SPEC.md"));
  await copyMarkdown("docs/V0103_PERFORMANCE_LAB_SCENARIO_MANIFEST.json", join(packageDir, "V0103_PERFORMANCE_LAB_SCENARIO_MANIFEST.json"));
  await copyMarkdown("docs/V0103_PERFORMANCE_BASELINE_REPORT.md", join(packageDir, "V0103_PERFORMANCE_BASELINE_REPORT.md"));
  await copyMarkdown("docs/V0103_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md", join(packageDir, "V0103_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md"));
  await copyMarkdown("docs/V0103_VISUAL_QA_REPORT.md", join(packageDir, "V0103_VISUAL_QA_REPORT.md"));
  await copyMarkdown("docs/V0103_IMPLEMENTATION_REPORT.md", join(packageDir, "V0103_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0103_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V0103_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V0103_DEFERRED_ART_AND_RENDERING_FINDINGS.md", join(packageDir, "V0103_DEFERRED_ART_AND_RENDERING_FINDINGS.md"));
  await copyMarkdown("ACT1_PLAYABILITY_TELEMETRY.md", join(packageDir, "ACT1_PLAYABILITY_TELEMETRY.md"));
  await copyMarkdown("ACT1_PLAYABILITY_TELEMETRY.json", join(packageDir, "ACT1_PLAYABILITY_TELEMETRY.json"));

  const buildInfo = createBuildInfo(packageName, commit, shortCommit, dirty);
  await writeFile(join(packageDir, "playtest-build-info.json"), `${JSON.stringify(buildInfo, null, 2)}\n`, "utf-8");
  await writeFile(join(packageDir, "PLAYTEST_BUILD_INFO.md"), renderBuildInfoMarkdown(buildInfo), "utf-8");
  await writeFile(join(packageDir, "start-playtest-server.mjs"), renderStaticServerScript(), "utf-8");
  await writeFile(join(packageDir, "START_GAME_WINDOWS.bat"), renderWindowsLauncher(), "utf-8");
  await writeFile(join(packageDir, "START_GAME_MAC_LINUX.sh"), renderShellLauncher(), "utf-8");

  console.log(`Created private playtest package: ${packageDir}`);
  console.log("Run npm run verify:playtest-package before sending it.");
}

function createBuildInfo(packageName: string, commit: string, shortCommit: string, dirty: boolean): PlaytestBuildInfo {
  return {
    packageName,
    checkpoint: CHECKPOINT,
    packagePurpose: PACKAGE_PURPOSE,
    commit,
    shortCommit,
    workingTreeDirty: dirty,
    generatedAtUtc: new Date().toISOString(),
    gameDirectory: "game/",
    startCommand: "node start-playtest-server.mjs",
    requiresLocalServer: true,
    feedbackFile: "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md",
    knownWarnings: ["Vite may warn that the Phaser vendor chunk is larger than 500 kB; this is expected for the current prototype."],
    notForJudging: [
      "final art quality",
      "placeholder unit scale",
      "unfinished animations",
      "missing final VFX",
      "future 2026 visual overhaul work"
    ]
  };
}

async function copyMarkdown(sourcePath: string, targetPath: string): Promise<void> {
  const content = await readFile(resolve(sourcePath), "utf-8");
  await mkdir(dirname(targetPath), { recursive: true });
  await writeFile(targetPath, content, "utf-8");
}

async function injectPrivatePlaytestToolsFlag(indexPath: string): Promise<void> {
  const marker = "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__";
  const content = await readFile(indexPath, "utf-8");
  if (content.includes(marker)) {
    return;
  }
  const injection = '<script>window.__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__=true;</script>';
  const next = content.replace(/(<script\s+type="module")/u, `${injection}\n    $1`);
  if (next === content) {
    throw new Error("Could not inject private playtest tools flag into package index.html.");
  }
  await writeFile(indexPath, next, "utf-8");
}

async function assertDirectoryExists(path: string, label: string): Promise<void> {
  try {
    const stats = await stat(path);
    if (!stats.isDirectory()) {
      throw new Error(`${label} exists but is not a directory: ${path}`);
    }
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      throw new Error(`Missing ${label} directory at ${path}. Run npm run build:playtest first.`);
    }
    throw error;
  }
}

function assertInside(parent: string, child: string): void {
  const relativePath = relative(resolve(parent), resolve(child));
  if (relativePath.startsWith("..") || relativePath === "" || relativePath.includes(`..${sep}`)) {
    throw new Error(`Refusing to write package outside ${parent}: ${child}`);
  }
}

function gitOutput(args: string[]): string {
  return execFileSync("git", args, { cwd: process.cwd(), encoding: "utf-8" }).trim();
}

function renderBuildInfoMarkdown(info: PlaytestBuildInfo): string {
  return `# Ascendant Realms Private Playtest Build Info

Package: ${info.packageName}
Checkpoint: ${info.checkpoint}
Purpose: ${info.packagePurpose}
Generated: ${info.generatedAtUtc}
Commit: ${info.commit}
Working tree dirty when packaged: ${info.workingTreeDirty ? "yes" : "no"}

## How To Start

Use ${info.startCommand}, or double-click START_GAME_WINDOWS.bat on Windows.

This build should be served from the included local server helper. Do not judge problems caused by opening game/index.html directly from the file system.

For v0.103, start with V0103_EMMANUEL_RETEST_CHECKLIST.md, V0103_PERFORMANCE_BASELINE_REPORT.md, V0103_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md, and V0103_PRIVATE_PERFORMANCE_PROFILER_SPEC.md. This package adds a private-package-only performance lab and modest battlefield clutter reduction. It changes no normal progression, persistent rewards, saves, gameplay values, stable IDs, maps, factions, art assets, Lume damage multiplier, pathing, or runtime/internal title.

## Known Warning

${info.knownWarnings.map((warning) => `- ${warning}`).join("\n")}

## What Not To Judge Yet

${info.notForJudging.map((item) => `- ${item}`).join("\n")}

## Feedback

Use ${info.feedbackFile} and send the completed form back to Emmanuel.
`;
}

function renderStaticServerScript(): string {
  return `import { createReadStream } from "node:fs";
import { stat } from "node:fs/promises";
import { createServer } from "node:http";
import { extname, join, relative, resolve, sep } from "node:path";
import { execFile } from "node:child_process";
import { fileURLToPath } from "node:url";

const packageRoot = resolve(fileURLToPath(new URL(".", import.meta.url)));
const gameRoot = resolve(packageRoot, "game");
const port = Number(process.env.ASCENDANT_PLAYTEST_PORT ?? "4174");
const host = "127.0.0.1";
const url = \`http://\${host}:\${port}/\`;

const mimeTypes = new Map([
  [".html", "text/html; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".mjs", "text/javascript; charset=utf-8"],
  [".css", "text/css; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".png", "image/png"],
  [".jpg", "image/jpeg"],
  [".jpeg", "image/jpeg"],
  [".svg", "image/svg+xml"],
  [".webp", "image/webp"],
  [".ico", "image/x-icon"]
]);

const server = createServer(async (request, response) => {
  try {
    const requestUrl = new URL(request.url ?? "/", url);
    const pathname = decodeURIComponent(requestUrl.pathname);
    const target = resolve(gameRoot, pathname === "/" ? "index.html" : pathname.slice(1));
    const relativePath = relative(gameRoot, target);

    if (relativePath.startsWith("..") || relativePath.includes(\`..\${sep}\`)) {
      response.writeHead(403);
      response.end("Forbidden");
      return;
    }

    const stats = await stat(target);
    const filePath = stats.isDirectory() ? join(target, "index.html") : target;
    response.writeHead(200, { "Content-Type": mimeTypes.get(extname(filePath).toLowerCase()) ?? "application/octet-stream" });
    createReadStream(filePath).pipe(response);
  } catch {
    response.writeHead(404);
    response.end("Not found");
  }
});

server.listen(port, host, () => {
  console.log("Ascendant Realms private playtest server is running.");
  console.log(\`Open: \${url}\`);
  if (process.env.ASCENDANT_PLAYTEST_NO_OPEN !== "1") {
    openBrowser(url);
  }
});

process.on("SIGINT", () => {
  server.close(() => process.exit(0));
});

function openBrowser(targetUrl) {
  const command =
    process.platform === "win32"
      ? ["cmd", ["/c", "start", "", targetUrl]]
      : process.platform === "darwin"
        ? ["open", [targetUrl]]
        : ["xdg-open", [targetUrl]];
  execFile(command[0], command[1], () => {});
}
`;
}

function renderWindowsLauncher(): string {
  return `@echo off
setlocal
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is required to run this private playtest package.
  echo Install Node.js LTS from https://nodejs.org/ or ask Emmanuel for a hosted link.
  pause
  exit /b 1
)
node "%~dp0start-playtest-server.mjs"
pause
`;
}

function renderShellLauncher(): string {
  return `#!/usr/bin/env sh
set -eu
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
node "$DIR/start-playtest-server.mjs"
`;
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : error);
  process.exitCode = 1;
});
