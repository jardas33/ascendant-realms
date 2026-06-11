# v0.211 Production Objectives Event Log Report

Status: PASS.

## Scope

v0.211 polishes only the isolated Godot Salto UI shell opt-in path behind `--salto-selection-command-panel --salto-production-objectives-log`. The default procedural launcher, prior launchers, browser runtime, gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance remain unchanged.

## UI Coverage

- Build tab: Worker-supported Barracks restoration, rally context and future-scope disabled cards.
- Train tab: existing Barracks Militia queue, staged defender state and locked unit explanations.
- Research tab: preview-only unavailable cards with clear why-unavailable messaging.
- Objective stack: current objective, concise next action and bounded progress pips.
- Event log: progression events with safe truncation and restrained severity rails.
- Alert card: right-side hostile-pressure summary with calm/default and hostile states.

## Review Pack

Ignored manual review path:

`artifacts/manual-review/v0211-production-objectives-log/`

Absolute path:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0211-production-objectives-log\`

Required PNGs:

- `01_build.png`
- `02_train.png`
- `03_research.png`
- `04_disabled_tooltip.png`
- `05_initial_objective.png`
- `06_event_progression.png`
- `07_ashen_alert.png`
- `08_overview.png`
- `09_contact_sheet.png`

## Boundary Notes

- Generated images: zero.
- Downloaded assets: zero.
- New runtime art slots: zero.
- Production UI or art slot: zero.
- Browser runtime changes: none.
- Default launcher mutation: none.

## Validation Evidence

- `npm run godot:test` passed.
- `npm run godot:export:windows` passed.
- `npm run godot:package:windows` passed.
- `npm run godot:capture:salto-production-objectives-log` passed and regenerated all required PNGs.
- `npm run godot:validate:salto-production-objectives-log` passed for the v0.211 opt-in path, the prior v0.210 selection-command path and the default procedural path.
- `npm run validate:runtime-art-slots` passed with stable slot order and no runtime slot leakage.
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0211/cleanup-dry-run` passed as a dry run.
- `npm run validate:content` passed.
- `npm run validate:art-intake` passed.
- `npm run build` passed.
- `npm test` passed.
- `git diff --check` passed.

Manual visual review confirmed that Build, Train, Research, disabled-tooltip, objective, event progression, active Ashen alert and overview states are represented. Non-hero selected contexts in this v0.211 path use procedural context emblems, while Aster keeps the validated portrait path.
