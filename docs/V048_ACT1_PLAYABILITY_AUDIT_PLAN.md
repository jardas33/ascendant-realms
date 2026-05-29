# v0.48 Act 1 Playability Audit Plan

## Goal

Stabilize the existing Act 1 loop as a release-candidate path without adding maps, factions, runtime art, shops, crafting, a new major mechanic, save-breaking migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or force-click/DOM fallback behavior.

## Route Under Audit

1. Tutorial / Proving Grounds: practice only, no save state, no persistent reward.
2. Border Village: first persistent battle, capture site, Barracks, first defense, first-clear reward.
3. Old Stone Road: base-development step, Worker production, production buildings, early upgrades.
4. Aether Well Ruins: resource-control step, Worker site assignment, site upgrades, ability pacing.
5. Bandit Hillfort: rival-pressure step, mixed army staging, commander pressure, support-node preparation.
6. Ashen Outpost: champion relic milestone, fortified assault, relic choice, skill/relic reminders.
7. Replay loop: completed battle nodes replay safely, one-time rewards and objective credit do not duplicate.

## Audit Questions

- Unlock flow: does each first clear unlock the intended next Act 1 node or branch?
- Reward flow: are first-clear, replay, already-claimed, relic, XP, and skill-point messages distinct?
- Onboarding: do Worker, building, resource-site, upgrade, hero skill, relic equip, and replay hints appear before they matter?
- Mission readability: are mission type, modifier, primary objective, optional objective, and reward preview visible without clutter?
- Replay safety: do reduced rewards, already-claimed state, and one-time optional objective credit stay clear?
- Difficulty pacing: does deterministic telemetry show unfair early pressure or only strategy spread on harder nodes?
- Tutorial protection: does Tutorial stay no-save/no-reward and avoid persistent progression noise?

## Evidence Sources

- Deterministic simulator output: `ACT1_PLAYABILITY_TELEMETRY.json` and `ACT1_PLAYABILITY_TELEMETRY.md`.
- Unit and content validation for campaign spine, guidance, package validation, and simulator report logic.
- Hosted Playwright proxy tests for route unlock, base-development/resource-control guidance, champion relic guidance, and replay-safe copy.
- Manual/visual QA as practical release-candidate evidence.

## Evidence Boundary

The simulator measures timing, resources, battle outcomes, objective completion, and script records. It does not measure human fun, stress, visual comprehension, audio clarity, or novice understanding. Any numeric tuning must be justified by real structural evidence, not by a single deterministic script spread.

## Tuning Rule

Use mission-local metadata, modifiers, copy, and existing AI pacing hooks only when needed. Prefer copy/readability fixes when Safe Beginner can clear a node and failures are concentrated in greedy or rushed scripts.

## Deferrals

- No new Act 1 maps.
- No new faction or enemy roster.
- No new reward economy or shop.
- No new cinematic/quest system.
- No broad inventory, skill tree, AI, or pathing rewrite.
- No final balance declaration without human tester evidence.
