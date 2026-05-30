# v0.78 Browser To Desktop Transition Gate

Date: 2026-05-30

## Status

The current game is a browser-based Phaser 3, TypeScript, and Vite RTS/RPG prototype. The long-term target is an installable desktop RTS/RPG. v0.78 does not start the desktop port and does not choose an engine.

## Core Principle

The final desktop game must not feel like a browser game merely wrapped inside an executable.

## Stage 1 - Browser Prototype

Purpose:

- prove the core loop is fun,
- validate gameplay,
- test systems,
- validate campaign pacing,
- stabilize controls,
- establish visual direction,
- support automated QA.

Current prototype components directly reusable as design proof:

- hero progression,
- skills and relic builds,
- Workers, construction, training, research,
- mines/resource sites and upgrades,
- campaign nodes, rewards, replay,
- rival commanders,
- Retinue persistence/recovery/reinforcement,
- doctrines, elites, tactical plans, battlefield events,
- control groups, Patrol, formation-aware movement,
- Act 1 pacing and finale structure,
- automated test and package workflows.

## Stage 2 - Desktop Vertical Slice

Purpose: later gated milestone, not v0.78.

Representative scope:

- installable PC build,
- one polished region,
- one polished faction,
- one polished hero,
- representative units and buildings,
- upgraded animation, VFX, sound, and desktop UX,
- graphics settings,
- performance audit,
- explicit engine and packaging decision.

## Stage 3 - Full Desktop Game

Purpose:

- commercial-quality installable RTS/RPG,
- long campaign,
- multiple playable races,
- Race + Class hero combinations,
- skirmish,
- replayability,
- escalating endgame content,
- future online PvP,
- future online co-op Expeditions.

## Reuse Classification

| Area | Reuse category | Notes |
| --- | --- | --- |
| Game rules and data shapes | Directly reusable or portable | TypeScript rules can inform future engine code. |
| Campaign/reward/progression models | Directly reusable conceptually | May need UI and save refactor for desktop. |
| Automated tests/simulators | Directly reusable as design safety | Some e2e tests may be replaced by engine-specific automation. |
| Phaser battle scenes | Conceptually reusable | Likely engine-specific rebuilding if moving away from Phaser. |
| Current art assets | Prototype only | Require source/license/style review and likely replacement. |
| UI layout | Conceptually reusable | Desktop UX needs settings, saves, rebinds, resolution support. |
| Save format | Prototype-compatible | Desktop save management needs a dedicated gate. |
| Multiplayer/co-op | Deferred | Requires future online architecture. |

## Desktop Engine Decision Gate

Do not finalize an engine now. A future gate should evaluate:

- whether browser gameplay is fun and stable,
- ability to support large RTS scenes,
- pathing and AI performance,
- 2D/2.5D/3D art pipeline fit,
- animation and VFX workflow,
- UI tooling and accessibility,
- save management,
- mod/content workflow,
- build packaging and patching,
- performance profiling,
- multiplayer roadmap,
- test automation,
- team familiarity and long-term maintenance.

## Deferred

No Electron, Tauri, wrapper, engine switch, desktop packaging script, or desktop settings implementation is approved in v0.78.
