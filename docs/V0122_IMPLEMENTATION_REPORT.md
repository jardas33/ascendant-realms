# v0.122 Godot Implementation Report

Status: implemented; final verification is recorded during checkpoint closeout.

v0.122 extends the repository-driven Godot Salto spike with a generated content-subset adapter proof, stable-ID validation, read-only save-fixture posture, and a bounded fixed-seed rules-parity harness.

Implemented:

- Added eight text-based GDScript adapters for content registry, stable IDs, save fixtures, units, buildings, sites, Lume, and Results.
- Extended the fixture importer to run adapter validation from generated JSON only.
- Added deterministic v0.122 artifact generation under `artifacts/desktop-spikes/godot-salto/v0122/`.
- Added fixed-seed parity checks for both 2D and 2.5D placeholder modes.
- Preserved the v0.121 procedural visual foundation as the visual carrier for the same spike.
- Advanced the future-boundary guard to block v0.123 follow-up docs instead of authorized v0.122 docs.
- Added v0.122 docs, handoff updates, and roadmap updates.

Not changed:

- Browser runtime.
- Browser gameplay, balance, AI, pathing, saves, rewards, campaign, content IDs, or stable IDs.
- Runtime art paths or imported/generated art.
- Final engine choice.
- Full desktop port.
- Multiplayer.

Required verification:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run export:portable-content`
- `npm run validate:portable-content`
- `npm run export:desktop-spike-fixture`
- `npm run validate:desktop-spike-fixture`
- `npm run godot:all`
- `npm run godot:fresh-checkout:validate`
- `git diff --check`
