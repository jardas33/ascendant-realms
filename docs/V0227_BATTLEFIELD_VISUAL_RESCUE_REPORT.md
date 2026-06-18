# v0.227 Battlefield Visual Rescue Report

Date: 2026-06-17

## Decision

`INSUFFICIENT_V0227_BATTLEFIELD_VISUAL_RESCUE`

The pass is materially clearer than v0.226 in a narrow readability sense, but it does not meet the requested artistic success bar.

## What improved

- Removed the broad stacked translucent composition treatment in the isolated v0.227 path.
- Made the river unmistakably cooler and darker than the ground.
- Added solid bank lips, stronger bridge abutments, approach contact and under-span depth.
- Strengthened road continuity and added restrained roof, entry, stone-course and foundation separation to existing structures.
- Preserved the compact reboot HUD, default launcher and all gameplay boundaries.

## Why it is still insufficient

- The replacement road and river geometry reads as blunt rectangular strips rather than authored terrain.
- The battlefield retains too much olive monotony and weak natural value variation.
- Structure improvements are modest and mixed-fidelity; several structures still feel placeholder-grade.
- The screenshot is easier to parse, but not convincingly closer to a finished fantasy RTS battlefield.

## Evidence

- Review pack: `artifacts/manual-review/v0227-battlefield-visual-rescue/`
- Before/after: `10_before_after_contact_sheet.png`
- New source images: none.
- Selected benchmark: 56.08 FPS average, 15.18 ms p95.
- v0.224 comparator: 61.01 FPS average, 17.86 ms p95.

## Single recommended next milestone

If another milestone is authorized, use v0.228 for an authored terrain-topology pass that replaces the rectangular road, river and bank strips with shaped mesh/ribbon geometry before any further HUD or structure-detail polish.
