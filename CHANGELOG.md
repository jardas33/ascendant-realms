# Changelog

## v0.11 Technical Reliability, E2E Runtime, and Performance Gate - 2026-05-11

This checkpoint improves release reliability documentation, e2e runtime clarity, preview smoke repeatability, optional visual QA reporting, bundle/performance measurement, developer command ergonomics, and release-checklist maintainability without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, maps, units, factions, rewards, or UI design.

### Included

- E2E runtime audit refresh: `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`.
- Release lane reliability plan: `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`.
- Automated production preview smoke helper: `npm run smoke:preview`, backed by `tools/smokePreview.ts`.
- Preview smoke reliability notes: `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`.
- Visual QA index/summary improvement plus `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`.
- Bundle/performance refresh: `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`.
- Developer command guide: `docs/DEVELOPER_COMMAND_GUIDE.md`.
- Tightened release checklist and v0.11 report: `docs/V11_TECHNICAL_RELIABILITY_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with the template-only empty intake.
- Preview helper gate: `npm run smoke:preview` passed with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.
- Visual QA gate: `npm run visual:qa` passed with 18 indexed screenshots and 0 recorded browser console errors.
- E2E smoke gate: `npm run test:e2e:smoke` passed.
- Phase/report gates: `git diff --check` passed.

### Next

- If Emmanuel provides tutorial feedback, run v0.10.1 Tutorial v2 Human-Feedback Polish.
- If source/license-documented candidate art exists, run v0.9.2 Controlled Cinderfen Style-Frame Candidate Review.
- If neither is available, the next safe autonomous goal is v0.11.1 CI Release Matrix Dry-Run and Preview Helper Portability.

## v0.10 Tutorial v2 Onboarding Refinement - 2026-05-11

This checkpoint refines Tutorial / Proving Grounds onboarding clarity, pacing documentation, overlay hierarchy, no-reward completion messaging, e2e lane documentation, visual QA review, and Emmanuel's manual playtest checklist without adding maps, units, factions, workers, enemy construction, economy AI, rewards, save persistence, campaign progression, generated art, imported art, runtime art replacement, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Tutorial v2 audit: `docs/V10_TUTORIAL_V2_AUDIT.md`.
- Tutorial pacing and scope plan: `docs/V10_TUTORIAL_V2_PACING_PLAN.md`.
- Tutorial copy refinement in `src/game/data/tutorials.ts` plus `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`.
- Small tutorial overlay hierarchy refinement in `src/game/ui/hudPanels/TutorialPanel.ts` and `src/game/styles/battle-feedback.css` plus `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`.
- Completion/no-reward clarity in the battle and main-menu handoff plus `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`.
- Tutorial e2e lane review: `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`.
- Tutorial visual QA review: `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`.
- Manual Tutorial v2 playtest checklist for Emmanuel: `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`.
- v0.10 report: `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with the template-only empty intake.
- Tutorial source/UI gates: `npm run test:e2e:smoke` passed.
- Layout gate: `npm run test:e2e:layout` passed.
- E2E lane review: `npm run test:e2e:release` passed with 67 Playwright tests.
- Visual review: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Final gate: full smoke/release, 2-way shards, 3-way shards, visual QA, simulator, diff check, and production preview smoke passed.
- Phase gates: `git diff --check` passed.

### Next

- Recommended immediate human step: Emmanuel should run `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md` and report confusing steps, screenshots, 1-5 ratings, and whether no-reward completion feels acceptable.
- Recommended next player-facing goal after feedback: v0.10.1 Tutorial v2 human-feedback polish, still no rewards, persistence, maps, units, factions, art replacement, or broad UI redesign.
- Recommended visual goal remains v0.9.2 Controlled Cinderfen Style-Frame Candidate Review only after source/license-documented candidate images exist.

## v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review - 2026-05-10

This checkpoint creates the safe non-runtime intake pipeline for future Cinderfen style-frame candidates. It adds review folders, source/license metadata templates, review manifest schema/types, metadata-only validation, a candidate scan, screenshot comparison planning, Emmanuel's manual preparation guide, and a future v0.9.2 review brief without adding generated art, imported assets, candidate binaries, runtime art, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Intake protocol: `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`.
- Non-runtime review folder structure under `art-review/`.
- Source/license metadata guide and templates: `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`, and `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`.
- Review manifest schema and tooling-only types: `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md` and `tools/art-intake/StyleFrameReviewManifestTypes.ts`.
- Metadata-only validation: `npm run validate:art-intake`, `tools/art-intake/validateArtIntake.ts`, and `tools/art-intake/validateArtIntake.test.ts`.
- Current candidate scan: `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`.
- Screenshot comparison plan: `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`.
- Manual preparation guide for Emmanuel: `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`.
- Future review brief: `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`.
- v0.9.1 report: `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with a template-only intake.
- Report gate: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Phase/report gates: `git diff --check` passed.

### Next

- Recommended next goal: v0.9.2 Controlled Cinderfen Style-Frame Candidate Review, only after Emmanuel provides source/license-documented candidates.
- Keep the next step non-runtime: validate metadata, reject unsafe candidates, catalogue safe candidates as reference/candidate only, run visual QA, and create a side-by-side human review.
- Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.9 Controlled Cinderfen Style-Frame Sprint - 2026-05-10

This checkpoint creates a docs/specs/prompts-only Cinderfen visual style-frame package before any art generation or runtime replacement. It defines the future ash-glass wetland identity, material language, shrine landmark direction, Ashen outpost architecture, unit/building scale standards, prompt pack, manifest templates, screenshot acceptance criteria, and future replacement sequence without adding generated art, imported assets, runtime art, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Cinderfen style-frame research packet: `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`.
- Cinderfen visual pillars: `docs/V09_CINDERFEN_VISUAL_PILLARS.md`.
- Terrain material sheet spec: `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`.
- Cinder Shrine/capture-site landmark spec: `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`.
- Ashen outpost architecture spec: `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`.
- Unit/building scale reference: `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`.
- Cinderfen style-frame prompt pack: `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`.
- Future Cinderfen manifest templates: `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`.
- Screenshot acceptance criteria: `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`.
- Future visual replacement implementation plan: `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`.
- v0.9 report: `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 45 test files and 340 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `git diff --check` passed.
- Report gate: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.

### Next

- Recommended next goal: v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review.
- Keep the next step non-runtime first: obtain 1 to 3 style-frame candidates, record source/license metadata, track as reference/candidate only, validate, run visual QA, and write a human source/screenshot review.
- Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion - 2026-05-10

This checkpoint hardens the visual asset pipeline by reviewing source/license risk, adding conservative source-review metadata, strengthening manifest validation, expanding optional screenshot QA coverage, and preparing a safe v0.9 visual direction without adding art, generated images, external assets, large binaries, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Source/license review plan: `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`.
- Asset source/license audit: `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`.
- Manifest metadata refinement with `reviewStatus` and `sourceReviewNotes`.
- Manifest validation hardening for production approval, runtime/reference conflicts, deprecated runtime assets, critical replacement notes, and production-safe source/license requirements.
- Screenshot coverage expansion plan: `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`.
- Expanded optional `npm run visual:qa` harness from 10 to 18 indexed screenshots, including Asset Gallery, Hero Inventory, tutorial mobile, route-complete campaign map, Cinderfen Crossing tablet, Crossing pressure warning, victory Results, and defeat Results.
- Extended screenshot review: `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`.
- Visual risk register: `docs/VISUAL_RISK_REGISTER.md`.
- v0.9 controlled visual sprint brief: `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`.
- v0.8.2 report: `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 340 tests during phase/report gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase/report gates.
- `npm run validate:content`: passed with gameplay content and hardened visual asset metadata validation.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during screenshot/report gates.
- `npm run visual:qa`: passed with 18 indexed review screenshots and zero recorded browser console errors.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the report gate.
- `git diff --check`: passed during phase/report gates.

### Next

- Recommended next goal: v0.9 Controlled Cinderfen Style-Frame Sprint.
- Keep the first v0.9 visual step docs/specs/prompts-only: terrain material sheet, Cinder Shrine/capture-site landmark sheet, and Ashen outpost architecture sheet.
- Do not generate, import, download, commit, or wire runtime art assets until a future goal explicitly scopes source/license metadata, manifest updates, validation, and before/after screenshot QA.

## v0.8.1 Visual Asset Manifest and Screenshot QA Gate - 2026-05-10

This checkpoint creates the visual asset manifest, metadata validation, runtime asset cross-check, and non-brittle screenshot QA foundation without adding final art, generated art, external assets, large binaries, gameplay content, new maps, new units, new factions, workers, enemy construction, economy AI, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Existing asset inventory audit across `public/assets/`, manual/final/runtime assets, loader references, and source usage.
- Typed visual asset manifest schema and 89-entry initial manifest covering runtime assets, manual source originals, procedural terrain debt, and future prompt/spec references.
- Visual asset metadata validation integrated into `npm run validate:content`, including runtime file existence checks in the CLI path.
- Runtime asset usage cross-check for battle textures, ability icons, UI-kit CSS assets, faction emblem, and screen backgrounds.
- Optional screenshot QA harness: `npm run visual:qa`, backed by `playwright.visual-qa.config.ts` and `tests/visual-qa/visual-qa.spec.ts`.
- Ignored screenshot output under `/visual-qa/`, with generated review index and zero pixel-perfect assertions.
- Screenshot QA review for main menu, tutorial, campaign map, skirmish setup, Cinderfen Crossing, Cinder Shrine capture, Cinderfen Watch, and Watch pressure warning.
- Cinderfen visual asset replacement backlog.
- Safe future asset prompt/spec templates.
- v0.8.1 report: `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 339 tests during the final gate.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during the final gate.
- `npm run validate:content`: passed with gameplay content and visual asset metadata validation.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during the final gate.
- `npm run test:e2e:release`: passed with 67 Playwright tests during the final gate.
- `npm run test:e2e:release:shard1`: passed with 55 Playwright tests during the final gate.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests during the final gate.
- `npm run test:e2e:release:shard1of3`: passed with 28 Playwright tests during the final gate.
- `npm run test:e2e:release:shard2of3`: passed with 27 Playwright tests during the final gate.
- `npm run test:e2e:release:shard3of3`: passed with 12 Playwright tests during the final gate.
- `npm run visual:qa`: passed with 10 generated review screenshots and zero recorded browser console errors.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the final gate.
- Production preview smoke: passed at `http://127.0.0.1:57934/` with title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors verified.
- `git diff --check`: passed during the final gate.

### Next

- Recommended next goal: v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion.
- Keep future visual work manifest-backed, source/license-reviewed, and screenshot-QA reviewed before committing binary replacements.
- Tutorial v2 onboarding refinement remains the safest player-facing alternative.

## v0.8 Technical Performance, E2E Runtime, and Visual Foundation Gate - 2026-05-10

This checkpoint refreshes technical performance/e2e runtime facts and creates a disciplined visual foundation without adding workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, desktop packaging, engine switching, external generated assets, large binary assets, a full UI redesign, a graphics overhaul, or broad systems.

### Included

- Refreshed performance and bundle audit with current app JS, Phaser vendor, CSS, gzip sizes, analyzer findings, and production-leak scan.
- E2E runtime and shard imbalance audit for the 67-test release suite.
- Additive optional 3-shard release scripts: `test:e2e:release:shard1of3`, `test:e2e:release:shard2of3`, and `test:e2e:release:shard3of3`.
- Visual debt audit covering terrain, roads, water/swamp, capture sites, units, buildings, minimap, HUD, and style mismatch.
- Visual scale/readability audit covering hero/unit/building/capture-site/minimap/camera/fog/pathfinding scale rules.
- Explicit no-code visual readability decision for v0.8.
- 2026 art direction bible for future original dark heroic fantasy RTS/RPG visuals.
- Asset pipeline plan for future source/license/status/scale metadata.
- Cinderfen visual rework spec with future identity, readability requirements, art prompt templates, and implementation phases.
- v0.8 report: `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during phase gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase gates.
- `npm run validate:content`: passed during phase gates.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 6.1m during the visual readability gate.
- `npm run test:e2e:layout`: first attempt hit the command timeout with no failing-test output; after cleaning repo-local leftover Playwright/Vite Node processes and rerunning with a longer timeout, passed with 25 Playwright tests in 14.9m.
- `npm run test:e2e:release:shard1of3`: passed with 28 Playwright tests in 12.3m.
- `npm run test:e2e:release:shard2of3`: passed with 27 Playwright tests in 14.9m.
- `npm run test:e2e:release:shard3of3`: passed with 12 Playwright tests in 5.3m.
- Report-gate `npm run test:e2e:smoke`: passed with 12 Playwright tests in 6.3m.
- Report-gate `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: passed during phase gates.

### Next

- Recommended next goal: v0.8.1 Visual Asset Manifest and Screenshot QA Gate, with no new assets or graphics overhaul.
- Alternative player-facing goal: Tutorial v2 onboarding refinement.
- Keep pressure-specific work blocked on manual feedback and simulator-only first experiments; do not promote live reinforcement, route contesting, or defensive hold behavior yet.

## v0.7.3 Real-Input Cinderfen Pressure Playtest - 2026-05-09

This checkpoint reviews Cinderfen pressure with controlled browser input and simulator evidence without expanding Enemy Strategic Pressure into workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Real-input pressure playtest protocol and seeded browser setup notes.
- Controlled browser-input review for Cinderfen Crossing, including natural Cinder Shrine capture and seeded delayed-warning visibility evidence.
- Controlled browser-input review for Cinderfen Watch, including natural Watch Road capture, immediate warning visibility, delayed warning visibility, and pressure-priority protection against generic status churn.
- Strategy-profile pressure review for Safe Beginner, Greedy Economy, Fast Army, and Retinue + Training Yard II.
- Manual Cinderfen pressure checklist for Emmanuel with 1 to 5 ratings for warning clarity, timing, fairness, usefulness, fun, and frustration.
- Explicit evidence-backed no-change decision: no pressure copy, timing, status-duration, defeat-tip, telemetry, e2e, scope, wave-nudge, or balance change.
- v0.8 direction brief recommending technical performance/e2e runtime work before any pressure-specific simulator-only reinforcement experiment.
- v0.7.3 report: `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during phase gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase gates.
- `npm run validate:content`: passed during phase gates.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during pressure review/polish/report gates.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during pressure review/polish/report gates.
- Pressure telemetry remains 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed during phase gates.

### Next

- Recommended next goal: v0.8 technical performance/e2e runtime pass, with Tutorial v2 onboarding refinement as the safer player-facing alternative.
- Emmanuel should still run the manual pressure checklist before any pressure-specific v0.8 work.
- If pressure work resumes, start with simulator-only `reinforce_next_wave`; do not promote live reinforcement, route contesting, defensive hold behavior, workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, or broad systems.

## v0.7.2 Human-Paced Cinderfen Pressure Review - 2026-05-09

This checkpoint reviews Cinderfen pressure feel and warning readability without expanding Enemy Strategic Pressure into workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Human-paced pressure review protocol and browser review notes.
- Seeded browser evidence and screenshot inspection for Cinderfen Crossing pressure warnings.
- Seeded browser evidence and screenshot inspection for Cinderfen Watch pressure warnings.
- Explicit no-change pressure readability decision: no warning copy, timing, status-duration, defeat-tip, telemetry, e2e, scope, or wave-nudge change.
- Retinue + Training Yard II pressure review documented as a saved-progress power watchpoint, not a pressure bug.
- Greedy Economy and Fast Army pressure review with no tuning applied.
- Fresh next-action decision keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- v0.7.2 report: `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during the report gate.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during the report gate.
- `npm run validate:content`: passed during the report gate.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.2m during the report gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the report gate.
- Pressure telemetry remains 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed during the report gate.

### Next

- Recommended next goal: v0.7.3 real-input Cinderfen pressure playtest.
- Focus on warning noticeability during actual unit commands, Cinder Shrine salience, Watch Road fairness, Greedy Economy timeout clarity, Fast Army quick-clear feel, and Retinue + Training Yard II power.
- Only after stronger human evidence should v0.8 consider a simulator-only `reinforce_next_wave` experiment.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, broad systems, live reinforcements, capture-site contest AI, and defensive-hold behavior.

## v0.7.1 Enemy Pressure Feel Review and Warning Polish - 2026-05-09

This checkpoint reviews, polishes, and hardens Enemy Strategic Pressure V1 without expanding it into real enemy construction, workers, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Pressure feel audit for Cinderfen Crossing and Cinderfen Watch.
- Clearer pressure warning copy and pressure-specific defeat tips.
- Pressure battle-status priority with a longer read window.
- Objective battle-status priority above pressure so `Cinder Shrine Surge` and capture feedback stay readable.
- Focused pressure e2e hardening for visible warning priority, Tutorial no-pressure protection, and skirmish no-pressure protection.
- Clearer simulator report wording with readable pressure plan/stage labels, triggered/quiet run counts, and per-strategy pressure reads.
- Pressure balance review with no tuning applied.
- Action promotion gate keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- v0.7.1 report: `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.3m during the final gate.
- Focused pressure e2e: passed with 2 Playwright tests in 43.1s during visibility hardening.
- `npm run test:e2e:release`: passed with 67 Playwright tests in 32.9m during the final gate.
- `npm run test:e2e:release:shard1`: passed with 55 Playwright tests in 28.2m during the final gate.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 5.0m during the final gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- Pressure telemetry: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- Production preview smoke: passed at `http://127.0.0.1:57931/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.
- `git diff --check`: passed.

### Next

- Human-play Cinderfen Crossing and Cinderfen Watch to judge warning salience and fairness.
- Keep follow-up limited to copy, timing, scope, telemetry, or a simulator-first tiny combat experiment only if human evidence justifies it.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, broad systems, live reinforcements, capture-site contest AI, and defensive-hold behavior.

## v0.7 Enemy Strategic Pressure V1 - 2026-05-09

This checkpoint adds the first controlled enemy commander pressure prototype. It preserves the frozen v0.3 Cinderfen Route Baseline, v0.3.1 polish layer, v0.4 technical groundwork, v0.5 safety gate, v0.6 tutorial foundation, and v0.6.1 tutorial feel polish. It does not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

### Included

- Enemy Strategic Pressure research audit, design spec, and final report.
- Data model and metadata for `causeway_contest_pressure` and `ashen_watch_captain_pressure`.
- Content validation for pressure plan ids, stage ids, map/node references, trigger/action types, unit references, capture-site references, and forbidden worker/construction/economy fields.
- Campaign-only runtime pressure tracker for Cinderfen Crossing and Cinderfen Watch.
- Existing battle status warning copy and pressure-specific battle stats/telemetry.
- One safe existing-wave timing nudge; reinforcement, contest, and defensive-hold actions remain warning/telemetry-only.
- Pressure-aware defeat tip copy only when pressure actually triggered.
- Simulator telemetry and generated pressure balance-gate reporting.
- Targeted Playwright release coverage for Cinderfen Watch pressure and Tutorial/skirmish no-pressure guards.

### Verification

- `npm test`: passed with 44 test files and 328 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.4m during the balance gate.
- Focused pressure e2e: passed with 2 Playwright tests in 49.4s.
- `npm run test:e2e:release`: passed with 67 Playwright tests in 29.4m during the e2e coverage gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- Pressure telemetry: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 149 warnings, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed.

### Next

- Human-play Cinderfen Crossing and Cinderfen Watch for pressure warning salience and fairness.
- Keep follow-up limited to copy, timing, scope, telemetry, or a tiny combat effect only if human evidence justifies it.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems.

## v0.6.1 Tutorial Feel Polish - 2026-05-09

This checkpoint finishes a small Browser-evidenced Tutorial / Proving Grounds feel pass. It preserves the existing no-reward, non-persistent tutorial shell and does not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

### Included

- Visible Browser review of main-menu Tutorial entry, desktop first objective, mobile-short first objective, Exit Tutorial, and console output.
- New review doc: `docs/V061_TUTORIAL_FEEL_REVIEW.md`.
- Mobile-short overlay priority polish so the tutorial panel renders above transient battle feedback instead of being interrupted by the battle status banner.
- Responsive layout assertion that protects tutorial overlay z-index priority over battle status feedback.
- v0.6.1 updates to the tutorial polish plan, readability surrogate review, and tutorial feel audit.

### Verification

- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:layout -- --grep "tutorial entry"`: passed with 4 Playwright tests in 43.2s.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 4.9m.
- `npm run test:e2e:layout`: passed with 25 Playwright tests in 12.4m.
- Production preview Browser smoke: passed at `http://127.0.0.1:57919/`; title, Tutorial launch/exit, first overlay, and zero browser warnings/errors were verified.

### Next

- Human-play the full twelve-step tutorial at normal speed before adding any tutorial content.
- Keep future follow-up limited to readability, overlay hierarchy, and no-reward completion clarity unless a narrow verified bug appears.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems.

## v0.6 Tutorial Onboarding And Testing Foundation - 2026-05-08

This checkpoint polishes and hardens the playable Tutorial / Proving Grounds shell while preserving the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content-validation gate, and no-reward tutorial policy. It does not add rewards, save-version changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, campaign progression, or broad systems.

### Included

- Tutorial human-feel surrogate audit.
- Tutorial copy tightening and hierarchy polish.
- Mobile-short overlay width and footer layout polish.
- Session-only no-reward completion notice on the main menu.
- Tutorial e2e runtime placement review keeping full completion in smoke for now.
- Test-only semantic command-log V1 helper used by exactly one tutorial completion smoke path.
- Command-log V1 plan and report.
- Tutorial accessibility checks for polite live-region semantics, described instruction/condition text, and explicit button labels.
- Desktop/2026 visual-direction plan, planning only.
- v0.6 onboarding/testing foundation report.

### Verification

- Phase 11 report gate and final full verification passed.
- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 4.8m during the final gate.
- `npm run test:e2e:layout`: passed with 25 Playwright tests in 12.5m after accessibility polish.
- `npm run test:e2e:release`: passed with 65 Playwright tests in 28.9m during the final gate.
- `npm run test:e2e:release:shard1`: passed with 53 Playwright tests in 24.0m.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 4.9m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes and no telemetry diff.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57918/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Recommended next long-running goal: human-paced Tutorial / Proving Grounds review and small v0.6.1 tutorial feel polish.
- Keep command-log V1 test-only and at one consumer unless a concrete second test path needs it.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems until their gates are explicit and green.

## Tutorial / Proving Grounds Playable Shell - 2026-05-08

This checkpoint implements the first playable Tutorial / Proving Grounds shell on top of the v0.5 safety gate. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate. It does not add rewards, save-version changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, campaign progression, or broad systems.

### Included

- Main-menu Tutorial launch surface.
- Validated playable tutorial metadata for `proving_grounds_basics`.
- Dedicated `tutorial` battle launch mode with rewards disabled.
- Existing-content Tutorial / Proving Grounds shell on `first_claim` using transient Warlord Aster data.
- Lightweight tutorial HUD overlay with current objective, instruction, hint, progress, completion condition, Next Objective, Complete Tutorial, and Exit Tutorial.
- Linear twelve-step objective model for camera, selection, movement, capture, resources, Command Hall, Barracks, Militia, rally point, Rally Banner, safe pressure, and completion.
- Non-persistent no-reward completion and exit paths back to the main menu.
- XP/veterancy guard for rewards-disabled tutorial kills.
- Save/persistence audit, tutorial content-validation gate, readability surrogate review, and playable-shell report.
- Unit, content-validation, smoke e2e, and layout e2e coverage for the tutorial shell.

### Verification

- Phase 12 report verification and final full gate passed.
- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.2m.
- `npm run test:e2e:release`: passed with 65 Playwright tests in 28.5m.
- `npm run test:e2e:release:shard1`: passed with 53 Playwright tests in 24.4m.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 4.9m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes and no telemetry diff.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57916/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Human-play Tutorial / Proving Grounds for length, clarity, mobile readability, building/training/rally timing, and no-reward completion clarity.
- Keep follow-up polish small: copy tightening, overlay hierarchy, completion clarity, and layout spacing only.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems until their gates are explicit and green.

## v0.5 Save Content Validation Gate - 2026-05-08

This checkpoint builds the v0.5 safety foundation before broad mechanics or new content expansion. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, and v0.4 technical groundwork. It does not add playable tutorial content, gameplay balance changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, monetization code, or broad army-management systems.

### Included

- File-backed save fixtures and test utilities under `tests/fixtures/saves/`.
- Fixture-based save migration and normalization tests for V1, V2, settings-only, invalid JSON, affixed inventory, legacy equipment, campaign progress, retinue, rivals, trophies, Chapter 2, and Cinderfen route state.
- Expanded save compatibility documentation and current save-version policy; save version remains `2`.
- Stronger content validation for campaign graph references, maps, reward tables, repeat rewards, event/town effects, modifiers, map objectives, enemy AI references, and tutorial metadata.
- Standalone `npm run validate:content` gate.
- Campaign graph and reward economy report.
- Command-log replay feasibility study recommending a future test-only semantic replay slice, not production replay.
- Simulator determinism report and tests locking the simulator matrix/schema and deterministic summary behavior.
- Candidate A, Tutorial / Proving Grounds, selected as the future vertical-slice candidate.
- Tutorial / Proving Grounds design brief plus a non-playable metadata-only scaffold.

### Verification

- Phase 14 documentation-gate verification passed.
- `npm test`: passed with 40 test files and 298 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests in 4.5m.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 28.4m.
- `npm run test:e2e:release:shard1`: passed with 49 Playwright tests in 23.9m.
- `npm run test:e2e:release:shard2`: passed with 10 Playwright tests in 4.4m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57915/`; title, main menu copy, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Recommended next long-running goal after full v0.5 verification: implement the first Tutorial / Proving Grounds playable shell using existing content only.
- Keep the first tutorial implementation non-rewarding, validation-first, and save-compatible.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Overnight Autonomous Progress Checkpoint - 2026-05-08

This checkpoint completes the extended v0.4 technical, UX, save-safety, route-review, and planning pass while preserving the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It does not add gameplay, change balance, alter save format, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, monetization code, or broad systems.

### Included

- Bundle analyzer report refreshed and the current production chunks documented.
- Test/dev hook production audit refreshed; no accidental large production leak was found.
- Analyzer-backed optimization decision recorded as no additional code optimization.
- E2E sharding plan and scripts verified while preserving the full 59-test release gate.
- One test-only rally wait in `tests/e2e/deep-flow.spec.ts` hardened against timing flake without changing gameplay.
- Settings readability copy clarified for colorblind minimap team markers and small-screen command-panel guidance.
- Save compatibility audited in `docs/SAVE_COMPATIBILITY_AUDIT.md`, with one new test preserving valid Chapter 2 selected chapter/node state.
- Automated route-feel surrogate review added in `docs/V04_ROUTE_FEEL_SURROGATE_REVIEW.md`.
- Full-game architecture docs expanded for fifteen future-system tracks, including modding/data-driven content, tutorial/onboarding, monetization/packaging, and recommended order.
- Tiny no-gameplay polish backlog added in `docs/V04_POLISH_BACKLOG.md`.

### Verification

- `npm test`: passed with 38 test files and 271 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests in 4.6m.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 27.8m.
- `npm run test:e2e:release:shard1`: passed with 49 Playwright tests in 23.0m.
- `npm run test:e2e:release:shard2`: passed with 10 Playwright tests in 4.2m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57911/`; main menu, New Campaign, Continue Campaign, Skirmish Setup, and browser console error checks passed.

### Next

- Recommended next long-running goal: v0.5 save/content-validation gate.
- Add fixture-based migration tests, future content validation rules, deterministic command-log feasibility notes, and one explicitly approved vertical-slice candidate before broad mechanics.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Autonomous Goal Progress Checkpoint - 2026-05-07

This checkpoint advances v0.4 technical/readability planning while preserving the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It does not add gameplay, change balance, alter saves, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, or broad systems.

### Included

- Settings readability/accessibility polish: clearer toggle labels and hints, UI Scale explanation, Fog of War Override labels, and a broader keyboard/control reference.
- New accessibility plan: `docs/V04_ACCESSIBILITY_READABILITY_PLAN.md`.
- New planning-only full-game architecture docs:
  - `docs/FULL_GAME_ROADMAP.md`
  - `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`
  - `docs/V05_SYSTEMS_DESIGN_BRIEF.md`
- Existing bundle analyzer, hook audit, no-op second optimization decision, and e2e shard scripts were validated and left behavior-preserving.

### Verification

- `npm test`: passed with 38 test files and 270 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 26.1m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57705/`; main menu loaded and browser console errors stayed at 0.

### Next

- Recommended next milestone: v0.5 save/content-validation gate before broad mechanics.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, and broad army-management systems until their gates are explicit and green.

## v0.3.1 Polish Release Frozen - 2026-05-06

The v0.3.1 polish release is now frozen. v0.3 remains the Cinderfen Route Baseline content release; v0.3.1 is a polish/readability/performance-audit/test-maintenance release on top of that baseline. This freeze does not add gameplay, change balance, refactor code, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems.

### Freeze Verification

- `npm test`: passed with 38 test files and 270 tests.
- `npm run build`: passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: passed with 59 Playwright tests in 28.6m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle node/profile summaries.
- `git diff --check`: passed with no whitespace errors.
- Production preview smoke: passed at `http://127.0.0.1:4188/`; main menu loaded with `Prototype v0.3` / `Cinderfen Route Baseline`, New Campaign reached Campaign Map, Continue Campaign returned to Campaign Map, Skirmish Setup opened, and browser console errors stayed at 0.

### Frozen Scope

- v0.3.1 preserves the frozen v0.3 Cinderfen content route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- v0.3.1 includes mobile/readability audit coverage, Cinderfen copy/hierarchy polish, route-complete clarity, Results copy improvements, performance/bundle audit documentation, e2e runtime audit documentation, and safe shared e2e helper cleanup.
- No risky bundle optimization or test coverage reduction was implemented.
- Release report: `docs/V031_POLISH_RELEASE_REPORT.md`.
- Next phase: **v0.4 planning or technical optimization**.
- Recommended next work: human readability review of the frozen route, measurement-first performance optimization, or explicit e2e default/release-gate script planning.
- Postponed next work: workers, enemy construction, new factions, new maps, new units, diplomacy, procedural systems, crafting, durability, and broad systems.

## v0.3 Cinderfen Route Baseline Frozen - 2026-05-05

The v0.3 Cinderfen Route Baseline is now frozen. This freeze does not add gameplay, change balance, refactor code, or add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad loot systems.

### Freeze Verification

- `npm test`: passed with 38 test files and 268 tests.
- `npm run build`: passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: passed with 52 Playwright tests.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle node/profile summaries.
- `git diff --check`: passed with no whitespace errors.
- Production preview smoke: passed at `http://127.0.0.1:4187/`; main menu loaded with `Prototype v0.3` / `Cinderfen Route Baseline`, New Campaign, Continue Campaign, Skirmish Setup, and Campaign Map did not crash, and browser console errors stayed at 0.

### Frozen Scope

- Frozen route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- Cinderfen Aftermath remains the end of the current playable v0.3 slice.
- Next phase: **v0.3.1 polish and human readability review**.
- Allowed next work: copy clarity, UX hierarchy, mobile/readability checks, small bug fixes, and controlled polish on the existing frozen route.
- Postponed next work: workers, enemy construction, new factions, diplomacy, procedural generation, crafting, new maps, and broad systems.

## v0.3 Cinderfen Route Baseline Candidate - 2026-05-04

This checkpoint promotes the current Cinderfen route to the v0.3 vertical-slice baseline candidate. It does not add gameplay, change balance, or add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad loot systems. The visible in-game menu now labels the playable build as `Prototype v0.3` with the subtitle `Cinderfen Route Baseline`; v0.2 remains the previous systems baseline.

### Route Baseline

- Current playable route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- Main menu product copy is aligned with the current route baseline: `Prototype v0.3` / `Cinderfen Route Baseline`.
- `docs/V03_CINDERFEN_ROUTE_BASELINE.md` records the current route order, rewards summary, simulator summary, e2e summary, known risks, forbidden next steps, and recommended next steps.
- The Chapter 2 reward-economy audit is complete: first clears remain useful, repeat clears now pay only tiny XP/resources, and repeat battle item rolls are disabled for the Cinderfen battles.
- Chapter 2 Playwright helper cleanup is complete in `tests/e2e/chapter2-helpers.ts`, with behavior-preserving helpers for post-Ashen setup, Waystation service flows, Crossing/Watch launch, shrine capture, and test-only victory fast-forwards.
- Chapter 1 reward values and route stability remain unchanged.

### Current Release Verification Expectations

- `npm test`: latest checkpoint passed with 38 test files and 268 tests.
- `npm run build`: latest checkpoint passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: latest full suite passed with 52 Playwright tests.
- `npm run playtest:sim`: latest simulator baseline passed with 255 deterministic runs across 85 campaign battle node/profile summaries, no structural too-hard nodes, no structural too-easy nodes, Ashen Outpost beatable, no Stronghold warnings, and Cinderfen repeat rewards reduced to tiny non-item payouts.
- Optional `npm run preview` plus Browser Use smoke remains useful for a visible production-preview check and browser console-error check.

### Next Phase

- Next phase: **automated route readiness + polish freeze**.
- Best current work is verification, readability, UX, copy clarity, mobile density checks, and controlled polish on the existing route.
- Continue to avoid workers, enemy construction, new factions, new maps, new units, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems unless explicitly requested.

## v0.2.1 Prototype Baseline Candidate - 2026-05-03

This checkpoint packages the v0.2 feature baseline with the follow-up technical and UX stabilization work. It does not add gameplay or change balance. At that historical checkpoint, the visible in-game menu labeled the playable prototype as `Prototype v0.2`; `v0.2.1` was the release-baseline candidate for docs, verification expectations, refactor state, and HUD/fog regression coverage.

### Completed Since v0.2

- CampaignRules module split completed: `CampaignRules.ts` is now a compatibility facade over focused pure campaign modules for nodes, choices, rewards, reputation, modifiers, town services, and rival hooks.
- HUD interaction polish completed: battle command hover no longer flickers under routine HUD refresh, and long side-panel scroll positions are preserved across refreshes.
- Captured-site fog polish completed: player-owned captured resource sites remain locally revealed after the capturing units move away.
- Permanent Playwright regression coverage added for command hover stability, side-panel scroll preservation, captured resource-site fog visibility, and desktop/tablet/mobile battle command reachability.
- Rival/Nemesis Persistence V1 and Rival Rewards and Trophies V1 are part of the completed v0.2.1 baseline rather than the next milestone.

### Historical v0.2.1 Verification Expectations

- `npm test`: expected to pass with 36 test files and 210 tests.
- `npm run build`: expected to pass with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: latest full suite passed with 49 Playwright tests after the HUD/fog regression coverage was added.
- `npm run playtest:sim`: latest simulator baseline passed with 180 deterministic runs, no structural too-hard nodes, no structural too-easy nodes, Ashen Outpost beatable, and no Stronghold warnings.
- Optional Browser Use preview sanity remains recommended for a visible production-preview check and browser console-error check.

### Historical Next Phase

- This milestone is superseded by the v0.3 Cinderfen route baseline candidate above.
- Before adding Chapter 2 content, do a human-paced readability pass on retinue, rival rewards/trophies, HUD hover/scroll feel, captured-site fog readability, and Ashen Outpost pressure.
- Continue to avoid workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems unless explicitly requested.

## v0.2 Prototype Baseline - 2026-05-02

This release baseline captures the current playable Ascendant Realms prototype so it is easier to share, test, and continue from. It does not represent a content-complete game; it is the stable RTS/RPG campaign spine with Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, and Rival Rewards and Trophies V1 included.

### Campaign And Skirmish Structure

- Main menu flow labels the build as `Prototype v0.2` with the subtitle `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`, and supports New Campaign, Continue Campaign, Skirmish, Hero Inventory, Settings, Asset Gallery, Info, and Reset Save.
- The Border Marches mini-campaign has eight authored nodes: Border Village, Old Stone Road, Marcher Camp, Aether Well Ruins, Bandit Hillfort, Chapel of the Marches, Refugee Caravan, and Ashen Outpost.
- Campaign battle nodes and standalone skirmishes launch through the shared `BattleLaunchRequest` path.
- Skirmish mode includes First Claim, Broken Ford, and Ashen Outpost with difficulty and AI-personality selection.
- Results return battle rewards, campaign node rewards, victory/defeat actions, and save updates through the shared Results flow.

### Hero Progression

- Heroes have class, origin, stats, XP, levels, skill points, skill trees, and class abilities.
- Current classes are Warlord, Arcanist, and Shepherd.
- Current equipment slots are weapon, armor, and trinket, with item instances stored in inventory and equipment referencing instance IDs.
- Victory rewards can grant XP, resources, and item instances; unique duplicate rewards convert into campaign resources.
- Equip Now and Hero Inventory both persist equipment changes and recalculate hero stats.

### RTS Battle Loop

- Battles include hero and unit selection, movement, attack commands, attack-move, projectiles, capture sites, neutral camps, enemy bases, and victory/defeat resolution.
- Player construction supports Barracks, Mystic Lodge, and Watchtower placement with previews, construction progress, production locks, and rally points.
- Unit training queues support Militia, Rangers, and Acolytes with visible progress and cancel/refund behavior.
- Research upgrades include current data-driven battle upgrades such as infantry, armor, ranger, and Aether study lines.
- Unit Veterancy V1 gives player non-hero units battle-local XP, Recruit/Seasoned/Veteran/Elite ranks, modest stat bonuses, selected-unit rank display, rank-up feedback, and Notable Veterans in victory Results.
- Retinue Camp V1 lets campaign victories save a small number of surviving Seasoned+ veterans, shows them on the Campaign Map, deploys them in future campaign battles, and removes them permanently if they die.
- Enemy Hero / Rival Commander V1 adds three named Ashen commanders: Gorak Emberhand on Bandit Hillfort, Veyra of the Cinders on Aether Well Ruins, and Captain Malrec on Ashen Outpost, with scout feedback, minimap markers, modest abilities, XP/objective/results credit, and simulator telemetry.
- Rival/Nemesis Persistence V1 saves commander encounters, defeats, victories against the player, last outcomes, dispositions, small repeat-encounter modifiers, Campaign Map intel, and Results consequence copy.
- Rival Rewards and Trophies V1 adds data-driven once-only first-defeat rewards, duplicate prevention, persistent trophy records, Results reward copy, and compact Campaign Map trophy display.
- Enemy AI expands, trains, defends, and sends pressure waves through data-driven personalities.

### Fog And Minimap

- Fog of war uses unseen, explored, and visible grid states, with Story difficulty able to disable fog.
- Enemy and neutral units/buildings are hidden outside current vision.
- The minimap renders units, buildings, capture sites, camps, rally points, pings, and the camera viewport.
- Minimap click-to-pan, fog toggles, alert pings, and colorblind minimap palette support are covered by automated browser tests.

### Stronghold Development

- Stronghold Development is a compact two-tier persistent-upgrade system, not a city-builder.
- Tier I upgrades are Training Yard I, Watch Post I, Quartermaster Stores I, Chapel Corner I, and Ranger Paths I.
- Tier II upgrades are Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II.
- Tier II upgrades require their matching Tier I upgrade.
- Implemented effects stay compact: starting units, starting resources, hero HP/Mana multipliers, warning lead time, Watchtower range, building vision, first-building construction speed, Militia/Ranger training speed, and Training Yard II's +1 Retinue capacity.

### Reputation Effects

- Reputation ranks exist for Free Marches, Common Folk, Old Faith, Ashen Covenant, and the Sylvan Concord placeholder.
- Shared thresholds are Friendly at 25, Honored at 50, Disliked at -25, and Hostile at -50.
- Common Folk Friendly discounts Marcher Camp services.
- Free Marches Friendly discounts Stronghold Crown costs.
- Old Faith Friendly improves Chapel Aether rewards.
- Ashen Covenant Hostile adds minor Ashen-node pressure through the existing launch-modifier path.
- Campaign choice cards show costs, adjusted rewards, reputation deltas, resulting reputation value/rank, modifiers, and completion behavior.

### Randomized Item Affixes V1

- Item instances can roll small, slot-filtered affixes from `src/game/data/itemAffixes.ts`.
- Current affixes are Sturdy, Sharp, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's.
- Rarity rules are common 0-1, uncommon 1, rare 1-2, epic 2, and legendary 2-3 affixes.
- Deterministic affix generation exists for tests and scripted e2e rewards.
- Affixes persist on item instances, old empty-affix saves remain valid, and equipped affixes contribute to hero stats.
- Results and Inventory display affix names, base stats, affix stat contribution, total item stats, and equip preview deltas.

### Automated Playtest Simulator

- `npm run playtest:sim` regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.
- The simulator currently runs 180 deterministic campaign battle runs across 60 profile-node summaries.
- Profiles include no Stronghold upgrades, Tier I paths, a Tier II Quartermaster path, and retinue-aware profiles for one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Telemetry includes assigned rival commander id, defeated state, attack-join timing, losses involving the rival, objective completion, rival state before/after, rival outcome, active rival modifiers, first-defeat reward state, duplicate prevention, and trophy-earned state.
- Latest simulator status: no too-easy nodes, no structural too-hard nodes, Ashen Outpost beatable, and no Stronghold warnings.

### Historical Verification Status

Latest full verification recorded at the v0.2 point after Rival Rewards and Trophies V1:

- `npm test`: 36 test files, 210 tests passing.
- `npm run build`: passing with the known Vite large-chunk warning.
- `npm run test:e2e -- --reporter=line`: 45 Playwright tests passing.
- `npm run playtest:sim`: 180 simulated runs passing.

Known release caveat: the Vite production build reports that the main Phaser bundle is larger than the default 500 kB chunk warning threshold. This is tracked as a warning, not a failure.

### Historical Next Milestone

- At the v0.2 baseline point, the next recommended pass was Rival Rewards Balance And Readability Review.
- This is now superseded by the v0.3 Cinderfen route baseline candidate above; the current next phase is `automated route readiness + polish freeze`.
