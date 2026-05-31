# v0.85 Private Demo Results UX Spec

## Scope

v0.85 adds a private-demo Results posture for the `Finish Demo & View Results` path. Normal mission victory and defeat Results remain unchanged unless they use the existing shared details rendering inside a private collapsed section.

## Heading

Private demo Results use:

`PRIVATE DEMO COMPLETE`

Subtitle:

`Lume Network test - rewards and campaign progress were not saved`

The runtime may render the dash as an em dash, but the source stays ASCII-safe.

## Above-The-Fold Summary

The first viewport prioritizes:

- `LUME NETWORK SUMMARY`
- Linked Ward awakened: Yes/No.
- Links awakened count.
- Links severed count.
- Protected route.
- Nearby allies: 8% less incoming damage.
- Rewards: Disabled.
- Campaign progress: Not saved.

## Actions

The private demo primary actions appear before full telemetry:

- `Return to Campaign Map`
- `Replay Lume Demo`
- `Show Full Battle Details`

`Show Full Battle Details` uses progressive disclosure and is collapsed by default.

## Collapsed Details

Full battle telemetry, Hero XP, Retinue, veterans, battle rewards, current hero stats, Lume telemetry, and normal Results details remain available under the details disclosure. No normal Results data is deleted.

## Save Safety

The private Results mode does not save campaign progress, rewards, hero XP, Retinue, reputation, relics, or save-version changes.

## Deferrals

- Broader normal Results progressive disclosure.
- Full Results information architecture redesign.
- Broad campaign shell cleanup.
