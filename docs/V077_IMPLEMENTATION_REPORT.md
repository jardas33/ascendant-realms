# v0.77 Implementation Report - Milestone Reward and Debrief

Date: 2026-05-30

## Summary

Results now close Ashen Outpost as an Act 1 milestone by connecting finale phases, Captain Malrec, battlefield events, tactical plan support, campaign rewards, relic choice, skill reminders, and replay safety.

## Runtime Changes

- Added Act 1 finale battle-stat fields for phase ids, completed phases, plan-supported phases, commander release timing, and finale completion.
- Added an Act 1 Finale Results block with phase completion, commander release/defeat, plan support, and next-step copy.
- Campaign Results guidance now says Act 1 is complete after Ashen Outpost first clear.
- Existing rival rewards, relic choice, Retinue summary, optional objectives, and campaign first-clear/replay handling remain the persistent sources of truth.

## Save Format

- No save-version bump.
- No persistent milestone reward fields.
- Replay safety remains handled by existing campaign reward, optional objective, rival, relic, and Retinue rules.

## Verification

Focused Results, runtime cloning, campaign guidance, and hosted Ashen Outpost proxy coverage were updated. Full matrix results are recorded in the v0.75-v0.77 handoff/checkpoint closeout.
