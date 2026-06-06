# v0.145 HUD Reference-Style Review Guide

Date: 2026-06-06

Status: Emmanuel human review guide for reference-only Salto HUD frames.

## What To Review

Review the three local v0.145 HUD candidates:

```text
artifacts/art-review/v0138/candidates/v0145-hud-h1-gameplay-first-tactical-clarity.png
artifacts/art-review/v0138/candidates/v0145-hud-h2-barrosan-material-restraint.png
artifacts/art-review/v0138/candidates/v0145-hud-h3-modern-balanced-pc-rts.png
```

The contact sheet and review pack are:

```text
artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.svg
artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json
```

Use the local review note:

```text
artifacts/art-review/v0138/review-notes/v0145-salto-hud-reference-style-review.md
```

## Human Decision Fields

- Shortlist H1.
- Shortlist H2.
- Shortlist H3.
- Approve a combined HUD reference direction.
- Request one more narrowly bounded HUD revision.
- Reject all.
- Proceed next to runtime-art pipeline decision preparation.
- Defer pipeline and explore another reference category.

## Candidate Reading

H1, `v0145-hud-h1-gameplay-first-tactical-clarity`, is the gameplay-first tactical clarity candidate. Judge it for fast hierarchy, central playfield protection, resource/objective/minimap scanning, and progress-state readability.

H2, `v0145-hud-h2-barrosan-material-restraint`, is the Barrosan material-restraint candidate. Judge it for whether weathered timber, dark iron, leather, bronze, cloth, carved stone, wet granite, restrained warmth, and Lume teal create useful identity without harming usability.

H3, `v0145-hud-h3-modern-balanced-pc-rts`, is the polished modern PC RTS/RPG balance candidate. Judge it for compact density, modern clarity, negative space, selected-entity context, and whether it feels original rather than generic.

## Review Questions

- Which H frame best preserves the existing Salto microloop information architecture?
- Which frame keeps the central combat and movement space most readable?
- Which frame makes mine conversion, Worker assignment, Barracks restoration, Militia recruitment, Ashen countdown, combat, Lume restoration, and Results readiness easiest to scan?
- Which minimap best communicates terrain outline, camera viewport, Aster, Worker, friendly group, active Ashen pressure, current objective, controlled mine, Barracks, and Lume endpoint/link posture?
- Which frame feels most original for JARDAS without protected-game lookalike risk?
- Does any frame become a mobile-game card stack, dashboard, MMORPG hotbar, gothic ornament wall, or protected RTS HUD imitation?
- Does any frame imply a gameplay flow beyond the current Salto player-facing slice?

## Runtime Boundary

Do not import, wire, register, package, approve, or load any frame for Godot or browser runtime use. Keep `runtimeIntegrationStatus = forbidden`. This review can only approve, reject, or request revisions to reference direction.

v0.146 is not started.
