# v0.304 Missing Artifacts Register

`MISSING` entries are explicit findings, not silent omissions.

| Artifact | Status | Search performed | Consequence |
|---|---|---|---|
| v0.138/v0.141 candidate workspace inside recovery checkout | `RECOVERED_FROM_PRESERVED_ORIGINAL_CHECKOUT` | Recovery checkout `artifacts/art-review/`; sibling original checkout; filenames, metadata, hashes | Six candidates were copied into `historical-reference/`; originals were not altered. |
| Historical v0.138/v0.141 playable runtime screenshot | `MISSING` | `artifacts/art-review/`, `artifacts/desktop-spikes/godot-salto/`, Git history, branches/tags | The six attractive frames are concept/reference images, not evidence of a playable v0.138-v0.142 runtime. |
| v0.141 runtime-integrated environment asset | `MISSING_BY_DESIGN` | v0.140-v0.142 reports, metadata, runtime-art manifests | Style lock explicitly kept `runtimeIntegrationStatus = forbidden`; no import should be reconstructed. |
| v0.236 connected playable/runtime replacement | `MISSING_BY_DESIGN` | v0.236 report, scene/source paths, runtime-art manifests | v0.236 is an isolated opt-in scene and does not replace the v0.303 player fixture. |
| Deterministic byte-identical regeneration of AI-generated reference frames | `MISSING` | v0.140/v0.141 metadata and prompt documents | Prompt lineage and recorded SHA-256 are preserved; provider output is not guaranteed byte-identical. |
| Human legal/IP clearance for generated frames | `MISSING` | v0.140/v0.141 metadata and v0.142 style-lock report | `protectedIpReview.status = pending`, `protectedLookalikeRisk = unknown`; references cannot enter runtime. |
| Historical screenshot of the v0.292 no-overlap guarantee in the current capture configuration | `MISSING` | v0.292-v0.303 capture packs and actual v0.303 PLAYER capture | Current actual evidence shows the overlap; v0.304 documents cause and safest next repair instead of changing code. |
| Production-ready unit sprite/animation set matching R1 | `MISSING` | `public/assets`, runtime-art slots, art-source, v0.236 reports | Future work needs original authored units or a bounded billboard pipeline; no unapproved asset import is made here. |
