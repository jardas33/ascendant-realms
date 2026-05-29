# v0.42 Mission Variety Foundation Spec

Date: 2026-05-28

## Goal

Add a small mission-type layer to existing campaign battle nodes so battles read as intentional campaign missions instead of isolated skirmishes. The foundation must use existing maps, objectives, AI, rewards, and UI surfaces only.

## Mission Types

Initial types:

- Assault: defeat the enemy base, commander, or key hostile position.
- Control: contest and hold resource sites.
- Defense: protect the Command Hall or weather pressure using existing battle rules.
- Skirmish / Training: basic battle, replay, or tutorial-safe route.

Mission type metadata influences briefing copy, primary objective wording, optional-objective suggestions, reward-preview copy, and conservative scenario modifier selection. It does not create new win conditions or maps.

## Campaign Node Rules

- Battle nodes should declare a mission type, briefing, primary objective, reward preview, and after-action summary.
- Non-battle nodes can omit mission type metadata.
- Tutorial / Proving Grounds remains no-save and no-reward, and does not receive campaign mission modifier complexity.
- Replay rules from v0.41 remain authoritative: completed missions can be replayed, but first-clear rewards and one-time objective completion credit do not duplicate.

## UI Scope

Use existing campaign map and Results panels:

- campaign node details show mission type, briefing, primary objective, reward preview, optional objectives, and completion/replay state;
- Results show mission type and after-action copy alongside campaign reward status, optional objectives, relic choice, and skill reminders.

No new campaign journal, map art, node art, or modal briefing flow is included.

## Save Compatibility

Mission type metadata is content-driven and is not stored in campaign saves. Old saves continue to load through the existing campaign normalization path. Unknown future mission ids and objective ids remain ignored by the v0.41 optional-objective guards.

## Deferrals

- New campaign map routes.
- New objective mechanics.
- Mission scoring ranks or medals.
- Branching mission outcomes.
- Large campaign journal or quest UI.
