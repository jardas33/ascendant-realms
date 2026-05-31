# v0.91 Staged Transition Experiments

Status: staged experiment roadmap only. This document does not port the game, choose an engine, create a wrapper, add dependencies, import assets, or alter saves.

## Purpose

The desktop transition should proceed through small gates. Each gate should answer one risk with evidence, then stop. This prevents a premature rewrite that loses the hard-won browser prototype, QA suite, and content model.

## Stage 1 - Browser-Prototype Fun Proof

Current status: active path.

Goal:

- Continue proving campaign flow, battle control, hero progression, Retinue, Lume, Results, visual readability, and deterministic telemetry in the browser prototype.

Evidence:

- Act 1 telemetry.
- Hosted release lanes.
- Visual QA matrix.
- Controls verification.
- Emmanuel manual retest packets.

Exit criteria:

- The smallest fun slice has durable human and automated evidence.
- Core loop is stable enough that a desktop slice would validate technology, not redesign every rule.

Stop condition:

- If player-facing control/readability is weak, stay in browser until it is improved.

## Stage 2 - Art-Pipeline Proof

Goal:

- Prove the controlled v0.88 art-intake process with a tiny candidate set before runtime integration.

Inputs:

- Barrosan, Ashen, and Wolfveil style-frame briefs.
- Prompt template library.
- Asset manifest and review gate.

Outputs:

- Human-reviewed style frames or concept sheets.
- Source/license/prompt metadata.
- Rejection or approval notes.

Exit criteria:

- The first small set reads as coherent, original, desktop-quality, and tactically clear.

Stop condition:

- If assets look incoherent, derivative, unreadable, or overproduced, revise briefs instead of importing art.

## Stage 3 - Desktop-Engine Benchmark Spike

Goal:

- Test candidate engine feasibility before selecting a full-game path.

Minimum benchmark:

- Selection, camera, pathing, combat engagement, simple building, one resource site, one Lume link, and one Results transition.
- Representative unit count target documented.
- Build/package proof.
- CI-friendly automation proof.

Outputs:

- Frame posture.
- CPU/GPU/memory notes.
- Input latency notes.
- Build size and startup timing.
- Developer workflow notes.

Exit criteria:

- One option shows credible pathing, UI, performance, packaging, and testability without unacceptable scope cost.

Stop condition:

- If no option passes, continue browser prototype and define a smaller technical experiment.

## Stage 4 - Content-Reuse Proof

Goal:

- Prove that current content data can be consumed by a future engine without changing stable IDs or rewriting gameplay definitions by hand.

Inputs:

- Current TypeScript content data.
- Stable IDs.
- Validation rules.

Outputs:

- Export or import prototype for units, buildings, campaign nodes, hero progression, and rewards.
- Round-trip validation that detects missing or renamed IDs.

Exit criteria:

- Future engine can load content in a deterministic, reviewable way.

Stop condition:

- If engine-native authoring requires ID churn, pause and design an adapter instead.

## Stage 5 - Save-Translation Proof

Goal:

- Prove old prototype saves can be understood or intentionally migrated into a desktop-safe save model.

Inputs:

- V1/V2 save fixtures.
- Current save normalization.
- Campaign, hero, Retinue, relic, skill, and settings fields.

Outputs:

- Translation plan.
- Fixture tests.
- Corrupt/unknown-field behavior.
- Profile/file-location policy.

Exit criteria:

- Save compatibility story is explicit before any desktop runtime writes real player data.

Stop condition:

- If save mapping is ambiguous, mark legacy browser saves as import-only or test fixtures until the desktop schema is approved.

## Stage 6 - Representative Battle Benchmark

Goal:

- Prove actual RTS/RPG battle posture, not just a tech demo.

Scenario:

- One hero.
- One Worker.
- Two player military unit types.
- Ashen enemies.
- Command Hall, Barracks, mine, shrine.
- Resource site.
- Lume link.
- Enemy pressure beat.

Outputs:

- Input responsiveness.
- Pathing/crowd behavior.
- Combat readability.
- HUD density.
- Results transition.
- Automated benchmark and screenshot evidence.

Exit criteria:

- The battle feels controllable and performs within target on the intended desktop acceptance profile.

Stop condition:

- If pathing or UI fails under modest load, do not expand content. Fix the technical base first.

## Stage 7 - Desktop Vertical Slice

Goal:

- Build one installable, representative desktop slice after the benchmark passes.

Scope:

- Salto-inspired region.
- Barrosan Freeholds.
- Ashen Covenant enemy.
- One mission.
- Campaign shell.
- Results.
- Settings/key rebinding/resolution/save proof.

Exit criteria:

- Emmanuel can play the slice, compare it against the browser prototype, and decide whether the desktop path earns full transition planning.

Stop condition:

- If the slice is less readable, less controllable, or less testable than the browser prototype, do not scale up.

## Stage 8 - Full Transition Planning

Goal:

- Only after prior gates pass, plan the full desktop transition.

Required inputs:

- Engine benchmark evidence.
- Vertical slice package.
- Save/content reuse proof.
- Art pipeline proof.
- QA automation proof.
- Cost/schedule/risk estimate.

Out of scope until then:

- Full production port.
- Multiplayer implementation.
- Multiple races.
- Final public title runtime migration.
- Large asset import.

## Operating Rule

Every stage should leave the browser prototype usable. The prototype is not disposable; it is the design, QA, and content evidence base that makes the desktop transition less speculative.
