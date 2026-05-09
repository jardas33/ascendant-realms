# v0.6.1 Tutorial Feel Review

Date: 2026-05-09

Status: visible Browser feel pass plus a small layout-priority polish for Tutorial / Proving Grounds. This pass stays existing-content-only, no-reward, and non-persistent.

## Scope

This review continues the v0.6 Tutorial / Proving Grounds onboarding foundation with a narrow human-feel check. It does not add maps, units, factions, rewards, save fields, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

## Browser Pass

Target: `http://127.0.0.1:5173/` using the Codex in-app Browser.

Checked states:

- Main menu at the default desktop viewport.
- Tutorial / Proving Grounds launch from the main-menu Tutorial button.
- First objective overlay on desktop.
- First objective overlay on a 360 x 640 mobile-short viewport.
- Exit Tutorial return to the main menu.
- Browser console warning/error check.

Findings:

| Area | Result |
| --- | --- |
| Main-menu Tutorial entry | Clear and reachable. The accessible name remains `Start Tutorial / Proving Grounds`. |
| Desktop first overlay | Readable and centered without covering the core playfield action. |
| Mobile-short first overlay | The battle status banner painted over the tutorial overlay before polish, interrupting the first objective text. |
| Exit Tutorial | Returned to the main menu cleanly. |
| Console | No warnings or errors were reported during the Browser pass. |

## Change Made

The tutorial overlay now has explicit visual priority over transient battle feedback overlays:

- `src/game/styles/battle-feedback.css` gives status, placement, and hint feedback a lower z-index.
- `src/game/styles/battle-feedback.css` gives `.tutorial-panel` a higher z-index.
- `tests/e2e/layout.spec.ts` now checks that the tutorial overlay renders above battle status feedback during the responsive tutorial entry lane.

This is a layout-priority fix only. It does not change tutorial steps, copy, input flow, battle behavior, rewards, persistence, campaign state, save version, maps, units, factions, or balance.

## Post-Polish Browser Check

The 360 x 640 Browser refresh confirmed the first tutorial objective text was no longer visually interrupted by the status banner. Exit Tutorial still returned to the main menu, and the console remained free of warnings/errors.

## Focused Verification

```text
npm run test:e2e:layout -- --grep "tutorial entry"
PASS: 4 Playwright tests in 43.2s.
```

## Final Verification

```text
npm test
PASS: 42 test files, 315 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor warning.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.9m.

npm run test:e2e:layout
PASS: 25 Playwright tests in 12.4m.

Production preview Browser smoke
PASS: http://127.0.0.1:57919/ with Tutorial launch/exit and zero browser warnings/errors.
```

## Remaining Human-Feel Watch Items

- The tutorial is still twelve steps long and should be played by a human at normal speed before adding content.
- Mobile-short is visually safer after this polish, but real input comfort still needs hands-on review.
- Completion remains clear and explicit rather than celebratory; do not make it stronger unless no-reward/no-save clarity stays intact.
- Keep the full tutorial completion smoke path while it remains stable and near the current runtime band.
