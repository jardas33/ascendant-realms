# v0.99 Visual QA Report

Status: passed.

## Added Coverage

v0.99 adds focused visual-QA captures for Act 1 mission presentation and Results summary:

- Salto Outskirts selected at 1920x1080.
- Old Stone Road selected at 1600x900.
- Marcher Camp selected at 1600x900.
- Refugee Caravan selected at 1600x900.
- Aether Well Ruins selected at 1600x900.
- Bandit Hillfort selected at 1600x900.
- Chapel of the Barrosan Marches selected at 1366x768.
- Ashen Outpost selected at 1600x900.
- Ashen Outpost More Details expanded at 1600x900.
- Ashen Outpost Results summary at 1600x900.

## Acceptance Notes

- Map remains immediately visible.
- Mission panel default read remains compact.
- Locked and available nodes preserve preview and action visibility.
- More Details retains longer rival/modifier/replay explanation.
- Results summary keeps primary action and next-step information above the detailed telemetry layer.
- No visual QA coverage changes imply gameplay, reward, save, or progression changes.

## Final Evidence

```text
npm run visual:qa - PASS, 15 tests / 136 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 136 screenshots / 7 contact sheets.
```

Non-pass evidence: the first `visual:qa` attempt reached the 30-minute tool timeout without pass/fail output after writing partial generated screenshots. The generated `visual-qa/latest` folder was cleaned, then the full harness reran with a longer timeout and passed.
