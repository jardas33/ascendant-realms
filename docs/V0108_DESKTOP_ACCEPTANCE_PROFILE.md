# v0.108 Desktop Acceptance Profile

Status: provisional docs-only acceptance profile for future desktop benchmarking. It does not choose an engine, start a port, add desktop saves, or claim final hardware targets.

## Viewports

- 1920x1080
- 1600x900
- 1366x768

## Profiles

- Low: Tier S and ordinary battle smoke should launch, reset, and remain readable at 1366x768. No obvious input stall during private hub launch, representative focus action, or Results return.
- Standard: Tier M representative battle should be the primary desktop benchmark posture at 1600x900 and 1920x1080. Representative action and Results transition should stay visibly responsive under local deterministic QA.
- Stretch: Tier L stress is private/local only and should be used to find density regressions before future desktop engine decisions. Stress results are directional evidence only and are not CI release blockers without a future explicit gate.

## Required Evidence

- Tier M is the target representative unit-count tier.
- Report FPS average, 1% low estimate, frame-time percentiles, long tasks, input/action latency, Results transition latency, and readability at 1920x1080, 1600x900, and 1366x768.
- Keep stress private/local only until a future explicit gate promotes it.
- Do not use these browser numbers as final desktop hardware targets.
