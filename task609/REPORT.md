# Task609 — A08 Stoneward / Clan Levy portrait integration

## Decision

`PASSED_P1_PLAYER_VISIBLE_IMPROVEMENT609_A08_STONEWARD_CLAN_LEVY_PORTRAIT_INTEGRATION_SAFETY`

Candidate is ready for independent Director visual review. Promotion is **not authorized** by this report.

## Candidate

- Branch: `codex/p1-task463-production-spawn-reliability`
- Parent/base: `491ce5a177c185cd155fbea7a2db308d5b0366a5`
- Candidate: `d7bf5b824d562032ffa668d4620329adcc09d58c`
- Protected canonical unchanged: `b9812797bba626a3b51e0b79739bc6e2cdf0bca4`
- Baseline-next unchanged at the approved base.

## Scope

Only two accepted A08-B1 Barrosan military portraits were added to the existing Task608 portrait architecture and mapped in `scripts/game/unit_defs.gd`: Stoneward Spears (`barrosan_spear_guard`) and Clan Levy (`barrosan_clan_levy`). No icon, HUD, Grok production import, glyph, gameplay, or architecture work was included.

## Validation

The final planned headed run passed through the public Skirmish route into genuine GameWorld. It naturally constructed a War Hall, naturally produced Clan Levy, verified Stoneward and Clan Levy selection/movement portrait persistence, verified switching without stale state, and captured Worker/War-Thane, unmapped fallback, and group-selection regressions. Runtime mutation flags are false; `production_source_changed=true` only records the intended candidate source change; `promotion_authorized=false`.

Evidence files:

- `runtime\final\1920\01_STONEWARD_SELECTED_1920.png`
- `runtime\final\1920\02_STONEWARD_MOVE_PORTRAIT_PERSISTS.png`
- `runtime\final\1920\03_CLAN_LEVY_SELECTED_1920.png`
- `runtime\final\1920\04_CLAN_LEVY_MOVE_PORTRAIT_PERSISTS.png`
- `runtime\final\1920\05_STONEWARD_CLANLEVY_SWITCH_NO_STALE.png`
- `runtime\final\1920\06_WORKER_WARTHANE_REGRESSION.png`
- `runtime\final\1920\07_UNMAPPED_FALLBACK_REGRESSION.png`
- `runtime\final\1920\08_GROUP_SELECTION_REGRESSION.png`
- `runtime\final\1366\08_STONEWARD_COMPACT_1366.png`
- `runtime\final\1366\09_CLAN_LEVY_COMPACT_1366.png`
- `10_BARROSAN_CORE_PORTRAIT_FAMILY_BOARD.png`

## Known retained backlog

- `PLAYER_REPORTED_MOVEMENT_STALL_REMAINS_OPEN_NO_REPRO`
- `COMMAND_CARD_PRESENTATION_REDESIGN_PENDING_AFTER_TASK598`

Task608 remains promoted and closed. Task610 remains unauthorized until Director review and a separate authorization.
