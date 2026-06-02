# v0.106 Runtime Art Slot Contract

Status: implemented as a typed runtime adapter and validator. No generated or imported art is included.

## Purpose

v0.106 creates stable runtime-facing art slots so future approved assets can be integrated without changing gameplay, saves, stable IDs, or current placeholder behavior. The slot contract is future-facing: every slot must resolve today through a known procedural, CSS, DOM, or Phaser-vector fallback.

## Runtime Rule

- A slot may load an image only when its assigned asset is `runtime-integrated`.
- `runtime-candidate-approved` is not enough to load.
- Missing art never blocks runtime.
- Candidate-review workspaces are never runtime paths.
- Direct `public/assets/final` bypasses are rejected.
- Private diagnostics and mock routing are hidden in public posture.

## Slot Owners

The contract covers these runtime surfaces:

- Main menu: `menu-background`, `logo-lockup`, `primary-button-frame`.
- Campaign: `campaign-background`, `route-frame`, `chapter-banner`, `mission-node-frame`, `selected-node-frame`, `locked-node-frame`.
- Battlefield: terrain, fog, selection/capture rings, objectives, minimap, and Lume slot families.
- Units: Barrosan hero/worker/militia/ranger/acolyte and Ashen raider/brute/hexer/commander.
- Buildings: command hall, barracks, shrine, watchtower, mine, and construction state.
- UI: HUD, command panel, Results, hero, relic, stronghold, intel, and reputation frames.

## Files

- `src/game/art/RuntimeArtSlotTypes.ts`
- `src/game/art/RuntimeArtSlots.ts`
- `src/game/art/RuntimeArtSlotAdapter.ts`
- `tools/runtime-art-slots/validateRuntimeArtSlots.ts`
- `src/game/playtest/PrivateRuntimeArtSlotDiagnostics.ts`
- `src/game/styles/runtime-art-slots.css`

## Validation

Use:

```text
npm run validate:runtime-art-slots
```

The validator checks stable slot order, fallback coverage, v0.105 registry references, review-state gates, allowed runtime paths, and private-only diagnostics posture.

## Not Changed

No save-version bump, save field, localStorage key, stable ID rename, gameplay rule, reward, balance value, map, faction, generated image, imported image, runtime title, desktop path, engine choice, or public diagnostic control is added by this checkpoint.
