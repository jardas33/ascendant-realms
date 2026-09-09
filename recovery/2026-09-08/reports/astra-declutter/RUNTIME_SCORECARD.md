# Runtime scorecard

| Check | Baseline | Candidate-01 | Result |
|---|---:|---:|---|
| Headed Godot 4.6.3 capture | pass | pass | equivalent production hook |
| Resolution | 1920x1080 | 1920x1080 | invariant |
| Camera pitch | -55.0 | -55.0 | invariant |
| Default zoom | 40.0 | 40.0 | invariant |
| Capture frame | 1 | 1 | pass |
| Manifest failures | 0 | 0 | pass |
| Intended exit code | 0 | 0 | pass |
| Astra instance count | 14 | 14 | invariant |
| Full public input route | not run | not run | unobserved, not inferred |

The runtime hook directly started the production GameWorld and rendered the player HUD, then paused and captured. Its automated PASS establishes capture integrity and boot smoke only; it does not substitute for human visual approval or a full public-input playtest.
