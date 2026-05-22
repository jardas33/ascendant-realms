# v0.16.8 Public Repo Safety Audit

Date: 2026-05-22

## Scope

Audit the now-public repository for accidentally exposed secrets, private tester data, unsafe binary artifacts, package output, and obvious protected-IP risk. This audit did not delete files, rewrite history, change runtime assets, or approve any asset for production use.

## Commands And Evidence

Baseline public-safety scans:

```text
git ls-files | rg -i "(^|/)(\\.env|\\.env\\.|id_rsa|id_dsa)|secret|token|credential|service.*account|private.*key|\\.pem$|\\.p12$|\\.key$|playwright-report|test-results|artifacts|dist|\\.zip$|\\.7z$|\\.rar$"
git ls-files | rg -i "\\.(png|jpg|jpeg|webp|gif|mp3|wav|ogg|mp4|mov|zip|7z|rar|psd|ai|blend|glb|gltf|aseprite)$"
git grep -I -l -i -E "api[_-]?key|token|secret|password|private[_-]?key|client[_-]?secret|service[_-]?account|bearer|-----BEGIN|AKIA|AIza|sk-[A-Za-z0-9]|ghp_|github_pat_|xox[baprs]-" -- . ":!package-lock.json"
git grep -I -n -E "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" -- . ":!package-lock.json"
git grep -I -l -i -E "warcraft|warlords battlecry|blizzard|azeroth|stormwind|arthas|orcish horde|human alliance|night elf|undead scourge" -- .
Get-ChildItem -Path . -Force -Recurse -File -Include ".env",".env.*","*.pem","*.p12","*.key" excluding node_modules/dist/artifacts/.git
```

Supporting reviews:

- `.gitignore`
- `public/assets/manual/ASSET_PROMPT_BOOK.md`
- `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`
- `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`
- `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`
- `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`

## Findings

### Secrets And Credentials

No tracked `.env`, private key, service-account, credential, package archive, `dist`, `artifacts/playtest`, Playwright report, or test-result path was found.

No email addresses were found in tracked text.

The secret-pattern grep matches are documentation/test references, not live secrets:

- docs that say the workflow/package should not include secrets or tokens
- old CI observation docs mentioning expired connector tokens without exposing token values
- package-validation test fixtures using dummy secret-like text to verify rejection
- validation code that detects secret-like files in playtest packages

No secret values were identified, and no secret rotation is required from this audit.

### Private Tester Data

The repo includes Emmanuel's first name, session IDs, and summarized manual retest findings. No email address, contact details, raw private forms, raw screenshots/videos, or unapproved recordings were found.

The package and feedback docs already instruct the project not to commit raw private feedback folders or unapproved recordings.

### Generated/Local Artifacts

`.gitignore` excludes:

- `node_modules/`
- `dist/`
- Playwright reports and test results
- `tmp-test-logs/`
- `bundle-analysis/`
- `/artifacts/playtest/`
- `/visual-qa/`
- local preview-server PID files
- non-runtime art-review inbox/reviewed/rejected binaries by default

No ignored package output was tracked.

### Binary Assets

Tracked image assets exist under `public/assets/manual/`:

- tracked manual asset files: 64
- largest tracked assets are around 1.7 to 2.3 MB each
- total tracked repository size estimate from local file scan: about 105 MB

These appear intentional for the current prototype, not accidental local package output.

Important safety note: previous asset docs already classify current file-backed image assets conservatively. `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md` records that runtime-visible image assets have unknown license/source proof, are review-needed, and are not approved for production. `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md` also states that no current file-backed image asset is marked approved-for-production.

### Protected-IP Search

Searches for obvious Warcraft, Warlords Battlecry, Blizzard, Azeroth, Stormwind, Arthas, and related protected terms found only project guardrails, prompt negatives, and art-direction warnings. No copied protected unit names, faction names, places, lore, UI, music, or asset paths were identified in this audit.

## Action Required

No immediate secret-removal or secret-rotation action is required.

Public-repo asset provenance remains a real project watchpoint:

- If the public repository is intended to remain public long-term, Emmanuel should confirm whether the tracked `public/assets/manual` images are acceptable to keep public as prototype material.
- Before commercial use, store pages, broader public marketing, or production approval, each runtime-visible image asset still needs source/license proof or replacement.
- Do not mark current file-backed image assets production-approved until their source/license metadata is complete.

## Cleanup Decision

No files were removed or added to `.gitignore` in this pass. The existing ignore rules already cover generated packages, reports, and raw art-review candidate folders. The remaining tracked binary assets are intentional prototype assets, not package debris.
