# v0.301 Player-Facing Presentation Mode / Debug Overlay Separation

## Scope

- Base HEAD: `be82d457209da3fc1539976b69d554573cdbaa6b`
- Branch: `codex/v0215-v0226-recovery`
- Scope: opt-in Barrosan presentation configuration and deterministic review evidence only.

The prototype previously used the review fixture itself as the player-facing view, leaving historical proof labels visible. v0.301 separates that presentation concern without changing gameplay state or marker semantics.

## Modes

`PLAYER` is the clean player-facing presentation. It hides superseded historical and validator-only world labels while retaining the current `PRESSURE STABILIZED` marker, readable selected cards, current top strip, minimap, units, buildings, and terrain.

`DEBUG_REVIEW` is the audit presentation. It retains accepted marker nodes and labels, the five static route-guide segments, deployed-support presence, bridge-line integration visual, pressure evidence, and an ordered evidence rail for reserve milestones.

The mode is selected through the opt-in fixture flags `--salto-barrosan-player-presentation` and `--salto-barrosan-debug-review-overlay`. No in-game button or gameplay state was added.

## Preserved contract

- The accepted v0.287-v0.300 chain and all accepted labels remain unchanged.
- Pressure remains `70/100` after stabilization and is idempotent.
- Route preview remains five static authored segments.
- Support presence and integration visual remain exactly once.
- Selected-card text, button-row layout, top-strip state, resources, unit positions, and minimap state remain unchanged across modes.
- PLAYER -> DEBUG_REVIEW -> PLAYER restores the clean player presentation without duplicate nodes or visuals.
- True default runtime remains unchanged.

## Implementation and evidence

- Presentation mode and proof: `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- Fixture flags, checkpoint dispatch, and dual capture steps: `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- Capture wrapper: `tools/godot/captureGodotV0301BarrosanPlayerFacingPresentationDebugOverlaySeparationWindows.ps1`
- Dedicated validator: `tools/godot/saltoV0301BarrosanPlayerFacingPresentationDebugOverlaySeparationTool.mjs`
- Validator wrapper: `tools/godot/validateGodotV0301BarrosanPlayerFacingPresentationDebugOverlaySeparationWindows.ps1`
- Review-pack builder: `tools/godot/buildV0301BarrosanPlayerFacingPresentationDebugOverlaySeparationPack.py`

The review pack contains the 48 requested numbered proofs, separate PLAYER and DEBUG_REVIEW contact sheets, a combined comparison sheet, and a black-frame rejection report. Near-black headless renderer frames are rejected; deterministic contract cards are used when a usable renderer frame is unavailable.

Review pack: `artifacts/manual-review/v0301-player-facing-presentation-debug-overlay-separation/`

Dedicated command: `npm run godot:validate:salto-barrosan-player-facing-presentation-debug-overlay-separation`

## Validation and closeout

The dedicated validator checks both mode manifests, accepted chain evidence, label visibility separation, selected-card/top-strip/pressure invariants, route/support/integration counts, round-trip/idempotence proof, forbidden gameplay boundaries, review-pack completeness, and default-runtime preservation. The retained v0.300-v0.269 ladder, v0.259 invariant validator, repository checks, Godot suite, commit, exact-SHA CI, and final clean/synced state are recorded in the closeout response.
