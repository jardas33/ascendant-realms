# v0.8.2 Asset Source And License Review Plan

Date: 2026-05-10  
Scope: review policy for current visual asset source/license safety before any future visual replacement sprint. This plan does not add, generate, download, replace, or approve new art.

## Purpose

Ascendant Realms now has an initial visual asset manifest, but most current assets still have conservative `unknown` or review-needed metadata. The purpose of this review is to prevent unsafe asset use before future visual upgrades and to make sure placeholder prototype art is not mistaken for production-ready material.

The review should answer:

- Where did this asset come from?
- Who created it?
- What license or ownership evidence exists?
- Can it ship in the browser prototype?
- Can it ship commercially in a future desktop-quality game?
- Does it need replacement before a visual sprint?

Unknown source is acceptable for a prototype only when it is explicitly marked as unknown, review-needed, and not production-safe. Unknown source is not production-safe.

## Asset Classes

### Runtime Assets

Runtime assets are loaded or displayed by the current app. They include battle sprites, portraits, ability icons, resource/capture-site icons, faction emblems, UI backgrounds, UI frames, and procedural terrain metadata.

Policy:

- Runtime assets must have manifest entries.
- Runtime assets with unknown source or license must set `needsReview: true`.
- Runtime assets must not use `licenseStatus: reference-only` or `licenseStatus: do-not-ship`.
- Runtime assets are not production-safe unless source/license evidence supports that claim.

### Manual And Reference Assets

Manual/reference assets are source files, prompt notes, concept images, or pipeline references retained for review or processing. Some sit under `public/assets/manual/`; some are docs or procedural records.

Policy:

- Manual/reference assets can exist without being production-ready.
- They should not be treated as final game art.
- They should not become runtime dependencies unless intentionally reviewed and reclassified.
- Reference-only files must not ship as runtime art.

### Generated-Looking Assets

Generated-looking assets are any current or future files whose appearance, naming, or pipeline history suggests AI or tool-assisted generation, even if the generation method is not yet proven.

Policy:

- Use `sourceType: generated` only when generation is known.
- Use `sourceType: unknown` when generation is suspected but unproven.
- Use `licenseStatus: generated-review-needed` only when generation evidence exists and the asset still requires legal/style review.
- Do not mark generated assets as final without prompt, tool, model, license, and usage evidence.

### Purchased Or Licensed Assets

Purchased/licensed assets require stronger records than local files alone.

Required evidence:

- Marketplace or creator source.
- License name or license text.
- Purchase/download proof when applicable.
- Commercial-use allowance.
- Modification and redistribution rules.
- Attribution requirements.

No current v0.8.2 work should invent or assume purchased/licensed status.

### Unknown-Source Assets

Unknown-source assets are files where the origin, author, or license is not proven.

Policy:

- Unknown-source assets may remain in the prototype only when flagged clearly.
- They must not be marked production-safe.
- They should have `needsReview: true`.
- They should be prioritized for replacement or source confirmation if they are runtime-visible.

### Do-Not-Ship And Reference-Only Assets

Do-not-ship or reference-only assets may exist for docs, internal comparison, or source review, but must not be used as runtime art.

Policy:

- `licenseStatus: reference-only` cannot pair with `usage: runtime`.
- `licenseStatus: do-not-ship` cannot pair with `usage: runtime`.
- These assets should have `allowedInProduction: false`.
- Their notes should explain why they are retained.

## Review Statuses

The manifest currently uses `currentStatus`, `sourceType`, `licenseStatus`, `needsReview`, and `allowedInProduction`. v0.8.2 docs should use these human review statuses consistently:

- `approved-for-prototype`: acceptable for current prototype use, still not necessarily production-safe.
- `approved-for-production`: source/license/style evidence is strong enough for future shipping.
- `needs-source-proof`: source, author, or license evidence is missing.
- `generated-review-needed`: generated or tool-assisted asset needs prompt/tool/license review.
- `reference-only`: may guide design, but should not ship as runtime art.
- `do-not-ship`: must not be runtime or production art.
- `deprecated`: retained for history or migration, not active runtime use.

Recommended mapping:

- `approved-for-prototype`: `usage: runtime`, `allowedInProduction: false`, explicit notes.
- `approved-for-production`: `allowedInProduction: true`, safe `licenseStatus`, non-unknown `sourceType`.
- `needs-source-proof`: `sourceType: unknown` or `licenseStatus: unknown`, `needsReview: true`.
- `generated-review-needed`: `sourceType: generated`, `licenseStatus: generated-review-needed`, `needsReview: true`.
- `reference-only`: `currentStatus: reference`, `licenseStatus: reference-only` or review notes, non-runtime usage.
- `do-not-ship`: `licenseStatus: do-not-ship`, non-runtime usage.
- `deprecated`: `currentStatus: deprecated`, non-runtime usage unless a future migration exception is explicitly documented.

## Required Evidence

Each reviewed asset should eventually have evidence for:

- File origin: how the file entered the repo.
- Author/source: project team, contractor, tool, marketplace, public-domain source, or unknown.
- License: owned, licensed, generated-review-needed, unknown, reference-only, or do-not-ship.
- Generation method if generated: tool, prompt/spec, date, source references, and usage terms.
- Modification history: manual edits, resizing, cleanup, sprite extraction, or pipeline processing.
- Allowed usage: prototype, internal reference, commercial shipping, derivative work, redistribution, or no shipping.
- Commercial future: whether it can ship in the future desktop-quality version.

Evidence should be documented in manifest notes, future source-review fields, or dedicated audit docs. Do not invent missing evidence.

## Review Policy

- Unknown source is not production-safe.
- Reference-only assets cannot be runtime assets.
- Do-not-ship assets cannot be runtime assets.
- Final status requires source/license confidence.
- `allowedInProduction: true` requires safe source and license status.
- Visual replacement should prioritize runtime assets with unknown source/license, critical replacement priority, low style consistency, or low silhouette readability.
- Current browser-prototype use is not the same as future production approval.
- No asset should be upgraded from unknown to safe because it "looks okay."
- Source/license review is a blocker for any future binary replacement sprint.

## Codex Policy

Codex may:

- Classify assets honestly.
- Document source/license gaps.
- Add or refine metadata.
- Add validation rules that preserve honest unknown states.
- Add source/license review docs and checklists.
- Add screenshot QA coverage for visual review.

Codex may not:

- Invent licenses or ownership evidence.
- Download replacement images.
- Import web images.
- Use copyrighted references as assets.
- Treat generated assets as production-safe without explicit generation and license evidence.
- Mark unknown-source assets as production-ready.
- Add large binary assets without explicit approval.
- Use asset review as a reason to switch engines, rewrite the renderer, or perform a graphics overhaul.

## v0.8.2 Review Order

1. Audit the current manifest counts and risk clusters.
2. Refine metadata conservatively.
3. Harden validation around source/license safety.
4. Expand screenshot QA so review covers more visible surfaces.
5. Create a visual risk register for future work.
6. Recommend a controlled v0.9 visual sprint without implementing new art.

## Non-Goals

- No new art.
- No generated art.
- No downloaded assets.
- No runtime visual replacement.
- No gameplay changes.
- No save-version changes.
- No campaign progression changes.
- No desktop packaging or engine switch.
- No pixel-perfect screenshot testing.
