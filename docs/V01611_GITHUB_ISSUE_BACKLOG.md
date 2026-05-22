# v0.16.11 GitHub Issue Backlog

Date: 2026-05-22

Use these as ready-to-copy GitHub issue templates. Do not paste private tester names, contact details, raw private feedback, screenshots, or videos into public issues.

## 1. Manual Retest Required Before v0.17

Title: `Manual retest required: v0.16.7 combat/control release candidate`

Labels: `manual-test`, `release-candidate`, `v0.16.x`

Body:

```md
## Context

The current release-candidate package includes the v0.16.7 combat/control fix plus v0.16.8-v0.16.11 verification, soak, tester-kit, and freeze docs.

Package: ascendant-realms-private-playtest-<final-hash>

## Retest Checklist

- Guard Area is default.
- Hold Ground does not chase distant idle enemies.
- Hold Ground: first adjacent enemy dies, second adjacent enemy engages.
- Melee enemies beside Command Hall attack locally.
- Retreat near multiple enemies starts and is not instantly canceled.
- Combat can resume after suppression expires.
- Attack cursor appears over enemy body/edge.
- Empty nearby terrain does not show attack intent.
- Left-click enemy attack remains intentional.
- Drag-select over HUD/minimap works.
- Minimap click plus H does not leave stale No Selection.
- Tutorial defeat Results works.

## Result

- [ ] Pass
- [ ] Mixed
- [ ] Fail

## Notes

Record browser, OS, route, exact steps, expected result, actual result, and whether it reproduced.
```

## 2. Possible v0.16.x Bugfix If Melee Contact Still Fails

Title: `v0.16.x bugfix candidate: adjacent melee contact still idles after first kill`

Labels: `bug`, `combat`, `manual-retest`, `v0.16.x`

Body:

```md
## Trigger

Open only if a real manual retest reproduces adjacent melee idle after the first enemy dies.

## Evidence Needed

- Build/package:
- Browser/OS:
- Route:
- Unit/hero selected:
- Enemy type/count:
- Behaviour mode:
- Exact steps:
- Expected:
- Actual:
- Reproduced? yes/no

## Guardrails

Fix only the failing melee-contact/reacquisition behavior. Do not change stats, balance, wave timings, save format, maps, units, buildings, or broad AI/pathing.
```

## 3. Possible v0.16.x Bugfix If Building Aggro Still Fails

Title: `v0.16.x bugfix candidate: melee enemies idle beside Command Hall`

Labels: `bug`, `enemy-aggro`, `manual-retest`, `v0.16.x`

Body:

```md
## Trigger

Open only if melee enemies stand beside a valid hostile building and do not attack when no better target is active.

## Evidence Needed

- Build/package:
- Browser/OS:
- Route/map:
- Building:
- Enemy type/count:
- Enemy position relative to building:
- Expected:
- Actual:
- Reproduced? yes/no

## Guardrails

Keep any fix local/contact-based. Do not make enemies globally chase buildings, do not tune building HP/damage, and do not rewrite enemy AI/pathing broadly.
```

## 4. Possible v0.16.x Bugfix If Retreat Still Fails

Title: `v0.16.x bugfix candidate: retreat near multiple enemies is canceled or ignored`

Labels: `bug`, `controls`, `retreat`, `manual-retest`, `v0.16.x`

Body:

```md
## Trigger

Open only if explicit move-away/retreat near multiple enemies is visibly canceled immediately or a selected unit ignores the command without clear blockage/death.

## Evidence Needed

- Build/package:
- Browser/OS:
- Route/map:
- Selected units:
- Enemy count/type:
- Command used:
- Expected:
- Actual:
- Was any unit physically blocked?
- Reproduced? yes/no

## Guardrails

Preserve explicit move priority without creating indefinite combat suppression. Do not rewrite pathfinding broadly.
```

## 5. Attack Cursor Readability Future Polish

Title: `Future polish: attack cursor and target readability`

Labels: `polish`, `readability`, `controls`, `future`

Body:

```md
## Context

v0.16.7 improved attack-hover tolerance, but human testers still need to judge whether attack intent is visually clear enough.

## Evidence Needed

- What felt unclear?
- Did the cursor fail to appear, or was it too subtle?
- Was the issue worse in dense clusters?
- Screenshot/video available outside public issue? yes/no

## Non-Goals

Do not add new runtime art/assets until an art-approved pass exists. Prefer existing CSS/cursor/selection-ring options first.
```

## 6. Worker Construction Future Design

Title: `Future design: worker construction model`

Labels: `design`, `workers`, `future`, `v0.17-candidate`

Body:

```md
## Context

Worker construction was requested as a future feature, not a v0.16.x bugfix.

## Design Questions

- Dedicated workers or existing villagers?
- Do buildings require workers, Command Hall authority, or both?
- Can workers be attacked?
- Can workers repair?
- How many workers per building?
- Does worker travel slow early game too much?
- How does this affect RTS/RPG hero control focus?
- What AI support is required?

## Guardrails

No implementation until a dedicated design/prototype goal opens.
```

## 7. First External Tester Feedback Intake

Title: `First external tester feedback intake: 2-5 tester batch`

Labels: `playtest`, `feedback-intake`, `private-test`

Body:

```md
## Scope

Collect structured notes from 2-5 first external testers using the private release-candidate package.

## Routes

- Route A: Tutorial Only
- Route B: Tutorial Plus First Campaign
- Route C: Baseline Cautious
- Route D: Skirmish / Broken Ford
- Route E: Behaviour Mode Stress

## Intake Rules

- Keep raw private feedback outside the public repo.
- Do not record private tester names/emails in the issue.
- Summarize only anonymized, actionable patterns.
- Separate bugs from readability, onboarding, preference, and future-feature notes.
```

## 8. Tutorial / Onboarding Polish

Title: `Future polish: Tutorial and onboarding clarity`

Labels: `tutorial`, `onboarding`, `polish`, `future`

Body:

```md
## Context

Use Emmanuel's retest and first tester batch to identify onboarding confusion. Do not add new gameplay content as a shortcut.

## Evidence Needed

- First unclear instruction:
- First point of control confusion:
- Did Results explain what happened?
- Did Tutorial prepare the tester for the first campaign battle?

## Guardrails

Keep Tutorial optional, no-reward, and non-persistent unless a future goal explicitly changes that.
```

## 9. Visual Overhaul Future Milestone

Title: `Future milestone: visual overhaul and asset approval`

Labels: `visual`, `art`, `future`, `production-readiness`

Body:

```md
## Context

Current tracked image assets are prototype assets. Production readiness still requires source/license proof and approval.

## Workstreams

- Source/license proof for current assets.
- Approved visual bible update.
- Runtime art replacement plan.
- UI/HUD readability review.
- Combat VFX and cursor readability pass.

## Guardrails

Do not import runtime art/assets during v0.16.x combat/control stabilization. Do not copy protected RTS UI/assets/lore/music.
```
