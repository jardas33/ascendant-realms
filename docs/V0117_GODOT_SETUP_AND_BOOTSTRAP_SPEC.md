# v0.117 Godot Setup And Bootstrap Spec

## Dependency Detection

The v0.117 scripts detect Godot in this order:

1. `GODOT_BIN`.
2. Repository-local ignored binary: `.tools/godot/Godot_v4.6.3-stable_win64.exe`.
3. `godot` on PATH.
4. `godot4` on PATH.

Windows export templates are detected under the Godot export-template directory for `4.6.3.stable`.

## Bootstrap Posture

`tools/godot/bootstrapGodotWindows.ps1` defaults to instruction-only mode. It does not download anything unless it is run with `-DownloadOfficial`.

The bootstrap script:

- uses official Godot release URLs only;
- installs the standard non-.NET Godot build;
- places the executable under ignored `.tools/godot/`;
- keeps archives and cache files under ignored `.tools/godot/cache/`;
- can install official export templates without administrator rights;
- does not modify system PATH;
- does not change Windows, browser, antivirus, firewall, or power settings.

## Local v0.117 Bootstrap Result

Supplemental authorization allowed the one-time local bootstrap for this spike. The local run used:

- Standard Godot editor: `https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_win64.exe.zip`
- Standard export templates: `https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz`

Detected Godot version:

```text
4.6.3.stable.official.7d41c59c4
```

Detected local binary:

```text
.tools/godot/Godot_v4.6.3-stable_win64.exe
```

Detected export-template posture:

```text
Windows release template: present.
Windows debug template: present.
Status: READY.
```

## One-Click Commands

From a fresh checkout:

```bat
GODOT_DOCTOR_WINDOWS.bat
GODOT_BOOTSTRAP_WINDOWS.bat
GODOT_VALIDATE_WINDOWS.bat
GODOT_GENERATE_SALTO_WINDOWS.bat
GODOT_TEST_WINDOWS.bat
GODOT_BENCHMARK_WINDOWS.bat
GODOT_EXPORT_WINDOWS.bat
GODOT_PACKAGE_WINDOWS.bat
GODOT_RUN_ALL_WINDOWS.bat
```

NPM equivalents:

```text
npm run godot:doctor
npm run godot:bootstrap:windows
npm run godot:fixture:export
npm run godot:fixture:validate
npm run godot:scene:generate
npm run godot:validate
npm run godot:test
npm run godot:benchmark
npm run godot:export:windows
npm run godot:package:windows
npm run godot:scorecard
npm run godot:all
```

If Godot is missing, `godot:doctor` reports `BLOCKED_PENDING_LOCAL_GODOT_SETUP` and the bootstrap script gives the exact next step.
