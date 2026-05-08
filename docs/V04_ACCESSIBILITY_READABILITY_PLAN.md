# v0.4 Accessibility And Readability Plan

Date: 2026-05-07

Scope: focused accessibility and human-readability polish for the frozen `Prototype v0.3` / `Cinderfen Route Baseline` and frozen `v0.3.1` polish layer. This pass does not add maps, units, factions, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, or new gameplay systems.

## Baseline Read

Inputs reviewed:

- `docs/V031_MOBILE_READABILITY_AUDIT.md`
- `docs/V031_POLISH_RELEASE_REPORT.md`
- `docs/CINDERFEN_ROUTE_READINESS_GATE.md`
- `docs/V03_RELEASE_CANDIDATE_REPORT.md`
- `src/game/scenes/SettingsScene.ts`
- `src/game/styles/settings.css`
- `src/game/systems/InputSystem.ts`
- Current smoke/layout e2e coverage around Settings and Cinderfen readability

Current state:

- Automated mobile/readability coverage finds no critical horizontal overflow on covered Cinderfen surfaces.
- Remaining watch items are density and scan hierarchy, especially Campaign Map panels, Waystation services, Aftermath choices, Cinder Shrine salience, and retinue/rival/trophy panels.
- Settings already owns reduced motion, floating text, screen shake, colorblind minimap palette, UI scale, fog override, and keyboard reference controls.
- The safest first polish surface is Settings copy and keyboard reference clarity because it does not touch campaign rules, battle tuning, save schema, maps, units, or progression.

## Accessibility Priorities

| Priority | Value | Risk | Safe first slice |
| --- | --- | --- | --- |
| Settings label clarity | Helps players understand motion, visibility, minimap, fog, and UI scale before battle. | Low if setting keys and values stay unchanged. | Improve labels and concise hints in `SettingsScene.ts`. |
| Keyboard/control reference | Helps keyboard and mobile-adjacent players recover core battle verbs without opening docs. | Low if it mirrors existing `InputSystem` behavior. | Add Shift-selection and right-click enemy clarity; keep existing commands. |
| Reduced motion readability | Makes accessibility intent visible without adding a new setting. | Low. | Explain that reduced motion quiets non-essential motion. |
| UI scale clarity | Makes the existing scale slider less ambiguous on dense route panels. | Low. | Explain it scales menus, route panels, and the battle HUD together. |
| Mobile command-panel hints | Helps small-screen players favor visible command buttons while preserving hotkeys. | Low if copy-only. | Add a concise note in the keyboard reference. |

## Implemented Low-Risk Polish

Implemented in this pass:

- Settings subtitle now names battle controls as part of the local profile surface.
- Accessibility toggles now use clearer labels and short hints:
  - Reduced Motion
  - Combat Floating Text
  - Screen Shake Feedback
  - Colorblind Minimap Palette
- UI Scale now states that it scales menus, route panels, and the battle HUD together.
- Fog of War is now labeled as `Fog of War Override` with clearer option labels:
  - `Use map default`
  - `Always on`
  - `Always off`
- Keyboard Reference now calls out:
  - Shift + left click for additive selection
  - Right click ground for movement or rally points
  - Right click enemy for direct attacks
  - Shift+A then right click for attack-move
- A compact mobile note points players toward command panel buttons first on small screens.

## Explicit Non-Goals

- No gameplay behavior changes.
- No balance changes.
- No save format changes.
- No new settings fields.
- No Cinderfen route content changes.
- No route progression changes.
- No map/objective/reward changes.
- No new systems.
- No selector or test-id removal.

## Remaining Watch Items

- Campaign Map density still needs human review with a real browser, especially retinue, rival intel, trophies, and reputation.
- Cinder Shrine salience remains a battle readability watch item.
- Waystation services and Aftermath choices remain text-dense on small screens.
- Layout e2e remains the automated guardrail, but subjective scan quality still needs human judgment.

## Verification Plan

Required for this phase:

```text
npm test
npm run build
npm run test:e2e:smoke
npm run test:e2e:layout
npm run playtest:sim
```

The layout lane is the key browser guardrail because this pass changes visible Settings text and CSS.

Phase verification completed:

- `npm test` - passed, 270 tests.
- `npm run build` - passed; known Vite warning remains for the intentionally isolated `vendor-phaser` chunk.
- `npm run test:e2e:smoke` - passed, 10 tests.
- `npm run test:e2e:layout` - passed, 21 tests.
- `npm run playtest:sim` - passed, 255 simulated runs across 85 campaign battle nodes.
- `git diff --check` - passed.
