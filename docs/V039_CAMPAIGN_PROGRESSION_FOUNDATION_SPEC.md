# v0.39 Campaign Progression Foundation Spec

Date: 2026-05-28

## Goal

Make the campaign map read as a connected progression layer instead of a list of isolated battles. The foundation should clarify locked, available, completed, and replayable mission state while reusing the existing campaign map UI, existing scenario shells, and existing save structures wherever possible.

## Node Completion State

- Locked nodes cannot launch and must show a locked reason through existing prerequisite copy.
- Available nodes can launch or resolve their event choices.
- Completed battle nodes are replayable.
- Completed event or town nodes keep their existing choice and service rules.
- First-clear campaign rewards are claimed once through `CampaignSaveData.nodeRewardsClaimedIds`.
- Replay state is derived from `CampaignSaveData.completedNodeIds` and `nodeRewardsClaimedIds`; it does not need a separate mission table.

## Campaign Map UI Scope

Each selected node should show:

- status label: Locked, Available, Completed, or Replayable;
- first-clear or replay marker;
- mission reward preview;
- already-claimed reward copy when relevant;
- optional objective summary when the linked map defines secondary objectives;
- a small build hint when the node has a clear Warrior, Seer, or Commander read.

No new art, map screen, chapter system, quest log, or broad campaign rewrite is part of this checkpoint.

## Save Compatibility

No save-version bump is planned. Existing campaign progression fields remain authoritative. New optional-objective persistence, if implemented, must default to an empty list for old saves and ignore unknown mission/objective ids safely.

## Deferrals

- New campaign chapters or maps.
- Branching quest journal.
- Large campaign reward table.
- Campaign-wide balance pass.
- New factions, runtime art/assets, shop, crafting, Patrol, formations, or broad AI/pathing changes.
