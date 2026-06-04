# v0.120 Implementation Report

v0.120 adds fresh-checkout reproducibility validation, a CI-style Windows posture, zero-editor automation contracts, and one-click guidance for the existing Godot Salto workflow spike.

## Implemented

- Added `tools/godot/validateGodotFreshCheckout.ps1`.
- Added `npm run godot:fresh-checkout:validate`.
- Added `GODOT_FRESH_CHECKOUT_VALIDATE_WINDOWS.bat`.
- Updated `GODOT_RUN_ALL_WINDOWS.bat` to include the fresh-checkout validation after the existing Godot all-in flow.
- Added `tools/godot/runGodotCiStyleWindows.ps1`.
- Added `npm run godot:ci-style:windows`.
- Added manual workflow-dispatch CI posture in `.github/workflows/godot-fresh-checkout-windows.yml`.
- Updated focused tests to enforce the v0.120 script/docs/workflow posture.
- Advanced the desktop-spike boundary guard to block the next Godot-specific v0.121 follow-up rather than authorized v0.120 docs.
- Added headless first-run Godot import priming and bounded temp cleanup retries for fresh Windows checkouts.

## Boundaries Preserved

- No gameplay change.
- No save migration, save writes, localStorage writes, or stable-ID rename.
- No art import or runtime art integration.
- No browser runtime replacement.
- No final Godot choice.
- No full port.
- No Unity, Unreal, Electron, multiplayer, content expansion, or v0.121 work.

## Verification Matrix

Required closeout commands:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run export:desktop-spike-fixture
npm run validate:desktop-spike-fixture
npm run godot:all
npm run godot:fresh-checkout:validate
git diff --check
```

Remote CI must be checked after the v0.120 commit is pushed.
