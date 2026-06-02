# v0.103 Private Performance Profiler Spec

## Purpose

Add a private-package/dev-only profiler that gives deterministic local evidence for UI and battlefield cost signals. It is a QA aid, not a public feature and not a cross-machine benchmark claim.

## Availability

- Installed only when private playtest tools are enabled.
- Off by default.
- Toggled by the private "Perf F8" button or F8.
- Does not write localStorage or mutate saves.
- Does not run requestAnimationFrame sampling or long-task observation while inactive.

## Captured Signals

- Frame timing summary: average FPS, 1% low, p50/p95/p99/max frame time, frames over 16.7/33.3/50 ms.
- Browser long-task count where supported.
- Scene counters: display objects, graphics objects, units, buildings, capture sites, labels, capture rings, Lume links/endpoints, fog visible cells, fog redraws, minimap refreshes, HUD updates, notifications, DOM nodes, optional JS heap use.

## Private Performance Lab

The Playtest Hub gains a private "Performance Lab" group with deterministic fixture launches. Scenarios reuse existing maps, units, Lume definitions, Results fixtures, and private no-save isolation.

## Scripts

- `npm run perf:profile:private`: runs the private lab scenarios through Playwright and writes local ignored artifacts under `artifacts/performance/v0103/`.
- `npm run perf:report:private`: regenerates the markdown summary from the latest private profiling JSON.

## Safety

Generated timing artifacts are ignored by git. Reports must label evidence as local deterministic QA evidence, not human fun data and not hardware-independent benchmark proof.
