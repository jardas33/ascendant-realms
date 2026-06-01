# v0.96 First Session Audit

Status: implementation audit for `v0.96 First-Time Player Onboarding and Tutorial UX Rescue`.

## Scope

This audit covers only first-session presentation and guidance. It does not authorize gameplay, save, reward, campaign progression, stable ID, map, faction, unit, building, Lume, desktop, multiplayer, or art changes.

## Baseline

- Starting commit: `dc54bb7`, `Checkpoint v0.95 procedural battlefield readability and placeholder-world rescue`.
- Repository state before edits: clean and synced with `origin/main`.
- Latest remote CI release dry run on the v0.95 commit: passing.
- v0.95 package: `artifacts/playtest/ascendant-realms-private-playtest-dc54bb7`, clean package metadata.

## Audited First-Session Route

1. Main Menu.
2. New Campaign.
3. Ascendant creation.
4. Campaign Map.
5. Salto Outskirts selection.
6. First battle launch.
7. Selection, movement, hero ability, Worker/build/site tasks, combat.
8. Results.
9. Return to campaign.

## Findings

### Tutorial / Proving Grounds

- The playable Tutorial is already no-save/no-reward and launches on `first_claim`.
- The opening step starts with camera controls, not the higher-priority "select hero" action.
- Some steps combine multiple ideas in one visible instruction, especially capture, construction, and battle pressure.
- Worker site assignment is supported by runtime systems but is not a distinct tutorial objective.
- The overlay already supports drag, hide, reset, progress, and next objective, but not More Help, Dismiss/Reopen, or Focus Objective.
- Lume is excluded from Tutorial via existing network rules and must remain excluded.

### Campaign First Step

- Fresh campaigns select Salto Outskirts by default and keep the primary Start Battle action visible.
- First-step guidance exists in the Hero tab and selected mission details, but the map tab needs a compact recommended-next-action card that does not compete with the primary action.
- The existing guidance copy is informative but too long for the default first-campaign moment.

### Battle HUD And Help

- The Objective tracker, command panel, minimap, and status line are stable.
- Help is spread across command tooltips/details and not available as a compact grouped surface from the battle HUD or campaign shell.
- Existing command buttons already expose disabled reasons and should not be redesigned.

### Results

- Results already distinguish Tutorial no-reward state, ordinary rewards, replay state, and campaign return paths.
- v0.96 should preserve Results behavior and only rely on existing Results guidance.

## Implementation Direction

- Reorder and tighten Tutorial step copy around one primary action at a time.
- Add optional Tutorial metadata for a visible reason, hidden More Help, and Focus Objective target.
- Keep the Tutorial overlay non-blocking and keyboard reachable.
- Add a reusable compact help surface to battle HUD, pause menu, and campaign shell.
- Add a compact Salto next-action card without changing node status, unlocks, rewards, or save data.

## Deferrals

- No interactive onboarding scripting engine.
- No persistent onboarding preferences.
- No new tutorial map or custom markers.
- No final art, icon pack, or generated assets.
- No new Lume tutorial path.
