# v0.84 Lume Link Rendering Spec

## Scope

Add procedural battlefield readability for the existing Lume Network only. Rendering uses Phaser graphics and existing site positions. No image assets, shaders, map edits, or balance changes are allowed.

## Link States

- Inactive: faint cyan line between eligible endpoints.
- Active: luminous teal/cyan line.
- Contested: amber pulsing line.
- Severed: red fading/pulsing line.
- Restored: active teal line with a modest pulse after a previously severed link returns active.

## Endpoint Markers

Eligible sites should get subtle endpoint halos so the player can read which sites matter. Markers must not cover capture rings, selection feedback, unit silhouettes, or resource icons.

## Layering

The link graphics should sit above the terrain and below most unit/building interaction affordances. Fog of war remains authoritative; no Lume rendering should reveal hidden enemy state.

## Testability

The battle test hook may expose a render snapshot with link ids, endpoint ids, state, and style labels. The snapshot is for automated verification only and must not create runtime UI state or save data.

## Deferrals

- No bespoke VFX.
- No imported symbols.
- No animated art assets.
- No map-authored Lume paths.
