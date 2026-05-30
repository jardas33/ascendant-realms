# v0.79 Safe Next Milestone Sequence

Status: docs-only sequencing lock.

This sequence defines safe next steps after v0.79. It is not permission to begin any of these milestones inside v0.79.

## Next Separately Supplied Milestone - v0.80

```text
Salto, Lume, and Display-Copy Migration Plan
```

Purpose:

- inventory current runtime-facing placeholder display strings;
- map proposed future player-facing terminology;
- identify copy-only changes;
- identify strings that should remain untouched;
- define migration order;
- define tests;
- preserve stable internal IDs;
- preserve save compatibility;
- avoid broad runtime copy migration unless explicitly approved by a later goal.

Expected posture:

- planning first;
- no stable ID rename;
- no save migration unless separately specified and justified;
- no runtime rebrand;
- no art generation;
- no Lume Network implementation.

## Following Separately Supplied Milestone - v0.81

```text
Lume Site Network Prototype Specification and Smallest-Fun-Slice Gate
```

Purpose:

- produce a rigorous implementation-ready design for the smallest fun Lume Network prototype;
- build on existing sites without a giant rewrite;
- define player-facing value;
- define race-safe extensibility;
- define save posture;
- define UI posture;
- define test strategy;
- define explicit non-goals;
- avoid runtime implementation unless explicitly approved by a later goal.

Expected posture:

- design and feasibility first;
- smallest-fun-slice definition required;
- Tutorial protection required;
- replay/farming safety required;
- no broad economy rewrite;
- no new maps/factions/art by default.

## Later Separately Supplied Milestone - v0.82

```text
Controlled Visual Style-Frame and Silhouette Review Gate
```

Purpose:

- define prompt templates and review rules;
- generate or curate controlled concept candidates only if explicitly authorized;
- compare Barrosan, Ashen, and Wolfveil silhouettes;
- preserve tactical readability;
- prevent uncontrolled AI-art flooding;
- avoid moving assets into runtime without explicit approval.

Expected posture:

- source/license metadata first;
- candidate review before runtime;
- no runtime asset import unless separately approved;
- no final art lock without human review.

## Later Candidate - Retinue Identity Deepening

Retinue identity deepening remains a later safe candidate after the Lume Network gate or as a narrowly scoped parallel design milestone.

Possible future topics:

- Retinue biography readability;
- oath/role labels;
- recovery identity;
- small survivor story hooks;
- non-persistent or save-safe presentation rules.

No Retinue runtime work is approved by v0.79.

## Stop Rule

After v0.79:

- do not start v0.80 without a new explicit goal;
- do not start v0.81 without a new explicit goal;
- do not start v0.82 without a new explicit goal;
- do not implement Lume Network;
- do not generate art;
- do not begin runtime rebrand;
- do not begin desktop port;
- do not choose a desktop engine.

Wait for the next separately supplied milestone.
