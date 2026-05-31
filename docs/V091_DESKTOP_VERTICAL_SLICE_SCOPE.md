# v0.91 Desktop Vertical Slice Scope

Status: future scope definition only. This document does not start desktop implementation, choose an engine, create a wrapper, add assets, change saves, or alter runtime behavior.

## Purpose

The future desktop vertical slice should be small enough to build and measure, but representative enough to answer whether the chosen technology can support a real installable RTS/RPG. It should not be a loose collection of menus or a beautiful screenshot without gameplay.

## Slice Identity

- Region: Salto-inspired foothold in the Barrosan Marches.
- Player faction: Barrosan Freeholds.
- Enemy: Ashen Covenant pressure force.
- Mood: dark heroic-fantasy RTS/RPG with tactical readability first.
- Scale: one compact mission with base, resource, hero, Lume, and Results loops present.

## Required Content

| Area | Included in slice | Notes |
| --- | --- | --- |
| Hero | One playable hero | Use current hero progression concepts, one small ability set, and visible level/XP hooks. |
| Worker | One Barrosan Worker | Must build/repair/assign clearly and read differently from combat units. |
| Military units | Two Barrosan unit types | Recommended: one frontline melee, one ranged unit. Exact names wait for content gate. |
| Buildings | Command Hall, Barracks, mine, shrine | Barracks handles training. Mine and shrine prove resource/Lume visual language. |
| Lume | One Lume link or site pair | Needs clear active/inactive/contested/readable state, not full Lume campaign expansion. |
| Enemy | Ashen Covenant units and one small commander or elite pressure | Use existing doctrine/elite concepts modestly. |
| Mission | One campaign battle | Start state, objective, tactical pressure, victory/defeat, and replay-safe outcome. |
| Campaign shell | One node or small shell | Enough to launch the mission, preview objective/reward, and return after Results. |
| Results | One victory and one defeat state | Must show primary objective, rewards/progression, and return action without clutter. |
| Settings | Audio, display, input, accessibility basics | Must include resolution/window mode posture and key rebinding proof. |
| Save handling | New desktop-safe proof save | Preserve stable content IDs and define translation from prototype data; do not reuse browser localStorage as final storage. |
| Audio | Placeholder posture | Simple approved placeholder cues are fine; final audio pipeline is separate. |
| Packaging | Installable desktop test package | Needs reproducible build, build metadata, clean/dirty status, and launch instructions. |

## Required Player Flow

1. Start from the desktop build.
2. Open settings and confirm resolution, volume, and key-rebinding posture.
3. Enter the campaign shell.
4. View the Salto-region mission briefing and recommended tactical read.
5. Launch the battle.
6. Train a Worker and one military unit, or launch with prebuilt small force if the slice starts mid-conflict.
7. Capture or contest a resource point.
8. Activate or defend one Lume link.
9. Survive an Ashen pressure beat.
10. Defeat the objective.
11. View Results.
12. Save and reload the post-mission state.

## Performance Target For Benchmarking

Initial target for the slice:

- 1920x1080 desktop as the primary acceptance viewport.
- 1366x768 as the minimum readable desktop acceptance viewport.
- Stable input response under ordinary battle load.
- No obvious frame hitch during selection, group movement, combat engagement, or Results transition.
- A representative battle benchmark with a documented active-unit count and frame posture.

Final numbers should be set by the future engine benchmark gate, not by this v0.91 document.

## Packaging Target

The vertical slice should produce:

- A reproducible installable or folder-launchable desktop build for Windows first.
- Build metadata with commit, dirty state, engine/tool version, build time, and target.
- A short tester launch card.
- A rollback path to the browser prototype for comparison.

## What Must Be Proven

- The engine can handle RTS camera, selection, pathing, combat feedback, and HUD density.
- The content pipeline can reuse or translate current data without stable-ID churn.
- The save strategy can support profiles, versioning, and migration tests.
- The UI stack can support campaign, battle HUD, Results, settings, and key rebinding cleanly.
- The art pipeline can integrate future approved Barrosan/Ashen/Lume style frames without incoherent asset flooding.

## Explicitly Out Of Slice

- Full Act 1 recreation.
- Multiple playable races.
- Multiplayer, PvP, or co-op.
- Shop, crafting, giant roster management, or a permanent control-group system.
- Final public title/runtime rename.
- Final art replacement for every unit/building.
- Full modding implementation.
- Engine lock for the full game before the slice benchmark is reviewed.
