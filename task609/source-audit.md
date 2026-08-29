# Task609 source audit

- Worktree: `D:\CodexData\worktrees\ascendant-realms-p1-normal-play-bug-sweep-01`
- Production project: `D:\CodexData\worktrees\ascendant-realms-p1-normal-play-bug-sweep-01\production\ascendant-realms-godot`
- Branch: `codex/p1-task463-production-spawn-reliability`
- Exact base and `codex/current-godot-baseline-next`: `491ce5a177c185cd155fbea7a2db308d5b0366a5`
- Protected canonical: `b9812797bba626a3b51e0b79739bc6e2cdf0bca4`
- Candidate commit: `d7bf5b824d562032ffa668d4620329adcc09d58c`

## Source-first ownership audit

The existing Task608 portrait architecture remained the owner for the accepted Task609 integration: `UNIT_TEMPLATE_ID_OWNER`, `UNIT_DISPLAY_NAME_OWNER`, `UNIT_PORTRAIT_PATH_OWNER`, `ENTITY_PORTRAIT_VIEW_OWNER`, `PORTRAIT_TEXTURE_CACHE_OWNER`, `PORTRAIT_FIT_MODE_OWNER`, `PORTRAIT_FALLBACK_OWNER`, `SELECTED_ENTITY_PORTRAIT_OWNER`, `GROUP_SELECTION_PORTRAIT_OWNER`, and `COMPACT_LAYOUT_PORTRAIT_OWNER`. No architecture change was made.

## Exact accepted sources

| Mapping | External source | SHA256 | Production destination |
|---|---|---|---|
| `barrosan_spear_guard` / Stoneward Spears | `D:\CodexData\external-art-intake\grok-art-a08-barrosan-visual-identity\01_MASTERS_B1\portraits\a08_b1_portrait_stoneward_spears.jpg` | `DD68AE06072257FE371730A75115D4A579FA4B7F97406268A626D45B9E221B87` | `res://assets/ui/portraits/barrosan/a08_b1_portrait_stoneward_spears.jpg` |
| `barrosan_clan_levy` / Clan Levy | `D:\CodexData\external-art-intake\grok-art-a08-barrosan-visual-identity\01_MASTERS_B1\portraits\a08_b1_portrait_clan_levy.jpg` | `EE87FC3D5705E6A7E550CD2C96AE270CFA10EFEFE9D076203F21AF0807B1A521` | `res://assets/ui/portraits/barrosan/a08_b1_portrait_clan_levy.jpg` |

The production files are byte-identical copies of the accepted external sources. No resize, recompression, repaint, Grok import, canonical mutation, or runtime state injection was used. Worker and War-Thane hashes remained unchanged.

## Runtime proof

The final bounded public run passed through the normal menu into a genuine GameWorld. Stoneward was selected and moved through the public order route. A Worker placed a War Hall through public construction, the building completed naturally, Clan Levy was queued and produced naturally, and the unit was selected, moved, and switched without stale portrait state. The runtime manifest reports `pass=true`, `public_gameworld_route=true`, no direct mutation flags, zero per-frame portrait loads/duplication, and the expected portrait paths. Full and compact proof was captured at 1920x1080 and 1366x768. Worker/War-Thane and unmapped fallback regressions passed.

Runtime evidence: `runtime\final\task609-runtime.json`, `runtime\final\task609-production-audit.json`, and `runtime\final\launch-a.log`.
