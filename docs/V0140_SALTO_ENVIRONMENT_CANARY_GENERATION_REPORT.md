# v0.140 Salto Environment Reference-Art Canary Generation Report

Status: reference-only canary complete. Exactly three Salto environment candidates were generated for human style review. Runtime integration remains forbidden.

## Capability Check

- Image-generation feature state: `image_generation stable true`.
- Generation path used: Codex built-in `image_gen` tool.
- Provider posture: not exposed by the built-in tool schema.
- Model/version posture: not exposed by the built-in tool schema.
- No external websites, unofficial generators, downloads, fallback assets, or placeholders were used.

## Source Brief

All candidates used:

`docs/art-prompts/V0138_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md`

The source brief's original-IP boundary, negative prompt, 16:9 target, expected 1920 x 1080 direction, review questions, rejection triggers, and runtime-integration prohibition remain authoritative.

## Candidates

| Candidate | Intent | Image | SHA-256 | Dimensions |
| --- | --- | --- | --- | --- |
| `v0138-env-a-tactical-clarity` | Tactical clarity first | `artifacts/art-review/v0138/candidates/v0138-env-a-tactical-clarity.png` | `be8be7bb27c5e9c0d397f437fa2ecbdc99546198145ea7257b8d0d570a59b5c3` | `1672 x 941` |
| `v0138-env-b-barrosan-atmosphere` | Barrosan highland atmosphere while preserving readability | `artifacts/art-review/v0138/candidates/v0138-env-b-barrosan-atmosphere.png` | `77454990a89cc4201981d37de7f8f7e268f457931a1e14084e898fe6a0ba5b5e` | `1672 x 941` |
| `v0138-env-c-modern-2_5d-balance` | Balanced modern 2026 fixed-camera 2.5D gameplay reference | `artifacts/art-review/v0138/candidates/v0138-env-c-modern-2_5d-balance.png` | `582745132f2a31df576c698b94b7d75629a7e07bf44015d03ceb6761f537a1e7` | `1672 x 941` |

The generated resolution is not the intended 1920 x 1080 target, but it preserves the 16:9 posture closely enough for reference-only review. The actual dimensions are recorded in metadata and validated against the PNG files.

## Review Outputs

- Metadata validation: `PASS_V0138_REFERENCE_METADATA`
- Contact sheet: `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.svg`
- Contact-sheet manifest: `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.json`
- Review-pack summary: `artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json`
- Review checklist: `artifacts/art-review/v0138/review-notes/v0138-reference-review-checklist.md`

## Boundary Confirmation

- No HUD art was generated.
- No Aster, Worker, unit, sprite, texture, model, or animation art was generated.
- No generated image was imported, wired, registered, packaged, approved, or loaded by Godot or the browser runtime.
- `runtimeIntegrationStatus = forbidden` remains the hard metadata boundary.
- Human protected-IP and style-lock review remains pending.
- v0.141 was not started.
