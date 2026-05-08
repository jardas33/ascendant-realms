# Tutorial / Proving Grounds Brief

Date: 2026-05-08

Status: design plus first playable shell. The current Tutorial / Proving Grounds path defines validated metadata and launches a no-reward shell on existing First Claim content with a lightweight objective overlay, linear step progression, and a non-persistent completion path. It still does not add new maps, new units, rewards, save fields, persisted completion, or campaign progression.

## 1. Purpose

Tutorial / Proving Grounds should become the safest next vertical slice after the v0.5 safety gate. Its job is to teach the existing RTS/RPG loop without expanding content scope.

The mode should:

- Help new players understand the current controls and battle loop.
- Reduce pressure on Border Village to teach everything at once.
- Improve confidence before future mechanics such as workers, enemy construction, factions, and new chapters.
- Stay original, compact, optional, and non-intrusive.

## 2. Target Player

Primary player:

- New to Ascendant Realms.
- May know RTS basics, but not this project’s specific hero, capture-site, construction, training, rally, ability, and campaign persistence loop.

Secondary player:

- Returning tester who wants a safe control refresher.
- Future QA/LLM agent that needs a deterministic, low-stakes smoke path.

The tutorial should assume the player can read brief prompts but should not rely on long paragraphs during combat.

## 3. What It Teaches

Camera:

- Pan or center on the hero.
- Understand minimap/camera relationship if the minimap is visible.

Selection:

- Select hero.
- Select groups.
- Select Command Hall and production buildings.

Movement:

- Right-click to move selected units.
- Understand formation movement enough to reach a site.

Capturing:

- Move units near a capture site.
- Wait for capture progress.
- Read local resource gain and first-capture bonus messaging.

Resources:

- Read Crowns, Stone, Iron, and Aether.
- Understand that battle resources are for battle actions, while campaign resources persist after victories.

Building:

- Select Command Hall.
- Start Barracks placement.
- Place on valid ground near base.
- Cancel placement if needed.

Training:

- Select Barracks.
- Train Militia.
- Notice queue progress and resource cost.

Rally point:

- Select Barracks.
- Set a ground rally point.
- See newly trained units move toward it.

Hero ability:

- Select hero.
- Use one unlocked ability by button or hotkey.
- Understand mana/cooldown feedback.

Enemy pressure:

- Experience a very small, clearly messaged enemy contact.
- Learn that a staged army is safer than rushing alone.

Victory/results:

- Complete the objective.
- Read Results without being overwhelmed.
- Understand XP, rewards, and return path.

Campaign persistence:

- Explain that the main campaign preserves hero XP, items, equipment, Stronghold progress, retinue, rivals, and choices.
- Keep the tutorial itself from changing campaign progression unless a later explicit implementation chooses otherwise.

## 4. What It Does Not Teach Yet

- Full campaign routing.
- Stronghold upgrade complexity.
- Retinue recruitment and death rules.
- Rival/trophy behavior.
- Advanced upgrades.
- Detailed fog tactics.
- Multiple factions.
- Workers/economy.
- Enemy construction.
- Crafting, durability, affix rerolling, diplomacy, procedural maps, multiplayer, or monetization.

## 5. Minimal Implementation Plan

Phase A: Docs only.

- This brief.
- Keep the selected future candidate documented in `docs/V05_VERTICAL_SLICE_CANDIDATE.md`.

Phase B: Metadata only, optional later.

- Implemented in Phase 13 as `src/game/data/tutorials.ts`, `src/game/types/TutorialTypes.ts`, and `src/game/data/validation/validateTutorials.ts`.
- Metadata includes `id`, `title`, `description`, `status`, and planned step definitions.
- Validation checks unique IDs, valid status, valid step types, and optional references.
- At that metadata-only phase, no playable launch path existed.
- No save fields were added.

Phase C: Shell only.

- Implemented as a main-menu Tutorial launch into `BattleScene` with tutorial mode.
- Uses existing units, buildings, abilities, and map data.
- Reuses `first_claim` with a transient existing Warlord hero.
- No new assets.
- No new faction.
- No new campaign rewards.
- No save-version bump.

Phase D: First guided objective.

- Implemented as the same linear overlay model used by the playable shell.
- Teach camera/readiness, selection, movement, and capture on existing data.
- Keep prompts short and non-blocking.
- Add focused unit/view-model tests and one smoke e2e.

Phase E: Full tutorial completion.

- Implemented as a no-reward completion path that returns directly to the main menu rather than normal campaign Results.
- Add build, train, rally, ability, small pressure, and finish steps.
- Keep it optional and clearly separate from the frozen Cinderfen route.

## 6. Tests

Unit/view-model tests:

- Tutorial metadata validates.
- Step IDs are unique.
- Step references exist.
- Prompt copy is present but not overasserted by exact long text.
- Tutorial status cannot be `playable` unless a safe launch target exists.

E2E tutorial start:

- Entry point is visible only when safe.
- Starting tutorial does not crash.
- Main menu, New Campaign, Continue Campaign, Skirmish Setup, Settings, and Inventory flows still work.

E2E tutorial completion:

- Player can select hero.
- Player can capture first site.
- Player can build Barracks.
- Player can train Militia.
- Player can set rally point.
- Player can cast one ability.
- Player can finish tutorial and return to the main menu without save pollution.

No break to campaign/skirmish:

- Existing smoke and release lanes continue passing.
- Tutorial state does not complete or lock campaign nodes.
- Skirmish setup remains unchanged.

## 7. Content Validation

Future validation should cover:

- Unique tutorial IDs.
- Unique step IDs per tutorial.
- Step type is valid.
- Referenced map IDs exist if a playable map is required.
- Referenced unit, building, ability, objective, capture site, and resource IDs exist.
- Planned/scaffolded tutorials cannot launch missing gameplay.
- Reward policy is explicit: no reward, tutorial-only reward, or campaign reward. The recommended first policy is no persistent reward.
- Tutorial status values are limited, for example `planned`, `scaffolded`, and later `playable`.

Validation should fail before UI exposes a broken tutorial.

Current metadata/runtime status:

- `proving_grounds_basics` is `playable` as the first onboarding shell.
- It is selectable from the main menu through the Tutorial button.
- It launches existing `first_claim` battle content in tutorial mode with rewards disabled.
- It shows a guided objective overlay with Next Objective and Complete Tutorial actions.
- It advances through camera, hero selection, hero movement, Crown Shrine capture, resource income, Command Hall selection, Barracks construction, Militia training, rally point, Rally Banner, safe pressure, and finish steps.
- It returns to the main menu instead of campaign Results because there are no rewards to show and no campaign state to apply.
- It does not grant rewards.
- It does not persist progress.

## 8. Risks

Too much tutorial text:

- Mitigation: use short prompts, step labels, and concise feedback. Put deeper reference text in optional help, not blocking prompts.

Brittle e2e:

- Mitigation: prefer semantic helper functions and stable test IDs. Avoid raw coordinate assertions except where the canvas interaction itself is the test.

Confusing with campaign:

- Mitigation: call it Proving Grounds, keep it optional, and do not place it inside the campaign graph until a later explicit decision.

UI clutter:

- Mitigation: entry point should be modest. Do not crowd the main menu or campaign map with tutorial marketing copy.

Save ambiguity:

- Mitigation: first implementation should require no save field. If persistence is needed later, add save fixtures and no-op migration tests first.

False confidence:

- Mitigation: tutorial e2e proves onboarding flow, not full balance, route feel, or Cinderfen readiness.

## 9. Future Implementation Phases

1. Docs only.
1. Docs only. Completed.
2. Tutorial metadata and validation, no launch path. Completed.
3. Tutorial scene/mode shell or battle setup shell, no rewards and no save change. Completed.
4. First guided objective: selection, movement, capture. Completed inside the playable shell.
5. Construction/training/rally objective. Completed inside the playable shell.
6. Hero ability and small enemy pressure objective. Completed inside the playable shell.
7. Tutorial completion path. Completed as a direct return to main menu with no rewards.
8. Telemetry and e2e hardening. Future work.
9. Human readability pass. Future work.

## Non-Negotiables

- Do not add a new map in the first implementation.
- Do not add units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, or multiplayer.
- Do not change Cinderfen balance.
- Do not change save format without a separate save audit and fixture gate.
- Do not make tutorial completion mandatory for campaign play.
- Do not use external generated assets or paid API dependencies.
