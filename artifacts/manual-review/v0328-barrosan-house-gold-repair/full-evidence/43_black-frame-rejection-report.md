# v0.328 black-frame and rejected-capture report

The final evidence is accepted only from the non-headless OpenGL Godot run. Headless/dummy renderer output is not used. The performance benchmark is a separate 20-second post-warm-up run with screenshot dumping and video encoding disabled.

- `ordinary_rts.png` 1280x720 mean RGB 99.6: ACCEPTED
- `roof_front_audit.png` 1280x720 mean RGB 90.7: ACCEPTED
- `roof_rear_audit.png` 1280x720 mean RGB 108.5: ACCEPTED
- `roof_underside_audit.png` 1280x720 mean RGB 88.8: ACCEPTED
- `front_elevation.png` 1280x720 mean RGB 99.0: ACCEPTED
- `rear_elevation.png` 1280x720 mean RGB 114.1: ACCEPTED
- `left_elevation.png` 1280x720 mean RGB 112.5: ACCEPTED
- `right_elevation.png` 1280x720 mean RGB 103.1: ACCEPTED
- `material_closeup.png` 1280x720 mean RGB 96.5: ACCEPTED
- `daylight.png` 1280x720 mean RGB 101.2: ACCEPTED
- `silhouette_overcast.png` 1280x720 mean RGB 111.5: ACCEPTED
- `lod0_overview.png` 1280x720 mean RGB 99.6: ACCEPTED
- `lod1_overview.png` 1280x720 mean RGB 98.2: ACCEPTED
- `lod2_overview.png` 1280x720 mean RGB 97.0: ACCEPTED
- `collision_wireframe.png` 1280x720 mean RGB 99.1: ACCEPTED

Turntable: H.264 1280x720 at 24.00 fps, 288 frames, 12.00s, unique-frame ratio 1.00.
