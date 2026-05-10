# v0.9.2 Future Style-Frame Review Goal Brief

Status: future goal brief only. Do not implement this goal during v0.9.1.

## Future Objective

When Emmanuel provides actual Cinderfen style-frame candidate images and matching source/license metadata, run a controlled non-runtime review. The goal is to decide which candidates are unsafe, reference-only, candidate-worthy, or potentially suitable for one later runtime-test proposal.

This future goal still must not replace runtime art unless a separate explicit runtime-test scope is created.

## Required Starting Inputs

Before starting v0.9.2, the repository should contain or be given:

- Candidate image files placed under `art-review/cinderfen-style-frames/inbox/`.
- Candidate-specific metadata files under `art-review/cinderfen-style-frames/metadata/`.
- Source, creator/tool, date, ownership, license, usage permission, prompt, and post-processing notes for each candidate.
- Emmanuel's intent for each candidate: reference only, prototype review, or possible future runtime-test candidate.

If these inputs are missing, stop before cataloguing or approving candidates.

## Future Tasks

1. Inspect candidate files in the non-runtime review folder.
2. Inspect candidate metadata and validate it with `npm run validate:art-intake`.
3. Reject unsafe candidates or keep them reference-only when source/license or originality is uncertain.
4. Catalogue safe candidates in a non-runtime review manifest only.
5. Mark candidates as `reference-only`, `candidate`, or another conservative non-production stage.
6. Update the review manifest with source status, license status, protected-IP risk, visual/readability/scale scores, Cinderfen pillar fit, screenshot targets, and allowed next step.
7. Run `npm run visual:qa`.
8. Create a side-by-side review document comparing candidate images against the current Cinderfen screenshot targets.
9. Choose at most one future runtime-test candidate, and only if metadata and review evidence are strong.
10. Leave all runtime files untouched unless a later explicit runtime-test goal is approved.

## Review Rules

- Unknown source means not production-safe.
- Unknown or blocked license means not production-safe.
- High protected-IP risk means not approved.
- Style frames are reference/candidate materials, not runtime art.
- Runtime-test approval is not production approval.
- Production approval is out of scope.
- No candidate may move from inbox to runtime during this future goal.

## Required Verification

At minimum, run:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run visual:qa
git diff --check
```

If any candidate is proposed for a later runtime-test target, also run the broader release lanes in the next scoped runtime-test goal before wiring anything.

## Stopping Conditions

Stop and report if any candidate has:

- Missing source metadata.
- Missing license or ownership metadata.
- Unknown source.
- Unknown, blocked, incompatible, or non-commercial license where the intended use needs more rights.
- Protected-IP risk marked high or unclear.
- A lookalike relationship to protected games, factions, units, UI, maps, terrain, buildings, symbols, or art styles.
- Too-large binaries for the repo without explicit approval.
- Wrong format or corrupted files.
- No stable file path under the non-runtime review area.
- Metadata that fails `npm run validate:art-intake`.
- Style direction that does not match the Cinderfen visual pillars.
- Terrain, road, shrine, unit, UI, minimap, mobile/tablet, or screenshot readability failure.
- A request to move, rename, delete, import, replace, or wire runtime art without explicit runtime-test scope.

## Output Documents For v0.9.2

The future goal should produce:

- A candidate file inventory.
- A metadata validation summary.
- A review manifest, if candidates are eligible.
- A side-by-side screenshot comparison document.
- A rejection list for unsafe or unsuitable candidates.
- A conservative recommendation for either no runtime work or one later runtime-test candidate.

## Allowed Final States

Allowed future final states:

- No candidates pass; everything remains rejected or reference-only.
- One or more candidates are catalogued as non-runtime candidates.
- At most one candidate is recommended for a later runtime-test goal, with no runtime code or asset changes yet.

Forbidden future final states:

- Runtime art replaced without explicit scope.
- Unknown-source assets marked production-safe.
- Candidate binaries committed without explicit approval.
- Broad visual overhaul started from a review task.
- New maps, units, factions, gameplay, campaign progression, rewards, engine changes, or desktop packaging added.
