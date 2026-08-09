# v0.436 E1R2 — Sustainable Economy Natural Conquest

## Result

The corrected headed run used the requested player-facing configuration: Barrosan versus one Lioraen Easy opponent on Hollowspan, Rich resources, Conquest, and 2x speed. Normal gameplay produced real worker/economy transactions, housing and military infrastructure, mixed-role real-cost queues, a ready force, and a real first offensive cycle with combat target lifecycles and losses.

The bounded run is `INCONCLUSIVE_E1R_TIME_LIMIT`: after losses, normal reinforcement production did not rebuild a useful fighting force before the bounded window expired. No conquest, result, Continue, or Play Again claim is made.

## Evidence

- Review pack: `artifacts/manual-review/v0436-e1r2-sustainable-economy-natural-conquest-attempt-02/session-a/`
- Configuration proof: `match-configuration.json` (`start_resources: rich`, `game_speed: 2.0`)
- Economy/production proof: `production-audit.json`, `construction-audit.json`, `force-readiness.json`
- Combat/consequence proof: `e1r-assault-cycles.json`, `e1r-blocker.json`, `e1r-final-state.json`
- Last valid frame: `05_E1R_FORCE_READINESS_TRUE.png`
- Dedicated validator: `npm run godot:validate:v0436-e1r2-sustainable-economy`

## Preservation

All actions were normal public player-command paths. No HP, death, victory, result, resource, spawn, teleport, save, stable-ID, protected-checkout, push, PR, R1K, or v0.437 mutation occurred. The prior standard-resource attempt remains separate from this corrected Rich configuration attempt.
