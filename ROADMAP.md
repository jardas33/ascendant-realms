# Ascendant Realms Roadmap

## Product Pillars

Every phase should protect these long-term pillars:

1. Persistent hero fantasy: race, class, origin, items, scars, titles, retinue, reputation, and choices should make the hero feel personal.
2. Faction asymmetry: factions need different economies, rhythms, combat identities, and strategic weaknesses.
3. Living campaign map: the world should react with alliances, betrayals, invasions, shops, temples, ruins, contracts, holy orders, cursed lands, and ancient threats.
4. Data-driven and mod-friendly content: future expansion should mostly mean adding data and assets, not rewriting engine code.

## Current Recommended Next Phase

The current checkpoint is **v0.105 Visual Asset Registry, Candidate Review Workspace, and Art-Intake Tooling** on 2026-06-02. It is a tooling/schema/docs milestone: the v0.88 vertical-slice asset plan now has a deterministic reference-only registry, ignored candidate review workspaces, strict art-review validation, SVG contact sheets, deterministic reports, and Emmanuel's first controlled art generation packet without generating/importing art or touching runtime assets.

The next recommended step is to have Emmanuel approve the first four prompt/reference packets, then run the v0.105 art-review tooling on manually placed candidates only. Do not start v0.106, generate a whole roster, import art into runtime, add gameplay systems, change rewards, change saves, rename IDs, create a desktop save path, choose an engine, or start a desktop port until a future explicit goal approves a narrow next step.

New v0.105 docs:

- `docs/V0105_VISUAL_ASSET_REGISTRY_SPEC.md`
- `docs/V0105_CANDIDATE_REVIEW_WORKSPACE_SPEC.md`
- `docs/V0105_ART_REVIEW_STATE_MACHINE.md`
- `docs/V0105_FIRST_ART_GENERATION_PACKET.md`
- `docs/V0105_IMPLEMENTATION_REPORT.md`
- `docs/V0105_EMMANUEL_ART_REVIEW_GUIDE.md`

Recent v0.104 docs:

- `docs/V0104_PROFILER_TRIAGE_REPORT.md`
- `docs/V0104_PUBLIC_BATTLE_HUD_MINIMAL_MODE_SPEC.md`
- `docs/V0104_PRIVATE_HUD_DENSITY_TOGGLE_SPEC.md`
- `docs/V0104_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`
- `docs/V0104_PERFORMANCE_DELTA_REPORT.md`
- `docs/V0104_VISUAL_QA_REPORT.md`
- `docs/V0104_IMPLEMENTATION_REPORT.md`
- `docs/V0104_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.103 docs:

- `docs/V0103_BATTLEFIELD_CLUTTER_REDUCTION_SPEC.md`
- `docs/V0103_PRIVATE_PERFORMANCE_PROFILER_SPEC.md`
- `docs/V0103_PERFORMANCE_LAB_SCENARIO_MANIFEST.json`
- `docs/V0103_PERFORMANCE_BASELINE_REPORT.md`
- `docs/V0103_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`
- `docs/V0103_VISUAL_QA_REPORT.md`
- `docs/V0103_IMPLEMENTATION_REPORT.md`
- `docs/V0103_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V0103_DEFERRED_ART_AND_RENDERING_FINDINGS.md`

Recent v0.102 docs:

- `docs/V0102_SAVE_FIXTURE_LIBRARY_SPEC.md`
- `docs/V0102_DESKTOP_SAVE_ENVELOPE_CONTRACT.md`
- `docs/V0102_SAVE_TRANSLATION_PROOF_REPORT.md`
- `docs/V0102_UNKNOWN_ID_AND_CORRUPTION_POLICY.md`
- `docs/V0102_IMPLEMENTATION_REPORT.md`

Recent v0.101 docs:

- `docs/V0101_PORTABLE_CONTENT_EXPORT_CONTRACT.md`
- `docs/V0101_STABLE_ID_FREEZE_POLICY.md`
- `docs/V0101_EXPORT_SCHEMA_REFERENCE.md`
- `docs/V0101_CONTENT_REUSE_ROUNDTRIP_PLAN.md`
- `docs/V0101_IMPLEMENTATION_REPORT.md`

Recent v0.100 docs:

- `docs/V0100_PRIVATE_PLAYTEST_HUB_SPEC.md`
- `docs/V0100_SCENARIO_GALLERY_MANIFEST.json`
- `docs/V0100_SAVE_ISOLATION_REPORT.md`
- `docs/V0100_EMMANUEL_FAST_REVIEW_GUIDE.md`
- `docs/V0100_VISUAL_QA_REPORT.md`
- `docs/V0100_IMPLEMENTATION_REPORT.md`

Recent v0.99 docs:

- `docs/V099_ACT1_PRESENTATION_AUDIT.md`
- `docs/V099_MISSION_CARD_AND_OBJECTIVE_SPEC.md`
- `docs/V099_WORLD_COPY_APPLIED_LEDGER.md`
- `docs/V099_ACT1_RESULTS_AND_NEXT_STEP_REPORT.md`
- `docs/V099_VISUAL_QA_REPORT.md`
- `docs/V099_IMPLEMENTATION_REPORT.md`
- `docs/V099_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.98 docs:

- `docs/V098_HERO_OVERVIEW_UX_SPEC.md`
- `docs/V098_SKILLS_AND_EQUIPMENT_UX_SPEC.md`
- `docs/V098_RETINUE_UX_RESCUE_SPEC.md`
- `docs/V098_STRONGHOLD_UX_RESCUE_SPEC.md`
- `docs/V098_RESULTS_TO_META_FLOW_REPORT.md`
- `docs/V098_VISUAL_QA_REPORT.md`
- `docs/V098_IMPLEMENTATION_REPORT.md`
- `docs/V098_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.97 docs:

- `docs/V097_SELECTION_FEEDBACK_SPEC.md`
- `docs/V097_COMMAND_MARKER_SPEC.md`
- `docs/V097_CAMERA_USABILITY_REPORT.md`
- `docs/V097_COMMAND_PANEL_FOLLOWUP_REPORT.md`
- `docs/V097_VISUAL_QA_REPORT.md`
- `docs/V097_IMPLEMENTATION_REPORT.md`
- `docs/V097_EMMANUEL_RETEST_CHECKLIST.md`

New v0.95 docs:

- `docs/V095_PROCEDURAL_BATTLEFIELD_READABILITY_SPEC.md`
- `docs/V095_FOG_AND_TERRAIN_PLACEHOLDER_RESCUE_REPORT.md`
- `docs/V095_ENTITY_SILHOUETTE_PLACEHOLDER_SPEC.md`
- `docs/V095_CAPTURE_SITE_AND_LABEL_DENSITY_REPORT.md`
- `docs/V095_VISUAL_QA_REPORT.md`
- `docs/V095_IMPLEMENTATION_REPORT.md`
- `docs/V095_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V095_DEFERRED_FINAL_ART_REQUIREMENTS.md`

Recent v0.94 docs:

- `docs/V094_MAIN_MENU_RESCUE_SPEC.md`
- `docs/V094_ASCENDANT_CREATION_UX_SPEC.md`
- `docs/V094_CAMPAIGN_DENSITY_RESCUE_SPEC.md`
- `docs/V094_RESULTS_DETAILS_COMPACTION_REPORT.md`
- `docs/V094_VISUAL_QA_REPORT.md`
- `docs/V094_IMPLEMENTATION_REPORT.md`
- `docs/V094_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.93 docs:

- `docs/V093_RUNTIME_UI_TOKEN_IMPLEMENTATION_SPEC.md`
- `docs/V093_SALTO_MISSION_PANEL_STATE_RESET_REPORT.md`
- `docs/V093_DESKTOP_TYPOGRAPHY_READABILITY_REPORT.md`
- `docs/V093_VISUAL_QA_REPORT.md`
- `docs/V093_IMPLEMENTATION_REPORT.md`
- `docs/V093_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.92 docs:

- `docs/V092_VISUAL_REVIEW_PACK_SPEC.md`
- `docs/V092_CONTACT_SHEET_INDEX.md`
- `docs/V092_EMMANUEL_UNIFIED_RETEST_PACKET.md`
- `docs/V092_IMPLEMENTATION_REPORT.md`

Recent v0.91 docs:

- `docs/V091_CURRENT_ARCHITECTURE_REUSE_MATRIX.md`
- `docs/V091_DESKTOP_ENGINE_DECISION_CRITERIA.md`
- `docs/V091_DESKTOP_VERTICAL_SLICE_SCOPE.md`
- `docs/V091_STAGED_TRANSITION_EXPERIMENTS.md`
- `docs/V091_SAVE_CONTENT_AND_TEST_REUSE_PLAN.md`
- `docs/V091_MULTIPLAYER_AND_COOP_DEFERRED_REQUIREMENTS.md`
- `docs/V091_EMMANUEL_DESKTOP_TRANSITION_REVIEW_PACKET.md`
- `docs/V091_IMPLEMENTATION_REPORT.md`

Recent v0.90 docs:

- `docs/V090_VISUAL_REGRESSION_MATRIX.json`
- `docs/V090_DESKTOP_VIEWPORT_ACCEPTANCE_SPEC.md`
- `docs/V090_LAYOUT_ASSERTION_COVERAGE.md`
- `docs/V090_LIGHTWEIGHT_PERFORMANCE_BASELINE.md`
- `docs/V090_VISUAL_QA_REVIEW_RULES.md`
- `docs/V090_IMPLEMENTATION_REPORT.md`

Recent v0.89 docs:

- `docs/V089_APPLIED_COPY_MIGRATION_LEDGER.md`
- `docs/V089_DEFERRED_AMBIGUOUS_TERMS.md`
- `docs/V089_COPY_ONLY_TEST_AND_ROLLBACK_REPORT.md`
- `docs/V089_VISUAL_QA_REPORT.md`
- `docs/V089_IMPLEMENTATION_REPORT.md`
- `docs/V089_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.88 docs:

- `docs/V088_SCREEN_BY_SCREEN_VISUAL_FOUNDATION.md`
- `docs/V088_UI_DESIGN_TOKEN_PROPOSAL.md`
- `docs/V088_BARROSAN_STYLE_FRAME_BRIEF.md`
- `docs/V088_ASHEN_STYLE_FRAME_BRIEF.md`
- `docs/V088_WOLFVEIL_SILHOUETTE_BRIEF.md`
- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md`
- `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`
- `docs/V088_ART_INTAKE_AND_REVIEW_GATE.md`
- `docs/V088_EMMANUEL_VISUAL_REVIEW_PACKET.md`
- `docs/V088_IMPLEMENTATION_REPORT.md`

Recent v0.87 docs:

- `docs/V087_CAMPAIGN_SHELL_SECOND_POLISH_SPEC.md`
- `docs/V087_RESULTS_INFORMATION_ARCHITECTURE_SPEC.md`
- `docs/V087_VISUAL_QA_REPORT.md`
- `docs/V087_IMPLEMENTATION_REPORT.md`
- `docs/V087_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V087_DEFERRED_CAMPAIGN_AND_RESULTS_FINDINGS.md`

New v0.82 docs:

- `docs/V082_LUME_NETWORK_RUNTIME_PROTOTYPE_SPEC.md`
- `docs/V082_LINKED_WARD_BALANCE_AND_READABILITY_REPORT.md`
- `docs/V082_LUME_NETWORK_TEST_AND_SAFETY_REPORT.md`
- `docs/V082_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V082_IMPLEMENTATION_REPORT.md`

New v0.81 docs:

- `docs/V081_EXISTING_SITE_SYSTEM_AUDIT.md`
- `docs/V081_LUME_NETWORK_DESIGN_PRINCIPLES.md`
- `docs/V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md`
- `docs/V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md`
- `docs/V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md`
- `docs/V081_DATA_MODEL_AND_INTEGRATION_PLAN.md`
- `docs/V081_UI_READABILITY_AND_TEACHING_SPEC.md`
- `docs/V081_RACE_EXTENSIBILITY_MATRIX.md`
- `docs/V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md`
- `docs/V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md`
- `docs/V081_FUTURE_IMPLEMENTATION_SEQUENCE.md`
- `docs/V081_EMMANUEL_REVIEW_PACKET.md`
- `docs/V081_IMPLEMENTATION_REPORT.md`

New v0.80 docs:

- `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`
- `docs/V080_TERMINOLOGY_TAXONOMY.md`
- `docs/V080_DISPLAY_COPY_MIGRATION_MAP.md`
- `docs/V080_SAFE_COPY_BATCHES.md`
- `docs/V080_TEST_AND_ROLLBACK_PLAN.md`
- `docs/V080_EMMANUEL_REVIEW_PACKET.md`
- `docs/V080_IMPLEMENTATION_REPORT.md`

New v0.79 docs:

- `docs/V079_EMMANUEL_APPROVAL_LEDGER.md`
- `docs/V079_DIRECTION_LOCK_SUMMARY.md`
- `docs/V079_VERTICAL_SLICE_PRIORITY_LOCK.md`
- `docs/V079_FIRST_SIGNATURE_SYSTEM_PRIORITY.md`
- `docs/V079_DEFERRED_DECISIONS_REGISTER.md`
- `docs/V079_SAFE_NEXT_MILESTONE_SEQUENCE.md`
- `docs/V079_IMPLEMENTATION_REPORT.md`

New v0.78 docs:

- `docs/V078_CREATIVE_IDENTITY_LOCK_PLAN.md`
- `docs/V078_PUBLIC_TITLE_AND_BRAND_OPTIONS.md`
- `docs/V078_WORLD_AND_LORE_BIBLE_DRAFT.md`
- `docs/V078_RACE_AND_FACTION_MASTER_MATRIX.md`
- `docs/V078_HERO_RACE_CLASS_ORIGIN_OATH_ARCHITECTURE.md`
- `docs/V078_SIGNATURE_GAMEPLAY_PILLARS.md`
- `docs/V078_LONG_CAMPAIGN_MASTER_OUTLINE.md`
- `docs/V078_BROWSER_TO_DESKTOP_TRANSITION_GATE.md`
- `docs/V078_VISUAL_DIRECTION_AND_AI_ART_GOVERNANCE.md`
- `docs/V078_VISUAL_VERTICAL_SLICE_BRIEF.md`
- `docs/V078_DISPLAY_NAME_MIGRATION_MAP.md`
- `docs/V078_ORIGINAL_IP_SEPARATION_LEDGER.md`
- `docs/V078_FUTURE_IMPLEMENTATION_SEQUENCE.md`
- `docs/V078_EMMANUEL_REVIEW_PACKET.md`
- `docs/V078_IMPLEMENTATION_REPORT.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `LLM_GAME_HANDOFF.md`

New v0.17 Tutorial/Ranger docs and outputs:

- `docs/V017_SOLO_PLAYTEST_INTAKE.md`
- `docs/V017_WORKER_ECONOMY_DESIGN_SPEC.md`
- `docs/V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `LLM_GAME_HANDOFF.md`

New v0.18 Worker construction docs:

- `docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md`
- `docs/V018_IMPLEMENTATION_REPORT.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `LLM_GAME_HANDOFF.md`

New v0.16 control behaviour docs and outputs:

- `docs/V016_BASELINE_AND_CI_AUDIT.md`
- `docs/V016_BEHAVIOUR_MODE_AUDIT.md`
- `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`
- `docs/V016_EMMANUEL_CONTROL_RETEST_SCRIPT.md`
- `docs/V016_PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md`
- `docs/V016_BEHAVIOUR_MODE_TESTER_CHECKLIST.md`
- `docs/V016_CONTROL_FEEDBACK_INTAKE_TEMPLATE.md`
- `docs/V016_CONTROL_REGRESSION_TRIAGE_GUIDE.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_LAB.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_LAB.json`
- `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json`
- `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json`

New v0.15 control behaviour docs:

- `docs/V015_CONTROL_COMBAT_BASELINE_AUDIT.md`
- `docs/V015_BEHAVIOUR_MODES_SPEC.md`
- `docs/V015_CONTROL_COMBAT_BEHAVIOUR_FIX_REPORT.md`

New v0.14.4 Emmanuel retest docs:

- `docs/V0144_COMBAT_CONTROL_RETEST_FIX_REPORT.md`

New v0.14.3 Emmanuel retest docs:

- `docs/V0143_EMMANUEL_RETEST_INTAKE.md`
- `docs/V0143_REPRODUCTION_PLAN.md`
- `docs/V0143_COMBAT_SELECTION_RETEST_FIX_REPORT.md`
- `docs/V0143_UNIT_BEHAVIOUR_MODES_DESIGN.md`

New v0.14.1 Emmanuel quick playtest docs:

- `docs/V0141_EMMANUEL_QUICK_PLAYTEST_INTAKE.md`
- `docs/V0141_REPRODUCTION_PLAN.md`
- `docs/V0141_QUICK_PLAYTEST_FIX_REPORT.md`

New v0.14 private playtest package docs and commands:

- `npm run build:playtest`
- `npm run package:playtest`
- `npm run verify:playtest-package`
- `docs/V014_PLAYTEST_BUILD_DISTRIBUTION_AUDIT.md`
- `docs/V014_PRIVATE_PLAYTEST_TESTER_README.md`
- `docs/V014_PLAYTEST_PACKAGE_COORDINATOR_GUIDE.md`
- `docs/V014_READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md`

New v0.13.1 extended automated scenario-lab docs and outputs:

- `docs/V0131A_EXTENDED_LAB_INTEGRITY_AUDIT.md`
- `docs/V0131A_SCRIPT_AND_OUTPUT_VERIFICATION.md`
- `docs/V0131A_STATISTICAL_USEFULNESS_REVIEW.md`
- `docs/V0131A_EXTENDED_SCENARIO_LAB_AUDIT_REPORT.md`
- `docs/V0131_SCENARIO_LAB_LIMITATIONS_AUDIT.md`
- `docs/V0131_NODE_RISK_DASHBOARD_SPEC.md`
- `docs/V0131_BALANCE_REGRESSION_THRESHOLDS.md`
- `docs/V0131_EXTENDED_AUTOMATED_EVIDENCE_REVIEW.md`
- `docs/V0131_TUNING_AND_ACTION_DECISION.md`
- `docs/V0131_EXTENDED_SCENARIO_LAB_REPORT.md`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.md`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.json`
- `PLAYTEST_PROFILE_COMPARISON.md`
- `PLAYTEST_PROFILE_COMPARISON.csv`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`
- `PLAYTEST_WATCHPOINTS_EXTENDED.md`

New v0.13 automated scenario-lab docs and outputs:

- `docs/V013_AUTOMATED_PLAYTEST_ARCHITECTURE_AUDIT.md`
- `docs/V013_AUTOMATED_SCENARIO_PROFILE_SPEC.md`
- `docs/V013_TELEMETRY_METRICS_SPEC.md`
- `docs/V013_WATCHPOINT_CLASSIFIER_RULES.md`
- `docs/V013_AUTOMATED_EVIDENCE_DECISION.md`
- `docs/V013_AUTOMATED_PLAYTEST_SCENARIO_LAB_REPORT.md`
- `PLAYTEST_SCENARIO_LAB.md`
- `PLAYTEST_SCENARIO_LAB.json`
- `PLAYTEST_WATCHPOINT_SUMMARY.md`
- `PLAYTEST_SCENARIO_PROFILES.md`
- `PLAYTEST_SCENARIO_PROFILES.json`

New v0.12.6 tester distribution docs:

- `docs/V0126_TESTER_QUICK_START.md`
- `docs/V0126_PLAYTEST_COORDINATOR_GUIDE.md`
- `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`
- `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`
- `docs/V0126_FEEDBACK_STORAGE_PLAN.md`
- `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`

New v0.12.5 manual playtest intake docs:

- `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md`
- `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md`
- `docs/V0125_WATCHPOINT_AGGREGATION_SHEET.md`
- `docs/V0125_TRIAGE_DECISION_TREE.md`
- `docs/V0125_SEVERITY_PRIORITY_RUBRIC.md`
- `docs/V0125_FEEDBACK_TO_ACTION_MATRIX.md`
- `docs/V0125_ISSUE_READY_TEMPLATES.md`
- `docs/V0125_SAMPLE_FEEDBACK_TRIAGE.md`

New v0.12.4 manual human playtest packet docs:

- `docs/V0124_MANUAL_HUMAN_PLAYTEST_PACKET.md`
- `docs/V0124_PLAYTEST_ROUTE_CARDS.md`
- `docs/V0124_MISSION_CHECKLISTS.md`
- `docs/V0124_WATCHPOINT_RATING_SHEET.md`
- `docs/V0124_BUG_AND_FRICTION_REPORT_TEMPLATE.md`
- `docs/V0124_PLAYTEST_SUMMARY_FORM.md`
- `docs/V0124_DESIGNER_INTERPRETATION_GUIDE.md`
- `docs/V0124_PLAYTEST_PACKET_INDEX.md`

New v0.12.3 human campaign balance docs:

- `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_PROTOCOL.md`
- `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_NOTES.md`
- `docs/V0123_CAMPAIGN_BALANCE_EVIDENCE_TABLE.md`
- `docs/V0123_BALANCE_PLAY_SESSION_DECISION.md`
- `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`

New v0.12.2 balance watchpoint docs:

- `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`
- `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`
- `docs/V0122_HUMAN_BALANCE_NOTES.md`
- `docs/V0122_TUNING_DECISION.md`
- `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`

New v0.12.1 human-paced playtest docs:

- `docs/V0121_HUMAN_PACED_PLAYTEST_PROTOCOL.md`
- `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`
- `docs/V0121_PLAYTEST_POLISH_PLAN.md`
- `docs/V0121_TUNING_DECISION.md`
- `docs/V0121_VISUAL_QA_REVIEW.md`
- `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`

New v0.12 core feel docs:

- `docs/V012_CORE_GAME_FEEL_AUDIT.md`
- `docs/V012_BATTLE_READABILITY_AUDIT.md`
- `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`
- `docs/V012_VISUAL_READABILITY_NOTES.md`
- `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`

New v0.11.2 remote CI observation docs:

- `docs/V112_REMOTE_CI_OBSERVATION_CAPABILITY.md`
- `docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md`
- `docs/V112_WORKFLOW_STATIC_REVIEW.md`
- `docs/V112_CI_TIMEOUT_TUNING_REVIEW.md`
- `docs/V112_PREVIEW_HELPER_REMOTE_PORTABILITY_REVIEW.md`
- `docs/V112_CI_ARTIFACT_REMOTE_REVIEW.md`
- `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md`
- `docs/V112_CI_NO_FIX_DECISION.md`
- `docs/V112_REMOTE_CI_OBSERVATION_REPORT.md`

New v0.11.1 CI release matrix docs and workflow:

- `.github/workflows/ci.yml`
- `docs/V111_CI_MATRIX_AUDIT.md`
- `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`
- `docs/V111_CI_RELEASE_MATRIX_PLAN.md`
- `docs/V111_CI_ARTIFACT_STRATEGY.md`
- `docs/V111_CI_LOCAL_PARITY_CHECK.md`
- `docs/V111_CI_RELEASE_MATRIX_REPORT.md`
- `tools/smokePreview.ts`

New v0.11 technical reliability docs and tooling:

- `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`
- `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`
- `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`
- `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`
- `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`
- `docs/DEVELOPER_COMMAND_GUIDE.md`
- `docs/V11_TECHNICAL_RELIABILITY_REPORT.md`
- `tools/smokePreview.ts`

New v0.10 tutorial onboarding docs:

- `docs/V10_TUTORIAL_V2_AUDIT.md`
- `docs/V10_TUTORIAL_V2_PACING_PLAN.md`
- `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`
- `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`
- `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`
- `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`

New v0.9.1 controlled intake docs and folders:

- `art-review/README.md`
- `art-review/cinderfen-style-frames/README.md`
- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`
- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`
- `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`
- `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`
- `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md`
- `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`
- `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`
- `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`
- `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`
- `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`
- `tools/art-intake/StyleFrameReviewManifestTypes.ts`
- `tools/art-intake/validateArtIntake.ts`
- `tools/art-intake/validateArtIntake.test.ts`

New v0.9 controlled style-frame docs:

- `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`
- `docs/V09_CINDERFEN_VISUAL_PILLARS.md`
- `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`
- `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`
- `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`
- `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`
- `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`
- `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`
- `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`
- `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`
- `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`

New v0.8.2 source/license and screenshot coverage docs:

- `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`
- `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`
- `docs/V082_MANIFEST_METADATA_REFINEMENT.md`
- `docs/V082_MANIFEST_VALIDATION_HARDENING.md`
- `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`
- `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`
- `docs/VISUAL_RISK_REGISTER.md`
- `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`
- `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`

New v0.8.1 visual asset and screenshot QA docs:

- `docs/V081_EXISTING_ASSET_INVENTORY_AUDIT.md`
- `docs/V081_VISUAL_ASSET_MANIFEST_SCHEMA.md`
- `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`
- `docs/V081_RUNTIME_ASSET_USAGE_CROSSCHECK.md`
- `docs/V081_SCREENSHOT_QA_PLAN.md`
- `docs/V081_SCREENSHOT_QA_REVIEW.md`
- `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`
- `docs/ASSET_PROMPT_TEMPLATES.md`
- `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`

New v0.8 technical/visual foundation docs:

- `docs/V08_PERFORMANCE_AUDIT.md`
- `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`
- `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md`
- `docs/V08_VISUAL_DEBT_AUDIT.md`
- `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`
- `docs/V08_PROTOTYPE_VISUAL_READABILITY_DECISION.md`
- `docs/ART_DIRECTION_2026_BIBLE.md`
- `docs/ASSET_PIPELINE_PLAN.md`
- `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`
- `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`

New v0.7/v0.7.1/v0.7.2/v0.7.3 pressure docs:

- `docs/V07_ENEMY_PRESSURE_RESEARCH_AUDIT.md`
- `docs/V07_ENEMY_STRATEGIC_PRESSURE_SPEC.md`
- `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`
- `docs/V071_ENEMY_PRESSURE_FEEL_AUDIT.md`
- `docs/V071_PRESSURE_WARNING_VISIBILITY_AUDIT.md`
- `docs/V071_PRESSURE_ACTION_PROMOTION_GATE.md`
- `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`
- `docs/V072_PRESSURE_PLAY_REVIEW_PLAN.md`
- `docs/V072_PRESSURE_BROWSER_REVIEW_NOTES.md`
- `docs/V072_CINDERFEN_CROSSING_PRESSURE_REVIEW.md`
- `docs/V072_CINDERFEN_WATCH_PRESSURE_REVIEW.md`
- `docs/V072_PRESSURE_READABILITY_POLISH_DECISION.md`
- `docs/V072_RETINUE_TRAINING_YARD_PRESSURE_REVIEW.md`
- `docs/V072_GREEDY_FAST_PRESSURE_REVIEW.md`
- `docs/V072_PRESSURE_NEXT_ACTION_DECISION.md`
- `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`
- `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_PROTOCOL.md`
- `docs/V073_PRESSURE_REVIEW_SETUP.md`
- `docs/V073_CINDERFEN_CROSSING_REAL_INPUT_REVIEW.md`
- `docs/V073_CINDERFEN_WATCH_REAL_INPUT_REVIEW.md`
- `docs/V073_STRATEGY_PROFILE_PRESSURE_REVIEW.md`
- `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`
- `docs/V073_EVIDENCE_BACKED_PRESSURE_POLISH_DECISION.md`
- `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`
- `docs/V08_DIRECTION_DECISION_BRIEF.md`

Recent tutorial shell docs:

- `docs/TUTORIAL_PLAYABLE_SHELL_PLAN.md`
- `docs/TUTORIAL_SAVE_PERSISTENCE_AUDIT.md`
- `docs/TUTORIAL_CONTENT_VALIDATION_GATE.md`
- `docs/TUTORIAL_READABILITY_SURROGATE_REVIEW.md`
- `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`
- `docs/V06_TUTORIAL_FEEL_AUDIT.md`
- `docs/TUTORIAL_E2E_RUNTIME_REVIEW.md`
- `docs/COMMAND_LOG_V1_TEST_ONLY_PLAN.md`
- `docs/COMMAND_LOG_V1_REPORT.md`
- `docs/DESKTOP_2026_VISUAL_DIRECTION.md`
- `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`
- `docs/V10_TUTORIAL_V2_AUDIT.md`
- `docs/V10_TUTORIAL_V2_PACING_PLAN.md`
- `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`
- `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`
- `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`
- `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`

The prior safety checkpoint is the **v0.5 save/content-validation gate** on 2026-05-08. It preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, and v0.4 technical groundwork while adding save fixtures, stronger content validation, a standalone content validation script, campaign graph/reward checks, command-log feasibility planning, simulator determinism checks, and one approved future vertical-slice candidate.

New v0.5 gate docs:

- `docs/SAVE_COMPATIBILITY_AUDIT.md`
- `docs/V05_SAVE_FIXTURE_PLAN.md`
- `docs/V05_SAVE_FIXTURE_REPORT.md`
- `docs/V05_CONTENT_VALIDATION_AUDIT.md`
- `docs/CAMPAIGN_GRAPH_REWARD_GATE.md`
- `docs/COMMAND_LOG_REPLAY_FEASIBILITY.md`
- `docs/SIMULATOR_DETERMINISM_GATE.md`
- `docs/V05_VERTICAL_SLICE_CANDIDATE.md`
- `docs/TUTORIAL_PROVING_GROUNDS_BRIEF.md`
- `docs/V05_SAVE_CONTENT_VALIDATION_GATE_REPORT.md`

Latest final v0.5 verification: `npm test` 298 tests, `npm run build`, `npm run validate:content`, `npm run test:e2e:smoke` 10 tests in 4.5m, `npm run test:e2e:release` 59 tests in 28.4m, `npm run test:e2e:release:shard1` 49 tests in 23.9m, `npm run test:e2e:release:shard2` 10 tests in 4.4m, `npm run playtest:sim` 255 deterministic runs, `git diff --check`, and production preview smoke passed. The current build output is app JS about 445.42 kB / 119.69 kB gzip, `vendor-phaser` about 1,481.79 kB / 339.86 kB gzip, and CSS about 42.04 kB / 8.74 kB gzip. The known Vite warning remains isolated to the Phaser vendor chunk.

Recommended visual follow-up after v0.9.1: **v0.9.2 controlled Cinderfen style-frame candidate review**, only after source/license-documented candidates are provided. Keep runtime gameplay unchanged and avoid workers, construction, new units, new maps, rewards, save changes, stronger pressure actions, desktop packaging, engine switching, runtime art replacement, large binaries, and broad systems.

The current release baseline is still **v0.3.1 Polish Release - frozen** for content, with v0.10 as the latest player-facing onboarding refinement on top of the existing Tutorial / Proving Grounds shell. v0.3 remains the frozen Cinderfen Route Baseline content release; v0.3.1 is the polish/readability/performance-audit/test-maintenance release on top of that content baseline. The v0.5 gate is the active post-freeze safety/planning baseline, and the Tutorial / Proving Grounds shell is the first safe onboarding vertical slice on top of it.

Latest checkpoint verification: 2026-05-11 v0.10 tutorial onboarding final gate. Final gates passed `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser vendor warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke`, `npm run test:e2e:release`, both 2-way release shards, all three 3-way release shards, `npm run visual:qa` with 18 indexed review screenshots and zero recorded browser console errors, `npm run playtest:sim`, `git diff --check`, and production preview smoke at `http://127.0.0.1:4173/`. No workers, real enemy construction, new maps, new units, new factions, rewards, save-version changes, tutorial completion persistence, campaign progression, diplomacy, procedural generation, crafting, monetization code, multiplayer, desktop packaging, engine switch, external assets, generated art, imported art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, graphics overhaul, full UI redesign, or broad systems were added.

The current playable v0.3 Chapter 2 slice ends at Cinderfen Aftermath. Any later Cinderfen nodes should stay clearly marked as upcoming and must not launch missing maps or unimplemented content.

The current visible product baseline remains `Prototype v0.3` with the menu subtitle `Cinderfen Route Baseline`. v0.2 remains the previous systems baseline; v0.3 is the frozen Cinderfen route baseline; v0.3.1 is the frozen polish and verification layer for that route.

Completed v0.2.1 stabilization remains part of the baseline:

- Rival/Nemesis Persistence V1: completed.
- Rival Rewards and Trophies V1: completed.
- CampaignRules split into focused pure-rule modules behind a compatibility facade: completed.
- HUD/fog polish for command hover stability, side-panel scroll preservation, and captured resource-site visibility: completed.
- Permanent Playwright regression coverage for the HUD/fog polish: completed.

Completed v0.3 Cinderfen route:

- [x] Cinderfen Overlook: `cinderfen_overlook` is a playable Chapter 2 preparation event after `ashen_outpost`, with three baseline choices plus the optional Malrec trophy consequence.
- [x] Cinderfen Waystation: `cinderfen_waystation` is a compact town/service node after `cinderfen_overlook`, with Marsh Guides, Ash Filters, Refugee Scouts, and Shrine Attunement using existing campaign choice/modifier/save rules.
- [x] Cinderfen Crossing: `cinderfen_crossing` is playable after `cinderfen_overlook` and launches the authored `cinderfen_causeway` / **Cinderfen Crossing** battle map.
- [x] Cinderfen Watch: `cinderfen_watch` is playable after `cinderfen_crossing` and launches the compact `cinderfen_watchpost` / **Cinderfen Watch** battle map.
- [x] Cinderfen Aftermath: `cinderfen_aftermath` is a compact non-battle event after `cinderfen_watch`, with three modest baseline once-only choices plus a tiny optional Malrec trophy reputation choice using existing resource, reward, reputation, modifier, save, and duplicate-prevention rules. It is the end of the current playable Cinderfen route.
- Implemented Cinderfen identity hook: the Cinder Shrine first-capture Aether surge exists as a small battle-local tactical feature.
- Baseline document: `docs/V03_CINDERFEN_ROUTE_BASELINE.md`.
- Slice report: `docs/CHAPTER_2_CINDERFEN_SLICE_REPORT.md`.
- Automated review: `docs/CINDERFEN_AUTOMATED_REVIEW.md`.
- Working proposal: The Cinderfen Road remains a small ash-glass wetland/causeway route that reuses the current campaign, rival, trophy, Stronghold, retinue, reputation, enemy hero, and affixed-loot systems.
- Default implementation stance: use existing Free Marches and Ashen Covenant content first; do not start a full new faction.
- Current slice result: `cinderfen_overlook`, `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath` are implemented. Cinderfen Crossing and Cinderfen Watch have map/objective/reward validation, Cinderfen appears in e2e coverage, both Cinderfen battles are included in the Chapter 2 simulator profile with one eligible Waystation Shrine Attunement service profile, and the aftermath is event-only. No new faction, worker, enemy construction, diplomacy, procedural generation, crafting, or broad army management has been added.

Completed Tutorial / Proving Grounds shell and v0.6 onboarding foundation:

- [x] Main-menu Tutorial launch surface.
- [x] Validated playable tutorial metadata for `proving_grounds_basics`.
- [x] Existing-content tutorial launch on `first_claim` with transient Warlord Aster data.
- [x] Lightweight tutorial overlay and linear twelve-step objective model.
- [x] No-reward, non-persistent completion and exit back to main menu.
- [x] Smoke, layout, content-validation, unit, and save-persistence coverage.
- [x] Tutorial report: `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`.
- [x] v0.6 copy/layout/no-reward clarity polish.
- [x] Test-only semantic command-log V1 for one tutorial completion smoke path.
- [x] Tutorial accessibility checks for live-region semantics and explicit button labels.
- [x] Desktop/2026 visual direction plan, planning only.
- [x] v0.6 onboarding/testing report: `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`.

Completed v0.7 Enemy Strategic Pressure V1:

- [x] Research audit of current enemy AI, waves, personalities, maps, and simulator telemetry.
- [x] Tight design spec for data-driven pressure plans, allowed triggers/actions, forbidden actions, tests, simulator, e2e, and rollback.
- [x] Data model and two V1 plans: `causeway_contest_pressure` and `ashen_watch_captain_pressure`.
- [x] Content validation for plan references and forbidden worker/construction/economy fields.
- [x] Campaign-only runtime tracker, battle warning copy, pressure telemetry, and one safe next-wave timing nudge.
- [x] Pressure-aware defeat advice only after a triggered pressure stage.
- [x] Simulator telemetry and generated pressure balance gate.
- [x] Targeted e2e release coverage for Cinderfen Watch pressure and Tutorial/skirmish no-pressure guards.
- [x] v0.7 report: `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`.

Completed v0.7.1 Enemy Pressure Feel Review:

- [x] Pressure feel audit for current telemetry, Cinderfen identity, Fast Army, Greedy Economy, retinue/Stronghold, tutorial, and skirmish protections.
- [x] Clearer pressure warning and defeat-tip copy that avoids implying live construction, reinforcement, or route-contest AI.
- [x] Pressure status priority with a longer read window, plus objective priority above pressure to preserve `Cinder Shrine Surge` and capture feedback.
- [x] Focused pressure e2e hardening for warning visibility and Tutorial/skirmish no-pressure guards.
- [x] Clearer simulator report wording and readable pressure plan/stage labels.
- [x] No-tuning pressure balance review.
- [x] Action promotion gate keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- [x] v0.7.1 report: `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`.

Completed v0.7.2 Human-Paced Cinderfen Pressure Review:

- [x] Pressure play review protocol and browser review notes.
- [x] Seeded browser/Playwright Cinderfen Crossing warning review with screenshot evidence and no-change decision.
- [x] Seeded browser/Playwright Cinderfen Watch warning review with screenshot evidence and no-change decision.
- [x] Explicit pressure readability no-change decision.
- [x] Retinue + Training Yard II pressure review, documented as a saved-progress power watchpoint rather than pressure bug.
- [x] Greedy Economy and Fast Army pressure review, with no timing/copy/mechanics tuning.
- [x] Pressure next-action decision gate keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- [x] v0.7.2 report: `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`.

Completed v0.7.3 Real-Input Cinderfen Pressure Playtest:

- [x] Controlled browser-input Crossing and Watch pressure reviews.
- [x] Manual pressure checklist for Emmanuel.
- [x] Strategy-profile no-change review.
- [x] v0.8 direction brief.
- [x] v0.7.3 report: `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`.

Completed v0.8 Technical Performance And Visual Foundation:

- [x] Performance/bundle audit refresh.
- [x] E2E runtime/shard audit and optional 3-shard release scripts.
- [x] Visual debt and visual scale/readability audits.
- [x] No-code visual readability decision.
- [x] 2026 art direction bible.
- [x] Asset pipeline plan.
- [x] Cinderfen visual rework spec.
- [x] v0.8 report: `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`.

Completed v0.8.1 Visual Asset Manifest And Screenshot QA Gate:

- [x] Existing asset inventory audit.
- [x] Typed visual asset manifest schema and initial 89-entry manifest.
- [x] Visual asset metadata validation inside `npm run validate:content`.
- [x] Runtime asset usage cross-check.
- [x] Optional `npm run visual:qa` screenshot capture harness.
- [x] Screenshot QA review.
- [x] Cinderfen visual asset replacement backlog.
- [x] Future-safe asset prompt/spec templates.
- [x] v0.8.1 report: `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`.

Completed v0.8.2 Visual Source/License Review And Screenshot Coverage Expansion:

- [x] Source/license review plan and audit.
- [x] Manifest `reviewStatus` and `sourceReviewNotes` metadata.
- [x] Hardened source/license production-safety validation.
- [x] Expanded optional `npm run visual:qa` coverage to 18 indexed screenshots.
- [x] Extended screenshot QA review.
- [x] Visual risk register.
- [x] v0.9 controlled visual sprint brief.
- [x] v0.8.2 report: `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`.

Completed v0.9 Controlled Cinderfen Style-Frame Sprint:

- [x] Cinderfen style-frame research packet.
- [x] Cinderfen visual pillars and style rules.
- [x] Terrain material sheet spec.
- [x] Cinder Shrine/capture-site landmark spec.
- [x] Ashen outpost architecture spec.
- [x] Unit/building scale reference.
- [x] Safe future prompt pack.
- [x] Future Cinderfen manifest templates.
- [x] Screenshot acceptance criteria.
- [x] Future-only visual replacement implementation plan.
- [x] v0.9 report: `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`.

Reference docs:

- v0.3.1 plan: `docs/V031_POLISH_PLAN.md`.
- v0.3.1 release report: `docs/V031_POLISH_RELEASE_REPORT.md`.
- v0.4 direction brief: `docs/V04_DIRECTION_BRIEF.md`.
- v0.4 performance plan: `docs/V04_PERFORMANCE_IMPLEMENTATION_PLAN.md`.
- Route-complete guidance after Cinderfen Aftermath should remain clear: Cinderfen route secured, Chapter 2 slice complete, and more Cinderfen content coming later.

Completed v0.3.1 polish release:

- [x] v0.3.1 polish release is frozen.
- [x] Mobile/readability audit completed for Cinderfen menu, campaign, battle HUD, and Results surfaces.
- [x] Existing Cinderfen copy/hierarchy polished for Overlook, Waystation, Crossing, Watch, Aftermath, route-complete guidance, and Results.
- [x] Performance bundle audit completed for the known Vite large-chunk warning; no risky optimization implemented.
- [x] E2E runtime audit completed; safe shared setup/helper cleanup applied without deleting meaningful coverage.
- [x] Final automated verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, `git diff --check`, and production preview smoke.

Completed v0.4 technical groundwork:

- [x] Direction brief created comparing performance optimization, e2e lane split, human readability/accessibility polish, and small content continuation.
- [x] Explicit Playwright lanes added: `test:e2e:smoke`, `test:e2e:layout`, `test:e2e:deep`, and `test:e2e:release`.
- [x] Full release-gate e2e coverage preserved at 59 tests; smoke lane is available for frequent iteration but does not replace the release gate.
- [x] Performance implementation plan created for measured bundle optimization.
- [x] First approved optimization implemented: Phaser is split into a `vendor-phaser` chunk through Vite/Rollup `manualChunks`.
- [x] Bundle analyzer script and report added for the v0.4 technical baseline.
- [x] Test/dev hook audit completed; no accidental large production leak was found.
- [x] Analyzer-backed second optimization decision recorded as no additional code optimization.
- [x] Minimal 2-shard Playwright release-gate scripts added for CI: `test:e2e:release:shard1` and `test:e2e:release:shard2`.
- [x] Bundle result documented: app JS is about 435.50 kB / 116.99 kB gzip; Phaser vendor JS is about 1,481.79 kB / 339.86 kB gzip; the known Vite warning remains on the vendor chunk.
- [x] Checkpoint verification passed: `npm test`, `npm run build`, `npm run test:e2e:smoke`, final `npm run test:e2e:release` rerun, `npm run playtest:sim`, and `git diff --check`.
- [x] Clean verification refresh passed on 2026-05-07: `npm test` 270 tests, `npm run build`, `npm run test:e2e:smoke` 10 tests, `npm run test:e2e:release` 59 tests in 28.1m, `npm run playtest:sim` 255 deterministic runs, and `git diff --check`.
- [x] v0.4 performance/e2e sharding checkpoint passed on 2026-05-07: `npm test` 270 tests, `npm run build`, `npm run test:e2e:smoke` 10 tests, `npm run test:e2e:release` 59 tests in 28.8m, both release shards, `npm run playtest:sim` 255 deterministic runs, `git diff --check`, and production preview smoke.
- [x] v0.4 accessibility/readability polish completed for Settings labels, setting hints, UI Scale explanation, Fog of War Override labels, and keyboard/control reference without gameplay or save changes.
- [x] v0.4 save compatibility audit completed; current save version stays at 2 and a test now preserves valid Chapter 2 selected chapter/node state.
- [x] v0.4 route-feel surrogate review completed with `watch, not blocked` status and no balance change.
- [x] Full-game roadmap architecture docs updated for future workers/economy, enemy construction, faction expansion, campaign chapters, diplomacy/reputation, tutorial/onboarding, crafting/affix rerolling, asset pipeline, performance, AI personality expansion, procedural/skirmish maps, modding/data-driven content, monetization/packaging, multiplayer feasibility, and save/content-validation gates.
- [x] v0.4 tiny polish backlog created with safe, medium-risk, high-risk, and blocked triage.

Must remain stable after the v0.3 freeze:

- v0.3 automated baseline should stay green: `npm test`, `npm run build`, full Playwright e2e, and `npm run playtest:sim`.
- Rival/retinue readability review remains current, including capacity, death/removal, deployed retinue identity, rival preview, duplicate reward prevention, trophies, and defeat/readiness copy.
- HUD command hover stability, side-panel scroll preservation, and captured-site fog visibility remain covered by permanent e2e regression tests.
- Ashen Outpost, mixed retinue, Training Yard II, Quartermaster II, rival rewards, and first-defeat trophy clarity remain under human-review watch before numeric tuning.

Explicitly postponed after the v0.3 freeze:

- Workers.
- Enemy construction or rebuilding.
- Full new faction.
- Diplomacy or alliance simulation.
- Procedural campaign or procedural maps.
- Crafting, durability, affix rerolling, or broader loot complexity.
- Full trophy room.
- Broad army-management or retinue replacement systems.

Recommended focus after the v0.3.1 freeze:

- Keep v0.3 and v0.3.1 frozen, compact, and data-driven.
- Use the v0.4 technical groundwork checkpoint as the new technical baseline.
- Choose between CI workflow wiring for the shard scripts, human readability/accessibility review, and a separate test-harness/content-validation hardening plan.
- If planning v0.4, start from the frozen route's human-readability findings rather than adding broad systems immediately.
- If optimizing technically, change only one measured optimization at a time and keep release-gate e2e green.
- Play Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost with no retinue, one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Specifically watch Gorak Emberhand, Veyra of the Cinders, and Captain Malrec for scout readability, nameplate clarity, ability readability, XP/objective payoff, first-defeat trophy clarity, late-attack fairness, and whether +5% rematch modifiers are noticeable without feeling mandatory.
- Confirm Retinue feels helpful without becoming mandatory, especially on Ashen Outpost.
- Review whether permanent retinue death feels clear enough before adding wounded timers or replacement UI.
- Recheck command hover stability, side-panel scroll preservation, and captured-site fog readability with human mouse movement even though automated regression tests now cover the core cases.
- Keep bonuses modest, visible in UI, and represented in telemetry.
- Human-paced campaign QA should still review Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, Ashen Outpost, rival commanders, the two-tier Stronghold paths, reputation hooks, and affixed reward readability before larger balance changes.
- Keep technical risk work scoped around `HUD`, `contentValidation`, `BattleScene`, `src/game/core/progression/ItemRewardRules.ts`, `RetinueRules`, `RivalRules`, and `CampaignRules`.
- Do not move into workers, enemy construction, new factions, new maps, diplomacy, procedural campaign, procedural maps, crafting, durability, broad loot complexity, full trophy rooms, or broad army-management systems as an immediate post-freeze step.
- Treat the remaining Vite large-chunk warning as a known Phaser vendor warning, not a failing roadmap item, unless a second focused bundle optimization becomes the explicit task.

## Phase 0: Project Foundation

- Phaser/Vite/TypeScript setup.
- Scene management.
- Data architecture.
- Save system shell.

## Phase 1: Playable Skirmish Prototype

- Hero.
- Units.
- Movement.
- Selection.
- Combat.
- Capture resources.
- Basic buildings.
- Enemy AI.
- Win/loss.
- Five authored battlefields now prove the map pipeline: First Claim, Broken Ford, Ashen Outpost, Chapter 2 Cinderfen Crossing, and Chapter 2 Cinderfen Watch.
- Ashen Outpost serves as the first campaign milestone/boss-style fortress assault, with secondary objective tracking for map-specific goals.

## Phase 2: Hero RPG Depth

- Full stats.
- Multiple abilities.
- Skill trees.
- Items.
- Equipment.
- Hero portraits.
- Level-up choices.
- Scars and titles.
- Reputation hooks.
- Unit Veterancy V1 is implemented as battle-local XP/ranks/results summaries. Retinue Camp V1 selectively saves a small number of campaign veterans. Enemy Hero / Rival Commander V1 gives important Ashen battles named commanders without adding enemy construction. Rival/Nemesis Persistence V1 now persists commander outcomes and small rematch modifiers, while Rival Rewards and Trophies V1 adds one-time first-defeat rewards and save-backed trophies.

## Phase 3: Faction Expansion

- 3 complete factions:
- Free Marches.
- Ashen Covenant.
- Sylvan Concord.
- Unique units.
- Unique buildings.
- Unique economy twist.
- Unique faction spell/technology.
- Explicit faction identity documents covering economy, combat rhythm, strengths, and weaknesses.

## Phase 4: Campaign Map

- Node-based overworld. Skeleton implemented with eight Border Marches nodes.
- Locations. First pass includes battle, shrine, and event node handling.
- Ashen Outpost now uses a dedicated fortress map as the current mini-campaign finale.
- Simple data-driven event choices with requirements, costs, rewards, reputation changes, and node unlocks.
- Reputation ranks and small data-driven effects for Marcher Camp discounts, Stronghold Crown discounts, Chapel Aether bonuses, and Ashen hostile pressure.
- Stronghold Development with five Tier I upgrades, five matching Tier II upgrades, prerequisite locks, campaign-resource spending, save-backed ranks, and battle-launch effects.
- Battle-local Unit Veterancy V1 with Notable Veterans in Results, plus Retinue Camp V1 for a capped set of saved campaign veterans.
- Enemy Hero / Rival Commander V1 with three named Ashen commanders, campaign node assignments, scout/battle/results feedback, modest abilities, and playtest telemetry.
- Rival/Nemesis Persistence V1 with campaign-save rival records, Rival Intel, node previews, Results outcome copy, escaped/triumphant rematch modifiers, and playtest telemetry fields.
- Rival Rewards and Trophies V1 with data-driven first-defeat XP/resource/reputation/item rewards, duplicate prevention, save-backed trophy records, Campaign Map trophy display, Results reward/trophy copy, and playtest telemetry fields.
- Save-backed node completion, unlocks, selected node, one-time node rewards, and once-only choice claims.
- Campaign battle launches through the shared `BattleLaunchRequest` path.
- Chapter 2 has a compact playable Cinderfen slice: `cinderfen_overlook` is the implemented event gate after Ashen Outpost, `cinderfen_crossing` unlocks after that event to launch `Cinderfen Crossing`, `cinderfen_watch` unlocks after Cinderfen Crossing to launch `Cinderfen Watch`, and `cinderfen_aftermath` unlocks after Cinderfen Watch as a non-battle consequence node.
- `cinderfen_waystation` is the implemented Chapter 2 support/town node after Cinderfen Overlook. It spends campaign resources on modest Cinderfen-only preparation without adding a broad shop, new faction, workers, enemy construction, diplomacy, procedural generation, or crafting.
- Cinderfen Crossing uses the Cinder Shrine first-capture Aether surge as its compact battle-local tactical identity feature.
- The only returning-rival consequence in Chapter 2 is the optional Malrec trophy event choice; there is no new Chapter 2 rival system.
- Quests.
- Shops.
- Temples.
- Ruins.
- Mercenary contracts.
- Holy orders.
- Cursed lands.
- Ancient threat encounters.
- Broader faction reputation arcs beyond the current rank/effect hooks.
- Alliances and betrayals.
- Invasions.
- Deeper random events and multi-step dialogue.
- Persistent consequences.

## Phase 5: Procedural Maps

- Random map generator.
- Biomes.
- Resource placement.
- Neutral camps.
- Enemy start positions.
- Difficulty scaling.

## Phase 6: Advanced AI

- AI personalities.
- Rush/economy/turtle/magic styles.
- Scouting.
- Counter-unit logic.
- Retreat logic.
- Hero build logic.

## Phase 7: Content Tools

- Map editor.
- Faction editor.
- Unit editor.
- Scenario editor.
- Mod loading.
- Data validation for mod packs.
- Non-coder content templates.

## Phase 8: Presentation

- Real art.
- Animation.
- Sound effects.
- Music.
- Better UI.
- Dedicated UI art kit with panel frames, button states, resource frames, dividers, tooltip frames, minimap frame, ability slots, inventory slots, victory panel, and defeat panel.
- Better UX.
- Tutorial.

## Phase 9: Steam-Ready Single-Player

- Achievements.
- Settings.
- Save slots.
- Campaign polish.
- Balance pass.
- Performance optimization.
- Packaging.

## Phase 10: Multiplayer Exploration

- Local network prototype.
- Deterministic simulation research.
- Lockstep or server-authoritative decision.
- Multiplayer only after single-player is strong.
