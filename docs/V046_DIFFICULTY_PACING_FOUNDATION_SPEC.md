# v0.46 Difficulty Pacing Foundation Spec

Date: 2026-05-29

## Goal

Add small data-driven pacing metadata so Act 1 missions communicate their intended difficulty ramp and pressure profile. The foundation should explain why a mission is easy, resource-focused, champion-focused, or replay-safe without changing global balance.

## Pacing Tiers

Initial pacing tiers:

- Training: Tutorial / Proving Grounds, no persistent reward or campaign pressure.
- Low: first campaign battle, light enemy pressure, simple capture reminder.
- Standard: resource-control and base-development missions with normal first-clear rewards.
- Milestone: rival champion or fortified missions with clearer preparation and relic/skill reminders.
- Replay: completed missions, reduced persistent reward, optional objective clean-up.

Pacing tier metadata is descriptive and UI-facing. Runtime pressure still comes from existing scenario definitions, mission types, enemy commanders, and v0.43 scenario modifier hooks.

## Mission Pacing Rules

- Early missions should not combine too many modifiers or instructions.
- Resource-control missions should explain site capture, assignment, and upgrade relevance.
- Base-development missions should remind the player about Workers, production buildings, and research without requiring a full tutorial overlay.
- Champion missions can be tougher but must clearly preview the rival, likely pressure, and reward stakes.
- Replays preserve mission identity but must not repeat one-time rewards.
- Tutorial / Proving Grounds remains no-save, no-reward, and avoids modifier complexity.

## UI Scope

Use existing campaign node and Results panels:

- campaign node briefing shows pacing tier, mechanic focus, and short preparation hint;
- Results summarize first-clear versus replay state and the next useful action;
- guidance copy stays short enough not to clutter the existing panel.

No new difficulty picker, campaign mutator UI, or balance menu is included.

## Save Compatibility

Pacing metadata is content-driven and not stored. No save-version bump is required. Existing completion and reward-claim state continues to prevent repeat first-clear rewards and optional-objective farming.

## Deferrals

- Dynamic difficulty scaling.
- Per-player difficulty presets.
- New enemy wave system.
- Broad AI rebalance.
- Randomized mission modifiers.
