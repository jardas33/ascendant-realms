# v0.108 Representative Battle Profile

Status: private QA benchmark profile only. This does not add gameplay content, change balance, change saves, rename stable IDs, add final art, choose an engine, or start a desktop port.

## Content Basis

The profile uses current runtime content:

- Map: `broken_ford`.
- Campaign node: `aether_well_ruins`.
- Hero: Aster from the private Playtest Hub fixture.
- Worker: `worker`.
- Player military unit types: `militia` and `ranger`.
- Ashen enemies: `raider`, `hexer`, `brute`, and existing commander placeholder `enemy_commander`.
- Buildings: player `command_hall`, private completed `barracks` fixture, enemy `enemy_stronghold`, and enemy `enemy_barracks`.
- Mine equivalent: existing capture-site infrastructure `west_stone_cut`.
- Shrine equivalent: existing capture-site infrastructure `ford_toll`.
- Resource site focus: one existing site, `west_stone_cut`.
- Lume link: `west_stone_cut_to_ford_toll` from `aether_well_ruins_lume_ward`.
- Results transition: no-save private battle victory transition into the private Lume Results surface.

Current runtime content has no mine or shrine buildable IDs. v0.108 therefore treats mine/shrine coverage as existing capture-site infrastructure and does not create new stable IDs.

## Tier Counts

| Tier | Use | Hero | Worker | Militia | Rangers | Ashen enemies | Structures | Site focus | Lume link | Pressure beat |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| S | Smoke | 1 | 1 | 2 | 2 | 5 | 4 | 1 mine/shrine pair | 1 | 4 nearby enemies |
| M | Representative | 1 | 1 | 8 | 6 | 15 | 4 | 1 mine/shrine pair | 1 | 8 nearby enemies |
| L | Stress | 1 | 1 | 14 | 12 | 25 | 4 | 1 mine/shrine pair | 1 | 12 nearby enemies |

Tier L is private/local only and is not a CI acceptance lane.

## Scenario Entries

The private Playtest Hub group is `REPRESENTATIVE BATTLE BENCHMARK` and contains:

- `benchmark_battle_tier_s_smoke`
- `benchmark_battle_tier_m_representative`
- `benchmark_battle_tier_l_stress`
- `benchmark_battle_lume_hidden`
- `benchmark_battle_lume_auto`
- `benchmark_battle_lume_always`
- `benchmark_battle_fog_heavy`
- `benchmark_battle_notification_heavy`
- `benchmark_battle_minimap_interaction`
- `benchmark_battle_results_transition`

All entries launch through isolated private fixtures with rewards disabled and localStorage mutation rejected by the benchmark runner.
