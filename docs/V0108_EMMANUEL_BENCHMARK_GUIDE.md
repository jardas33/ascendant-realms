# v0.108 Emmanuel Benchmark Guide

Use this only with the private package or local dev server.

## Private Hub Route

1. Open the private Playtest Hub.
2. Scroll to `REPRESENTATIVE BATTLE BENCHMARK`.
3. Open Tier S first, then Tier M representative.
4. Review Lume Hidden, Auto, and Always.
5. Review fog-heavy, notification-heavy, minimap interaction, and Results transition.
6. Treat Tier L stress as a local/private density check, not a normal playtest target.

## What To Judge

- Does Tier M feel like a useful future desktop benchmark posture?
- Are hero, Worker, Militia, Rangers, Ashen pressure, Command Hall, Barracks, mine/shrine site infrastructure, one resource site, one Lume link, HUD, minimap, and Results all represented?
- Are the 1366x768, 1600x900, and 1920x1080 screenshots readable?
- Do the reports separate browser prototype evidence from final desktop hardware targets?

## What Not To Judge

- Final art quality.
- Final desktop engine performance.
- Final mine/shrine building visuals.
- New gameplay balance.
- Campaign reward/progression outcomes.

## Commands

```text
npm run benchmark:battle:smoke
npm run benchmark:battle:representative
npm run benchmark:battle:report
```

Optional local-only stress:

```text
npm run benchmark:battle:stress
```

## Latest Local Evidence

- Benchmark report: 10 scenarios generated under `artifacts/benchmarks/v0108/`.
- Visual QA: 213 screenshots, 0 console errors, 0 screenshot retries.
- Visual review pack: 213 screenshots and 9 contact sheets.
- In-app Browser check: Representative Battle Benchmark group, Tier S smoke, Tier M representative, and Results-transition entries were visible on the local dev server.
