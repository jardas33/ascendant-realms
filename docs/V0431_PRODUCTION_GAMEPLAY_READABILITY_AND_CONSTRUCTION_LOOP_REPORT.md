# v0.431 Production Gameplay Readability and Construction Loop

## Scope

v0.431 is a bounded production-runtime readability repair and one real construction-loop proof. It does not introduce a new game system, renderer, scene, resource type, building type, movement model, or combat feature. The only new gameplay-facing proof is a real worker-driven Clan Croft placement and completion transaction in the existing production scene.

Base commit: `044a14de65c4b1308a21f402d04f89b881f291a6`

Branch: `codex/v0431-gameplay-readability-construction-loop`

The accepted v0.430 production rebase remains the source baseline. Historical or experimental files already present in the worktree are not part of this checkpoint.

## Readability correction

The production battle world was visibly washed out because its existing environment combined excessive ambient energy, high tonemap white, glow, fog density, and key-light energy. v0.431 narrows those values only in `GameWorld`'s battle-world setup:

- ambient energy: `0.60` -> `0.42`
- tonemap white: `6.0` -> `3.2`
- glow: disabled
- fog density: `0.0016` -> `0.00045`
- sun energy: `1.15` -> `1.0`
- warmer restrained key-light color

Title, campaign, settings, and menu setup are unchanged. The captured comparison in `03_V0430_V0431_MATCHED_GAMEPLAY_COMPARISON.png` shows the v0.430 gameplay reference beside the real headed v0.431 battlefield and the valid construction preview.

## Construction loop

The existing `GameWorld.place_building`, `RTSController`, `Unit.command_move`, build-menu, preview, placement, and completion paths remain authoritative. The v0.431 additions are audit metadata around the existing transaction:

1. select a real production worker;
2. issue `Unit.command_move` to a deterministic valid build location;
3. enter the existing Clan Croft build mode;
4. capture invalid and valid preview states;
5. confirm placement through the existing RTS controller;
6. observe construction progress and completion;
7. select the completed building;
8. reload the production scene and repeat the complete loop.

Each loop records exactly one `barrosan_clan_croft` transaction. The cost is 60 timber and 20 stone. Resources change from timber 300 / stone 180 to timber 240 / stone 160, with food and gold unchanged. The audit records one deduction and one completion event per loop.

The guard is target-scoped and idempotent. It does not replace normal placement for other buildings, and preview or invalid clicks do not deduct resources.

## Headed evidence recovery

The first headless capture attempt failed closed because the dummy renderer did not provide a usable viewport. No dummy frame was retained as gameplay proof. The recovery uses the official headed Windows Godot 4.3 executable and Forward Plus:

```text
npm run godot:capture:v0431-gameplay-construction
```

The capture enters `scenes/main.tscn`, transitions through the production title flow, waits for the real `GameWorld`, `RTSController`, HUD, worker, and building nodes, synchronizes after `RenderingServer.frame_post_draw`, and exits after the second fresh-scene loop. The required command is recorded in `v0431-capture-command.json`; the renderer and failure classification are recorded in `v0431-headed-capture-audit.json`.

The project requests a 1920x1080 viewport. The headed Windows client image is 1920 pixels wide and 1061 pixels high after the native window frame; this is recorded in `v0431-black-frame-rejection.json` and the sampled gameplay images pass non-black and meaningful-variance checks.

## Review pack

Review pack: `artifacts/manual-review/v0431-gameplay-readability-construction-loop/`

Key real captures:

- `02_V0431_GAMEPLAY_READABILITY_AFTER.png` — readable production battlefield after the environment correction.
- `04_V0431_WORKER_SELECTED.png` — selected worker and selected card.
- `05_V0431_WORKER_MOVEMENT_DESTINATION.png` — worker movement command evidence.
- `06_V0431_CLAN_CROFT_BUILD_MENU.png` — existing build menu.
- `07_V0431_CLAN_CROFT_VALID_PREVIEW.png` — valid Clan Croft ghost and green placement preview.
- `08_V0431_CLAN_CROFT_INVALID_PREVIEW.png` — invalid preview.
- `09_V0431_PLACEMENT_CONFIRMED_RESOURCE_DEDUCTION.png` — confirmed placement and changed resource HUD.
- `10_V0431_CONSTRUCTION_EARLY_PROGRESS.png` and `11_V0431_CONSTRUCTION_LATE_PROGRESS.png` — real progress.
- `12_V0431_CLAN_CROFT_COMPLETE.png` and `13_V0431_COMPLETED_CLAN_CROFT_SELECTED.png` — completed building and selected state.
- `14_V0431_REPLAY_SECOND_LOOP_COMPLETE.png` — completed second fresh-scene loop.
- `03_V0430_V0431_MATCHED_GAMEPLAY_COMPARISON.png` — before/after/valid-preview comparison.
- `18_V0431_GAMEPLAY_CONSTRUCTION_CONTACT_SHEET.png` — real rendered construction sequence.

The four preservation references are copied from the v0.430 production pack: title, skirmish setup, campaign, and v0.430 gameplay baseline. The three rejected desktop diagnostic files are intentionally absent.

## Validation contract

Dedicated command:

```text
npm run godot:validate:v0431-gameplay-construction
```

The validator proves base ancestry, branch, required real PNG dimensions and variance, headed Forward Plus capture metadata, two completed construction loops, exact resource deductions, driver completion, audit evidence, and absence of rejected desktop diagnostics. It also checks that the production project has no `TesanaWorldEditor` autoload and that the expected readability and construction hooks remain present.

The smoke command remains available separately:

```text
npm run godot:smoke:v0431-gameplay-construction
```

## Boundaries preserved

- no new movement, pathfinding, route following, combat, attacks, damage, HP loss, projectiles, death/despawn, AI, waves, fog gameplay, economy, production logic, pressure behavior, stable-ID, save, or network mutation;
- no true-default runtime mutation; the capture autoload and scene hooks are inert unless `ASCENDANT_V0431_CAPTURE=1`;
- no final-state injection; the capture driver operates through real production nodes and existing actions;
- v0.430 fallback/debug renderer and accepted chain remain intact;
- original source tree remains out of scope.

## Current evidence status

The headed capture and review pack are complete locally. The dedicated validator and full repository validation must pass before commit. Commit, push, and exact-SHA GitHub Actions confirmation are the final closeout gates.
