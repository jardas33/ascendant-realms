# v0.92 Visual Review Pack Spec

Status: QA tooling and documentation milestone. This spec does not alter gameplay, runtime behavior, saves, stable IDs, balance, art assets, desktop implementation, or engine choice.

## Purpose

The v0.90 visual-QA harness captures 64 deterministic screenshots across important prototype states. v0.92 turns that raw screenshot folder into a static review pack Emmanuel can open quickly without inspecting image files one by one.

## Command

```text
npm run visual:review-pack
```

The command runs `tools/generateVisualReviewPack.ts`, which uses the existing TypeScript runtime through `tsx`. No dependency is added.

## Inputs

- `visual-qa/latest/index.md`
- `visual-qa/latest/*.png`
- `docs/V090_VISUAL_REGRESSION_MATRIX.json`

The generator does not capture new screenshots. Run `npm run visual:qa` first when fresh screenshots are needed.

## Output

```text
artifacts/visual-review/latest/
  index.html
  review-manifest.json
  README.md
  screenshots/*.png
  contact-sheets/*.html
```

The output folder is ignored by git. It can be regenerated at any time.

## Static Review Page

`index.html` must:

- group screenshots by screen family,
- group screenshots by viewport,
- show screenshot ID,
- show route/state,
- show intended visible controls,
- show intended absent controls,
- show review notes,
- show last-reviewed checkpoint,
- link directly to copied screenshots,
- link to contact sheets,
- remain static and local,
- require no server,
- require no external dependency.

## Required Screen Groups

- Main Menu
- Campaign Map
- Campaign Tabs
- Battle HUD
- Selected Units
- Selected Buildings
- Capture Sites
- Fog And Minimap
- Lume States
- Private Demo Results
- Normal Results
- Tutorial

## Determinism Rules

- The generator derives `generatedAtUtc` from the existing visual-QA index instead of the current clock.
- Source screenshots are copied, not modified.
- Manifest paths are relative and stable.
- Screenshot ordering follows the visual-QA index.
- Contact sheet ordering is deterministic.
- Duplicate screenshot IDs fail.
- Missing screenshots fail.
- Missing required screen groups fail.

## Safety Boundary

- No runtime files are modified by running the generator.
- No gameplay logic is touched.
- No save data is read or written.
- No stable IDs are renamed.
- No generated art or imported assets are created.
- Contact sheets are review pages over existing screenshots, not new game art.
