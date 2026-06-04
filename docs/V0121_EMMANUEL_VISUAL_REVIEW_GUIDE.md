# v0.121 Emmanuel Visual Review Guide

Status: one-click review guide for the verified v0.121 package.

Use this only after the repository is clean/synced and Godot 4.6.3 standard x86_64 plus export templates are available locally.

## One-Click Review

Run:

```bat
GODOT_CAPTURE_REVIEW_WINDOWS.bat
```

or:

```bash
npm run godot:capture:review
```

Then open:

`artifacts/desktop-spikes/godot-salto/v0121/contact-sheet.svg`

Verified local output:

- Visual captures: 32/32 required screenshots.
- Package: `artifacts/desktop-spikes/godot-salto/latest/AscendantRealmsGodotSalto-v0121-windows.zip`
- Package SHA-256: `2d6392a3a47c2fb9394ec252fdc38a2ec678e4bdb5e5b585bbc15556f7cfce6b`

Review default:

- Treat `CLEAN_READABILITY` as the normal 2.5D review default.
- Use `ATMOSPHERIC_BALANCED` for atmosphere-versus-readability judgment.
- Treat `VFX_STRESS_PRIVATE` as private stress evidence only.

Do not treat this as final art, imported art approval, a full port, or a final Godot decision.
