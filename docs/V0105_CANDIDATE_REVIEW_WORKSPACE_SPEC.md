# v0.105 Candidate Review Workspace Spec

Status: ignored local workspace tooling only. Candidate files are not committed and are not runtime assets.

## Workspace Roots

v0.105 uses ignored artifact folders:

- `artifacts/art-review/candidates/`
- `artifacts/art-review/contact-sheets/`
- `artifacts/art-review/reports/`

The folders are created by tooling as needed. Raw candidate images, generated contact sheets, and generated reports stay ignored by git.

## Initialize A Workspace

```bash
npm run art:review:init -- --asset <assetId>
```

The command validates the asset ID against `src/game/art/visual-asset-registry.json`, then creates:

- `artifacts/art-review/candidates/<assetId>/candidate-metadata.json`
- `artifacts/art-review/candidates/<assetId>/prompt-reference.json`
- `artifacts/art-review/candidates/<assetId>/reviewer-checklist.md`
- `artifacts/art-review/candidates/<assetId>/images/`
- matching contact-sheet and report directories.

Existing template files are preserved on rerun.

## Candidate Images

Candidate images are placed manually under:

```text
artifacts/art-review/candidates/<assetId>/images/
```

Supported contact-sheet formats are PNG, JPG/JPEG, and WebP. The tooling does not generate images, call a network service, import art into runtime folders, or approve candidates automatically.

## Contact Sheet

```bash
npm run art:review:contact-sheet -- --asset <assetId>
```

The command writes:

- `artifacts/art-review/contact-sheets/<assetId>/contact-sheet.svg`
- `artifacts/art-review/contact-sheets/<assetId>/contact-sheet.json`

Each candidate tile includes filename, image dimensions when readable, asset ID, prompt version, and review state. If no candidate images exist, the command still writes a safe empty contact sheet.

## Report

```bash
npm run art:review:report -- --asset <assetId>
```

The command writes:

- `artifacts/art-review/reports/<assetId>/art-review-report.md`
- `artifacts/art-review/reports/<assetId>/art-review-report.json`

Reports are deterministic summaries of registry state, metadata state, candidate files, contact-sheet posture, source/tool/model, license terms, protected-IP assessment, human review status, and runtime posture.

## Validate

```bash
npm run art:review:validate
```

The command validates the committed registry plus any ignored candidate metadata currently present. It rejects unsafe progressions such as unclear license terms, missing prompt versions, missing protected-IP assessments, style-approved runtime posture, and runtime-integrated candidates without future integration proof.
