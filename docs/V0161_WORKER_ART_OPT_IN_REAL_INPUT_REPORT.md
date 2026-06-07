# V0161 Worker Art Opt-In Real-Input Report

Status: real-input hardening report for the existing Worker-art opt-in path.

## Covered Automation

The v0.161 hardening wrapper runs packaged Godot scenarios for:

- Default real-input smoke.
- Opt-in real-input smoke.
- Opt-in site-semantics smoke for mine conversion and Worker assignment.
- Opt-in post-mine flow smoke for Barracks restoration continuation.
- Opt-in restart/replay and recoverable-mistake profile.

## Required Evidence

The expected PASS reports are:

- `PASS_HEADED_REAL_INPUT_SMOKE`
- `PASS_V0132_HEADED_SITE_SEMANTICS_SMOKE`
- `PASS_MINE_CONVERSION_PROOF`
- `PASS_WORKER_ASSIGNMENT_PROOF`
- `PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE`
- `PASS_BARRACKS_RESTORATION_PROOF`
- `PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH`
- `PASS_V0134_RECOVERY_CASES`
- `PASS_V0134_RESTART_INTEGRITY`

Aggregated v0.161 status:

```text
PASS_V0161_WORKER_ART_OPT_IN_REAL_INPUT
```

Latest evidence also includes:

- `PASS_OBJECTIVE_MONOTONICITY_PROOF`
- `PASS_MILITIA_RECRUIT_PROOF`
- `PASS_COMBAT_ONSET_PROOF`
- `PASS_LUME_RESTORE_PROOF`
- `PASS_V0134_NO_SOFTLOCK_PROOF`
- `PASS_V0134_NO_SHORTCUT_PROOF`

The opt-in real-input packet records normal mouse events and normal simulation for launch, Aster selection, Aster movement, mine conversion, Worker selection, Worker assignment, Barracks restoration continuation, restart/replay, and recoverable mistakes.

## Limitation

Automation proves the scripted normal-input paths stayed functional. It does not claim full human playability or final Worker visual approval.
