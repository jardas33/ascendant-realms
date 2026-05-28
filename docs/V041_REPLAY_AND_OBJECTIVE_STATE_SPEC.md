# v0.41 Replay and Objective State Spec

Date: 2026-05-28

## Goal

Add a small replay and optional-objective state foundation that makes completed missions safe to revisit without reopening first-clear farming. Optional objectives should use existing battle signals and be visible on campaign and Results surfaces.

## Optional Objective Rules

Initial optional objectives come from existing map secondary objectives:

- capture a resource site;
- destroy a marked building;
- defeat a marked unit or rival commander where already represented by map data.

Objectives are not required to finish a mission. Completion is recorded only for known objectives on the mission's linked map. Unknown ids are ignored during save normalization and campaign result recording.

## Persistence

The preferred save-safe structure is a flat optional objective completion list on `CampaignSaveData`, keyed as `missionId:objectiveId`.

- Old saves without the field load with an empty list.
- Unknown mission ids are ignored.
- Unknown objective ids are ignored.
- No save-version bump is required.
- The field records completion credit only; it does not duplicate campaign rewards.

## Replay Rules

- Completed battle nodes can be launched again.
- Replays do not duplicate campaign node rewards.
- Replays do not duplicate optional objective completion credit.
- Replays can still earn the reduced repeat-clear battle reward path already used by map reward tables.
- Results and campaign node copy must make replay status clear.

## UI Scope

- Campaign map selected-node details show objective names and completion state.
- Results show objectives completed this run plus whether each objective was newly recorded or already recorded.
- Campaign status messages should say when replay rewards were reduced or already claimed.

## Deferrals

- Large objective reward catalog.
- Timed challenge medals.
- Mission scoring ranks.
- Objective-based unlock branches.
- Account-wide achievement system.
