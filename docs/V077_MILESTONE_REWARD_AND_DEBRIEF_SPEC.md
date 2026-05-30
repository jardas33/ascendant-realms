# v0.77 Milestone Reward and Debrief Spec

## Goal

Close Act 1 with clear Results copy that connects finale phases, Captain Malrec, battlefield events, tactical plan support, Retinue status, relic rewards, skill progression, and replay safety.

## Reward Model

Use existing reward systems only:

- Battle reward table: `ashen_outpost_rewards`.
- Campaign node first-clear reward: `ashen_outpost`.
- Rival first-defeat reward: Captain Malrec.
- Relic choice: existing rival commander relic reward flow.
- Skill points: existing hero XP/level progression.
- Retinue status: existing deployment, loss, recovery, and reinforcement summaries.

No new persistent loot system is added.

## First Clear

On eligible first-clear victory:

- campaign node is completed,
- campaign reward is claimed once,
- optional objectives are recorded once,
- rival first-defeat/relic rewards may resolve if Captain Malrec was defeated,
- Results says Act 1 finale completed and Chapter 2 / replay optional objectives are available.

## Replay

On replay:

- finale phases still run for readability,
- reduced/replay rewards apply through existing campaign rules,
- milestone/first-clear rewards remain already claimed,
- rival first-defeat and unique relic rewards do not duplicate,
- Results uses replay-safe copy.

## Results Layout

Use existing Results blocks:

- Battle summary: add finale phase and commander rows when present.
- Battlefield Events: keep existing event/objective summary.
- Enemy Tactics: keep doctrine and elite copy.
- Rival Outcome: keep commander reward/relic status.
- Campaign Node Complete: keep first-clear/replay/claimed state.
- New Act 1 Finale block: concise debrief with phase completion, commander release/defeat, plan support, and next step.

## Save Compatibility

- No save-version bump.
- Finale data is battle-session Results stats only.
- Existing `completedNodeIds`, `nodeRewardsClaimedIds`, `optionalObjectiveCompletionIds`, rival state, relic inventory, and Retinue state remain the persistent sources of truth.

## Manual Retest Focus

- Launch Ashen Outpost from an eligible campaign.
- Confirm phase copy appears and does not clutter objectives.
- Confirm commander is not sent in the first wave.
- Complete the finale and confirm debrief/reward/replay copy.
- Replay and confirm rewards are not duplicated.
