# v0.16.9 Worker Construction Design Brief

Date: 2026-05-22

## Status

Worker construction remains deferred. v0.16.9 does not implement workers, builders, new construction units, new buildings, economy changes, save changes, or runtime UI for worker assignment.

## Future Design Models

### Model A: Dedicated Worker Unit

- Workers are a separate low-combat unit.
- Buildings require one or more workers to travel to a site and construct.
- Pros: familiar RTS readability, clear harassment target, strong economy identity.
- Risks: adds unit roster, pathing pressure, AI requirements, tutorial burden, and more micro.

### Model B: Existing Villager / Militia Can Build

- Existing non-hero units can receive build orders.
- Pros: fewer new units, easier onboarding, less content expansion.
- Risks: blurs combat/economy roles and may make army control feel worse.

### Model C: Command Hall Builds Remotely

- Command Hall remains the builder; workers are not represented as units.
- Pros: simplest current control model, low pathing risk.
- Risks: less RTS texture and does not satisfy the fantasy of visible construction labor.

### Model D: Hybrid Assisted Construction

- Command Hall places buildings, workers speed them up or repair.
- Pros: incremental path from current prototype.
- Risks: can become confusing if build ownership and worker benefits are not obvious.

## Questions Before Implementation

- Are workers separate units or existing villagers?
- Do buildings require workers, Command Hall authority, or both?
- Can workers be attacked?
- Can workers fight back?
- How many workers can build one structure?
- Can workers repair?
- Does worker travel slow the early game too much?
- How does worker micro affect RTS/RPG hero control focus?
- How does AI use workers without a broad rewrite?
- Does adding workers require save data or tutorial changes?

## Recommendation

Treat worker construction as a future v0.17+ design spike with prototype-only tests before runtime commitment. Do not bolt it onto v0.16.x combat/control stabilization.

