# v0.170 Player Slice Five-Slot Boundary

Status: `PASS_V0170_ASHEN_OPT_IN_BOUNDARY`

## Authorized Change

Add only the selected v0.157 restrained Ashen Raider derivative as the fifth opt-in player-slice slot behind the new five-slot launcher.

## Preserved Boundaries

- Default stabilized launcher remains procedural.
- Default player-slice launcher remains procedural.
- Prior launchers preserved: Worker-only, Worker + Barracks, Worker + Barracks + Militia, Worker + Barracks + Militia + Aster.
- Browser runtime remains untouched.
- Save and stable IDs remain untouched.
- Selected local art, derivatives, metadata, tracked fallbacks, required evidence, and unknown files are preserved.
- No sixth slot.
- No generated images.
- No art enabled by default.

## Boundary Gate

The `tools/godot/saltoFiveSlotArtOptInTool.mjs boundary` command checks prior launcher hashes, forbidden browser/runtime/save path changes, zero image changes, and the new fifth-slot wrapper shape.

Final status: `PASS_V0170_ASHEN_OPT_IN_BOUNDARY`.

The default stabilized launcher and default player-slice launcher remain procedural. Worker-only, Worker + Barracks, Worker + Barracks + Militia, and Worker + Barracks + Militia + Aster launchers are preserved unchanged.
