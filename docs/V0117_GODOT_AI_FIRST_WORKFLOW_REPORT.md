# v0.117 Godot AI-First Workflow Report

## Result

Godot passed the first AI-first workflow spike as a workflow candidate, not as a final engine selection.

Scorecard AI-operability result:

```text
24 / 25
```

## Evidence

- Project setup is reproducible from repository files and scripts.
- Scene creation is text-editable through `.tscn` scenes and `.gd` scripts.
- Fixture import is manifest-driven and deterministic.
- Stable-ID validation rejects unknown IDs.
- Save fixture validation is read-only.
- Routine Godot editor use is not required.
- Builds, tests, benchmarks, export, package, and scorecard generation are scriptable.
- A fresh checkout has one-command validation through `GODOT_RUN_ALL_WINDOWS.bat` or `npm run godot:all`.
- Asset registration does not require Emmanuel to drag files into the editor.

## Codex Routine Workflow

Codex can:

- generate and validate fixture JSON;
- create and update scenes from text files;
- run headless Godot tests;
- run placeholder benchmarks;
- export a Windows build when templates are present;
- package the Windows build into an ignored ZIP;
- regenerate the scorecard and manual-review checklist.

## Emmanuel Routine Workflow

Emmanuel should not need to operate the Godot editor manually during routine work.

Expected Emmanuel actions are limited to:

- run one-click scripts;
- approve a one-time official Godot setup if missing;
- launch the packaged build;
- record short playtests;
- approve visual direction;
- answer creative questions.

## Manual Editor Steps

Unavoidable manual editor steps found in v0.117:

```text
None.
```

The spike does not prove that every future final-art import can avoid the editor, but routine placeholder scene generation, validation, export, and packaging were scriptable.
