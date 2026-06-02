# v0.88 Art Intake And Review Gate

Status: process gate only. No art is generated, imported, or runtime-approved by v0.88.

## Purpose

This gate prevents incoherent AI-art flooding and protects the browser prototype from unreviewed assets. It extends the existing asset-pipeline and art-intake discipline into a stricter future style-frame workflow.

## Intake Stages

1. Brief approved.
   - Relevant v0.88 brief is reviewed by Emmanuel.
   - Scope is limited to one planned asset ID or a tightly grouped sheet.

2. Manifest entry exists.
   - `assetId`, category, faction, runtime slot, concept stage, source, license, prompt version, and review status are recorded before generation.
   - Runtime slot must remain `reference-only:not-runtime` or equivalent until integration approval.

3. Prompt version recorded.
   - Prompt uses `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md`.
   - Negative prompt guidance and camera/aspect rules are included.

4. Candidate generated outside runtime.
   - Candidate is stored in a future review area, not imported into `public/assets/final` or runtime slots.
   - Source/tool/model, generated-by, date, prompt version, and license terms are recorded.

5. Human style review.
   - Emmanuel or a designated reviewer checks silhouette, faction identity, desktop readability, original-IP separation, and consistency with the brief.

6. Protected-IP and source/license review.
   - Candidate is rejected if it resembles protected game/film/art expressions too closely.
   - Unknown or unclear license/source cannot become runtime art.

7. Technical integration review.
   - Only after approval, a separate runtime milestone may process, crop, scale, and validate the asset.
   - Runtime integration must pass `npm run validate:art-intake`, manifest validation, build, and visual QA.

## Required Metadata

Each future candidate needs:

- Asset ID.
- Category.
- Faction.
- Runtime slot.
- Concept stage.
- Review status.
- Source/tool/model.
- License terms.
- Generated-by.
- Prompt version.
- Original prompt text or stored prompt reference.
- Negative prompt version.
- Visual-consistency notes.
- Protected-IP risk assessment.
- Human reviewer.
- Approval status.
- Integration readiness.
- Replacement history.

## Approval Status Values

- `not-approved`: default for all v0.88 planned entries.
- `style-approved`: approved as reference only.
- `revision-requested`: needs another prompt or paintover.
- `rejected`: not usable.
- `runtime-candidate-approved`: may enter a future runtime integration milestone.
- `runtime-integrated`: only after separate implementation and validation.

## Rejection Triggers

- Protected franchise resemblance.
- Source/license missing or unclear.
- Anatomy, hands, tools, or construction are incoherent.
- Silhouette unreadable at RTS scale.
- Faction identity conflicts with approved brief.
- Mobile-game UI look, gacha card composition, or shop-like framing.
- Excessive generated text, logos, watermarks, or fake glyphs.
- Too much visual noise for battlefield readability.
- Any image that implies unapproved gameplay systems, maps, factions, or engine decisions.

## Placeholder-Safe Runtime Rule

Until a future milestone explicitly approves integration:

- Current placeholder/procedural rendering remains valid.
- Existing runtime asset slots remain stable.
- Existing IDs remain unchanged.
- Existing save data remains untouched.
- Missing final art is not a blocker.

## Validation Expectations

For v0.88:

- `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json` must parse as valid JSON.
- `npm run validate:art-intake` must pass with no generated candidates.

For v0.105 registry/workspace tooling:

- `src/game/art/visual-asset-registry.json` preserves every v0.88 asset ID and keeps them `not-created`, `not-approved`, and `not-runtime`.
- `npm run art:review:init -- --asset <assetId>` creates ignored candidate-review templates only under `artifacts/art-review/`.
- `npm run art:review:validate` validates registry shape, candidate metadata, prompt references, source/tool/model, license terms, protected-IP assessment, human-review posture, runtime-slot posture, and integration readiness.
- `npm run art:review:contact-sheet -- --asset <assetId>` and `npm run art:review:report -- --asset <assetId>` summarize manually placed candidates without network calls, image generation, runtime imports, or automatic approval.

For future art-intake milestones:

- Candidate metadata must be validated before runtime discussion.
- Package verification must include any new review docs if metadata changes.
- Visual QA must show no readability regressions after integration.

## Anti-Flooding Rule

Generate the minimum set needed for review:

1. One Salto battlefield/environment frame.
2. One Barrosan Worker concept sheet.
3. One Barrosan unit or hero sheet.
4. One HUD frame.

Do not generate entire rosters, complete UI kits, or replacement battle sprites until those first candidates pass human review.
