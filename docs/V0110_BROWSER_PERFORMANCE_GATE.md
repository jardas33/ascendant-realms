# v0.110 Browser Performance Gate

Status: RED.

Baseline case: v0110_tier_m_density.
FPS average: 2.5.
p95 frame: 550 ms.
Max frame: 550 ms.
Long tasks: 55.

## Gate Rule

- GREEN: Tier M FPS average at least 30, p95 at or below 50 ms, and no more than one long task.
- AMBER: Tier M FPS average at least 18, p95 at or below 120 ms, and max frame at or below 500 ms.
- RED: Anything below AMBER remains a performance rescue blocker for future work.

## Reason

Tier M representative battle remains below the trusted browser gate; defer broad rescue/engine work to a separately approved goal.
