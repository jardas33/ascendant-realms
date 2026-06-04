# v0.122 Godot Content Subset Adapter Spec

Status: implemented for the bounded Salto spike subset.

v0.122 keeps the browser prototype and generated portable JSON as the content authority. Godot consumes only the generated fixture files copied into `desktop-spikes/godot-salto/data/generated/`; it does not maintain a parallel content database.

## Included Subset

The adapter proof covers this controlled fixture slice:

- Barrosan placeholder faction reference: `free_marches`
- Ashen placeholder enemy reference: `ashen_covenant`
- Hero reference: `hero_aster`
- Player units: `worker`, `militia`, `ranger`
- Enemy references: representative Ashen raider, hexer, brute, and commander IDs from the generated Tier M fixture
- Buildings: `command_hall`, `barracks`
- Sites: `west_stone_cut`, `ford_toll`, `north_aether_spring`
- Lume endpoint and link: `aether_well_ruins_lume_ward`
- Ability placeholder: `rally_banner`
- Results contract: generated no-save Results fixture
- Enemy-pressure fixture: representative Tier M generated workload

## Adapter Files

- `desktop-spikes/godot-salto/scripts/adapters/content_registry_adapter.gd`
- `desktop-spikes/godot-salto/scripts/adapters/stable_id_validator.gd`
- `desktop-spikes/godot-salto/scripts/adapters/save_fixture_read_only_adapter.gd`
- `desktop-spikes/godot-salto/scripts/adapters/unit_definition_adapter.gd`
- `desktop-spikes/godot-salto/scripts/adapters/building_definition_adapter.gd`
- `desktop-spikes/godot-salto/scripts/adapters/site_definition_adapter.gd`
- `desktop-spikes/godot-salto/scripts/adapters/lume_definition_adapter.gd`
- `desktop-spikes/godot-salto/scripts/adapters/results_contract_adapter.gd`

## Acceptance Rules

- Unknown IDs must be rejected.
- Missing IDs must be rejected.
- Duplicate IDs must be rejected.
- Adapter output ordering must be deterministic.
- The fixture hash must be recorded.
- `linked_ward` must remain exactly `0.92`.
- Save fixtures must be read-only.
- Browser `localStorage` access is not allowed.
- Routine Godot editor work is not required.

## Explicit Non-Goals

This spec does not port the campaign, hero progression, technology tree, all factions, art, multiplayer, complete simulation, browser saves, or browser runtime systems. It also does not choose Godot finally.
