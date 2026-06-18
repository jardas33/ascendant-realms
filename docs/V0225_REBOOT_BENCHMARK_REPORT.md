# v0.225 Reboot Benchmark Report

Date: 2026-06-17

| Path | Mean FPS | p95 frame time |
|---|---:|---:|
| Procedural default | 75.68 | 12.81 ms |
| v0.223 reboot comparator | 58.97 | 9.34 ms |
| v0.224/v0.225 selected reboot | 66.24 | 13.97 ms |

The selected reboot is 12.3% faster than the fresh v0.223 comparator and 12.5% slower than procedural default. Cache counters show one-time source decode/material creation with reuse thereafter; no per-frame decode or material creation was observed. This is acceptable for the isolated review path and is not a catastrophic regression.
