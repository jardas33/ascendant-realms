# v0.100 Visual QA Report

## Scope

Visual QA adds a private hub gallery pass without changing production posture or normal game progression.

## Added Captures

- `v0100-playtest-hub-1920.png`
- `v0100-playtest-hub-1600.png`
- `v0100-playtest-hub-1366.png`
- `v0100-hub-campaign-shell.png`
- `v0100-hub-first-session.png`
- `v0100-hub-battle-shell.png`
- `v0100-hub-lume-flow.png`
- `v0100-hub-meta-flow.png`
- `v0100-hub-results-flow.png`

## Acceptance

- Hub visible in private posture.
- Gallery groups visible at desktop and laptop review sizes.
- Campaign Shell, First Session, Battle Shell, Lume, Meta, and Results fixture families all have review screenshots.
- Private hub previews show return controls.
- Lume first-link sample renders active link progress.
- Results fixture uses ordinary Results shell with private hub return.

## Notes

The visual QA count increases from 136 to 145 screenshots.

Final full visual QA outcome:

```text
npm run visual:qa - PASS, 16 tests / 145 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 145 screenshots / 7 contact sheets.
```

The generated review pack is written to `artifacts/visual-review/latest/`.
