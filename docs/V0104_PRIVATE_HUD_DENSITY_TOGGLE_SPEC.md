# v0.104 Private HUD Density Toggle Spec

## Scope

Private playtest tools expose a session-only HUD density control with `Minimal`, `Standard`, and `Debug`. The control is available only when `__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__` is enabled. It is not saved, not read from localStorage, and not represented in campaign or hero save data.

## Density Modes

- `Minimal`: mirrors the public battle HUD density for private comparison.
- `Standard`: preserves the v0.103 full-detail private review HUD and is the default for private hub and private Lume review launches.
- `Debug`: private-only mode that adds HUD rendering counters to the objective surface.

## Controls

- Control container: `data-testid="hud-density-controls"`.
- Mode buttons: `hud-density-minimal`, `hud-density-standard`, `hud-density-debug`.
- Active HUD roots: `battle-hud-density-minimal`, `battle-hud-density-standard`, `battle-hud-density-debug`.
- Debug counters: `battle-hud-debug-counters`.

## Scenario Mapping

- `perf_hud_minimal`: private Minimal selected-hero comparison.
- `perf_hud_standard`: private Standard selected-hero comparison.
- `perf_hud_debug`: private Debug selected-hero comparison.
- Existing private profiler scenarios default to Standard unless the test explicitly selects Minimal.

## Safety Rules

- No save writes, no localStorage writes, no campaign progress, no rewards, no XP, no Retinue, no relic, no reputation mutation.
- Debug density is private-tool gated and absent from public posture.
- Existing private long-copy review remains possible in Standard mode.
