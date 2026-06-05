# v0.130 Salto Vertical-Slice Acceptance Gate

Classification: `SALTO_VERTICAL_SLICE_REVIEW_READY`

This gate is for human review of the current Godot Salto slice only. It does not select Godot finally, start a full port, import art, generate images, change browser runtime, change saves, or change stable IDs.

## Evidence Inputs

- Default launch: `GODOT_LAUNCH_SALTO_VERTICAL_SLICE_WINDOWS.bat`
- Validation: `GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat`
- Capture: `GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat`
- Artifact root: `artifacts/desktop-spikes/godot-salto/v0130/`
- Private harness: `GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat`, preserved separately

## Acceptance Matrix

| Area | Gate result | Notes |
| --- | --- | --- |
| Title | Ready | Player-facing Salto entry screen remains the default human-review start. |
| Briefing | Ready | Short objective setup leads into the battle without engineering harness copy. |
| Camera | Ready | Current 2.5D fixed-camera framing remains script-driven and reviewable. |
| Environment | Ready | Procedural Salto terrain is sufficient for direction review, not final art. |
| Silhouettes | Ready | Aster, Worker, friendly units, Ashen units, sites, and structures remain readable placeholders. |
| HUD | Ready | Compact HUD supports resources, selected role, commands, and objectives. |
| Minimap | Ready | Authored minimap markers support orientation in the slice. |
| Onboarding | Ready | Micro-onboarding leads the review path without broad tutorial expansion. |
| Hero | Ready | Aster selection, movement posture, and one ability beat are visible. |
| Worker | Ready | Worker selection and mine assignment are present in the bounded loop. |
| Mine/resource posture | Ready | Mine conversion and boosted production evidence are included. |
| Barracks build | Ready | Barracks placement and construction completion are included. |
| Militia recruit | Ready | Queue and spawn evidence are included. |
| Pressure wave | Ready | One bounded Ashen pressure wave is defeated. |
| Lume | Ready | Lume restore remains visible and linked to the slice objective. |
| Results | Ready | The flow reaches the Results screen. |
| Performance | Ready | The player-facing Tier M smoke report is captured in `performance-smoke.json`. |
| Package | Ready | Windows package evidence is mirrored in `package-report.json`. |
| Zero-editor workflow | Ready | Validation, capture, export, package, and reports are script-driven. |
| Fresh-checkout reproducibility | Ready | The existing `npm run godot:fresh-checkout:validate` gate remains required. |
| Private harness separation | Ready | The private harness stays behind a separate launcher and explicit proof capture. |

## Decision Boundary

Ready means Emmanuel can review the slice as a first player-facing foundation and decide whether the next explicit milestone should continue Godot, art direction review, gameplay feel, or technical confidence. Ready does not mean production art, final UI, final engine selection, runtime-art integration, save migration, or full desktop port approval.
