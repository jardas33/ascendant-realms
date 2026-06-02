# v0.104 Emmanuel Retest Checklist

## Public Minimal HUD

- Launch a normal public battle.
- Confirm `Minimal` density is active by default.
- Confirm private HUD-density controls are absent.
- Confirm resources, hero HP/Mana, selected controls, minimap, objectives, status, and menu remain usable.

## Private Density Review

- Open the private Playtest Hub.
- Launch `HUD Minimal density`, `HUD Standard density`, and `HUD Debug density` from the Performance Lab.
- Confirm Minimal is quieter, Standard keeps full detail review copy, and Debug shows counters only in private tooling.
- Toggle between Minimal, Standard, and Debug and confirm no save/localStorage behavior is introduced.

## Scenario Checks

- Worker Minimal: Worker build/repair/resource-site commands remain usable.
- Building Minimal: Command Hall production/research controls remain usable.
- Urgent alert Minimal: critical status remains visible.
- Lume Auto Minimal: Lume objective/progress remains readable.
- Lume Hidden Minimal: battlefield overlay remains quiet.
- Lume Always Standard: inspection overlay remains private and readable.
- Tutorial Minimal: tutorial overlay remains visible.

## Performance Evidence

- Review `artifacts/performance/v0104/performance-delta.md`.
- Compare only local scenario shape and rates; do not treat it as hardware-independent benchmark proof.

## Package

- Use `V0104_PERFORMANCE_DELTA_REPORT.md`, `V0104_VISUAL_QA_REPORT.md`, and this checklist before sending the private package.
