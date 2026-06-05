# v0.129 Data Adapter Report

Status: generated-content and adapter posture preserved.

v0.129 continues to use the generated Godot content subset under `desktop-spikes/godot-salto/data/generated/` and the typed Godot adapters under `desktop-spikes/godot-salto/scripts/adapters/`. The microloop does not introduce a hand-maintained duplicate content database.

Protected posture:

- stable IDs remain unchanged;
- `linked_ward` remains exactly `0.92`;
- read-only save fixture posture remains unchanged;
- no browser localStorage mutation is introduced;
- no runtime art path or imported artwork is introduced;
- routine editor use is not required.

The generated artifact `data-adapter-report.json` checks adapter file presence, selected stable IDs for the loop, read-only save posture, no art import, no browser runtime change, and zero-editor posture.
