# v0.118 Godot Headed Benchmark Report

v0.118 measures both placeholder modes inside the packaged Windows executable at 1600x900. This is a workflow benchmark, not a final production certification.

## Modes

- `2D_PLACEHOLDER`
- `2_5D_ORTHOGRAPHIC_PLACEHOLDER`

## Metrics

The headed benchmark records:

- startup time
- scene launch time
- average FPS
- one-percent-low FPS
- frame time p50, p95, p99, and max
- input acceptance timing
- Results transition timing
- Godot version
- fixture hash
- executable hash

## Artifacts

```text
artifacts/desktop-spikes/godot-salto/v0118/headed-benchmark-2d.json
artifacts/desktop-spikes/godot-salto/v0118/headed-benchmark-2_5d.json
```

These reports must remain explicit that no final engine decision is made.

## Current Results

```text
2D status - PASS_PACKAGED_HEADED_BENCHMARK
2D average FPS - 75
2D p95 frame time - 13.42 ms
2D input timing - 0.027 ms
2D Results transition - 66.561 ms

2.5D status - PASS_PACKAGED_HEADED_BENCHMARK
2.5D average FPS - 75.01
2.5D p95 frame time - 13.55 ms
2.5D input timing - 0.189 ms
2.5D Results transition - 66.726 ms

Fixture hash - d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3
Window - 1600x900
```
