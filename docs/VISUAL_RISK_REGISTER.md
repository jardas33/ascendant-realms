# Visual Risk Register

Date: 2026-05-10  
Status: v0.8.2 living risk register for visual source/license, screenshot QA, and future art-sprint planning.

## Purpose

This register tracks visual risks that could undermine Ascendant Realms as it moves from a systems-first browser prototype toward future controlled visual work. It does not authorize new art, runtime asset replacement, graphics overhaul, desktop packaging, engine switching, or gameplay expansion.

Risk owners are process owners, not named people. Future work should update this register whenever assets, visual metadata, screenshot QA, UI layout, or art-direction docs change.

## Risk Summary

| ID | Risk | Severity | Likelihood | Owner / Process | Mitigation | Test / Validation / Doc Guard | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| VR-01 | Unknown source/license runtime assets | Critical | High | Asset manifest + source/license review | Keep unknown assets `needsReview: true`, `allowedInProduction: false`, and never promote them without evidence. | `validate:content` visual asset rules; `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`; `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md` | Get user/source confirmation or replace through a documented original pipeline before production use. |
| VR-02 | Placeholder assets mistaken for final | High | High | Asset manifest + release checklist | Keep `currentStatus` conservative; avoid treating `public/assets/final/` as legal or production proof. | Manifest `currentStatus`, `reviewStatus`, `sourceReviewNotes`; `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md` | Keep all current file-backed image art prototype/reference until source and art review prove otherwise. |
| VR-03 | Style mismatch between units, buildings, and terrain | High | High | Art direction review | Use `docs/ART_DIRECTION_2026_BIBLE.md` and future style frames before replacing runtime visuals. | `docs/V08_VISUAL_DEBT_AUDIT.md`; `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`; screenshot QA before/after | Start with a Cinderfen style-frame sprint before any runtime replacement. |
| VR-04 | Scale mismatch | High | Medium | Scale/readability review | Use intended/current render-height metadata and future scale sheets before swapping sprites. | `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`; manifest scale fields; layout/e2e battle checks | Do not adjust entity scale constants without screenshot QA and gameplay readability verification. |
| VR-05 | Capture-site ring/icon dependence | High | High | Cinderfen visual backlog + art direction | Treat rings/icons as prototype readability aids; future sites need landmark silhouettes and terrain dressing. | `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`; `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`; pressure/shrine screenshots | Make Cinder Shrine/capture-site concepts part of the first visual style-frame work. |
| VR-06 | Text-heavy HUD identity | Medium | High | Game UI/frontend review | Preserve semantic clarity now; defer final UI reduction until visual direction and player evidence exist. | `npm run test:e2e:layout`; `npm run visual:qa`; `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md` | Review HUD hierarchy after future art style frame, not before. |
| VR-07 | Mobile battle HUD density | High | High | Responsive QA + screenshot QA | Keep mobile screenshots in visual QA; do not assume desktop readability proves mobile readability. | `tutorial-mobile.png`; `cinderfen-crossing-tablet.png`; layout tests; `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md` | Add mobile battle HUD to every future visual/UI review checklist. |
| VR-08 | Minimap readability | Medium | Medium | Battle UI + layout review | Keep minimap semantic checks and screenshots; avoid over-styling markers before terrain art changes. | Existing e2e minimap assertions; `npm run visual:qa`; `docs/V081_SCREENSHOT_QA_REVIEW.md` | Re-review minimap contrast after any terrain or UI palette change. |
| VR-09 | Cinderfen terrain material ambiguity | High | High | Cinderfen visual direction | Treat current procedural roads/water/swamp as placeholder material language, not final art. | `docs/V08_VISUAL_DEBT_AUDIT.md`; `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`; screenshot QA Cinderfen views | Prioritize Cinderfen terrain/road/water style frames before runtime terrain replacement. |
| VR-10 | Over-reliance on generated art later | High | Medium | Asset pipeline + legal review | Generated art must have prompts, tool/source, license status, edits, and review notes before use. | `docs/ASSET_PIPELINE_PLAN.md`; `docs/ASSET_PROMPT_TEMPLATES.md`; manifest `sourceReviewNotes` | Treat generated output as review-needed and prototype-only until explicitly approved. |
| VR-11 | IP contamination from references | Critical | Medium | Art direction + source/license review | Require original IP language in prompts/specs; forbid copying protected names, factions, units, maps, UI, art, music, or lore. | `docs/ART_DIRECTION_2026_BIBLE.md`; `docs/ASSET_PROMPT_TEMPLATES.md`; source/license review docs | Keep future prompts/specs explicit about original work and non-copying. |
| VR-12 | Large binary asset bloat | Medium | Medium | Asset pipeline + performance review | Avoid committing large assets without approval; track size, source, use, and replacement plan. | `docs/ASSET_PIPELINE_PLAN.md`; bundle/performance audits; git review before commits | Add size guidance before any real art import sprint. |
| VR-13 | Future desktop/engine migration asset mismatch | Medium | Medium | Long-term roadmap + asset pipeline | Keep browser prototype assets clearly tagged; do not assume 2D prototype art will carry into desktop-quality production. | `docs/DESKTOP_2026_VISUAL_DIRECTION.md`; `docs/FULL_GAME_ROADMAP.md`; `docs/ASSET_PIPELINE_PLAN.md` | Separate prototype-safe assets from future desktop source files in future pipeline plans. |
| VR-14 | Screenshot QA becoming ignored or stale | High | Medium | Release checklist + screenshot QA process | Keep `npm run visual:qa` optional but documented; review `visual-qa/latest/index.md` as source of truth; update coverage when screens change. | `docs/V081_SCREENSHOT_QA_PLAN.md`; `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`; `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md` | Re-run visual QA before and after any future visual asset or HUD/layout change. |

## Severity Guide

- Critical: could create legal/IP exposure, production-safety false confidence, or major future rework.
- High: likely to harm player readability, art direction, or future sprint safety if ignored.
- Medium: meaningful but manageable with normal validation and review discipline.
- Low: not currently tracked here unless it becomes a recurring issue.

## Process Rules

- Unknown-source assets are acceptable in the current private prototype only because they are explicitly review-needed and not production-approved.
- Current screenshot QA is evidence capture, not pixel-perfect regression testing.
- Future visual changes should update the manifest, docs, and screenshot QA together.
- Future art prompts/specs must be original-IP safe and must not copy protected games, factions, units, maps, UI, lore, art, music, or other expression.
- No future runtime asset replacement should ship without before/after screenshot review and `npm run validate:content`.

## Current Highest-Risk Cluster

The highest-risk cluster is VR-01, VR-02, VR-03, VR-05, VR-09, and VR-11:

- current images lack source/license proof,
- placeholders could be mistaken for production art,
- Cinderfen's terrain and capture sites lack a final visual language,
- future references/prompts could accidentally drift toward protected IP if not guarded.

The safest next visual step is therefore a controlled Cinderfen style-frame sprint with prompts/specs and source/license discipline, not direct runtime replacement.
