# v0.79 Deferred Decisions Register

Status: docs-only decision register.

The following decisions are intentionally deferred after Emmanuel's v0.78 review. They are not approved for runtime implementation during v0.79.

## Legal And Commercial Decisions

- Formal trademark clearance.
- Formal legal review.
- Public commercial announcement.
- Final commercial-title lock.
- Domain and storefront naming strategy.
- Localization and pronunciation strategy for `JARDAS`, `Barrosan`, and related names.

Reason: v0.79 records creative approval only. Legal and commercial clearance require qualified human review.

## Naming And Identity Decisions

- Final race-name lock.
- Final public faction-name lock.
- Runtime rebrand.
- Stable internal-ID migration.
- Runtime display-copy migration.
- Save migration for any future renamed IDs.

Reason: stable IDs and saves must remain safe until a dedicated migration gate exists.

## Content Roster Decisions

- Exact race rosters.
- Exact unit rosters.
- Exact building rosters.
- Exact hero class implementation.
- Exact hero race/class/origin/oath rules.
- Exact act-by-act mission lists.
- Broad Act 2 runtime expansion.

Reason: v0.79 approves direction, not implementation detail.

## Runtime System Decisions

- Lume Network implementation.
- Living Mines implementation.
- Dynamic Battlefield Oaths implementation.
- Salto Stronghold runtime transformation.
- deeper Rival Commander/Nemesis evolution.
- Retinue identity deepening implementation.
- high-level endgame systems.

Reason: each requires a separate scoped specification, tests, save posture, UI posture, and rollback plan.

## Art, Audio, And Presentation Decisions

- Asset generation.
- Runtime-art integration.
- AI-assisted style-frame generation or curation.
- Final art direction production lock.
- Audio production.
- final UI art kit.
- animation/VFX production.

Reason: no art is generated or imported in v0.79. Future visual work requires source/license and review gates.

## Desktop And Platform Decisions

- Desktop-engine selection.
- Electron wrapper.
- Tauri wrapper.
- desktop packaging.
- Steam/store integration.
- desktop-specific UX and settings.
- final installable build process.

Reason: browser prototype remains the current development vehicle. Desktop work needs a later deliberate gate.

## Multiplayer Decisions

- multiplayer architecture.
- PvP.
- co-op.
- networking model.
- lockstep vs server-authoritative simulation.
- matchmaking, lobbies, or persistence services.

Reason: multiplayer remains long-term and must not pull the prototype off the single-player foundation.

## Decision Handling Rule

Any deferred item can move forward only through a later separately supplied goal that states:

- what decision is being reopened;
- whether the work is docs-only or runtime;
- allowed files and systems;
- save posture;
- package posture;
- validation commands;
- stop conditions.

v0.79 does not reopen these decisions.
