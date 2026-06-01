# v0.98 Results-To-Meta Flow Report

Status: implemented.

## Change

Ordinary Results screens now include a compact `Progression Summary` block below the main overview and above detailed sections.

## Summary Fields

The block summarizes:

- Hero XP and skill point change;
- battle rewards;
- relic change or no relic change;
- Retinue notable veterans, recovery, losses, ready returns, or reinforcement use;
- Stronghold/campaign resource consequence when campaign Results data exists.

## Progressive Disclosure

The existing compact Results summary remains above the fold. Full battle details, hero stat sheets, detailed reward cards, Retinue recruitment, and debug-like telemetry remain in existing expanded or lower-priority areas.

## Safety

The summary is derived from existing `ResultsData`. It does not write saves, alter XP, alter rewards, mutate Retinue state, change campaign rewards, or change replay/Tutorial/private-demo behavior.
