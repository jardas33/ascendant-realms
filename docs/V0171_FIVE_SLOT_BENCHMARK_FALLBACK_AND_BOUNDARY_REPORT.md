# v0.171 Five-Slot Benchmark, Fallback, And Boundary Report

Status: `PASS_V0171_FIVE_SLOT_BENCHMARK_FALLBACK_BOUNDARY`

This report consolidates the already-selected five-slot Godot Salto opt-in evidence after v0.170 and confirms the v0.171 freeze boundary. It adds no images, adds no art slots, and integrates nothing into the browser runtime.

## Fallback Matrix

| Mode | Evidence | Loaded slots | Status |
| --- | --- | ---: | --- |
| M0 default procedural | `v0160/validation/worker-art-opt-in-validation.json` | 0 / 0 | `PASS_V0160_WORKER_ART_OPT_IN_VALIDATION` |
| M1 Worker opt-in | `v0160/validation/worker-art-opt-in-validation.json` | 1 / 1 | Worker missing-art and hash-mismatch fall back closed |
| M2 Worker + Barracks | `v0162/validation/worker-barracks-art-opt-in-validation.json` | 2 / 2 | Barracks missing-art and hash-mismatch fall back closed while Worker remains active |
| M3 Worker + Barracks + Militia | `v0164/validation/worker-barracks-militia-art-opt-in-validation.json` | 3 / 3 | Militia missing-art and hash-mismatch fall back closed while Worker/Barracks remain active |
| M4 Worker + Barracks + Militia + Aster | `v0168/validation/worker-barracks-militia-aster-art-opt-in-validation.json` | 4 / 4 | Aster missing-art and hash-mismatch fall back closed while prior slots remain active |
| M5 Worker + Barracks + Militia + Aster + Ashen | `v0170/validation/five-slot-art-opt-in-validation.json` | 5 / 5 | Ashen missing-art and hash-mismatch fall back closed while prior slots remain active |

## Benchmark Matrix

| Mode | FPS | P95 frame time | Evidence |
| --- | ---: | ---: | --- |
| M0 procedural baseline | 75.03 | 13.64 | `v0170/benchmark/five-slot-art-opt-in-benchmark-report.json` |
| M3 Worker + Barracks + Militia | 75.57 | 12.88 | `v0164/benchmark/worker-barracks-militia-art-opt-in-benchmark-report.json` |
| M4 Worker + Barracks + Militia + Aster | 75.19 | 13.25 | `v0170/benchmark/five-slot-art-opt-in-benchmark-report.json` |
| M5 Worker + Barracks + Militia + Aster + Ashen | 75.05 | 12.42 | `v0170/benchmark/five-slot-art-opt-in-benchmark-report.json` |

M5 benchmark gates:

- FPS ratio versus M0: `1.0003`, threshold `>= 0.90`.
- FPS ratio versus M4: `0.9981`, threshold `>= 0.90`.
- P95 ratio versus M0: `0.9106`, threshold `<= 1.15`.
- P95 ratio versus M4: `0.9374`, threshold `<= 1.15`.

The M5 path remains inside the accepted performance envelope. The v0.170 boundary report also records no per-frame art-package leakage and no forbidden browser/save/default-launcher mutation.

## Boundary Findings

| Boundary | Result |
| --- | --- |
| Default player launcher remains procedural | PASS |
| Default stabilized launcher remains procedural | PASS |
| Worker-only launcher preserved | PASS |
| Worker + Barracks launcher preserved | PASS |
| Worker + Barracks + Militia launcher preserved | PASS |
| Worker + Barracks + Militia + Aster launcher preserved | PASS |
| Five-slot launcher remains opt-in | PASS |
| Sixth character slot added | FAIL condition avoided, no sixth slot |
| New image generation | None |
| Browser runtime mutation | None |
| Save or stable-ID mutation | None |
| Gameplay, objective, AI, balance, or campaign mutation | None |
| Default art enablement | None |

## Conclusion

The five-slot opt-in posture remains performant and fail-closed. It should stay experimental and opt-in while the next phase moves to procedural environment-shell readability instead of adding more character art slots.
