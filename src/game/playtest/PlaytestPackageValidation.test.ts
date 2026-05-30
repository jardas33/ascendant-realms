import { describe, expect, it } from "vitest";
import { validatePlaytestPackageSnapshot, type PlaytestPackageSnapshot } from "./PlaytestPackageValidation";

describe("PlaytestPackageValidation", () => {
  it("accepts a complete private playtest package snapshot", () => {
    const result = validatePlaytestPackageSnapshot(completeSnapshot());

    expect(result.errors).toEqual([]);
    expect(result.checks).toContain("game/index.html uses package-safe relative asset URLs");
    expect(result.checks).toContain("built game assets present");
  });

  it("rejects absolute asset paths that would break portable package serving", () => {
    const snapshot = completeSnapshot();
    snapshot.files = snapshot.files.map((file) =>
      file.path === "game/index.html" ? { ...file, textContent: '<script type="module" src="/assets/index.js"></script>' } : file
    );

    const result = validatePlaytestPackageSnapshot(snapshot);

    expect(result.ok).toBe(false);
    expect(result.errors).toContain("game/index.html uses absolute /assets/ URLs; playtest builds should use relative assets.");
  });

  it("rejects development folders, raw private feedback, and obvious secrets", () => {
    const snapshot = completeSnapshot();
    snapshot.files.push(
      { path: "node_modules/example/index.js", sizeBytes: 10 },
      { path: "playtest-feedback/raw/PT-PRIVATE.md", sizeBytes: 10, textContent: "private tester note" },
      { path: ".env", sizeBytes: 24, textContent: "OPENAI_API_KEY=secret" }
    );

    const result = validatePlaytestPackageSnapshot(snapshot);

    expect(result.ok).toBe(false);
    expect(result.errors).toEqual(
      expect.arrayContaining([
        "Forbidden package path included: node_modules/example/index.js.",
        "Forbidden package path included: playtest-feedback/raw/PT-PRIVATE.md.",
        "Forbidden secret-like file included: .env.",
        "Possible secret detected in .env: OpenAI API key assignment."
      ])
    );
  });
});

function completeSnapshot(): PlaytestPackageSnapshot {
  return {
    packageName: "ascendant-realms-private-playtest-afbb37f",
    files: [
      { path: "game/index.html", sizeBytes: 128, textContent: '<script type="module" src="./assets/index.js"></script>' },
      { path: "game/assets/index.js", sizeBytes: 1024, textContent: "console.log('game');" },
      { path: "README_FOR_TESTERS.md", sizeBytes: 20, textContent: "Read me" },
      { path: "PLAYTEST_BUILD_INFO.md", sizeBytes: 20, textContent: "Build info" },
      {
        path: "playtest-build-info.json",
        sizeBytes: 200,
        textContent: JSON.stringify({
          commit: "afbb37f000000000000000000000000000000000",
          shortCommit: "afbb37f",
          generatedAtUtc: "2026-05-18T13:00:00.000Z",
          checkpoint: "v0.63-v0.65 Retinue recovery and reinforcement foundation",
          packagePurpose: "private human playtest distribution",
          requiresLocalServer: true
        })
      },
      { path: "FEEDBACK_SUBMISSION_PACKET.md", sizeBytes: 20, textContent: "Feedback form" },
      { path: "TESTER_QUICK_START.md", sizeBytes: 20, textContent: "Quick start" },
      { path: "ROUTE_ASSIGNMENT_PLAN.md", sizeBytes: 20, textContent: "Routes" },
      { path: "CONTROL_RETEST_SCRIPT.md", sizeBytes: 20, textContent: "Retest" },
      { path: "PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md", sizeBytes: 20, textContent: "Route card" },
      { path: "BEHAVIOUR_MODE_TESTER_CHECKLIST.md", sizeBytes: 20, textContent: "Checklist" },
      { path: "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md", sizeBytes: 20, textContent: "Feedback" },
      { path: "CONTROL_REGRESSION_TRIAGE_GUIDE.md", sizeBytes: 20, textContent: "Triage" },
      { path: "RELEASE_CANDIDATE_NOTES.md", sizeBytes: 20, textContent: "Release candidate" },
      { path: "EMMANUEL_MANUAL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "Manual retest" },
      { path: "FIRST_TESTER_MESSAGE.md", sizeBytes: 20, textContent: "Tester message" },
      { path: "TESTER_FEEDBACK_FORM_SHORT.md", sizeBytes: 20, textContent: "Feedback short" },
      { path: "ROUTE_ASSIGNMENTS_SMALL_BATCH.md", sizeBytes: 20, textContent: "Routes short" },
      { path: "TESTER_LAUNCH_PACKET_INDEX.md", sizeBytes: 20, textContent: "Launch index" },
      { path: "V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Retest intake" },
      { path: "V01613_BD26DE3_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Retest intake" },
      { path: "V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md", sizeBytes: 20, textContent: "Fix note" },
      { path: "V017_SOLO_PLAYTEST_INTAKE.md", sizeBytes: 20, textContent: "Solo intake" },
      { path: "V017_WORKER_ECONOMY_DESIGN_SPEC.md", sizeBytes: 20, textContent: "Worker economy spec" },
      { path: "V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial retest intake" },
      { path: "V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial follow-up intake" },
      { path: "V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial v0.17.3 intake" },
      { path: "V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial v0.17.4 intake" },
      { path: "V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial v0.17.5 intake" },
      { path: "V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Worker construction spec" },
      { path: "V018_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Worker construction report" },
      { path: "V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md", sizeBytes: 20, textContent: "Worker construction expansion spec" },
      { path: "V0182_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Worker construction expansion report" },
      { path: "V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Worker retest intake" },
      { path: "V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md", sizeBytes: 20, textContent: "Worker pathing fix report" },
      { path: "V019_PRODUCTION_ARCHITECTURE_SPEC.md", sizeBytes: 20, textContent: "Production architecture spec" },
      { path: "V019_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Production architecture report" },
      { path: "V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md", sizeBytes: 20, textContent: "Production role plan" },
      { path: "V0191_REMOTE_CI_STATUS.md", sizeBytes: 20, textContent: "Remote CI status" },
      { path: "V0191_PRODUCTION_ROLE_POLISH_REPORT.md", sizeBytes: 20, textContent: "Production role report" },
      { path: "V020_TECH_TREE_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Tech tree spec" },
      { path: "V020_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Tech tree report" },
      { path: "V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md", sizeBytes: 20, textContent: "Tech tree closeout" },
      { path: "V021_WORKER_REPAIR_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Worker repair spec" },
      { path: "V021_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Worker repair report" },
      { path: "V0211_WORKER_REPAIR_CLOSEOUT.md", sizeBytes: 20, textContent: "Worker repair closeout" },
      { path: "V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Worker repair retest intake" },
      { path: "V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md", sizeBytes: 20, textContent: "Cursor note" },
      { path: "V0213_WORKER_INTENT_CLOSEOUT.md", sizeBytes: 20, textContent: "Worker intent closeout" },
      { path: "V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Worker attack retest intake" },
      { path: "V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md", sizeBytes: 20, textContent: "Cursor note" },
      { path: "V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md", sizeBytes: 20, textContent: "Resource site Worker assignment spec" },
      { path: "V022_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Resource site Worker assignment report" },
      { path: "V022_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "Resource site Worker assignment retest" },
      { path: "V023_RESOURCE_SITE_UPGRADES_SPEC.md", sizeBytes: 20, textContent: "Resource site upgrades spec" },
      { path: "V023_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Resource site upgrades report" },
      { path: "V023_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "Resource site upgrades retest" },
      { path: "V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md", sizeBytes: 20, textContent: "Enemy resource site strategy spec" },
      { path: "V024_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Enemy resource site strategy report" },
      { path: "V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md", sizeBytes: 20, textContent: "Economy pressure and raid AI spec" },
      { path: "V025_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Economy pressure report" },
      { path: "V025_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "Enemy resource site AI retest" },
      { path: "V026_ENEMY_BASE_DEVELOPMENT_SPEC.md", sizeBytes: 20, textContent: "Enemy base development spec" },
      { path: "V026_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Enemy base development report" },
      { path: "V027_ENEMY_TECH_ESCALATION_SPEC.md", sizeBytes: 20, textContent: "Enemy tech escalation spec" },
      { path: "V027_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Enemy tech escalation report" },
      { path: "V027_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "Enemy tech retest" },
      { path: "V028_HERO_PROGRESSION_SPEC.md", sizeBytes: 20, textContent: "Hero progression spec" },
      { path: "V028_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Hero progression report" },
      { path: "V029_HERO_ABILITIES_AND_REWARDS_SPEC.md", sizeBytes: 20, textContent: "Hero ability rewards spec" },
      { path: "V029_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Hero ability rewards report" },
      { path: "V029_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "Hero ability retest" },
      { path: "V0291_BLOCKED_REMOTE_CI_STATUS.md", sizeBytes: 20, textContent: "Blocked remote CI status" },
      { path: "V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md", sizeBytes: 20, textContent: "Local verification closeout" },
      { path: "V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md", sizeBytes: 20, textContent: "Deep battle failure audit" },
      { path: "V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md", sizeBytes: 20, textContent: "Deep battle fix report" },
      { path: "V0292_RELEASE_MATRIX_CLOSEOUT.md", sizeBytes: 20, textContent: "Release matrix closeout" },
      { path: "V0292_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.29.2 retest" },
      { path: "V0292_LONG_SOAK_REPORT.md", sizeBytes: 20, textContent: "Long soak report" },
      { path: "V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Rival champion spec" },
      { path: "V031_RELIC_REWARD_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Relic reward spec" },
      { path: "V030_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Rival champion report" },
      { path: "V031_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Relic reward report" },
      { path: "V031_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.31 retest" },
      { path: "V032_PERSISTENT_RELIC_INVENTORY_SPEC.md", sizeBytes: 20, textContent: "Persistent relic inventory spec" },
      { path: "V033_HERO_RELIC_LOADOUT_SPEC.md", sizeBytes: 20, textContent: "Hero relic loadout spec" },
      { path: "V032_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Persistent relic inventory report" },
      { path: "V033_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Hero relic loadout report" },
      { path: "V033_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.33 retest" },
      { path: "V034_RELIC_REWARD_CHOICE_SPEC.md", sizeBytes: 20, textContent: "Relic reward choice spec" },
      { path: "V035_HERO_BUILD_IDENTITY_SPEC.md", sizeBytes: 20, textContent: "Hero build identity spec" },
      { path: "V034_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Relic reward choice report" },
      { path: "V035_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Hero build identity report" },
      { path: "V035_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.35 retest" },
      { path: "V036_HERO_SKILL_TREE_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Hero skill tree spec" },
      { path: "V037_ABILITY_UPGRADE_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Ability upgrade spec" },
      { path: "V038_RELIC_BUILD_SYNERGY_SPEC.md", sizeBytes: 20, textContent: "Relic synergy spec" },
      { path: "V036_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Hero skill tree report" },
      { path: "V037_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Ability upgrade report" },
      { path: "V038_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Relic synergy report" },
      { path: "V038_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.38 retest" },
      { path: "V039_CAMPAIGN_PROGRESSION_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Campaign progression spec" },
      { path: "V040_MISSION_REWARD_STRUCTURE_SPEC.md", sizeBytes: 20, textContent: "Mission reward spec" },
      { path: "V041_REPLAY_AND_OBJECTIVE_STATE_SPEC.md", sizeBytes: 20, textContent: "Replay objective spec" },
      { path: "V039_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Campaign progression report" },
      { path: "V040_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Mission reward report" },
      { path: "V041_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Replay objective report" },
      { path: "V041_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.41 retest" },
      { path: "V042_MISSION_VARIETY_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Mission variety spec" },
      { path: "V043_SCENARIO_MODIFIERS_SPEC.md", sizeBytes: 20, textContent: "Scenario modifier spec" },
      { path: "V044_CAMPAIGN_PACING_AND_BRIEFING_SPEC.md", sizeBytes: 20, textContent: "Campaign pacing spec" },
      { path: "V042_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Mission variety report" },
      { path: "V043_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Scenario modifier report" },
      { path: "V044_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Campaign pacing report" },
      { path: "V044_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.44 retest" },
      { path: "V045_ACT1_CAMPAIGN_SPINE_SPEC.md", sizeBytes: 20, textContent: "Act 1 spine spec" },
      { path: "V046_DIFFICULTY_PACING_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Difficulty pacing spec" },
      { path: "V047_ONBOARDING_AND_PLAYER_GUIDANCE_SPEC.md", sizeBytes: 20, textContent: "Onboarding guidance spec" },
      { path: "V045_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Act 1 spine report" },
      { path: "V046_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Difficulty pacing report" },
      { path: "V047_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Onboarding guidance report" },
      { path: "V047_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.47 retest" },
      { path: "V048_ACT1_PLAYABILITY_AUDIT_PLAN.md", sizeBytes: 20, textContent: "Act 1 audit plan" },
      { path: "V048_ACT1_PLAYTEST_TELEMETRY_REPORT.md", sizeBytes: 20, textContent: "Act 1 telemetry report" },
      { path: "V048_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Act 1 playability report" },
      { path: "V049_ACT1_BALANCE_AND_TELEMETRY_REPORT.md", sizeBytes: 20, textContent: "Act 1 balance telemetry" },
      { path: "V050_ACT1_RELEASE_CANDIDATE_NOTES.md", sizeBytes: 20, textContent: "Act 1 release candidate" },
      { path: "V050_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Release candidate report" },
      { path: "V050_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.50 retest" },
      { path: "V051_PLAYER_UX_AUDIT_PLAN.md", sizeBytes: 20, textContent: "Player UX audit plan" },
      { path: "V051_PLAYER_UX_AUDIT_REPORT.md", sizeBytes: 20, textContent: "Player UX audit report" },
      { path: "V051_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Player UX implementation report" },
      { path: "V052_COMMAND_AND_CURSOR_READABILITY_REPORT.md", sizeBytes: 20, textContent: "Command cursor report" },
      { path: "V053_COMBAT_AND_RESULTS_READABILITY_REPORT.md", sizeBytes: 20, textContent: "Combat results report" },
      { path: "V053_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.53 retest" },
      { path: "V054_CONTROL_GROUPS_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Control groups spec" },
      { path: "V055_FORMATION_AWARE_MOVEMENT_SPEC.md", sizeBytes: 20, textContent: "Formation-aware movement spec" },
      { path: "V056_PATROL_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Patrol spec" },
      { path: "V054_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Control groups implementation report" },
      { path: "V055_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Formation movement implementation report" },
      { path: "V056_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Patrol implementation report" },
      { path: "V056_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.56 retest" },
      { path: "V057_ARMY_VETERANCY_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Army veterancy spec" },
      { path: "V058_UNIT_ROLE_IDENTITY_SPEC.md", sizeBytes: 20, textContent: "Unit role identity spec" },
      { path: "V059_TACTICAL_COMBAT_FEEDBACK_SPEC.md", sizeBytes: 20, textContent: "Tactical feedback spec" },
      { path: "V057_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Army veterancy implementation report" },
      { path: "V058_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Unit role identity implementation report" },
      { path: "V059_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Tactical feedback implementation report" },
      { path: "V059_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.59 retest" },
      { path: "V060_RETINUE_PERSISTENCE_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Retinue persistence spec" },
      { path: "V061_PRE_BATTLE_DEPLOYMENT_SPEC.md", sizeBytes: 20, textContent: "Retinue deployment spec" },
      { path: "V062_SURVIVOR_CONTINUITY_AND_RESULTS_SPEC.md", sizeBytes: 20, textContent: "Retinue survivor continuity spec" },
      { path: "V060_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Retinue persistence report" },
      { path: "V061_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Retinue deployment report" },
      { path: "V062_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Retinue survivor continuity report" },
      { path: "V062_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.62 retest" },
      { path: "V063_RETINUE_RECOVERY_SPEC.md", sizeBytes: 20, textContent: "Retinue recovery spec" },
      { path: "V064_RESERVE_MANAGEMENT_SPEC.md", sizeBytes: 20, textContent: "Reserve management spec" },
      { path: "V065_BATTLEFIELD_REINFORCEMENT_SPEC.md", sizeBytes: 20, textContent: "Battlefield reinforcement spec" },
      { path: "V063_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Retinue recovery report" },
      { path: "V064_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Reserve management report" },
      { path: "V065_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Battlefield reinforcement report" },
      { path: "V065_EMMANUEL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "v0.65 retest" },
      { path: "ACT1_PLAYABILITY_TELEMETRY.md", sizeBytes: 20, textContent: "Act 1 telemetry markdown" },
      { path: "ACT1_PLAYABILITY_TELEMETRY.json", sizeBytes: 20, textContent: "{\"schemaVersion\":1}" },
      { path: "start-playtest-server.mjs", sizeBytes: 20, textContent: "server" },
      { path: "START_GAME_WINDOWS.bat", sizeBytes: 20, textContent: "node start-playtest-server.mjs" },
      { path: "START_GAME_MAC_LINUX.sh", sizeBytes: 20, textContent: "node start-playtest-server.mjs" }
    ]
  };
}
