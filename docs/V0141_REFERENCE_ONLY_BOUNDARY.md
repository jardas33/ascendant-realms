# v0.141 Reference-Only Boundary

Date: 2026-06-06

v0.141 is a controlled Salto environment reference-art revision round. It is not an art import, runtime integration, game-engine, or implementation milestone.

## Allowed

- Generate exactly three revised Salto environment reference-only candidates.
- Store the generated raster candidates in the ignored local art-review workspace.
- Store matching ignored metadata in the local art-review workspace.
- Validate metadata, hashes, dimensions, and reference-only posture.
- Regenerate the ignored local contact sheet and review pack.
- Create tracked documentation for Emmanuel's style-lock review.

## Forbidden

- Runtime integration.
- Godot scene wiring.
- Browser runtime wiring.
- Asset manifest mutation.
- Art-slot registry mutation.
- Save changes.
- Stable-ID changes.
- Package inclusion changes.
- Texture, sprite, model, UI kit, animation sheet, HUD art, Aster art, Worker art, unit art, or additional-candidate generation.
- Protected-IP approval.
- Final art approval.
- v0.142 work.

## Required Metadata Posture

Every v0.140 and v0.141 candidate must remain:

```text
runtimeIntegrationStatus = forbidden
licencePosture.runtimeUse = forbidden
humanStatus = pending-review
protectedIpReview.status = pending
```

## Runtime Confirmation

No generated v0.141 candidate is referenced by Godot, the browser runtime, runtime asset manifests, fixture manifests, package scripts, save fixtures, stable-ID ledgers, or art-slot registries.

Any later runtime-art step requires a separate explicit milestone, a protected-IP review posture, human approval, and a new validation plan.
