# v0.84 Guided Lume Demo Readability Spec

## Scope

v0.84 improves the existing v0.82 Lume Network prototype and v0.83 private playtest launch so a tester can understand the loop quickly. It does not add maps, factions, art, save fields, rewards, balance changes, new Lume rules, or broad UI redesign.

## Guided HUD Tracker

The HUD objective surface should replace the paragraph-style Lume copy with a progressive tracker:

- Start: `LUME WARD`, `Capture West Stone Cut`, `LUME LINKS 0/2`.
- West held only: `LUME WARD`, `Capture Ford Toll`, `1 of 2 sites held`.
- First active link: `LUME WARD ACTIVE`, `West Stone Cut <-> Ford Toll`, `Nearby allies take 8% less damage`.
- Lost endpoint: `LUME LINK SEVERED`, `Recapture <site>`.
- Restored link: `LUME WARD RESTORED`, restored link name.
- Optional second link reveal after the first activation: `OPTIONAL LINK`, `Capture North Aether Spring`.
- Both active: `LUME NETWORK ACTIVE - 2/2`.

The normal `Objectives 0/0` line should not be shown when the private Lume tracker is the only objective-like surface. `LUME LINKS x/2` should be the readable progress marker instead.

## Details Disclosure

Long explanation belongs behind a small Details disclosure:

- Linked Ward is battle-local.
- Active linked endpoints grant nearby player units/buildings 8% less incoming damage.
- Enemy recapture severs a link.
- Recapturing both endpoints restores it.
- Tutorial and generic no-reward launches are excluded.

## Private Demo Controls

The private Aether Well Lume demo should expose compact controls in the existing HUD:

- `Focus West Stone Cut`.
- `Focus Ford Toll`.
- `Focus North Aether Spring` only after the first link has awakened.
- `Exit Demo` at all times.
- `Finish Demo & View Results` only after the first link has awakened.

Focus buttons only center the camera. Exit returns to Campaign Map without Results or persistence. Finish uses the existing Results scene and existing no-save/no-reward private summary with Lume telemetry so far.

## Notifications

Only high-priority Lume status changes should interrupt the status line:

- `Lume Ward awakened`.
- `Lume Link severed: <site> lost`.
- `Lume Ward restored`.
- `Lume Network fully awakened: 2/2 links active`.

Notifications must dedupe and remain battle-local. Broader notification cleanup is deferred to a later checkpoint.

## Deferrals

- No new Lume rules.
- No new persistent progress.
- No broader campaign copy migration.
- No new art or asset pipeline.
- No full objective-panel redesign.
