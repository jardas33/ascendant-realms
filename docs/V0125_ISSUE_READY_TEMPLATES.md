# v0.12.5 Issue-Ready Templates

Date: 2026-05-18

Use these templates to turn triaged feedback into future GitHub issues or Codex tasks. Keep guardrails visible so the next task does not broaden accidentally.

## 1. Bug Issue Template

```text
Title:
[Bug] <node/screen> <short failure>

Source sessions:
- PT-...

Evidence:
- Build/commit:
- Browser:
- Node/screen:
- Steps to reproduce:
  1.
  2.
  3.
- Screenshot/video:
- Console errors:

Expected behavior:

Actual behavior:

Severity/priority:
S_ / P_

Proposed action:
Reproduce and fix the smallest cause.

Guardrails:
Do not change gameplay numbers, save format, maps, factions, units, art/assets, hosted release stability patterns, or unrelated tests.

Verification needed:
- focused repro
- npm test
- npm run build
- relevant smoke/e2e if UI/runtime behavior changed
- git diff --check
```

## 2. Clarity Polish Task

```text
Title:
[Clarity] <objective/result/warning> confused testers in <node>

Source sessions:
- PT-...

Evidence:
- Quote/summary:
- Affected route/node:
- Current text/surface:
- What testers expected:

Expected behavior:
Tester understands what to do before the mistake matters.

Actual behavior:

Proposed action:
Copy/readability-only change, smallest relevant surface.

Guardrails:
No numeric tuning, new mechanics, art replacement, save migration, or test weakening.

Verification needed:
- npm test
- npm run build
- npm run validate:content if content text/data changes
- relevant focused smoke/layout/visual QA if UI surface changes
- git diff --check
```

## 3. Tiny Balance Tuning Proposal

```text
Title:
[Tiny Tuning Proposal] <route/node/watchpoint>

Source sessions:
- PT-...

Evidence:
- Repetition count:
- Routes:
- Nodes:
- Army/resources/objectives:
- Pressure-warning state:
- Why clarity/control/art are not root causes:

Expected behavior:

Actual behavior:

Proposed action:
Smallest possible numeric change.

Old value:

New value:

Risk:

Guardrails:
No broad rebalance, new mechanics, new maps/factions/units, reward redesign, save migration, art replacement, or hosted CI plumbing.

Verification needed:
- npm test
- npm run build
- npm run validate:content
- npm run playtest:sim and compare telemetry
- relevant smoke/release/hosted lanes if gameplay/HUD/campaign behavior changes
- git diff --check
```

## 4. Pressure Warning Polish Task

```text
Title:
[Pressure] <Crossing/Watch> warning noticeability issue

Source sessions:
- PT-...

Evidence:
- Did testers see warning?
- Were they in combat?
- Did they know what to do?
- Did they have time to react?
- Result after warning:

Expected behavior:
Warning is noticeable and actionable during normal combat.

Actual behavior:

Proposed action:
Copy/readability/UI salience only unless repeated timing evidence is clear.

Guardrails:
Do not expand pressure mechanics, live reinforcements, route contest behavior, enemy construction, or broad AI systems.

Verification needed:
- npm test
- npm run build
- relevant pressure smoke/e2e/visual QA if UI/runtime changes
- npm run playtest:sim if timing/data changes
- git diff --check
```

## 5. Visual Overhaul Backlog Item

```text
Title:
[Visual Backlog] <landmark/UI/map readability issue>

Source sessions:
- PT-...

Evidence:
- Screenshot/link:
- Node/screen:
- Did it block gameplay understanding?
- Decision affected:

Expected behavior:

Actual behavior:

Proposed action:
Defer to future visual/UI overhaul or style-frame review.

Guardrails:
Do not generate/import/replace runtime art in this task. Require source/license review and before/after screenshot plan in a future visual goal.

Verification needed:
- future visual-overhaul acceptance criteria
- visual QA before/after when implementation is explicitly opened
```

## 6. Future Systems Feature Request

```text
Title:
[Future Systems] <requested feature>

Source sessions:
- PT-...

Evidence:
- What tester wanted:
- Why:
- Did it block current slice?

Expected behavior:

Actual behavior:

Proposed action:
Backlog for future systems planning.

Guardrails:
Do not implement under balance/playtest intake. No new maps, factions, units, save migration, procedural generation, multiplayer, workers, enemy construction, or reward redesign unless a future goal explicitly scopes it.

Verification needed:
- future design brief before implementation
```

## 7. More Testing Needed Item

```text
Title:
[More Testing] <watchpoint/question>

Source sessions:
- PT-...

Current evidence:

Missing evidence:
- route/profile
- node
- army state
- resources
- pressure state
- result
- screenshot/video
- repeat count

Recommended next test:

Guardrails:
Evidence collection only. Do not tune, add content, replace art, or change systems.

Verification needed:
- completed packet forms
- watchpoint aggregation update
```
