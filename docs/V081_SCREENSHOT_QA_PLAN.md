# v0.8.1 Screenshot QA Plan

Date: 2026-05-10  
Status: planning only. No screenshot capture harness or visual regression test is implemented in this phase.

## Purpose

This plan defines how Ascendant Realms should capture visual evidence for review without turning screenshots into brittle pixel-perfect tests. The project now has a visual asset manifest and runtime usage cross-check, but it still needs repeatable visual review points for menus, campaign flow, tutorial, Cinderfen battle views, pressure feedback, results, and responsive layouts.

The screenshot QA workflow is meant to support human visual review and future art direction. It should not block ordinary development because a few pixels differ between browsers or machines.

## Non-Goals

- No new art assets.
- No generated art.
- No map, unit, faction, reward, save, campaign, enemy pressure, or gameplay changes.
- No desktop packaging, engine switching, 3D rewrite, or renderer overhaul.
- No full UI redesign.
- No pixel-perfect screenshot comparisons.
- No large screenshot artifacts committed to git.

## Screenshot Review Targets

The initial capture harness should target the smallest useful review set:

1. Main menu.
2. Tutorial / Proving Grounds after launch.
3. Campaign map after starting or loading a campaign.
4. Cinderfen Crossing launch if the existing helpers can seed it safely.
5. Cinderfen Crossing shrine/capture-site view if the existing helpers can reach it without brittle play.
6. Cinderfen Watch launch if the existing helpers can seed it safely.
7. Cinderfen Watch pressure-warning view if the existing pressure helpers can trigger it cheaply.
8. Results screen if an existing helper can reach victory/defeat without a long full-flow run.
9. Skirmish Setup.
10. Mobile or tablet variants for main menu, campaign map, tutorial, and one battle view if practical.

If a target requires long, fragile, or gameplay-heavy setup, the harness should skip that target and record the gap in the generated index/report.

## Proposed Capture Command

Use one optional package script:

```bash
npm run visual:qa
```

The script should run a focused Playwright capture spec or tool. It should be outside normal `npm test`, `npm run test:e2e:smoke`, and release lanes unless a later goal explicitly promotes it.

## Output Folder

Recommended ignored output folder:

```text
visual-qa/
```

Suggested structure:

```text
visual-qa/
  latest/
    index.md
    main-menu-desktop.png
    tutorial-desktop.png
    campaign-map-desktop.png
    cinderfen-crossing-desktop.png
    cinderfen-watch-desktop.png
    skirmish-setup-desktop.png
```

The harness may overwrite `visual-qa/latest/` on each run. Screenshots should stay ignored by git. If a future release needs tiny representative images committed, that decision should be documented separately and kept intentionally small.

## Gitignore Policy

Add these ignored paths when the capture harness is implemented:

```text
visual-qa/
```

Do not ignore source files, test files, docs, or the visual asset manifest. The ignored folder is for generated visual review artifacts only.

## Naming Convention

Use stable, readable names:

```text
<view-id>-<viewport>.png
```

Examples:

- `main-menu-desktop.png`
- `tutorial-desktop.png`
- `campaign-map-tablet.png`
- `cinderfen-crossing-desktop.png`
- `cinderfen-watch-pressure-desktop.png`
- `skirmish-setup-mobile.png`

Avoid timestamps in screenshot filenames inside `latest/`. The index can include capture time if needed.

## Viewport Sizes

Initial viewports:

- Desktop: `1440x900`
- Tablet: `1024x768`
- Mobile: `390x844`

Minimum v0.8.1 harness target:

- Desktop for all available core views.
- Tablet or mobile for a small subset if the existing layout helpers can do it without slow runtime.

## Browser Settings

Use the existing Playwright browser/project setup where possible. The harness should:

- Reuse the existing Vite dev-server setup from Playwright config.
- Capture with animations allowed unless they make output impossible to review.
- Wait for stable app markers instead of fixed sleeps where possible.
- Collect console errors and include them in the index.
- Fail only on app-launch failures, missing expected view markers, or browser console errors that existing e2e rules would consider real errors.

## Safe Automated Checks

Automated checks may verify:

- The app loads.
- The expected screen or battle launches.
- A known heading/HUD/objective marker is visible.
- A screenshot file was written.
- Browser console errors are zero, using the same practical standard as existing e2e tests.
- The screenshot dimensions match the requested viewport.

Automated checks should not assert:

- Exact pixel colors.
- Exact sprite positions.
- Exact terrain brush shapes.
- Exact animation frame.
- Exact fog or status text timing unless that behavior already has a non-visual e2e assertion.

## Manual Review Checklist

For each screenshot, review:

- Is the primary screen purpose immediately readable?
- Are the main buttons or commands visible?
- Is the playfield protected from UI overlap?
- Are unit and building labels readable without overpowering the scene?
- Are health bars and selection rings readable?
- Are roads, water/swamp, fog, and blocked terrain understandable?
- Are capture sites, especially Cinder Shrine, visually salient?
- Is the minimap readable?
- Is the current scene obviously prototype-quality, candidate-quality, or blocked by visual debt?
- Do any assets look legally/source-unclear and need manifest review?

## Asset Manifest Linkage

Screenshot review should cross-reference:

- `src/game/assets/visualAssetManifest.ts`
- `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`
- `docs/V081_RUNTIME_ASSET_USAGE_CROSSCHECK.md`
- `docs/V08_VISUAL_DEBT_AUDIT.md`
- `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`
- `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`

When a screenshot reveals a visual problem, record whether the likely cause is:

- A manifest-tracked file asset.
- A procedural rendering issue.
- A scale/readability metadata problem.
- A UI/CSS layout problem.
- A future art-pipeline problem.

## Review Outcomes

Each screenshot QA review should classify findings as:

- `acceptable-for-prototype`: rough but not blocking current gameplay review.
- `needs-manifest-review`: source/license/status/scale metadata needs attention.
- `needs-readability-fix`: small UI or scale issue may be worth a prototype-safe patch.
- `needs-art-pipeline`: cannot be fixed honestly without new art direction or assets.
- `blocked`: screenshot target could not be captured reliably.

## First Harness Scope

The first implementation should capture:

- Main menu desktop.
- Tutorial desktop.
- Campaign map desktop.
- Skirmish Setup desktop.
- Cinderfen Crossing desktop if existing helpers can seed it.
- Cinderfen Watch desktop if existing helpers can seed it.

Optional if cheap:

- One tablet menu screenshot.
- One mobile menu screenshot.
- One pressure-warning screenshot.

The harness should prefer fewer reliable captures over a large flaky visual set.

## Future Promotion Criteria

Screenshot QA can become more formal only after:

- The asset manifest covers all runtime visual assets.
- Source/license metadata is trustworthy.
- Stable screenshot seeding exists for campaign, battle, tutorial, and skirmish views.
- The team decides which screenshots are release-critical.
- A non-pixel, semantic visual review policy exists for art changes.

Until then, screenshot QA remains an optional evidence capture workflow.

## v0.8.1 Decision

This phase only plans the screenshot workflow. The next phase may implement an optional capture harness, but it should stay outside normal test and release gates unless manually run.
