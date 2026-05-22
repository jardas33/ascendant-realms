# v0.16.9 Control Visual Readability Audit

Date: 2026-05-22

## Scope

Audit control readability only. No new runtime art/assets were added, no cursor art was replaced, and no UI feature was implemented in this pass.

## Attack Cursor And Hover

Current state:

- v0.16.7 made enemy hit tolerance more forgiving.
- Existing tests confirm visible enemy body/edge hover resolves to attack intent.
- Empty nearby terrain remains non-targetable.

Readability risk:

- The existing cursor may still be visually subtle even when the hit area is correct.
- Dense clusters can make it hard to know which enemy will receive the click.

Future non-art options:

- stronger existing CSS cursor choice if supported
- clearer selected-unit order summary
- hover outline or existing selection-ring reuse if already available and approved

Deferred:

- new attack cursor art
- new VFX
- new target decals

## Dense Combat Clusters

Current automated evidence covers contact and group edge cases, but not human visual parsing.

Watchpoints:

- overlapping health bars
- small enemies near hero feet
- hover target ambiguity between adjacent enemies
- whether melee contact reads as attack range

## Behaviour Buttons

Current state:

- `Guard Area` is default.
- `Hold Ground`, `Guard Area`, and `Press Attack` have automated mode-difference coverage.
- Browser tests assert mode switching and side-panel copy.

Watchpoints:

- whether testers understand the difference without reading docs
- whether mode labels are remembered after combat starts
- whether `Press Attack` sounds too aggressive compared with its bounded pursuit

## Retreat / Order Feedback

Current state:

- explicit move-away suppression has deterministic and browser coverage.
- order summary can show movement/repositioning states.

Watchpoints:

- if a unit is physically blocked, testers may read it as disobedience
- if enemies continue chasing, testers may think retreat failed even when the order was accepted
- group retreat needs visual confirmation for each selected unit when clusters are dense

## Recommendation

Use Emmanuel's next manual retest and the first external tester batch to separate mechanical correctness from readability. Do not change art or UI until repeated human notes identify the same readability blocker.

