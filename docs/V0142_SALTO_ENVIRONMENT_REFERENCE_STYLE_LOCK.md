# v0.142 Salto Environment Reference-Only Style Lock

Date: 2026-06-06

Status: human environment style-lock decision ratified as reference-only. Runtime integration remains forbidden.

## Start State

- Repository branch: `main`
- Expected start commit: `99b598b35f53c5086f37f9cab3ec8617ca2575ae`
- Local synchronization before editing: `HEAD == origin/main`
- v0.141 produced exactly three revised environment reference-only candidates.
- Six total environment candidates exist and validate.
- All six candidate metadata files keep `runtimeIntegrationStatus = forbidden`.

## Human Decision

The v0.141 human style review is complete.

- Primary reference-only Salto environment style lock: `v0141-env-r1-gameplay-first-barrosan`.
- Approved secondary companion reference: `v0141-env-r2-barrosan-signature`.
- Limited composition reference only: `v0141-env-r3-modern-balanced-ashen-contrast`.

No further Salto environment revision is requested at this stage.

## R1 Primary Reference-Only Style Lock

R1 is approved as the primary reference-only base for the Salto environment direction because it best balances:

- Gameplay-first readability.
- Barrosan highland material identity.
- Wet granite and worked-earth terrain.
- Quarry/mine, bridge, ford, ruin, shrine, and build-space legibility.
- High three-quarter orthographic fixed-camera RTS framing.
- UI-safe margins and practical route readability.

R1 is not runtime art. It is not imported, wired, registered, packaged, or approved for Godot or browser use.

## R2 Approved Companion Reference

R2 is approved as the secondary companion reference for:

- Barrosan material language.
- Practical timber-and-stone architecture.
- Wet-granite atmosphere.
- Restrained mist.
- Warm hearth accents.

R2 should support future style prompts but should not replace R1 as the primary composition and gameplay-readability lock.

## R3 Limited Reference And Restrictions

R3 is limited to:

- Lane hierarchy.
- Ashen readability.
- Tactical route separation.

Do not carry forward these R3 elements:

- Technological Lume pylons.
- Visible energy-beam infrastructure.
- Sci-fi crystal-tower language.
- Excessive cliff spectacle.
- Cinematic key-art framing.

## Frozen Environment Rules

Carry forward:

- Wet granite, moss, worked earth, low grass, and mountain-foothold identity.
- Practical weathered Barrosan timber-and-stone architecture.
- Readable RTS lanes with at least two plausible movement routes.
- Bridge and shallow-ford clarity.
- UI-safe margins and gameplay-distance legibility.
- Mystical land-bound Lume: ancient stone, roots, water, and restrained teal traces.
- Ashen corruption as charred soil, dead growth, restrained embers, and cracks.
- High three-quarter orthographic fixed-camera RTS gameplay-reference framing.

Do not carry forward:

- Technological Lume infrastructure.
- Lava-world spectacle.
- Giant black-spire dominance.
- Generic RTS tent camps.
- Mobile-game gloss.
- Protected-game callbacks.

## Metadata Handling

The current metadata schema does not support additional human-review role annotations because `tools/art-reference/referenceCandidate.schema.json` uses `additionalProperties: false` and has no dedicated style-lock role field.

No metadata schema rewrite was performed. No unsupported enum values or fields were added. The authoritative style-lock decision is recorded in this tracked document and in the ignored local review note:

```text
artifacts/art-review/v0138/review-notes/v0142-salto-environment-style-lock-decision.md
```

All six environment candidates remain reference-only and runtime-forbidden. `protectedIpReview.status` remains `pending`; human style approval is not protected-IP clearance.

## Runtime Boundary

This style lock is not a final runtime-art choice. It does not authorize Godot import, browser import, manifest mutation, art-slot mutation, package inclusion, save changes, stable-ID changes, or asset registration.
