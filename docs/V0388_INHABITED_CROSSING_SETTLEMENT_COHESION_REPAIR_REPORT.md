# v0.388 Inhabited Crossing Settlement Cohesion Repair

## Scope

This is a bounded, opt-in visual repair following ChatGPT's v0.387 `REJECT` verdict. It addresses only the concrete rendered defects: a visibly continuous bridge-to-yard-to-door route, physical separation between the house and barn, five independently readable yard functions, an unobstructed third character, and restored settlement-versus-bridge value hierarchy.

## Base and ancestry

- Base HEAD: `75ecc30a22fc13046fd36bc82f4be949c137fbea`
- Branch: `codex/v0215-v0226-recovery`
- v0.387 remains retained as the rejected reference and is not overwritten.
- Accepted v0.380 infrastructure GLB hash remains `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`.

## What changed

- Added `desktop-spikes/godot-salto/scenes/v0388_inhabited_crossing_settlement_cohesion_repair.tscn` and its isolated script.
- Kept one primary Barrosan house and one subordinate agricultural barn with a clear gap and readable entrances.
- Replaced the five disconnected visible patches with one continuous ribbon mesh from the bridge landing through the working yard to the house door; five named segment nodes remain as audit metadata only.
- Kept exactly five yard groups: cart, firewood/lumber, barrel-crate storage, workstone/workbench, and fence/gate.
- Added exactly three complete static source-diverse roles: Farmer resident, Worker traveller/porter, Adventurer crossing guard.
- Moved the barn into a clear, separated L-position, moved the worker into open yard space, spread and enlarged the yard groups, and added localized neutral-warm fill while lowering the bridge-dominant base key.
- Added three real iteration directories and a nine-file review pack.

## What did not change

No gameplay, state chain, movement, animation, navigation, pathfinding, combat, selection, AI, economy, construction, production, save, stable-ID, or default-runtime behavior was added or altered. v0.387 and the accepted bridge/river/road/landing infrastructure remain available.

## Rendered evidence

The seven final images are actual Godot renders at 1920x1080. The primary/context and role-audit frames visibly contain all three figures. The detail frames show the separated buildings, bridge, river, path threshold, and yard functions. A grayscale primary is included for value review; black-frame rejection is recorded in `09_VALIDATION.json`.

## Asset provenance

The primary and subordinate are existing repository-authored/accepted Barrosan assets. The three character and prop assets are the already-intaken Quaternius v0.370 package, tracked by the existing third-party notice. No new external download or protected-game asset was introduced.

## Validation

- Dedicated command: `npm run godot:validate:v0388-inhabited-crossing`
- Capture command: `npm run godot:capture:v0388-inhabited-crossing`
- Smoke command: `npm run godot:smoke:v0388-inhabited-crossing`
- Review pack: `artifacts/manual-review/v0388-inhabited-crossing-settlement-cohesion-repair/`
- Iteration evidence: `artifacts/work/v0388-iteration-01/` through `-03/`
- Retained validators passed: v0.386, v0.385, v0.384, v0.383, v0.382, v0.381, and v0.380.
- Full local checks passed: `npm test` (887 tests), `npm run build`, content validation, art-intake validation, runtime-art-slot validation, artifact retention, `npm run godot:all`, and `git diff --check`.

## Provisional evaluation for external review

The composition was submitted for external visual review rather than self-declared acceptance. ChatGPT returned `REJECT` after inspecting the seven real renders. The house and barn are now clearly separate and all three figures are visible, but the route still disappears into undifferentiated ground before the entrance, the barn reads detached rather than farmyard-linked, firewood/workstation/fence remain ambiguous, two figures are crowded against the house, and grayscale still gives the bridge the strongest visual dominance. These are the exact v0.389 repair targets.

## Final state

## Confirmed closeout

- Commit: `b72c5c60a62eeccfdb3c7ddce627f1bd0fee5cd6`
- GitHub Actions: run `30186632225` — success for the exact commit SHA.
- Branch: `codex/v0215-v0226-recovery`.
- Tracked working tree: clean and synchronized with origin at 0 ahead / 0 behind.
- Pre-existing untracked generated artifacts were intentionally left untouched.
