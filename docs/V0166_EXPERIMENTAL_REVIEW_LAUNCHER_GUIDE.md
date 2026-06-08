# v0.166 Experimental Review Launcher Guide

Status: `PASS_V0166_REVIEW_LAUNCHER_GUIDE`

Use:

```text
GODOT_REVIEW_SALTO_THREE_SLOT_ART_WINDOWS.bat
```

The launcher delegates to the existing Worker + Barracks + Militia opt-in path and adds only review clarity:

- explicitly starts `desktop-spikes/godot-salto/builds/AscendantRealmsGodotSalto-v0166.exe`;
- prints the selected Worker, Barracks, and Militia identifiers and SHA-256 hashes;
- passes `--experimental-review-mode-label=Experimental opt-in art: Worker + Barracks + Militia`;
- passes `--salto-three-slot-review-framing`;
- leaves `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` unchanged and procedural;
- leaves Worker-only, Worker + Barracks, and Worker + Barracks + Militia launchers unchanged.

The on-screen label is intentionally experimental-only. It does not appear in the default player-facing launcher.

Computer Use live review confirmed the repaired launcher shows the label on the title, briefing, and battle screens.
