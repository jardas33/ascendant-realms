# v0.141 Salto Environment Style-Lock Review Guide

Date: 2026-06-06

This guide is for Emmanuel's human review of the v0.141 revised Salto environment reference candidates. These images are reference-only and forbidden for runtime integration.

## Review Inputs

Open the updated local contact sheet:

```text
artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.svg
```

Inspect the three revised candidates:

```text
artifacts/art-review/v0138/candidates/v0141-env-r1-gameplay-first-barrosan.png
artifacts/art-review/v0138/candidates/v0141-env-r2-barrosan-signature.png
artifacts/art-review/v0138/candidates/v0141-env-r3-modern-balanced-ashen-contrast.png
```

Use this local ignored review note for the decision:

```text
artifacts/art-review/v0138/review-notes/v0141-salto-environment-style-lock-review.md
```

## Intended Comparison

- Compare R1 against Candidate A for gameplay-first tactical readability.
- Compare R2 against Candidate A for Barrosan material identity and strong Salto sense of place.
- Compare R3 against Candidate C for tactical layout, 2.5D composition, and readable Ashen contrast.
- Use Candidate B only as a restrained atmosphere reference; do not let it pull the direction into moody, low-readability concept art.

## Review Questions

1. Which revised candidate best supports a modern top-down RTS/RPG slice?
2. Which candidate best evokes the spirit of a super-cool 2026 evolution of Warlords Battlecry while remaining original IP?
3. Which candidate has the clearest playable read for lanes, mine/quarry, build area, Lume landmark, and Ashen pressure route?
4. Which candidate gives the strongest Barrosan terrain and material signature?
5. Which candidate should become the next reference-only style-lock base, if any?

## Decision Options

Record one of these outcomes in the local review note:

- Shortlist R1.
- Shortlist R2.
- Shortlist R3.
- Request one more revision round.
- Reject all candidates.
- Approve one candidate as the reference-only style-lock base.

Approving a reference-only style-lock base is not runtime approval. It only authorizes future style guidance if a later explicit prompt asks for it.

## Hard Boundary

All six current candidates keep `runtimeIntegrationStatus = forbidden`.

Do not import these images into Godot or the browser. Do not wire them into manifests, art slots, packages, sprites, textures, models, UI kits, or scene files. Do not treat them as protected-IP cleared. Do not start v0.142 until a future explicit goal approves the next step.
