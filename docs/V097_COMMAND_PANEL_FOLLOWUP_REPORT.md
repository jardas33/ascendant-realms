# v0.97 Command Panel Follow-Up Report

Status: implemented.

## Goal

Preserve the compact v0.86 command panel while making follow-up explanations more deliberate and less developer-manual-like by default.

## Changes

- Command disclosure labels now use `More Details`.
- Player command trays continue to show primary verb, target name, cost/state, hotkey where available, and concise lock reason first.
- Longer command descriptions and effects remain behind the disclosure.
- Enemy inspection no longer exposes player behavior controls.
- Group summaries filter to selected player units, preventing inspected enemy units from polluting command groups.

## Guardrails

- No command availability changed.
- No costs changed.
- No production/research/training rules changed.
- No HUD redesign.
- No saved command-panel preference added.

## Verification Targets

- Building production/research disabled states still show short reasons.
- Worker build/repair/site-assignment commands still expose clear reasons and valid actions.
- Hero ability buttons still show cooldown/mana states.
- Patrol/behavior controls still render for selected player combat units only.
- More Details opens without hiding primary action access.

## Tests

- CommandPanel unit coverage expects `More Details`.
- SelectedEntityPanel coverage verifies enemy inspection hides player behavior controls.
- Hosted v0.97 coverage verifies compact selection focus plus command disclosure.
