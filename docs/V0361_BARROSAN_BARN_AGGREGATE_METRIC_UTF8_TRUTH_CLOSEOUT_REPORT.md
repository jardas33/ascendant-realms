# v0.361 Barrosan Barn Aggregate-Metric and UTF-8 Truth Closeout

## Decision

v0.360 was visually accepted for its eight boards, Board 06 legibility, Board 08 presentation, raw-array exclusion, and ten-file structure. Documentary closeout was rejected because its compact summary mixed capped v0.358 performance values with the accepted uncapped v0.359 benchmark, while its README and JSON carried visible encoding/control corruption despite claiming zero defects. v0.361 repairs that evidence layer only.

## Scope and freeze

Base HEAD: `7b0500095973b839719bea32bd956195c2126689`
Branch: `codex/v0215-v0226-recovery`

The canonical Barn scene, meshes, materials, textures, UVs, roof, shutters, transforms, cameras, raw captures, raw benchmark arrays, loader behavior, fail-closed behavior, rollback behavior, gameplay, production runtime, default launcher, browser runtime, collision, navigation, animation, props, and visual slots were not changed or rerun. Boards 01–07 were not regenerated. Board 08 was retained losslessly.

Mutation counts are all zero:

| Mutation | Count |
|---|---:|
| canonical asset / geometry / material / texture / transform | 0 |
| gameplay / default runtime / browser | 0 |
| save / stable ID / capture / benchmark rerun | 0 |

## Aggregate repair

Canonical source: `artifacts/performance/v0359-barrosan-barn/v0359-performance.json`
Protocol: `v0.359-uncapped-v1`
Samples: 3,600 default and 3,600 opt-in.

The six stale capped fields found in v0.360 were:

| Field | Capped value before repair |
|---|---:|
| defaultOnePercentLowFps | 72.8228845017675 |
| optInOnePercentLowFps | 72.7285704510637 |
| defaultMedianFrameTimeMs | 13.333 |
| optInMedianFrameTimeMs | 13.332 |
| defaultP99FrameTimeMs | 13.489 |
| optInP99FrameTimeMs | 13.541 |

All aggregate scalars were copied from the retained uncapped source; deltas and ratios use those same exact source values. Board 08 uses display rounding only: FPS to two decimals and frame times to three decimals. The compact summary retains exact source scalars. Cross-file aggregate mismatch count is zero.

| Aggregate | Default | Opt-in |
|---|---:|---:|
| Median FPS | 1461.98830409357 | 1451.37880986938 |
| 1% low FPS | 623.138273033618 | 580.501026458428 |
| Median frame time (ms) | 0.685 | 0.689 |
| P95 frame time (ms) | 1.271 | 1.349 |
| P99 frame time (ms) | 1.475 | 1.603 |
| Maximum frame time (ms) | 2.211 | 2.419 |

Additional retained aggregates are 74/116 draw calls, 26,956/31,676 primitives, 53/73 loaded resources, and 61/82 total nodes for default/opt-in. The deltas are 42 draw calls, 4,720 primitives, 20 resources, and 21 nodes. Over-50-ms spike counts remain 0/0. Median FPS ratio is `0.992743105950653`; P95 frame-time ratio is `1.06136900078678`.

## UTF-8 truth repair

The prior README had a leading BOM and one U+0007 control character before the external performance path. The prior compact JSON had a leading BOM and mojibake in the human-decision text. v0.361 writes the README, compact summary, and report as strict UTF-8 without a BOM, and scans contents and filenames for mojibake signatures, C0 controls except tab/LF/CR, DEL, U+FFFD, and BOM leakage.

The repaired decision text is:

`V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`

After repair: `utf8Valid=true`, mojibake `0`, forbidden control characters `0`, replacement characters `0`, BOM leakage `0`.

## Retained key contract

All 82 v0.358 top-level keys remain present, with missing retained key count `0`. The validator distinguishes key preservation from value copying: the six stale performance fields remain keys, but their obsolete values are not copied unchanged. No raw arrays are present in the upload pack; the raw source remains external.

## Exact review-pack inventory

`artifacts/manual-review/v0361-barrosan-barn-aggregate-metric-utf8-truth-closeout/UPLOAD_TO_CHAT/` contains exactly ten files:

1. `00_READ_ME_FIRST.md`
2. `01_HUMAN_DECISION_AND_SINGLE_SLOT_AUTHORITY.png`
3. `02_EXACT_SINGLE_SLOT_DEFAULT_VS_OPT_IN.png`
4. `03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png`
5. `04_RTS_DISTANCE_AND_TERRAIN_CONTACT.png`
6. `05_FRONT_REAR_AND_EXTERIOR_ROOF.png`
7. `06_FOUR_FAIL_CLOSED_STATES.png`
8. `07_EXACT_ROLLBACK_AND_DEFAULT_PRESERVATION.png`
9. `08_UNCAPPED_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png`
10. `compact-evidence-summary.json`

There are exactly eight PNGs, no video, no CSV, no manifest, no raw JSON, and no raw benchmark arrays in the pack. The eight PNGs are byte-identical to the accepted v0.360 pack; Board 08's displayed values agree with the corrected source within its documented display precision.

## Validator and negative tests

Dedicated command:

`npm run godot:validate:salto-v0361-barrosan-barn-aggregate-metric-utf8-truth-closeout`

The validator checks canonical hashes, lossless board retention, raw sample counts, raw-array exclusion, exact aggregate derivation, stale-value absence, report/summary/Board 08 consistency, retained key coverage, strict UTF-8, filename/content scans, the exact ten-file contract, mutation counts, and compact-summary size. Its negative tests fail for a stale capped value, mojibake, U+0007, U+FFFD, a Board 08 mismatch, a missing retained key, or an injected raw benchmark array.

## Deferred work

No visual, runtime, gameplay, production integration, collision, navigation, animation, props, default enablement, or new visual slot work belongs to v0.361. This checkpoint stops for human review.

<!-- V0361_AGGREGATES_BEGIN -->
{
  "performanceSampleCountDefault": 3600,
  "performanceSampleCountOptIn": 3600,
  "defaultMedianFps": 1461.98830409357,
  "optInMedianFps": 1451.37880986938,
  "medianFpsRatio": 0.992743105950653,
  "defaultOnePercentLowFps": 623.138273033618,
  "optInOnePercentLowFps": 580.501026458428,
  "defaultMedianFrameTimeMs": 0.685,
  "optInMedianFrameTimeMs": 0.689,
  "defaultP95FrameTimeMs": 1.271,
  "optInP95FrameTimeMs": 1.349,
  "p95FrameTimeRatio": 1.06136900078678,
  "defaultP99FrameTimeMs": 1.475,
  "optInP99FrameTimeMs": 1.603,
  "defaultMaximumFrameTimeMs": 2.211,
  "optInMaximumFrameTimeMs": 2.419,
  "defaultOver50MsSpikeCount": 0,
  "optInOver50MsSpikeCount": 0,
  "defaultDrawCalls": 74,
  "optInDrawCalls": 116,
  "drawCallDelta": 42,
  "defaultTriangleOrPrimitiveCount": 26956,
  "optInTriangleOrPrimitiveCount": 31676,
  "primitiveDelta": 4720,
  "defaultLoadedResourceCount": 53,
  "optInLoadedResourceCount": 73,
  "resourceDelta": 20,
  "defaultTotalNodeCount": 61,
  "optInTotalNodeCount": 82,
  "nodeDelta": 21
}
<!-- V0361_AGGREGATES_END -->
