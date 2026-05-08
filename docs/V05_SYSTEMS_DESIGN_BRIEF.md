# v0.5 Systems Design Brief

Date: 2026-05-08

Scope: planning only. This brief defines future-system design boundaries for Ascendant Realms. It does not implement any of these systems.

## Design Principles

- Grow from the frozen v0.3/v0.3.1 baseline instead of replacing it.
- Preserve save compatibility and route-complete behavior.
- Keep faction, lore, unit, spell, map, UI, and campaign expression original.
- Prefer pure-rule modules and content validation before player-facing UI.
- Add one vertical slice at a time, verify it, document it, then continue.
- Treat e2e release coverage and playtest simulator telemetry as gates, not optional polish.

## 1. Future Workers And Economy Model

Player value:

- Makes base-building feel alive, gives players a clearer reason to defend territory, and creates strategic pressure between expansion, army timing, and tech.

Risk:

- High. Workers affect resource pacing, selection rules, command UI, pathing, collision, enemy fairness, save fields, and battle duration.

Dependencies:

- Stable economy type definitions, building queues, resource sites, selection and command panels, save migration policy, and simulator profiles.

Required tests:

- Pure economy rules for gather/dropoff or resource-rate calculations.
- Save defaults and migration tests for any persistent worker/economy state.
- Battle smoke e2e confirming existing campaign launches are unchanged.
- Playtest simulator coverage for any battle where economy pacing changes.

Likely files touched:

- `src/game/types/EconomyTypes.ts`
- `src/game/systems/ResourceSystem.ts`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/SelectionSystem.ts`
- `src/game/ui/hudPanels/CommandPanel.ts`
- `src/game/save/*`
- `src/game/playtest/*`
- `tests/e2e/*`

Safe first vertical slice:

- A player-only economy rule prototype with one worker-like role in pure rules or a contained test map. It should not affect current campaign battles by default.

What not to do:

- Do not add enemy workers, full gather AI, multiple new resources, worker production queues, or new campaign dependencies in the first slice.

## 2. Future Enemy Construction Model

Player value:

- Makes opponents feel less static and creates the fantasy of a contested battlefield where pressure can return if ignored.

Risk:

- High. Enemy construction can create runaway matches, unclear objectives, fog surprises, pathing failures, and simulator drift.

Dependencies:

- Worker/economy model, enemy AI state machine, battle pacing data, map validation, building placement rules, and telemetry.

Required tests:

- AI construction decision tests.
- Building placement tests for enemy-owned structures.
- Battle runtime tests for objective completion with rebuilt structures.
- Release e2e for affected battles.
- Simulator profiles showing duration and win-rate impact.

Likely files touched:

- `src/game/ai/EnemyAIController.ts`
- `src/game/ai/AIStateMachine.ts`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/BuildingPlacementRules.ts`
- `src/game/battle/*`
- `src/game/data/maps.ts`
- `src/game/playtest/*`

Safe first vertical slice:

- One scripted rebuild or repair behavior in a contained scenario after player economy rules are proven stable.

What not to do:

- Do not let AI freely expand, rebuild every destroyed structure, train from new bases, or change current Cinderfen fights as the first implementation.

## 3. Future Faction Expansion Model

Player value:

- Adds replay identity, strategic variety, and long-term campaign fantasy through distinct economies, units, buildings, and story roles.

Risk:

- High. Factions touch originality, balance, data validation, assets, AI, UI, save compatibility, and campaign launch rules.

Dependencies:

- Original faction identity documents, unit/building schema validation, asset pipeline policy, battle pacing telemetry, and save-safe faction selection.

Required tests:

- Content validation for faction IDs, unit/building availability, requirements, and missing assets.
- Unit/building rule tests.
- Smoke e2e for selecting/launching a faction slice.
- Simulator profiles for faction-specific pacing.

Likely files touched:

- `src/game/data/factions.ts`
- `src/game/data/units.ts`
- `src/game/data/buildings.ts`
- `src/game/data/contentValidation.ts`
- `src/game/types/*`
- `src/game/entities/*`
- `src/game/systems/*`
- `src/game/scenes/HeroCreationScene.ts`
- `src/game/scenes/SkirmishSetupScene.ts`

Safe first vertical slice:

- A design-only faction identity and validation stub using original names, original themes, and existing role placeholders before adding bespoke mechanics.

What not to do:

- Do not copy external faction identities, add full rosters, introduce new art requirements, or combine faction expansion with workers and enemy construction in one pass.

## 4. Future Campaign Chapter Model

Player value:

- Gives Ascendant Realms a longer journey with regional arcs, route consequences, rival follow-through, and stronger campaign identity.

Risk:

- Medium-high. Chapter expansion can create missing-map launches, reward duplication, unclear locks, save migration drift, and layout density.

Dependencies:

- Campaign node rules, chapter panel UX, reward rules, route-complete wording, save normalization, and e2e helpers.

Required tests:

- Campaign node unlock tests.
- Chapter presentation tests.
- Duplicate reward tests.
- Smoke/deep e2e for chapter transitions.
- Layout e2e for new chapter panels.

Likely files touched:

- `src/game/data/campaignChapters.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/data/campaignRewards.ts`
- `src/game/core/campaign/*`
- `src/game/campaign/*`
- `src/game/scenes/CampaignMapScene.ts`
- `tests/e2e/chapter2-helpers.ts`

Safe first vertical slice:

- A locked chapter shell or roadmap-facing preview that cannot launch missing maps and clearly states that later nodes are upcoming.

What not to do:

- Do not add playable battle nodes without authored maps, rewards, simulator profiles, layout checks, and route-complete copy.

## 5. Future Diplomacy And Reputation Expansion

Player value:

- Makes choices feel political, persistent, and reactive beyond simple resource/reputation rewards.

Risk:

- Medium-high. Diplomacy can create hidden state, unclear irreversible outcomes, and branching test burden.

Dependencies:

- Existing reputation ranks, campaign modifiers, choice preview copy, save migration policy, and campaign map hierarchy.

Required tests:

- Reputation effect tests.
- Campaign choice requirement/result tests.
- Save migration and normalization tests.
- Smoke e2e for choice previews and post-choice state.

Likely files touched:

- `src/game/core/campaign/CampaignReputationRules.ts`
- `src/game/core/campaign/CampaignChoiceRules.ts`
- `src/game/data/campaignModifiers.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/campaign/*`
- `src/game/save/*`

Safe first vertical slice:

- Preview-only diplomacy consequences that reuse current reputation ranks and make future branching visible without adding new simulation.

What not to do:

- Do not add alliance simulation, global war turns, hidden timers, or broad faction diplomacy before state visibility and migrations are proven.

## 6. Future Procedural And Skirmish Map Ideas

Player value:

- Adds replayability, experiment space, and future skirmish depth beyond authored campaign routes.

Risk:

- High. Generated maps can break pathfinding, resource fairness, fog readability, objective placement, minimap clarity, and determinism.

Dependencies:

- Seeded RNG policy, map schema validation, pathfinding validation, start/resource placement constraints, and skirmish setup UX.

Required tests:

- Seed determinism tests.
- Generated map validation tests.
- Pathfinder reachability tests.
- Smoke e2e on one known seed after playable generation exists.
- Simulator coverage for generated battle pacing.

Likely files touched:

- `src/game/data/maps.ts`
- `src/game/types/MapTypes.ts`
- `src/game/pathfinding/*`
- `src/game/battle/BattleSceneMapRenderer.ts`
- `src/game/scenes/SkirmishSetupScene.ts`
- Future `src/game/mapgen/*`

Safe first vertical slice:

- A deterministic seed preview and validation harness that can report whether a generated layout is legal, without launching generated battles yet.

What not to do:

- Do not ship random maps before validating starts, resource access, objective reachability, enemy placement, fog reveal, and minimap readability.

## 7. Future Crafting And Affix Rerolling Ideas

Player value:

- Gives players more agency over hero builds and lets loot become a long-term planning layer.

Risk:

- Medium-high. Crafting can undermine reward pacing, item identity, duplicate-prevention rules, campaign resources, and save compatibility.

Dependencies:

- Affix rules, item reward rules, inventory UI, campaign resource economy, save migrations, and duplicate reward behavior.

Required tests:

- Affix generation and reroll tests.
- Duplicate reward and item identity tests.
- Save migration tests.
- Inventory smoke e2e.
- Simulator checks only if battle rewards or pacing change.

Likely files touched:

- `src/game/core/progression/AffixRules.ts`
- `src/game/core/progression/ItemRewardRules.ts`
- `src/game/core/progression/DuplicateRewardRules.ts`
- `src/game/progression/*`
- `src/game/data/itemAffixes.ts`
- `src/game/save/*`

Safe first vertical slice:

- A pure-rule reroll preview that takes an item instance and returns a possible result without mutating inventory or consuming resources.

What not to do:

- Do not add destructive crafting, durability, paid rerolls, broad currencies, or full crafting UI before the rule tests and save model are ready.

## 8. Future Multiplayer Feasibility

Player value:

- Creates a long-term path for co-op or competitive play if the simulation becomes deterministic enough.

Risk:

- Very high. Multiplayer changes simulation determinism, input handling, networking, replayability, debugging, UI, and deployment.

Dependencies:

- Deterministic command model, battle-state serialization, input command log, stable simulation ticks, and clear server/no-server decision.

Required tests:

- Determinism tests from repeated command logs.
- Command serialization tests.
- Latency or delayed-command simulation.
- No external dependency or paid API requirement without explicit approval.

Likely files touched:

- Future `src/game/net/*`
- `src/game/battle/*`
- `src/game/systems/InputSystem.ts`
- `src/game/systems/*`
- `src/game/save/*`

Safe first vertical slice:

- A feasibility document plus an offline command-log experiment that proves whether one battle can replay deterministically from recorded commands.

What not to do:

- Do not add live networking, lobby UI, matchmaking, external servers, paid services, or multiplayer save coupling as an early step.

## 9. Future Asset Pipeline

Player value:

- Supports larger content drops with consistent visual language, smaller production deploys, and fewer missing-asset errors.

Risk:

- Medium. Pipeline changes can break manifests, load paths, production builds, and visual consistency.

Dependencies:

- Asset manifest builder, production asset policy, style bible, tiny placeholder rules, and preview smoke.

Required tests:

- Asset manifest validation.
- Production build.
- Production preview smoke.
- File-size audit for shipped assets.

Likely files touched:

- `tools/manual-asset-pipeline/*`
- `src/game/assets/AssetLoader.ts`
- `src/game/assets/AssetKeys.ts`
- `public/assets/*`
- `docs/*`

Safe first vertical slice:

- Audit which final assets versus manual/reference assets ship in production and document a small-placeholder policy.

What not to do:

- Do not add large generated assets, external runtime asset dependencies, or broad art replacement without a production shipping policy.

## 10. Future AI Personality Expansion

Player value:

- Makes battles more memorable by giving enemies distinct pressure patterns, risk tolerance, and tactical flavor.

Risk:

- Medium-high. AI behavior affects fairness, battle duration, objective clarity, and simulator outcomes.

Dependencies:

- Current AI personality data, enemy AI controller, battle pacing profiles, telemetry fields, and map constraints.

Required tests:

- AI personality data tests.
- Enemy AI controller tests.
- Simulator profiles for affected personalities.
- Smoke or deep e2e for any player-visible encounter changes.

Likely files touched:

- `src/game/data/aiPersonalities.ts`
- `src/game/ai/EnemyAIController.ts`
- `src/game/ai/AIStateMachine.ts`
- `src/game/data/battlePacing.ts`
- `src/game/playtest/*`

Safe first vertical slice:

- Telemetry-only personality labels and design notes before new tactical orders. This lets reports classify future behavior without changing battles.

What not to do:

- Do not add scouting, counter-build logic, retreat logic, or hero build logic until economy and enemy construction gates exist.

## 11. Future Save Migration Risks

Player value:

- Lets the game grow while preserving existing heroes, campaign progress, items, retinue, reputation, rivals, trophies, and route completion.

Risk:

- Very high. Save corruption is one of the clearest ways to damage trust in the prototype.

Dependencies:

- Versioned save schema, defaults, normalization, migration tests, import/export behavior, and backward-compatible IDs.

Required tests:

- Migration tests from old saves to current saves.
- No-op migration tests for current saves.
- Mock future-field migration tests.
- Import/export tests.
- Campaign flow e2e after any persistent field is added.

Likely files touched:

- `src/game/save/SaveTypes.ts`
- `src/game/save/SaveMigrations.ts`
- `src/game/save/SaveDefaults.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/save/SaveImportExport.ts`
- `src/game/core/SaveSystem.ts`

Safe first vertical slice:

- Add tests that prove current saves migrate without mutation except expected defaults, then add one mock optional future field to validate the path.

What not to do:

- Do not rename existing IDs, change reward IDs, delete fields, require save resets, or mutate old saves without explicit migration tests.

## 12. Future Performance Risks

Player value:

- Keeps load times, responsiveness, deploy size, and browser stability healthy as content grows.

Risk:

- Medium-high. Performance changes can break boot, scene transitions, asset paths, production builds, and test hooks.

Dependencies:

- Bundle analyzer, production preview smoke, e2e lanes, asset audit, content loading policy, and chunk warning policy.

Required tests:

- `npm run build:analyze` for measurement changes.
- `npm run build`.
- `npm run test:e2e:smoke`.
- `npm run test:e2e:release` for scene/data/asset loading changes.
- Production preview smoke.
- `npm run playtest:sim` if runtime behavior can change.

Likely files touched:

- `vite.config.ts`
- `src/game/config.ts`
- `src/game/scenes/*`
- `src/game/data/contentIndex.ts`
- `src/game/assets/*`
- `docs/BUNDLE_ANALYSIS_REPORT.md`
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`

Safe first vertical slice:

- Continue one analyzer-backed optimization at a time, recording before/after app chunk size, vendor chunk size, CSS size, gzip sizes, and warning status.

What not to do:

- Do not hide warnings by policy before measuring, lazy-load BattleScene or CampaignMapScene casually, or combine scene loading, data loading, and asset pruning in one pass.

## Recommended v0.5 Gate

Before implementing any broad system, v0.5 should deliver:

- Save migration tests and policy.
- Future content validation plan for workers, factions, maps, and chapters.
- One deterministic command-log feasibility note for future AI/multiplayer work.
- Updated release checklist language for simulator coverage when battle pacing changes.
- A single approved vertical-slice candidate, preferably workers/economy only after the save/content gates are green.

## 2026-05-08 Full-System Planning Matrix

This matrix is the authoritative planning checklist for the next full-game architecture pass. It does not authorize implementation. It records the fifteen future system families requested for the v0.4 overnight goal, including the safe order in which they should be considered.

### 1. Save Migration And Content Validation Gate

Player value: protects existing heroes, route completion, inventory, retinue, rivals, trophies, settings, and campaign resources before new systems add persistent state.

Risk: very high because corrupted or silently dropped save data would undermine all future expansion.

Dependencies: current V2 save audit, content validators, import/export behavior, old-save fixtures, and release checklist rules.

Required tests: old-save fixture migrations, no-op current-save migrations, invalid import preservation, content validation for future node/faction/map IDs, and smoke e2e after persistent fields are added.

Likely files touched: `src/game/save/*`, `src/game/data/validation/*`, `src/game/data/contentValidation.ts`, `src/game/core/SaveSystem.ts`, `tests/e2e/*`.

Safe first vertical slice: add fixture-based migration tests and future content-validation planning without changing the save version.

What not to do: do not bump save version, rename IDs, delete fields, or require a save reset without a real migration need.

Recommended order: first. This gate should precede workers, enemy construction, factions, new chapters, modding, or crafting.

### 2. Workers And Economy Model

Player value: makes bases feel alive and adds strategic tension between expansion, defense, tech, and army timing.

Risk: high because workers touch resource pacing, pathing, selection, command UI, battle duration, save state, and simulator profiles.

Dependencies: save/content gate, economy type definitions, resource-site rules, building queues, command panel affordances, and playtest profiles.

Required tests: pure economy rules, resource-site behavior, worker command tests, save normalization only if persistent, smoke e2e, and simulator coverage for affected maps.

Likely files touched: `src/game/types/EconomyTypes.ts`, `src/game/systems/ResourceSystem.ts`, `src/game/systems/BuildingSystem.ts`, `src/game/systems/SelectionSystem.ts`, `src/game/ui/hudPanels/CommandPanel.ts`, `src/game/save/*`, `src/game/playtest/*`.

Safe first vertical slice: one player-only worker-like rule prototype in pure rules or an isolated test map, disabled for current campaign battles by default.

What not to do: do not add enemy workers, freeform gather AI, new resources, worker production chains, or current-route dependencies in the first slice.

Recommended order: second, after save/content validation and before enemy construction.

### 3. Enemy Construction Model

Player value: makes enemy camps feel reactive, contested, and less static.

Risk: high because rebuilding and expansion can destabilize objectives, fog readability, pathfinding, match length, and fairness.

Dependencies: player economy model, enemy AI state machine, building placement rules, map validation, telemetry, and pacing budgets.

Required tests: enemy construction decision tests, enemy-owned placement tests, BattleRuntime objective tests, release e2e for affected battles, and simulator win-rate/duration profiles.

Likely files touched: `src/game/ai/*`, `src/game/systems/BuildingSystem.ts`, `src/game/systems/BuildingPlacementRules.ts`, `src/game/battle/*`, `src/game/data/maps.ts`, `src/game/playtest/*`.

Safe first vertical slice: one scripted repair or rebuild behavior in a contained test scenario after player economy rules are stable.

What not to do: do not let AI freely expand, rebuild every destroyed structure, add enemy workers first, or alter Cinderfen route fights as the first implementation.

Recommended order: third, after workers/economy and before broad faction asymmetry.

### 4. Faction Expansion Model

Player value: adds replay identity, fantasy depth, different strategic rhythms, and long-term campaign variety.

Risk: high because factions affect originality, balance, assets, validation, AI, UI, save state, and launch rules.

Dependencies: original faction design documents, unit/building schemas, asset policy, battle pacing telemetry, and save-safe faction selection.

Required tests: content validation for faction/unit/building IDs, availability/requirement tests, smoke e2e for selecting and launching a faction slice, and simulator profiles.

Likely files touched: `src/game/data/factions.ts`, `src/game/data/units.ts`, `src/game/data/buildings.ts`, `src/game/data/validation/*`, `src/game/types/*`, `src/game/entities/*`, `src/game/systems/*`, `src/game/scenes/HeroCreationScene.ts`, `src/game/scenes/SkirmishSetupScene.ts`.

Safe first vertical slice: one design-only original faction identity plus validation stubs using placeholder role parity before adding bespoke mechanics.

What not to do: do not copy external factions, add full rosters, require large asset drops, or combine faction rollout with workers and enemy construction in one pass.

Recommended order: fourth, after economy/enemy-construction assumptions are stable.

### 5. Campaign Chapter Expansion Model

Player value: turns the prototype into a longer journey with regional arcs, route consequences, and rival follow-through.

Risk: medium-high because chapters can create missing launches, duplicate rewards, unclear locks, save drift, and campaign-map density.

Dependencies: campaign node rules, chapter panel view models, reward rules, route-complete copy, save normalization, and e2e helpers.

Required tests: chapter unlock rules, presentation/view-model tests, duplicate-prevention tests, smoke/deep e2e for transitions, layout e2e for chapter density, and simulator coverage for new battle nodes.

Likely files touched: `src/game/data/campaignChapters.ts`, `src/game/data/campaignNodes.ts`, `src/game/data/campaignRewards.ts`, `src/game/core/campaign/*`, `src/game/campaign/*`, `src/game/scenes/CampaignMapScene.ts`, `tests/e2e/*`.

Safe first vertical slice: locked chapter shell with clear upcoming copy and no missing playable launches.

What not to do: do not add playable battle nodes without authored maps, rewards, route copy, validation, simulator coverage, and e2e checks.

Recommended order: fifth, after faction/economy assumptions and before diplomacy broadening.

### 6. Diplomacy And Reputation Expansion

Player value: makes choices feel political and gives factions, towns, and rivals persistent meaning.

Risk: medium-high because hidden branching state can become opaque and hard to migrate.

Dependencies: current reputation hooks, campaign choice previews, save migration policy, faction identity plan, and campaign-map hierarchy.

Required tests: reputation rules, choice requirement/result tests, save migration/normalization, smoke e2e for choice previews, and layout checks for dense panels.

Likely files touched: `src/game/core/campaign/CampaignReputationRules.ts`, `src/game/core/campaign/CampaignChoiceRules.ts`, `src/game/data/campaignModifiers.ts`, `src/game/data/campaignNodes.ts`, `src/game/campaign/*`, `src/game/save/*`.

Safe first vertical slice: preview-only diplomacy consequence copy using existing reputation ranks, with no new simulation.

What not to do: do not add alliance simulation, global war turns, hidden timers, or irreversible diplomacy branches before state visibility is proven.

Recommended order: sixth, after campaign chapter shape and faction identity are clearer.

### 7. Tutorial And Onboarding Path

Player value: helps players understand hero creation, base setup, capture sites, first army timing, Results, campaign progression, settings, and Cinderfen route boundaries.

Risk: medium because onboarding can add brittle state, intrusive UI, and e2e overhead if it becomes a parallel campaign.

Dependencies: existing first-experience guidance, settings/readability work, route-complete copy, input clarity, and smoke e2e flows.

Required tests: guidance rule tests, smoke e2e for first-run prompts, layout e2e for help surfaces, and save tests if dismissal state persists.

Likely files touched: `src/game/core/FirstExperienceGuidance.ts`, `src/game/scenes/MainMenuScene.ts`, `src/game/scenes/CampaignMapScene.ts`, `src/game/ui/*`, `src/game/save/*`, `tests/e2e/*`.

Safe first vertical slice: improve existing guidance/help copy or add a non-blocking reference panel without new campaign nodes.

What not to do: do not add a separate tutorial campaign, new maps, mandatory pop-up chains, or hidden save state before the guidance model is tested.

Recommended order: seventh, after route/readability evidence is stable and before procedural or multiplayer experiments.

### 8. Crafting And Affix Rerolling Ideas

Player value: gives hero builds more agency and lets loot become a longer-term planning layer.

Risk: medium-high because item identity, duplicate prevention, economy balance, and save compatibility can break quickly.

Dependencies: affix rules, item reward rules, inventory UI, campaign resources, save migration policy, and duplicate-prevention tests.

Required tests: pure reroll rules, affix constraints, duplicate reward tests, item-instance save tests, inventory smoke e2e, and simulator checks only if rewards/pacing change.

Likely files touched: `src/game/core/progression/AffixRules.ts`, `src/game/core/progression/ItemRewardRules.ts`, `src/game/core/progression/DuplicateRewardRules.ts`, `src/game/progression/*`, `src/game/data/itemAffixes.ts`, `src/game/save/*`.

Safe first vertical slice: pure-rule reroll preview that returns a possible result without mutating inventory or consuming resources.

What not to do: do not add destructive crafting, durability, paid rerolls, broad currencies, or full crafting UI first.

Recommended order: eighth, after save migration fixtures and before any broad loot-economy work.

### 9. Asset Pipeline

Player value: lets content scale with consistent visuals, small production deploys, and fewer missing-asset surprises.

Risk: medium because path, manifest, size, and visual consistency mistakes can break production builds.

Dependencies: asset manifest policy, production preview smoke, style direction, placeholder rules, and file-size audit.

Required tests: asset manifest validation, production build, production preview smoke, file-size audit, and targeted browser checks for new asset surfaces.

Likely files touched: `tools/manual-asset-pipeline/*`, `src/game/assets/*`, `public/assets/*`, `docs/*`.

Safe first vertical slice: audit production-shipped assets and define final/manual/reference asset separation plus tiny-placeholder policy.

What not to do: do not add large generated assets, external runtime asset dependencies, or broad art replacement before a shipping policy exists.

Recommended order: ninth, before large faction/chapter content drops and before any procedural art needs.

### 10. Performance Risks

Player value: keeps load, boot, browser responsiveness, and release confidence healthy as content grows.

Risk: medium-high because loading/chunk changes can break boot, scene transitions, hooks, and production assets.

Dependencies: bundle analyzer, e2e lanes, production preview smoke, asset audit, and warning policy.

Required tests: `npm run build:analyze`, `npm run build`, smoke e2e, release e2e for scene/data/asset loading changes, simulator if runtime behavior can change, and preview smoke.

Likely files touched: `vite.config.ts`, `src/game/config.ts`, `src/game/scenes/*`, `src/game/data/contentIndex.ts`, `src/game/assets/*`, `docs/BUNDLE_ANALYSIS_REPORT.md`, `docs/PERFORMANCE_BUNDLE_AUDIT.md`.

Safe first vertical slice: one analyzer-backed optimization with before/after chunk, gzip, CSS, and warning status.

What not to do: do not hide warnings, lazy-load BattleScene/CampaignMapScene casually, or combine multiple optimizations in one pass.

Recommended order: tenth, repeated as needed after each content expansion rather than treated as a one-time phase.

### 11. AI Personality Expansion

Player value: makes opponents feel more memorable through distinct pressure patterns and tactical flavor.

Risk: medium-high because AI changes can alter fairness, duration, objective clarity, and telemetry.

Dependencies: current AI personality data, EnemyAIController, battle pacing profiles, telemetry fields, and map constraints.

Required tests: AI personality data tests, controller tests, simulator profiles, and smoke/deep e2e for visible encounter changes.

Likely files touched: `src/game/data/aiPersonalities.ts`, `src/game/ai/*`, `src/game/data/battlePacing.ts`, `src/game/playtest/*`.

Safe first vertical slice: telemetry-only personality labels and design notes before new tactical orders.

What not to do: do not add scouting, counter-builds, retreat logic, or hero build logic before economy and enemy construction gates exist.

Recommended order: eleventh, after economy/enemy construction telemetry exists.

### 12. Procedural And Skirmish Map Ideas

Player value: adds replayability and a sandbox for varied skirmish sessions.

Risk: high because generated maps can break pathfinding, fairness, fog, objectives, minimap readability, and determinism.

Dependencies: seeded RNG policy, map schema validation, pathfinding reachability checks, start/resource placement constraints, and skirmish setup UX.

Required tests: seed determinism, generated map validation, pathfinder reachability, smoke e2e for one known seed after playable generation exists, and simulator pacing coverage.

Likely files touched: `src/game/data/maps.ts`, `src/game/types/MapTypes.ts`, `src/game/pathfinding/*`, `src/game/battle/BattleSceneMapRenderer.ts`, `src/game/scenes/SkirmishSetupScene.ts`, future `src/game/mapgen/*`.

Safe first vertical slice: deterministic seed preview and validator that reports whether a layout is legal without launching it.

What not to do: do not ship random maps before starts, resources, objectives, enemy placement, fog reveal, and minimap readability can be validated.

Recommended order: twelfth, after authored map/content validation is stricter.

### 13. Modding And Data-Driven Content Possibility

Player value: gives long-term community extension paths and keeps internal content easier to validate.

Risk: high because untrusted data can break saves, validation, balance, asset loading, and security assumptions.

Dependencies: strict content schemas, import trust boundary, asset policy, save migration rules, ID namespace policy, and deterministic validation.

Required tests: schema validation for every public data file, invalid mod rejection tests, duplicate-ID tests, asset path allowlist tests, and save/import safety tests.

Likely files touched: `src/game/data/validation/*`, `src/game/data/contentIndex.ts`, `src/game/types/*`, `src/game/save/*`, future `src/game/modding/*`, `docs/*`.

Safe first vertical slice: internal data-driven schema hardening with no user-imported mods and no runtime code execution.

What not to do: do not execute imported scripts, load arbitrary remote assets, allow mods to mutate saves directly, or promise public mod support before schemas are stable.

Recommended order: thirteenth, after validation gates and before public content tools.

### 14. Monetization And Packaging Possibilities

Player value: defines a fair, non-disruptive path for eventually shipping the game without harming trust or design clarity.

Risk: medium-high because monetization can distort balance, content scope, save formats, and user expectations.

Dependencies: product positioning, offline packaging plan, save/export trust, asset licensing policy, platform requirements, and legal originality review.

Required tests: build/package smoke, save import/export tests, offline boot test if packaged, entitlement-free default behavior tests if any unlock flags are ever added, and release checklist review.

Likely files touched: `package.json`, `vite.config.ts`, `src/game/scenes/MainMenuScene.ts`, `src/game/save/*`, release docs, future packaging scripts.

Safe first vertical slice: documentation-only packaging options such as free prototype, paid full release, demo branch, or DLC-like future chapters, with no code unlocks.

What not to do: do not add microtransactions, paid APIs, online entitlement checks, pay-to-win progression, or monetization-gated balance systems.

Recommended order: fourteenth, after the game has stronger single-player identity and before public release planning.

### 15. Multiplayer Feasibility

Player value: creates a distant path for co-op or competitive play if the single-player simulation can support it.

Risk: very high because multiplayer changes determinism, input, networking, debugging, deployment, fairness, and UX.

Dependencies: deterministic command model, battle-state serialization, stable simulation tick, command log replay, server/no-server decision, and packaging policy.

Required tests: deterministic replay from command logs, command serialization tests, delayed-command simulation, state checksum checks, and no external service requirement without explicit approval.

Likely files touched: future `src/game/net/*`, `src/game/battle/*`, `src/game/systems/InputSystem.ts`, `src/game/systems/*`, `src/game/save/*`, docs.

Safe first vertical slice: feasibility document plus an offline command-log experiment outside the player runtime.

What not to do: do not add live networking, lobby UI, matchmaking, external servers, paid services, or multiplayer save coupling early.

Recommended order: last. Multiplayer should wait until single-player systems, determinism, packaging, and performance are all much stronger.

## Phase 9 Verification

This planning-only update changed documentation only.

```text
npm test
PASS: 38 test files, 271 tests, 7.16s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-90WGArXv.js, 436.35 kB / gzip 117.34 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.
```
