# v0.143 Silhouette-Scale Review Guide

Date: 2026-06-06

Status: Emmanuel human review guide for reference-only Aster / Worker silhouette-scale boards.

## What To Review

Review the three local candidate boards:

```text
artifacts/art-review/v0138/candidates/v0143-silhouette-s1-gameplay-first-readability.png
artifacts/art-review/v0138/candidates/v0143-silhouette-s2-barrosan-grounded-identity.png
artifacts/art-review/v0138/candidates/v0143-silhouette-s3-modern-balanced-scale.png
```

The contact sheet and review pack are:

```text
artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.svg
artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json
```

## Human Decision Fields

Use the local review note:

```text
artifacts/art-review/v0138/review-notes/v0143-aster-worker-silhouette-scale-review.md
```

Decision options:

- Shortlist S1.
- Shortlist S2.
- Shortlist S3.
- Request one more bounded silhouette revision.
- Reject all.
- Approve silhouette-scale direction as a reference-only lock.

## Candidate Reading

S1, `v0143-silhouette-s1-gameplay-first-readability`, is the gameplay-first candidate. It should be judged for fastest hero-versus-worker recognition and least clutter at RTS distance.

S2, `v0143-silhouette-s2-barrosan-grounded-identity`, is the grounded Barrosan identity candidate. It should be judged for practical highland materials, Worker labor cues, and whether both figures feel native to the same world.

S3, `v0143-silhouette-s3-modern-balanced-scale`, is the modern proportion/readability candidate. It should be judged for disciplined negative-space separation, relative height and mass, and whether future selection rings and HUD markers would have room to work.

## Review Questions

- Which board makes Aster readable as the hero fastest at fixed-camera RTS distance?
- Which board makes Worker readable as practical labor/support fastest at fixed-camera RTS distance?
- Which board has the best relative height, mass, and silhouette separation?
- Which board best supports future selection rings and HUD markers without clutter?
- Does any board lock unsupported race, class, costume, weapon, facial detail, or final production direction too strongly?
- Does any board resemble a protected game, famous character, generic mobile-game style, or protected archetype too closely?

## Runtime Boundary

Do not import, wire, register, package, approve, or load any board for Godot or browser runtime use. Keep `runtimeIntegrationStatus = forbidden`. This review can only approve or reject reference direction.

v0.144 is not started.
