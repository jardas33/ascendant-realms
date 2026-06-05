# v0.129 Hero Worker Mine Build Recruit Report

Status: implemented as a bounded Godot spike microloop.

The runtime now exposes deterministic actions for Aster selection/movement/ability, mine conversion, Worker assignment, boosted mine production, Barracks restoration, Militia queue/spawn, one Ashen wave, Lume restore, and Results. Both 2D and 2.5D placeholder scenes delegate to the same runtime fixture.

The loop deliberately stays small:

- one mine/resource site;
- one Worker assignment;
- one Barracks restoration action;
- one Militia recruit button/queue;
- optional Ranger support is present as a safe runtime method but not required for the default review path;
- one pressure wave;
- no save writes or full-port claim.

Evidence is generated under `artifacts/desktop-spikes/godot-salto/v0129/` by the existing player-slice validation and capture scripts.
