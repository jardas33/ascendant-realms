# v0.86 Objective Tracker Presentation Spec

## Goal

The objective tracker should reuse the compact readability pattern introduced by the Lume tracker without expanding Lume rules or creating a new objective system.

## Presentation Model

Each compact tracker row may show:

- title,
- current state,
- next action,
- optional progress,
- optional details behind disclosure.

## Supported Sources

- ordinary mission objectives,
- active battlefield events,
- enemy doctrine and threat posture,
- finale or phase-style objective context,
- Lume tracker context,
- private playtest notice context.

## Rules

- Active or urgent rows appear before lower-priority context.
- Completed and low-priority context stays compact.
- The tracker must not show misleading `OBJECTIVES 0/0` text when no ordinary objective exists but special context is present.
- Existing objective completion and reward rules remain unchanged.

## Deferrals

- No new objective reward model.
- No new mission scripting system.
- No Lume rule expansion.
