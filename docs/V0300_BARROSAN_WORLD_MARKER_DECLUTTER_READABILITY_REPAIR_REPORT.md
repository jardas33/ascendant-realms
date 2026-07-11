# v0.300 Barrosan World Marker Declutter and Readability Repair

## Checkpoint

- Base: `252391e5330061a1745196fb6e9f34f2aacbe687` (accepted v0.299)
- Branch: `codex/v0215-v0226-recovery`
- Scope: opt-in visual layout repair only
- Feature: readable world-marker lanes for the accepted Barrosan chain through `BRIDGE PRESSURE STABILIZED`

## Problem and resolution

The v0.299 proof frames exposed two presentation defects: the East bridge labels were crowded into one unreadable cluster, and superseded reserve-chain labels accumulated around the Field Barracks. v0.300 keeps the accepted marker nodes and state semantics, then applies a v0.300-only layout pass when the v0.300 review mode is requested.

The bridge labels remain exact and are placed in distinct readable lanes:

- `ROUTE PREVIEW`
- `DEPLOY AUTHORIZED`
- `SUPPORT DEPLOYED`
- `LINE REINFORCED`
- `PRESSURE STABILIZED`

Superseded Barracks/reserve labels are hidden for the opt-in presentation while their accepted marker nodes remain present and validator-readable. No new marker, state, button, gameplay system, or runtime mutation was added.

## Preserved contract

- The v0.287-v0.299 accepted chain is retained without renaming accepted labels.
- The v0.295 route remains exactly five static authored segments.
- v0.297 reserve support presence remains exactly once.
- v0.298 bridge-line integration remains static and exactly once.
- v0.299 stabilization remains deterministic at `Pressure 70/100`; repeated stabilization does not stack.
- Selected Defender, Reserve Support, and Field Barracks cards remain readable.
- The true default runtime remains unchanged; v0.300 is opt-in review-only presentation wiring.

## Implementation and proof

- Runtime layout and proof: `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- Capture step dispatch: `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- Capture wrapper: `tools/godot/captureGodotV0300BarrosanWorldMarkerDeclutterReadabilityRepairWindows.ps1`
- Dedicated validator: `tools/godot/validateGodotV0300BarrosanWorldMarkerDeclutterReadabilityRepairWindows.ps1`
- Validator core: `tools/godot/saltoV0300BarrosanWorldMarkerDeclutterReadabilityRepairTool.mjs`
- Review-pack builder: `tools/godot/buildV0300BarrosanWorldMarkerDeclutterReadabilityRepairPack.py`
- Package commands:
  - `npm run godot:capture:salto-barrosan-world-marker-declutter-readability-repair`
  - `npm run godot:validate:salto-barrosan-world-marker-declutter-readability-repair`

The review pack contains the 41 requested numbered proofs, a 40-frame contact sheet, and a black-frame rejection report. Runtime capture warnings from the headless renderer are rejected as evidence; when a renderer frame is unavailable, the pack builder emits a deterministic static contract card instead of accepting a black frame.

## Validation record

The dedicated v0.300 validator checks source scope, proof snapshots, marker uniqueness, label-lane separation, accepted chain retention, route/support/integration counts, pressure idempotence, selected-card cleanliness, and all forbidden gameplay/default-runtime mutations. The retained validator ladder and repository-wide checks are run during closeout before commit.

## Review artifact

`artifacts/manual-review/v0300-barrosan-world-marker-declutter-readability-repair/`

Final commit, exact-SHA GitHub Actions result, and clean/synced repository status are recorded in the closeout response after the push completes.
