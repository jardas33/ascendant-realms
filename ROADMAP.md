# Ascendant Realms Roadmap

## Product Pillars

Every phase should protect these long-term pillars:

1. Persistent hero fantasy: race, class, origin, items, scars, titles, retinue, reputation, and choices should make the hero feel personal.
2. Faction asymmetry: factions need different economies, rhythms, combat identities, and strategic weaknesses.
3. Living campaign map: the world should react with alliances, betrayals, invasions, shops, temples, ruins, contracts, holy orders, cursed lands, and ancient threats.
4. Data-driven and mod-friendly content: future expansion should mostly mean adding data and assets, not rewriting engine code.

## Current Recommended Next Phase

The current release baseline candidate is **v0.2.1**. It packages the v0.2 feature baseline with completed Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, the CampaignRules module split, and the HUD/fog polish pass.

The current visible product baseline is `Prototype v0.2` with the menu subtitle `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`.

Completed v0.2.1 stabilization:

- Rival/Nemesis Persistence V1: completed.
- Rival Rewards and Trophies V1: completed.
- CampaignRules split into focused pure-rule modules behind a compatibility facade: completed.
- HUD/fog polish for command hover stability, side-panel scroll preservation, and captured resource-site visibility: completed.
- Permanent Playwright regression coverage for the HUD/fog polish: completed.

Next phase:

- **v0.3 proposed milestone: Chapter 2 vertical slice**.
- Planning spec: `docs/CHAPTER_2_PLAN.md`.
- Minimal scaffold status: Chapter metadata and locked/upcoming Cinderfen Road placeholder nodes are in place; no Chapter 2 gameplay, battle map, unit, faction, worker flow, enemy construction, diplomacy, procedural generation, crafting, or balance content is implemented.
- Working proposal: The Cinderfen Road, a small ash-glass wetland/causeway chapter that reuses the current campaign, rival, trophy, Stronghold, retinue, reputation, enemy hero, and affixed-loot systems.
- Scope target: 4-6 campaign nodes, exactly one new battle map when implementation begins later, one new event node, one town/service addition, one returning-rival consequence, and at most one new enemy unit type only if existing Ashen units cannot carry the map identity.
- Default implementation stance: use existing Free Marches and Ashen Covenant content first; do not start a full new faction.

Must be stable before implementation:

- v0.2.1 automated baseline remains green: `npm test`, `npm run build`, full Playwright e2e, and `npm run playtest:sim`.
- Rival/retinue readability review remains current, including capacity, death/removal, deployed retinue identity, rival preview, duplicate reward prevention, trophies, and defeat/readiness copy.
- HUD command hover stability, side-panel scroll preservation, and captured-site fog visibility remain covered by permanent e2e regression tests.
- Ashen Outpost, mixed retinue, Training Yard II, Quartermaster II, rival rewards, and first-defeat trophy clarity remain under human-review watch before numeric tuning.

Explicitly postponed for v0.3:

- Workers.
- Enemy construction or rebuilding.
- Full new faction.
- Diplomacy or alliance simulation.
- Procedural campaign or procedural maps.
- Crafting, durability, affix rerolling, or broader loot complexity.
- Full trophy room.
- Broad army-management or retinue replacement systems.

Recommended focus before new Chapter 2 gameplay:

- Keep v0.3 planning compact and data-driven. Define the next chapter's smallest playable vertical slice before adding broad systems.
- Play Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost with no retinue, one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Specifically watch Gorak Emberhand, Veyra of the Cinders, and Captain Malrec for scout readability, nameplate clarity, ability readability, XP/objective payoff, first-defeat trophy clarity, late-attack fairness, and whether +5% rematch modifiers are noticeable without feeling mandatory.
- Confirm Retinue feels helpful without becoming mandatory, especially on Ashen Outpost.
- Review whether permanent retinue death feels clear enough before adding wounded timers or replacement UI.
- Recheck command hover stability, side-panel scroll preservation, and captured-site fog readability with human mouse movement even though automated regression tests now cover the core cases.
- Keep bonuses modest, visible in UI, and represented in telemetry.
- Human-paced campaign QA should still review Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, Ashen Outpost, rival commanders, the two-tier Stronghold paths, reputation hooks, and affixed reward readability before larger balance changes.
- Keep technical risk work scoped around `HUD`, `contentValidation`, `BattleScene`, `src/game/core/progression/ItemRewardRules.ts`, `RetinueRules`, `RivalRules`, and `CampaignRules`.
- Do not move into workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, or broad army-management systems as part of this baseline.
- Treat the Vite large-chunk warning as a known build warning, not a failing roadmap item, unless bundle optimization becomes the explicit task.

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
- Three authored battlefields now prove the map pipeline: First Claim, Broken Ford, and Ashen Outpost.
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
