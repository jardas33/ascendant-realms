# Systems Expansion Risk Register

Date: 2026-05-08

Scope: planning only. This register identifies future-system risks and gates for Ascendant Realms. It does not authorize implementation in the current checkpoint.

## Risk Scale

| Rating | Meaning |
| --- | --- |
| Low | Localized change, mostly docs/data/copy, easy rollback, existing tests likely cover it. |
| Medium | Touches player-facing UI or data rules, needs focused tests and smoke e2e. |
| High | Touches save state, battle rules, AI, campaign progression, or multiple scenes. |
| Very high | Requires network, determinism, broad architecture, or irreversible save/schema choices. |

## Register

| System | Primary risk | Rating | Dependencies | Required tests | Likely files touched | Safe first vertical slice | What not to do |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Workers/economy | Broadly changes base-building pace, resource flow, UI density, and save shape. | High | Economy model, building queues, selection/command UI, save defaults, simulator profiles. | Pure economy unit tests, save normalization tests, smoke e2e, playtest simulator. | `src/game/types/EconomyTypes.ts`, `src/game/systems/ResourceSystem.ts`, `src/game/systems/BuildingSystem.ts`, `src/game/ui/hudPanels/CommandPanel.ts`, `src/game/save/*`, `tests/e2e/*`. | One player-only worker/resource rule prototype behind data and tests. | Do not add enemy workers, broad gather AI, new resources, or full economy UI in the first slice. |
| Enemy construction | Can destabilize battle duration, objective clarity, pathfinding, fog, and fairness. | High | Worker/economy model, enemy AI state machine, map validation, telemetry. | AI unit tests, battle runtime tests, release e2e, simulator balance profiles. | `src/game/ai/*`, `src/game/systems/BuildingSystem.ts`, `src/game/battle/*`, `src/game/data/maps.ts`, `src/game/playtest/*`. | One scripted rebuild behavior in a contained test scenario after player economy is stable. | Do not let AI freely expand, rebuild everything, or alter current campaign battles first. |
| Faction expansion | Can create originality, balance, asset, and content-validation risks. | High | Faction design doc, unit/building data validation, asset policy, campaign launch rules. | Content validation tests, unit/building rule tests, smoke e2e for selection/building, simulator profiles. | `src/game/data/factions.ts`, `src/game/data/units.ts`, `src/game/data/buildings.ts`, `src/game/data/contentValidation.ts`, `src/game/entities/*`, `src/game/systems/*`. | One original faction concept document plus data-validation stubs before mechanics. | Do not copy external faction identities, add full rosters, or mix faction launch with worker/enemy construction. |
| Campaign chapter model | Missing-map links, route lock bugs, reward duplication, and save drift. | Medium-high | Campaign node rules, chapter panel, reward rules, save migrations, layout coverage. | Campaign rules tests, reward duplicate tests, smoke/deep e2e, layout e2e. | `src/game/data/campaignChapters.ts`, `src/game/data/campaignNodes.ts`, `src/game/core/campaign/*`, `src/game/campaign/*`, `tests/e2e/chapter2-helpers.ts`. | Locked chapter shell and copy-only route preview with no missing playable launches. | Do not add playable battle nodes without maps, rewards, simulator coverage, and route-complete copy. |
| Diplomacy/reputation | Persistent state can become opaque and hard to test. | Medium-high | Current reputation rules, campaign choice previews, save migration policy, UI hierarchy. | Reputation rule tests, campaign choice tests, save tests, smoke e2e for choice preview. | `src/game/core/campaign/CampaignReputationRules.ts`, `src/game/data/campaignModifiers.ts`, `src/game/campaign/*`, `src/game/save/*`. | Preview-only diplomacy consequences using existing reputation ranks. | Do not add alliance simulation, faction war systems, or hidden irreversible state first. |
| Procedural/skirmish maps | Determinism, pathing, objectives, fog, and fairness can all fail at once. | High | Map schema validation, seeded RNG policy, pathfinding tests, minimap/fog coverage. | Seed determinism tests, map validation tests, pathfinding tests, smoke e2e on one generated seed. | `src/game/data/maps.ts`, `src/game/types/MapTypes.ts`, `src/game/pathfinding/*`, `src/game/battle/BattleSceneMapRenderer.ts`, `src/game/scenes/SkirmishSetupScene.ts`. | Deterministic seed preview plus validator, no playable generated battle yet. | Do not ship random maps before every generated start/resource/objective can be validated. |
| Crafting/affix rerolling | Can break item identity, economy balance, duplicate prevention, and saves. | Medium-high | Affix rules, item reward rules, inventory UI, save migrations, campaign resources. | Affix/reroll unit tests, duplicate reward tests, save tests, inventory smoke e2e. | `src/game/core/progression/AffixRules.ts`, `src/game/core/progression/ItemRewardRules.ts`, `src/game/progression/*`, `src/game/data/itemAffixes.ts`, `src/game/save/*`. | Pure-rule reroll simulator that returns a preview without mutating saves. | Do not add currency sinks, durability, destructive crafting, or broad loot UI first. |
| Multiplayer feasibility | Browser networking and RTS determinism are a major architecture shift. | Very high | Deterministic simulation audit, input command log, save/serialization model, server choice. | Determinism tests, command serialization tests, latency simulation, no production dependency until approved. | Future `src/game/net/*`, `src/game/battle/*`, `src/game/systems/InputSystem.ts`, `src/game/save/*`. | Feasibility doc and deterministic command-log experiment outside player runtime. | Do not add paid APIs, external servers, lobby UI, real-time netcode, or save coupling first. |
| Asset pipeline | Large source assets can bloat deploys or create inconsistent visuals. | Medium | Manifest build, production asset policy, style bible, placeholder rules. | Asset manifest validation, production build, preview smoke, file-size audit. | `tools/manual-asset-pipeline/*`, `src/game/assets/*`, `public/assets/*`, `docs/*`. | Audit production-shipped assets and define final/manual asset separation. | Do not add large generated assets or rely on external generation at runtime. |
| AI personality expansion | New personalities can look flavorful but produce unfair or broken battles. | Medium-high | Enemy AI controller, pacing data, telemetry labels, map constraints. | AI tests, simulator profiles, smoke/deep e2e for affected encounters. | `src/game/data/aiPersonalities.ts`, `src/game/ai/*`, `src/game/playtest/*`, `src/game/data/battlePacing.ts`. | Telemetry-only personality label expansion before new tactical behavior. | Do not add broad scouting, counter-builds, or retreat logic before economy/enemy construction gates. |
| Save migration | Future fields can corrupt existing v0.3/v0.3.1 saves if added casually. | Very high | Save versioning policy, defaults, normalization, import/export tests. | Migration tests for old/current/future mock saves, import/export tests, campaign flow e2e. | `src/game/save/SaveMigrations.ts`, `src/game/save/SaveDefaults.ts`, `src/game/save/SaveNormalization.ts`, `src/game/save/SaveTypes.ts`, `src/game/core/SaveSystem.ts`. | Versioned no-op migration test plus one mock optional future field. | Do not rename existing keys, change reward IDs, or require players to restart saves. |
| Performance | Content growth can make chunking, boot, e2e runtime, and asset delivery worse. | Medium-high | Bundle analyzer, test lanes, production preview, asset audit. | `npm run build:analyze`, build, smoke/release e2e, simulator, preview smoke. | `vite.config.ts`, `src/game/config.ts`, `src/game/data/contentIndex.ts`, `src/game/scenes/*`, `docs/*`. | One analyzer-backed optimization at a time with before/after numbers. | Do not hide warnings, lazy-load battle/campaign scenes casually, or mix multiple optimizations. |
| Modding/data-driven content | Untrusted or loosely validated data can break saves, assets, balance, and security assumptions. | High | Strict schemas, ID namespace policy, asset allowlists, save/import trust boundary. | Schema validation, invalid mod rejection, duplicate-ID tests, asset allowlist tests, save/import safety tests. | `src/game/data/validation/*`, `src/game/data/contentIndex.ts`, `src/game/types/*`, `src/game/save/*`, future `src/game/modding/*`, `docs/*`. | Internal schema hardening only, with no public mod import and no runtime code execution. | Do not execute imported scripts, load arbitrary remote assets, mutate saves from mod data, or promise public mod support early. |
| Tutorial/onboarding | Guidance can become intrusive, brittle, or a parallel campaign if it grows too quickly. | Medium | First-experience guidance, settings/readability work, route-complete copy, input clarity. | Guidance rule tests, smoke e2e for first-run prompts, layout e2e for help/reference surfaces, save tests if dismissal persists. | `src/game/core/FirstExperienceGuidance.ts`, `src/game/scenes/MainMenuScene.ts`, `src/game/scenes/CampaignMapScene.ts`, `src/game/ui/*`, `src/game/save/*`, `tests/e2e/*`. | Non-blocking reference/help copy using current systems. | Do not add a separate tutorial campaign, new maps, mandatory pop-up chains, or hidden save state first. |
| Monetization/packaging | Shipping plans can distort balance, save shape, release scope, and user trust. | Medium-high | Product positioning, offline package plan, save/export trust, asset licensing policy, platform requirements. | Package/build smoke, save import/export tests, offline boot test if packaged, entitlement-free behavior tests if unlock flags ever exist. | `package.json`, `vite.config.ts`, `src/game/scenes/MainMenuScene.ts`, `src/game/save/*`, release docs, future packaging scripts. | Documentation-only packaging options with no code unlocks or paid services. | Do not add microtransactions, paid APIs, online entitlement checks, pay-to-win progression, or monetization-gated balance. |

## Cross-System Watch Items

- Save compatibility is the hardest shared dependency. Any persistent system should land only after migration tests exist.
- Enemy construction depends on worker/economy clarity; implementing it first would produce unstable pacing.
- Faction expansion should not begin as a full roster. It should begin as identity, validation, and one tiny vertical slice.
- Procedural maps should not become a replacement for authored maps until deterministic validation is strong.
- Modding should start as internal schema hardening, not public user-imported content.
- Tutorial/onboarding should use existing guidance surfaces before it becomes a new mode.
- Monetization/packaging should remain documentation-only until the single-player game identity is stronger.
- Multiplayer should remain research until battle simulation is deterministic enough to replay from command logs.
- Performance work should stay measured. The existing Phaser vendor warning is known and should not be hidden as a cosmetic fix.

## Recommended Expansion Order

| Order | System | Why here |
| --- | --- | --- |
| 1 | Save migration and content validation | It protects every later persistent field and data contract. |
| 2 | Workers/economy | It is the first broad RTS foundation that future AI and faction work depend on. |
| 3 | Enemy construction | It depends on player economy clarity and should not precede it. |
| 4 | Faction expansion | Asymmetry needs stable economy, AI, validation, and asset boundaries. |
| 5 | Campaign chapter expansion | New chapters should wait for stable route, faction, and reward assumptions. |
| 6 | Diplomacy/reputation | It becomes safer once campaign chapter and faction state are clearer. |
| 7 | Tutorial/onboarding | It can teach the stable loop without creating broad mechanics. |
| 8 | Crafting/affix rerolling | It should wait for save fixtures and item identity safeguards. |
| 9 | Asset pipeline | It should precede large content drops and new faction art demands. |
| 10 | Performance | It repeats after each content expansion and remains analyzer-backed. |
| 11 | AI personality expansion | It needs worker/enemy construction telemetry before tactical behavior grows. |
| 12 | Procedural/skirmish maps | It needs stronger authored-map validation and deterministic checks first. |
| 13 | Modding/data-driven content | It should begin as internal schema hardening before public import. |
| 14 | Monetization/packaging | It should stay planning-only until the game identity and package target are clearer. |
| 15 | Multiplayer feasibility | It is last because determinism, networking, and deployment are the highest-risk shift. |

## Gate Recommendation

Before the next mechanics implementation checkpoint, create a v0.5 save/content validation gate:

- Save migration tests for current and old saves.
- Content validation plan for future workers, factions, maps, and campaign nodes.
- A small command-log or simulation determinism note for future multiplayer and AI work.
- A release checklist entry requiring simulator coverage for any battle pacing change.
