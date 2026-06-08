# v0.169 Aster Benchmark, Fallback, And Boundary Report

Status: `PASS_V0169_ASTER_BENCHMARK_FALLBACK_BOUNDARY`

Primary gate:

```text
npm run godot:validate:salto-worker-barracks-militia-aster-art-experiment
```

PASS token:

```text
PASS_V0168_WORKER_BARRACKS_MILITIA_ASTER_ART_OPT_IN_AUTOMATION_READY
```

The historical PASS token remains v0.168 because the same four-slot report tool is reused, but all current evidence is written under `artifacts/desktop-spikes/godot-salto/v0169/`.

Benchmark scorecard:

- Report: `artifacts/desktop-spikes/godot-salto/v0169/benchmark/worker-barracks-militia-aster-art-opt-in-scorecard.json`
- Status: `PASS_V0168_ASTER_OPT_IN_BENCHMARK`
- M4 FPS ratio versus M0: `0.9960`
- M4 FPS ratio versus M3: `0.9985`
- M4 p95 frame-time ratio versus M0: `0.9895`
- M4 p95 frame-time ratio versus M3: `0.9947`

Acceptance thresholds:

- FPS ratios are both above `0.90`.
- p95 frame-time ratios are both below `1.15`.

Aster runtime posture:

- Scale: `1.08`
- Runtime world height: `0.9936`
- Runtime world width: `0.9936`
- Rendered benchmark pixel height: `96.67`
- Hierarchy versus Militia: `1.4612`
- Hierarchy versus Worker: `1.3427`
- Aspect ratio preserved: `true`
- Pivot: `bottom-center-foot-pivot`
- Foreground readability posture: `foregroundDepthBypassForHeroReadability=true`, `renderPriority=2`

Fallbacks:

- Missing-art fallback status: procedural Aster restored, `fallbackMode=missing`, `fallbackReason=missing source file`.
- Hash-mismatch fallback status: procedural Aster restored, `fallbackMode=hash-mismatch`, `fallbackReason=metadata hash mismatch`.
- In both fallback modes, Worker, Barracks, and Militia remain active.

Boundary:

- Report: `artifacts/desktop-spikes/godot-salto/v0169/boundary/worker-barracks-militia-aster-art-opt-in-boundary-scan.json`
- Status: `PASS_V0168_PLAYER_SLICE_FOUR_SLOT_BOUNDARY`
- Default launchers procedural: `true`
- Exactly four opt-in normal-slice slots: `true`
- Fifth slot added: `false`
- Browser runtime changed: `false`
- Generated new images: `false`
- Save/stable-ID mutation: `false`
- Package leakage: `false`

Retention and cleanup:

- `npm run godot:validate:salto-experimental-artifact-retention`
- `npm run godot:cleanup:salto-experimental-artifacts`

Both must remain green before the checkpoint commit.
