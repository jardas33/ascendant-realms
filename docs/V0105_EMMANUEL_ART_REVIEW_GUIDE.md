# v0.105 Emmanuel Art Review Guide

Status: reviewer guide for future manually placed candidates. No generation or runtime import happened in v0.105.

## Review Order

1. Read `docs/V0105_FIRST_ART_GENERATION_PACKET.md`.
2. Confirm the asset ID is one of the approved first packet IDs.
3. Confirm the candidate workspace has complete source/tool/model/license metadata.
4. Open the generated contact sheet.
5. Review thumbnail readability before detail polish.
6. Decide one state: `style-approved`, `revision-requested`, or `rejected`.

## What To Approve

Approve as `style-approved` only when:

- the candidate matches the correct asset ID and prompt;
- the silhouette reads at RTS thumbnail scale;
- the Barrosan/Salto/HUD material language is clear;
- source, tool, model, generated-by, license terms, and prompt version are recorded;
- protected-IP assessment is low or medium risk with written notes;
- the candidate remains `reference-only:not-runtime`.

## What To Reject

Reject when:

- the image resembles a protected game, faction, UI, logo, map, unit, or art expression;
- the source, model, or license is unclear;
- it hides gameplay readability behind mood or clutter;
- it uses mobile UI shapes, gacha-card composition, or shop-like framing;
- it implies unapproved systems, maps, races, engine choices, or final art replacement;
- the candidate cannot be trusted as original project visual direction.

## Decisions

- `style-approved`: reference direction is useful, but no runtime import is approved.
- `revision-requested`: prompt or candidate should be adjusted.
- `rejected`: candidate is not usable; record a rejection reason.

Do not use `runtime-candidate-approved` or `runtime-integrated` unless a future runtime integration milestone explicitly opens that gate.
