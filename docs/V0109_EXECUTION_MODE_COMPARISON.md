# v0.109 Execution Mode Comparison

Production preview is the primary automated evidence lane. Dev-server results are secondary; headed/manual evidence is local-only when available.

| Case | Mode | Visibility | Viewport | User agent | Overlay | Warm-up | Sample | FPS avg | p95 ms |
| --- | --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| mode-dev-headless | dev server + headless Playwright | visible | 1600x900 | Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHT... | off | 5000 | 10000 | 2.7 | 466.6 |
| baseline | production preview + headless Playwright | visible | 1600x900 | Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHT... | off | 5000 | 10000 | 2.6 | 516.7 |
| mode-preview-headless | production preview + headless Playwright | visible | 1600x900 | Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHT... | off | 5000 | 10000 | 2.6 | 466.7 |
