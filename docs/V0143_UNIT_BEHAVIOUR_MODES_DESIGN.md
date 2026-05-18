# v0.14.3 Unit Behaviour Modes Design

Date: 2026-05-18  
Status: design-only for v0.14.3

## Purpose

Emmanuel asked for unit behaviour options similar to common RTS expectations: units that hold ground, defend, press attacks, or patrol. This document defines an original Ascendant Realms stance direction without copying any protected game's UI, names, icons, layout, art, lore, or exact control scheme.

v0.14.3 does not implement stance controls. The critical fixes for this pass are marquee selection, melee engagement, retreat intent, tutorial defeat feedback, and hero creation clarity.

## Design Principles

- Stances should describe intent in plain language, not hidden AI rules.
- The default should stay readable for new testers.
- Stances must not replace explicit move, attack, and attack-move orders.
- Retreat/move-away orders should remain reliable regardless of stance.
- No new art or icons should be required for V1.
- Patrol should wait until path reliability and command feedback are stronger.

## Proposed Original Modes

| Mode | Player-facing Meaning | Runtime Intent | V1 Risk |
| --- | --- | --- | --- |
| Hold Ground | Stay near the ordered point and do not chase distant enemies. | Attack only enemies in immediate weapon/contact range or enemies directly attacking the unit. | Medium: needs clear leash and "why not chasing" copy. |
| Guard Area | Balanced default. Defend the nearby area and respond to threats. | Current default guard-chase behavior with explicit move/attack orders taking priority. | Low: closest to current behavior. |
| Press Attack | Seek nearby hostiles more confidently within a leash. | Larger target-acquisition leash after explicit attack-move or while idle in enemy territory. | Medium/high: can look like AI takeover if not explained. |
| Escort | Stay near selected hero or group anchor. | Follow a friendly anchor and engage threats near that anchor. | Medium: useful, but needs group state and UI clarity. |
| Patrol Route | Move between marked points until interrupted. | Future command queue with visible route and stop condition. | High: deferred; too large for v0.14.3. |

## Recommended V1

Do not implement a stance panel in v0.14.3.

For v0.15 or later, start with two states only:

- Guard Area: the current default.
- Hold Ground: a narrow option for "do not chase far from this point."

Add Press Attack, Escort, and Patrol only after:

- current move/retreat reliability is retested by Emmanuel,
- unit order summaries can explain stance and current command together,
- browser tests cover stance persistence within a battle,
- no save-format dependency is introduced.

## Deferred Implementation Notes

- Store stance as volatile battle runtime state at first, not persistent save data.
- Expose stance in the selected unit panel only when at least one unit is selected.
- Use text labels and existing button styling first; no runtime art or icon work.
- Keep attack-move as a separate command because it is route-specific, not a persistent stance.
- Keep enemy pursuit intact; stance should change friendly intent, not enemy combat rules.

