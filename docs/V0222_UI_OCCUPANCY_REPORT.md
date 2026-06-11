# v0.222 UI Occupancy Report

Date: 2026-06-11

## Measurement Summary

Source:

```text
artifacts/desktop-spikes/godot-salto/v0222/v0222-minimal-contextual-hud-capture-report.json
```

Measured occupancy:

```text
Default fixed HUD area ratio: 0.0805
Expanded worst-case contextual area ratio: 0.2227
v0.214 comparator estimated area ratio: 0.36
```

## Supported Resolution Matrix

| Resolution | Scale | Default Area | Expanded Area | Result |
| --- | ---: | ---: | ---: | --- |
| 1920x1080 | 1.200 | 0.0805 | 0.2227 | PASS |
| 1600x900 | 1.000 | 0.0805 | 0.2227 | PASS |
| 1366x768 | 0.853 | 0.0805 | 0.2226 | PASS |

## Default-State Gate

```text
Battlefield dominant: PASS
Default exposes more battlefield than v0.214 comparator: PASS
Default right alert hidden: PASS
Default tooltip hidden: PASS
Default event log collapsed: PASS
Default production grid collapsed: PASS
```

## Drawer Safety Gate

```text
No drawer overlaps minimap: PASS
No drawer overlaps battlefield center: PASS
No drawer overlaps critical action context: PASS
Objective detail is on demand: PASS
Tooltip is docked to drawer/context edge: PASS
```

## Boundary Gate

```text
Generated images: 0
Downloaded assets: 0
New art slots: 0
Browser runtime changes: 0
Default launcher changes: 0
Gameplay/pathing/collision/objective/AI/economy/save/stable-ID/balance changes: 0
```
