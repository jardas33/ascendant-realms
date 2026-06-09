# v0.172 Environment Phase Roadmap

Status: `ACTIVE_V0183_ENVIRONMENT_PHASE_ROADMAP`

## v0.183 Post-Freeze Update

The environment-material phase is frozen after the selected Barrosan foothold ground material and road material opt-ins. The next recommended bounded milestone is v0.184 Emmanuel environment-freeze manual review decision packet, not another comparator or integration step.

Do not add bridge/river, structure-shell, lighting, HUD, animation, default-art, or cleanup execution work until Emmanuel chooses that direction from the v0.184 packet.

The character-slot phase is frozen after five selected slots. The next bounded phase should improve the procedural environment foundation while keeping the default launcher procedural and the browser runtime untouched.

## Stage 1: Procedural World-Shell Hierarchy

Target future checkpoint: v0.173 if explicitly queued and prerequisites pass.

Purpose:

- Improve terrain hierarchy, structure silhouettes, road/river readability, camera framing, and review overlays in an opt-in environment-foundation launcher.
- Keep zero image generation.
- Add no new runtime-art slot.
- Preserve existing five character/material opt-in slots.
- Keep the default launcher procedural.

Acceptance focus:

- Battlefield, river/banks, bridge, roads, mine, Barracks/restored, Command Hall, markers, coexistence with five-slot art, combat onset, minimap, and pan/zoom review.
- Benchmark opt-in foundation path against the current five-slot baseline.

## Stage 2: Road, River, Bridge, And Site Markers

Target future checkpoint: v0.174 if explicitly queued and v0.173 passes.

Purpose:

- Harden tactical readability of road continuity, river banks, bridge crossing, mine/Barracks lanes, site markers, hostile approach, friendly boundary, minimap correlation, and pan/zoom.
- Keep zero image generation.
- Avoid gameplay/pathing semantic mutation.
- Modify only the environment-foundation opt-in path.

## Stage 3: Private Terrain-Material Comparator

Target future checkpoint: v0.175 if explicitly queued and v0.174 passes.

Purpose:

- Generate exactly one original private-comparator Barrosan foothold ground material source.
- Keep it ignored/local and private-comparator-only.
- Add no player-facing integration.
- Select a derivative only if seam, repetition, material language, and performance gates pass.

## Stage 4: Terrain-Material Readiness Packet

Target future checkpoint: v0.176 if explicitly queued and v0.175 passes.

Purpose:

- Documentation-only readiness packet for exactly one future terrain-material opt-in player-slice slot.
- Generate zero images.
- Add zero slots.
- Make no runtime code change.

## Explicit Non-Goals

- No sixth character slot.
- No broad environment art import.
- No default art enablement.
- No browser runtime wiring.
- No save/stable-ID/gameplay mutation.
- No terrain material integration before the private comparator and readiness packet pass.
- No v0.173 work inside v0.172.
