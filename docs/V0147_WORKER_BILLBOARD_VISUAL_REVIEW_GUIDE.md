# v0.147 Worker Billboard Visual Review Guide

Status: Emmanuel human review packet for a private comparator-only Worker billboard intake experiment.

## Review Evidence

Open the ignored visual packet after running the v0.147 wrapper:

```text
artifacts/desktop-spikes/godot-salto/v0147/evidence/contact-sheet.svg
artifacts/desktop-spikes/godot-salto/v0147/evidence/visual-review-guide.md
artifacts/desktop-spikes/godot-salto/v0147/evidence/screenshots/
```

One-click wrapper:

```text
GODOT_WORKER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat
```

## Review Questions

- Does the Worker read clearly at gameplay distance?
- Does the Builder / camp-hand / repair-support role come through?
- Does the alpha edge look acceptable?
- Is the foot pivot stable?
- Is selection-ring room adequate?
- Does repeated-worker overlap remain readable?
- Is `0.90x`, `1.00x`, or `1.10x` the best runtime scale posture?
- Does the hybrid posture deserve one more single-slot experiment?
- Should the next slot be Aster static billboard, one environment material / structure slot, or a repair pass?

## Current Recommendation For Review

The comparator defaults to `1.00x` as the preferred scale posture unless Emmanuel chooses otherwise after viewing the captures. `0.90x` is safer for crowding, while `1.10x` is useful for close diagnostic readability.

The final headed capture reports `FAIL_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD`: Tier L local Worker average FPS was `0.8464` of the diagnostic fallback baseline against the `0.90` target. The recommendation is one bounded repair pass if Emmanuel wants this slot to continue; do not move to a second slot or production integration from this checkpoint.

## Explicit Boundary

This is private comparator-only intake. It is not production approval, not player-facing Salto integration, not final Worker design approval, not final Godot selection, and not v0.148.
