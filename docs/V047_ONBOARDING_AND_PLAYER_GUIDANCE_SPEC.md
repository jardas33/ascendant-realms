# v0.47 Onboarding and Player Guidance Spec

Date: 2026-05-29

## Goal

Polish player guidance across the existing campaign loop so players understand the next practical step after each Act 1 milestone: produce Workers, capture sites, build production, research upgrades, spend skill points, equip relics, and replay optional objectives.

## Guidance Moments

Guidance should appear only where an existing surface already supports it:

- Tutorial box: basic controls and no-save/no-reward expectations.
- Campaign node briefing: mission type, Act 1 role, objective, reward preview, modifier list, and preparation hint.
- Results: first-clear/replay state, next mission unlocked, replay available, optional objective incomplete, skill point available, relic equip reminder.
- Hero inventory/progression surfaces: existing relic and skill-tree summaries.
- HUD alerts: only if the current alert system already supports a short safe reminder.

## Onboarding Copy Rules

- Keep each hint short and action-oriented.
- Do not duplicate long tutorial text in every mission.
- Mention mechanics when they become relevant: Workers and buildings before base-development pressure, resource sites before control missions, relic equip after relic reward, and skill spending after skill points are available.
- Tutorial / Proving Grounds remains simple and does not introduce persistent reward copy.
- Results should never imply a reward was granted when replay or no-reward rules blocked it.

## Replay and Optional Objectives

Replay guidance should tell the player that completed missions remain playable, first-clear rewards are already claimed, and optional objectives can be cleaned up once without duplicating one-time bonuses. Optional-objective incomplete copy should be visible but not punitive.

## Save Compatibility

Guidance is derived from existing content and save state. No save-version bump is required. Old saves that lack newer campaign fields continue to load through existing defaults; missing optional-objective or reward-claim records simply mean no claim has been recorded yet.

## Deferrals

- Full tutorial scripting rewrite.
- In-game codex or quest journal.
- Cinematic/tutorial voiceover.
- New art, icons, or map overlays.
- Full campaign objective tracker.
