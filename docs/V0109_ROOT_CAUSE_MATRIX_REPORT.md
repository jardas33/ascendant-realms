# v0.109 Root-Cause Matrix Report

All rows are private/session-only diagnostic comparisons. They do not change saves, gameplay rules, combat balance, fog simulation, capture logic, stable IDs, art, or public posture.

| Case | Focus | FPS avg | p95 ms | p95 delta | HUD/s | Minimap/s | Fog/s | Notifications/s | DOM | Note |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| baseline | baseline composed representative battle | 2.6 | 516.7 | 0 | 0.4 | 0.4 | 0 | 0 | 821 | baseline |
| campaign-map | non-battle campaign map DOM posture | 10.6 | 183.3 | -333.4 | 0 | 0 | 0 | 0 | 480 | lower p95 than baseline |
| fog-reduced | fog visual redraw cost without changing fog simulation | 2.7 | 499.9 | -16.8 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| hud-debug | debug counter surface cost | 2.5 | 483.4 | -33.3 | 0.4 | 0.4 | 0 | 0 | 840 | similar p95 |
| hud-minimal | minimal HUD baseline | 2.6 | 483.3 | -33.4 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| hud-standard | standard HUD detail surface cost | 2.6 | 466.7 | -50 | 0.4 | 0.4 | 0 | 0 | 821 | lower p95 than baseline |
| labels-hidden | label text/display cost | 2.6 | 550 | 33.3 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| lume-always | max Lume overlay cost | 2.6 | 483.3 | -33.4 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| lume-hidden | hidden Lume render cost | 2.6 | 466.7 | -50 | 0.4 | 0.4 | 0 | 0 | 821 | lower p95 than baseline |
| minimap-paused | minimap snapshot/render cost ceiling | 2.6 | 483.2 | -33.5 | 0.4 | 0 | 0 | 0 | 821 | similar p95 |
| minimap-reduced | reduced minimap DOM/SVG refresh | 2.6 | 516.6 | -0.1 | 0.4 | 0 | 0 | 0 | 821 | similar p95 |
| notifications-suppressed | status/floating notification cost | 2.6 | 516.5 | -0.2 | 0.4 | 0.4 | 0 | 0 | 821 | similar p95 |
| overlays-enabled | maximum private review overlay posture | 2.5 | 533.4 | 16.7 | 0.4 | 0.4 | 0 | 0 | 861 | similar p95 |
| overlays-minimized | minimum private visual overlay posture | 2.6 | 466.6 | -50.1 | 0.4 | 0 | 0 | 0 | 821 | lower p95 than baseline |
| profiler-overlay-on | old profiler overlay/panel distortion | 2.7 | 433.2 | -83.5 | 0.4 | 0.4 | 0 | 0 | 842 | lower p95 than baseline |
| results-transition | transition separated from steady-state frame score | 3.1 | 400 | -116.7 | 0.5 | 0.5 | 0 | 0 | 821 | lower p95 than baseline |
| rings-minimal | capture-ring graphics cost | 2.6 | 450 | -66.7 | 0.4 | 0.4 | 0 | 0 | 821 | lower p95 than baseline |
| tier-l | local-only high-density stress | 2 | 716.5 | 199.8 | 0.3 | 0.3 | 0 | 0 | 839 | higher p95 than baseline |
| tier-s | small-tier density | 3.2 | 433.3 | -83.4 | 0.5 | 0.5 | 0 | 0 | 807 | lower p95 than baseline |

## Interpretation

Trusted evidence still shows serious browser lag in the baseline; treat the earlier evidence as mixed with real runtime cost, not merely artifact.
