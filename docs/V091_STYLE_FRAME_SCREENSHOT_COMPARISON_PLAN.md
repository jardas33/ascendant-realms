# v0.9.1 Style-Frame Screenshot Comparison Plan

Status: future comparison plan only. No screenshot baselines, image candidates, runtime asset changes, visual harness changes, or pixel-perfect tests were added.

## Purpose

Future Cinderfen style-frame candidates need to be reviewed against the current playable game before any runtime test is considered. This plan maps those future candidates to the existing `npm run visual:qa` capture set and defines a human side-by-side review process.

The comparison process is evidence for review, not automatic art approval.

## Current Baseline Screenshots

Use `visual-qa/latest/index.md` after running `npm run visual:qa`. The current useful baseline set includes:

| Review surface | Current screenshot target |
|---|---|
| Main menu | `main-menu-desktop.png`, `main-menu-tablet.png`, `main-menu-mobile.png` |
| Campaign map | `campaign-map-desktop.png`, `campaign-route-complete-desktop.png` |
| Cinderfen Crossing desktop | `cinderfen-crossing-desktop.png` |
| Cinderfen Crossing tablet | `cinderfen-crossing-tablet.png` |
| Cinderfen Crossing Cinder Shrine | `cinderfen-crossing-shrine-desktop.png` |
| Cinderfen pressure warning | `cinderfen-crossing-pressure-desktop.png`, `cinderfen-watch-pressure-desktop.png` |
| Cinderfen Watch defeat | `results-defeat-desktop.png` after `cinderfen-watch-desktop.png` and `cinderfen-watch-pressure-desktop.png` |
| Results | `results-victory-desktop.png`, `results-defeat-desktop.png` |
| Inventory | `hero-inventory-desktop.png` |
| Asset Gallery | `asset-gallery-desktop.png` |

The screenshots are ignored review artifacts. They should be regenerated for each future candidate review rather than committed as binary baselines.

## Future Comparison Method

1. Run `npm run visual:qa` on the unchanged current game and keep `visual-qa/latest/index.md` open as the baseline index.
2. Open the candidate image and its metadata record from `art-review/cinderfen-style-frames/metadata/`.
3. Create a side-by-side review document that pairs candidate images with the relevant baseline screenshot targets.
4. Compare by human review, not pixel-perfect diffing.
5. Record candidate review stage, source/license outcome, visual fit, readability fit, scale fit, Cinderfen pillar fit, screenshot targets, blockers, and allowed next step.

The side-by-side review document should be Markdown unless a later tool explicitly needs a richer format. It should reference local paths; it should not embed or commit large screenshots unless explicitly approved.

## Evaluation Criteria

Reviewers should evaluate:

- Terrain readability: passable ground, blocked swamp, water, ash mud, reeds, ruins, and fog must remain understandable from the RTS camera.
- Road readability: causeways and intended routes must be visible before reading labels or objective text.
- Shrine landmark visibility: the Cinder Shrine should read as a landmark and capture site without depending only on UI rings.
- Unit contrast: player, enemy, neutral, hero, and building silhouettes must remain legible over the proposed material direction.
- UI compatibility: HUD panels, labels, health bars, selection rings, command buttons, and status warnings must not be visually crowded or camouflaged.
- Minimap compatibility: battlefield material direction must not contradict minimap markers, ownership colors, fog states, or route/capture-site priority.
- Mobile/tablet impact: `cinderfen-crossing-tablet.png`, `tutorial-mobile.png`, and mobile/menu screenshots should remain readable when a future visual change affects density.
- Style/IP safety: the candidate must remain original to Ascendant Realms and must not imitate protected franchises, copied symbols, copyrighted screenshots, or unlicensed web art.

## Runtime Integration Blockers

Runtime integration is blocked if any of these are true:

- Source, creator/tool, date, ownership, or license fields are missing.
- `sourceType` or `licenseStatus` is unknown.
- `protectedIpRisk` is high or unknown for an approval-stage candidate.
- Metadata fails `npm run validate:art-intake`.
- The candidate is only a style-frame reference and not a runtime-sized asset.
- No reviewer has approved the next stage.
- Screenshot comparison finds road, shrine, unit, UI, minimap, or tablet readability regressions.
- Candidate art would require new gameplay, maps, units, factions, engine switching, or broad renderer rewrites.
- The runtime visual asset manifest would need to mark unknown-source art as production-safe.

## Non-Runtime Candidate Approval

A future image may be approved as a non-runtime candidate when:

- The file is in `art-review/cinderfen-style-frames/inbox/`, `reviewed/`, or another explicitly approved non-runtime review path.
- Metadata is complete enough for source/license review.
- `npm run validate:art-intake` passes.
- The candidate is original-IP and not a protected-franchise lookalike.
- Human review records what the candidate is useful for.
- The allowed next step is still non-runtime review, reference study, or a later scoped runtime-test proposal.

Non-runtime candidate approval does not allow runtime import.

## Runtime-Test Approval Later

Runtime-test approval can only be considered in a future scoped goal when:

- Source/license proof is complete and usable.
- Review status is no stronger than `approved-for-runtime-test`.
- The runtime visual asset manifest can represent the asset honestly as a test/candidate, not final production art.
- `npm run validate:art-intake` and `npm run validate:content` pass.
- `npm run visual:qa` passes and the side-by-side review records no blocking readability regressions.
- The proposed change touches at most one tiny runtime target and includes rollback notes.

Production approval is a later, stricter decision and is not granted by this plan.

## Recording Review Decisions

Each review decision should record:

- Candidate ID and title.
- Candidate file path.
- Metadata path.
- Reviewer and review date.
- Review stage before and after review.
- Source/license status.
- Protected-IP risk.
- Visual fit score, readability score, and scale fit score.
- Cinderfen pillar fit.
- Screenshot targets reviewed.
- Replacement targets, if any, as future-only notes.
- Allowed next step.
- Blockers and remaining risks.

Use `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md` and `tools/art-intake/StyleFrameReviewManifestTypes.ts` as the schema reference when creating a future review manifest.

## Current Decision

No candidate style frames exist yet, so no side-by-side comparison is possible in v0.9.1. The comparison plan is ready for future v0.9.2 review work after Emmanuel provides source/license-documented candidates.
