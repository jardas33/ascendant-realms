# v0.120 Godot CI-Style Workflow

v0.120 adds a CI-style Windows posture for the Godot Salto workflow spike without making Godot part of the normal browser fast-confidence lane.

## Script

`npm run godot:ci-style:windows` runs `tools/godot/runGodotCiStyleWindows.ps1`.

The script:

- uses a process-local isolated `APPDATA` value under ignored `.tools/godot/ci-appdata`;
- detects `GODOT_BIN` or `.tools/godot/Godot_v4.6.3-stable_win64.exe`;
- accepts `-DownloadOfficialInCi` only when `CI=true`;
- delegates official download/template installation to the existing bootstrap script;
- verifies Godot `4.6.3`;
- runs the fresh-checkout validator.

## Workflow

`.github/workflows/godot-fresh-checkout-windows.yml` is manual `workflow_dispatch` only.

It runs on `windows-latest`, sets up Node 22, optionally downloads the official standard Godot 4.6.3 Windows x86_64 binary and official export templates in CI, runs the CI-style script, and uploads the ignored v0.120 report artifact.

## Safety

- No administrator privileges.
- No system PATH changes.
- No third-party mirrors.
- No plugins.
- No artwork import.
- No manual editor scene assembly.
- No browser runtime replacement.
- No automatic push-triggered Godot download.

## Artifact Posture

Reports live under:

```text
artifacts/desktop-spikes/godot-salto/v0120/
```

The workflow uploads those reports with short retention when manually dispatched.
