# v0.120 Godot Fresh Checkout Spec

v0.120 proves that the existing Godot Salto workflow spike can be rebuilt from repository files and scripts in a temporary checkout without relying on tracked editor state or ignored generated artifacts.

## Scope

This checkpoint is tooling, automation, validation, CI-style proof, and documentation only.

It does not add gameplay depth, import art, choose Godot finally, replace the browser runtime, create Unity/Unreal/Electron work, or start v0.121.

## Fresh Checkout Flow

`npm run godot:fresh-checkout:validate` runs `tools/godot/validateGodotFreshCheckout.ps1`.

The script:

- creates a temp folder under the OS temp directory with an `ascendant-realms-godot-fresh-` prefix;
- copies current repository source files from `git ls-files --cached --modified --others --exclude-standard`;
- omits ignored artifacts, `.tools/godot/`, `.godot/`, generated builds, generated reports, and ignored artifact roots;
- locates Godot through `GODOT_BIN` or ignored repo-local `.tools/godot/Godot_v4.6.3-stable_win64.exe`;
- verifies Godot reports `4.6.3`;
- runs `npm ci --no-audit --no-fund` inside the temp checkout;
- regenerates and validates the desktop-spike fixture;
- generates the Godot Salto scene from repository scripts;
- runs static Godot validation, headless tests, representative benchmarks, Windows export, and package assembly through waiting CLI wrappers;
- validates the package SHA-256 against the generated ZIP;
- writes a v0.120 report under ignored `artifacts/desktop-spikes/godot-salto/v0120/`;
- deletes the temporary checkout after a safe temp-path check.

## Required Pass Conditions

- Temporary checkout generated.
- Ignored caches and generated artifacts absent before the run.
- Fixture recreated from repository files.
- Stable-ID and read-only save posture validation pass.
- Headless Godot tests pass.
- Both 2D and 2.5D placeholder modes benchmark Tier M.
- Windows export passes.
- Package report has a hash and the hash matches the ZIP.
- Temp cleanup is safe and complete.
- Routine Godot editor use remains unnecessary.

## Boundary

The v0.120 report may reference v0.119 runtime artifacts because the runtime workload is unchanged. The v0.120 proof is the fresh-checkout wrapper and zero-editor reproducibility gate around that workload.
