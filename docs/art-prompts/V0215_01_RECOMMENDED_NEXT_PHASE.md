# v0.215 Recommended Next Phase

Title: Salto Production-Art Battlefield Content Direction Packet

Proceed only from a clean, synced, pushed and CI-green v0.214 checkpoint.

## Purpose

The v0.207 through v0.214 UI direction is frozen for the isolated Godot Salto shell-v2 opt-in review path. The next visible weakness is production-art quality inside the battlefield, not more HUD structure.

v0.215 should create a bounded production-art/content direction packet for the Salto battlefield before any new art generation, art import, runtime slot, launcher, browser runtime wiring or default enablement.

## Scope

Authorized:

- documentation and evidence review only
- review of v0.207 through v0.214 screenshots and docs
- comparison against `REFERENCE_UI_TARGET.png` as a hierarchy and quality benchmark only
- a production-art/content contract for later human review

Forbidden:

- generated images
- downloaded assets
- new runtime art slots
- normal-slice art integration
- default launcher changes
- browser runtime wiring
- gameplay, pathing, collision, objective, AI, economy, save, stable-ID or balance changes
- character-slot expansion

## Required Output

Create a concise packet that defines:

- terrain, road, river, bridge and bank art priorities
- Command Hall, Barracks, mine, bridge and hostile landmark identity targets
- unit and hostile readability rules
- material, lighting and value constraints
- what can stay procedural
- what should become authored or generated art later
- acceptance gates for any future source generation
- acceptance gates for any future opt-in integration

## Acceptance

PASS only if the packet chooses a small, reviewable next art/content step and keeps the current v0.214 UI freeze intact.

Stop after the packet. Do not begin any image generation or integration work in v0.215 unless a future prompt explicitly authorizes it.
