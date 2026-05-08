# Ascendant Realms Roadmap

## Product Pillars

Every phase should protect these long-term pillars:

1. Persistent hero fantasy: race, class, origin, items, scars, titles, retinue, reputation, and choices should make the hero feel personal.
2. Faction asymmetry: factions need different economies, rhythms, combat identities, and strategic weaknesses.
3. Living campaign map: the world should react with alliances, betrayals, invasions, shops, temples, ruins, contracts, holy orders, cursed lands, and ancient threats.
4. Data-driven and mod-friendly content: future expansion should mostly mean adding data and assets, not rewriting engine code.

## Current Recommended Next Phase

The latest feature checkpoint is the **Tutorial / Proving Grounds playable shell** on 2026-05-08. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate while adding a safe no-reward onboarding shell that reuses existing First Claim content.

The next recommended phase is **human-paced Tutorial / Proving Grounds review and small tutorial polish**, with no new maps, units, factions, rewards, save-version changes, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, or broad systems.

New tutorial shell docs:

- `docs/TUTORIAL_PLAYABLE_SHELL_PLAN.md`
- `docs/TUTORIAL_SAVE_PERSISTENCE_AUDIT.md`
- `docs/TUTORIAL_CONTENT_VALIDATION_GATE.md`
- `docs/TUTORIAL_READABILITY_SURROGATE_REVIEW.md`
- `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`

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

Recommended next phase after the playable tutorial shell: **human-paced Tutorial / Proving Grounds review and small tutorial polish**, keeping the shell existing-content-only and no-reward.

The current release baseline is **v0.3.1 Polish Release - frozen**. v0.3 remains the frozen Cinderfen Route Baseline content release; v0.3.1 is the polish/readability/performance-audit/test-maintenance release on top of that content baseline. The v0.5 gate is the active post-freeze safety/planning baseline, and the Tutorial / Proving Grounds shell is the first safe onboarding vertical slice on top of it.

Latest checkpoint verification: 2026-05-08. `npm test`, `npm run build`, `npm run test:e2e:smoke`, `npm run test:e2e:release`, `npm run test:e2e:release:shard1`, `npm run test:e2e:release:shard2`, `npm run playtest:sim`, `git diff --check`, and production preview smoke passed. No gameplay, content, balance, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, monetization code, or multiplayer was added.

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
- [x] Cinderfen Crossing: `cinderfen_crossing` is playable after `cinderfen_overlook` and launches the authored `cinderfen_causeway` / **Cinderfen Causeway** battle map.
- [x] Cinderfen Watch: `cinderfen_watch` is playable after `cinderfen_crossing` and launches the compact `cinderfen_watchpost` / **Cinderfen Watchpost** battle map.
- [x] Cinderfen Aftermath: `cinderfen_aftermath` is a compact non-battle event after `cinderfen_watch`, with three modest baseline once-only choices plus a tiny optional Malrec trophy reputation choice using existing resource, reward, reputation, modifier, save, and duplicate-prevention rules. It is the end of the current playable Cinderfen route.
- Implemented Cinderfen identity hook: the Cinder Shrine first-capture Aether surge exists as a small battle-local tactical feature.
- Baseline document: `docs/V03_CINDERFEN_ROUTE_BASELINE.md`.
- Slice report: `docs/CHAPTER_2_CINDERFEN_SLICE_REPORT.md`.
- Automated review: `docs/CINDERFEN_AUTOMATED_REVIEW.md`.
- Working proposal: The Cinderfen Road remains a small ash-glass wetland/causeway route that reuses the current campaign, rival, trophy, Stronghold, retinue, reputation, enemy hero, and affixed-loot systems.
- Default implementation stance: use existing Free Marches and Ashen Covenant content first; do not start a full new faction.
- Current slice result: `cinderfen_overlook`, `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath` are implemented. Cinderfen Causeway and Cinderfen Watchpost have map/objective/reward validation, Cinderfen appears in e2e coverage, both Cinderfen battles are included in the Chapter 2 simulator profile with one eligible Waystation Shrine Attunement service profile, and the aftermath is event-only. No new faction, worker, enemy construction, diplomacy, procedural generation, crafting, or broad army management has been added.

Completed Tutorial / Proving Grounds shell:

- [x] Main-menu Tutorial launch surface.
- [x] Validated playable tutorial metadata for `proving_grounds_basics`.
- [x] Existing-content tutorial launch on `first_claim` with transient Warlord Aster data.
- [x] Lightweight tutorial overlay and linear twelve-step objective model.
- [x] No-reward, non-persistent completion and exit back to main menu.
- [x] Smoke, layout, content-validation, unit, and save-persistence coverage.
- [x] Tutorial report: `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`.

Next phase:

- **Human-paced Tutorial / Proving Grounds review and small tutorial polish.**
- Best current work is copy clarity, overlay hierarchy, completion clarity, and real input feel. Do not add broad systems.
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
- Five authored battlefields now prove the map pipeline: First Claim, Broken Ford, Ashen Outpost, Chapter 2 Cinderfen Causeway, and Chapter 2 Cinderfen Watchpost.
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
- Chapter 2 has a compact playable Cinderfen slice: `cinderfen_overlook` is the implemented event gate after Ashen Outpost, `cinderfen_crossing` unlocks after that event to launch `Cinderfen Causeway`, `cinderfen_watch` unlocks after Cinderfen Crossing to launch `Cinderfen Watchpost`, and `cinderfen_aftermath` unlocks after Cinderfen Watch as a non-battle consequence node.
- `cinderfen_waystation` is the implemented Chapter 2 support/town node after Cinderfen Overlook. It spends campaign resources on modest Cinderfen-only preparation without adding a broad shop, new faction, workers, enemy construction, diplomacy, procedural generation, or crafting.
- Cinderfen Causeway uses the Cinder Shrine first-capture Aether surge as its compact battle-local tactical identity feature.
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
