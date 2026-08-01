# Ascendant Realms Master Player-Experience Backlog

Status: durable planning record created for v0.436-R1A. These issues are not fixed by this checkpoint unless a cited runtime proof says otherwise.

## P0 — Functional blockers

| ID | Title | Status | Player impact | Known evidence/source | Suspected causes | Dependencies | Acceptance criteria | Future grouping | Fixed now |
|---|---|---|---|---|---|---|---|---|---|
| P0-NAV-001 | Navigation/pathfinding reliability | Focused v0.436-R1/R1A/R1B/R1F proof accepted; R1G and R1H natural-match observations reached truthful assault-force-eliminated blockers; no new navigation repair authorized | Workers and armies can fail long commands | v0.436-R1 source repair; v0.436-R1A/R1B proof pack; v0.436-R1F physics-frame truth pack; v0.436-R1H natural assault pack | Navigation map lifecycle, projection, retries, target churn; timer-vs-physics sampling contract repaired | Natural conquest capture remains separate | Long worker, military, pursuit, invalid-target, and isolated boundary cases complete with bounded telemetry; continue monitoring in natural conquest | v0.436-R1F / follow-up | Physics-frame acceptance restored; R1G/R1H recorded truthful assault-force-eliminated blockers |
| P0-RESULT-001 | Natural conquest/result/replay proof | Open; R1G and R1H truthful captures stopped before natural conquest, with R1H status `BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED` | Players need trustworthy match completion and replay flow | v0.436-R1G/R1H conquest captures remain separate | Requires accepted navigation behavior first | v0.436-R1A acceptance | Real gameplay-scale victory, result freeze, Continue, and Play Again evidence | v0.437 candidate | No |
| P0-GAME-001 | Other game-breaking defects found during real play | Watch; R1H retained a reproducible assault-force-eliminated observation without authorizing a repair | Can block ordinary play | R1H natural assault pack and report | To be determined from real runs; no balance or gameplay repair authorized here | Broad audit | Reproducible issue record and bounded repair | Future audit | No |

## P1 — Core playability and comprehension

| ID | Title | Status | Player impact | Known evidence/source | Suspected causes | Dependencies | Acceptance criteria | Future grouping | Fixed now |
|---|---|---|---|---|---|---|---|---|---|
| P1-UNIT-001 | Unit role and faction silhouettes are difficult at gameplay zoom | Open | Worker, hero, spear, archer, defender, race, and team are hard to distinguish | Historical/current gameplay-scale captures; reopen audit required | Scale, silhouette, equipment, faction colour, contrast, camera | Navigation and evidence baseline | Roles read at ordinary zoom without selection-only dependence | Unit readability checkpoint | No |
| P1-PORTRAIT-001 | Selected portraits can be black or empty | Open | Selection feedback loses identity | Historical/current gameplay-scale captures; reopen audit required | Asset loading, crop, fallback | Capture audit | Every selected role has a non-empty, readable portrait | Portrait/UI checkpoint | No |
| P1-HUD-001 | Global HUD text, icons, resource images, and thin lines need readability review | Open | State and economy information are hard to parse | Existing v0.292-v0.303 UI evidence | Scale, contrast, safe margins, layering | Resolution matrix | Readable at supported resolutions and scaling modes | HUD/readability checkpoint | No |
| P1-MINIMAP-001 | Minimap does not communicate terrain, visibility, or fog state clearly | Open | Spatial orientation is weak | Existing player/runtime captures; reopen audit required | Current minimap rendering and state mapping | Gameplay-scale audit | Terrain, units, visibility, and fog semantics are readable | Minimap checkpoint | No |
| P1-COMMAND-001 | Current command and role feedback are insufficient | Open | Players cannot confidently tell what a unit is doing | Navigation behavioral evidence and future gameplay audit | Sparse state feedback and presentation debt | Unit/UI audit | Movement, build, gather, return, attack, and terminal states are explicit | Command feedback checkpoint | No |

## P2 — Interaction presentation

| ID | Title | Status | Player impact | Known evidence/source | Suspected causes | Dependencies | Acceptance criteria | Future grouping | Fixed now |
|---|---|---|---|---|---|---|---|---|---|
| P2-BUILD-001 | Worker construction panel is plain and unfinished | Open | Construction intent and cost are weakly communicated | Existing runtime/UI captures | Missing command-card hierarchy | HUD baseline | Costs, requirements, progress, disabled state, and queue are readable | Command-panel checkpoint | No |
| P2-PROD-001 | Building production panels need a coherent command-card system | Open | Training choices and queues are difficult to parse | Existing runtime/UI captures | Inconsistent card structure | UI audit | Costs, icons, requirements, queue, progress, and tooltips are consistent | Command-panel checkpoint | No |
| P2-UPGRADE-001 | Upgrade, research, and ability panels need the same command-card language | Open | Strategic options are unclear | Existing runtime/UI captures | Fragmented presentation | UI audit | Shared card contract across systems | Command-panel checkpoint | No |

## P3 — Menu terminology and language quality

| ID | Title | Status | Player impact | Known evidence/source | Suspected causes | Dependencies | Acceptance criteria | Future grouping | Fixed now |
|---|---|---|---|---|---|---|---|---|---|
| P3-MENU-001 | Difficulty selector needs an explicit player-facing label | Open | Players may not understand the setting | Menu audit required | Ambiguous terminology | Menu capture audit | Label and explanation are explicit | Menu wording checkpoint | No |
| P3-MENU-002 | “Quick” starting resources is ambiguous | Open | Resource setup intent is unclear | Menu audit required | Short label lacks explanation | Menu capture audit | Rename or explain the option in player-facing language | Menu wording checkpoint | No |
| P3-LANGUAGE-001 | Review wording across menu, match, hero, settings, pause, result, and commands | Open | Inconsistent capitalization, spacing, and hierarchy reduce trust | Historical/current screenshots; reopen audit required | Incremental wording changes | Full UI audit | Terminology and layout review is captured and accepted | Menu/HUD checkpoint | No |

## P4 — Broader presentation quality

| ID | Title | Status | Player impact | Known evidence/source | Suspected causes | Dependencies | Acceptance criteria | Future grouping | Fixed now |
|---|---|---|---|---|---|---|---|---|---|
| P4-ART-001 | Terrain and environment quality | Open | World lacks final production cohesion | v0.304-v0.430 art archaeology and current runtime captures | Asset and integration gaps | Stable gameplay baseline | Coherent authored terrain, structures, props, and lighting | Art-direction sequence | No |
| P4-UNIT-001 | Unit animation and effects | Open | Motion and feedback lack production clarity | Future gameplay-scale audit | Asset/animation burden | Role animations and effects read at gameplay zoom | Unit art checkpoint | No |
| P4-BUILD-001 | Building identity | Open | Buildings can be visually generic | Historical/current captures | Repeated placeholder or inherited families | Art kit and placement audit | Buildings communicate faction, role, and use | Building identity checkpoint | No |
| P4-AUDIO-001 | Audio feedback | Open | Actions lack confirmation and consequence | Future playtest audit | Incomplete event coverage | Audio review | Core commands and results have readable feedback | Audio checkpoint | No |
| P4-FACTION-001 | Faction differentiation | Open | Teams and races are not consistently distinct | Historical/current captures | Shared art/value language | Art bible and UI audit | Faction identity survives gameplay zoom and UI | Faction presentation checkpoint | No |
| P4-QUALITY-001 | Overall modern visual quality | Open | Prototype presentation is below intended target | v0.304-v0.430 visual review history | Structural art gap | Art-direction decision | Human review accepts a coherent production slice | Art-direction sequence | No |

## Evidence-audit requirement

Future audits must reopen historical and current gameplay-scale images covering menus and setup, ordinary gameplay zoom, selection and portraits, economy, construction, production, combat, minimap, resolution and scaling, pause/settings, and Victory/Defeat/replay. A title card, beauty shot, stale frame, or source string does not resolve a player-experience issue.

## Checkpoint boundary

This backlog records confirmed categories and does not authorize v0.437 or any unrelated gameplay, visual, HUD, wording, or art redesign work. Each issue remains explicitly open until a future bounded checkpoint provides reproducible evidence and acceptance criteria are met.
