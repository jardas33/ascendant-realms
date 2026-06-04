# v0.117 Godot Visual Direction Comparison

## Visual Ambition

The future game should evoke the spirit of a super-cool 2026 evolution of Warlords Battlecry while remaining original: original IP, factions, lore, assets, UI, mechanics, and visual identity.

The benchmark posture assesses a modern top-down RTS/RPG presentation with:

- strong faction silhouettes;
- atmospheric Salto terrain;
- modern lighting and VFX;
- a central persistent hero;
- tactical readability;
- no generic mobile-game or developer-dashboard look.

## 2D Placeholder Mode

Status: implemented and tested.

The 2D mode uses Node2D-style placeholder composition and procedural shapes. It is readable, deterministic, and friendly to text diffs. It is the safest mode for automation, fast iteration, and strict tactical clarity.

Strengths:

- clean top-down readability;
- simple text-editable scene posture;
- lower conceptual import complexity;
- strong baseline for deterministic fixture parity.

Risks:

- final lighting, terrain atmosphere, height, and VFX polish may require more custom art direction work;
- it may look flatter unless the final art pipeline is strong.

## 2.5D Orthographic Placeholder Mode

Status: implemented and tested.

The 2.5D mode uses a fixed high-angle orthographic 3D posture with primitive terrain, meshes, lighting, shadows, and a Lume VFX placeholder. It is still placeholder-only.

Strengths:

- better early fit for modern lighting, terrain depth, and atmospheric presentation;
- stronger path toward a polished fixed-camera RTS/RPG look;
- central hero and faction silhouettes can read with shape, shadow, and height.

Risks:

- more moving parts for art import, camera framing, material management, and performance validation;
- needs a future visual-quality spike before any engine recommendation.

## Recommendation

For the next explicit visual-quality spike, keep 2.5D orthographic as the leading presentation candidate because it better supports the intended modern lighting, depth, and atmosphere. Keep 2D as the automation/readability control and fallback.

Do not select Godot finally from v0.117. Do not select 2.5D finally from v0.117.
