# Changelog

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

- Phase 11 report gate passed before final full verification.
- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.0m during the report gate.
- `npm run test:e2e:layout`: passed with 25 Playwright tests in 12.5m after accessibility polish.
- `npm run test:e2e:release`: passed with 65 Playwright tests in 28.8m after command-log V1.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes and no telemetry diff.
- `git diff --check`: passed.

### Next

- Run final full verification for v0.6.
- Recommended next long-running goal after the final gate: human-paced Tutorial / Proving Grounds review and small v0.6.1 tutorial feel polish.
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
