# Full Game Roadmap

Date: 2026-05-08

Scope: planning only. This roadmap prepares Ascendant Realms for long-term growth into a polished, original fantasy RTS/RPG without adding systems, maps, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, or broad army-management behavior in this checkpoint.

Update note, 2026-06-01: v0.96 completed a first-session Tutorial/onboarding UX rescue within the browser prototype. It improved presentation, help, and Salto first-step guidance only; the longer-term roadmap below still treats broader tutorial/onboarding expansion as future gated work, especially any persistent preferences, new tutorial maps, analytics, or new gameplay teaching systems.

## Product Guardrails

Ascendant Realms should grow through original lore, original faction identities, original UI language, original map names, original unit names, and original mechanical expression. It can share broad genre DNA with fantasy RTS/RPG hybrids, but it must not copy protected names, faction concepts, campaign structures, maps, art direction, sound, music, UI, or story expression from any existing game.

The frozen playable baseline remains:

- `Prototype v0.3` / `Cinderfen Route Baseline`.
- `v0.3.1` polish/readability/release layer.
- v0.4 technical groundwork: bundle analyzer, hook audit, Phaser vendor chunk split, release e2e shard scripts, and accessibility/readability polish.

Future work should protect save compatibility, deterministic tests, release-gate e2e coverage, playtest simulator coverage, and the current route-complete state for Cinderfen Aftermath.

## Roadmap Shape

| Horizon | Goal | Status | Gate before implementation |
| --- | --- | --- | --- |
| v0.4 | Technical measurement, e2e sharding, readability polish | Active checkpoint | Keep `npm test`, build, smoke/release e2e, simulator, and diff checks green. |
| v0.5 | Systems architecture and content validation hardening | Planning only | Finish design briefs, risk register, and save migration plan before adding new mechanics. |
| v0.6 | Economy and worker vertical slice | Future | Unit tests for economy state, save defaults, AI non-use, UI copy, and e2e smoke for no-regression launch. |
| v0.7 | Enemy construction prototype | Future | Worker/economy model stable, battle pacing telemetry expanded, no save migration ambiguity. |
| v0.8 | First fully distinct faction expansion | Future | Faction identity doc, content validation, asset pipeline constraints, and release e2e coverage. |
| v0.9 | Campaign chapter expansion | Future | Chapter model stable, route-complete UX stable, map/test budget approved. |
| v1.x | Tutorial hardening, skirmish, procedural, modding, packaging, and multiplayer investigations | Future | Each system requires its own gate, prototype, and rollback plan. |

## System Expansion Order

Recommended order:

1. Save migration and content validation hardening.
2. Worker/economy model design, then one player-only vertical slice.
3. Enemy construction model after the player economy can be simulated and tested.
4. Faction expansion only after economy and enemy behavior can express asymmetry.
5. Campaign chapter model once route and faction assumptions are stable.
6. Diplomacy/reputation expansion after campaign state transitions are better versioned.
7. Tutorial/onboarding improvements after the route-readability baseline is stable.
8. Crafting/affix rerolling only after item economy and duplicate-prevention rules are audited.
9. Asset pipeline hardening before large content drops.
10. Performance passes after each meaningful content expansion, always analyzer-backed.
11. AI personality expansion after worker/enemy construction telemetry exists.
12. Procedural/skirmish maps after authored map validation is stricter.
13. Modding/data-driven content only after strict schemas, ID namespaces, and asset allowlists exist.
14. Monetization/packaging planning only after the single-player identity is stronger.
15. Multiplayer feasibility last, after deterministic simulation and input/state boundaries are understood.

## System Snapshot

| Future system | Player value | Risk | Safe first vertical slice |
| --- | --- | --- | --- |
| Workers/economy | Makes bases feel alive and gives players strategic build pressure. | High | One player-side worker/economy prototype on a test map or isolated rule module, not enemy use. |
| Enemy construction | Makes opponents feel reactive and less static. | High | Scripted rebuild of one known structure in one contained scenario, behind test coverage. |
| Faction expansion | Adds replay identity and long-term fantasy depth. | High | One data-only faction concept with existing unit roles reskinned in original terms before mechanics. |
| Campaign chapters | Gives the game a larger journey and consequence arc. | Medium-high | One planning chapter shell with locked nodes and no playable missing maps. |
| Diplomacy/reputation | Makes world choices feel political and persistent. | Medium-high | Extend existing reputation UI with preview-only consequences before new rule effects. |
| Procedural/skirmish maps | Adds replayability beyond authored routes. | High | Deterministic seed preview and validation harness before playable generation. |
| Crafting/affix rerolling | Gives loot agency and long-term hero builds. | Medium-high | One non-destructive reroll simulation in pure rules, not UI or save mutation. |
| Multiplayer | Enables competitive/co-op dreams. | Very high | Feasibility note and deterministic simulation audit only. |
| Asset pipeline | Lets content scale without shipping messy source assets. | Medium | Production asset manifest audit and tiny placeholder policy. |
| AI personalities | Makes enemies more memorable. | Medium-high | Expand current personality data with telemetry-only labels before new orders. |
| Save migration | Protects existing players and checkpoints. | Very high | Versioned migration tests for no-op current saves and one mock future field. |
| Performance | Keeps the game responsive as content grows. | Medium-high | One measured optimization at a time, analyzer first, release gate before commit. |
| Modding/data-driven content | Keeps future content extensible and potentially community-friendly. | High | Internal schema hardening and validation, no public mod import yet. |
| Tutorial/onboarding | Helps new players learn the current RTS/RPG loop and route boundaries. | Medium | Non-blocking help/reference polish using current first-experience guidance. |
| Monetization/packaging | Defines how the game could eventually ship without warping design. | Medium-high | Documentation-only packaging options, no code unlocks or paid services. |

## Content And Lore Direction

Future worldbuilding should deepen current original anchors:

- Free Marches as a frontier coalition with civic defense and hard-won logistics.
- Ashen Covenant as a dangerous original adversary with ash, oath, and ruin motifs already present in-game.
- Cinderfen as ash-glass wetland, causeway, shrine, and post-battle consequence space.

Future factions should be named, themed, and mechanically expressed from original design documents. Do not borrow faction rosters, hero archetype names, unit names, spell names, music cues, campaign beats, or UI motifs from any existing fantasy RTS/RPG.

## Stability Gates

Every future system should define:

- Save compatibility and migration behavior.
- Data validation and content loading behavior.
- Unit tests for pure rules.
- E2E coverage for the smallest player-visible path.
- Playtest simulator telemetry if battles, rewards, AI, or campaign pacing are affected.
- Production build and preview smoke when bundling or asset loading changes.
- Documentation in `LLM_GAME_HANDOFF.md`, `ROADMAP.md`, and the relevant design/audit doc.

## Recommended Next Milestone

The next safest milestone is v0.5 systems design hardening:

- Audit save migration strategy before new persistent fields.
- Add content-validation plans for future factions, workers, and generated maps.
- Decide the first economy prototype boundaries without implementing it.
- Keep v0.3/v0.3.1 playable content frozen while preparing tests for future vertical slices.
