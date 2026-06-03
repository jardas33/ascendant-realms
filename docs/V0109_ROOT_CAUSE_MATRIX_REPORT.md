# v0.109 Root-Cause Matrix Report

All rows are private/session-only diagnostic comparisons. They do not change saves, gameplay rules, combat balance, fog simulation, capture logic, stable IDs, art, or public posture.

| Case | Focus | FPS avg | p95 ms | p95 delta | HUD/s | Minimap/s | Fog/s | Notifications/s | DOM | Note |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| baseline | baseline composed representative battle | 2.7 | 499.9 | 0 | 0.4 | 0.4 | 0 | 0 | 821 | baseline |
| campaign-map | non-battle campaign map DOM posture | 10.9 | 166.7 | -333.2 | 0 | 0 | 0 | 0 | 480 | lower p95 than baseline |
| fog-reduced | fog visual redraw cost without changing fog simulation | 2.6 | 500 | 0.1 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| hud-debug | debug counter surface cost | 2.6 | 499.9 | 0 | 0.4 | 0.4 | 0 | 0 | 840 | similar p95 |
| hud-minimal | minimal HUD baseline | 2.6 | 500 | 0.1 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| hud-standard | standard HUD detail surface cost | 2.6 | 483.3 | -16.6 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| labels-hidden | label text/display cost | 2.6 | 499.9 | 0 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| lume-always | max Lume overlay cost | 2.6 | 516.7 | 16.8 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| lume-hidden | hidden Lume render cost | 2.6 | 500 | 0.1 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| minimap-paused | minimap snapshot/render cost ceiling | 2.6 | 533.3 | 33.4 | 0.4 | 0 | 0 | 0 | 821 | similar p95 |
| minimap-reduced | reduced minimap DOM/SVG refresh | 2.6 | 483.3 | -16.6 | 0.4 | 0 | 0 | 0 | 821 | similar p95 |
| notifications-suppressed | status/floating notification cost | 2.6 | 483.3 | -16.6 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| overlays-enabled | maximum private review overlay posture | 2.6 | 483.4 | -16.5 | 0.4 | 0.4 | 0 | 0 | 861 | similar p95 |
| overlays-minimized | minimum private visual overlay posture | 2.6 | 483.2 | -16.7 | 0.4 | 0 | 0 | 0 | 821 | similar p95 |
| profiler-overlay-on | old profiler overlay/panel distortion | 2.7 | 450 | -49.9 | 0.4 | 0.4 | 0 | 0 | 842 | similar p95 |
| results-transition | transition separated from steady-state frame score | 3.1 | 400.1 | -99.8 | 0.5 | 0.5 | 0 | 0 | 821 | lower p95 than baseline |
| rings-minimal | capture-ring graphics cost | 2.7 | 516.5 | 16.6 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| tier-l | local-only high-density stress | 2 | 616.6 | 116.7 | 0.4 | 0.4 | 0 | 0 | 839 | higher p95 than baseline |
| tier-s | small-tier density | 3.1 | 450 | -49.9 | 0.5 | 0.5 | 0 | 0 | 807 | similar p95 |

## Interpretation

Trusted evidence still shows serious browser lag in the baseline; treat the earlier evidence as mixed with real runtime cost, not merely artifact.
