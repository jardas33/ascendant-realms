# G0 startup stage map

Source SHA: `07e55140acd737433dce9f14565310320aa0355a`
Branch: `codex/local-runtime-startup-g0`

This map is an observation contract for G0. It does not assert a root cause
before the bounded runs produce telemetry.

| Order | Stage | Owner | Sync/async | Resource or transition | Completion signal |
|---:|---|---|---|---|---|
| 1 | Project boot and autoload construction | Godot / `project.godot` | synchronous engine boot | `LoadingScreen`, `Match`, `V0436*Capture` autoloads | main scene starts |
| 2 | Main menu construction | `scripts/main_menu.gd:_ready` and `_build` | synchronous scene setup | menu background, wordmark, theme, music, buttons | main menu scene ready |
| 3 | Normal menu selection | `main_menu.gd:_on_skirmish` then `ui/skirmish_setup.gd` | scene transition, then synchronous UI build | `scenes/ui/skirmish_setup.tscn` | setup scene ready |
| 4 | Match configuration | `ui/skirmish_setup.gd:_on_begin` | synchronous dictionary write | `Match.set_config` with race, opponent, map, resources, victory, speed | config stored |
| 5 | Loading overlay entry | `LoadingScreen.preload_and_change_scene` | async coroutine | `_show`, two `process_frame` awaits | `_busy=true`, progress visible |
| 6 | Preload sequence | `LoadingScreen._run_preload_sequence` | synchronous `load(path)` per entry plus one `process_frame` await per entry | `PRELOAD_PATHS`, `_cache`, `ResourceLoader.exists` | sequence returns, `_preloaded=true` |
| 7 | Scene swap | `LoadingScreen._change_scene_to` | async scene transition | cached `PackedScene` or `change_scene_to_file` | `GameRoot` becomes current scene |
| 8 | World construction | `world/game_root.gd:_ready` | synchronous scene setup with deferred match start | `GameWorld`, RTS, HUD, AI, pause/debug layers | `GameWorld` child exists |
| 9 | First playable frame | `GameWorld.call_deferred("_start_match")` and HUD | deferred/async frame progression | terrain, commanders, resources, navigation, HUD | GameWorld ready + HUD visible |
| 10 | Loading overlay exit | `LoadingScreen.preload_and_change_scene` | async coroutine | `_vfx_warmup` on web only, min-display timer | `_busy=false`, overlay hidden |

Potential loop or stall points to measure:

- repeated invocation of `_run_preload_sequence` or `preload_and_change_scene`;
- progress regression or repeated stage entry;
- a single long synchronous `load(path)` blocking the first frame;
- scene transition requested without `GameRoot` completion;
- capture-hook work after `GameRoot` creation;
- resource/UID load failures;
- shader/cache output correlated with a specific stage.

The observer records stage transitions, loader invocation state, progress,
cache size, current scene, GameWorld/HUD readiness, and first-frame timing.
