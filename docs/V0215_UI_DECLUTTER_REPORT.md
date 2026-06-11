# v0.215 UI Declutter Report

Status: PASS

v0.215 reduces the immediate visual overload in the isolated Godot Salto presentation-reboot path while preserving all prior launchers and the v0.214 full-HUD comparator.

## Declutter Changes

- Added a slim top strip with compact resources and phase state.
- Converted the objective surface to a one-line summary with compact progress cues.
- Replaced the always-heavy event log posture with a small toast stack.
- Hid the production drawer by default and expanded it only for relevant build, train, research or disabled-production contexts.
- Docked tooltips near the lower edge/context panel instead of the center battlefield.
- Kept hostile pressure visible through a compact alert without occupying large permanent HUD space.
- Simplified selected-context presentation at the bottom edge.
- Kept the minimap compact.
- Reduced reboot-path selection and target marker radius and opacity.

## Occupancy Measurements

The generated occupancy report is:

`artifacts/manual-review/v0215-presentation-reboot-declutter/07_ui_occupancy_measurements.md`

Summary:

| Surface | Measurement | Budget | Result |
| --- | ---: | ---: | --- |
| Top strip | 38 px, 0.042 height ratio | <= 0.050 height | PASS |
| Minimap | 220 x 164 px | <= 16% width, <= 20% height | PASS |
| Selected context | 594 x 106 px | <= 38% width, <= 18% height | PASS |
| Production drawer | 430 x 174 px | <= 28% width, <= 20% height | PASS |

Objective summary, collapsed event posture and docked tooltip posture all passed the v0.215 budget gate.

## Visual QA Notes

The first reboot capture showed an overlap risk between the production drawer and tooltip zone. The implementation was tightened so the production drawer stays collapsed unless explicitly relevant and the tooltip docks higher when production is expanded.

The final review pack shows:

- initial overview with battlefield dominance preserved;
- contextual production expansion without permanent bottom-right clutter;
- hostile alert state with the combat read still visible;
- docked tooltip state without central battlefield coverage.

## Boundary Confirmation

- Default launcher remains procedural.
- v0.214/full-HUD comparator remains available.
- Browser runtime remains untouched.
- Runtime-art slot manifests remain unchanged.
- No generated or downloaded art was introduced.

## Decision

PASS. The reboot path is visually cleaner than v0.214 and is acceptable as the baseline for the next queued production-presentation steps.
