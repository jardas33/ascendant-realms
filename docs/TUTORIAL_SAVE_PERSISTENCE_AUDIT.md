# Tutorial Save Persistence Audit

Date: 2026-05-08

Status: current playable Tutorial / Proving Grounds shell is non-persistent and does not require a save-version bump.

## Scope

This audit covers the first playable Tutorial / Proving Grounds shell added after the v0.5 save/content-validation gate. It checks whether tutorial launch, tutorial battle state, tutorial completion, and tutorial exit write to hero saves, campaign saves, settings saves, inventory/equipment state, XP/skills, resources, retinue/rival/trophy state, or localStorage.

## Launch Path

- Main menu `Tutorial` uses `MainMenuScene.startTutorial()`.
- It creates a transient existing Warlord hero named Aster with `createNewHeroSave(...)`.
- It creates a battle request with `createTutorialBattleLaunchRequest(...)`.
- The launch request sets `mode: "tutorial"`, `sourceId: "proving_grounds_basics"`, `mapId: "first_claim"`, Story difficulty, and `rewardsDisabled: true`.
- The launch path starts `BattleScene` directly and does not call `SaveSystem.saveHero`, `SaveSystem.saveCampaign`, or `SaveSystem.saveGame`.

## Runtime Save Writes

Tutorial runtime reads settings through `SaveSystem.load()?.settings` so existing accessibility/readability preferences still apply. It does not write settings.

Tutorial runtime does not create a campaign save. It does not call campaign node completion, campaign reward, retinue update, rival update, trophy update, town service, event choice, Stronghold, or campaign resource write paths.

Tutorial completion uses `BattleScene.advanceTutorialStep()` for the final step and returns directly to the main menu. It does not enter normal Results reward/equip/campaign-return actions.

If a tutorial battle ever reaches normal battle end conditions, `endBattleAndOpenResults()` treats tutorial launches as rewards-disabled and returns to the main menu before normal save writes.

## Domain Audit

| Domain | Tutorial behavior | Protection |
| --- | --- | --- |
| Hero save creation | No persistent hero save is created. Aster is transient launch data only. | Smoke e2e asserts `localStorage` remains empty after launch, completion, and exit. |
| Settings | Existing settings may be read and applied. Tutorial does not save settings. | No tutorial code calls `SaveSystem.saveSettings`. |
| Campaign progress | No campaign node is completed, unlocked, locked, or selected. | Tutorial mode is not a campaign node and bypasses `completeCampaignNodeWithRewards`. |
| Inventory/equipment | No items are awarded and no equipment changes persist. | `BattleRuntime.completeBattle()` returns empty rewards and starting hero data for tutorial launches. |
| XP/skills | Tutorial kills do not award live hero XP when rewards are disabled; runtime completion reports zero XP. | `BattleScene.handleKill()` skips hero/unit XP awards for `rewardsDisabled`; runtime tests cover no-reward completion. |
| Campaign resources | No campaign resources are granted. Battle-local resources are transient. | Completion bypasses campaign reward application. |
| Event choices/town services | No event or town-service state is touched. | Tutorial is not on the campaign map. |
| Stronghold upgrades | No purchases or ranks are touched. Existing upgrade effects are not part of tutorial launch modifiers. | Launch modifiers are empty. |
| Retinue | No retinue units are deployed or updated. | Tutorial launch has no retinue and does not call retinue update after battle. |
| Rival state | No rival state changes. | Tutorial has no campaign node/enemy hero reward context and bypasses rival updates. |
| Rival trophies | No trophy records are created. | Trophy grants only happen through campaign/rival reward flows. |
| Save version | No new save fields or migration are required. | Tutorial completion is non-persistent for this shell. |

## Existing Tests

- `src/game/battle/BattleLaunchRequest.test.ts` verifies tutorial launch requests are rewards-disabled and rejects tutorial requests that could grant rewards.
- `src/game/battle/BattleRuntime.test.ts` verifies tutorial completion returns the starting hero, zero XP, empty rewards, no inventory, no completed battles, and `shouldSaveHero: false`.
- `tests/e2e/smoke.spec.ts` verifies the playable tutorial launch/completion path leaves `localStorage.getItem(SAVE_KEY)` null and that defeating the tutorial pressure Raider grants no live hero XP or runtime XP.
- `tests/e2e/smoke.spec.ts` separately verifies Exit Tutorial returns to main menu without saving.

## Gaps

- There is no dedicated browser test for launching the tutorial while a settings-only save already exists. Current code only reads settings during tutorial launch/runtime, and `SaveSystem` already has settings-only coverage, but a future persistence pass should add this if tutorial completion state is ever stored.
- There is no persistent tutorial-completed flag yet. This is intentional for the first shell.
- There is no ResultsScene tutorial-specific no-reward panel. This is intentional because the current final step returns directly to the main menu.

## Policy

Do not add tutorial persistence until a separate save fixture/update phase exists. If a future tutorial-completed flag is desired, prefer an existing settings/statistics-safe field only after documenting the UX need, adding a fixture, and proving old saves normalize without a save-version bump. Do not persist tutorial rewards, campaign resources, campaign node state, inventory, XP, retinue, rivals, trophies, or Stronghold state from Tutorial / Proving Grounds.
