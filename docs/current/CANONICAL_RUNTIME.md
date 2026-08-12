# Canonical Ascendant Realms Runtime

Status: local C1 canonical baseline; proof passed locally, no release claim.

## Identity

- Production project: `production/ascendant-realms-godot`
- Project name: `Ascendant Realms`
- Main scene: `res://scenes/main.tscn`
- Engine: Godot 4.6.3 stable (`4.6.3.stable.official.7d41c59c4`)
- Certified executable: `D:/CodexData/tools/godot-4.6.3-stable/Godot_v4.6.3-stable_win64.exe`
- Certified SHA256: `EF90E929BA1A6A4322860285D97F40F4AA349C90329A91B0E8B55B8DF0F4CB00`

## Runtime classification

The current Golden Battle production target is the Godot project above. The repository-root `package.json`, `index.html`, `src/`, and `dist/` surface is retained as `LEGACY_BROWSER_PROTOTYPE`; it must not be used as production visual or gameplay proof. `desktop-spikes/godot-salto` is also not the canonical production project.

## Launch

From the repository root, use `npm run godot:play:production` or `PLAY_ASCENDANT_REALMS_GODOT.cmd`. Both resolve the certified 4.6.3 executable by default and accept `ASCENDANT_REALMS_GODOT` as an explicit override. The launcher must not silently fall back to Godot 4.3.

## Specialist sanity check

Before production edits, verify the expected baseline SHA, `AGENTS.md`, this document, `production/ascendant-realms-godot/project.godot`, `config/name="Ascendant Realms"`, and `run/main_scene="res://scenes/main.tscn"`. A browser/Vite/Phaser launch is `WRONG_RUNTIME_TARGET`.

## Safety

The dirty source snapshot and protected checkout are preserved outside this worktree. C1 consolidation is local-only: no push, PR mutation, merge, rebase, destructive Git operation, or protected-checkout mutation is allowed.

## C1 proof record

- Direct Godot 4.6.3 editor import/parse: exit 0.
- Direct Godot 4.6.3 headless production smoke: exit 0; only non-fatal ObjectDB/resource-leak shutdown diagnostics were emitted.
- Fresh headed viewport proof: `D:/CodexData/evidence/ascendant-realms-c1-headed/p1s1-capture-manifest.json`, pass at 1920x1080 and 1366x768.
- Representative inspected frame: `D:/CodexData/evidence/ascendant-realms-c1-headed/02_1920_LIVE_HUD_IDLE.png`.
- `npm test`: 136 files / 956 tests passed.
- `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, and `npm run godot:all`: passed; `godot:all` reports certified Godot 4.6.3 `READY` when `ASCENDANT_REALMS_GODOT` points to the certified D: executable.
- Retained artifact files copied into this ignored evidence surface were verified byte-for-byte against the protected approved checkout; the protected checkout was not modified.
