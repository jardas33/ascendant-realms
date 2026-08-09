# v0.436 E3R — Real Player-Facing Tutorial Contract

## Scope

This bounded lane replaced the capture-only tutorial shortcut with the real `scenes/main.tscn -> scenes/game_world.tscn` How to Play entry and a read-only tutorial state snapshot. The harness performs normal player-facing actions only: camera input, selection, gather, placement, worker construction, queueing, hero movement, attack orders, damage, and Lume movement/capture observation.

## Result

The headed production run reached and captured real Steps 1–7, including real extraction, construction completion, production completion, hero position change, attack orders, and a combat damage event. It failed closed at Step 8 with `BLOCKED_E3R_LUME_OWNERSHIP_NOT_RECOGNIZED`: units were captured at the central site, but natural CapturePoint ownership did not transition. No completion or return-to-menu evidence was created, and this is not classified as an E3R pass.

## Evidence

- Review pack: `artifacts/manual-review/v0436-e3r-real-tutorial/session-a/`
- Last valid frame: `18_1366_TUTORIAL_ACTIVE.png`
- Blocker: `e3r-blocker.json`
- Final state: `e3r-final-state.json`
- Validator: `npm run godot:validate:v0436-e3r-real-tutorial`
- Source SHA in evidence: `e1aa6451b975444d8ccac011056adb1693ca8e88`
- Official runtime: Godot 4.6.3 stable, D-backed certified executable.

## Preservation

No gameplay state injection, resource injection, teleportation, victory injection, default-runtime change, push, PR mutation, protected-checkout mutation, R1K work, or v0.437 work occurred. The E3R partial evidence is preserved as a truthful blocker for the next bounded repair decision.
