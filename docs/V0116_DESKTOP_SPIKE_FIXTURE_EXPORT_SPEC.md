# v0.116 Desktop Spike Fixture Export Spec

## Purpose

Create one deterministic, engine-neutral Salto fixture pack for future desktop spike review. The fixture is a downstream contract derived from existing content, stable IDs, save-translation fixtures, benchmark definitions, and reference-only art docs.

## Boundary

- No engine selection.
- No engine project.
- No desktop wrapper.
- No engine dependency.
- No gameplay, AI, pathing, save, stable-ID, network, or runtime art change.
- No generated image or runtime art integration.
- No v0.117 start.

## Commands

- `npm run export:desktop-spike-fixture`
- `npm run validate:desktop-spike-fixture`

The validation command writes the fixture, validates the payload, validates the scorecard template, checks repository boundaries, and performs a deterministic double export.

## Output Root

`artifacts/desktop-spike-fixture/latest/`

This root is intentionally ignored by git. It is regenerated from repository files.

## Output Files

| File | Purpose |
| --- | --- |
| `README.md` | Human-readable fixture boundary and file index. |
| `scene-fixture.json` | Engine-neutral representative Salto scene contract. |
| `content-subset.json` | Selected content entries derived from portable content export. |
| `stable-id-subset.json` | Stable-ID snapshot and manifest subset for selected IDs. |
| `save-fixture-index.json` | Read-only v0.102 save fixture index. |
| `benchmark-contract.json` | Tier S/M/L and Results-transition benchmark expectations. |
| `expected-parity.json` | No-change parity expectations for future spikes. |
| `visual-placeholder-contract.json` | v0.107 reference-only art boundary. |
| `input-contract.json` | Representative RTS input and feedback expectations. |
| `results-contract.json` | No-save Results transition expectations. |
| `qa-checklist.md` | Manual and automated future-spike checklist. |
| `fixture-hashes.json` | SHA-256 hashes and aggregate fixture hash. |

## Authoritative Inputs

- `src/game/portable/PortableContentExport.ts`
- `src/game/portable/stable-id-snapshot.json`
- `tests/fixtures/saves/v0102/manifest.json`
- `src/game/playtest/RepresentativeBattleBenchmark.ts`
- `src/game/data/lumeNetworks.ts`
- `docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json`
- `docs/V0115_BROWSER_PERFORMANCE_GATE.md`

## Required Constants

- Checkpoint: `v0.116`
- Generated timestamp: `deterministic-v0116`
- `linked_ward` damage taken multiplier: exactly `0.92`
- v0.115 browser gate: `RED`
- Current save version: `2`

## AI-First Future Spike Expectations

The fixture should allow a future engine candidate to prove automation:

- Content import is manifest-driven.
- Scene creation is scriptable or text-editable.
- Asset registration avoids routine manual editor drag-and-drop.
- Build, export, benchmark, and Windows packaging are scriptable.
- Fresh checkout validation is documented.
- Any unavoidable editor steps are explicitly reported in the scorecard.

## Visual Benchmark Expectations

Future candidates should use this fixture to assess a modern original RTS/RPG visual direction: fixed-camera 2D or 2.5D, strong unit and faction silhouettes, atmospheric Salto terrain, modern lighting/VFX, central persistent hero readability, tactical clarity, and a polished game UI.
