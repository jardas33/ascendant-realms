# v0.336 Granite Candidate Identity and Comparative Evidence Repair

## 1. v0.335 human outcome

v0.335 was rejected at the human selection gate because the compact JSON mapping contradicted the instantiated runtime order, candidate-specific sheets reused comparison imagery, and the 15-second video repeated essentially one beige candidate instead of proving all three materials. The allowed v0.336 outcome is therefore evidence repair only: `READY FOR HUMAN FINAL GRANITE CANDIDATE SELECTION`. No automatic winner is selected.

## 2. What v0.335 achieved

The v0.335 CC0 Poly Haven source study remains intact. It located a plausible irregular rubble source, retained the original 2K source bundle and deterministic A/B/C derivatives, and established the isolated Godot test structure. v0.336 reuses those three candidates without inventing replacements.

## 3. Candidate identity contradiction

The v0.335 compact summary declared `MATERIAL 1 = candidate_c`, `MATERIAL 2 = candidate_a`, and `MATERIAL 3 = candidate_b`, while the visible runtime scene constructed candidate A, then B, then C. The prior pack also reused the same upper-right comparison image in multiple candidate sheets and showed all candidates in each lower panel. v0.336 removes the manual mapping source of truth.

## 4. Runtime binding recovery

The new scene `desktop-spikes/godot-salto/scenes/review/V0336GraniteEvidenceRepair.tscn` loads three explicit `.tres` materials, instantiates one labeled structure per material, and writes `artifacts/runtime/v0336/candidate-binding-ledger.json` from the live node/material/texture bindings. Each ledger record includes the displayed label, mesh node path, material resource path and SHA-256, source candidate directory, and four source texture paths and SHA-256 values.

Recovered mapping:

| Display label | Candidate | Runtime material | Status |
|---|---|---|---|
| MATERIAL 1 | candidate C | `assets/v0336/materials/material_1.tres` | hybrid scan plus limited merged relief |
| MATERIAL 2 | candidate B | `assets/v0336/materials/material_2.tres` | procedural polygon rubble; visibly rejected direction retained for comparison |
| MATERIAL 3 | candidate A | `assets/v0336/materials/material_3.tres` | photo-scanned Poly Haven rubble |

## 5. Corrected mapping

The corrected mapping is generated from the instantiated resource bindings, not copied from the v0.335 JSON. The v0.335 mismatch was `C / A / B`; the v0.336 runtime ledger and compact summary are `C / B / A`.

## 6. Candidate-specific capture repair

Each directory below contains 14 images captured while that material alone was visible. Every image contains the Godot-generated runtime watermark (`MATERIAL 1`, `MATERIAL 2`, or `MATERIAL 3`) and a small resource-hash footer.

- `artifacts/runtime/v0336/material-1/`
- `artifacts/runtime/v0336/material-2/`
- `artifacts/runtime/v0336/material-3/`

The modes are near, front, normal RTS, far RTS, greyscale, thumbnail, neutral, warm, albedo-only, normal-only, normal-disabled, roughness isolation, top-down, and side view. No candidate image is copied into another candidate directory.

## 7. Reused-image diagnosis

The previous pack's candidate boards reused a shared comparison image and therefore could not prove identity. v0.336 builds each board directly from its corresponding candidate directory. The validator checks the SHA-256 of corresponding near, normal, and far renders and rejects reused/identical files.

## 8. Video repetition diagnosis and corrected video

The v0.335 video looped a single visible candidate. v0.336 creates a continuous Godot frame sequence with the same camera route and swaps the instantiated visible material at frames 0, 144, and 288. The corrected output is:

`artifacts/manual-review/v0336-granite-evidence-repair/UPLOAD_TO_CHAT/08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4`

It is H.264, 1280x720, 24 fps, 18 seconds, exactly 432 decoded frames, and has six seconds per material. The MP4 SHA-256 is `69bf274d79cc854b76c6c04f8d8720e15a7bdd5183e268777bdca27312087e15`. Equivalent-frame mean absolute differences between Material 1 and Material 2 are 2.347, 2.346, and 2.344 at the three sampled offsets; the Material 2 segment visibly retains the colored polygon candidate.

## 9. Candidate A PBR

Candidate A is displayed as Material 3. It binds the photo-scanned Poly Haven albedo, height, normal, and roughness maps. Albedo SHA-256: `fce2fe5350bb8ca1ded96b6c81eaacb19126b3bf7d9d59c493cca7f76753796a`; height: `72325fddbf04962e6b79381d2293394e2714a58fa4b500a5bc8ab5c27688003f`; normal: `a3b9c476b2306af9d0f1737f3a1e4abe4460be86dd451e31a99128edbadd590d`; roughness: `1e59cd0b9fea11246fe42a2c96af89f7038910751c001470a6ca29baef934a41`.

## 10. Candidate B PBR

Candidate B is displayed as Material 2. It binds the authored procedural polygon albedo, height, normal, and roughness maps. It remains visibly colored and polygonal in the evidence so the human reviewer sees the rejection honestly. Albedo SHA-256: `a635755bdcf7b2fe0e732899bba3deca44660991954412ace83904a2208d0f8d`; height: `81865332c482e5d69127d72e6388aca510f9ac696b11736066cb29d7620f889b`; normal: `f24923594dbee47b30ec2ba0c57b3c4b4e0d5f7dbcf417e3fc8facbf437465a2`; roughness: `14d49afd130c00ff20284e2cb523ae5f549f55a667ea73f8c242d0462a03f81b`.

## 11. Candidate C PBR

Candidate C is displayed as Material 1. It binds the derived scan-plus-relief albedo, height, normal, and roughness maps. The scene adds one merged `HybridMergedLimitedRelief` mesh containing seven authored relief boxes / 84 triangles, visible in near and side views. Albedo SHA-256: `05a591cca26f3fd55c14d36c4acf853efa90cca4b66ab15b4974729bd32c061a`; height: `b603ac1513eb29cc8b6af7094d7eff39d1ca0c2f38e1259632eeff3c3f2b79bf`; normal: `5ae87dde4f2c80044507541a5af5b8126448176f1e0842860b6bd76f68e01323`; roughness: `3c63b8c19f5d213f68b53bb4235430c15488297cee2f573d72770690387bf2d5`.

## 12. Three stone masks

The pack contains separate masks for all candidates. Material 1 includes both a source-derived stone mask and an authored-relief selection mask. Material 2 uses the existing authored polygon labels. Material 3 derives a source mask from its final height source. The exact mask files and method notes are recorded in the compact summary and shown in `06_THREE_STONE_MASKS_AND_METRICS.png`. The metrics remain rejection aids, not an automated authenticity decision.

## 13. Hybrid relief proof

The hybrid is not represented only by a tinted texture. It is instantiated with one merged relief mesh, seven limited authored relief boxes, and 84 triangles. The near and side captures show the added edge/quoins relief. The rendered M1/M3 SSIM remains high (`0.98693` near, `0.99386` normal RTS), so the honest conclusion is that the hybrid's extra relief is visible in close/side evidence but is not a decisive RTS-distance transformation by itself.

## 14. Candidate distinctness

The generated `artifacts/runtime/v0336/candidate-distinctness.json` records albedo, height, normal, roughness, material-resource, near-view SSIM, and normal-RTS SSIM for all pairs:

| Pair | Near SSIM | Normal RTS SSIM | Material resources |
|---|---:|---:|---|
| M1/M2 | 0.86759 | 0.91675 | distinct |
| M1/M3 | 0.98693 | 0.99386 | distinct |
| M2/M3 | 0.84208 | 0.89771 | distinct |

M1 and M3 share a scan-derived height basis, as documented, but their albedo, normal, roughness, material resource, rendered near view, and rendered RTS response are not functionally identical.

## 15. Normal-only repair

The normal-only mode uses a neutral mid-grey albedo, no albedo texture, a valid normal map, controlled lighting, and non-clipped exposure. The generated diagnostics record mean, standard deviation, clipped white/black percentages, and difference from the normal-disabled render. Results are:

| Material | Mean | Std dev | Clipped white | Clipped black | Difference vs disabled |
|---|---:|---:|---:|---:|---:|
| M1 | 122.382 | 29.750 | 0.195% | 0.000% | 0.504 |
| M2 | 122.529 | 29.929 | 0.174% | 0.000% | 0.502 |
| M3 | 122.472 | 29.739 | 0.065% | 0.000% | 0.508 |

All three pass the v0.336 automated diagnostic thresholds. Human review remains required for whether relief is artistically useful.

## 16. Matched-camera proof

`artifacts/runtime/v0336/matched-camera-ledger.json` records an orthographic 1280x720 camera, the exact normal camera transform and target, matched key/fill rotations and energy, background/ambient values, filmic tone mapping, and disabled fog. The same capture code and light values are used for all candidates.

## 17. Near, normal RTS, far, greyscale and thumbnail comparisons

The independent candidate boards and `05_MATCHED_BLIND_COMPARISON.png` show identical capture modes and crop policy. The three-way comparison is honest: Material 2 is clearly polygonal and colored; Materials 1 and 3 are both scan-derived beige rubble; Material 1 adds limited close-range relief but remains close to Material 3 at normal RTS scale.

## 18. Provisional human direction without automatic winner selection

The pack is ready for a human final granite candidate selection review. It does not approve a material, name a winner, or apply a candidate to House 02. The visible evidence supports Material 3 / candidate A as the clean documentary scanned baseline and Material 1 / candidate C as a plausible hybrid study requiring a human choice about whether its relief contribution justifies the added complexity. Material 2 remains internally rejected for the documented colored polygon/synthetic-panel read.

## 19. Known limitations

- The source-derived candidates share some underlying scan data by design.
- M1/M3 remain visually close at RTS distance; the hybrid relief advantage is strongest in near/side views.
- The masks for scanned candidates are source-derived threshold studies, not hand-authored stone instance segmentation.
- The runtime test structure is an isolated evidence wall, not House 02.
- Human review is still required; automatedVisualApproval is false.

## 20. House 02 preservation

House 02 was not modified. The v0.334 source GLB SHA-256 remains `f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5`. The v0.334 imported-resource record remains `b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531`. No complete v0.336 Blender asset, GLB, roof change, architecture change, or replacement House 02 material binding was created.

## 21. Review-pack manifest

Canonical pack:

`artifacts/manual-review/v0336-granite-evidence-repair/UPLOAD_TO_CHAT/`

It contains exactly ten files. The compact summary is 11,668 bytes. The manifest SHA-256 is `c21416bad1f1d47a5ec1d86a060990a9bef525e6c985aeadcc4e20f417a13383`. The pack includes the Godot-generated binding ledger board, three independent complete evidence boards, blind comparison, all three masks and metrics, all three PBR/normal diagnostics, the corrected 18-second video, and compact JSON.

## Validation and closeout

Dedicated command: `npm run godot:granite-evidence:v0336:validate`.
Local validation includes the v0.336 runtime capture and validator, frozen v0.334 hash checks, candidate-specific provenance checks, matched-camera checks, PBR/normal diagnostics, video frame/duration checks, exact ten-file pack checks, no-reuse checks, and gameplay/House 02 isolation checks. The v0.335 validator and the repository test/build/content/art/runtime/retention/Godot gates are run before commit. Exact pushed-SHA CI evidence and the final clean/synced repository state are recorded in the final closeout after publication.
