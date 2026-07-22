# v0.368 Ascendant Realms Playable Slice Visual Coherence

## Scope

v0.368 is a bounded, opt-in visual/game-feel pass over the accepted v0.367 Barrosan playable slice. It does not claim production readiness and does not change the underlying gameplay rules.

Base HEAD: `dfb1347c6bf619b377875a282ffa99b3c218c121`
Branch: `codex/v0215-v0226-recovery`

## What changed

- Added an opt-in coherent-slice route alongside the v0.367 fallback.
- Replaced the broad rectangular board with split land masses, irregular clearings, segmented roads, a recessed stream, and a structured timber bridge.
- Replaced the gold spheres with a small authored low-poly ore formation and vein accents.
- Reused the accepted Barrosan worker and militia source textures as grounded billboard units with restrained contact shadows and selection rings.
- Added compact HUD positioning while preserving the selected-card/action contracts and input pass-through.
- Added a non-opaque scaffold/footprint construction presentation.
- Added a deterministic bridge-constrained militia route through three authored waypoints before target pursuit; this reuses the v0.367 attack and damage rules.
- Added a dedicated four-frame raw PLAYER review pack, smoke manifest, package commands, and validator.

## Gameplay and runtime preservation

The v0.367 logic remains the gameplay base: gather, deposit, build, recruit, move, attack, retaliation, result, restart, and launcher return are unchanged in semantics. v0.368 adds only an opt-in authored bridge waypoint route for militia attack presentation; it does not add a generalized pathfinding system. The prototype does not add resources, buildings, units, factions, AI, persistence, or network behavior. The v0.367 route remains available as the explicit fallback; the true default runtime is unchanged.

The visual restart repair keeps static terrain/clearing parents and the stream glint under the retained world roots, and retains valid debug label references without changing gameplay state. The headed check confirmed launcher entry, Worker selection, and right-click mine command with the HUD allowing map input through.

## Visual evidence

The human-review pack is limited to five files:
`artifacts/manual-review/v0368-playable-slice-visual-coherence/`

The four raw PLAYER frames show the compact hamlet overview, translucent construction scaffold, completed Field Barracks/Militia state, and the Victory result. The images are real Godot renders, not title cards; black/blank evidence is rejected by the pack validator through a minimum-size gate.

## Commands

- `npm run godot:play:coherent-slice` — headed opt-in route.
- `npm run godot:smoke:coherent-slice` — deterministic gameplay/evidence smoke.
- `npm run godot:capture:coherent-slice` — four raw PLAYER captures.
- `npm run godot:validate:coherent-slice` — dedicated validator and pack gate.

## Validation evidence

Targeted v0.368 smoke/capture/validator and retained v0.367 validator pass. Full local checks pass: 887 Vitest tests, production build, content validation, art-intake validation, runtime-art-slot validation, artifact-retention validation, `npm run godot:all`, and `git diff --check`. The dedicated smoke manifest records Gold deposit, Barracks construction, Militia recruitment, bridge-route issuance, combat resolution, victory, restart restoration, HUD pass-through, and hidden diagnostic labels.

## Limitations

This is a small authored slice, not a production-wide art conversion. The bridge, terrain, ore, and construction geometry are deliberately low-poly and the accepted sprite-based character presentation remains a bounded compromise. Visual balance is judged from the four raw frames; no claim is made that the slice is production-ready.

## Closeout

Implementation commit: `5cd0c4cab31a37b0d34cbf4ce54a63ed1c4e8be8`

Exact GitHub Actions run: `29936962700` (`CI Release Matrix Dry Run`, run 539) — success for the exact implementation SHA. The Fast confidence job passed unit/pure-rule tests, production build, content validation, art-intake validation, E2E fast smoke, and production preview smoke.

The final documentation amendment is published after this run so the report remains truthful for the final pushed SHA. The repository is required to end clean and synchronized with `origin/codex/v0215-v0226-recovery`.
