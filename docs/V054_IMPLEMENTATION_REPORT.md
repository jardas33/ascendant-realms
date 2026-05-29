# v0.54 Control Groups Implementation Report

## Summary

v0.54 adds the first small, session-only RTS control-group layer:

- Ctrl+1 through Ctrl+5 assigns the current living player unit and hero selection.
- 1 through 5 recalls stored groups and selects only living valid members.
- Dead or invalid members are pruned silently during recall.
- Enemy units, neutral entities, buildings, and resource sites are ignored.
- The selected-entity HUD shows compact group membership such as `1:3`.

## Runtime

- Added `ControlGroupSystem` as a pure battle-session helper.
- Wired assignment and recall through the existing keyboard input flow.
- Recall updates the existing selection system rather than adding a parallel selection model.
- Ability hotkeys continue to work when no stored control group consumes the number key.
- Control groups are not written to campaign, hero, profile, settings, or save data.

## UI

- Assignment feedback: `Group 1 assigned: 3 units`.
- Recall feedback: `Group 1 selected: 2 units`.
- Empty/dead feedback: `Group 1 is empty`.
- Selected unit panel hint: `Ctrl+1-5 assigns; 1-5 recalls.`

## Save Format

No save-version bump and no new save fields were introduced. Control groups are discarded when the battle scene ends.

## Verification

Targeted evidence:

- `npx tsc -p tsconfig.json --noEmit`
- focused Vitest coverage for control-group assignment, recall, invalid filtering, and dead-member cleanup
- hosted deep-battle proxy for assign, recall, and group move through canvas pointer helpers

Full checkpoint evidence also passed `npm test` (78 files / 591 tests), production build, content/art validation, smoke, controls, Act 1 telemetry, hosted deep-battle (28 tests), hosted smoke, hosted deep-campaign-pressure, visual QA, local release shards 1/3 through 3/3, package verification (155 checks), and `git diff --check`.

## Deferrals

- No persistent groups.
- No camera jump on double-tap.
- No production/building groups.
- No subgroup tabs.
