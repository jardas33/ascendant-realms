# v0.91 Desktop Engine Decision Criteria

Status: decision criteria only. This document does not select an engine, start a port, create a wrapper, add dependencies, or change runtime behavior.

## Purpose

The future product target is an installable desktop RTS/RPG. The current browser prototype remains the correct development and testing environment until explicit benchmark gates prove a desktop path. This document compares decision criteria without locking a winner.

## Options To Evaluate Later

| Option | Role in decision process | Boundary |
| --- | --- | --- |
| Remain Phaser/browser for prototype | Continue fast gameplay, content, QA, and systems iteration. | Current default. Not the final desktop answer by itself. |
| Later desktop packaging experiment | Test whether a packaged prototype helps distribution or local QA. | Experiment only. It must not become the final product posture unless it meets desktop-quality gates. |
| Godot evaluation | Evaluate 2D/2.5D workflow, UI, tools, export, and scripting fit. | No commitment without pathing, scale, and pipeline benchmarks. |
| Unity evaluation | Evaluate asset pipeline, UI tooling, RTS pathing packages/options, build tooling, and C# ecosystem. | No commitment without performance, licensing, and AI-assisted workflow review. |
| Unreal evaluation | Evaluate 3D/2.5D ambition, VFX, animation, performance tooling, and packaging. | No commitment without scope discipline, UI/tooling risk review, and team learning assessment. |
| Other justified option | Only if a specific risk or opportunity is not covered above. | Requires a written reason and comparable benchmark evidence. |

## Criteria Matrix

| Criterion | Phaser/browser prototype | Later packaging experiment | Godot evaluation | Unity evaluation | Unreal evaluation | Other option |
| --- | --- | --- | --- | --- | --- | --- |
| RTS pathing | Current grid pathing proves rules and edge cases, but not final scale. | Would expose packaged-browser limitations, not solve pathing. | Needs benchmark for crowds, dynamic obstacles, and command responsiveness. | Needs benchmark plus package/asset choice review. | Needs benchmark for RTS camera, selection, and pathing stack. | Must beat or clarify one of the named options. |
| Large-unit counts | Good for deterministic prototype tests, unknown for production counts. | Useful for stress-packaging evidence only. | Needs representative battle benchmark. | Needs representative battle benchmark. | Needs representative battle benchmark. | Must supply comparable benchmark. |
| 2D vs 2.5D vs 3D | Current is 2D/procedural with DOM UI. | Does not answer final art dimension. | Strong candidate for 2D/2.5D evaluation. | Flexible for 2D/2.5D/3D. | Stronger if final target leans 3D/2.5D. | Must explain visual target fit. |
| Asset pipeline | Existing manual intake and manifest are process assets. | Can carry prototype assets, not final pipeline. | Needs import, atlas, animation, and review workflow spike. | Needs import, animation, addressable/build workflow review. | Needs material/VFX/animation pipeline review. | Must integrate with v0.88 art gate. |
| Animation | Minimal current evidence. | Does not solve animation quality. | Needs Worker/troop movement and attack animation spike. | Needs humanoid and creature animation spike. | Needs animation-state complexity spike. | Must prove RTS-scale readability. |
| VFX | Current status/line/floating-text feedback only. | Does not prove final VFX. | Needs Lume/Ashen/fire/readability spike. | Needs VFX Graph or equivalent evaluation. | Needs Niagara/readability evaluation. | Must avoid noise and preserve tactical clarity. |
| UI | Browser DOM is productive and testable. | Packaging could preserve DOM UI but risks wrapped-browser feel. | Needs desktop HUD/campaign/results rebuild study. | Needs desktop HUD/campaign/results rebuild study. | Needs UMG/common UI study. | Must support dense RTS UI. |
| Modding/content | TS data is simple and versioned. | Could ship JSON/TS-derived content in prototype. | Needs import pipeline and schema strategy. | Needs data asset or external JSON strategy. | Needs data asset or external JSON strategy. | Must preserve stable IDs and validation. |
| Save migration | Current V2 normalization is good evidence. | Could keep browser localStorage only for prototype package. | Needs file/profile/export strategy. | Needs file/profile/export strategy. | Needs file/profile/export strategy. | Must support versioned migration and tests. |
| Testing | Vitest, Playwright, deterministic simulator are strong. | Browser packaged tests remain useful only if harnessable. | Needs engine automation proof. | Needs engine automation proof. | Needs engine automation proof. | Must support CI-friendly automation. |
| Online roadmap | Browser prototype does not answer netcode. | Packaging experiment does not answer netcode. | Needs future net architecture review. | Needs future net architecture review. | Needs future net architecture review. | Must not force premature multiplayer. |
| Build tooling | Vite is fast and simple. | Useful for private distribution. | Needs export/CI/package signing proof. | Needs build/CI/package signing proof. | Needs build/CI/package signing proof. | Must be reproducible. |
| Performance | Good enough for prototype, not final evidence. | Can test local packaged startup only. | Needs CPU/GPU/memory benchmark. | Needs CPU/GPU/memory benchmark. | Needs CPU/GPU/memory benchmark. | Must define target hardware. |
| Licensing | Current dependencies are limited. | Packaging tools need license review. | Needs engine/license review. | Needs engine/license review. | Needs engine/license review. | Must pass legal/commercial review. |
| Learning curve | Current stack is known and productive. | Low short-term learning, high long-term risk if misused. | Needs team comfort test. | Needs team comfort test. | Needs team comfort and scope-risk test. | Must not slow core proof. |
| AI-assisted development practicality | TypeScript is highly agent-friendly. | Same as browser for prototype tasks. | Needs code-generation workflow evaluation. | Needs C# workflow evaluation. | Needs Blueprint/C++ workflow evaluation. | Must be inspectable and testable. |
| Reuse of current TypeScript logic | Direct for browser prototype. | Direct if wrapper-like, but that does not prove desktop quality. | Likely through generated data and rewritten runtime logic. | Likely through data export and ported rules. | Likely through data export and ported rules. | Must define reuse path. |

## Minimum Benchmark Before Choosing

Before any final engine decision, run a representative benchmark with:

- 1 hero, 1 Worker, 2 player military unit types, enemy equivalents, buildings, resource sites, and one Lume link.
- 80 to 150 active units or a documented lower target if the final design chooses smaller tactical battles.
- Dynamic obstacles, group selection, attack commands, Patrol-like movement, and at least one commander/elite pressure case.
- Campaign shell, Results, settings, key rebinding, resolution options, and save/load proof.
- Startup, battle launch, average frame posture, memory, build size, and packaging evidence.
- A test harness that can run in CI without relying on manual screenshots only.

## Decision Rules

- Do not choose an engine based on screenshots or editor preference alone.
- Do not accept a desktop packaging experiment as the final answer unless it meets the same desktop-quality criteria as engine-native options.
- Do not trade away deterministic tests and content validation for faster visuals.
- Do not use multiplayer ambition as a reason to skip single-player benchmarks.
- Do not migrate stable IDs or saves until a save/content translation proof exists.

## Deferred

- Final engine selection.
- Engine-specific dependency installation.
- Desktop wrapper creation.
- Desktop build scripts.
- Full art import pipeline.
- Multiplayer architecture implementation.
