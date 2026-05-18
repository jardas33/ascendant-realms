# v0.13.1 Node Risk Dashboard Spec

Date: 2026-05-18

Purpose: define the node-level dashboard added by v0.13.1 for repeated deterministic scenario-lab evidence.

## Output

The node dashboard appears in:

- `PLAYTEST_SCENARIO_LAB_EXTENDED.md`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.json`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`

## Inputs

The dashboard is generated from extended scenario-lab metric rows:

- default 5 deterministic iterations
- 255 source simulator runs per iteration
- 355 derived profile-run metrics per iteration
- 1,775 derived extended metric rows total

## Fields

Each node row includes:

- node id and name
- total extended rows
- win/defeat/timeout record
- win rate
- timeout rate
- loss rate
- average unit losses
- pressure-warning count
- Greedy Economy record
- Fast Army record
- Retinue + Training Yard II record
- Pressure-Ignoring record
- Retinue advantage score
- dashboard status
- verdict

## Required Views

The dashboard supports:

- safest nodes
- riskiest nodes
- timeout-prone nodes
- Greedy Economy struggle nodes
- Fast Army dominance nodes
- Retinue + Training Yard II advantage nodes
- Pressure-Ignoring proxy health
- Ashen Outpost status
- Cinderfen Crossing status
- Cinderfen Watch status

## Status Rules

- `OK`: no high loss/timeout signal and no pressure-watch burden.
- `Monitor`: timeout or pressure-watch evidence exists but does not imply tuning.
- `Warning`: repeated loss-risk signal across profiles.

These statuses are automated regression cues only. They do not authorize gameplay tuning.

## Current v0.13.1 Dashboard Reading

- Safest structural nodes: Border Village and Old Stone Road.
- Highest loss-risk node: Bandit Hillfort, driven by aggressive/greedy route failures rather than Safe Beginner collapse.
- Biggest timeout-risk node: Ashen Outpost by timeout count/rate in the generated dashboard.
- Pressure-risk signal: Cinderfen Watch has the largest pressure-warning count, with Cinderfen Crossing close behind.
- Cinderfen Crossing and Cinderfen Watch remain Safe Beginner stable, so route feel and warning noticeability need human testing before tuning.
