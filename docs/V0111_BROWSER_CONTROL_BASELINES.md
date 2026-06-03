# v0.111 Browser Control Baselines

Private reproducibility evidence. These controls compare host/browser overhead, simple rendering, Phaser baseline posture, campaign-map posture, and Tier M battle cost without changing saves or gameplay.

Rows: 10. Warm-up: 5000 ms. Sample: 10000 ms.

| Control | Mode | FPS avg | 1% low | p50 | p95 | p99 | max | long tasks | DOM | Save mutation |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| blank-page-raf | clean-profile-headless | 60.1 | 59.52 | 16.7 | 16.7 | 16.8 | 16.8 | 0 | 4 | no |
| phaser-empty-scene | clean-profile-headless | 60 | 59.52 | 16.7 | 16.7 | 16.8 | 16.8 | 3 | 7 | no |
| campaign-map | clean-profile-headless | 9.8 | 2.4 | 83.4 | 300 | 416.7 | 416.7 | 4 | 480 | no |
| tier-m-representative-battle | clean-profile-headless | 2.5 | 2.07 | 400.1 | 483.3 | 483.3 | 483.3 | 51 | 829 | no |
| blank-page-raf | preview-headless | 60.1 | 59.52 | 16.7 | 16.7 | 16.8 | 16.8 | 0 | 4 | no |
| simple-dom | preview-headless | 60.1 | 59.52 | 16.7 | 16.7 | 16.8 | 16.8 | 0 | 127 | no |
| simple-canvas | preview-headless | 60.1 | 59.52 | 16.7 | 16.7 | 16.8 | 16.8 | 0 | 6 | no |
| phaser-empty-scene | preview-headless | 60 | 59.52 | 16.7 | 16.7 | 16.8 | 16.8 | 4 | 7 | no |
| campaign-map | preview-headless | 9.9 | 2 | 83.4 | 183.4 | 500 | 500 | 8 | 480 | no |
| tier-m-representative-battle | preview-headless | 2.5 | 1.88 | 400 | 516.6 | 533.3 | 533.3 | 50 | 829 | no |

## Interpretation

- Slow blank/simple controls point at host or browser environment contribution.
- Healthy blank/simple/canvas but slow Phaser-empty points at Phaser/browser scene posture.
- Healthy controls and Phaser-empty but slow Tier M points at battle-code cost.
