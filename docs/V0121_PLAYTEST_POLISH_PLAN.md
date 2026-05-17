# v0.12.1 Playtest Polish Plan

Date: 2026-05-17

Scope: Phase 3 prioritization after the human-paced v0.12.1 review. This plan keeps implementation deliberately small and evidence-backed.

## Now

Small, safe, player-facing fixes:

1. Align player-facing Cinderfen map names.
   - Evidence: campaign route, user-facing goal language, defeat tips, and route docs say `Cinderfen Crossing` / `Cinderfen Watch`, while skirmish setup, battle status, and results say `Cinderfen Causeway` / `Cinderfen Watchpost`.
   - Fix: rename the display names in map data to `Cinderfen Crossing` and `Cinderfen Watch`; keep ids, file names, map layout, descriptions, and mechanics unchanged.
   - Risk: low-medium because exact-copy tests reference map names.

2. Make Cinder Shrine objective copy more conversational.
   - Evidence: `Cinder Shrine Surge (+20 Aether once)` is accurate but reads like an internal mechanic label in the small objective tracker.
   - Fix: keep the same one-time +20 Aether payoff but word it as an action: claim the shrine for a one-time +20 Aether surge, then hold it.
   - Risk: low; update exact objective-copy tests if needed.

3. Remove campaign-only support advice from skirmish defeat guidance.
   - Evidence: a skirmish defeat showed `Use Camp Or Chapel Support`, which is not available from skirmish.
   - Fix: keep that action for campaign-node defeats, but use a skirmish-safe action such as `Hold after each wave` for skirmish defeats.
   - Risk: low; add a pure results guidance test.

## Later

Visual art debt:

- New selection-ring art, destination markers, attack lines, Cinderfen shrine/watchtower/causeway landmarks, fog-edge polish, minimap icons, results art, and map thumbnails.

Larger balance questions:

- Retinue + Training Yard II strength.
- Greedy Economy timeout feel.
- Fast Army quick-clear feel.
- Early campaign wave/economy pacing after more human evidence.

New systems:

- Control groups, command queue, stances, tactical log, minimap filters, tutorial persistence, or richer combat explanation panels.

Larger AI/economy behavior:

- Enemy workers, construction, harvesting, economy AI, route contest AI, defensive hold behavior, or live reinforcement systems.

Content expansion:

- New maps, factions, units, campaign nodes, rewards, or route branches.

## Implementation Limit

Implement only the three `Now` fixes above unless verification exposes a direct regression caused by them. No numeric tuning is justified by the review.
