# v0.169 Aster Visual-QA Hardening

Status: `PASS_V0169_ASTER_VISUAL_QA_HARDENING_READY`

Scope:

- Zero new images.
- Zero new slots.
- Aster fourth-slot opt-in path only.
- Default stabilized launcher remains procedural.
- Prior Worker-only, Worker + Barracks, and Worker + Barracks + Militia launchers remain unchanged.
- Browser runtime remains untouched.

Repairs made:

- Increased Aster opt-in presentation scale from `1.00` to `1.08`.
- Raised the Aster default runtime scale to `1.08` for the same opt-in path.
- Added Aster foreground/depth-sort reporting with `foregroundDepthBypassForHeroReadability` and `renderPriority`.
- Set the Aster billboard material to no-depth-test with render priority `2`.
- Moved current Aster four-slot validation/capture output to `artifacts/desktop-spikes/godot-salto/v0169/`.
- Taught the player-slice capture checkpoint classifier that `v0169` uses the same four-slot capture family as v0.168.

Windows visual QA:

- Battle default: Aster reads larger, selected, and distinct from Worker and Militia.
- Squad crowding: Aster remains visible and no duplicate procedural hero body appears. The foreground structure still crosses the lower-body area in the current authored review layout; this is documented as an art-direction/framing limitation, not a load/fallback defect.
- Combat onset: Aster remains readable during squad selection and enemy contact.
- Missing-art fallback: only Aster returns to the procedural body; Worker, Barracks, and Militia remain art-enabled.
- Hash-mismatch fallback: only Aster returns to the procedural body; Worker, Barracks, and Militia remain art-enabled.

Representative screenshots:

- `artifacts/desktop-spikes/godot-salto/v0169/capture/worker-barracks-militia-aster/screenshots/03_battle_default.png`
- `artifacts/desktop-spikes/godot-salto/v0169/capture/worker-barracks-militia-aster/screenshots/09_squad_crowding.png`
- `artifacts/desktop-spikes/godot-salto/v0169/real-input/worker-barracks-militia-aster-post-mine-flow/screenshots/16_combat_onset.png`
- `artifacts/desktop-spikes/godot-salto/v0169/capture/aster-missing-art-fallback/screenshots/03_battle_default.png`

Computer Use review:

- `artifacts/desktop-spikes/godot-salto/v0169/computer-use/worker-barracks-militia-aster-art-opt-in-computer-use-review.json`
- `artifacts/desktop-spikes/godot-salto/v0169/computer-use/worker-barracks-militia-aster-art-opt-in-computer-use-gate.json`

Result:

The v0.169 path is ready for human review. It is visibly stronger than v0.168, but it is not a final art-direction approval for Aster or the complete Godot presentation.
