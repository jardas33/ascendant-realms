# Ascendant Realms LLM Handoff

Last updated: 2026-05-02 11:51 -04:00

This file is the main continuation note for future LLMs working on Ascendant Realms. It supersedes older scattered status notes when they disagree.

## Project Identity

Ascendant Realms is a Phaser 3, TypeScript, and Vite browser-game prototype for a fantasy RTS/RPG hybrid.

The current playable loop:

1. Create or load a persistent hero.
2. Enter the Border Marches mini-campaign or a standalone skirmish.
3. Play an RTS battle with hero abilities, capture sites, construction, training queues, upgrades, rally points, pathfinding, fog of war, live minimap, and enemy pressure waves.
4. Resolve victory or defeat through the shared Results scene.
5. Persist hero XP, skill points, inventory item instances with affixes, equipment, campaign node progress, event choices, town purchases, Stronghold upgrades, retinue units, campaign modifiers, campaign resources, settings, and save migrations in localStorage.

The project is now marked as the v0.2 prototype baseline plus Unit Veterancy V1 and Retinue Camp V1. It is still a prototype, but it has a broad playable RTS/RPG spine with Stronghold Tier I telemetry-response changes, Stronghold Development Tier II, campaign consequence/reputation hooks, randomized item affixes V1, battle-local unit XP/ranks/results summaries, compact save-backed retinue persistence, regenerated telemetry, a safe HeroProgressionRules module split, release documentation, and updated balance/docs notes. Preserve that work. Do not reset, delete, checkout, or revert changes unless the user explicitly asks.

## Current Git State

Project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

Current branch:

```text
main
```

Latest published commit:

```text
9cd3205e3d1be23ed967bd51f315bab3d39cc52e
```

Latest commits:

```text
9cd3205 Update development checkpoint metadata
a3dba27 Checkpoint Stronghold development and simulator profiles
a0d3f3c Update development checkpoint metadata
3f676e1 Checkpoint Stronghold development and campaign simulator profiles
```

Known shell/tool note:

- `rg.exe` has returned access-denied errors in this workspace. Use PowerShell `Select-String`, `Get-ChildItem`, and targeted `Get-Content` if `rg` fails.
- Latest Browser Use sanity was rerun during the pre-feature checkpoint: the current in-app preview at `http://127.0.0.1:4182/` showed the Ascendant Realms main menu with browser console errors at 0. The visible menu still says `Prototype v0.1` even though the docs describe the current v0.2 prototype baseline; treat that as a known copy/version mismatch until product copy is intentionally refreshed. Playwright e2e remains the deterministic browser verification surface for gameplay flows.

Current branch status for this handoff update:

```text
## main...origin/main
```

Before the checkpoint commit is created, `main` and `origin/main` both point at `9cd3205e3d1be23ed967bd51f315bab3d39cc52e`. The worktree contains intentional uncommitted code, test, documentation, and telemetry edits from the Stronghold/reputation/affix follow-up work, Unit Veterancy V1, Retinue Camp V1, the retinue telemetry balance pass, and the HeroProgressionRules refactor. Do not reset or revert those edits unless the user explicitly asks.

Pending checkpoint commit:

```text
9f96b1f9e5cdf25081c4a817f9c5796000fdfc82
```

Pending branch sync status:

```text
Post-checkpoint/pre-push: `main...origin/main [ahead 1]` at checkpoint commit `9f96b1f9e5cdf25081c4a817f9c5796000fdfc82`. A small metadata follow-up records this hash before pushing.
```

Notable current untracked additions include `CHANGELOG.md`, `RELEASE_CHECKLIST.md`, `src/game/core/progression/`, `src/game/core/RetinueRules.ts`, `src/game/core/RetinueRules.test.ts`, `src/game/campaign/RetinuePanel.ts`, `src/game/results/ResultsRetinuePanel.ts`, `src/game/data/unitVeterancy.ts`, and `src/game/data/unitVeterancy.test.ts`. Many existing game, test, docs, telemetry, and e2e files are modified as part of the same intentional feature/refactor stack.

## Randomized Item Affixes V1 - 2026-05-01

Goal: add a small, safe affix layer to item instances without crafting, durability, item art, inventory rewrites, or large loot complexity.

What changed in this pass:

- Added `src/game/data/itemAffixes.ts` with 9 data-driven affixes: Sturdy, Sharp, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's.
- Added `ItemAffixDefinition` to `ItemTypes.ts`: affixes have `id`, `name`, `tier`, `allowedSlots`, `statMods`, `tags`, and `weight`.
- Added rarity-based affix counts: common 0-1, uncommon 1, rare 1-2, epic 2, legendary 2-3. Deterministic mode picks weighted slot-filtered affixes for tests.
- Reward-generated item instances now roll and persist affix IDs when item definitions are available. Old empty-affix instances remain valid.
- Equipment stat calculation now applies base item stats plus valid equipped affix stats. Unknown or slot-invalid saved affix IDs are ignored by stat application.
- Results and Inventory UI now show affix names, base stats, affix stat contribution, total item stats, and equip preview deltas.
- Content validation now checks affix IDs, names, tiers, slots, tags, stat values, and weights.
- E2E adds a deterministic affixed reward path: earn an affixed Weathered Command Sword, verify Sharp and total stats in Results, equip it, verify save persistence and Inventory stats.

Verification completed for this pass:

```text
npm test
PASS: 33 test files, 178 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 41 Playwright tests in 16.1m

npm run playtest:sim
PASS: 105 simulated runs across 35 campaign battle nodes; no structural too_hard nodes, no too_easy nodes, Ashen Outpost beatable, no Stronghold warnings

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, browser console errors: 0
```

## Campaign Consequences And Reputation Hooks - 2026-05-01

Goal: make campaign choices and reputation visibly affect play without adding a broad diplomacy system.

What changed in this pass:

- Added `src/game/data/reputation.ts` with data-driven ranks for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord. Thresholds are Friendly `>= 25`, Honored `>= 50`, Disliked `<= -25`, and Hostile `<= -50`.
- Added four compact reputation effects:
  - Common Folk Friendly: Marcher Camp choice/service costs are 10% cheaper.
  - Free Marches Friendly: Stronghold upgrade Crown costs are 10% cheaper.
  - Old Faith Friendly: Chapel choices with Aether rewards grant +5 extra Aether.
  - Ashen Covenant Hostile: Ashen battle launches include the `ashen_hostile_pressure` modifier, spawning one extra Raider.
- Campaign choice rules now preview and apply adjusted costs/rewards, so discounts and Chapel bonuses are visible before purchase and deterministic when applied.
- Stronghold purchase rules now accept hero reputation context and spend discounted Crown costs when Free Marches Friendly is active.
- Campaign map UI now shows reputation value, rank, active effects, adjusted cost/reward lines, reputation deltas, modifier grants/removals, and whether a choice completes its node.
- Battle launch now merges campaign modifiers, reputation-derived launch modifiers, and Stronghold modifiers. The Ashen hostile pressure effect uses the existing launch-modifier path and battle telemetry.
- Content validation now checks reputation effect references, ranks, modifiers, discount multipliers, bonus values, and scoped node references.
- Save/load needed no schema change; existing reputation values persist through the current save format.

Verification completed for this pass:

```text
npm test
PASS: 32 test files, 170 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 40 Playwright tests in 15.3m

npm run playtest:sim
PASS: 105 simulated runs across 35 campaign battle nodes; no structural too_hard nodes, no too_easy nodes, Ashen Outpost beatable, no Stronghold warnings

Browser Use preview smoke at http://127.0.0.1:4181/
PASS: main menu visible, campaign reputation panel rendered, browser console errors: 0
```

## Stronghold Development Tier II - 2026-05-01

Goal: add a compact second tier of Stronghold upgrades without turning the campaign into a city-builder.

What changed in this pass:

- Added five data-driven Tier II upgrades in `src/game/data/strongholdUpgrades.ts`: Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II.
- Each Tier II upgrade requires its matching Tier I upgrade through `prerequisites.upgradeRanks`.
- Implemented Tier II effects through existing launch-effect hooks:
  - Training Yard II: Militia and Rangers train 10% faster and Retinue capacity increases by +1.
  - Watch Post II: first enemy wave warning arrives 15s earlier on top of Watch Post I, and player Watchtowers reach +20% total range.
  - Quartermaster Stores II: additional starting battle resources, including Iron and Aether.
  - Chapel Corner II: hero starts with +8% max HP and Mana total.
  - Ranger Paths II: +1 starting Ranger.
- Stronghold UI now exposes the new effects through the existing cost/effect/locked-state cards.
- Content validation now checks that Tier II Stronghold upgrades require their previous tier at rank 1.
- Battle launch support covers Tier II through existing modifier aggregation, runtime starter resources, hero stat modifiers, enemy warning lead, Watchtower range, construction/training modifiers, and extra starting unit spawning.
- The simulator now includes a `tier_two_quartermaster_path` profile and writes aggregated Stronghold effects into telemetry so every launch effect is visible in JSON and Markdown.
- The Stronghold e2e now seeds resources, verifies a locked Tier II card, buys Quartermaster Stores I and II, launches Border Village, and verifies the Tier II starting-resource package in battle.

Verification completed for this pass:

```text
npm test
PASS: 32 test files, 162 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 14.6m

npm run playtest:sim
PASS: 105 simulated runs across 35 profile-node summaries; no structural too_hard nodes, no too_easy nodes, no Stronghold warnings

Browser Use preview smoke at http://127.0.0.1:4180/
PASS: main menu visible, browser console errors: 0
```

## Commands

Run these from the project root:

```bash
npm install
npm run dev
npm test
npm run build
npm run preview
npm run test:e2e
npm run test:e2e:headed
npm run assets:prompts
npm run assets:ui-kit
npm run assets:process-battle-sprites
npm run assets:manifest
npm run assets:validate
npm run assets:refresh
```

Notes:

- `npm run test:e2e` starts Vite through Playwright.
- The e2e suite intentionally uses one worker for stability.
- Use a long shell timeout for e2e. A 3-minute shell timeout is too short; the latest full run took 18.0 minutes.
- `npm run assets:refresh` is only needed after changing asset registry, manual art, processed sprites, or manifest inputs.

## Latest Verified Status

Fresh pre-feature checkpoint verification completed on 2026-05-02 at about 11:51 -04:00:

```text
npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 18.0m. This suite is slow; use a long timeout. Slow file noted by Playwright: tests/e2e/deep-flow.spec.ts, 10.7m.

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

Browser Use sanity
PASS: current in-app preview at http://127.0.0.1:4182/ loads Ascendant Realms main menu, browser console errors: 0. Known copy/version mismatch: visible menu still says `Prototype v0.1`.

Checkpoint commit
9f96b1f9e5cdf25081c4a817f9c5796000fdfc82

Branch sync
Post-checkpoint/pre-push: `main...origin/main [ahead 1]` at checkpoint commit `9f96b1f9e5cdf25081c4a817f9c5796000fdfc82`. A small metadata follow-up records this hash before pushing.
```

Focused item-affix verification on 2026-05-02 during this pass:

- `npm test -- src/game/data/itemAffixes.test.ts src/game/core/HeroProgressionRules.test.ts src/game/progression/ItemComparison.test.ts src/game/core/SaveSystem.test.ts src/game/data/contentValidation.test.ts src/game/battle/BattleRuntime.test.ts`: passed, 6 test files and 57 tests.
- The full e2e suite includes affixed reward display, affix persistence after Equip Now, and Inventory stat display including affix contribution.

Focused reputation/consequence verification on 2026-05-01 during this pass:

- `npm test -- src/game/core/CampaignRules.test.ts src/game/core/StrongholdRules.test.ts src/game/campaign/CampaignMapViewModel.test.ts src/game/core/SaveSystem.test.ts src/game/data/contentValidation.test.ts`: passed, 5 test files and 66 tests.
- The full e2e suite includes reputation rank/effect display, Free Marches Stronghold discount preview, Common Folk Marcher Camp discount preview, and event choice reputation/modifier preview coverage.

Focused Stronghold verification on 2026-05-01 during this pass:

- `npm test -- src/game/core/StrongholdRules.test.ts src/game/core/SaveSystem.test.ts src/game/battle/BattleRuntime.test.ts src/game/data/contentValidation.test.ts src/game/playtest/ScriptedBattlePlaytest.test.ts`: passed, 5 test files and 52 tests.
- `npm run playtest:sim`: passed after the final code/docs update and regenerated both telemetry files.

Recent targeted checks also passed:

```text
npm run test:e2e -- --reporter=line -g "Ashen Outpost landmarks"
PASS: 1 Playwright test, including Normal-fog baseline, scouted Ashen resource sites, neutral camps, fortress buildings, minimap markers, and HUD-overlap guards

npm run test:e2e -- --reporter=line -g "minimap renders marker families"
PASS: 1 Playwright test, including unit/building/site/camp/rally markers, player/enemy/neutral teams, the camera rectangle, and rally/wave/base/resource pings

npm run test:e2e -- --reporter=line -g "unlocked hero ability hotkeys"
PASS: 1 Playwright test, including keyboard casts for Rally Banner, Cleave, and War Cry plus success-feedback stability

npm run test:e2e -- --reporter=line -g "main menu, info"
PASS: 1 Playwright test, including Arcanist and Shepherd save persistence through hero creation, with explicit 60s timeout after the expanded flow measured 35.9s

npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"
PASS: 1 Playwright test, including direct canvas click-selection of the live hero and selected-hero HUD state

npm run test:e2e -- --reporter=line -g "all skirmish maps"
PASS: 1 Playwright test after the transient full-suite `net::ERR_NO_BUFFER_SPACE` interruption

npm run test:e2e -- --reporter=line -g "first enemy wave pressure can damage the base and be survived"
PASS: 1 Playwright test, including tracked wave pressure, Command Hall damage, pings, and survival bookkeeping

npm test -- battlePacing
PASS: 1 test file, 3 tests, including ordered difficulty pacing and fog defaults

npm run test:e2e -- --reporter=line -g "skirmish difficulty selection changes fog and starting pressure"
PASS: 1 Playwright test, including Story vs Normal live fog and starting enemy roster differences

npm run test:e2e -- --reporter=line -g "campaign Border Village launches a battle scene"
PASS: 1 Playwright test, including fogged quarry camp/site/unit minimap-marker leak coverage

npm test -- UnitOrderSummary CombatSystem FogOfWarSystem
PASS: 3 test files, 12 tests

npm run test:e2e -- --reporter=line tests/e2e/smoke.spec.ts -g "campaign Border Village launches a battle scene"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line tests/e2e/deep-flow.spec.ts -g "battle HUD supports"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost special objectives"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost defeat tips"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "alternate Refugee Caravan"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Old Stone Road victory"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "settings screen persists accessibility options"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost objectives do not cover"
PASS: 1 Playwright test

npm test -- ResultsViewModel
PASS: 1 test file, 3 tests

npm run test:e2e -- --reporter=line -g "victory and defeat result actions"
PASS: 1 Playwright test, including defeat Open Hero Inventory navigation to saved hero progress

npm run test:e2e -- --reporter=line -g "victory reward can be kept"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "first campaign battle path"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost special objectives"
PASS: 1 Playwright test; the final full-suite run also passes after targeting the visible completed objectives panel
```

## Most Recent Completed Work

### Clean Checkpoint Verification - 2026-05-02

Goal: create a clean checkpoint before any new feature work, preserving all current dirty work from Unit Veterancy V1, Retinue Camp V1, Stronghold Tier II, reputation hooks, randomized item affixes V1, the retinue telemetry balance pass, release docs, and the HeroProgressionRules split.

What was verified:

```text
npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 18.0m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, browser console errors: 0; visible menu still labels the build `Prototype v0.1`
```

Checkpoint commit:

```text
9f96b1f9e5cdf25081c4a817f9c5796000fdfc82
```

Branch sync status:

```text
Post-checkpoint/pre-push: `main...origin/main [ahead 1]` at checkpoint commit `9f96b1f9e5cdf25081c4a817f9c5796000fdfc82`. A small metadata follow-up records this hash before pushing.
```

No gameplay behavior changed during this checkpoint pass; only verification, telemetry regeneration from `npm run playtest:sim`, and checkpoint documentation updates were performed.

### HeroProgressionRules Refactor - 2026-05-02

Goal: split the high-risk hero progression rules file into focused pure-rule modules without changing gameplay, balance, save format, UI, or formulas.

What changed:

- `src/game/core/HeroProgressionRules.ts` is now a 1-line compatibility barrel for existing imports.
- Added focused modules under `src/game/core/progression/`: `HeroStatRules.ts`, `SkillRules.ts`, `EquipmentStatRules.ts`, `ItemRewardRules.ts`, `AffixRules.ts`, `DuplicateRewardRules.ts`, `LevelingRules.ts`, and `index.ts`.
- Public imports through `src/game/core/HeroProgressionRules.ts` still work.
- Important Windows/path note: the compatibility barrel exports from `./progression/index` instead of `./progression` to avoid casing ambiguity with the existing `src/game/core/Progression.ts`.
- No formulas were intentionally changed. This was extraction-only.

Verification completed for this refactor:

```text
npm test -- --run src/game/core/HeroProgressionRules.test.ts src/game/progression/ItemComparison.test.ts src/game/data/itemAffixes.test.ts src/game/core/ResultsFlow.test.ts
PASS: 4 test files, 24 tests

npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 18.9m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

git diff --check
PASS: no whitespace errors; existing `.gitignore` CRLF warning only

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, browser console errors: 0; visible menu still labels the build `Prototype v0.1`
```

### Retinue Telemetry Balance Pass - 2026-05-02

Goal: make Unit Veterancy and Retinue Camp V1 useful but not mandatory, using `LLM_GAME_HANDOFF.md`, `BALANCE.md`, `PLAYTEST_TELEMETRY.md`, and `PLAYTEST_TELEMETRY.json` as the source read.

What changed:

- Unit Veterancy thresholds moved from 40 / 100 / 180 XP to 55 / 130 / 230 XP.
- Rank bonuses were softened from +5% / +10% / +15% to +4% / +8% / +12%.
- The +1 armor bonus now starts at Elite instead of Veteran, keeping Veteran useful without making every saved Veteran a small armor upgrade.
- The simulator now includes combined retinue profiles for mixed retinue plus Training Yard II and mixed retinue plus Quartermaster II.
- Simulator retinue deployment now respects live campaign capacity: 2 active units by default, +1 only after Training Yard II is purchased.
- Retinue death handling remains the simple V1 permanent-removal rule. No wounded timer, replacement UI, workers, enemy construction, maps, factions, diplomacy, or crafting were added.

Telemetry read after this pass:

- No retinue baseline: 9-3-3 overall; Ashen Outpost is 1-0-2, with Safe Beginner winning and no structural `too_hard`.
- One Veteran Militia: 10-3-2 overall; Ashen Outpost becomes 2-0-1, useful but not required.
- One Veteran Ranger: 10-3-2 overall; Ashen Outpost becomes 2-0-1, useful but not required.
- Mixed retinue: 11-3-1 overall; Ashen Outpost sweeps 3-0 and stays flagged `needs_human_review`.
- Retinue plus Training Yard II: 11-3-1 overall; third-slot Ashen starts 7 Militia / 3 Rangers and is flagged `needs_human_review`, not structural `too_easy`.
- Retinue plus Quartermaster II: 11-3-1 overall; Ashen sweep is flagged for human review because starter resources plus mixed retinue are visibly strong.
- Early nodes produce no structural `too_easy`; Old Stone Road retinue sweeps remain human-review items because the no-retinue baseline already wins all scripts.

### Retinue Camp V1 - 2026-05-02

Goal: let a small number of surviving campaign veterans persist across battles as the hero's personal retinue without adding workers, enemy construction, diplomacy, crafting, new factions, or a large army-management layer.

What changed:

- Added `src/game/core/RetinueRules.ts` for capacity, eligibility, add/dismiss, deployment, survivor updates, and death removal.
- Campaign retinue capacity is 2 active units by default; Training Yard II adds +1 capacity.
- Eligible recruits come from campaign victory Results Notable Veterans: player-owned surviving non-hero units that are Seasoned or better.
- Campaign saves now persist `retinueUnits` with retinue ID, unit type, optional name, rank, XP, kills, source battle, acquired timestamp, and status. Old saves normalize safely to an empty retinue.
- Results can add eligible surviving veterans to the retinue when capacity is available. Full retinues show current saved units and disable additional adds rather than opening replacement UI.
- Campaign Map now has a Retinue Camp panel with capacity, saved units, rank/type, and a simple Dismiss button.
- Campaign battle launches pass active retinue units through `BattleLaunchRequest`; `BattleSceneSpawner` deploys them near the player start with saved rank, XP, kills, and rank stat bonuses.
- Skirmish stays retinue-free by default.
- V1 death handling is permanent removal after the battle if a retinue unit dies. There is no wounded recovery timer in this slice.
- Retry launches refresh campaign retinue from the current save so dead/dismissed retinue units are not reintroduced from an older Results payload.
- Added deterministic retinue simulator profiles: no retinue, one Veteran Militia, one Veteran Ranger, mixed Veteran Militia plus Seasoned Ranger, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II.

Fresh Retinue Camp V1 verification completed on 2026-05-02:

```text
npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 18.5m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

### Unit Veterancy V1 - 2026-05-02

Goal: make ordinary battle units feel like they can become veterans without adding workers, enemy construction, new factions, diplomacy, crafting, maps, or broad army persistence.

What changed:

- Added data-driven unit veterancy rules in `src/game/data/unitVeterancy.ts`.
- Added battle-local unit veterancy state for runtime unit instances: unit instance ID, unit type ID, XP, rank, kills, damage dealt, survived-battle state, and rank-up state.
- Added four ranks: Recruit, Seasoned, Veteran, and Elite.
- Added rank bonuses, currently tuned to Seasoned +4% max HP/damage, Veteran +8% max HP/damage, and Elite +12% max HP/damage plus +1 armor.
- Units earn XP from actual damage dealt, kills using target XP value, and surviving a victorious battle.
- Rank bonuses apply immediately to player non-hero units during battle.
- Selected-unit UI now shows unit rank, unit XP, and kills.
- Rank-ups use the existing floating/status message path.
- Victory Results now show Notable Veterans, including ranked-up units, top surviving unit, kills, damage dealt, and campaign retinue recruitment when eligible.
- Normal units are still not automatically persisted; Retinue Camp V1 only saves selected campaign veterans under a small cap.
- Added pure tests for thresholds, XP rules, stat bonuses, rank-up behavior, and veteran Results summaries.
- Added Playwright coverage that grants deterministic unit XP, verifies the selected-unit panel, forces victory, and verifies the Results veteran summary.

Verification passed for this pass:

```text
npm test
PASS: 34 test files, 186 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 42 Playwright tests in 16.2m

npm run playtest:sim
PASS: 105 simulated runs across 35 campaign battle nodes
```

Next recommended work after Unit Veterancy plus Retinue: human-paced campaign balance and readability review with no retinue, one Veteran Militia, one Veteran Ranger, mixed retinue, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II.

### v0.2 Prototype Baseline Documentation - 2026-05-02

Goal: make the current Ascendant Realms prototype easy to understand, share, release-check, and continue from without adding gameplay, changing balance, or refactoring code.

What changed:

- Created `CHANGELOG.md` with the v0.2 prototype baseline summary: campaign/skirmish structure, hero progression, construction/training/upgrades, fog/minimap, Stronghold Tier I/II, reputation effects, randomized item affixes V1, automated playtest simulator, and current verification status.
- Created `RELEASE_CHECKLIST.md` with required release commands, expected v0.2 results, the known Vite chunk warning, optional preview check, and manual QA areas that remain outside automation.
- Updated `README.md` so setup, feature summary, known limitations, and next-feature prompts match the current baseline instead of older Tier I/early simulator status.
- Updated `ROADMAP.md` to name Retinue and Unit Veterancy V1 as the next feature milestone at the time of the v0.2 baseline; Retinue Camp V1 has since been implemented, so the next milestone is human-paced campaign balance/readability review.
- Marked this handoff as the v0.2 prototype baseline and corrected the published branch status to `main...origin/main` at `9cd3205e3d1be23ed967bd51f315bab3d39cc52e`.

Verification passed for this docs-only pass: `npm test` and `npm run build`.

### Campaign Reputation Choice Preview Recheck - 2026-05-02

Goal: make reputation consequences more visible on campaign choices without adding diplomacy, new factions, or a broader faction simulation.

What changed:

- Confirmed the existing rank/effect layer remains data-driven for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord.
- Kept the current compact effects: Common Folk Friendly Marcher Camp discount, Free Marches Friendly Stronghold Crown discount, Old Faith Friendly Chapel Aether bonus, and Ashen Covenant Hostile pressure on Ashen nodes.
- Updated choice reputation previews to show the resulting value and rank after the delta, for example `+8 Common Folk (to +33 Friendly)`.
- Added pure presentation coverage for threshold-crossing choice previews and updated e2e coverage for the visible preview text.
- Updated `DESIGN.md`, `BALANCE.md`, and `CONTENT_GUIDE.md` to document the resulting-rank preview rule.

Verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, and `npm run playtest:sim`.

### Stronghold Development Tier II Recheck - 2026-05-02

Goal: keep the existing compact Tier II Stronghold layer clear, optional, and fully verified without adding workers, enemy construction, diplomacy, maps, new factions, or new affix work.

What changed:

- Confirmed the current branch already has all five Tier II upgrades: Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II.
- Kept the existing clean implementation choices: 10% Militia/Ranger training speed, stacked earlier warning and Watchtower reach, a moderate resource package with Iron/Aether, +8% hero HP/Mana, and +1 starting Ranger on the scout path.
- Tightened Tier II UI descriptions so players can read future-battle effects and stacking behavior more easily.
- Left prerequisite, save normalization, launch-effect support, content validation, e2e coverage, and the `tier_two_quartermaster_path` simulator profile intact.
- Updated `DESIGN.md`, `BALANCE.md`, `CONTENT_GUIDE.md`, `ROADMAP.md`, and this handoff with the current Tier II framing and verification.

Verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, and `npm run playtest:sim`.

### Randomized Item Affixes V1

Goal: add modest item-instance variation while keeping inventory, reward tables, and equipment flow simple.

What changed:

- Added data-driven affix definitions and deterministic rarity/slot-filtered generation.
- Reward-generated item instances can now persist affixes, while old empty-affix saves remain valid.
- Equipped affixes contribute to hero stats through the existing equipment stat path.
- Results and Inventory UI show affix names, base stats, affix stats, total item stats, and equip preview deltas.
- Added unit/content/save/e2e coverage for generation rules, allowed-slot filtering, stat application, persistence, deterministic generation, and browser-visible affix UI.
- Full verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, and Browser Use preview smoke.

### Campaign Consequences And Reputation Hooks

Goal: make choices and faction reputation visible and mechanically meaningful without adding a full diplomacy layer.

What changed:

- Added rank calculation and active-effect helpers for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord.
- Added Common Folk Marcher Camp discounts, Free Marches Stronghold Crown discounts, Old Faith Chapel Aether bonuses, and Ashen Covenant Hostile enemy-pressure launches.
- Updated campaign choice cards to show costs, adjusted rewards, reputation changes, modifiers, and completion outcomes.
- Updated campaign reputation UI to show each faction's value/rank and currently active effects.
- Added unit/content/save/e2e coverage for ranks, discounts, hostile pressure, view-model output, persistence, and browser-visible previews.
- Full verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, and Browser Use preview smoke.

### Stronghold Development Tier II

Goal: add a compact second Stronghold tier that requires matching Tier I upgrades, creates campaign-strategy differences, and stays readable in UI/telemetry.

What changed:

- Added Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II as data-driven upgrades.
- Added Tier I prerequisite validation for all Tier II Stronghold upgrades.
- Applied Tier II effects at battle launch through existing systems: faster Militia/Ranger training, earlier enemy warning, larger Watchtower range, broader starter resources, hero HP/Mana bonus, and an extra Ranger.
- Expanded pure tests, save normalization tests, content validation, Playwright e2e, simulator profiles, generated telemetry, and design/balance/content docs.
- Full verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, and Browser Use preview smoke.

### Stronghold Tier I Telemetry Response

Goal: improve Stronghold Development V1 based on simulator telemetry so Watch Post I and Quartermaster Stores I have clear deterministic value, while keeping all Tier I upgrades modest and readable.

Files touched by this follow-up:

- `src/game/data/strongholdUpgrades.ts`
- `src/game/types/CampaignTypes.ts`
- `src/game/campaign/StrongholdPanel.ts`
- `src/game/data/validation/validateStronghold.ts`
- `src/game/ai/EnemyAIController.ts`
- `src/game/ai/EnemyAIController.test.ts`
- `src/game/battle/BattleSceneSpawner.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/TrainingSystem.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/core/StrongholdRules.test.ts`
- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `BALANCE.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Watch Post I old issue: +80 player-building vision was readable in fog but did not change deterministic simulator outcomes. It now keeps +80 building vision, makes the first enemy-wave gathering warning 25 seconds earlier, and gives player Watchtowers +10% attack range. Live enemy attack timing is unchanged.
- Quartermaster Stores I old issue: +50 Crowns/+30 Stone mostly increased floated resources. It now grants +60 Crowns, +40 Stone, +20 Iron, and +10 Aether at battle start, and the first player building in each battle completes 10% faster.
- Chapel Corner I now explicitly gives +5% hero maximum HP and +5% maximum Mana; UI copy and aggregation tests match the intended chapel fantasy.
- Ranger Paths I changed from +1 starting Ranger to Rangers training 10% faster, and its Iron cost moved from 45 to 40. A temporary full Ranger profile showed that stacking a free Ranger on top of Training Yard I made Ashen Outpost too easy, so the final version uses the safer training-speed effect.
- Training Yard I stayed mechanically unchanged; copy now uses explicit `+1 Militia`.
- Stronghold UI effect formatting now names enemy warning lead, Watchtower range, first-building construction speed, hero Mana, and unit training speed clearly.
- The simulator now covers six profiles: No Stronghold upgrades, Training Yard path, Defensive Watch Post path, Economy Quartermaster path, Chapel Corner path, and Ranger Paths path.
- Stronghold usefulness analysis now counts earlier first-wave warning, earlier Barracks completion, and earlier first trained unit as deterministic improvements, in addition to result/loss/duration/final-army outcomes.
- Regenerated telemetry is 90 runs across 30 profile-node summaries. Stronghold warnings are none. `too_hard` nodes are none. `too_easy` nodes are none. Ashen Outpost remains beatable.
- Updated `BALANCE.md` with old effect, new effect, reason, expected effect, and telemetry result for every Tier I upgrade.

Final telemetry profile records after this pass:

| Profile | Record | Improved runs | First purchase | Warnings |
| --- | ---: | ---: | --- | --- |
| No Stronghold upgrades | 9-3-3 | 0 | - | none |
| Training Yard path | 10-3-2 | 2 | ashen_outpost | none |
| Defensive Watch Post path | 9-3-3 | 9 | aether_well_ruins | none |
| Economy Quartermaster path | 9-3-3 | 6 | bandit_hillfort | none |
| Chapel Corner path | 9-2-4 | 1 | bandit_hillfort | none |
| Ranger Paths path | 10-3-2 | 2 | ashen_outpost | none |

Verification passed:

```text
npm test
PASS: 32 test files, 159 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 14.1m

npm run playtest:sim
PASS: 90 simulated runs across 30 profile-node summaries, no structural too-hard nodes, no too-easy nodes, no Stronghold warnings
```

### Automated Stronghold Playtest Profiles

Goal: update the deterministic playtest simulator so Stronghold Development is represented in baseline and upgraded campaign-battle paths without adding gameplay or changing live balance values.

Files touched by this follow-up:

- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `BALANCE.md`
- `tests/e2e/deep-flow.spec.ts`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added four simulator profiles: No Stronghold upgrades, Training Yard path, Defensive Watch Post path, and Economy Quartermaster path.
- Each profile now runs Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost through the existing Safe Beginner, Greedy Economy, and Fast Army scripts, for 60 deterministic runs total.
- Added a conservative simulated campaign bank for profile purchases. It buys each profile's target upgrade only when prior campaign-node rewards can afford it, then records purchase notes and the upgrades active for that node.
- Extended telemetry with Stronghold profile ID/name, target upgrades, purchased upgrades, purchase notes, starting unit counts after upgrade effects, starting resources after upgrade effects, battle result, duration, first-wave survival, resources floated, objective completion, and rewards.
- Updated analyzer output with per-profile records, first purchase node, improved-run counts, too-expensive warnings, useless-upgrade warnings, and overpowered/trivialization warnings.
- Regenerated `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json` as schema version 2.
- At that checkpoint, telemetry said no structural `too_hard` nodes; Training Yard I improved Ashen Outpost; Watch Post I and Quartermaster Stores I were flagged as not improving deterministic outcomes. This was superseded by the later Stronghold Tier I telemetry response above.
- Updated `BALANCE.md` with the early Stronghold simulator read and left live balance values unchanged.
- Hardened one existing Ashen objective e2e assertion to target the visible completed objectives panel after a full-suite stale-HUD-locator failure; the focused test and final full e2e run both pass.

Verification passed after this follow-up:

```text
npm test
PASS: 32 test files, 157 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 13.7m

npm run playtest:sim
PASS: 60 simulated runs across 20 profile-node summaries, no structural too-hard nodes
```

### Stronghold Development V1

Goal: add a small, data-driven persistent campaign-resource sink that improves future battles without turning the campaign layer into a city builder.

Files touched by this feature:

- `src/game/data/strongholdUpgrades.ts`
- `src/game/core/StrongholdRules.ts`
- `src/game/campaign/StrongholdPanel.ts`
- `src/game/types/CampaignTypes.ts`
- `src/game/save/SaveTypes.ts`
- `src/game/save/SaveDefaults.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/battle/BattleRuntime.ts`
- `src/game/battle/BattleSceneSpawner.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/CampaignMapScene.ts`
- `src/game/styles/campaign.css`
- `src/game/data/validation/validateStronghold.ts`
- `src/game/core/StrongholdRules.test.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `tests/e2e/deep-flow.spec.ts`
- `DESIGN.md`
- `BALANCE.md`
- `CONTENT_GUIDE.md`
- `README.md`
- `ROADMAP.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a Stronghold panel to the Campaign Map below the campaign bank.
- Added five data-driven upgrades: Training Yard I, Watch Post I, Quartermaster Stores I, Chapel Corner I, and Ranger Paths I.
- Purchases spend campaign Crowns, Stone, Iron, and Aether, record `resourcesSpent`, persist in `campaign.strongholdUpgradeRanks`, and cannot be repeated past `maxRank`.
- Save normalization now safely migrates legacy `strongholdUpgradeIds` arrays into rank 1 purchases and filters unknown upgrade IDs.
- Battle launches now convert purchased Stronghold upgrades into non-consumable launch modifiers.
- Implemented effects: extra starting Militia, extra starting Ranger, extra starting Crowns/Stone, +5% hero max HP, and +80 player-building vision radius.
- Added content validation for Stronghold upgrade IDs, costs, prerequisites, unit references, resource references, and effect values.
- Added pure tests for affordability, duplicate purchase prevention, prerequisites, resource spending, save/load normalization, and battle-launch effect aggregation.
- Added Playwright coverage that seeds campaign resources, buys Training Yard I, launches Border Village, and verifies the extra starting Militia.
- No workers, enemy construction, diplomacy, new maps, randomized affixes, or broad city-builder systems were added.

Verification already passed:

```text
npm test -- src/game/core/StrongholdRules.test.ts src/game/core/SaveSystem.test.ts src/game/battle/BattleRuntime.test.ts src/game/data/contentValidation.test.ts
PASS: 4 test files, 42 tests

npm test
PASS: 32 test files, 157 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line -g "stronghold upgrades"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 13.7m

npm run playtest:sim
PASS: 60 simulated runs across 20 profile-node summaries
```

### Ashen Outpost Landmark Fog Coverage

Goal: close the remaining automated Ashen Outpost landmark/readability gap without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/layout.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a Playwright layout test that launches Ashen Outpost on Normal so fog is active.
- Verifies the enemy Stronghold is hidden from the minimap before scouting.
- Uses test-only unit positioning to scout Burned Shrine, the west/south/north resource sites, all neutral camps, the enemy Stronghold, the enemy Barracks, and the gate Watchtower.
- Verifies each scouted landmark becomes visible in-world and appears on the minimap.
- Verifies each centered landmark is not covered by the top bar, hero panel, side panel, minimap, objectives panel, status line, or hint line.
- No gameplay logic, balance values, fog logic, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Minimap Marker And Ping Matrix Coverage

Goal: close the remaining automated minimap marker/ping matrix gap without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deep Playwright test that launches First Claim on Story to keep marker families visible for this matrix check.
- The test builds, completes, and selects Barracks, then sets a rally point through right-click input.
- The snapshot now verifies unit, building, capture-site, camp, and rally marker families.
- The snapshot now verifies player, enemy, and neutral marker teams.
- The test verifies concrete Command Hall, Barracks, Crown Shrine, and rally marker IDs.
- The test triggers live minimap pings for rally, enemy wave, Command Hall attack, and Crown Shrine attack.
- The rendered SVG is checked for site, building, unit, camp, rally, ping, and camera elements.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Ability Hotkey Feedback Coverage

Goal: close the remaining automated hero ability hotkey gap and fix confusing duplicate ability feedback.

Files touched by this follow-up:

- `src/game/systems/AbilitySystem.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/scenes/BattleScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deep Playwright test that seeds a level-4 Warlord with Rally Banner, Cleave, and War Cry unlocked.
- The test verifies HUD labels for ability slots `1`, `2`, and `3`, presses each key through the live keyboard path, and confirms mana spend, cooldown start, ally buffing, and enemy damage.
- Fixed successful ability feedback being overwritten by immediate duplicate cooldown retries.
- Ability SFX now plays only after successful casts.
- The expanded menu/hero-creation test has a 60s timeout because the two-class creation flow can exceed Playwright's default 35s timeout on this machine.

### Hero Creation And Direct Hero Click Selection Coverage

Goal: close two remaining player-control coverage gaps without changing runtime behavior.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The main menu/create/reset e2e flow now verifies Arcanist and Shepherd hero class selections persist to save. Warlord remains covered by the first campaign battle path.
- The battle HUD e2e flow now centers the camera on the live hero, click-selects the hero on the canvas, verifies the BattleScene selected entity is the hero, and verifies selected-hero HUD/order state before using `H`.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### First Enemy Wave Survival Coverage

Goal: close the remaining automated first-wave pressure gap without changing battle balance or player-facing behavior.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deep Playwright test that launches Border Village through the live campaign battle path.
- The test tracks a first Raider wave, puts it in melee range of the Command Hall, and ticks live combat to verify the base takes damage.
- The test verifies incoming-wave and Command Hall under-attack minimap pings.
- The test defeats the tracked wave, verifies `enemyWavesSurvived` increments to 1, confirms the tracked wave clears, and confirms the Command Hall remains alive.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Difficulty Selection, Pacing, And Fog Coverage

Goal: close the remaining automated coverage gap proving difficulty selection changes live battle behavior, not just setup UI state.

Files touched by this follow-up:

- `src/game/data/battlePacing.test.ts`
- `tests/e2e/smoke.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Battle-pacing unit coverage now verifies Story, Easy, Normal, and Hard remain ordered from forgiving to punishing across first attack delay, attack interval, wave size, enemy income multiplier, training interval, and fog defaults.
- Smoke e2e now launches Story and Normal skirmishes through the UI and verifies those choices reach BattleScene.
- The browser test verifies Story has fog off and one starting Raider, while Normal has fog on and a larger starting enemy roster.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Fog And Minimap Visibility Coverage

Goal: close the remaining automated coverage gap where fogged entities could be hidden in-world but still leak through minimap marker data.

Files touched by this follow-up:

- `tests/e2e/smoke.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The Border Village campaign smoke test now verifies fog is active in both the BattleScene and minimap snapshot.
- The same test verifies minimap fog cells are present.
- The test verifies unseen Stone Quarry, Quarry Imps, and hidden quarry neutral units are absent from minimap marker IDs before scouting.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Reward Keep-In-Inventory Clarity And Objective HUD Refresh

Goal: make the non-equip reward path explicit and remove a timing-sensitive secondary-objective HUD refresh gap found during full e2e.

Files touched by this follow-up:

- `src/game/results/ResultsEquipActions.ts`
- `src/game/results/ResultsRewardPanel.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `src/game/scenes/BattleScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Victory reward cards now show `Keep in Inventory` beside `Equip Now` for newly earned equippable rewards.
- Results status now confirms the item is kept in inventory and can be equipped later from Hero Inventory.
- Reward-card copy now says the item is already saved to inventory, making the non-equip path obvious.
- Unit coverage verifies the keep-in-inventory Results helper leaves equipment unchanged and returns a useful status message.
- Browser e2e verifies keeping a reward unequipped, opening Hero Inventory, seeing the reward marked `New`, and leaving the weapon slot empty.
- The live first-campaign reward test now verifies rewards are saved without being auto-equipped.
- Battle HUD secondary-objective state now refreshes immediately when an objective completes, which improves player feedback and removed a timing-sensitive Ashen objective e2e failure.
- No rewards, balance values, save format, map, faction, worker, affix, or strategic systems changed in this pass.

### Defeat Inventory Prep Action

Goal: make defeat prep match the advice shown on the Results screen without changing gameplay or reward persistence.

Files touched by this follow-up:

- `src/game/results/ResultsNavigation.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `src/game/scenes/HeroProgressionScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Defeat Results now include `Open Hero Inventory` alongside Retry and Campaign Map/Main Menu.
- Results inventory navigation now uses the saved starting hero on defeat, matching Retry and preventing unsaved live battle XP or skill points from appearing in prep.
- The progression screen now labels defeat prep as `Hero Inventory` instead of `Victory Progression`.
- Unit coverage verifies defeat inventory data uses the saved hero.
- Browser e2e clicks the defeat inventory action and verifies the inventory screen shows `Hero Inventory`, saved Level 1, and 0 skill points after synthetic unsaved battle XP.
- No gameplay, balance, save format, map, faction, worker, affix, or battle runtime logic changed in this pass.

### Defeat Results Saved Progress Clarity

Goal: make defeat Results honest about unsaved live battle XP after Browser Use found an Ashen Outpost Defeat screen showing a level jump that would not persist.

Files touched by this follow-up:

- `src/game/battle/BattleSceneResults.ts`
- `src/game/results/ResultsViewModel.ts`
- `src/game/results/ResultsObjectiveSummary.ts`
- `src/game/scenes/ResultsScene.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Defeat Results now display saved hero progress as the after-battle state, because defeat does not persist live battle XP or level-ups.
- The XP summary shows `XP saved: 0` on defeat and labels combat XP as `Battle XP earned ... (not saved)`.
- The top Hero Level badge, defeat tips, and current hero stat strip use the saved hero on defeat.
- The live BattleScene-to-Results handoff now sends saved hero progress for normal defeats, so the Results payload itself is honest.
- Unit coverage now verifies defeat view-model progress does not use unsaved live XP/skill points.
- Browser e2e now verifies defeat Results wording and saved-level display alongside Retry/Campaign actions.
- No gameplay, balance, save format, map, faction, worker, affix, or battle runtime logic changed in this pass.

### Ashen Fortress Readability And Minimap Palette Coverage

Goal: keep Ashen Outpost's objective HUD useful without covering the desktop fortress focus lane, and strengthen colorblind minimap coverage without changing gameplay.

Files touched by this follow-up:

- `src/game/styles/battle-hud.css`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/smoke.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Moved the desktop Objectives panel from the right side under the minimap to the upper-left under resources.
- Added a deterministic Ashen Outpost layout e2e guard that centers the camera on the enemy fortress and verifies the objectives panel does not cover the enemy Stronghold, enemy Barracks, or gate Watchtower focus points.
- Expanded the settings/accessibility e2e test to assert the rendered minimap SVG uses colorblind player/enemy colors (`#56b4e9` and `#d55e00`).
- Browser Use verified the rebuilt preview with Ashen Outpost launch, upper-right minimap camera movement, clear right-side lane, and 0 console errors.
- No gameplay, balance, save format, or battle runtime logic changed in this pass.

### Old Stone Road Live Completion Coverage

Goal: close the remaining browser-coverage gap for Old Stone Road post-victory progression and repeated reward protection without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a generic `startCampaignBattle(page, nodeId)` e2e helper and kept `startBorderVillageCampaignBattle` as a wrapper.
- Added a deterministic Playwright test that seeds a Border Village-complete campaign, launches Old Stone Road, forces a live BattleScene victory, and verifies Results plus saved campaign progression.
- The test confirms Old Stone Road first-clear campaign resources, node reward claim recording, and unlocks for Aether Well Ruins, Bandit Hillfort, Refugee Caravan, and Marcher Camp.
- The test returns to the campaign map and verifies completed Old Stone Road disables Start Battle, protecting against repeat live reward claims through the UI.
- Browser Use also visually sanity-checked Ashen Outpost launch and the player-facing Barracks placement feedback loop in the production preview.
- No gameplay, balance, save format, or runtime behavior changed in this pass.

### Alternate Campaign Choice Browser Coverage

Goal: close the remaining browser-coverage gap for early campaign choice branches without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deterministic Playwright test for alternate Refugee Caravan and Chapel of the Marches choices.
- Recruit Volunteers is now browser-tested as locked for level 1 heroes with the visible level requirement.
- Protect Them is now browser-tested for Crown cost, Scout's Bow, Inspired Militia, XP, completion, and reputation rewards.
- Recruit Volunteers is now browser-tested for Crown cost, Iron reward, Marcher Plate, Inspired Militia, XP, completion, and reputation changes.
- Pray for Strength is now browser-tested for Chapel completion, Aether, Blessed Road, XP, reputation, and Ashen Outpost unlock.
- No gameplay, balance, save format, or runtime behavior changed in this pass.

### Ashen Defeat Tip Browser Coverage

Goal: cover the objective-aware Ashen Outpost defeat advice in browser e2e, not only pure unit tests.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The synthetic Results e2e helper can now launch Results for a specific map, campaign node, difficulty, reward table, and completed secondary-objective state.
- A new Playwright test verifies Ashen Outpost defeat Results before Burned Shrine completion and after Burned Shrine completion.
- The test confirms the player-facing tips show Burned Shrine / gate Watchtower advice first, then Enemy Barracks / Stronghold advice after the shrine objective is complete.
- No gameplay, balance, save format, or runtime source behavior changed in this pass.

### Telemetry Verdict And Defeat Tip Refinement

Goal: keep the automated playtest bot useful without overclaiming difficulty failures, and give failed Ashen Outpost runs more actionable Results-screen guidance.

Files touched by this follow-up:

- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `src/game/core/ResultsFlow.ts`
- `src/game/core/ResultsFlow.test.ts`
- `src/game/results/ResultsRewardPanel.ts`
- `.gitignore`
- `BALANCE.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The playtest analyzer now separates structural `too_hard` failures from fair-opening strategy-spread cases.
- The regenerated telemetry report now says: Too hard none; Needs human review Aether Well Ruins, Bandit Hillfort, and Ashen Outpost.
- Suggested tuning now steers future work toward objective route, army timing, and final-assault attrition instead of automatically recommending first-attack/resource tuning.
- Ashen Outpost defeat tips now lead with Burned Shrine advice, then Enemy Barracks advice, then Outpost Captain advice as objectives are completed.
- `.preview-server.pid` was added to `.gitignore` for local Browser Use preview cleanup hygiene.

### Ashen Objective Readability And Live Effect

Goal: make Ashen Outpost's staged Burned Shrine route visible in live play, matching the automated telemetry assumption without adding a new campaign system.

Files touched by this follow-up:

- `src/game/battle/BattleSceneObjectives.ts`
- `src/game/battle/SecondaryObjectiveEffects.ts`
- `src/game/battle/SecondaryObjectiveEffects.test.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/systems/UISystem.ts`
- `src/game/ui/HUD.ts`
- `src/game/styles/battle-hud.css`
- `src/game/styles/responsive.css`
- `src/game/data/maps/ashenOutpost.ts`
- `tests/e2e/deep-flow.spec.ts`
- `BALANCE.md`
- `PLAYTEST_TELEMETRY.md`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Maps with secondary objectives now get a compact in-battle Objectives panel in the HUD.
- Ashen Outpost shows Capture the Burned Shrine, Destroy Enemy Barracks, and Defeat the Outpost Captain during live battle.
- Completing `capture_burned_shrine` on Ashen Outpost now weakens the enemy gate Watchtower by 45% max HP without destroying it.
- The Ashen objective description now tells the player that Burned Shrine weakens the gate Watchtower.
- The existing Ashen Outpost e2e test now verifies the objective HUD, the Watchtower weakening effect, and Results objective completion states.

### Enemy AI Config Alignment And Telemetry Balance Follow-Up

Goal: continue the deep systems/balance polish using automated telemetry rather than manual playtesting, while keeping changes numeric or dev-only where possible.

Files touched by this follow-up:

- `src/game/ai/EnemyAIController.ts`
- `src/game/ai/EnemyAIController.test.ts`
- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/data/maps/firstClaim.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/aiPersonalities.ts`
- `BALANCE.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Live enemy AI now uses map-level `scenario.enemyAI` values for initial attack delay, attack interval, wave size, train interval, expansion cadence, expansion squad size, and unit plan after personality modifiers.
- The scripted playtest driver now uses the same map-level enemy AI config, so telemetry matches live battle pacing instead of silently reading only global difficulty defaults.
- First Claim pacing was softened after that alignment: slightly slower training, later first attack, longer interval, and smaller wave target.
- Fortress Keeper and Hexfire Cult assault caps were trimmed because failures happened after first-wave survival.
- Ashen Outpost now starts with one extra Militia and one extra Ranger, one fewer enemy Watchtower, softer enemy economy/training/wave pressure, and smaller defense radius/squad values.
- The Ashen simulator model now treats Burned Shrine capture as a staged fortress-approach advantage. Safe Beginner beats Ashen; Greedy Economy and Fast Army still time out.
- `BALANCE.md` records the before/after values and the remaining risks.

### Battle Feedback, Auto-Attack, Fog, And Order-State Polish

Goal: address player-facing confusion from building placement, unclear research effects, inconsistent troop attack behavior, and fog/readability issues without adding new gameplay systems or changing balance.

Files touched by this pass:

- `src/game/ui/HUD.ts`
- `src/game/ui/UnitOrderSummary.ts`
- `src/game/ui/UnitOrderSummary.test.ts`
- `src/game/styles/battle-feedback.css`
- `src/game/styles/battle-hud.css`
- `src/game/styles/responsive.css`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/CombatSystem.ts`
- `src/game/systems/CombatSystem.test.ts`
- `src/game/systems/FogOfWarSystem.ts`
- `src/game/systems/FogOfWarSystem.test.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/battle/BattleSceneSpawner.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/smoke.spec.ts`

What changed:

- Building placement now has a clear HUD placement banner, stronger ghost/label feedback, cleaner cancellation state, and placement mode suppresses conflicting first-battle tutorial hints.
- Build, train, and research buttons now show concise descriptions and stat/effect summaries, including upgrade effects such as Infantry Weapons I.
- Player units stop and fight when enemies enter weapon range, idle units guard-chase nearby threats, and normal move orders do not pull troops into distant aggro.
- Selected heroes/troops now show an order strip: Guarding, Moving, Attack-moving, or Attacking; mixed unit selections summarize their orders.
- Fog updates more frequently, uses smaller cells, and applies exact source-distance checks for entity visibility so coarse visible cells no longer reveal entities by accident.
- Neutral camp labels are tracked and hidden by fog unless currently visible; unowned capture-site views require current vision, while player-owned sites remain visible.
- Fog debug now respects settings override and says when fog is disabled for the current battle.

No balance values, campaign rules, maps, factions, workers, or affixes were intentionally changed in this pass.

### GameTypes Domain Split

Goal: split the central cross-domain type file without changing runtime behavior, game logic, balance, or save format.

Files touched by this pass:

- `src/game/core/GameTypes.ts`
- `src/game/types/CampaignTypes.ts`
- `src/game/types/CombatTypes.ts`
- `src/game/types/EconomyTypes.ts`
- `src/game/types/HeroTypes.ts`
- `src/game/types/ItemTypes.ts`
- `src/game/types/MapTypes.ts`
- `src/game/types/UITypes.ts`
- `src/game/types/index.ts`
- `LLM_GAME_HANDOFF.md`

Shape after the split:

- `src/game/core/GameTypes.ts` is now a one-line compatibility barrel:

```ts
export type * from "../types";
```

- Existing `import type { ... } from "../core/GameTypes"` callers still work.
- The new `src/game/types/index.ts` re-exports all domain type modules.
- Cross-module dependencies use type-only imports so no runtime coupling was introduced.
- No direct gameplay/data imports were churned unless needed; this keeps the diff focused and lowers merge risk.

Domain grouping:

- `UITypes.ts`: shared primitives such as `Team`, `EntityKind`, `Position`, `Size`, and `VisibilityState`.
- `EconomyTypes.ts`: resource keys, bags, costs, and resource definitions.
- `CombatTypes.ts`: combat stats, unit/building definitions, factions, status effects, upgrades, pacing, difficulty, and AI personality definitions.
- `HeroTypes.ts`: hero stats, abilities, classes, origins, and skill-tree definitions.
- `ItemTypes.ts`: equipment slots, item definitions/instances, reward tables, battle rewards, duplicate conversions, and level-up summaries.
- `MapTypes.ts`: terrain, capture sites, spawns, battle objectives, scenarios, maps, and battle stats.
- `CampaignTypes.ts`: campaign modifiers, node choices, node rewards, node definitions, and node status.

### Automated Browser Coverage Expansion

Goal: expand deterministic Playwright coverage for implemented systems that were still under-tested without adding gameplay or changing balance.

Files touched by this pass:

- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`
- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/smoke.spec.ts`

Coverage added:

- Chapel of the Marches: Ask for Guidance scouts/unlocks without completing the node; Repair the Chapel spends resources, grants rewards, removes Angered Raiders, adds Local Support, and completes the node.
- Mystic Lodge and Acolyte: build Mystic Lodge, accelerate construction through existing scene systems, train Acolyte, and verify a live player Acolyte appears.
- Watchtower combat: build/complete Watchtower, reposition an existing enemy into range through Playwright, and verify enemy HP decreases.
- Research UI: verify an insufficient-resource lock reason, then research Infantry Weapons I, Reinforced Armor I, Ranger Training I, and Aether Study I through HUD buttons.
- Ashen Outpost: launch the campaign node, mark Burned Shrine / Enemy Barracks / Outpost Captain objectives complete through a test hook, force victory, and verify Results shows each objective as Completed.
- Settings/accessibility: persist floating text off, reduced motion, fog override disabled, and colorblind minimap palette; verify those settings reach battle state, fog is inactive, colorblind minimap snapshot is true, and forced damage does not spawn damage-number text while floating text is disabled.

No gameplay behavior, balance values, maps, factions, workers, or affixes were changed in this pass.

### First Real Human-Paced Campaign Balance Pass

Goal: make the first 30 minutes of the mini-campaign coherent, fair, and rewarding without adding systems, maps, factions, workers, enemy construction, affixes, or new strategic layers.

Files touched by this pass:

- `BALANCE.md`
- `src/game/core/FirstExperienceGuidance.ts`
- `src/game/data/aiPersonalities.ts`
- `src/game/data/battlePacing.ts`
- `src/game/data/campaignModifiers.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/rewards.ts`
- `src/game/ai/EnemyAIController.test.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/data/battlePacing.test.ts`
- `tests/e2e/deep-flow.spec.ts`

Core tuning:

- Story is now more clearly the learning/testing lane.
- Easy has more breathing room for Border Village and Old Stone Road.
- Normal remains the first serious baseline but spikes less abruptly.
- Raider Rush still pressures greedy play, but Old Stone Road should be readable.
- Fortress Keeper and Hexfire Cult were trimmed so identity comes more from composition/behavior than raw economy.
- Marcher Camp costs and usefulness were rebalanced.
- Refugee Caravan choices are more distinct and less dominated by Demand Tribute.
- Aether Well Ruins and Bandit Hillfort rewards are stronger for the first Normal branch.
- Chapel guidance now explicitly scouts without completing the node.
- Ashen Outpost player/enemy starting banks and enemy income were softened so fortress/towers/composition create the challenge.
- Reward weights now lean toward understandable early gear on First Claim and slightly more exciting branch/milestone drops later.

`BALANCE.md` now records before/after values, reasons, intended first-30-minute arc, and remaining human testing notes.

### Save System Split

The public import path still works:

```ts
import { SaveSystem } from "../core/SaveSystem";
```

But `src/game/core/SaveSystem.ts` is now a small compatibility re-export:

```ts
export * from "../save/SaveSystem";
```

Focused save modules added before the latest checkpoint:

- `src/game/save/SaveDefaults.ts`
- `src/game/save/SaveImportExport.ts`
- `src/game/save/SaveMigrations.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/save/SaveSystem.ts`

The facade still owns localStorage IO. Defaults, import/export, migrations, and normalization now live in focused modules. Tests in `src/game/core/SaveSystem.test.ts` cover the split and migration behavior.

### BattleScene System Wiring Split

`BattleScene` is still the live Phaser coordinator, but system construction/wiring has moved into:

- `src/game/battle/BattleSceneSystems.ts`

This helper owns constructor ordering and callback wiring between systems. `BattleScene` still owns Phaser lifecycle, runtime state, entity arrays, fog overlay rendering, rally markers, input callbacks, settings/audio integration, and update order.

### Battle HUD And Responsive Polish

The checkpoint also includes battle HUD and responsive updates:

- `src/game/styles/battle-hud.css`
- `src/game/styles/responsive.css`
- `src/game/ui/HUD.ts`
- `tests/e2e/layout.spec.ts`

The e2e suite verifies command-panel reachability and horizontal overflow across desktop, tablet, and mobile viewports.

## Current Scenes

Scene keys live in `src/game/core/SceneKeys.ts`.

- `BootScene`: loads manifests/assets and enters the menu.
- `MainMenuScene`: New Campaign, Continue Campaign, Skirmish, Hero Inventory, Asset Gallery, Settings, Reset Save, Credits / Info.
- `SettingsScene`: audio, accessibility, UI scale, fog override, minimap palette, and keyboard reference.
- `HeroCreationScene`: hero name/class/origin creation, then campaign or skirmish handoff.
- `CampaignMapScene`: campaign node map, hero summary, campaign bank, reputation, modifiers, selected node details, event choices, town services, and campaign battle launch.
- `SkirmishSetupScene`: map selection, hero summary, difficulty selection, enemy faction placeholder, AI personality selection, and start battle.
- `BattleScene`: main RTS runtime and Phaser entity orchestration.
- `ResultsScene`: victory/defeat summary, rewards, Equip Now, retry/return flow.
- `HeroProgressionScene`: inventory/equipment and skill allocation.
- `AssetGalleryScene`: local/manual asset inspection.

## Current Campaign Flow

Campaign data lives in `src/game/data/campaignNodes.ts`. Rules live in `src/game/core/CampaignRules.ts`.

The Border Marches mini-campaign has eight nodes:

| Node | Type | Difficulty | Map | Role |
| --- | --- | --- | --- | --- |
| `border_village` | Battle | Easy | First Claim | Tutorial battle: capture, build, train, defend, win. |
| `old_stone_road` | Battle | Easy | First Claim | First real battle with Raider Rush pressure. |
| `marcher_camp` | Town | Story | First Claim placeholder | First spending sink; reusable services and one-time item purchases. |
| `refugee_caravan` | Event | Story | First Claim placeholder | First consequence choice. |
| `aether_well_ruins` | Battle | Normal | Broken Ford | First Normal branch, Hexfire Cult pressure. |
| `bandit_hillfort` | Battle | Normal | Broken Ford | First Normal branch, Fortress Keeper pressure. |
| `chapel_of_the_marches` | Shrine | Story | First Claim placeholder | Spiritual/support event and route guidance. |
| `ashen_outpost` | Battle | Normal | Ashen Outpost | Milestone fortress assault. |

Unlock shape:

- Start: Border Village.
- Border Village -> Old Stone Road.
- Old Stone Road -> Aether Well Ruins, Bandit Hillfort, Refugee Caravan, Marcher Camp.
- Aether Well Ruins -> Chapel of the Marches.
- Bandit Hillfort + Chapel of the Marches -> Ashen Outpost.
- Chapel guidance can also reveal Refugee Caravan/Ashen Outpost without completing the chapel.

On campaign battle victory:

- `BattleRuntime` grants battle rewards.
- `ResultsScene` applies campaign node completion.
- One-time node rewards are applied if not already claimed.
- Campaign resources go to the persistent campaign bank.
- Unique duplicate item rewards convert into campaign resources.
- Hero and campaign state are saved.

On campaign battle defeat:

- Rewards are not granted.
- Campaign node completion is not granted.
- The player can retry or return to campaign map.

## Intended First-30-Minute Campaign Arc

1. Border Village teaches capture/build/train/defend/win with low pressure.
2. Old Stone Road asks the player to use Barracks and rally behavior against readable Raider Rush pressure.
3. Marcher Camp teaches spending the campaign bank on rest, volunteers, supplies, or early fixed gear.
4. Refugee Caravan teaches that choices trade resources, reputation, modifiers, and item rewards.
5. Aether Well Ruins or Bandit Hillfort introduces the first Normal branch with stronger rewards.
6. Chapel of the Marches supports the player before the milestone and now explains that guidance does not close the node.
7. Ashen Outpost is the current boss-style fortress map. It should feel fortified, not impossible.

Remaining human-feel checks:

- Fresh novice Border Village timing.
- Greedy vs clean Old Stone Road openings.
- Marcher Camp spend preference after two clears.
- Both Normal branches after typical early spending.
- Ashen Outpost with and without Chapel repair.

## Current Maps

Map data is split into per-map modules:

- `src/game/data/maps/firstClaim.ts`
- `src/game/data/maps/brokenFord.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/maps/index.ts`
- `src/game/data/maps.ts` remains a compatibility barrel export.

### First Claim

- ID: `first_claim`
- Size: 2400 x 1600
- Role: balanced tutorial skirmish.
- Player starts west; enemy starts east.
- Capture sites: Crown Shrine, Stone Quarry, Iron Vein, Aether Well.
- Reward table: `first_claim_rewards`.
- Used by Border Village and Old Stone Road.

### Broken Ford

- ID: `broken_ford`
- Size: 2600 x 1700
- Role: contested ruined river crossing.
- Player starts southwest; enemy starts northeast.
- Two main lanes and a risky central ford.
- Capture sites: Ford Toll, West Stone Cut, South Iron Cache, North Aether Spring.
- Reward table: `broken_ford_rewards`.
- Used by Aether Well Ruins and Bandit Hillfort.

### Ashen Outpost

- ID: `ashen_outpost`
- Size: 2600 x 1800
- Role: current mini-campaign milestone fortress assault.
- Player starts lower-left; enemy fortress starts upper-right.
- Capture sites: Burned Shrine, West Supply Pyre, South Iron Pit, North Stone Scar.
- Enemy fortress starts with Enemy Stronghold, Enemy Barracks, and one gate Watchtower.
- Reward table: `ashen_outpost_rewards`.
- Special objectives:
  - Destroy the Ashen Stronghold.
  - Capture the Burned Shrine; in live battle this weakens the gate Watchtower by 45% max HP without destroying it.
  - Destroy Enemy Barracks.
  - Defeat the Outpost Captain / Ashen Commander.

Ashen Outpost tuning after the balance pass:

- Player starting bank: 560 Crowns, 390 Stone, 235 Iron, 140 Aether.
- Player starts with 4 Militia and 2 Rangers.
- Enemy starting bank: 240 Crowns, 190 Stone, 135 Iron, 105 Aether.
- Enemy income every 5s: 80 Crowns, 40 Stone, 38 Iron, 30 Aether.
- Enemy AI map pacing: 7s train interval, 78s attack interval, 205s base first attack before Hexfire personality modifiers, 6-unit wave target, 5-unit defense squad, 460 defense radius.
- Burned Shrine is now both telemetry-modeled and live: capturing it softens the fortress approach by damaging the gate Watchtower and showing a status/minimap cue.

## Current Battle Pacing

Pacing data lives in `src/game/data/battlePacing.ts`.

Battle phases:

- Opening, 0:00 to 2:00: no base attacks.
- Expansion, 2:00 to 5:00: small base attacks allowed, no commander.
- Pressure, 5:00 to 8:00: mixed waves, no commander.
- Assault, 8:00 onward: larger waves and commander support allowed.

Difficulty presets after the balance pass:

| Difficulty | Enemy income | First attack | Attack interval | Wave target | Train interval | Commander | Fog |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Story | 0.45x | 300s | 100s | 2 | 9s | 840s | Off |
| Easy | 0.65x | 240s | 82s | 3 | 7s | 750s | On |
| Normal | 0.86x | 195s | 66s | 6 | 5.8s | 570s | On |
| Hard | 1.15x | 150s | 48s | 8 | 3.8s | 480s | On |

First-match tutorial protection:

- No first attack before 150s.
- If the player has not captured a site, first attack waits until 180s.
- Large attacks are capped to 2 units until the player has built production or 240s has passed.
- Enemy commander is excluded from the first attack and cannot join until assault pacing allows it.

Expected Normal waves:

- First wave around 3:15 baseline or around 3:30 on Hexfire Cult.
- First wave is usually 2 Raiders, or 2 Raiders plus 1 Hexer if the player has already built production.
- Mid waves, 5:00 to 8:00: 3 to 5 mixed Raiders, Hexers, and occasional Brutes.
- Late waves, 8:00 onward: Brute and Hexer support, commander after about 9:30 baseline.

## Current Enemy AI Behavior

Enemy AI lives in `src/game/ai/EnemyAIController.ts`.

The AI:

- Gains scaled income on a timer.
- Trains from completed enemy production buildings.
- Expands toward capture sites.
- Defends its base when player units approach.
- Selects phase-limited attack waves.
- Respects difficulty timing, wave size, income, training speed, expansion speed, and commander join timing.
- Sends alerts such as scouts moving, enemy forces gathering, and attack incoming.

AI personality data lives in `src/game/data/aiPersonalities.ts`.

Current personalities:

- Balanced Warlord: mixed expansion and attacks; Border Village default.
- Raider Rush: 0.86x first attack, 0.88x attack interval, 0.82x expansion interval, 0.88x income, mostly Raiders/Hexers, weaker late posture.
- Fortress Keeper: 1.22x first attack, 1.18x attack interval, 1.02x income, defensive reserves, protects captured sites, Brute-heavy later waves.
- Hexfire Cult: 1.08x first attack and attack interval, 1.02x income, more Hexers, burstier caster pressure, thinner frontline.

AI limitations:

- No enemy construction.
- No workers.
- No true scouting memory.
- No retreat logic.
- No counter-unit strategy.
- No pathfinding-aware threat routing.
- No long-term strategy beyond personality/timing/composition modifiers.

## Current Campaign Economy

Campaign resources are saved separately from temporary battle resources.

Bank resources:

- Crowns
- Stone
- Iron
- Aether

Starting battle resources for First Claim/Broken Ford come from `STARTING_PLAYER_RESOURCES`:

- 380 Crowns
- 255 Stone
- 140 Iron
- 75 Aether

Marcher Camp after the balance pass:

- Rest and Recovery: 30 Crowns for Well Rested, next-battle +20% hero max HP.
- Hire Volunteers: 50 Crowns for Inspired Militia, next battle starts with one extra Militia.
- Buy Supplies: 40 Crowns for 30 Stone, 18 Iron, 10 Aether.
- Emberglass Wand: 60 Crowns, one-time common weapon purchase.
- Marcher Plate: 75 Crowns and 15 Iron, one-time uncommon armor purchase.
- Green Chapel Icon: 85 Crowns and 16 Aether, one-time trinket purchase.

Refugee Caravan after the balance pass:

- Protect Them: costs 40 Crowns; grants 40 XP, Scout's Bow, Inspired Militia, +8 Common Folk, +2 Free Marches.
- Recruit Volunteers: requires hero level 2, costs 15 Crowns; grants 25 XP, 30 Iron, Marcher Plate, Inspired Militia, -4 Common Folk, +2 Free Marches.
- Demand Tribute: grants 65 Crowns, Angered Raiders, -8 Common Folk, -2 Free Marches, -3 Ashen Covenant.

Chapel of the Marches:

- Pray for Strength: grants 40 XP, 20 Aether, Blessed Road, +3 Old Faith, +1 Common Folk, completes the node.
- Repair the Chapel: costs 45 Crowns and 55 Stone; grants 35 Aether, Green Chapel Icon, Local Support, removes Angered Raiders, recovers hero placeholder, +2 Free Marches, +6 Old Faith, +2 Common Folk, completes the node.
- Ask for Guidance: grants 15 XP, unlocks/scouts Refugee Caravan and Ashen Outpost, +1 Old Faith, does not complete the node.

## Current Rewards And Items

Item data lives in `src/game/data/items.ts`. Item affixes live in `src/game/data/itemAffixes.ts`. Reward tables live in `src/game/data/rewards.ts`.

Current item model:

- Static catalog item definitions.
- Save inventory stores item instances with `instanceId`, `itemId`, `acquiredAt`, `source`, `affixes`, and optional `locked`/`favorite` flags.
- Equipment references item instance IDs where possible.
- Legacy saves with catalog IDs migrate into instances.
- Unique duplicate rewards convert into campaign resources.
- Non-unique duplicate rewards remain separate instances.
- Reward-generated instances can roll modest affixes by rarity and slot. Current affixes are Sturdy, Sharp, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's.
- Equipped item stats combine base item stats plus valid affix stat modifiers.

Reward tables support:

- Guaranteed item IDs.
- Weighted item pools.
- Deterministic item order for tests.
- Deterministic affix generation for tests.
- Map-specific item pool filters.
- First-clear-only and repeat-clear-only entries.
- Resource rewards.
- XP rewards.
- First-clear and repeat-clear bonuses.

Reward pacing after the balance pass:

- First Claim: one weighted item roll, modest resources, 35 base victory XP, 40 first-clear XP, starter resources, weighted toward starter/common gear.
- Broken Ford: one weighted item roll, stronger resources, 55 base victory XP, first-clear Fordbreaker Halberd, 65 first-clear XP, slightly improved rare/epic excitement.
- Ashen Outpost: one weighted item roll, high resources, 85 base victory XP, first-clear Ashbound Censer, 95 first-clear XP, and campaign node Oathbound Aegis.

Affix generation rules:

- Common: 0-1 affix.
- Uncommon: 1 affix.
- Rare: 1-2 affixes.
- Epic: 2 affixes.
- Legendary: 2-3 affixes.

## Current Hero System

Hero data lives in:

- `src/game/data/heroes.ts`
- `src/game/data/heroClasses.ts`
- `src/game/data/origins.ts`
- `src/game/data/abilities.ts`
- `src/game/data/skillTrees.ts`

Current hero classes:

- Warlord
- Arcanist
- Shepherd

Current origins:

- Exiled Noble
- Temple Orphan
- Wildland Raider

Skill trees:

- Combat: damage, HP, Warlord Cleave.
- Magic: mana, armor, Arcanist Arcane Burst/Blink, Shepherd Sanctify Ground.
- Leadership: command, faith, Warlord War Cry, Shepherd Blessing.

Battle hero stats are recalculated from class base stats, origin modifiers, level bonuses, skill ranks, and equipped item stat modifiers, including valid affix modifiers on equipped item instances.

## Current Factions

Faction data lives in `src/game/data/factions.ts`.

Current factions:

- `free_marches`: player baseline faction; balanced economy, reliable Militia/Rangers/Acolytes, defensive Watchtower, leadership and reputation hooks.
- `ashen_covenant`: main enemy faction; aggressive, cheaper early Raiders, harder-hitting but less durable units except Brutes, magic pressure through Hexers, burn/status pressure, and Ashen AI personality preferences.
- `sylvan_concord`: future placeholder faction with early identity hooks and item origins, not yet playable or fully implemented.

Implemented Ashen mechanics:

- `hexfire_burn`: damage over time with floating feedback.
- `ashen_fury`: low-health damage pressure trait.
- `smoke_march`: wave movement-speed modifier for matching Ashen units.

## Current Construction, Training, Research, And Rally

Building data lives in `src/game/data/buildings.ts`.

Player buildings:

- Command Hall
- Barracks
- Mystic Lodge
- Watchtower

Enemy buildings:

- Enemy Stronghold
- Enemy Barracks

Construction times:

- Command Hall: 0s.
- Barracks: 25s.
- Mystic Lodge: 30s.
- Watchtower: 20s.
- Enemy prebuilt structures: 0s.

Construction behavior:

- Player placement uses a ghost preview.
- Resources are paid on final placement.
- Under-construction buildings appear at partial HP and cannot train/research/attack.
- Construction completes automatically.
- There are no workers.

Training:

- Only completed production buildings train.
- Resources are paid when queued.
- Canceling a queued or active unit refunds the full paid cost for now.
- Rally points can be set by right-clicking ground with a rally-capable building selected.

Research:

- Research pays up front and completes after `researchTimeSeconds`.
- Current upgrades: Infantry Weapons I, Ranger Training I, Reinforced Armor I, Aether Study I, Ember Blades placeholder trait.

## Current UI And CSS

`src/game/styles/ui.css` is the import hub. Domain CSS files:

- `asset-gallery.css`
- `base.css`
- `battle-feedback.css`
- `battle-hud.css`
- `campaign.css`
- `forms.css`
- `inventory.css`
- `main-menu.css`
- `minimap.css`
- `responsive.css`
- `results.css`
- `settings.css`

Recent HUD/responsive behavior:

- Battle HUD panels are visually tighter.
- Hero-selected state uses a compact command panel.
- Building command rows were simplified.
- Mobile/tablet rules keep hero/building command panels inside the viewport.
- E2E verifies command reachability and horizontal overflow.

## Current Save Architecture

Current save modules:

- `src/game/core/SaveSystem.ts`: compatibility re-export.
- `src/game/save/SaveDefaults.ts`: versions and fallback/current save creation.
- `src/game/save/SaveImportExport.ts`: JSON parse/stringify boundary.
- `src/game/save/SaveMigrations.ts`: legacy migration.
- `src/game/save/SaveNormalization.ts`: hero/campaign shape checks and normalization.
- `src/game/save/SaveSystem.ts`: public localStorage facade.
- `src/game/save/SaveTypes.ts`: save-facing types.

Current save version is V2. Save normalization protects:

- Settings-only saves.
- Legacy catalog-ID inventory/equipment.
- Item instance migration.
- Campaign resource and resource-spent bags.
- Choice IDs.
- Town service claimed IDs and use counts.
- Active modifier IDs.
- Completed/unlocked/locked/node-reward IDs.
- Negative numeric resource/stat clamping where appropriate.

## Current Helper Architecture

### Types

`src/game/core/GameTypes.ts` is now a compatibility barrel for focused type modules in `src/game/types/`:

- `CampaignTypes.ts`
- `CombatTypes.ts`
- `EconomyTypes.ts`
- `HeroTypes.ts`
- `ItemTypes.ts`
- `MapTypes.ts`
- `UITypes.ts`
- `index.ts`

Prefer importing new type-only dependencies from `src/game/types` or the focused module when touching nearby code, but existing `core/GameTypes` imports are intentionally preserved for compatibility.

### Results

`ResultsScene` is now a coordinator. Helper modules live in `src/game/results/`:

- `ResultsCampaignFlow.ts`
- `ResultsEquipActions.ts`
- `ResultsFormatting.ts`
- `ResultsNavigation.ts`
- `ResultsObjectiveSummary.ts`
- `ResultsRewardPanel.ts`
- `ResultsTypes.ts`
- `ResultsViewModel.ts`

### Campaign Map

`CampaignMapScene` delegates view-model creation and panel rendering to helpers in `src/game/campaign/`:

- `CampaignChoicePanel.ts`
- `CampaignMapViewModel.ts`
- `CampaignNavigation.ts`
- `CampaignNodePanel.ts`
- `CampaignPresentationTypes.ts`
- `CampaignResourcePanel.ts`
- `CampaignTownServicesPanel.ts`

### Hero Progression

`HeroProgressionScene` delegates inventory, equipment, skill tree, comparison, and stat presentation to helpers in `src/game/progression/`:

- `EquipmentPanel.ts`
- `HeroProgressionViewModel.ts`
- `HeroStatsPanel.ts`
- `InventoryPanel.ts`
- `ItemComparison.ts`
- `SkillTreePanel.ts`

### Battle

Battle helpers live in `src/game/battle/`:

- `BattleLaunchRequest.ts`
- `BattleRuntime.ts`
- `BattleSceneAlerts.ts`
- `BattleSceneMapRenderer.ts`
- `BattleSceneObjectives.ts`
- `SecondaryObjectiveEffects.ts`
- `BattleSceneResults.ts`
- `BattleSceneSnapshots.ts`
- `BattleSceneSpawner.ts`
- `BattleSceneSystems.ts`

Several battle helpers changed during earlier checkpoint work and the current uncommitted Retinue/Unit Veterancy stack. Preserve future dirty edits unless the user explicitly asks for a reset or revert.

## Current Tests

Latest verified suite status, refreshed after Unit Veterancy V1, Retinue Camp V1, the retinue telemetry balance pass, and the HeroProgressionRules refactor:

- `npm test`: passed, 35 test files, 194 tests.
- `npm run build`: passed with the known Vite large-chunk warning, which is not a failure.
- `npm run test:e2e -- --reporter=line`: passed, 43 Playwright tests in 18.0m. Use a long timeout.
- `npm run playtest:sim`: passed, 180 simulated runs across 60 campaign battle node/profile summaries, with no structural `too_hard` nodes, no `too_easy` nodes, Ashen Outpost beatable, and no Stronghold warnings.

Current unit/pure test files:

- `src/game/ai/EnemyAIController.test.ts`
- `src/game/battle/BattleLaunchRequest.test.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/battle/SecondaryObjectiveEffects.test.ts`
- `src/game/campaign/CampaignMapViewModel.test.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/core/FirstExperienceGuidance.test.ts`
- `src/game/core/HeroProgressionRules.test.ts`
- `src/game/core/ResultsFlow.test.ts`
- `src/game/core/RetinueRules.test.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/core/StrongholdRules.test.ts`
- `src/game/data/aiPersonalities.test.ts`
- `src/game/data/battlePacing.test.ts`
- `src/game/data/campaignModifiers.test.ts`
- `src/game/data/contentValidation.test.ts`
- `src/game/data/itemAffixes.test.ts`
- `src/game/data/unitVeterancy.test.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `src/game/progression/ItemComparison.test.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `src/game/systems/AudioManager.test.ts`
- `src/game/systems/BuildingPlacementRules.test.ts`
- `src/game/systems/CombatSystem.test.ts`
- `src/game/systems/FogOfWarSystem.test.ts`
- `src/game/systems/PathfindingGrid.test.ts`
- `src/game/systems/PrerequisiteSystem.test.ts`
- `src/game/systems/RallyPointSystem.test.ts`
- `src/game/systems/StatusEffectSystem.test.ts`
- `src/game/systems/UpgradeEffects.test.ts`
- `src/game/systems/UpgradeSystem.test.ts`
- `src/game/ui/MinimapView.test.ts`
- `src/game/ui/UnitOrderSummary.test.ts`
- `src/game/ui/hudPanels/HudFormatting.test.ts`

Current e2e files:

- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/smoke.spec.ts`

Browser-level tests currently cover:

- Main menu boot.
- Settings persistence, including floating text, reduced motion, fog override, colorblind minimap persistence, and rendered player/enemy colorblind minimap colors.
- Hero creation.
- Campaign map and locked-node behavior.
- Reputation rank/effect display, active reputation consequences, discounted Marcher Camp/Stronghold previews, and event-choice reputation/modifier previews.
- Stronghold panel purchase flow, resource spending, save persistence, prerequisite lock text, and Quartermaster Stores I/II battle-launch resources.
- Border Village battle launch.
- First enemy wave pressure, Command Hall damage alerts, and wave-survival bookkeeping.
- Campaign choices, including Refugee Caravan Demand/Protect/Recruit, Chapel guidance/repair/pray, and Marcher Camp services/purchases.
- Inventory equip/unequip, including affix display and equipped affix stat contribution.
- Skill spending.
- Results Equip Now, including deterministic affixed reward display and affix persistence after equip.
- Unit Veterancy selected-panel rank display, victory Results Notable Veterans, retinue recruitment, save/load persistence, campaign launch retinue deployment, saved rank bonus preservation, and permanent retinue death removal.
- Defeat tips.
- Defeat Results saved-progress display and unsaved battle XP labeling.
- Ashen Outpost defeat tips for Burned Shrine and Enemy Barracks recovery sequencing.
- Skirmish launches for all maps and AI personalities.
- Skirmish difficulty selection changes live battle fog and starting enemy pressure between Story and Normal.
- Minimap click handling.
- Minimap marker matrix for units, buildings, capture sites, neutral camps, rally markers, camera rectangle, and rally/wave/base/resource pings.
- Fog toggle.
- Hero ability hotkeys `1`, `2`, and `3`, including Warlord Rally Banner, Cleave, and War Cry effects.
- Fog visibility regression for distant neutral camp labels, neutral units, unowned capture sites, minimap fog cells, and hidden minimap marker IDs.
- Building placement cancellation feedback.
- Build Barracks placement ghost near Command Hall.
- Selected-unit order summary for Guarding and Moving states.
- Mystic Lodge construction and Acolyte training.
- Watchtower combat damage against an enemy in range.
- Research UI lock/researched states for Infantry Weapons I, Reinforced Armor I, Ranger Training I, and Aether Study I.
- First-battle loop: capture, Barracks construction, Militia training, rally point, accelerated result.
- Old Stone Road live campaign victory, next-layer unlocks, first-clear campaign resource reward, and completed-node Start Battle disablement.
- Ashen Outpost objective HUD, Burned Shrine gate-Watchtower weakening, and special objective Results states for Burned Shrine, Enemy Barracks, and Outpost Captain.
- Ashen Outpost desktop objective-panel placement avoiding the enemy stronghold/barracks/gate-Watchtower focus area.
- Ashen Outpost landmark scoutability under Normal fog, including resource sites, neutral camps, fortress buildings, minimap markers, and major HUD-overlap guards.
- Live objective resolution into Results.
- Responsive layout reachability and overflow across desktop, tablet, and mobile.

Full real-time human-style victory from first click to enemy base kill remains manual QA.

### Crown Shrine Selected-Forces Copy Polish

Goal: make the Crown Shrine retake guide accurate for partial combat selections. Browser Use showed that after selecting only Aster, the guide still said to right-click with `hero and troops`.

Files changed in this pass:

- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneAlerts.test.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The combat-selected Crown Shrine retake prompt now says `Right-click the Crown Shrine with your selected forces.`.
- This wording stays correct for the opening full-squad selection, hero-only selection, or any selected player unit.
- Added focused unit coverage for the hero-only retake state.

Verification in this pass:

- `npm test -- --run src/game/battle/BattleSceneAlerts.test.ts`: passed, 1 file and 4 tests.
- `npm test`: passed, 30 test files and 145 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- Browser Use: fresh First Claim skirmish starts with `4 units selected` and the selected-forces Crown Shrine prompt.

### Crown Shrine Retake Selection Hint Polish

Goal: prevent the first-battle guide from asking for a combat move while a production building is selected. Browser Use showed that when the enemy recaptured the Crown Shrine and the Barracks was selected, right-clicking the Shrine set the Barracks rally point instead of moving the army.

Files changed in this pass:

- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneAlerts.test.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- `firstBattleTutorialHint` now detects whether a player combat entity is selected before giving the Crown Shrine retake move prompt.
- If no hero or player unit is selected while the Crown Shrine is not player-owned, the guide says `Select your army, then right-click the Crown Shrine.`.
- If the hero or a player unit is selected, the follow-up selected-forces copy pass now uses `Right-click the Crown Shrine with your selected forces.`.
- Added focused unit coverage for the building-selected retake state.

Verification in this pass:

- `npm test -- --run src/game/battle/BattleSceneAlerts.test.ts`: passed, 1 file and 3 tests.
- `npm test`: passed, 30 test files and 144 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- Browser Use: with Command Hall selected and Crown Shrine not owned, the guide asks for army selection; combat-selected retake wording was tightened in the follow-up selected-forces copy pass.

### First Battle Construction Hint Polish

Goal: keep the first-battle guide synchronized after the player places their first Barracks. Browser Use showed that immediately after placing the Barracks, the construction site became selected but the guide could briefly step backward to `Select your Command Hall.`.

Files changed in this pass:

- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneAlerts.test.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- `firstBattleTutorialHint` now checks for an in-progress player Barracks before requiring Command Hall selection.
- While the unfinished Barracks is selected, the guide stays on `Barracks is under construction. Hold near your base until it completes.`.
- Added focused unit coverage for the in-progress Barracks hint and the earlier no-production Command Hall prompt.

Verification in this pass:

- `npm test -- --run src/game/battle/BattleSceneAlerts.test.ts`: passed, 1 file and 2 tests.
- `npm test`: passed, 30 test files and 143 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- `git diff --check`: no whitespace errors; existing `.gitignore` CRLF warning only.
- Browser Use: First Claim Easy replayed through capture, Command Hall selection, Barracks placement, construction completion, Militia training, and the first-defense prompt.

### First Claim Neutral Camp Opening Polish

Goal: preserve the First Claim tutorial capture as a clean first beat after full-squad opening selection. Browser Use showed that moving the selected starting squad to the Crown Shrine could pull the nearby Sunken Road Pack into combat before the player had built production.

Files changed in this pass:

- `src/game/data/maps/firstClaim.ts`
- `src/game/data/contentValidation.test.ts`
- `BALANCE.md`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Moved `sunken_road_pack` from `(710, 1110)` to `(650, 1240)`.
- Added a content-validation test that keeps the tutorial Crown Shrine farther from that camp than capture radius plus normal aggro and opening formation spacing.
- No enemy attack timing, unit stats, rewards, campaign economy, or new systems changed.

Verification in this pass:

- `npm test -- --run src/game/data/contentValidation.test.ts`: passed, 1 file and 6 tests.
- `npm test`: passed, 29 test files and 141 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"`: passed, 1 focused Playwright test.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- Browser Use: First Claim Easy opening captured Crown Shrine cleanly with the neutral camp visible lower on the map and not pulled into combat.

### Opening Squad Selection Polish

Goal: close a small first-click onboarding mismatch found in Browser Use. The first battle hint told the player to right-click the Crown Shrine with hero and troops, but battle startup selected only the hero, so the first command sent Aster alone.

Files changed in this pass:

- `src/game/scenes/BattleScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Battle startup now selects every alive starting player unit after the scene systems are created.
- The initial First Claim HUD now visibly starts at `4 units selected` for the default Warlord skirmish: Aster, two Militia, and Ranger.
- The existing battle HUD Playwright test now asserts that the opening selection includes the hero and all starting player units before it continues into click-selection, minimap, fog, and building-placement coverage.
- Browser Use rechecked First Claim Easy from Skirmish, without resetting or replacing the user's campaign save.

Verification in this pass:

- `npm test`: passed, 29 test files and 140 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"`: passed, 1 focused Playwright test.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.

## Current Known Bugs

No deterministic runtime bug is currently reproduced by unit tests, build, or Playwright e2e.

Known issues and caveats:

- Vite reports a large bundle chunk warning.
- Full e2e is slow and can exceed short shell-tool timeouts.
- Full human-paced battle victory/defeat through normal input remains manual.
- Balance remains prototype-level and needs human playtesting after each larger AI/map/economy change.
- Automated Stronghold telemetry currently has no too-expensive, useless-upgrade, overpowered, too-easy, or structural too-hard warnings after the Tier II pass.
- `QA_RUN.md` contains earlier manual QA notes; latest automated verification counts in this handoff are newer.

## Current Known Limitations

- Campaign is a mini-campaign skeleton, not a full strategic layer.
- Stronghold Development is a compact two-tier persistent-upgrade slice, not a broad city-builder.
- Reputation hooks are compact rank/effect rules, not a diplomacy screen or full faction simulation.
- No broad vendor economy, mercenaries, repairs, diplomacy, invasions, or world simulation beyond Marcher Camp, Stronghold upgrades, reputation hooks, and compact event choices.
- Event choices are compact cards, not a dialogue engine.
- `recoverHero` is a placeholder reward effect.
- Item affixes are V1 stat packages only; crafting, durability, affix rerolling, proc chains, and full item-icon presentation are not implemented.
- Relic slot is typed but not fully used.
- Music is not implemented; `musicVolume` is reserved.
- `screenShakeEnabled` is saved but no active screen shake system currently gates it.
- Fog of war is grid-based and not blocker-aware.
- Minimap has no drag-to-pan or last-known enemy memory.
- Enemy AI is paced but simple; it does not construct, retreat, scout intelligently, or adapt composition.
- Player construction is automatic; no workers.
- Pathfinding uses A* waypoints, but it is not formation-aware, flow-field based, or fully dynamic around every temporary obstruction.
- Scene UI is DOM-heavy and still duplicated across several scenes.

## Large Or Risky Files

Current rough line counts:

- `src/game/playtest/ScriptedBattlePlaytest.ts`: 1806 lines.
- `src/game/scenes/BattleScene.ts`: 934 lines.
- `src/game/core/SaveSystem.test.ts`: 469 lines.
- `src/game/core/CampaignRules.ts`: 420 lines.
- `src/game/systems/PathfindingGrid.ts`: 354 lines.
- `src/game/battle/BattleSceneSystems.ts`: 347 lines.
- `src/game/ai/EnemyAIController.ts`: 318 lines.
- `src/game/scenes/CampaignMapScene.ts`: 309 lines.
- `src/game/data/campaignNodes.ts`: 309 lines.
- `src/game/data/aiPersonalities.ts`: 279 lines.
- `src/game/data/strongholdUpgrades.ts`: 272 lines.
- `src/game/scenes/HeroProgressionScene.ts`: 268 lines.
- `src/game/types/CombatTypes.ts`: 249 lines.
- `src/game/core/progression/ItemRewardRules.ts`: 212 lines.
- `src/game/data/itemAffixes.ts`: 182 lines.
- `src/game/types/CampaignTypes.ts`: 145 lines.
- `src/game/types/MapTypes.ts`: 121 lines.
- `src/game/core/StrongholdRules.ts`: 120 lines.
- `src/game/core/progression/HeroStatRules.ts`: 107 lines.
- `src/game/campaign/StrongholdPanel.ts`: 105 lines.
- `src/game/core/progression/SkillRules.ts`: 98 lines.
- `src/game/types/ItemTypes.ts`: 90 lines.
- `src/game/core/progression/EquipmentStatRules.ts`: 75 lines.
- `src/game/ui/HUD.ts`: 72 lines.
- `src/game/data/validation/validateContent.ts`: 71 lines.
- `src/game/core/progression/AffixRules.ts`: 37 lines.
- `src/game/core/progression/LevelingRules.ts`: 29 lines.
- `src/game/core/progression/DuplicateRewardRules.ts`: 18 lines.
- `src/game/core/progression/index.ts`: 7 lines.
- `src/game/core/HeroProgressionRules.ts`: 1 line.
- `src/game/core/GameTypes.ts`: 1 line.
- `src/game/data/contentValidation.ts`: 1 line.

Risk notes:

- `BattleScene` is smaller than before but still the highest live-scene integration risk.
- `ScriptedBattlePlaytest.ts` is now the largest file because it carries deterministic strategies, Stronghold profile planning, telemetry rendering, and analyzer logic; keep future simulator additions focused and tested.
- `GameTypes.ts` is no longer a large risk file; it is a 1-line compatibility barrel over focused modules.
- `HeroProgressionRules.ts` is no longer a large risk file; it is a 1-line compatibility barrel over focused modules in `src/game/core/progression/`.
- `ItemRewardRules.ts`, `HeroStatRules.ts`, `SkillRules.ts`, `EquipmentStatRules.ts`, `AffixRules.ts`, `DuplicateRewardRules.ts`, and `LevelingRules.ts` now split the hero progression domain. Keep formulas stable unless the user explicitly asks for tuning.
- `CampaignRules.ts` joins node completion, costs/rewards, modifiers, town services, and reward claims.
- `HUD.ts` has been reduced to a facade over focused HUD panel modules; selectors and behavior should still be treated as fragile.
- `contentValidation.ts` is now a compatibility export over focused validators; the validation domain remains important even though the old catch-all file is gone.
- `StrongholdRules`, `strongholdUpgrades`, `StrongholdPanel`, and the Stronghold hooks in AI/building/training systems are covered, but should stay small until human campaign-economy feel is checked.
- `reputation.ts`, `CampaignChoicePanel`, `CampaignResourcePanel`, and the reputation hooks inside `CampaignRules`, `StrongholdRules`, and `CampaignMapScene` are covered, but should remain a compact consequence layer rather than growing into diplomacy.
- `itemAffixes.ts`, `progression/AffixRules.ts`, `progression/ItemRewardRules.ts`, `ItemComparison`, `InventoryPanel`, and `ResultsRewardPanel` now form the compact affix path; keep future affix work data-driven and modest unless the user explicitly asks for deeper loot systems.

## Most Fragile Systems

1. `BattleScene` integration: live scene lifecycle, system update order, input mode overlap, fog/minimap/rally wiring.
2. Results and campaign reward saving: battle rewards, node rewards, affix generation/display, Equip Now, first-clear, duplicate conversion, campaign bank, and the `progression/ItemRewardRules.ts` handoff into Results.
3. Save migration/normalization: old localStorage saves, item-instance migration, settings-only saves, campaign state.
4. Campaign choices and town services: pure rules are covered, but UI crowding can regress.
5. Fog/minimap visibility: filters rendering and minimap markers.
6. Input modes: selection, move/attack, rally, placement, minimap, abilities, fog debug, Esc.
7. Enemy AI pacing: data-driven but dependent on milestone gates and phase math.
8. DOM CSS: split by domain but global selectors can still collide.
9. Asset fallback chain: optional manual/final/placeholder assets need validation after art changes.

## Manual QA Checklist

Run this before a checkpoint commit after gameplay/UI changes:

1. Start dev server and open `http://127.0.0.1:5173/`.
2. Main menu appears.
3. Settings opens and persists audio, UI scale, reduced motion, floating text, fog override, and minimap palette.
4. Reset Save works in an isolated test context before using on a real save.
5. New Campaign opens hero creation when no playable save exists.
6. Create Warlord, Arcanist, and Shepherd at least once.
7. Campaign map opens after creation.
8. Campaign bank, reputation, active modifiers, and Retinue Camp display. On a disposable seeded save, verify retinue capacity, rank/type text, and Dismiss behavior.
9. Stronghold panel displays resources, purchased/locked/available states, costs, effects, and purchase buttons.
10. Buy Quartermaster Stores I and II from a resource-seeded campaign and verify the next launched battle starts with the Tier II resource package.
11. Border Village is available and locked nodes cannot start.
12. Border Village launches First Claim.
13. Select hero with click and `H`; select a ranked non-hero unit during a seeded run and verify rank/XP/kills display.
14. Move units with right-click.
15. Capture Crown Shrine.
16. Select Command Hall.
17. Place Barracks and verify valid/invalid placement reasons.
18. Barracks appears under construction and cannot train until complete.
19. Completed Barracks trains Militia and Ranger.
20. Queue progress displays and cancel/refund works.
21. Set Barracks rally point and verify marker plus trained-unit movement.
22. Build Mystic Lodge and train Acolyte.
23. Build Watchtower and verify it attacks.
24. Research all current upgrades through UI.
25. Verify locked train/upgrade buttons show reasons.
26. Use hero ability hotkeys.
27. Verify audio cues with human ears.
28. Verify floating text and reduced motion visually.
29. Verify fog hides unexplored/undetected entities.
30. Press `F` on fog-enabled difficulty and verify fog debug.
31. Verify settings fog override changes battle fog behavior.
32. Verify minimap units/buildings/sites/camera/rally/pings and colorblind palette.
33. Survive or lose the first wave through normal play.
34. Defeat screen shows contextual tips and retry/campaign return.
35. Victory screen shows map, difficulty, time, XP, level progress, battle rewards, affixes, node rewards, campaign bank, Notable Veterans, and Retinue add/skip controls when eligible.
36. Equip Now changes stats, including affix stats, and persists after leaving Results.
37. Campaign victory completes Border Village and unlocks Old Stone Road; if a retinue unit was added, the next campaign battle deploys it near the hero/Command Hall with saved rank.
38. Complete Old Stone Road and verify Aether Well Ruins, Bandit Hillfort, Marcher Camp, and Refugee Caravan unlock.
39. Marcher Camp repeatable services, once-only purchases, costs, locked reasons, and save persistence work.
40. Refugee Caravan choices and reputation/resource effects work.
41. Chapel choices work, especially non-completing guidance.
42. Campaign node rewards cannot be claimed repeatedly.
43. Skirmish Setup opens separately.
44. First Claim, Broken Ford, and Ashen Outpost launch from skirmish.
45. Ashen Outpost shows fortress layout, Burned Shrine, side resources, neutral camps, and defensive towers.
46. Ashen Outpost Results show special objective completion states.
47. Difficulty selection changes pacing/fog behavior.
48. AI personality selection changes displayed style and launches without errors.
49. Hero Inventory opens from main menu.
50. Equipping/unequipping items changes hero stats, including affixed item instances.
51. Skill point spending persists.
52. Asset Gallery opens.
53. Browser console has no new hard errors.
54. Production build preview boots if doing release-style QA.

## Recommended Next Priorities

1. Next feature milestone: human-paced campaign balance/readability review with Retinue Camp V1 included. Test no retinue, one Veteran Militia, one Veteran Ranger, mixed Veteran Militia plus Seasoned Ranger, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II.
2. Do a human-paced Border Village and Old Stone Road playtest on Easy, timing the first warning, Barracks completion, first trained unit, first attack contact, and whether retinue trivializes the opener.
3. Play both Aether Well Ruins and Bandit Hillfort on Normal from a typical early campaign save.
4. Play Ashen Outpost with and without Chapel repair to validate fortress pressure, final approach readability, tower pressure, upper-left objective-panel placement, and whether mixed or Stronghold-backed retinue feels helpful or mandatory.
5. Human-review affixed rewards in Results and Inventory to make sure base/affix/total stat copy is readable without crowding the equipment flow.
6. Human-review reputation hooks in actual campaign flow: Common Folk service discounts, Free Marches Stronghold discounts, Old Faith Chapel Aether bonus, and Ashen Covenant Hostile pressure.
7. Human-review the full two-tier Stronghold set in actual fog/build-order play, especially whether Training Yard II's retinue capacity, Watch Post II's earlier warning/tower reach, and Quartermaster II's broader starter package feel helpful without becoming mandatory.
8. Reputation hooks, item affixes V1, Stronghold Tier II, battle-local Unit Veterancy V1, and Retinue Camp V1 are compact slices; future campaign-depth work should stay compact. Do not move into workers, enemy construction, crafting, durability, affix rerolling, diplomacy, new maps, or broad city-builder systems yet.
9. Treat the next technical risks as `ScriptedBattlePlaytest`, `BattleScene`, `HUD`, `contentValidation`, `CampaignRules`, `RetinueRules`, `src/game/core/progression/ItemRewardRules.ts`, `itemAffixes`, and the reputation helper/rule hooks. `HeroProgressionRules.ts` itself is now only a compatibility barrel.
10. Keep Vite chunk-size warning as a known build warning unless the user asks for bundle optimization.

## Guidance For Future LLMs

- Preserve current dirty work unless explicitly told to reset/revert. The checkpoint commit is synced with origin, and the current Stronghold Tier I telemetry-response, Stronghold Tier II, campaign reputation/consequence, item affix V1, Unit Veterancy V1, Retinue Camp V1, retinue balance, and HeroProgressionRules refactor edits are intentional.
- Treat the current docs as the v0.2 prototype baseline. Use `CHANGELOG.md` and `RELEASE_CHECKLIST.md` for release-facing summaries and verification commands.
- The next named milestone is human campaign balance/readability review with Retinue Camp V1 included. Do not reopen completed Stronghold Tier II, reputation, item-affix V1, battle-local Unit Veterancy V1, Retinue Camp V1, retinue balance, or HeroProgressionRules refactor work unless the user asks for a targeted polish pass.
- Keep campaign and skirmish separate entry flows that share `BattleLaunchRequest`.
- Prefer data tuning in `src/game/data` and pure rules in `src/game/core` or `src/game/systems`.
- `src/game/core/HeroProgressionRules.ts` is intentionally a compatibility barrel. Preserve it for old imports and put future hero progression work in the focused modules under `src/game/core/progression/`.
- Add or update tests for persistent save fields and data contracts.
- Use Playwright for browser verification when UI/gameplay changes.
- Use Browser Use when the user asks for in-app browser inspection or visible local-browser interaction; the latest handoff update used it for an in-app preview smoke after deterministic Playwright e2e passed.
- Keep changes conservative until the current first-hour campaign balance has human playtesting.
- Never run destructive git commands without explicit user approval.
