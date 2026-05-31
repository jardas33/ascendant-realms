# v0.92 Contact Sheet Index

Status: generated review artifact index. Counts reflect the current `artifacts/visual-review/latest/` output after running `npm run visual:review-pack`.

## Artifact Path

```text
D:\Code for projects\WB game like\ascendant-realms\artifacts\visual-review\latest
```

Open:

```text
D:\Code for projects\WB game like\ascendant-realms\artifacts\visual-review\latest\index.html
```

No local server is required.

## Current Counts

- Screenshots copied into review pack: 64.
- Static contact sheets: 7.
- Required screen groups: 12.
- Target desktop viewports: 1920x1080, 1600x900, 1366x768.

## Viewport Contact Sheets

| Sheet | Path | Screenshot count |
| --- | --- | ---: |
| 1920x1080 | `artifacts/visual-review/latest/contact-sheets/viewport-1920x1080.html` | 16 |
| 1600x900 | `artifacts/visual-review/latest/contact-sheets/viewport-1600x900.html` | 13 |
| 1366x768 | `artifacts/visual-review/latest/contact-sheets/viewport-1366x768.html` | 16 |

## Focused Contact Sheets

| Sheet | Path | Screenshot count |
| --- | --- | ---: |
| Campaign shell | `artifacts/visual-review/latest/contact-sheets/campaign-shell.html` | 21 |
| Battle shell | `artifacts/visual-review/latest/contact-sheets/battle-shell.html` | 11 |
| Lume flow | `artifacts/visual-review/latest/contact-sheets/lume-flow.html` | 14 |
| Results flow | `artifacts/visual-review/latest/contact-sheets/results-flow.html` | 10 |

## Review Use

1. Open `index.html`.
2. Skim the summary and screen groups.
3. Use viewport sheets for desktop acceptance review.
4. Use focused sheets for campaign, battle, Lume, and Results passes.
5. Record subjective findings in the v0.92 Emmanuel packet or a tester note.

## Regeneration

```text
npm run visual:qa
npm run visual:review-pack
```

Regeneration replaces `artifacts/visual-review/latest/`. It does not modify `visual-qa/latest/` source screenshots.
