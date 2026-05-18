# v0.13 Watchpoint Classifier Rules

Date: 2026-05-18

Purpose: document how the automated scenario lab converts deterministic telemetry into conservative watchpoint actions.

Classifier implementation:

- `src/game/playtest/ScenarioLabClassifier.ts`

## Allowed Actions

- `no change`
- `monitor`
- `needs human testing`
- `copy/readability candidate`
- `tiny tuning candidate`
- `future systems pass`
- `future visual/UI pass`

## Core Rules

- Do not classify a watchpoint as `tiny tuning candidate` from one weak signal.
- Human testing is a valid output, not a failure of the tool.
- Automated pressure-warning telemetry cannot prove human noticeability.
- Copy/readability should be considered before numbers when the issue could be understanding.
- No runtime gameplay changes should follow from this classifier without a dedicated decision step.

## Watchpoint Rules

Retinue + Training Yard II:

- If Ashen/Cinderfen watchpoint nodes are clean but the full suite is not a whole-route sweep, classify as `needs human testing`.
- Only consider `tiny tuning candidate` if repeated automated and human evidence show trivialization across Ashen and both Cinderfen nodes with low losses and little objective engagement.

Greedy Economy:

- If first waves are survived but timeouts remain high with large resource surplus, classify as `monitor`.
- Do not buff Greedy Economy just because greed is risky.
- Treat high surplus plus timeout as conversion, pacing, or clarity evidence before numeric economy changes.

Fast Army:

- If Cinderfen wins are high but failures remain elsewhere, classify as `monitor`.
- Do not slow Fast Army just because it is fast.
- Only escalate if it invalidates slower profiles across multiple nodes and profile rows.

Early defeats:

- If early-node records show no defeats, classify as `no change`.
- First-wave not-survived markers can be benign when speed routes win before absorbing a wave.

Pressure fairness:

- If Safe Beginner wins pressure nodes and warnings are shown, classify as structurally actionable but `needs human testing`.
- Human noticeability and reaction stress remain unknown.

Cinderfen Crossing / Cinderfen Watch:

- If Safe Beginner wins all current rows, classify as `no change` for structural fairness.
- Keep route feel and pressure noticeability in human testing.

Ashen Outpost:

- If Safe Beginner wins but route timeouts remain, classify as `monitor`.
- Treat as pacing/final-assault watchpoint before tuning.

## Confidence

- High confidence: broad run count and stable repeated signal.
- Medium confidence: repeated automated signal, but human feel still matters.
- Low confidence: narrow profile/proxy signal.
- Inconclusive: insufficient or contradictory automated evidence.
