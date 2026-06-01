# v0.99 Act 1 Results and Next-Step Report

Status: implemented.

## Goal

Ordinary Results should tell the player what happened and what to do next without changing rewards, XP, campaign writes, or replay safety.

## Results Overview Changes

- Campaign Results now prefer the selected mission's primary objective in the overview when a campaign result is present.
- Victories use `Secured:` copy for the primary objective.
- Campaign failures without a campaign completion result still show the safe generic defeat posture.
- Next action uses the existing Act 1 guidance model when available.
- Replay Results use replay-safe next-step copy instead of implying new first-clear progress.
- Finale Results show Act 1 complete guidance and remind the player to equip rewards or spend skill points when relevant.

## Mission-Specific Outcome Copy

- Salto Outskirts now reads as the foothold outside Salto.
- Old Stone Road now points players toward the road and site-control layer.
- Aether Well Ruins keeps its visible title and frames Lume pressure without renaming stable IDs.
- Bandit Hillfort and Chapel of the Barrosan Marches now clarify why each supports Ashen Outpost.
- Ashen Outpost now names Captain Malrec and Act 1 completion clearly.

## Replay Safety

v0.99 does not change first-clear state, replay rewards, optional objective credit, relic rewards, XP, campaign resources, or save writes. It only changes the text used to explain those existing states.

## Telemetry and Detail Posture

Existing detailed Results, telemetry, modifier, Retinue, and statistics sections remain behind the established full-details disclosure. v0.99 does not remove data.
