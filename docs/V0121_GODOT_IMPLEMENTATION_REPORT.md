# v0.121 Godot Implementation Report

Status: implemented and verified.

v0.121 extends the existing repository-driven Godot Salto spike with a procedural 2.5D visual-foundation pass and 2D control comparison.

Implemented:

- Procedural 2.5D terrain plane, height bands, road, ford/water posture, quarry, shrine, ruin, structure silhouettes, role silhouettes, selection discs, Lume placeholders, fog posture, HUD placeholder, resource row, hero card, objective summary, and minimap/orientation placeholder.
- Scriptable presets: `CLEAN_READABILITY`, `ATMOSPHERIC_BALANCED`, and private `VFX_STRESS_PRIVATE`.
- Review-harness preset buttons and `--visual-preset=` argument support.
- v0.121 capture matrix under `artifacts/desktop-spikes/godot-salto/v0121/`.
- v0.121 benchmark comparison reports under the same ignored artifact root.
- Scaffold tests and desktop-spike boundary guard advanced to block v0.122, not authorized v0.121.

Not changed:

- Browser runtime.
- Gameplay, balance, AI, pathing, saves, rewards, campaign, content IDs, or stable IDs.
- Runtime art paths or imported/generated art.
- Final engine choice.
- Full desktop port.

Verification evidence:

- `npm test -- src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts src/game/desktop-spike/DesktopSpikeFixture.test.ts`
- `npm run export:desktop-spike-fixture`
- `npm run validate:desktop-spike-fixture`
- `npm run godot:test`
- `npm run godot:benchmark`
- `npm run godot:capture:review`
- `npm run godot:all`
- `npm run godot:fresh-checkout:validate`
- `npm test`
- `npm run build`
- `npm run validate:content`

Latest package evidence:

- Package: `artifacts/desktop-spikes/godot-salto/latest/AscendantRealmsGodotSalto-v0121-windows.zip`
- SHA-256: `2d6392a3a47c2fb9394ec252fdc38a2ec678e4bdb5e5b585bbc15556f7cfce6b`
- Size: 34.481 MB
