# v0.436 H2 Selected Entity Portraits 2.0

## Scope

H2 improves the selected-card portrait presentation without touching entity
state, selection semantics, model assets, or gameplay simulation.

## Changes

- Increased the isolated portrait viewport from 96 to 128 pixels.
- Increased the single-unit portrait presentation to 108 pixels and the
  building portrait to 92 pixels where the existing card layout permits.
- Rebalanced the preview camera framing so authored units and buildings occupy
  more of the portrait while retaining a readable three-quarter angle.
- Replaced the near-black preview surround with a restrained slate neutral,
  increased ambient fill, and kept a warm key/cool fill lighting relationship.

## Evidence

Fresh headed captures at 1920x1080 and 1366x768 passed the existing P1-R2
portrait probe. They are stored outside the repository at:

`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/H2-portraits/`

The probe recorded lit portrait pixels for worker, military, hero, small
building, and HQ views at both resolutions, with unchanged entity positions.
