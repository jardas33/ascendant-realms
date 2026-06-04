# v0.118 Emmanuel Headless And Headed Review Guide

This guide is for v0.118 only.

## Quick Commands

```powershell
npm run godot:all
npm run godot:headed:smoke
npm run godot:capture:review
```

For a manual headed look, double-click:

```text
GODOT_LAUNCH_REVIEW_WINDOWS.bat
```

## What To Review

- The packaged build opens as a Windows executable.
- The home screen appears without opening the Godot editor.
- The compact review overlay can switch between 2D and 2.5D.
- Hero, Worker, squad selection, site capture, Lume focus, and Results transition are visually distinguishable.
- The contact sheet exists under `artifacts/desktop-spikes/godot-salto/v0118/contact-sheet.svg`.

## What Not To Do

- Do not assemble scenes manually in the Godot editor.
- Do not drag assets into the editor.
- Do not import artwork.
- Do not start v0.119 from this guide.
- Do not treat this as a final Godot decision.

This checkpoint is meant to prove Codex can create, validate, launch, benchmark, capture, and package the representative Salto slice with minimal human interaction.
