# v0.91 Emmanuel Desktop Transition Review Packet

Status: review packet only. No desktop port, wrapper, engine selection, dependency, art generation, runtime behavior change, or save change is included.

## Bottom Line

Keep building and testing the browser prototype for now. It is still the best place to prove the core RTS/RPG loop, content rules, campaign pacing, Lume readability, hero/Retinue progression, and automated QA. The future desktop game should be a genuine installable RTS/RPG, but it should start from benchmarked evidence, not a rushed port.

## What Should Remain In Browser For Now

- Core campaign loop iteration.
- Act 1 readability and pacing.
- Hero XP, skills, relics, Retinue, and Results flow.
- Lume Network gameplay proof.
- Enemy doctrine and event pressure tuning.
- Content validation.
- Deterministic simulator and telemetry.
- Visual QA and desktop viewport acceptance rules.
- Controlled art-intake preparation before runtime art import.

## What Is Safe To Continue Building

- Data-driven content polish that preserves stable IDs.
- Pure-rule systems that can be tested without Phaser.
- Campaign/reward/readability improvements with save safety.
- Deterministic playtest telemetry.
- Art-direction and asset-intake docs before generation/import.
- UI information-architecture polish as long as it does not redesign gameplay.
- Save-normalization tests and old-save fixtures.

## What Should Be Deferred

- Desktop port.
- Desktop wrapper.
- Final engine choice.
- New dependencies for desktop experiments.
- Runtime art replacement.
- Large roster/race expansion.
- Multiplayer, PvP, and co-op.
- Public title/runtime rename.
- Save schema migration.
- Full Act 1 desktop rebuild.

## Future Engine Questions

Before choosing an engine, answer:

- Can it handle RTS pathing and group commands at target unit counts?
- Does it support the intended 2D, 2.5D, or 3D art direction without fighting readability?
- Can it build dense desktop HUD, campaign, Results, settings, and keybinding screens?
- Can it support automated tests and deterministic telemetry?
- How much current TypeScript data/rules can remain authoritative?
- What is the save/profile/file strategy?
- What is the asset pipeline for Barrosan, Ashen, Lume, and future non-human silhouettes?
- Can it package a Windows desktop build reproducibly?
- Does it leave room for future online requirements without forcing them now?
- Is the team/agent workflow productive enough to maintain it?

## Minimum Benchmark Needed Before Choosing

Do not choose based on promise or visuals alone. Require a benchmark that includes:

- one hero,
- one Worker,
- two military unit types,
- enemy pressure,
- Command Hall,
- Barracks,
- mine,
- shrine,
- one resource site,
- one Lume link,
- group selection and movement,
- combat engagement,
- campaign launch,
- Results,
- settings,
- key rebinding,
- save/load,
- packaging metadata,
- performance and automation evidence.

## Risks Of Premature Porting

- Losing deterministic simulator and test discipline.
- Rebuilding UI before the final information architecture is stable.
- Locking pathing too early and limiting RTS scale.
- Importing art before the style-frame gate has real approval.
- Creating a wrapped-browser build that feels cheaper than the current prototype.
- Splitting content data into two sources and causing ID drift.
- Breaking save/reward assumptions without visible gameplay gain.
- Slowing core fun proof while chasing engine setup.

## How Current Prototype Work Retains Value

The prototype is not throwaway. It gives the future desktop project:

- stable content IDs,
- battle and campaign rules,
- save-normalization lessons,
- reward/replay safety,
- Retinue and hero progression loops,
- Lume interaction design,
- enemy doctrine and event pacing,
- UI hierarchy lessons,
- visual QA acceptance criteria,
- package/build discipline,
- deterministic telemetry.

## Recommended Next Decision

Keep v0.91 as the desktop-transition audit and roadmap. The next desktop-related work, when explicitly approved, should be a small benchmark or content/save reuse experiment, not a port.

## Emmanuel Review Questions

- Is the Salto/Barrosan/Ashen vertical slice the right first desktop benchmark?
- Should the first engine benchmark prioritize 2D readability or 2.5D/3D ambition?
- What target unit count feels like the minimum credible RTS/RPG battle?
- What desktop settings are must-have for the first installable slice?
- Which art proof should happen before engine evaluation, if any?
- Should old browser saves be imported into future desktop builds or treated as prototype fixtures only?
