# v0.5 Vertical Slice Candidate Selection

Date: 2026-05-08

Status: planning only. This document selects a future vertical-slice candidate. It does not implement a tutorial, map, unit, faction, worker, enemy construction, diplomacy, procedural generation, crafting, multiplayer, or broad system.

## Decision

Approved future planning candidate: Candidate A, Tutorial / Proving Grounds.

Rationale:

- It improves onboarding and route comprehension without requiring new factions, new units, workers, enemy construction, crafting, diplomacy, procedural maps, multiplayer, or a save-version bump.
- It can start as metadata, validation, and tests before it becomes playable.
- It teaches existing systems instead of expanding the game sideways.
- It directly addresses current watch items around route feel, input clarity, mobile density, and human readability.

Do not implement this candidate in the v0.5 safety-gate goal.

## Candidate A: Tutorial / Proving Grounds

Player value:

- Gives new players a safer first contact with camera, selection, movement, capture, building, training, rally points, hero ability use, and victory/results.
- Reduces pressure on the first campaign battle to teach every control and system at once.
- Supports future accessibility/readability work without changing Cinderfen balance.

Risk:

- Medium. A tutorial can become intrusive, text-heavy, brittle in e2e, or accidentally become a parallel campaign.
- Lower systems risk than workers, enemy construction, factions, and new campaign content.

Dependencies:

- Current first-experience guidance.
- Stable input and HUD commands.
- Content validation for any future tutorial metadata.
- Save compatibility rules proving no required save-version bump.
- Smoke/deep e2e coverage that current campaign and skirmish still launch.

Files likely touched in a future implementation:

- `src/game/core/FirstExperienceGuidance.ts`
- `src/game/scenes/MainMenuScene.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/CampaignMapScene.ts`
- `src/game/ui/*`
- `src/game/data/validation/*`
- `src/game/save/*` only if dismissal/progress persistence is added
- `tests/e2e/*`
- future docs under `docs/`

Content validation needs:

- Tutorial/proving grounds metadata IDs must be unique.
- Step IDs must be unique within a tutorial.
- Any referenced unit, building, ability, map, objective, or reward policy must exist.
- Planned/scaffolded tutorial metadata must not expose a launch path to missing playable content.

Save migration needs:

- Preferred first implementation should require no save fields.
- If tutorial completion/dismissal is later persisted, it must default safely for old saves and add fixture coverage before any version bump.

E2E needs:

- Tutorial entry point visible only when it is safe.
- Tutorial start does not break main menu, campaign, skirmish, inventory, or settings.
- First guided objective can complete in Playwright without arbitrary sleeps.
- Current smoke, release, and layout lanes remain intact.

Simulator needs:

- None for metadata-only work.
- Later playable tutorial combat should not enter the default campaign simulator unless it becomes a real battle pacing target.

Why now:

- The v0.5 save/content/determinism gate makes metadata-first tutorial planning safer.
- It improves usability before risky mechanics.
- It supports the current watch list: Cinder Shrine salience, Waystation density, input clarity, and human route feel.

Why not now:

- The current v0.5 goal is a safety gate, not an implementation sprint.
- The brief must define scope first so tutorial work does not become a new map/content project.

Exact smallest safe first implementation:

- A docs-only tutorial brief.
- Then, only if separately approved, a metadata-only scaffold with validation and no launch path to missing content.

Explicit non-goals:

- No new map.
- No new units.
- No new faction.
- No new campaign rewards.
- No required save-version bump.
- No mandatory modal chain.
- No replacement for the current campaign smoke path.

Recommended order:

1. Design brief.
2. Metadata type and validation only.
3. Non-launching UI placeholder only if safe.
4. First guided objective using existing map/unit/building data.
5. Completion/results pass.
6. Telemetry and e2e hardening.

## Candidate B: Workerless Enemy Construction Prototype

Player value:

- Could make enemies feel more reactive and less static without introducing full workers.
- Helps test future base expansion and rebuild pressure.

Risk:

- High. It touches AI, battle pacing, objectives, map validation, fog readability, performance, and simulator trust.
- Even without workers, enemy construction can create runaway fights or unclear victory states.

Dependencies:

- Stronger enemy AI state boundaries.
- Map building spawn/reference validation.
- Objective rules that define rebuilt structures.
- Simulator profiles that measure duration and pressure changes.
- Human readability review for fog and surprise construction.

Files likely touched:

- `src/game/ai/*`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/BuildingPlacementRules.ts`
- `src/game/battle/*`
- `src/game/data/maps/*`
- `src/game/playtest/*`
- `tests/e2e/*`

Content validation needs:

- Enemy construction plans reference existing buildings, valid teams, valid placement zones, valid objectives, and valid AI personalities.
- Rebuild/repair targets cannot be required for current victory if they are not represented in objective rules.

Save migration needs:

- None if kept battle-local.
- Future campaign consequences would require save planning.

E2E needs:

- Focused battle e2e proving existing objectives still complete.
- Release lane coverage for affected maps.

Simulator needs:

- New profile for enemy rebuild timing.
- Drift checks for first attack, duration, and win/loss outcomes.

Why now:

- It would exercise the new content validation and simulator gates.

Why not now:

- It is a broad battle-system change and explicitly prohibited until earlier gates are green and a separate phase permits it.

Exact smallest safe first implementation:

- Planning-only AI construction spec, then a test-only data stub. Not gameplay.

Explicit non-goals:

- No enemy workers.
- No free expansion.
- No new maps.
- No current route pacing changes.

Recommended order:

1. AI construction design note.
2. Validation-only plan.
3. Test-only scenario.
4. One scripted repair/rebuild behavior.
5. Simulator and release-gate pass.

## Candidate C: Micro-Faction Prototype

Player value:

- Starts the long-term promise of faction identity and replay variety.
- Could eventually give the game stronger original strategic personality.

Risk:

- High. Factions touch originality, naming, units, buildings, AI, assets, rewards, launch rules, UI, save shape, and balance.
- Easy to overbuild or accidentally echo existing fantasy RTS faction expression.

Dependencies:

- Original faction identity brief.
- Unit/building/reward/content validation.
- Asset pipeline policy.
- AI and simulator profile support.
- Save-safe faction selection model.

Files likely touched:

- `src/game/data/factions.ts`
- `src/game/data/units.ts`
- `src/game/data/buildings.ts`
- `src/game/data/validation/*`
- `src/game/entities/*`
- `src/game/systems/*`
- `src/game/scenes/HeroCreationScene.ts`
- `src/game/scenes/SkirmishSetupScene.ts`
- `tests/e2e/*`

Content validation needs:

- Faction IDs, unit availability, building availability, upgrades, abilities, AI preferences, reputation hooks, and rewards must all validate.
- Any placeholders must be clearly non-playable until complete.

Save migration needs:

- If player faction selection persists, old saves need defaults and fixtures.
- Current hero/campaign save shape must remain compatible.

E2E needs:

- Faction selection smoke.
- Existing campaign unaffected.
- Skirmish launch with the faction only after unit/building data is complete.

Simulator needs:

- Faction-specific strategy assumptions and pacing profiles.

Why now:

- It is aspirationally valuable and long-term central.

Why not now:

- Too much content/design risk for the first post-gate vertical slice.
- Requires assets, balance, and originality review before mechanics.

Exact smallest safe first implementation:

- Design-only faction identity constraints and validation stub. Not playable.

Explicit non-goals:

- No full roster.
- No copied fantasy identity.
- No new assets required at runtime.
- No faction-specific campaign branch.

Recommended order:

1. Original faction identity doc.
2. Data-validation schema.
3. Placeholder non-playable metadata.
4. One existing-role unit experiment.
5. AI/simulator profile.

## Candidate D: Cinderfen Epilogue Node

Player value:

- Smallest direct content continuation after Cinderfen Aftermath.
- Could give the current route a stronger emotional close.

Risk:

- Medium. It adds content before manual route-feel review, and content additions can affect campaign graph, rewards, save state, e2e, layout density, and simulator coverage.

Dependencies:

- Human review of current Aftermath wording/density.
- Campaign graph/reward validation.
- E2E route flow update.
- Save fixture coverage for new node completion if added.

Files likely touched:

- `src/game/data/cinderfenRoadNodes.ts`
- `src/game/data/campaignChapters.ts`
- `src/game/campaign/*`
- `src/game/core/campaign/*`
- `tests/e2e/chapter2-helpers.ts`
- `tests/e2e/smoke.spec.ts`
- `docs/*`

Content validation needs:

- Node ID, prerequisites, unlocks, rewards, choices, reputation changes, and route endpoint policy.
- Any map reference must be valid or the node must be non-launching.

Save migration needs:

- Old saves completed through Aftermath must not become broken or confusing.
- New completion state should normalize safely without a save-version bump if possible.

E2E needs:

- Chapter 2 route completion flow.
- Duplicate reward/choice prevention.
- Layout checks for added panel density.

Simulator needs:

- None for a pure event node unless rewards affect later battle pacing.

Why now:

- It is the smallest content extension.

Why not now:

- The goal explicitly prioritizes safety gates before new content.
- It risks expanding the frozen route before human review of the current route feel.

Exact smallest safe first implementation:

- Epilogue design note only.

Explicit non-goals:

- No new battle.
- No new map.
- No new faction.
- No large reward economy.
- No hidden route branch.

Recommended order:

1. Human review of current Aftermath.
2. Epilogue copy/design note.
3. Validation-only node plan.
4. Event-only node with no battle/map launch.
5. Smoke/layout e2e update.

## Final Recommendation

Select Candidate A, Tutorial / Proving Grounds, for future planning.

Do not implement it inside the v0.5 safety-gate goal. The next phase should create a dedicated tutorial/proving grounds design brief. A metadata-only scaffold may be considered afterward only if it remains non-playable, validation-first, and does not add maps, units, rewards, save versioning, or launch paths to missing content.

Phase 13 follow-up:

- A metadata-only scaffold was added after the design brief.
- The scaffold is validation-first and non-playable.
- No map, unit, reward, save field, scene, UI launch path, or gameplay behavior was added.
