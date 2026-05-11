# Content Guide

Most prototype content lives in `src/game/data`. Change one small thing at a time, run the game, and keep a backup before large balance edits.

## Validation Gates

Run this after any data edit before launching broad e2e or simulator checks:

```bash
npm run validate:content
npm run validate:art-intake
```

It runs the same content validator used by the pure test suite without opening the game UI. It should fail with direct messages for duplicate IDs, missing references, unsafe campaign graph links, invalid reward references, broken map objective references, invalid enemy pressure plan references, and Cinderfen-specific modifier leakage.

`npm run validate:art-intake` is only for non-runtime Cinderfen style-frame candidate metadata under `art-review/cinderfen-style-frames/metadata/`. It checks source/license fields, approval gates, protected-IP risk, related spec references, and submitted-file references without approving runtime use or requiring candidate image files for an empty intake.

Follow it with `npm test` for save fixture coverage, pure rules, view models, and simulator unit coverage. Use e2e and `npm run playtest:sim` when the edited content can affect campaign flow, battle launch, rewards, rival state, or route balance.

## Edit Visual Asset Metadata

Visual asset metadata lives in `src/game/assets/visualAssetManifest.ts`, with types in `src/game/assets/VisualAssetManifestTypes.ts` and validation in `src/game/data/validation/validateVisualAssets.ts`.

1. Add or edit manifest entries before treating any visual asset as part of the reviewed set.
2. Keep `id` unique and stable. Runtime ids should match current `AssetKeys.ts` references when applicable.
3. Use honest `currentStatus` values: most current assets are `placeholder`, `prototype`, `candidate`, or `reference`, not `final`.
4. Use honest `sourceType`, `licenseStatus`, and `reviewStatus`. If source/license proof is unclear, keep `licenseStatus: "unknown"`, `reviewStatus: "needs-source-proof"`, `needsReview: true`, and `allowedInProduction: false`.
5. Runtime assets must not use `reference-only` or `do-not-ship` license statuses.
6. Runtime assets must not use `reviewStatus: "reference-only"` or `reviewStatus: "do-not-ship"`.
7. Runtime assets with unknown license must set `needsReview: true`.
8. Final assets cannot have unknown source or unknown license, and must set `allowedInProduction: true`.
9. `allowedInProduction: true` requires `licenseStatus: "owned"` or `licenseStatus: "licensed"` and a known non-reference source.
10. Runtime entries need non-empty `usedBy` so future reviewers understand why the asset ships.
11. Keep `intendedWorldHeightPx` and `currentRenderHeightPx` positive when present.
12. Use `sourceReviewNotes` for explicit evidence or gaps such as "No explicit author/source/license proof is attached."
13. Use `replacementPriority` to guide backlog work, not to imply approval to replace assets; critical replacements need clear notes.
14. Do not add generated art, downloaded images, large binaries, or production claims without explicit approval and source/license metadata.
15. Run `npm run validate:content` after edits; the CLI checks metadata and runtime visual file paths without bundling filesystem checks into browser boot.

Optional screenshot QA for visual changes:

```bash
npm run visual:qa
```

The output under `visual-qa/latest/` is ignored by git and is for human review only. Do not make pixel-perfect screenshot assertions in this workflow.

Current visual QA captures 18 indexed screenshots covering main menu, Asset Gallery, Hero Inventory, Tutorial desktop/mobile, campaign map, route-complete campaign map, Skirmish Setup, Cinderfen Crossing desktop/tablet, Cinder Shrine, Crossing pressure warning, Cinderfen Watch, Watch pressure warning, and victory/defeat Results views. Use `visual-qa/latest/index.md` as the source of truth because the ignored folder can contain older manual artifacts. The v0.10 tutorial visual review lives in `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`.

Source/license review docs:

- `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`
- `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`
- `docs/VISUAL_RISK_REGISTER.md`

Do not mark unknown-source assets production-safe. Do not treat the `public/assets/final/` folder name as legal proof.

v0.9 Cinderfen style-frame docs for future visual work:

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

Use these as future planning inputs only. They do not authorize generated art, downloaded images, runtime asset replacement, production approval, or manifest runtime entries. A future Cinderfen asset must start outside runtime, record source/license metadata, enter the manifest as reference/candidate first, pass `npm run validate:content`, and receive human screenshot QA before any integration.

v0.9.1 adds a separate non-runtime intake lane for future style-frame candidates: `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`, `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md`, `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`, `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`, `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`, `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`, `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`, and `art-review/cinderfen-style-frames/`. Fill candidate metadata before committing review materials, keep unknown-source or high-IP-risk candidates out of approval states, and run `npm run validate:art-intake` after metadata edits. This still does not authorize generated art, downloaded images, runtime replacement, or production approval.

## Edit Tutorial Metadata

Tutorial metadata lives in `src/game/data/tutorials.ts`, with types in `src/game/types/TutorialTypes.ts` and validation in `src/game/data/validation/validateTutorials.ts`.

1. Keep `proving_grounds_basics` non-rewarding. Its `noReward` field must stay `true`.
2. Use `status: "planned"` for rough future notes, `status: "scaffolded"` for validated metadata that still has no launch path, and `status: "playable"` only after a safe runtime shell exists.
3. Use `launchMode: "battle"` only when the tutorial will reuse the current battle scene systems.
4. If a tutorial is playable, give it a valid `mapId`. The first shell should reuse `first_claim`.
5. Keep steps short and linear. Current supported step types are `info`, `selectHero`, `moveHero`, `captureSite`, `gatherResources`, `selectBuilding`, `buildStructure`, `trainUnit`, `setRally`, `useHeroAbility`, `defeatEnemy`, and `finish`.
6. Every step needs a concise `title`, `description`, `instruction`, `objectiveType`, and `requiredAction`.
7. Use `hint` for optional help, not for mandatory long-form tutorial text.
8. Put referenced maps, units, buildings, abilities, resources, and capture sites in `references` so validation catches typos before the game launches.
9. Do not expose a tutorial launch path unless `npm run validate:content` passes with a valid playable tutorial, valid map reference, and at least one step.
10. Do not add a playable tutorial without steps, set `noReward` false for the first shell, or point a step at missing map/unit/building/ability/resource/capture-site IDs.
11. Do not use tutorial metadata to add maps, units, factions, rewards, campaign node completion, save fields, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, desktop packaging, or external assets.
12. Run `npm run validate:content` and `npm test` after edits.

v0.10 Tutorial v2 onboarding docs for future tutorial work:

- `docs/V10_TUTORIAL_V2_AUDIT.md`
- `docs/V10_TUTORIAL_V2_PACING_PLAN.md`
- `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`
- `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`
- `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`
- `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`

Use these before changing tutorial copy or layout. v0.10 keeps the twelve-step shell, no-reward policy, no-save policy, existing map/content reuse, and smoke coverage. Future changes should stay evidence-driven, preferably from Emmanuel's manual checklist, and should not add persistence, campaign rewards, map changes, new content, or broad UI redesign.

## Add A New Unit

1. Open `src/game/data/units.ts`.
2. Copy an existing unit entry.
3. Give it a unique `id`.
4. Edit name, cost, HP, damage, range, speed, armor, train time, color, and XP value.
5. To train it from a building, add the unit `id` to that building's `trainOptions` in `src/game/data/buildings.ts`.
6. Add `prerequisites` if it should require a completed building or researched upgrade.
7. Run `npm run validate:content` and `npm run test` to make sure the new ID is valid everywhere.

## Tune Unit Veterancy

1. Open `src/game/data/unitVeterancy.ts`.
2. Tune only one axis at a time: rank thresholds, XP source rules, or rank stat bonuses.
3. Keep ranks to the current V1 set unless you are also updating UI and Results copy: Recruit, Seasoned, Veteran, and Elite.
4. Keep bonuses modest. V1 rank bonuses are percentages to max HP and damage, plus a small armor bonus only at Elite.
5. Keep automatic persistence out of this file. Retinue Camp saves only selected campaign veterans through `src/game/core/RetinueRules.ts`.
6. If you add a new XP source, wire it through battle systems and add pure tests before using it in e2e.
7. Update `src/game/data/unitVeterancy.test.ts`, battle Results coverage, and Playwright coverage when rank behavior changes.
8. Run `npm test` and an e2e battle HUD/Results flow before relying on the new tuning.

Current V1 behavior:

- Damage dealt grants 1 XP per 4 actual damage, minimum 1 for positive damage.
- Kills grant the defeated target's existing XP value.
- Surviving a victory grants 12 XP.
- Rank bonuses apply immediately to player non-hero units.
- Selected-unit UI shows rank, unit XP, and kills.
- Results show Notable Veterans, and campaign victories can add eligible Seasoned+ survivors to the Retinue Camp.

## Tune Retinue Camp

1. Open `src/game/core/RetinueRules.ts` for capacity, eligibility, add/dismiss, deployment, and death-removal behavior.
2. Keep base capacity small. Current capacity is 2 active units, with +1 from Training Yard II.
3. Keep eligibility narrow: player-owned surviving units, not heroes, not buildings, preferably Seasoned or better.
4. Retinue save shape lives in `src/game/save/SaveTypes.ts`; normalize old or malformed saves in `src/game/save/SaveNormalization.ts`.
5. Results recruitment UI lives in `src/game/results/ResultsRetinuePanel.ts`; Campaign Map display lives in `src/game/campaign/RetinuePanel.ts`.
6. Campaign battle deployment passes through `BattleLaunchRequest` and `BattleSceneSpawner`; skirmish should stay retinue-free unless a future task explicitly changes it.
7. Current death rule is permanent removal after a battle when a retinue unit dies. Do not add wounded recovery until there is a concrete UI/test plan.
8. Update `src/game/core/RetinueRules.test.ts`, save tests, launch tests, Playwright retinue deployment coverage, and simulator profiles if retinue rules change.

## Add Or Tune An Enemy Hero

1. Open `src/game/data/enemyHeroes.ts`.
2. Add or edit a compact `EnemyHeroDefinition`: `id`, `name`, `title`, `factionId`, `personalityId`, `archetype`, `level`, `unitId`, `stats`, `xpValue`, `abilities`, flavor text, and campaign/map assignments.
3. Keep `unitId` as `enemy_commander` for V1 unless you are intentionally adding a new enemy unit and updating validation, objectives, AI phase data, and tests.
4. Add ability data in the same file only from the supported V1 effect shapes: `damage-and-burn`, `damage-buff`, `direct-damage`, and `armor-aura`.
5. Assign the hero to a battle node with `enemyHeroId` in the relevant focused campaign node module, such as `src/game/data/borderMarchesNodes.ts` or `src/game/data/cinderfenRoadNodes.ts`.
6. Make sure the assigned map spawns `enemy_commander` for that difficulty, or the named hero will have no live commander slot to replace.
7. If the hero should count for a secondary objective, point the map objective at `enemy_commander` and use node/map copy for the named commander.
8. Update `src/game/data/contentValidation.test.ts`, `BattleLaunchRequest` tests, Playwright commander coverage, and playtest simulator telemetry expectations.
9. Run `npm run validate:content`, `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, and `npm run playtest:sim`.

Current Enemy Hero V1 assignments:

- `gorak_emberhand`: Gorak Emberhand, Ashen Raider Captain, assigned to Bandit Hillfort.
- `veyra_cinders`: Veyra of the Cinders, Hexfire Seer, assigned to Aether Well Ruins.
- `captain_malrec`: Captain Malrec, Outpost Commander, assigned to Ashen Outpost and the `Defeat Captain Malrec` objective.

## Add Or Tune Enemy Strategic Pressure Plans

Enemy Strategic Pressure V1 metadata lives in `src/game/data/enemyPressurePlans.ts`, with types in `src/game/types/EnemyPressureTypes.ts` and validation in `src/game/data/validation/validateEnemyPressurePlans.ts`.

1. Keep V1 scoped to existing campaign battle nodes and maps. Current initial plans are `ashen_watch_captain_pressure` for `cinderfen_watch` and `causeway_contest_pressure` for `cinderfen_crossing`.
2. Use existing map IDs in `allowedMapIds` and existing campaign node IDs in `allowedNodeIds`.
3. Keep `scope: "campaign_node"` for active candidates or `scope: "disabled"` for parked metadata.
4. Use existing AI personality IDs in `personalityTags`.
5. Use only the V1 trigger types: `battle_start_time`, `player_captures_site`, `player_destroys_structure`, `player_trains_first_army_unit`, `enemy_hero_damaged`, `enemy_hero_defeated`, and `late_battle_time`.
6. Use only the V1 action types: `show_warning`, `mark_telemetry`, `adjust_next_wave_timing`, `reinforce_next_wave`, `defensive_hold`, and `contest_capture_site`.
7. If a trigger, condition, or action references a capture site, it must exist on one of the plan's allowed maps.
8. If an action references units, they must be existing unit IDs.
9. Keep warning copy short and tactical. Prefer clear messages like `The Watch Captain tightens the road guard. Keep income protected.`
10. Do not add fields for workers, harvesting, construction, placement, or economy. Validation rejects pressure metadata with forbidden worker/construction/economy-style field names.
11. Do not use pressure metadata to add maps, units, factions, rewards, save fields, campaign progression, workers, enemy construction, diplomacy, crafting, procedural generation, multiplayer, desktop packaging, or external assets.
12. Run `npm run validate:content`, `npm test`, and `npm run build` after edits. If a plan is attached to a live campaign node or its timing changes, also run `npm run test:e2e:smoke`, `npm run playtest:sim`, and the focused pressure lane: `npx playwright test tests/e2e/enemy-pressure.spec.ts --reporter=line`.

Current V1 status:

- `causeway_contest_pressure` is attached only to `cinderfen_crossing` on `cinderfen_causeway`.
- `ashen_watch_captain_pressure` is attached only to `cinderfen_watch` on `cinderfen_watchpost`.
- Tutorial and skirmish launches must stay pressure-free unless a future task explicitly scopes otherwise.
- `reinforce_next_wave`, `defensive_hold`, and `contest_capture_site` are currently warning/telemetry-only. Do not promote them into real combat effects without a human playtest finding and a new simulator/e2e gate.
- Latest telemetry shows 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 149 warnings, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.

## Tune Rival / Nemesis Persistence

1. Open `src/game/core/RivalRules.ts` for campaign rival state creation, outcome updates, launch modifiers, copy labels, first-defeat reward claiming, and trophy records.
2. Open `src/game/data/rivalRewards.ts` for data-driven first-defeat rewards. Each entry should reference an existing enemy hero, optional item, optional reputation faction, resources, XP, and one trophy definition.
3. Keep state compact: `enemyHeroId`, encounters, defeats, victories against the player, last node, last outcome, disposition, active modifiers, known/unseen status, and save-backed `rivalTrophies`.
4. Keep consequences small. V1 supports one-time first-defeat XP/resource/reputation/item/trophy rewards, escaped-rival +5% HP, triumphant-rival +5% damage, and compact campaign choices that require an existing trophy through `requirements.rivalTrophyIds`.
5. Campaign save shape lives in `src/game/save/SaveTypes.ts`; old saves must normalize to empty `rivals` and `rivalTrophies` arrays in `src/game/save/SaveNormalization.ts`.
6. Campaign Map display lives in `src/game/campaign/RivalIntelPanel.ts` and node preview copy lives in `src/game/campaign/CampaignNodePanel.ts`.
7. Battle launch modifiers are added from `CampaignMapScene` through `BattleLaunchRequest`; enemy hero stat application happens in `BattleSceneSpawner`.
8. Results outcome/reward/trophy copy lives in `src/game/results/ResultsObjectiveSummary.ts`.
9. Simulator telemetry fields live in `src/game/playtest/PlaytestTypes.ts`, `PlaytestRunner.ts`, and `PlaytestReportWriter.ts`.
10. Update `src/game/core/RivalRules.test.ts`, save normalization tests, Campaign Map presentation tests, Results rendering tests, Playwright rival flow coverage, content validation, and simulator telemetry if rival behavior changes.
11. Do not add rival leveling trees, procedural rematches, new maps, new factions, diplomacy, workers, enemy construction, crafting, durability, broad loot complexity, full trophy rooms, or capture/recruit outcomes unless a future task explicitly scopes them.

## Add A New Building

1. Open `src/game/data/buildings.ts`.
2. Copy an existing building entry.
3. Give it a unique `id`.
4. Edit cost, HP, size, build options, train options, or attack values.
5. Set `constructionTimeSeconds`. Use `0` only for prebuilt scenario structures.
6. Add `upgradeOptions` if the building should research upgrades.
7. Add `prerequisites` if it should require another completed building or researched upgrade.
8. To build it from the Command Hall, add its `id` to the Command Hall's `buildOptions`.
9. To place it at battle start, add it to a map `scenario.buildingSpawns` entry in the relevant file under `src/game/data/maps/`.

## Add A New Upgrade

1. Open `src/game/data/upgrades.ts`.
2. Copy an existing upgrade entry.
3. Give it a unique `id`.
4. Set name, description, cost, `researchTimeSeconds`, prerequisites, and effects.
5. Add the upgrade `id` to a building's `upgradeOptions` in `src/game/data/buildings.ts`.
6. Supported effect types currently modify unit stats or hero mana regeneration. New effect types need code in the battle systems.
7. Run `npm run validate:content` and `npm run test`.

## Add A New Hero Class

1. Open `src/game/data/heroClasses.ts`.
2. Copy an existing class.
3. Give it a unique `id`.
4. Edit starting stats and the `primaryAbilityId`.
5. Add all class ability IDs to `abilityIds`.
6. Add matching abilities in `src/game/data/abilities.ts`.
7. Add class-specific skill nodes in `src/game/data/skillTrees.ts` if the class should unlock abilities through progression.

## Add A New Ability

1. Open `src/game/data/abilities.ts`.
2. Copy an existing ability.
3. Give it a unique `id`.
4. Edit mana cost, cooldown, range, radius, duration, and amount.
5. Engine behavior for brand-new effect types must be added in `AbilitySystem.ts`.
6. Add the ability ID to the correct hero class `abilityIds`.
7. If it should be unlocked later, add a skill node with `unlockAbilityId`.
8. Add `prerequisites` only if the ability should later require tech or hero level gates.
9. Run `npm run test` to confirm the hero class and ability links are valid.

## Add A New Skill Node

1. Open `src/game/data/skillTrees.ts`.
2. Copy an existing skill node.
3. Give it a unique `id`.
4. Choose `treeId`: `combat`, `magic`, or `leadership`.
5. Use `statModsPerRank` for passive bonuses.
6. Use `unlockAbilityId` to unlock an ability.
7. Use `classId` only if the skill belongs to one class.
8. Use `requires` if another skill must be learned first.
9. Run `npm run test`.

## Add A New Item

1. Open `src/game/data/items.ts`.
2. Copy an existing item.
3. Give it a unique `id`.
4. Choose a slot: `weapon`, `armor`, `trinket`, or future `relic`.
5. Choose a rarity: `common`, `uncommon`, `rare`, `epic`, or `legendary`.
6. Write `description`, `flavorText`, and `tags`.
7. Add passive bonuses in `statMods`. Supported hero stats are HP, mana, damage, range, attack cooldown, speed, armor, Might, Command, Arcana, and Faith.
8. Optional fields:
   - `classAffinity`: hero class IDs that thematically fit the item.
   - `factionOrigin`: faction ID for where the item came from.
   - `iconAssetKey`: future item icon asset key.
   - `unique`: set to `true` when the hero should only keep one owned copy.
9. Add the item ID to a reward table in `src/game/data/campaignRewards.ts`. `src/game/data/rewards.ts` is the compatibility barrel used by existing imports.
10. Run `npm run test`.

Inventory stores item instances, not raw catalog IDs. Rewards and town purchases create an instance with `instanceId`, `itemId`, `acquiredAt`, `source`, and `affixes`. Equipment references the instance ID. Unique duplicate rewards convert into campaign resources instead of adding a second copy; non-unique duplicates remain separate instances.

## Add Or Tune An Item Affix

1. Open `src/game/data/itemAffixes.ts`.
2. Copy an existing affix entry.
3. Give it a unique `id` and player-facing `name`.
4. Choose `tier`: currently `minor` or reserved `major`.
5. Set `allowedSlots` to one or more of `weapon`, `armor`, `trinket`, or future `relic`.
6. Add modest `statMods`. Supported stats match item stats: HP, mana, damage, range, attack cooldown, speed, armor, Might, Command, Arcana, and Faith.
7. Add `tags` for content meaning, such as `damage`, `support`, `aether`, or `ranged`.
8. Set a positive `weight`; higher weights appear more often when an eligible item rolls an affix.
9. Keep V1 affixes simple. Do not add crafting, durability, rerolling, item art, or proc chains through this file.
10. Run `npm test -- src/game/data/itemAffixes.test.ts src/game/data/contentValidation.test.ts`.

Affix generation is slot-filtered and rarity-based:

- Common: 0-1 affix.
- Uncommon: 1 affix.
- Rare: 1-2 affixes.
- Epic: 2 affixes.
- Legendary: 2-3 affixes.

Deterministic tests can request predictable affixes through the reward/item-generation helpers. Normal play uses weighted randomness. Old saves with empty `affixes` arrays remain valid, and stat application ignores unknown or slot-invalid affix IDs.

## Add A New Reward Table

1. Open `src/game/data/campaignRewards.ts`.
2. Copy a reward table in the matching chapter section.
3. Give it a unique `id`.
4. Add fixed items to `guaranteedItemIds` if every victory should grant them.
5. Add weighted drops to `weightedItemPool`. Each entry needs an `itemId` and positive `weight`.
6. Use `mapIds` when a drop should only appear on specific maps.
7. Use `firstClearOnly` or `repeatClearOnly` for table entries that should only appear before or after the first win on that map.
8. Set `rolls` to the number of weighted item attempts per victory.
9. Add `resourceRewards` and `xpRewards` for normal victory payouts.
10. Add `firstClearBonus` and `repeatClearReward` for map-clear pacing.
11. Keep `deterministicItemIds` when tests or scripted flows need predictable item selection.
12. Open the relevant map module under `src/game/data/maps/` and set the map scenario's `rewardTableId`.
13. Run `npm run test`.

Weighted reward rolls prefer unowned catalog items when possible. When a reward creates a new item instance, the instance rolls affixes from the item rarity and slot unless a deterministic test hook supplies exact affixes. If a guaranteed, deterministic, or scripted reward grants a unique item the hero already owns, the reward flow converts it into Crowns or Aether and reports the conversion on the Results screen.

## Add A New Skirmish Map

1. Create a new map module under `src/game/data/maps/`, usually by copying `firstClaim.ts`, `brokenFord.ts`, or `ashenOutpost.ts`.
2. Export one named `BattleMapDefinition` constant from that file, such as `NEW_FRONTIER_MAP`.
3. Give the map a unique `id`, display `name`, `role`, `description`, and `strategicNotes`.
4. Set `width`, `height`, `playerStart`, `enemyStart`, and `visualPaths`. Visual paths draw roads and lanes; keep every path point inside the map.
5. Add terrain zones. Include one full-map grass zone, buildable zones for each base, and blocked or water zones that shape building placement.
6. Add 4 capture sites for the current skirmish setup. Each site must use a resource ID from `resources.ts`.
7. Add neutral camps with valid unit IDs. Use stronger central camps when the center should feel risky.
8. Fill the `scenario` block with starting resources, hero spawn, player/enemy buildings, player/enemy unit spawns, objectives, enemy AI config, and reward table.
   - Primary objectives use `playerBaseBuildingId` and `enemyBaseBuildingId`.
   - Optional `secondaryObjectives` can track `capture_site`, `destroy_building`, or `defeat_unit` targets for milestone maps and ResultsScene display.
9. Add a reward table in `rewards.ts` and point the map's `scenario.rewardTableId` at it.
10. Import and add the new map constant to `MAPS` in `src/game/data/maps/index.ts`. Keep `src/game/data/maps.ts` as the compatibility barrel.
11. Run `npm run test` and `npm run build`. The setup screen automatically lists maps from `MAPS`.

Current map examples:

- `first_claim`: tutorial skirmish with the safest opening economy.
- `broken_ford`: contested two-lane river map with a risky center.
- `ashen_outpost`: campaign milestone fortress assault with a central Burned Shrine, enemy defensive towers, side resource paths, and secondary objectives for shrine capture, enemy Barracks destruction, and commander defeat.
- `cinderfen_causeway`: first Chapter 2 ash-marsh causeway battle with a safe but constrained player start, four capture sites, three neutral camps, a central contested Cinder Shrine with a one-time +20 Aether first-capture surge, and one enemy staging tower.
- `cinderfen_watchpost`: second compact Chapter 2 raised-road watchpost battle with three capture sites, two neutral camps, fogged central tower pressure, and no Cinder Shrine.

## Add A New Campaign Node

Campaign node definitions are split by chapter. `src/game/data/campaignNodes.ts` is a public compatibility barrel that combines the focused arrays; do not add new node objects directly to the barrel.

1. Open the focused chapter node module: `src/game/data/borderMarchesNodes.ts` for Chapter 1 or `src/game/data/cinderfenRoadNodes.ts` for the current Chapter 2 slice.
2. Copy an existing node entry from the same chapter when possible.
3. Give it a unique `id`, display `name`, and `description`.
4. Choose `nodeType`: `battle`, `shrine`, `town`, `ruin`, `fortress`, or `event`.
5. Set `difficulty`, `mapId`, `enemyFactionId`, optional `aiPersonalityId`, and optional `enemyHeroId` for named rival battles.
6. Add prerequisite node IDs to `prerequisites`.
7. Add future node IDs to `unlocks`.
8. Add node rewards with optional `xp`, `itemIds`, and `resources`. Node resource rewards are added to the persistent campaign bank, not to the temporary battle economy.
9. For `event`, `town`, `shrine`, or other non-battle nodes, add optional `eventText` and `choices` when the node should ask the player to choose an outcome or use a service.
10. Set `x` and `y` as percentages for the campaign map UI position.
11. Add the node id to the matching `nodeIds` list in `src/game/data/campaignChapters.ts`; keep the order in that list the same as the focused chapter node array.
12. Battle nodes launch combat through `BattleLaunchRequest`. Non-battle nodes either resolve direct rewards or show data-driven choices from the campaign map.
13. Run `npm run test`. Content validation checks node links, map IDs, faction IDs, AI personality IDs, reward item IDs, resource IDs, choice references, and that focused chapter arrays still flow through the public barrels.

## Add A New Chapter

1. Add a focused node module under `src/game/data/`, following the pattern in `borderMarchesNodes.ts` and `cinderfenRoadNodes.ts`.
2. Export the chapter node array from `src/game/data/campaignNodes.ts` and append it to `CAMPAIGN_NODES`.
3. Add the chapter metadata to `src/game/data/campaignChapters.ts`, including `id`, title, short description, ordered `nodeIds`, and unlock prerequisites.
4. Add or group any chapter-specific battle reward tables in `src/game/data/campaignRewards.ts`; keep `src/game/data/rewards.ts` as the public import surface.
5. Add maps under `src/game/data/maps/` only when the task explicitly calls for a map. Otherwise, reuse existing maps and systems.
6. Run `npm test`, `npm run build`, and any requested Playwright/simulator coverage.

Current campaign battle assignments:

- Chapter 1 Border Marches uses First Claim, Broken Ford, and Ashen Outpost across its battle nodes.
- Chapter 2 Cinderfen Road currently has one playable event gate, one compact support/town node, two playable battle nodes, and one compact aftermath event.
- `cinderfen_overlook` unlocks after `ashen_outpost` and offers three baseline one-time preparation choices using existing campaign resources, reputation, item rewards, and campaign modifiers. If the hero has `trophy_malrec_outpost_standard`, it also offers the optional Raise Malrec's Standard choice for a small morale-style modifier and reputation reward.
- `cinderfen_waystation` unlocks after `cinderfen_overlook` and stays open as a small support node. It offers Marsh Guides, Ash Filters, Refugee Scouts, and Shrine Attunement through the existing town-service choice UI, resource costs, modifiers, reputation, and save/duplicate-prevention rules.
- `cinderfen_crossing` launches `cinderfen_causeway` only after `cinderfen_overlook` is completed. Its only Cinderfen-specific tactical feature is the Cinder Shrine: a first-capture +20 Aether battle-local surge on the existing central Aether site.
- `cinderfen_watch` launches `cinderfen_watchpost` only after `cinderfen_crossing` is completed. It reuses existing Ashen units, structures, objective types, rewards, fog/minimap behavior, and simulator/e2e hooks; it has no named rival and no Cinder Shrine.
- `cinderfen_aftermath` unlocks only after `cinderfen_watch` is completed. It is a non-battle event with three baseline once-only choices: Secure the Watch Road, Aid the Fenfolk, and Study the Ashen Marks. If the hero has `trophy_malrec_outpost_standard`, it also offers Display Malrec's Standard for a tiny Free Marches reputation consequence. Keep aftermath-style nodes modest, event-only, and backed by `choiceIdsClaimed` duplicate prevention.
- Do not make additional Chapter 2 nodes playable unless the task explicitly scopes them.

Campaign choices support:

- `id`, `label`, and `description` for display.
- `requirements` for campaign resources, hero level, completed nodes, owned items, earned rival trophies, or faction reputation.
- `costs` paid from the persistent campaign resource bank.
- `rewards` for XP, item IDs, campaign resources, campaign modifiers, node unlocks, reputation changes, and a `recoverHero` placeholder.
- `stockItemId` for town item purchases. It should point at the same item granted in `rewards.itemIds` so the UI can show stock rarity and slot.
- `reputationChanges` and `unlockNodeIds` as direct choice effects when that reads cleaner than nesting under `rewards`.
- `onceOnly` to save a claim ID in `choiceIdsClaimed`.
- `completesNode: false` when the choice should leave the node open for a later choice.
- For aftermath or consequence events that complete after one choice, use `onceOnly: true` and let the node complete so rewards cannot be claimed twice. Prefer small campaign-bank resources, XP, reputation, and existing campaign modifiers over new mechanics.

Reputation guidance:

- Reputation values live on the hero save in `hero.factionReputation`.
- The tracked campaign reputation IDs are `free_marches`, `common_folk`, `old_faith`, `ashen_covenant`, and `sylvan_concord`.
- Rank thresholds are shared by every tracked faction: Friendly at 25, Honored at 50, Disliked at -25, and Hostile at -50.
- Small reputation effects live in `src/game/data/reputation.ts`; add effects there instead of hard-coding campaign UI or battle launch behavior.
- Current supported effect shapes discount Marcher Camp choice costs, discount Stronghold Crown costs, add a Chapel Aether bonus, or add the Ashen hostile pressure launch modifier.
- Choice previews should show both the reputation delta and resulting value/rank so players can see threshold consequences before committing.
- If a new effect references a node, faction, or campaign modifier, update validation and tests so non-coder data edits fail loudly.

Town service guidance:

- Use `nodeType: "town"` for repeatable service hubs such as Marcher Camp.
- Give repeatable services `onceOnly: false` and `completesNode: false`.
- Give fixed stock purchases `onceOnly: true`, `completesNode: false`, `stockItemId`, and a matching `rewards.itemIds` entry.
- Costs are paid from the persistent campaign bank and are tracked in `campaign.resourcesSpent`.
- Town service usage is tracked in `campaign.townServiceUseCounts`; once-only service purchases are also tracked in `campaign.townServiceClaimedIds`.
- Next-battle effects should usually grant a campaign modifier such as `well_rested` or `inspired_militia`.
- Chapter-specific services can use narrow campaign modifiers when they remain small and clearly labeled. Current Cinderfen examples are `marsh_guides`, `ash_filters`, and `shrine_attunement`; broad next-Cinderfen-battle services apply to Cinderfen battle nodes, while site-specific services such as Shrine Attunement are consumed only when the launched map contains the matching Cinder Shrine site.
- Avoid turning a town node into a broad vendor system unless the task explicitly scopes one. Cinderfen Waystation is a preparation stop, not a general shop.

## Add A Stronghold Upgrade

1. Open `src/game/data/strongholdUpgrades.ts`.
2. Copy an existing `STRONGHOLD_UPGRADES` entry and give it a unique `id`.
3. Add that ID to `StrongholdUpgradeId` in `src/game/types/CampaignTypes.ts`.
4. Set `name`, `description`, `tier`, `cost`, `prerequisites`, `effects`, `maxRank`, optional `iconKey`, and `flavorText`.
5. Use only supported effect types unless you are also adding engine support:
   - `extra-starting-unit`
   - `starting-resources`
   - `hero-max-hp-multiplier`
   - `hero-max-mana-multiplier`
   - `building-vision-bonus`
   - `enemy-wave-warning-lead`
   - `watchtower-range-multiplier`
   - `first-building-construction-time-multiplier`
   - `unit-training-time-multiplier`
6. Add prerequisite upgrade IDs through `prerequisites.upgradeRanks` and prerequisite campaign nodes through `prerequisites.completedNodeIds`. Tier II upgrades must require the matching Tier I upgrade at rank 1.
7. Keep costs in campaign resources; purchases spend from `campaign.resources` and record `campaign.resourcesSpent`.
8. Purchases persist in `campaign.strongholdUpgradeRanks`, and save normalization filters unknown upgrades for old or edited saves.
9. If you add a new effect type, update battle launch application, Stronghold UI copy, and `src/game/data/validation/validateStronghold.ts`.
10. Run `npm test` and at least one e2e flow that opens the Campaign Map before relying on the new upgrade.

Current Tier II pairings are deliberately narrow: Training Yard II speeds Militia/Ranger training and adds +1 Retinue capacity, Watch Post II extends warning and Watchtower range, Quartermaster Stores II adds a moderate Iron/Aether-inclusive starter package, Chapel Corner II raises the hero HP/Mana blessing to 8%, and Ranger Paths II adds one starting Ranger after Ranger Paths I.

## Add A New Faction

1. Open `src/game/data/factions.ts`.
2. Copy an existing faction.
3. Give it a unique `id`.
4. Write `name`, `fantasy`, and a readable `color`.
5. Fill the `mechanics` block:
   - `economyStyle`, `militaryStyle`, and `magicStyle` are shown in setup/campaign UI.
   - `availableUnitIds`, `availableBuildingIds`, and `availableUpgradeIds` must reference valid data IDs.
   - `aiPersonalityPreferences` must reference valid AI personality IDs.
   - `campaignReputationHooks` should list factions whose reputation can be affected by this faction.
   - `factionModifiers` can currently use `burn-on-hit`, `low-health-damage`, or `wave-speed`.
6. Add faction units in `units.ts`.
7. Add faction buildings in `buildings.ts`.
8. Add faction upgrades or trait placeholders in `upgrades.ts` when needed.
9. Assign the faction to campaign nodes with `enemyFactionId` and pair it with a fitting `aiPersonalityId`.
10. Run `npm run test` so validation checks faction unit, building, upgrade, AI, and reputation references.

Current faction modifier support:

- `burn-on-hit`: applies a damage-over-time status when matching units or buildings hit.
- `low-health-damage`: multiplies damage when matching units are below an HP threshold.
- `wave-speed`: increases movement speed for matching units when an AI attack wave launches.

New modifier types require code in combat or battle systems plus validation in `contentValidation.ts`.

## Add A New Manual Art Asset

1. Open `tools/manual-asset-pipeline/assetRegistry.ts`.
2. Copy an existing asset entry from the same category.
3. Give it a unique `id`, clear `displayName`, target folder, filename, size, usage, and notes.
4. Run `npm run assets:prompts`.
5. Open `public/assets/manual/ASSET_PROMPT_BOOK.md`.
6. Generate the image manually in ChatGPT.
7. Put the image in the listed `public/assets/manual/...` folder.
8. Exact snake_case filenames are best, but friendly display names also work.
9. Run `npm run assets:refresh`.
10. Add or update the matching entry in `src/game/assets/visualAssetManifest.ts`.
11. Set honest metadata for `currentStatus`, `sourceType`, `licenseStatus`, `usage`, `usedBy`, scale/readability fields, `allowedInProduction`, and `needsReview`.
12. Run `npm run validate:content`; this now validates visual asset metadata and CLI-side runtime asset file paths.

Visual manifest rules:

- Do not mark an asset `final` with unknown source or unknown license.
- Runtime assets cannot use `licenseStatus` `reference-only` or `do-not-ship`.
- Runtime assets with unknown license must set `needsReview: true`.
- Runtime assets need non-empty `usedBy` references.
- Positive `intendedWorldHeightPx` and `currentRenderHeightPx` are required when those fields are present.
- Deprecated assets must not be runtime-used.
- Manual source duplicates should usually be `usage: "manual-reference"` and `currentStatus: "reference"`.

## Add Or Replace UI Art Kit Images

UI-kit images are reusable frames and slots, not full menu screenshots.

1. Run `npm run assets:prompts`.
2. Open `public/assets/manual/ASSET_PROMPT_BOOK.md`.
3. Search for `Reusable Panel Frame` or any asset ID starting with `ui_`.
4. Generate one image at a time in ChatGPT.
5. Save the image in `public/assets/manual/ui`.
6. Use the exact filename from the prompt book, such as `ui_panel_frame.png`.
7. Run `npm run assets:refresh`.
8. Refresh the browser and check the main menu, battle HUD, results screen, and Asset Gallery.

Important UI-kit rules:

- Frames should have transparent centers.
- Button states should not contain words.
- Slots should not contain ability or item icons.
- Dividers should be thin and quiet.
- Do not use one big screenshot as UI art.
- If a UI asset looks stretched, ask Codex to tune the CSS `border-image-slice` value for that asset.

## Edit A Skirmish Map

1. Open the map's module under `src/game/data/maps/`.
2. Setup metadata, terrain, visual paths, capture sites, and neutral camps are near the top of each map entry.
3. Starting buildings, starting units, hero spawn, objectives, starting resources, and enemy AI settings live in the map's `scenario` block.
4. To change enemy pressure, edit `scenario.enemyAI.attackInterval`, `minAttackArmySize`, `attackWaveSize`, and `unitPlan`.
5. To change victory rewards, edit `scenario.rewardTableId`.
6. Run `npm run test` after edits. The content validation test catches missing IDs before the game opens.

Map index structure:

- `src/game/data/maps/firstClaim.ts`: First Claim map definition.
- `src/game/data/maps/brokenFord.ts`: Broken Ford map definition.
- `src/game/data/maps/ashenOutpost.ts`: Ashen Outpost map definition.
- `src/game/data/maps/cinderfenCauseway.ts`: Cinderfen Causeway map definition.
- `src/game/data/maps/cinderfenWatchpost.ts`: Cinderfen Watchpost map definition.
- `src/game/data/maps/index.ts`: imports map constants, exports `MAPS`, `DEFAULT_MAP_ID`, and lookup helpers.
- `src/game/data/maps.ts`: compatibility barrel so existing imports from `src/game/data/maps` keep working.

## Add Or Tune An AI Personality

1. Open `src/game/data/aiPersonalities.ts`.
2. Copy one of the four existing personalities: Balanced Warlord, Raider Rush, Fortress Keeper, or Hexfire Cult.
3. Give it a unique `id`, `name`, `shortDescription`, and `description`.
4. Set `preferredUnitIds` and `unitPlan` using valid unit IDs.
5. Tune timing multipliers for first attack delay, attack interval, expansion interval, training interval, and commander join delay.
6. Tune wave behavior through `attackWaveSizeMultiplier`, `minAttackArmySizeDelta`, and per-phase overrides for allowed, preferred, and capped units.
7. Tune defense through `defendRadiusMultiplier`, `defenseSquadSizeDelta`, `reserveDefenseUnits`, and `protectCaptureSites`.
8. Assign the personality to a campaign battle node with `aiPersonalityId`, or select it in Skirmish Setup.
9. Run `npm run test` so validation catches missing units or invalid campaign references.

## Safe Editing Tips

- Keep IDs lowercase and use hyphens or underscores consistently.
- Do not reuse IDs.
- Change numbers gradually.
- Completed-building prerequisites only count finished construction, not structures still under construction.
- If the game stops building, undo the last data edit and run `npm run build` again.
- If tests fail with "references missing", check for a typo in an ID.
