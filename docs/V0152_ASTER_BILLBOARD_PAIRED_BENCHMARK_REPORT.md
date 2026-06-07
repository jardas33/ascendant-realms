# v0.152 Aster Billboard Paired Benchmark Report

Status: `PASS_V0152_ASTER_BILLBOARD_REPAIR_GATE`.

The private repair comparator benchmarked the preserved diagnostic fallback against the same-source Aster repair candidates at Tier S, M, and L. Tier L used five rotated trials per source.

Selected recommendation: `HYBRID_ASTER_TRIMMED_1024`.

Selected SHA-256: `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`.

Evidence:

- Runtime evidence: `PASS_V0152_ASTER_BILLBOARD_REPAIR_EVIDENCE_RECORDED`.
- Benchmark rows: `35`.
- Screenshot manifest: `31` captures.
- Source image count: `1`.
- Fallback Tier L mean FPS: `1151.29`; p95 mean: `1.13 ms`.

Tier L gate summary:

| Candidate | FPS ratio | p95 ratio | Mean FPS | Mean p95 | Trials | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `HYBRID_ASTER_FULL_RES` | `0.9766` | `1.0531` | `1124.33` | `1.19 ms` | `5` | PASS |
| `HYBRID_ASTER_TRIMMED_512` | `1.0127` | `0.9912` | `1165.91` | `1.12 ms` | `5` | PASS |
| `HYBRID_ASTER_TRIMMED_768` | `0.9935` | `0.9469` | `1143.84` | `1.07 ms` | `5` | PASS |
| `HYBRID_ASTER_TRIMMED_1024` | `0.9708` | `1.0088` | `1117.66` | `1.14 ms` | `5` | PASS |

Preserved gate:

- FPS ratio >= 0.90 versus fallback.
- p95 frame-time worsening <= 15 percent versus fallback.
- Hero readability true.
- Worker distinction true.
- No obvious halo true.
- Foot pivot stable true.
- Selection ring visible true.

Human review remains required for final identity, halo, and edge-quality judgement. This report does not approve production art or runtime integration.
