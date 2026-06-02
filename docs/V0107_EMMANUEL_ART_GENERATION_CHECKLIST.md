# v0.107 Emmanuel Art Generation Checklist

Status: human checklist only. Do not treat any checkmark here as runtime integration approval.

## Before Generating Anything

- [ ] Read `docs/V0107_SALTO_VERTICAL_SLICE_COMPOSITION_SPEC.md`.
- [ ] Read `docs/V0107_ASSET_DIMENSION_CONTRACTS.md`.
- [ ] Read `docs/V0107_GENERATION_DEPENDENCY_ORDER.md`.
- [ ] Run `npm run art:packet:salto-slice`.
- [ ] Confirm the packet under `artifacts/art-review/salto-slice-packet/` contains markdown/json only.
- [ ] Choose exactly the next asset in dependency order.
- [ ] Approve the final prompt text before any candidate is created.

## Generation Order

- [ ] 1. `v0107_salto_environment_style_frame`
- [ ] 2. `v0107_battlefield_style_frame`
- [ ] 3. `v0107_hud_frame`
- [ ] 3b. `v0107_results_frame`
- [ ] 4. `v0107_lume_style_frame`
- [ ] 5. `v0107_campaign_map_style_frame`
- [ ] 6. `v0107_barrosan_worker_concept`
- [ ] 7. `v0107_barrosan_militia_concept`
- [ ] 8. `v0107_barrosan_ranger_concept`
- [ ] 9. `v0107_barrosan_hero_concept`
- [ ] 10. `v0107_barrosan_command_hall`
- [ ] 11. `v0107_barrosan_barracks`
- [ ] 12. `v0107_barrosan_mine`
- [ ] 13. `v0107_barrosan_shrine`
- [ ] 14. `v0107_ashen_enemy_contrast_sheet`
- [ ] 15. Choose runtime candidates only after human review.
- [ ] 16. Open a separate runtime integration milestone if, and only if, a candidate is chosen.

## Candidate Workspace

For each candidate:

- [ ] Run `npm run art:review:init -- --asset <registryAssetId>` for the mapped v0.105 registry asset.
- [ ] Paste the final prompt into `prompt-reference.json`.
- [ ] Place manually created candidate images only in the ignored candidate workspace.
- [ ] Fill candidate metadata with source/tool/model/license/protected-IP fields.
- [ ] Keep runtime posture `reference-only:not-runtime`.
- [ ] Run `npm run art:review:validate`.
- [ ] Generate a contact sheet/report only after metadata is complete.

## Review Questions

- [ ] Does the asset match the correct role, screen, faction, and region?
- [ ] Does the silhouette read at the required thumbnail size?
- [ ] Are camera, aspect ratio, safe crop, transparency, and noise posture correct?
- [ ] Is source/license posture clear?
- [ ] Is protected-IP risk acceptable?
- [ ] Does it avoid mobile UI, logos, watermarks, fake text, and copied franchise shapes?
- [ ] Does it preserve current fallback behavior?
- [ ] Is it still reference-only and not runtime art?

## Runtime Boundary

- [ ] No candidate is copied into runtime asset folders.
- [ ] No candidate path is assigned to runtime slots.
- [ ] `runtime-candidate-approved` is not treated as loadable.
- [ ] A future `runtime-integrated` milestone is required before runtime loading.
