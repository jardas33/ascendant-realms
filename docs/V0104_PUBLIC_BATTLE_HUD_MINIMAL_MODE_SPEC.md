# v0.104 Public Battle HUD Minimal Mode Spec

## Scope

Public battle launches now default to `Minimal` HUD density. Minimal keeps the battle surface focused on resources, selected-entity essentials, usable commands, minimap/camera posture, objective/status visibility, critical alerts, and tutorial guidance. It does not add a save setting, localStorage setting, save migration, gameplay rule, reward path, stable ID, art asset, map, faction, or Lume mechanic.

Private review launches keep `Standard` density by default when private playtest tools are enabled, so existing long-copy QA and regression assertions can still inspect the full detail surfaces.

## Public Minimal Contract

- The public HUD renders `data-testid="battle-hud-density-minimal"`.
- Public launches do not render `hud-density-controls`.
- Optional detail copy is visually hidden with `.density-optional` under Minimal density, but core controls remain present and accessible.
- Hero essentials remain visible: name, level, HP, Mana, HP meter, portrait.
- Resources, status/hint, objective panel, selected side panel, command buttons, minimap, and pause/menu controls remain visible.
- Tutorial overlays remain visible and draggable/minimizable independently of HUD density.

## Rejected Work

- No persistent HUD-density preference.
- No save-version bump or save migration.
- No gameplay, balance, AI, pathing, map, faction, reward, Retinue, relic, reputation, or Lume multiplier changes.
- No production Debug density.

## Verification Targets

- Public non-private battle screenshot: `v0104-public-battle-minimal-1366.png`.
- Public desktop screenshots: `v0104-public-battle-minimal-1600.png`, `v0104-public-battle-minimal-1920.png`.
- Public posture check: `hud-density-controls` absent.
- E2E smoke/layout/deep lanes must continue to pass with forced HUD refresh calls intact.
