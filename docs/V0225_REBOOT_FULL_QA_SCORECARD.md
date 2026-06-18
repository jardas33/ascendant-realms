# v0.225 Reboot Full QA Scorecard

Date: 2026-06-17

Status: PASS.

- Packaged Windows capture: 23 states passed.
- Full progression and restart/replay posture: passed.
- Procedural default, v0.223 comparator and v0.224 selected path: passed.
- Missing-ground fallback: passed.
- Resolution matrix: 1366x768, 1600x900 and 1920x1080 passed.
- Runtime-art slots: 52 slots validated.
- Content and art-intake validation: passed.
- Godot scaffold: passed.
- Vitest: 122 files and 887 tests passed.
- Production build: passed.
- Retention, cleanup and diff hygiene: passed.

One harness race was repaired: the v0.224 capture wrapper now waits for the manifest to reach `PASS_PLAYER_SLICE_CAPTURE` instead of treating the first partially written JSON snapshot as final.
