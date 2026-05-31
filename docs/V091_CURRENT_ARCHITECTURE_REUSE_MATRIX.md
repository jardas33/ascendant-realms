# v0.91 Current Architecture Reuse Matrix

Status: docs-only technical audit. This document does not choose a desktop engine, port the game, create a wrapper, add dependencies, change runtime behavior, alter saves, or start v0.92.

## Purpose

The current Ascendant Realms browser prototype is still the active development and testing environment. The long-term product target remains a genuine installable desktop RTS/RPG. This matrix classifies the current repository by desktop-transition reuse value so future work can preserve what is valuable without pretending the Phaser prototype can become the full game by wrapping it.

Reuse categories:

- Directly reusable: logic, data, tests, or process can likely move forward with limited adaptation.
- Conceptually reusable: design and behavior are valuable, but runtime implementation probably changes.
- Likely refactor: useful code exists, but boundaries are not yet clean enough for a desktop slice.
- Likely engine-specific rebuild: current implementation is tied to browser, Phaser, DOM, or prototype constraints.
- Defer: do not build this for desktop yet.
- Unknown requiring experiment: needs a benchmark or spike before classification can harden.

## Major Subsystem Matrix

| Subsystem | Current evidence | Reuse classification | Desktop-transition read |
| --- | --- | --- | --- |
| Content data | `src/game/data/*`, `contentIndex.ts`, validation helpers, campaign/modifier/doctrine/relic/skill/event definitions. | Directly reusable | Keep stable IDs and TypeScript data as the source of truth while evaluating whether future runtime consumes TS modules, generated JSON, or an engine-native import format. |
| Hero progression | `progression`, skill trees, relics, equipment, XP, Results integration, save normalization. | Directly reusable | Rules and tuning are portable. UI and animation presentation will need a desktop layer, but the progression model should survive. |
| Race + Class architecture | v0.78/v0.79 docs, runtime hero classes, factions, future race matrix. | Conceptually reusable / likely refactor | Current runtime supports classes and factions, but future Race + Class combinations need a larger content model, clearer public naming, and explicit migration rules. |
| Campaign data | Campaign nodes, chapters, act spine, rewards, unlock rules, optional objectives, replay state. | Directly reusable | Campaign graph and reward rules are a strong portability candidate. The desktop campaign shell UI should be rebuilt around the same graph concepts. |
| Saves | `CURRENT_SAVE_VERSION = 2`, V1 to V2 migration, normalization, localStorage-backed browser save. | Conceptually reusable / likely refactor | Save data shapes and normalization rules are valuable, but desktop needs file locations, profiles, backup/export, corruption handling, and a versioned translation gate. |
| Combat | `CombatSystem`, abilities, status effects, veterancy, tactical feedback. | Likely refactor | Combat rules are useful, but implementation is intertwined with Phaser scene entities, frame update cadence, rendering feedback, and current unit volumes. |
| Pathing | `MovementSystem`, `PathfindingGrid`, formation spacing, Patrol, blocker correction. | Likely engine-specific rebuild | Current grid A* is good prototype evidence. A desktop RTS needs benchmarked pathing, crowd movement, obstacle updates, large-unit cases, and engine fit validation. |
| AI | `EnemyAIController`, doctrines, resource-site strategy, base development, event pressure. | Conceptually reusable / likely refactor | High-level doctrine/state logic is valuable. Command execution, sensing, pathing, and pacing integration should be adapted after engine and benchmark results. |
| Resource sites | Capturable sites, Worker assignment, upgrades, Lume adjacency hooks, campaign objectives. | Directly reusable / conceptually reusable | The system design is portable. Runtime presentation and tactical feedback will need engine/UI-specific treatment. |
| Lume Network | Data definitions, mission-local director, rendering tests, v0.82-v0.85 readability work. | Conceptually reusable | Rules and readability principles are valuable. Link rendering, interaction affordances, VFX, and final art need a desktop visual slice. |
| Retinue | `RetinueRules`, deployment/reserve/recovery/reinforcement, Results summaries. | Directly reusable | Mostly rule-driven and save-backed. Spawn placement, reinforcement UI, and animation need engine integration. |
| HUD | DOM/CSS panels, command panel, objective tracker, minimap, settings scale. | Likely engine-specific rebuild | Information architecture is reusable. Implementation should be rebuilt for the selected desktop UI stack, with v0.88/v0.90 acceptance rules retained. |
| Campaign shell | DOM campaign map, tabs, card hierarchy, progression lanes. | Conceptually reusable / likely engine-specific rebuild | Layout goals and data binding are reusable. The actual UI should be rebuilt or heavily refactored for desktop input, resolution, and accessibility requirements. |
| Results | View models, reward panels, private-demo mode, progressive disclosure. | Conceptually reusable / likely refactor | Flow, reward safety, and view-model logic are useful. Desktop presentation and persistence handoff need a future UI shell. |
| Visual pipeline | v0.88 art gate, style-frame briefs, manifest/metadata, asset validation, current placeholder manifest. | Directly reusable for process; runtime assets prototype-only | Governance and validation should continue. Current prototype art and procedural placeholders are not production art. |
| Audio | `AudioManager` uses simple WebAudio oscillator cues and settings volume. | Likely engine-specific rebuild | Cue taxonomy and settings intent are reusable. Real music/SFX middleware, mixing, spatial policy, and asset licensing need a later audio gate. |
| Input | Phaser pointer input, DOM/canvas interactions, keyboard hotkeys, control groups, Patrol, ability keys. | Likely refactor / engine-specific rebuild | Command model is valuable. Desktop needs explicit action map, rebinding, conflict detection, localization, controller policy if any, and OS-safe focus behavior. |
| Resolution handling | Phaser Scale.RESIZE, CSS desktop acceptance, UI scale setting, visual QA matrix. | Likely refactor | Acceptance criteria are reusable. Desktop needs fullscreen/windowed, resolution selection, DPI scaling, ultrawide policy, and graphics settings. |
| Accessibility | Reduced motion, UI scale, colorblind minimap palette, copy readability, layout assertions. | Conceptually reusable | Policies and tests are useful. Desktop accessibility needs engine support for focus, remapping, contrast, subtitles/captions if audio expands, and readable scaling. |
| Tests | Vitest rules tests, Playwright e2e/visual QA, deterministic labs, package validation. | Directly reusable / conceptually reusable | Pure rule tests and deterministic simulator should be preserved. Browser e2e and visual QA become acceptance reference for a future engine harness. |
| Deterministic simulator | `playtest` labs, Act 1 telemetry, control behavior, scenario reports. | Directly reusable | Strongest transition asset. Keep it as the design-safety oracle while engine experiments are evaluated. |
| Packaging | Vite build, private playtest package, package verification. | Likely engine-specific rebuild | Useful as prototype distribution discipline only. Desktop packaging, installer, patching, crash logs, and build signing need a separate gate. |
| Multiplayer future scope | v0.79 deferred architecture, no runtime multiplayer. | Defer | Do not retrofit now. Future multiplayer must influence engine decision criteria, but implementation waits until single-player vertical slice proves pathing/performance/control. |

## Cross-Cutting Findings

- The most portable assets are data, pure rules, save normalization intent, deterministic simulator coverage, and docs/process gates.
- The least portable assets are Phaser scene composition, DOM-heavy UI shells, WebAudio prototype cues, browser packaging, and current pathing scale assumptions.
- The current prototype remains valuable because it proves campaign flow, combat feel, Retinue/relic/skill loops, Lume readability, Results IA, and QA discipline before a costly desktop transition.
- A future desktop slice should not begin by copying scenes wholesale. It should extract content/rules and validate engine-specific rendering, input, pathing, animation, and packaging through small experiments.

## Non-Goals For v0.91

- No engine winner.
- No wrapper recommendation.
- No runtime code change.
- No save migration.
- No asset import.
- No multiplayer implementation.
