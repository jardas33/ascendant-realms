# v0.112 Emmanuel Retest Checklist

- Run `npm run perf:trusted:preview` and compare the Tier M baseline with v0.111.
- Run `npm run perf:trusted:clean-profile` to confirm the host classification remains game-cost dominant.
- Run `npm run perf:phase-profile`, `npm run perf:allocation-audit`, and `npm run perf:idle-cost-matrix`.
- Confirm linked_ward remains exactly 0.92.
- Confirm Tutorial, Tier M, minimap, fog, HUD, Lume, Results, reset, and return-to-hub paths remain no-save and stable.
- Package with `npm run package:playtest` and verify with `npm run verify:playtest-package`.
