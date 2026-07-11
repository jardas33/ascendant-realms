# v0.298 Barrosan Static Bridge Support Integration Gate

## Scope

Opt-in static integration after v0.297 `RESERVE SUPPORT DEPLOYED`. `Integrate Support` produces `SUPPORT INTEGRATED`, one `LINE REINFORCED` marker, and one static bridge-line reinforcement visual.

## Base HEAD and branch

- Base: `10b477fbc2f9508f3e91c0064a9e7d46a60bc7f9`
- Branch: `codex/v0215-v0226-recovery`

## What changed / what did not change

Reserve Support, Defender, and Field Barracks receive the requested integrated static card truth. The v0.287-v0.297 chain, five v0.295 route segments, deployed-support presence, true default runtime, positions, bridge pressure, and resources remain unchanged. No movement, pathfinding, route following, combat, damage, HP loss, projectiles, death, AI, waves, or fog was added.

## Evidence

The proof records one integration state, one marker, one static integration visual, one retained support presence, five static route segments, idempotence, readable cards, and all forbidden systems absent.

- Review pack: `artifacts/manual-review/v0298-barrosan-static-bridge-support-integration-gate/`
- Validator: `npm run godot:validate:salto-barrosan-static-bridge-support-integration-gate`
- Retained ladder: v0.297 through v0.269 and v0.259 invariant.
- Full local validation: tests, build, content/art/runtime checks, artifact retention, Godot suite, and diff check.
- CI and final repository state are recorded at closeout.
