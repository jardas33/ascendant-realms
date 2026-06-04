# v0.122 Emmanuel Review Guide

Status: one-click adapter/parity review guide for the v0.122 Godot spike.

Use this only after the repository is clean/synced and Godot 4.6.3 standard x86_64 plus export templates are available locally.

## One-Click Validation

Run:

```bat
GODOT_RUN_ALL_WINDOWS.bat
```

or:

```bash
npm run godot:all
```

Fresh-checkout validation:

```bat
GODOT_FRESH_CHECKOUT_VALIDATE_WINDOWS.bat
```

or:

```bash
npm run godot:fresh-checkout:validate
```

## Review Artifacts

Open the ignored local folder:

```text
artifacts/desktop-spikes/godot-salto/v0122/
```

Primary files:

- `content-subset.json`
- `stable-id-report.json`
- `adapter-validation.json`
- `parity-report.json`
- `migration-readiness.json`
- `README.md`

## What To Check

- The content subset is small and generated from repository data.
- The adapters reject unknown, duplicate, and missing IDs.
- `linked_ward` remains exactly `0.92`.
- Save fixtures remain read-only.
- The 2D and 2.5D modes use the same fixture.
- The report does not claim full simulation parity.
- The workflow remains editor-optional for routine work.

Do not treat this as final art, a full content migration, a full port, or a final Godot decision.
