# v0.5 Content Validation Audit

Date: 2026-05-08

Scope: audit current content/data validation before future expansion. This phase is documentation-only. It does not change validators, gameplay, balance, maps, units, factions, rewards, saves, or runtime behavior.

## Current Validation Entry Points

Runtime and test entry points:

- `src/game/data/contentValidation.ts`
- `src/game/data/validation/index.ts`
- `src/game/data/validation/validateContent.ts`
- `src/game/scenes/BootScene.ts`
- `src/game/data/contentValidation.test.ts`

Current behavior:

- `BootScene` runs `validateContent()` before entering the main menu.
- If validation returns errors, boot stops and renders a Content Data Error panel.
- `src/game/data/contentValidation.test.ts` asserts `validateContent()` returns an empty list.
- The current validation has no standalone npm script yet.

## Validators That Exist

| Area | File | Current coverage |
| --- | --- | --- |
| Shared IDs/context | `ValidationTypes.ts`, `validateContent.ts` | Builds ID sets for units, buildings, abilities, factions, hero classes, origins, items, affixes, resources, skill trees/nodes, reward tables, upgrades, Stronghold upgrades, campaign chapters/nodes, AI personalities, campaign modifiers, enemy heroes, enemy hero abilities, and rival trophy IDs. Detects duplicate top-level IDs through `idsFor`. |
| Units | `validateUnits.ts` | Faction reference, positive HP/radius/vision, non-negative train time, positive attack cooldown, prerequisites, and combat stat sanity. |
| Buildings | `validateBuildings.ts` | Faction reference, positive HP/footprint/vision, non-negative construction time, build/train/upgrade references, prerequisites, and attack tuning sanity. |
| Upgrades | `validateUpgrades.ts` | Display name, non-negative research time, prerequisites, non-empty effects, unit targets, stat multiplier sanity, and hero mana regen sanity. |
| Abilities | `validateAbilities.ts` | Hero class reference, hotkey, non-negative costs/timing/range/radius/duration, and prerequisites. |
| Hero classes | `validateAbilities.ts` | Primary ability reference, ability list references, primary ability included in class ability list, positive vision, combat stats, and non-negative mana. |
| Skill nodes | `validateAbilities.ts` | Skill tree references, optional class references, unlock ability references, positive rank/cost, and prerequisite skill references. |
| Items | `validateItems.ts` | Slot, rarity, unique flag type, name/description/flavor text, tags, class affinity references, faction origin references, and finite stat modifiers. |
| Item affixes | `validateItems.ts` | Name, tier, allowed slots, tags, positive weight, and finite stat modifiers. |
| Origins/resources | `validateResources.ts` | Origin stat modifier sanity and resource display names. |
| Factions | `validateFactions.ts` | Name/fantasy, mechanics text, unit/building/upgrade references, AI personality preferences, reputation hooks, unique faction modifiers, modifier copy, modifier type, modifier unit references, and modifier tuning sanity. |
| Reward tables | `validateRewards.ts` | Non-negative rolls, non-empty item source, item references, deterministic item references, weighted pool weights, weighted pool map references, resource references, non-negative resource/XP rewards, first-clear bonus references, and repeat-clear reward references. |
| Rival rewards | `validateRewards.ts` | Enemy hero references, one reward per enemy hero, non-negative XP/resources, item references, reputation faction references, trophy ID/copy, and duplicate trophy IDs. |
| Stronghold upgrades | `validateStronghold.ts` | Copy, positive tier/max rank, Tier II previous-tier prerequisite, cost resources, prerequisite upgrades/nodes, non-empty effects, effect unit/resource references, and effect tuning sanity. |
| Campaign chapters | `validateCampaign.ts` | Title/description, chapter node references, unlock prerequisite node references, nodes omitted from chapter lists, and at least one unlocked current chapter. |
| Campaign nodes | `validateCampaign.ts` | Node type, copy, chapter reference, map reference unless placeholder, placeholder copy, enemy faction, difficulty, AI personality, enemy hero, prerequisite nodes, unlock nodes, item rewards, resource rewards, XP rewards, unique choice IDs per node, and choice validation. |
| Campaign choices | `validateCampaign.ts` | Choice copy, cost/resource requirement/reward resource references, hero-level requirement sanity, completed-node requirements, item requirements/rewards, rival trophy requirements, reputation requirements/changes, stock item reference, XP sanity, unlock/lock node references, and modifier grant/remove references. |
| Reputation effects | `validateCampaign.ts` | Tracked faction IDs, reputation effect faction references, rank values, effect tuning, campaign modifier references, and campaign node references. |
| Campaign modifiers | `validateCampaign.ts` | Copy, trigger values, unit references, positive multipliers, and resource reward multiplier sanity. |
| Difficulties | `validateAi.ts` | Enemy income, attack/train/expand timing, wave sizing, and enemy starting spawn IDs. |
| AI personalities | `validateAi.ts` | Copy, aggression range, preferred/unit plan references, non-empty unit plan, positive timing, economy/wave/defense sanity, phase override IDs, unit references, and max attack unit references. |
| Enemy heroes | `validateEnemyHeroes.ts` | Unique enemy hero ability IDs, ability copy/tuning, unique enemy hero IDs, hero copy, faction/personality/unit references, level/XP sanity, combat stats, ability references, hero campaign node claims, map references, and node-to-hero reverse linkage. |
| Maps | `validateMaps.ts` | Positive dimensions, setup copy, strategic notes, visual paths, unique terrain/paths/sites/camps/spawns/objectives within each map, points inside map bounds, terrain bounds, capture-site resources/income/bonuses, building/unit spawn references, neutral camp unit references, starting resources, primary objective building references, secondary objective references, enemy AI unit/building references, non-empty AI plan, and reward table references. |

## Existing Test Coverage

The current test coverage for content validation is concentrated in:

- `src/game/data/contentValidation.test.ts`

That test suite provides:

- One global `validateContent()` empty-error assertion.
- Barrel wiring checks for chapter and reward modules.
- Authored map metadata checks.
- First Claim opening safety check.
- Chapter 1 and Chapter 2 shape checks.
- AI personality, enemy hero, rival reward, faction, Stronghold Tier II, reputation, and affix smoke assertions.

This is good baseline coverage, but many future-proofing rules still live as human expectation rather than validator failures.

## Validators That Are Missing Or Weak

| Area | Current gap | Risk |
| --- | --- | --- |
| Standalone validation gate | No `npm run validate:content` script yet. Validation runs through unit tests and boot only. | CI or release users can miss a quick content-only gate. |
| Campaign graph reachability | Validation ensures at least one start and checks missing prerequisite/unlock IDs, but does not prove all current playable nodes are reachable from starts and chapter prerequisites. | Future chapters can accidentally create unreachable nodes or unintended dead ends. |
| Chapter node list uniqueness | Top-level campaign node IDs are unique, but duplicate node IDs inside a chapter's `nodeIds` list are not explicitly flagged. | Chapter panels could duplicate display entries or hide ordering mistakes. |
| Campaign unlock graph policy | Missing unlock/prerequisite references are checked, but intentional endpoints and dead ends are not documented as validator policy. | A future node could end a route accidentally. |
| Battle node reward linkage | Map scenarios validate reward table IDs, but campaign battle nodes do not explicitly prove their map's reward table policy is appropriate for that node. | A battle can launch with an unintended reward table because maps are shared. |
| Repeat reward policy | Reward tables validate values and references, but do not require an explicit repeat-clear policy for every table or block risky repeat weighted pools. | Repeat farming can become too generous by accident. |
| Event/town choice visible effects | Choices validate references and costs, but a costed choice with no visible reward/effect/continuation is not rejected. | Future non-battle nodes can spend resources and feel broken. |
| One-time service duplicate policy | Choices have `onceOnly`, but validation does not check stock item/one-time service consistency or repeatable service effect visibility. | One-time town services can duplicate rewards or repeatables can become unclear. |
| Campaign modifier capture-site references | `firstCaptureBonusResourceAdditions` keys are not validated against map capture site IDs. | Cinder Shrine-style modifiers can silently target missing sites. |
| Cinderfen-specific modifier scope | Cinderfen modifier targeting is enforced by runtime trigger logic, but validation does not prove Cinderfen-only site IDs belong to Cinderfen maps. | A one-battle route modifier can drift onto the wrong map family. |
| Map AI building spawn consistency | Enemy AI building IDs are validated as known building IDs, but not all are proven to be spawned on the map for the correct team. | Enemy AI can reference a valid building type that is absent from the scenario. |
| Map pathing/reachability | Points are in bounds, but pathfinding reachability between bases, capture sites, neutral camps, and objectives is not validated. | Future maps can be legal on paper but unwinnable or unreadable. |
| Objective economy consistency | Secondary objectives validate targets, but not reward/telemetry importance or route objective completeness. | Objectives can be technically valid but strategically invisible. |
| Faction roster consistency | Factions reference units/buildings/upgrades, but validation does not yet enforce complete playable roster requirements for a future full faction. | New factions can be data-valid but not playable. |
| Save/content interaction | Save fixtures protect current saves, but content validation does not yet check whether persisted IDs in fixtures remain valid content IDs. | Future content removal can strand existing save fixtures unless tests catch it indirectly. |
| Asset manifest/content coupling | Asset validation is separate; content validation does not check optional item/building/unit icon keys against shipped assets. | Future art-linked content can point at missing assets. |

## High-Risk Content References

Highest-risk references before expansion:

- Campaign node IDs in prerequisites, unlocks, choices, chapters, save fixtures, and e2e seeded saves.
- Map IDs on campaign nodes and reward-table weighted map filters.
- Reward table IDs on map scenarios.
- Item IDs in campaign node rewards, event/town choices, reward tables, rival rewards, save fixtures, and inventory UI.
- Campaign modifier IDs in choices, reputation effects, saves, simulator telemetry, and runtime consumption.
- Capture site IDs in map objectives and Cinderfen first-capture modifier additions.
- Enemy hero IDs in campaign nodes, rival rewards, save fixtures, and trophy state.
- Stronghold upgrade IDs in save normalization and upgrade prerequisite graphs.
- AI personality IDs on battle nodes and enemy heroes.
- Unit/building IDs in maps, AI plans, factions, upgrades, Stronghold effects, and objectives.

## Duplicate ID Risks

Already covered:

- Top-level data IDs through `idsFor`.
- Nested map terrain/path/capture/camp/building spawn/unit spawn/secondary objective IDs within each map.
- Campaign choice IDs within each node.
- Faction modifier IDs within each faction.
- Enemy hero ability IDs and enemy hero IDs.
- Rival reward enemy hero IDs and trophy IDs.

Still weak:

- Duplicate IDs inside `CampaignChapterDefinition.nodeIds`.
- Duplicate IDs inside `CampaignChapterDefinition.unlockPrerequisiteNodeIds`.
- Duplicate capture-site first-capture bonus IDs within or across maps.
- Duplicate weighted item pool entries in a single reward table if not intentional.
- Duplicate deterministic item IDs in reward tables if not intentional.
- Duplicate campaign modifier site targets in `firstCaptureBonusResourceAdditions` are harmless but not explicitly checked.

## Dangling Reference Risks

Mostly covered:

- Units, buildings, abilities, factions, hero classes, origins, items, affixes, resources, skill trees, reward tables, upgrades, Stronghold upgrades, chapters, nodes, AI personalities, modifiers, enemy heroes, enemy hero abilities, and rival trophies.

Still weak:

- Campaign modifier `firstCaptureBonusResourceAdditions` capture site IDs.
- Enemy AI building IDs being present as correct-team building spawns on the map.
- Campaign battle nodes inheriting a valid and intended reward table through map scenarios.
- Save fixture persisted IDs versus current content data, especially if future content is removed or renamed.
- Optional asset/icon keys versus asset manifest entries.

## Reward And Economy Consistency Risks

Current validation catches missing resource/item references and negative reward values. It does not yet enforce:

- Explicit repeat-clear policy on every battle reward table.
- Repeat rewards staying small.
- Weighted item pools being first-clear-only or explicitly allowed on repeats.
- Event choice costs always producing a visible saved effect, progression change, reward, or clear "no purchase" behavior.
- Town services with resources consumed and no visible effect.
- One-time stock purchases preventing duplicate item rewards.
- Unique reward duplicate conversion policy.
- Stronghold + retinue + repeat-reward farming impact.
- Fast Army quick-clear farming watch items from telemetry.

## Map Objective Consistency Risks

Current validation catches missing objective target references. It does not yet validate:

- Pathfinding reachability from player start to each capture site/objective.
- Objective salience or route-specific objective necessity.
- Whether all battle nodes have objective copy that matches their map objective shape.
- Whether secondary objectives are too dense for mobile UI.
- Whether Cinder Shrine-style first-capture bonuses are surfaced strongly enough.

## Campaign Unlock Graph Risks

Current validation catches missing node references and requires at least one start. It does not yet produce:

- Reachability from current starting nodes.
- Chapter-by-chapter reachability.
- Intentional route endpoints list.
- Dead-end detection.
- Cycle detection or a policy for deliberate loops.
- "Playable current" versus "upcoming placeholder" graph classification.

These should become a v0.5 campaign graph/reward gate before adding Chapter 3 or new routes.

## Future Chapter 3 And New Faction Risks

Chapter 3 risks:

- Missing map/reward table on a battle node.
- Unreachable or accidentally unlocked nodes.
- Route-end ambiguity.
- Event choices with no persistent outcome.
- Repeat rewards too high.
- Save selected-node values pointing at retired or renamed nodes.

New faction risks:

- Data-valid but unplayable roster.
- Units/buildings/upgrades missing prerequisites.
- AI personality preferences that cannot train legal armies.
- Reputation defaults and save migration not updated.
- Faction identity drift or external-expression risk if naming/lore is not reviewed.

## Recommended Hardening Order

1. Add stricter low-risk content validation rules for obvious references and policies.
2. Add a standalone `npm run validate:content` script.
3. Add a campaign graph/reward integrity gate with reachability and repeat-reward reporting.
4. Add validation of save fixture persisted IDs against current content IDs.
5. Add map reachability/pathfinding validation only after a careful design pass, because it may need geometry-specific rules.
6. Add faction roster completeness checks before any micro-faction prototype.
7. Add asset/icon manifest reference checks before broad asset-pipeline work.

## Candidate Phase 6 Rules

Safest next validation rules:

- Duplicate chapter `nodeIds` and duplicate chapter unlock prerequisites.
- Campaign modifier `firstCaptureBonusResourceAdditions` capture site IDs exist on at least one map.
- Cinderfen-specific capture-site modifier IDs are only used by Cinderfen maps/nodes.
- Enemy AI base/production/attack target building IDs are present in map building spawns for the expected team where current data supports that.
- Reward tables with repeat rewards have explicit, non-negative repeat rewards and no repeat weighted item pool unless explicitly allowed.
- Event/town choices with costs have at least one visible effect: XP, resources, item, modifier, reputation change, unlock/lock, recovery, stock item, or completion behavior.
- Battle campaign nodes resolve to maps with reward tables.

## Phase 6 Implementation Update

Implemented safe validator rules:

- Campaign chapters now reject duplicate `nodeIds` and duplicate `unlockPrerequisiteNodeIds`.
- Campaign battle nodes now report when their map resolves to a missing reward table.
- Campaign modifiers now validate `firstCaptureBonusResourceAdditions` capture site IDs, resource IDs, positive resource amounts, and Cinderfen-only capture site scope for `next_cinderfen_battle` modifiers.
- Costed campaign choices now require at least one visible saved effect, such as XP, resources, item, modifier, reputation, unlock/lock, recovery, stock item, or completion.
- Reward tables now require an explicit `repeatClearReward`.
- Reward tables now reject duplicate deterministic item IDs, duplicate weighted item IDs, and weighted entries marked both `firstClearOnly` and `repeatClearOnly`.
- Map enemy AI base/production building IDs must be spawned for the enemy team, and AI attack target building IDs must be spawned for the player team.

Tests added in `src/game/data/contentValidation.test.ts`:

- Duplicate chapter node and prerequisite entries.
- Missing and non-Cinderfen capture-bonus modifier targets.
- Map AI building references absent from expected team spawns.
- Reward table missing repeat policy and duplicate weighted pool entries.
- Costed campaign choices with no visible saved effect.
- Battle nodes whose maps resolve to missing reward tables.

No content data, gameplay, balance, save format, maps, units, factions, workers, enemy construction, crafting, diplomacy, procedural generation, or broad systems changed.

Phase 6 verification:

```text
npm test
PASS: 40 test files, 290 tests.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-BMQ_4xND.js, 439.61 kB / gzip 118.07 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.5m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

Defer until Phase 8:

- Full campaign graph reachability.
- Dead-end policy.
- Repeat reward economy thresholds.
- Fast Army and Retinue + Training Yard II farming watch.

## Phase 8 Implementation Update

Implemented the campaign graph and reward-economy gate in code, tests, and `docs/CAMPAIGN_GRAPH_REWARD_GATE.md`.

Additional validator coverage:

- Current chapters must be reachable from their entry and chapter prerequisite graph.
- Chapter node lists cannot point at nodes from another chapter.
- Battle nodes must have at least one direct unlock, dependent prerequisite node, or chapter-continuation role.
- Non-town choices with `completesNode: false` must still unlock or lock a path.
- One-time town item services must use `stockItemId` as a duplicate guard.
- Direct repeat-clear bonus item grants are rejected.
- Repeat-clear XP and resources cannot exceed matching first-clear bonuses.

Additional tests in `src/game/data/contentValidation.test.ts`:

- Repeat-clear direct item grants and excessive repeat XP/resources.
- Unreachable chapter graph plus isolated battle-node continuation.
- Non-town no-complete choices without path flow and one-time town item services without stock guards.
- Reputation effects that reference missing tracked factions.

No content data, gameplay, balance, save format, maps, units, factions, workers, enemy construction, crafting, diplomacy, procedural generation, or broad systems changed.

Phase 8 verification:

```text
npm test
PASS: 40 test files, 294 tests.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-X0lfuOZ2.js, 442.16 kB / gzip 118.76 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.

npm run validate:content
PASS.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

## Verification

Planned verification for this docs-only audit:

```text
npm test
PASS: 40 test files, 284 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Known Vite warning remains for vendor-phaser.

git diff --check
PASS.
```
