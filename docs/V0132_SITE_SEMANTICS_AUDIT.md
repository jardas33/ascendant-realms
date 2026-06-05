# v0.132 Site Semantics Audit

Status: `IMPLEMENTED_FOR_PLAYER_SLICE`

## Finding

Emmanuel's v0.131 retest showed that the first control path was playable, but the next interaction was unclear. The slice mixed mine and quarry language, did not clearly identify whether the quarry object was the mine objective, did not expose conversion progress or ownership, and did not naturally guide Worker assignment.

## Repair Scope

- Canonical player-facing target: `West Stone Cut Mine`.
- Site states: `NEUTRAL`, `OBJECTIVE_TARGET`, `CONVERTING`, `CONTROLLED`, and `WORKER_ASSIGNED`.
- Proof source: packaged Godot player-slice mouse input only.
- Exclusions: no art import, save change, stable-ID change, browser-runtime change, Godot-editor assembly, full port, final engine choice, or v0.133 work.

## Root Cause

The underlying runtime already had `west_stone_cut` mine-equivalent site data, but the player-facing slice inherited older terrain language from the procedural quarry landmark and v0.128 onboarding copy. That made the visible objective read like a quarry while the bounded microloop described a mine.

## Outcome

The v0.132 path makes `West Stone Cut Mine` the live player-facing name, adds visible battlefield and minimap target cues, exposes conversion progress and controlled state, highlights the Worker after control, accepts Worker assignment by right-clicking the controlled mine, and records a monotonic objective history.
