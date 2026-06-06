# v0.143 Aster / Worker Silhouette-Scale Generation Report

Date: 2026-06-06

Status: exactly three reference-only Aster / Worker silhouette-scale boards generated for human review. Runtime integration remains forbidden.

## Start State

- Repository branch: `main`
- Expected start commit: `cf93376a36bef8b0678a8d1125e7a893270d272e`
- Local synchronization before editing: `HEAD == origin/main`
- v0.142 ratified `v0141-env-r1-gameplay-first-barrosan` as the primary reference-only Salto environment style lock.
- v0.142 retained `v0141-env-r2-barrosan-signature` as the approved Barrosan material and atmosphere companion.
- v0.142 limited `v0141-env-r3-modern-balanced-ashen-contrast` to lane hierarchy and Ashen readability only.
- All six v0.140/v0.141 environment candidates remained reference-only and runtime-forbidden before generation.
- No runtime import was found for existing reference candidates.
- Built-in Codex image generation was available and produced the three v0.143 boards.

## Established Repo Facts Preserved

Aster facts preserved:

- Aster is the default player hero name.
- Aster is the central persistent hero.
- The hero role is Commander / Champion.
- The hero anchors fights, spends skills, and carries relic build identity.

Worker facts preserved:

- Worker is the `free_marches` Builder unit.
- Worker is a camp hand and utility/site-support unit.
- Workers build, repair, finish construction, and boost captured resource sites.
- Command Hall trains Workers only.
- Workers can build Barracks, Mystic Lodge, and Watchtower.
- Workers are useful in combat only as a last resort.

No unsupported race, class, final costume, final armor, final weapon, facial-detail, animation, or final production-asset detail is locked by this checkpoint.

## Generated Boards

### S1 Gameplay-First Readability

- Candidate ID: `v0143-silhouette-s1-gameplay-first-readability`
- Path: `artifacts/art-review/v0138/candidates/v0143-silhouette-s1-gameplay-first-readability.png`
- SHA-256: `0c08f13ddd0fe881b6d1cb01e122bab1a4582c444745f982f747ab4f8b251c3e`
- Dimensions: `1536 x 1024`
- Notes: strongest direct hero-versus-worker read. Human review should check whether Aster's sword-like silhouette is too specific for an exploratory reference board.

### S2 Barrosan Grounded Identity

- Candidate ID: `v0143-silhouette-s2-barrosan-grounded-identity`
- Path: `artifacts/art-review/v0138/candidates/v0143-silhouette-s2-barrosan-grounded-identity.png`
- SHA-256: `a29ca5070af87dde59dc6681c417627bf097e40ebf60761d5a9017d0cb991743`
- Dimensions: `1536 x 1024`
- Notes: strongest grounded Barrosan material identity and practical Worker labor cue set.

### S3 Modern Balanced Scale

- Candidate ID: `v0143-silhouette-s3-modern-balanced-scale`
- Path: `artifacts/art-review/v0138/candidates/v0143-silhouette-s3-modern-balanced-scale.png`
- SHA-256: `7aa576566677bbc6db3198b89fe0c7af2bdba2b6d4a70b1b105fdf8d165644a3`
- Dimensions: `1571 x 1001`
- Notes: cleanest presentation, negative-space separation, and proportion balance. Decorative border and selection-ring-like inset marks are review presentation only.

## Metadata Handling

Matching ignored metadata files were created under:

```text
artifacts/art-review/v0138/metadata/
```

The existing schema has no combined Aster/Worker board category and uses `additionalProperties: false`. No schema rewrite was performed. The supported `V0138_03_ASTER_HERO_SILHOUETTE_SHEET` brief category was used because Aster is the lead silhouette category, while Worker is recorded honestly as the required scale companion in `purpose`, `source.notes`, `visualNotes`, and tracked review docs.

All three v0.143 metadata records keep:

```text
humanStatus = pending-review
runtimeIntegrationStatus = forbidden
protectedIpReview.status = pending
licencePosture.runtimeUse = forbidden
```

## Review Outputs

- Updated contact sheet: `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.svg`
- Updated contact-sheet manifest: `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.json`
- Updated review pack: `artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json`
- Local human review note: `artifacts/art-review/v0138/review-notes/v0143-aster-worker-silhouette-scale-review.md`

## Boundary

These boards are exploratory reference boards only. They are not final character designs, runtime assets, protected-IP clearance, art-slot approvals, Godot imports, browser imports, packaged assets, or a v0.144 start.
