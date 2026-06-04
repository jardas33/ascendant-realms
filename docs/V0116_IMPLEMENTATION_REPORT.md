# v0.116 Implementation Report

## Scope

Created the reviewed architecture direction, desktop-engine spike preparation pack, and engine-neutral Salto fixture tooling requested for v0.116.

## Start State

- Branch: `main`
- Expected commit: `9e6b2437101c8e31944ce8d7706ed078f622b888`
- Expected v0.115 gate: `docs/V0115_BROWSER_PERFORMANCE_GATE.md` Result `RED`
- Repository status before edits: clean and synchronized with `origin/main`

## Added Documentation

- `docs/V0116_ARCHITECTURE_DECISION_RECORD.md`
- `docs/V0116_ENGINE_CANDIDATE_MATRIX.md`
- `docs/V0116_RECOMMENDED_ENGINE_SPIKE_ORDER.md`
- `docs/V0116_DESKTOP_SPIKE_ACCEPTANCE_CONTRACT.md`
- `docs/V0116_DESKTOP_SPIKE_FIXTURE_EXPORT_SPEC.md`
- `docs/V0116_ENGINE_SPIKE_SCORECARD_TEMPLATE.json`
- `docs/V0116_EMMANUEL_ARCHITECTURE_REVIEW_PACKET.md`
- `docs/V0116_REFERENCE_ART_CONTINUATION_BOUNDARY.md`

## Added Tooling

- `npm run export:desktop-spike-fixture`
- `npm run validate:desktop-spike-fixture`
- `src/game/desktop-spike/DesktopSpikeFixture.ts`
- `src/game/desktop-spike/DesktopSpikeFixture.test.ts`
- `tools/exportDesktopSpikeFixture.ts`
- `tools/validateDesktopSpikeFixture.ts`

## Fixture Boundary

The fixture is generated under `artifacts/desktop-spike-fixture/latest/` and ignored by git. It derives from existing portable content, stable IDs, save fixture manifest, representative benchmark definitions, Lume data, and v0.107/v0.115 docs.

It preserves:

- No engine selected.
- No engine project.
- No desktop wrapper.
- No engine dependency.
- No runtime gameplay, save, stable-ID, network, or art integration change.
- `linked_ward` damage taken multiplier exactly `0.92`.
- v0.115 browser gate result `RED`.

## AI-First Requirement

The engine matrix, spike order, acceptance contract, review packet, and scorecard template score future candidates heavily on AI-operability, deterministic automation, editor-optional routine work, manifest-driven import, CLI build/export/benchmark/package support, and one-command validation from a fresh checkout.

## Visual Ambition

The documentation records the intended original RTS/RPG direction: the spirit of a super-cool 2026 evolution of Warlords Battlecry, but with original Ascendant Realms IP, factions, lore, assets, UI, mechanics, and visual identity. Future spikes should assess polished 2D versus fixed-camera 2.5D presentation, faction silhouettes, Salto terrain, lighting/VFX, persistent hero readability, and tactical clarity.

## Verification

```text
npm test - PASS, 120 files / 830 tests.
npm run build - PASS with the known large Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run export:portable-content - PASS, 229 stable manifest entries.
npm run validate:portable-content - PASS, deterministic double export.
npm run test:save-translation-contract - PASS, 16 fixtures, 11 translated, 2 quarantined, 3 rejected.
npm run export:desktop-spike-fixture - PASS.
npm run validate:desktop-spike-fixture - PASS, deterministic double export of 12 files.
git diff --check - PASS with Git's line-ending warning for .gitignore.
```

Desktop spike fixture hash:

```text
d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3
```

Package generation and `npm run verify:playtest-package` were not run because v0.116 did not change package metadata or private package contents.

## Closeout

v0.116 must be committed with:

`Checkpoint v0.116 reviewed architecture direction desktop-engine spike preparation pack and engine-neutral Salto fixture`

Do not start v0.117 automatically.
