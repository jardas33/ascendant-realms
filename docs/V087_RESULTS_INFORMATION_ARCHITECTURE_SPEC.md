# v0.87 Results Information Architecture Spec

## Scope

v0.87 applies progressive disclosure to ordinary Results screens while preserving the v0.85 private-demo Results rescue. It does not alter rewards, XP, save writes, campaign replay rules, Tutorial protection, Retinue rules, relic choices, or item equipment behavior.

## Above The Fold

Ordinary victory and defeat Results should immediately show:

- Victory or defeat.
- Mission name.
- Battle time.
- Primary objective result.
- Key rewards or no-reward status.
- Hero XP summary.
- Important veteran summary.
- One obvious return action.
- Replay action when appropriate.

Actionable reward and progression controls must remain visible without opening telemetry:

- Relic choice and equip-now actions.
- Retinue recruitment actions.
- Battle reward equipment buttons.
- Defeat retry/prep actions.

## Full Battle Details

Extended information moves behind `Show Full Battle Details`:

- Detailed battle telemetry.
- Detailed unit/resource totals.
- Expanded Retinue battle status.
- Full modifier, doctrine, elite, Lume, event, and finale information.
- Current hero stat strip.

Private-demo Results already use this structure and must remain unchanged.

## Replay And Tutorial Safety

Replay Results keep existing reduced-reward and already-claimed copy. Tutorial Results keep no-save/no-reward copy and do not surface relic or campaign rewards. The disclosure change is HTML presentation only.

## Tests And QA

Add or extend coverage for:

- Normal victory Results above-the-fold summary.
- Normal defeat Results above-the-fold summary.
- Replay Results action/copy.
- Private-demo Results disclosure preserved.
- Reward and save regressions avoided.
- Visual QA screenshots for campaign and Results at desktop/laptop viewports.

## Deferrals

- No reward logic changes.
- No new statistics.
- No exported battle report system.
- No new art or animation.
