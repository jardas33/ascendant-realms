# v0.84 Private Demo Fast Retest Spec

## Goal

The private Aether Well Lume demo should let Emmanuel retest the Lume loop quickly from a locked or fresh campaign without granting rewards, campaign progress, hero XP, Retinue changes, reputation, relics, or save mutations from the battle.

## Private Ribbon

The HUD ribbon should be compact:

`PRIVATE DEMO - rewards and campaign progress disabled`

The longer explanation remains available in a disclosure.

## Fast Actions

- `Exit Demo`: always available, returns to Campaign Map, persists nothing from the battle.
- `Finish Demo & View Results`: revealed only after the first Linked Ward activation, ends the private demo through existing Results, persists nothing, and shows Lume telemetry so far.

## Guardrails

- The feature is available only to local development builds or private playtest packages with the existing private playtest flag.
- Normal campaign unlocks remain unchanged.
- Generic no-reward battles remain excluded from Lume.
- Tutorial remains excluded and simple.

## Retest Evidence

Automated tests should cover launch isolation, focus controls, finish-to-Results, save isolation, and package validation for the v0.84 docs.
