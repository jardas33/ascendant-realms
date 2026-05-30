# v0.64 Reserve Management Spec

## Goal

Clarify the small Retinue reserve layer while keeping deployment optional and lightweight.

## Reserve Rules

- Ready Retinue units can be selected or reserved from the existing Campaign Map Retinue Camp.
- Deployment cap stays two, with Training Yard II adding one slot.
- Zero selected Retinue units remains a valid battle launch.
- Recovering units count against the tiny roster cap but cannot be selected for deployment.
- Dismiss remains available as the simple roster cleanup action.

## Presentation Rules

- The panel shows roster count, deployed count, ready reserve count, and recovering count.
- Each unit shows name, type, role, rank, XP progress, kills, survival/deployment counters, and status.
- Ready reserve action copy is `Deploy`.
- Selected action copy is `Reserve`.
- Recovering action copy is `Recovering`.
- Full-cap action copy remains `Deployment Full`.

## Abuse Limits

- Replays cannot refresh recovery timers.
- Replays cannot duplicate Retinue recruitment beyond existing roster-cap and survivor checks.
- Tutorial and skirmish remain Retinue-deployment-free.

## Deferrals

- No drag-and-drop army board.
- No large roster screen.
- No saved formations or persistent control groups.
- No auto-fill recommendation system.
