# v0.82 Lume Network Runtime Prototype Spec

Status: implemented for the smallest approved runtime slice.

## Scope

v0.82 turns the v0.81 Lume Site Network recommendation into one mission-local prototype. It is intentionally narrow:

- Campaign node: `aether_well_ruins`.
- Map: `broken_ford`.
- Launch mode: `campaign_node`.
- Rewards-disabled/Tutorial routes: excluded.
- Replay: allowed because the Lume objective is battle-local and gives no persistent reward.

No new map, faction, art asset, unit, building, save migration, shop, crafting, desktop shell, display-name migration, race system, Jardas binding command, Worker binding command, or hero command was added.

## Network Definition

Network id: `aether_well_ruins_lume_ward`.

Eligible sites:

1. `west_stone_cut`
2. `ford_toll`
3. `north_aether_spring`

Links:

1. `west_stone_cut_to_ford_toll`: `west_stone_cut` to `ford_toll`.
2. `ford_toll_to_north_aether_spring`: `ford_toll` to `north_aether_spring`.

Caps:

- Maximum eligible sites: 3.
- Maximum active links: 2.

## Activation

Activation mode: `capture_only`.

Rules:

- A link is inactive until both endpoints exist, are alive, and are player-owned.
- A link activates when both endpoint sites are player-owned.
- A link is severed if it was active and then either endpoint is neutral or enemy-owned.
- A severed link can reactivate if the player recaptures both endpoints.
- Contested capture progress can show a contested state, but it does not add a separate Lume progress bar.

## Benefit

Benefit id: `linked_ward`.

Player-facing name: `Linked Ward`.

Runtime effect:

- Friendly player units and buildings near active linked endpoint sites take 8% less incoming damage.
- The multiplier is `0.92` before armor.
- It is non-stacking across multiple active links.
- It applies only while the link is active.
- It does not modify resource income, campaign rewards, hero XP, relics, skills, AI economy, or global balance.

## UI

Campaign briefing line:

`Hold two linked sites to wake a Lume Ward. Enemy recapture severs the link.`

HUD:

- One compact Lume row in the existing objective surface.
- Shows title, objective, inactive/active/contested/severed state, benefit summary, and counterplay.
- Hidden outside `aether_well_ruins`.

Selected resource site:

- Eligible selected sites show a compact Lume link summary.
- Unrelated sites remain unchanged.

Results:

- One Lume Network block appears only for the chosen mission.
- It shows activated links, severed links, objective completion, Linked Ward summary, and battle-local wording.

## Save And Replay

No save-version bump.

No campaign or hero save fields were added. Lume state is battle-session telemetry only:

- `lumeNetworkId`
- `lumeLinkActivatedIds`
- `lumeLinkSeveredIds`
- `lumeObjectiveCompleted`
- `lumeTelemetryLabels`

Replay can repeat the battle-local link experience, but it cannot duplicate one-time campaign rewards because existing replay rules remain unchanged.

## Deferrals

- Jardas binding.
- Worker binding.
- Hero command/binding.
- Minimap link lines.
- Race-specific Lume variants.
- Living Mines.
- Runtime display rename from Aether to Lume.
- Any new AI targeting bump.
