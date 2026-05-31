# v0.85 Visual QA Report

Status: passed.

## Scope

v0.85 visual QA covers contextual Lume overlay readability and the private-demo Results rescue.

## Planned Captures

- Private demo before first site capture.
- Relevant faint guide only.
- First active link during activation pulse.
- First active link after stable fade.
- Endpoint selected with highlighted line.
- `Links: Auto`.
- `Links: Always`.
- `Links: Hidden`.
- Contested state.
- Severed state.
- Restored state.
- Optional North Aether link revealed only after relevance.
- Private Demo Complete summary above the fold.
- Private Demo Complete expanded details.
- Normal mission Victory screen unchanged.
- No Lume controls in Tutorial.
- No Lume controls in unrelated mission.

## Result

`npm run visual:qa` passed:

- 6 Playwright visual QA tests.
- 29 screenshots.
- 0 browser console errors.
- 0 screenshot retries.

New v0.85 captures:

- `visual-qa/latest/v085-private-lume-hidden-links-1920.png`
- `visual-qa/latest/v085-private-lume-always-links-1920.png`
- `visual-qa/latest/v085-private-lume-results-1366.png`

Manual inspection notes:

- Hidden mode removes stable Lume link clutter while preserving the HUD tracker and selected-site clarity.
- Always mode keeps eligible links visible but faint enough not to dominate the battlefield.
- Private demo Results open with `PRIVATE DEMO COMPLETE`, show Lume/no-save state above the fold, and keep full telemetry collapsed behind `Show Full Battle Details`.
