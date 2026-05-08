# Tutorial / Proving Grounds Playable Shell Plan

Date: 2026-05-08

Status: implementation plan only. This document defines the first playable shell scope before code changes. It does not add a launch path, scene, gameplay behavior, map, unit, faction, reward, save field, or save-version bump.

## 1. Tutorial Scope

The first Tutorial / Proving Grounds playable shell should be an optional training mode that teaches the existing RTS/RPG controls and battle loop.

In scope:

- A visible main-menu Tutorial / Proving Grounds entry.
- A playable shell that reuses existing battle content and existing systems.
- Lightweight tutorial metadata, validation, view models, overlay text, and e2e coverage.
- No persistent reward and no campaign progression.

Out of scope:

- No campaign rewards or tutorial rewards.
- No save-version bump.
- No new maps.
- No new units.
- No new factions.
- No workers, enemy construction, crafting, diplomacy, procedural systems, multiplayer, desktop packaging, external generated assets, or paid APIs.
- No Cinderfen route, Chapter 1 balance, campaign graph, or skirmish balance changes unless a verified bug requires a narrow fix.

The tutorial should remain independent from campaign progression. It should not become a new campaign chapter or a prerequisite for New Campaign, Continue Campaign, or Skirmish.

## 2. Launch Surface

Preferred launch surface: a modest main-menu entry in `src/game/scenes/MainMenuScene.ts`.

Planned main-menu behavior:

- Add a `Tutorial` button with a nearby `Proving Grounds` label or concise supporting copy.
- Use a stable test id, likely `menu-tutorial`.
- Keep existing menu actions and version copy intact: New Campaign, Continue Campaign, Skirmish, Hero Inventory, Asset Gallery, Settings, Reset Save, and Credits / Info.
- Do not require a saved hero. The tutorial should create or use a transient tutorial hero.
- Do not write campaign save data when the button is clicked.

Phase sequencing:

- Phase 3 may open a safe informational panel or placeholder if the runtime shell is not ready yet.
- By the playable-shell phase, the same button should launch the actual Tutorial / Proving Grounds shell.
- Returning or exiting should go back to the main menu without touching campaign state.

Regression expectations:

- New Campaign still reaches Campaign Map.
- Continue Campaign still opens only with a valid campaign save.
- Skirmish still opens setup or hero creation exactly as before.
- Settings and Inventory behavior remain unchanged.

## 3. Tutorial Mode Choice

Chosen direction: add an explicit tutorial battle launch path that reuses `BattleScene` systems through a small tutorial-specific configuration, while keeping no-reward completion outside the campaign reward path.

Why this is the smallest maintainable approach:

- `BattleScene` already owns the RTS loop: selection, movement, capture sites, construction, training, rally points, hero abilities, fog, minimap, enemy AI, and HUD refresh.
- `first_claim` already exists as the safest teaching map and is already described as a balanced tutorial skirmish.
- Duplicating battle logic into a separate scene would be riskier than a narrow tutorial mode check.
- A dedicated tutorial wrapper or small scene can own launch/completion UI, but combat should continue to use the existing battle runtime where possible.

Implementation shape to prefer:

- Add a launch helper such as `createTutorialBattleLaunchRequest(...)` or equivalent.
- Add a `tutorial` mode to the battle launch model only if the code needs to distinguish no-reward completion from skirmish and campaign behavior.
- Use `BattleScene` for the actual playable space.
- Keep tutorial-specific checks explicit and localized, especially in battle ending and overlay state.
- Avoid making production code import test fixtures.

No-reward completion should not call `completeCampaignNodeWithRewards`, `SaveSystem.saveGame`, or normal victory reward granting. The safest first pass is a tutorial completion panel or overlay that exits to main menu, rather than pushing through the normal Results reward flow.

## 4. Existing Content Reuse

Map:

- Use `first_claim` unless implementation inspection proves it is too coupled to rewards.
- It already contains a readable base, nearby Crown Shrine, resource sites, neutral camps, enemy base, and delayed enemy pressure.

Hero:

- Use an existing transient hero save, preferably from `createNewHeroSave("Aster", "warlord", "exiled_noble")` or an equivalent helper.
- The transient hero should not be saved.
- Starting ability should be an existing Warlord ability, likely `rally_banner`, because it teaches the ability bar without adding content.

Units and buildings:

- Use existing player Command Hall, Militia, Ranger, Barracks, and current build/train/rally commands.
- Use existing enemy/neutral units already present on `first_claim`.
- Do not add dummy units or tutorial-only unit definitions.

Objectives:

- Reuse current battle primitives: select units, move, capture a site, build a Barracks, train Militia, set a rally point, use ability, defeat safe existing pressure or finish through tutorial conditions.
- Avoid tying tutorial completion to destroying the enemy stronghold if that makes the tutorial too long.

Rewards:

- No item, XP, campaign resources, reputation, retinue, rival, trophy, Stronghold, or campaign-node reward should be granted.
- If a results-like surface is needed, it must clearly be a tutorial completion surface with no rewards.

## 5. Tutorial Steps

The first playable flow should be linear and short. Copy should be concise enough to read during play and should avoid blocking controls.

Planned step order:

1. Camera and controls: show how to pan or center the hero, and point to minimap/camera basics without requiring a fragile camera assertion.
2. Select hero: require or detect the hero selection.
3. Move hero: require or detect movement away from the spawn area.
4. Capture site: guide the player to the existing Crown Shrine and detect player ownership.
5. Gather resources: show that captured sites generate battle resources; completion can depend on a captured-site resource tick or a safe resource threshold.
6. Select Command Hall: detect selecting the existing player Command Hall.
7. Build Barracks: use the existing build command and detect a completed Barracks.
8. Train Militia: use the existing training command and detect a trained Militia.
9. Set rally point: detect a rally point on the Barracks if the current building model exposes it safely.
10. Use hero ability: ask the player to select the hero and use an existing ability if available; this can be optional or hook-assisted if timing is fragile.
11. Defeat small enemy pressure: use existing safe pressure if practical; otherwise complete after the core build/train/rally lesson and document why enemy pressure was postponed.
12. Finish tutorial: show a clear completion message and return to the main menu.

The first implementation may collapse the camera/resources/pressure beats into informational steps if direct runtime detection would be brittle. It should still launch, guide, complete, and exit cleanly.

## 6. Gating And Persistence

Required guarantees:

- Tutorial is independent of campaign saves.
- Tutorial does not require an existing hero save.
- Tutorial does not award XP, items, campaign resources, reputation, retinue units, rival progress, or trophies.
- Tutorial does not mark campaign nodes complete or unlock campaign nodes.
- Tutorial does not update Stronghold purchases or town/event choices.
- Tutorial does not bump save version.

Persistence decision:

- Do not persist tutorial completion in the first playable shell.
- Existing settings can still be read and respected.
- If completion persistence becomes desirable later, add a save audit and fixture coverage before introducing any field.

No-reward implementation checks:

- Tutorial completion should not call `SaveSystem.saveHero`, `SaveSystem.saveCampaign`, or `SaveSystem.saveGame`.
- If the shared battle runtime must complete a battle internally, tutorial mode should bypass reward granting and save writes.
- E2E should verify localStorage does not gain campaign completion, XP, or item rewards from the tutorial.

## 7. Tests

Content validation:

- Tutorial metadata validates.
- Playable tutorial metadata references an existing map.
- Playable tutorial has steps.
- The initial tutorial has `noReward: true`.
- Step types and any referenced units/buildings/abilities/resources/capture sites are valid.

Unit/view-model tests:

- Tutorial launch/config creation uses existing content and produces a no-reward request.
- Tutorial step model returns current step, instruction, hint, progress, and next step.
- Invalid step ids are handled safely.
- No-reward completion helpers, if added, cannot return normal rewards.

E2E smoke:

- Main-menu Tutorial / Proving Grounds entry is visible.
- Clicking it does not crash.
- Tutorial overlay is visible once playable.
- Exit Tutorial returns to main menu.
- Existing New Campaign and Skirmish launch paths still work.

Deeper e2e or release coverage:

- Basic tutorial completion path using semantic hooks where needed.
- Skip/Exit path.
- No campaign save pollution after tutorial completion.
- No hero XP/item reward granted.

Lane placement:

- Keep one lightweight tutorial path in smoke.
- Put full completion coverage in release or deep-flow if smoke runtime grows too much.

## 8. Risks And Mitigations

UI clutter:

- Keep the main-menu entry compact and avoid making the tutorial look like a campaign chapter.

Confusing tutorial with campaign:

- Use `Tutorial / Proving Grounds` language and no campaign-node unlocks.
- Return to main menu instead of Campaign Map.

Brittle e2e:

- Prefer semantic scene hooks and stable test ids for completion checks.
- Use real UI interactions for launch, overlay visibility, exit, and campaign/skirmish regressions.

BattleScene mode coupling:

- Keep tutorial-specific logic localized to launch creation, tutorial overlay/state, and no-reward completion.
- Do not fork broad BattleScene behavior.

Accidental rewards or save pollution:

- Add tests around no reward, no XP/item grant, and no campaign node completion.
- Keep completion non-persistent until a later save-fixture-backed decision.

Enemy pressure tuning:

- Use existing safe pressure only if it does not require map or balance edits.
- If current pressure makes the tutorial too long or flaky, postpone the enemy-pressure beat and document the gap instead of adding content.

Mobile/readability density:

- Keep overlay copy short.
- Use responsive constraints and layout tests before calling the shell complete.

## Preferred Phase Order After This Plan

1. Strengthen tutorial metadata and validation without launch UI.
2. Add the main-menu Tutorial / Proving Grounds launch surface.
3. Add the smallest tutorial scene/mode shell and transient hero launch.
4. Add pure guided-step view models.
5. Add a lightweight overlay with Exit Tutorial.
6. Wire the first playable flow through completion with no rewards.
7. Add stable e2e coverage and save-persistence audit.
8. Document content validation, readability, release status, and final verification.
