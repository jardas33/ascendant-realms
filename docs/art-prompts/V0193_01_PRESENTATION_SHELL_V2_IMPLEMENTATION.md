Execute this bounded goal exactly as written.

# v0.193 - Isolated Salto presentation-shell v2 prototype implementation and human-review stop

## Run condition

Run only after v0.192 passed and left `main` clean/synced.

Expected prior message:

`Checkpoint v0.192 human-review override presentation-shell v2 architecture audit and implementation contract stop`

## Safety rule

Before editing:

- confirm the required preceding checkpoint exists as current `HEAD`;
- confirm `HEAD == origin/main` and `HEAD...@{u} = 0 0`;
- run `git status --short --untracked-files=all`;
- if the tree is dirty only because of already-classified Godot-generated transient sidecars or cache residue, run the existing safe-only cleanup wrapper and re-check;
- stop immediately if any unknown file remains, any tracked file is unexpectedly modified, any selected local asset or metadata file is missing, or any required PASS gate is absent;
- preserve selected local art, active derivatives, required metadata, tracked fallbacks, latest required evidence, and unknown files;
- never relax a gate, broaden scope, enable art in the default launcher, wire browser runtime, mutate gameplay/pathing/collision/objectives/AI/saves/stable IDs, or begin the following milestone automatically.

## Purpose

Implement the bounded shell-v2 prototype selected in v0.192 as one isolated opt-in Godot review path.

This is the last queued milestone. Stop for Emmanuel review after completion.

Use:

- zero images;
- zero new imported art slots;
- existing five character slots;
- existing foothold-ground and road materials;
- no wet-granite integration yet;
- no gameplay/pathing/collision/objective/AI/save/ID changes;
- default launcher untouched;
- browser untouched.

Do NOT begin v0.194.

## New launcher

Add:

`GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`

with matching validate and capture wrappers.

The launcher must:

- preserve every existing launcher;
- enable existing five character slots;
- enable selected foothold-ground and road materials;
- use shell-v2 visual-only compositor;
- read gameplay state without mutating truth;
- show:
  `Experimental opt-in: Salto presentation shell v2`;
- report node counts, material hashes, and fallback posture;
- fail safely to the prior opt-in shell if shell-v2 initialization fails.

## Shell-v2 prototype scope

Create a small number of coherent visual-only surfaces:

- scoped foothold terrain;
- route-following roads;
- continuous river channel;
- shaped visual banks;
- readable bridge deck and abutments using procedural colors/materials only;
- structure masses for Command Hall, mine, Barracks, and site shells;
- explicit z-order;
- restrained contact grounding;
- restrained overcast palette;
- minimal overlay;
- no giant translucent diagnostic pads.

Gameplay/collision/pathing nodes remain untouched.

Prefer clean geometry over stacked transparency layers.

## Required Windows-side review

Use Computer Use where available.

Capture comparison:

- legacy shell overview;
- shell-v2 overview;
- Aster initial frame;
- Worker assignment area;
- Barracks restoration;
- Militia recruitment;
- Ashen combat posture if safely reachable;
- road close view;
- river and banks;
- bridge;
- structures;
- pan;
- zoom;
- minimap;
- contact sheet.

## Functional smoke

Run bounded smoke:

- title;
- briefing;
- battle;
- Aster selection and movement;
- mine conversion;
- Worker assignment;
- Barracks restoration;
- Militia recruitment;
- squad selection;
- Results/restart/replay where safely reachable.

Prove gameplay state, traversal, collision/pathing truth, and objectives are unchanged.

## Benchmark

Compare:

- L1 legacy opt-in shell;
- V2 shell-v2 opt-in.

Require for this prototype:

- V2 FPS ratio vs L1 `>= 0.85`;
- V2 p95 worsening vs L1 `<= 20%`;
- no per-frame decode/parse;
- no repeated material creation;
- no package leakage.

## Cleanup

Run retention validator, sidecar scan, cleanup dry-run, and safe-only cleanup for positively classified transient residue only.

## Gate

Pass only if:

- shell v2 visibly improves coherence;
- large floating rectangles absent or materially reduced;
- roads follow routes;
- river reads continuously;
- bridge reads as crossing;
- structure masses improve;
- characters sit more naturally inside world;
- smoke green;
- old shell preserved;
- default/browser/gameplay/pathing/collision/save/ID boundaries intact;
- zero images;
- zero new slots;
- v0.194 not started.

If gate fails:

- report honestly;
- stop;
- recommend one bounded shell-v2 repair only.

If pass:

- stop for Emmanuel visual review.

## Docs budget

Create only:

- `docs/V0193_SHELL_V2_PROTOTYPE_QA_BENCHMARK.md`
- `docs/V0193_SHELL_V2_BOUNDARY_ROLLBACK.md`
- `docs/V0193_IMPLEMENTATION_REPORT.md`

Update handoff/index/roadmap/changelog/checkpoint/checklist.

Commit exactly:

`Checkpoint v0.193 isolated Salto presentation-shell v2 prototype implementation and human-review stop`

Push safely and stop.

Return implementation summary, legacy-vs-v2 captures, smoke, benchmark, cleanup, boundaries, commit, CI, and confirmation v0.194 not started.
