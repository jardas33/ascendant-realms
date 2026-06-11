# v0.209 UI Shell Opt-In Report

## Status

The original Salto fantasy RTS UI shell is wired into the packaged Godot Salto review slice behind `GODOT_LAUNCH_SALTO_UI_SHELL_EXPERIMENT_WINDOWS.bat`.

## Scope

- Opt-in launcher only.
- Godot packaged review path only.
- Default procedural launcher unchanged.
- Browser runtime untouched.
- No generated images, downloaded assets, imported UI textures, production art slot, gameplay mutation, save mutation, or stable-ID mutation.

## Live State Wiring

- Top resources read current Crowns, Stone, Iron, and Aether from the live runtime status.
- Objective and event log summarize the active micro-loop state.
- Selection panel changes between Aster, Worker, Barracks restoration/restored, defenders, and Ashen pressure.
- Production panel switches Build/Train posture based on Barracks and Militia state.
- Alert card reports Ashen pressure and remaining hostile count.
- Minimap mirrors current objective, friendly, hostile, road, river, bridge, and camera markers.
- Help, Pause, Move, Attack, Work/Train, and Lume controls call existing Godot scene methods.

## Review Pack

Generated with:

```powershell
npm run godot:capture:salto-ui-shell-opt-in
```

Manual review artifacts are ignored and written to `artifacts/manual-review/v0209-ui-shell-opt-in/`.

Required PNGs present:

- `01_initial.png`
- `02_aster.png`
- `03_worker_assignment.png`
- `04_barracks_restoring.png`
- `05_barracks_restored.png`
- `06_train.png`
- `07_defenders.png`
- `08_ashen_pressure.png`
- `09_replay.png`
- `10_fallback.png`
- `11_contact_sheet.png`

The Ashen pressure frame proves the live shell reports an active wave with four hostiles remaining instead of using the older forced-defeat capture state.
