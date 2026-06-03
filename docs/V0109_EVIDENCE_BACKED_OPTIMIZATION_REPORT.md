# v0.109 Evidence-Backed Optimization Report

## Top Genuine Cost Signals

1. tier-l: p95 716.5 ms, FPS avg 2, DOM 839, HUD 0.3/s, minimap 0.3/s.
2. labels-hidden: p95 550 ms, FPS avg 2.6, DOM 821, HUD 0.4/s, minimap 0.4/s.
3. baseline: p95 516.7 ms, FPS avg 2.6, DOM 821, HUD 0.4/s, minimap 0.4/s.

## Probable Harness Artifacts

- The previous 1200 ms window was too short for stable FPS claims.
- The previous v0.108 lane used dev-server headless sampling and a visible profiler panel.
- Launch, action, and Results transition work are now separated from steady-state frame scoring.

## Optimizations Applied

- Replaced the automated benchmark protocol with production-preview-first warm-up plus steady-state sampling.
- Kept profiler overlay off by default during trusted samples and measured overlay-on separately.
- Added private session-only diagnostic reductions for labels, rings, Lume visibility, minimap refresh, fog redraw, HUD density, notifications, and profiler overlay so costs can be isolated without changing gameplay.

## Deferred

- Broader rendering or engine work remains deferred for a separate reviewed goal.
