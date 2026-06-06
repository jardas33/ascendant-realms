# v0.141 Salto Environment Style-Lock Revision Report

Date: 2026-06-06

Status: reference-only revision round complete, pending Emmanuel style-lock review.

## Start State

- Repository branch: `main`
- Expected start commit: `5a5f662de51fedd6cfa8635c01e851c6ad524b4d`
- Local synchronization before generation: `HEAD == origin/main`
- v0.140 precondition: exactly three validated Salto environment reference-only candidates existed with `runtimeIntegrationStatus = forbidden`.
- Image-generation capability: available through Codex `image_generation` feature.

## Revision Direction

The v0.141 revision round used Emmanuel's review direction:

- Candidate A, `v0138-env-a-tactical-clarity`, is the primary visual base.
- Candidate C, `v0138-env-c-modern-2_5d-balance`, is the tactical-layout reference.
- Candidate B, `v0138-env-b-barrosan-atmosphere`, is used only as a restrained atmosphere reference.

The revision prompts targeted a modern top-down RTS/RPG Salto environment style frame: polished 2.5D fixed-camera readability, strong Barrosan terrain identity, clear lanes, buildable areas, the West Stone Cut Mine/quarry, Lume landmark space, and restrained Ashen contrast. The prompts explicitly excluded HUD art, characters, units, sprites, textures, models, UI kits, animation sheets, and runtime-ready asset output.

## New Reference Candidates

| Candidate | Purpose | Local ignored path | SHA-256 | Dimensions |
| --- | --- | --- | --- | --- |
| `v0141-env-r1-gameplay-first-barrosan` | Gameplay-first Barrosan revision: tactical clarity from A, layout readability from C, restrained atmosphere from B. | `artifacts/art-review/v0138/candidates/v0141-env-r1-gameplay-first-barrosan.png` | `d87f6e5cce98d85ca9e659b2ed98fd62dc443481f5342c09f472c6aac2aad5ca` | 1672 x 941 |
| `v0141-env-r2-barrosan-signature` | Strongest Barrosan environmental identity and material language while preserving readable RTS lanes. | `artifacts/art-review/v0138/candidates/v0141-env-r2-barrosan-signature.png` | `22443e261f40f4228c9fcb346aa2c344e37449af8c35418259482a3e292b6a7f` | 1672 x 941 |
| `v0141-env-r3-modern-balanced-ashen-contrast` | Balanced modern 2.5D presentation with clearer Ashen pressure contrast and tactical layout. | `artifacts/art-review/v0138/candidates/v0141-env-r3-modern-balanced-ashen-contrast.png` | `97fcedfb8565c7c9b522192221612b24d3d92165d2790952bbfe5c28445daa8e` | 1672 x 941 |

## Metadata

Each revised candidate has a matching ignored metadata file under `artifacts/art-review/v0138/metadata/`.

Required metadata posture:

- `purpose = reference-only`
- `humanStatus = pending-review`
- `runtimeIntegrationStatus = forbidden`
- `licencePosture.runtimeUse = forbidden`
- `protectedIpReview.status = pending`
- `protectedIpReview.protectedLookalikeRisk = unknown`

Validation result:

```text
PASS_V0138_REFERENCE_METADATA
Metadata files: 6
Candidate images: 6
```

## Contact Sheet And Review Pack

Updated ignored local review outputs:

- Contact sheet SVG: `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.svg`
- Contact sheet manifest: `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.json`
- Review checklist: `artifacts/art-review/v0138/review-notes/v0138-reference-review-checklist.md`
- Review pack summary: `artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json`
- v0.141 local review note: `artifacts/art-review/v0138/review-notes/v0141-salto-environment-style-lock-review.md`

The contact sheet now contains six environment candidates: the three v0.140 canary candidates and the three v0.141 revision candidates.

## Boundaries

No generated image is approved for runtime use. This checkpoint does not import, wire, register, package, or approve any generated image for Godot or browser runtime use.

No HUD art, Aster art, Worker art, unit art, sprite, texture, model, UI kit, animation sheet, or additional candidate was generated.

No Godot file, browser runtime file, asset manifest, art-slot registry, save data, stable ID, content ID, reward table, package inclusion rule, or fixture integration changed for runtime art.

v0.142 was not started.
