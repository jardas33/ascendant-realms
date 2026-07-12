# v0.304 Visual Archaeology, Style-Lock Recovery, and Runtime Gap Analysis

## Executive conclusion

v0.303 is technically complete but visually rejected as the player-facing baseline. The strongest historical direction is not a hidden playable build: it is a reference-only R1 style lock from v0.141, supported by R2 material guidance and the v0.236 Blender-authored Godot slice as the best technical seed. The current procedural PLAYER scene should be retained as a deterministic fallback/debug/proof layer and demoted as the primary art direction.

The credible next route is **Route C: low-poly 3D authored environment with billboard/sprite units**, using Godot orthographic presentation, the retained Blender/GLB pipeline, original Barrosan materials, and one bounded representative sector before broader integration.

## Why v0.303 was visually rejected

The actual non-headless v0.303 PLAYER evidence shows a flat procedural board: square building pads, overlapping road strips, a rectangular bridge/channel, weak side faces, token-like units, broad translucent shadow/selection shapes, muddy palette, and an onboarding prompt over the selected-card band. These are representation failures, not a missing minor material or shadow constant. v0.303 does not meet the historical R1/R2 style lock or the desired readable 2.5D RTS standard.

## Historical visual lineage

The complete lineage is recorded in `artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/visual-lineage-timeline.md`. The key chain is:

- v0.138 established reference-only intake and hard runtime-forbidden metadata.
- v0.140 generated Candidate A/B/C environment references.
- v0.141 generated R1/R2/R3 revisions from Candidate A + C + restrained B.
- v0.142 ratified R1 as the primary reference-only style lock, R2 as companion, and R3 as limited composition reference.
- v0.232 proved an orthographic Godot 3D direction.
- v0.233R proved a Blender-authored modular GLB pipeline.
- v0.234 composed the kit into a connected battlefield slice.
- v0.235 corrected Barrosan architecture and pitched roofs.
- v0.236 added the strongest authored Barrosan production-direction slice.
- v0.301-v0.303 separated proof presentation and added procedural PLAYER depth/material layers without recovering the authored visual language.

## Best historical candidates

**Best visual candidate:** v0.141 R1, `historical-reference/candidates/v0141-env-r1-gameplay-first-barrosan.png`.

**Actual nature:** Codex-generated reference-only environment concept frame, not browser runtime, not Godot runtime, not a 2.5D sprite composite, and not a playable scene. It was human-approved as a reference-only style lock in v0.142. Its metadata still marks runtime use forbidden and protected-IP review pending/unknown.

**Best technical runtime-adjacent candidate:** v0.236 isolated Godot/Blender-authored Barrosan production-direction slice. It is a real Godot-rendered scene with tracked Blender/GLB inputs, but it is non-playable, low-poly, and explicitly partial rather than a shipped runtime replacement.

## Reference-only versus actual runtime

The recovered R1/R2/R3 and A/B/C images are reference frames. The v0.232-v0.236 captures are real Godot renders of isolated private scenes. The v0.303 captures are real non-headless screenshots of the current opt-in PLAYER presentation. No historical reference PNG is imported or wired into runtime by this checkpoint.

## Recovered and missing artifacts

The recovered inventory, source paths, hashes, and classifications are in `historical-reference-index.md` and `historical-runtime-index.md`. Missing or explicitly unavailable material is recorded in `missing-artifacts-register.md`; notably, no historical v0.138-v0.142 playable screenshot or runtime-integrated style-lock asset was found or should be inferred.

## Current v0.303 diagnosis

The category-level comparison is in `current-v0303-gap-analysis.md` and the real-image contact sheets. The largest gaps are authored terrain/road/bridge geometry, architectural mass and roof construction, unit silhouettes and grounding, coherent shadow receivers, material/value identity, and UI-safe presentation.

### Camera / projection

The v0.302 orthographic camera is technically controlled, but camera settings alone cannot create the authored three-quarter composition visible in R1. The current frame remains visually close to a board because the underlying geometry and edge hierarchy are flat.

### Terrain, roads, bridge, and water

R1 uses irregular wet granite, worked earth, clear roads, readable bridge/ford crossings and bank volume. v0.303 uses broad procedural bands and rectangular surfaces. This is why the bridge reads as a rectangle and the river as a strip instead of a constructed crossing.

### Buildings and units

v0.236 demonstrates the right structural direction: pitched roofs, foundations, role-specific mass, props, bridge bracing and authored road/river integration. v0.303’s added roof/side/base boxes remain overlays around small procedural blocks. Units remain procedural tokens/cylinders rather than original, readable silhouettes grounded into authored terrain.

### Lighting, shadows, palette, and materials

The historical target has a cool wet highland base, warm Barrosan construction and restrained teal accents with readable value separation. v0.303’s translucent value boxes and halos do not produce coherent light transport or material identity. Another cosmetic shadow pass is not the recommended repair.

## HUD overlap regression diagnosis

The actual v0.303 PLAYER screenshot visibly contains `Select Aster.` over the selected-card band. This is an opt-in runtime/presentation-path defect, not a stale headless-only artifact.

The responsible boundary is the HUD sync chain in `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`: `_sync_hud()` calls the inherited HUD sync first, while `_v0303_apply_presentation_mode_ui()` delegates to v0.302/v0.301 presentation and material functions but does not explicitly clear/hide `hud_onboarding_label`. Earlier v0.292-v0.295 repair functions explicitly set that label to empty and invisible. Therefore the safer next action is a narrowly scoped future HUD repair that re-applies the v0.292 no-overlap invariant after the v0.303 PLAYER presentation sync. v0.304 does not change runtime code.

## Comparison contact sheets

- Historical candidates: `artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/contact-sheets/v0304_historical_visual_candidates.png`
- Current v0.303 PLAYER runtime: `.../contact-sheets/v0304_current_v0303_runtime.png`
- Runtime/spike lineage and actual current v0.303: `.../v0304_current_and_historical_runtime.png`
- Category gap comparisons: `.../v0304_side_by_side_gap_analysis.png`

The current-side images are real rendered captures, not title cards.

## Runtime-route scorecard and recommendation

The full route scorecard is in `recommended-target-selection.md`. Route C scores best overall: low-poly authored 3D environment plus billboard/sprite units. It follows the proven Godot and Blender evidence, matches R1 more closely than procedural layering, controls asset/animation burden, supports deterministic validation, and leaves room for future faction differentiation.

## v0.302/v0.303 disposition

Retain v0.302/v0.303 as technical fallback, deterministic DEBUG/proof renderer, and a temporary compatibility layer beneath a future authored presentation path. Do not treat them as the accepted player-facing art target. Do not delete them or alter their gameplay/state contracts in this checkpoint.

## Exact next checkpoint and 3–6 checkpoint roadmap

**v0.305 — Barrosan R1 Authored Environment Target Bake-Off.** Build an isolated, review-only representative sector from the retained v0.236 Blender/GLB pipeline: one river crossing, one road junction, Main Hall/Keep, Field Barracks, one mine/ruin/shrine landmark, original Barrosan material families, R1 camera/composition rules, and no gameplay reconnection. Include an explicit HUD overlap repair only if separately kept tiny and invariant-preserving.

Recommended sequence:

1. **v0.305 — target bake-off:** compare authored Blender/GLB environment, controlled 2.5D sprites, and the procedural fallback in one bounded sector; stop on the first credible visual winner.
2. **v0.306 — representative Barrosan sector:** compose the chosen authored environment with readable river, bridge/ford, road junction, Keep, Field Barracks, mine/ruin/shrine and open build space.
3. **v0.307 — unit and building integration:** add original billboard/sprite units with exact pivots, grounding, role silhouettes and selection readability; preserve current stable IDs and HUD semantics.
4. **v0.308 — depth, lighting, and material lock:** tune orthographic camera, depth sorting, shadow receivers, water/road/stone material families and R1/R2 atmosphere without gameplay changes.
5. **v0.309 — player-facing vertical-slice review:** compare real non-headless captures against R1 and the v0.303 fallback, fix only structural gaps, and decide whether to broaden the authored lane.

## Risks and IP safeguards

- Reference frames remain outside runtime and are not used as source textures.
- Generated-reference metadata retains `runtimeIntegrationStatus = forbidden` and pending protected-IP review.
- Future production assets must be original authored geometry/materials with explicit provenance; no copied protected-game expression, assets, logos, symbols or recognizable visual identity.
- Full 3D units and broad asset-roster expansion are deferred until one environment sector proves credible.
- The authored lane must remain opt-in until visual and technical review passes.

## What did not change

No gameplay, movement, pathfinding, route following, combat, damage, HP, projectiles, death/despawn, AI, waves, fog gameplay, economy, resources, stable IDs, saves, true-default runtime, accepted state chain, Pressure 70/100, or runtime art-slot contract changed. No historical reference was integrated. No v0.305 implementation was started.

## Validation evidence

The v0.304 validator checks the indexed candidate hashes/classifications, explicit missing-artifact markings, real v0.303 evidence, contact-sheet mappings, report/index agreement, runtime-forbidden reference posture, and working-tree scope. The retained v0.303 validator, tests, build, content/art/runtime checks, artifact retention, and `git diff --check` are run during closeout.

Local results before commit:

- `npm run godot:validate:visual-archaeology-style-lock-recovery`: PASS.
- `npm run godot:validate:salto-barrosan-player-facing-2-5d-visual-hierarchy-material-readability`: PASS.
- `npm test`: PASS, 122 test files and 887 tests.
- `npm run build`: PASS; existing Vite large-chunk warning only.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS.
- `npm run validate:runtime-art-slots`: PASS, 52 slots.
- `npm run godot:validate:salto-experimental-artifact-retention`: PASS.
- `npm run godot:all`: PASS, including Godot 4.6.3 detection, fixture/parity checks, headless runtime validation, Windows export and package.
- `git diff --check`: PASS.

Exact closeout evidence:

- Branch: `codex/v0215-v0226-recovery`.
- Evidence checkpoint commit: `edb4d8333ef87b0cb36fe0f5bfddf1a38af93245`.
- GitHub Actions run `29177645474`: completed successfully for that exact SHA.

## Final repo state

Recorded at closeout after commit, push and exact-SHA GitHub Actions verification: clean and synchronized with origin, 0 ahead / 0 behind at the evidence checkpoint before this final report-only closeout commit. The final report commit is validated and pushed separately with its own exact-SHA CI confirmation.
