# v0.9 Controlled Visual Sprint Brief

Date: 2026-05-10  
Status: v0.8.2 planning brief. No art is generated, imported, downloaded, replaced, or committed by this document.

## Purpose

v0.8 established visual debt and art-direction foundations. v0.8.1 added the visual asset manifest, validation, screenshot QA harness, and Cinderfen visual backlog. v0.8.2 reviewed source/license risk and expanded screenshot coverage. The next visual step should be controlled, evidence-backed, original-IP safe, and small.

This brief compares exactly four possible v0.9 directions. None of them authorizes new maps, units, factions, gameplay systems, rewards, save changes, desktop packaging, engine switching, generated assets, external art, or full graphics overhaul.

## Option A - Cinderfen Style-Frame Sprint

Summary: create or prepare 1-3 source/license-safe style-frame prompts/specs for Cinderfen terrain, Cinder Shrine/capture-site identity, and Ashen outpost architecture. No runtime asset replacement yet.

| Category | Assessment |
| --- | --- |
| Player value | High future value. It gives the roughest current battlefield a coherent visual target before risky runtime work starts. |
| Risk | Low if kept to prompts/specs/docs. Main risk is drifting into image generation or committing assets too early. |
| Files likely touched | `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`, `docs/ASSET_PROMPT_TEMPLATES.md`, `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`, `docs/VISUAL_RISK_REGISTER.md`, `LLM_GAME_HANDOFF.md`. |
| Tests needed | Docs-only gate: `npm test`, `npm run build`, `npm run validate:content`, `git diff --check`. If any optional prompt tooling changes: add focused unit/content validation as needed. |
| Screenshot QA targets | Existing Cinderfen Crossing launch, Cinderfen Crossing shrine, Cinderfen Crossing pressure, Cinderfen Watch launch, Cinderfen Watch pressure, tablet battle HUD. |
| Asset needs | No committed assets. Optional future human/manual output would need source/license metadata, manifest entries, and before/after screenshot QA before runtime use. |
| Why now | Source/license risk and screenshot evidence both point to Cinderfen terrain/capture-site identity as the safest next visual planning target. |
| Why not now | It does not immediately improve the live prototype visuals; it depends on later human/art execution. |
| Smallest safe first implementation | Add a Cinderfen style-frame packet with 3 prompt/spec sheets: terrain material, Cinder Shrine/capture site, and Ashen watch/outpost architecture. Mark all output as future/manual review, not runtime-ready. |

## Option B - Prototype Terrain Readability Pass

Summary: make small renderer/CSS/overlay/material-zone tweaks to improve current terrain readability without new art.

| Category | Assessment |
| --- | --- |
| Player value | Medium immediate value if a very specific readability bug is proven. Could make roads, water, or capture sites slightly clearer. |
| Risk | Medium-high. Procedural terrain tweaks can create screenshot churn, accidental one-off art direction, and false confidence without solving the real asset problem. |
| Files likely touched | `src/game/battle/BattleSceneMapRenderer.ts`, map data under `src/game/data/maps/`, CSS if HUD/overlay contrast changes, screenshot QA docs. |
| Tests needed | `npm test`, `npm run build`, `npm run validate:content`, `npm run test:e2e:smoke`, `npm run test:e2e:layout`, `npm run visual:qa`, `git diff --check`. |
| Screenshot QA targets | Before/after Cinderfen Crossing launch, shrine, pressure, Watch launch, Watch pressure, tablet/mobile battle. |
| Asset needs | No new art if limited to procedural color/opacity/shape changes. |
| Why now | Terrain material ambiguity is one of the top visual risks. |
| Why not now | v0.8.2 evidence says the problem is structural art direction debt, not one obvious safe constant. A renderer tweak could churn without a final visual language. |
| Smallest safe first implementation | Only after a specific screenshot/human finding: adjust one road/water/capture overlay parameter, document before/after, and run layout plus visual QA. |

## Option C - Unit/Building Scale Normalization Pass

Summary: adjust scale constants, selection rings, label offsets, and health-bar offsets to normalize tactical scale.

| Category | Assessment |
| --- | --- |
| Player value | Medium if scale mismatch directly hurts readability. Could improve hero/infantry/building relationships. |
| Risk | High. Scale changes affect selection feel, combat readability, screenshots, minimap expectations, and possibly hidden assumptions in tests. |
| Files likely touched | `src/game/entities/BaseEntity.ts`, `src/game/entities/Unit.ts`, `src/game/entities/Building.ts`, `src/game/entities/CaptureSite.ts`, unit/building data, visual manifest scale metadata, layout/e2e docs. |
| Tests needed | `npm test`, `npm run build`, `npm run validate:content`, `npm run test:e2e:smoke`, `npm run test:e2e:layout`, `npm run visual:qa`, possibly targeted battle e2e. |
| Screenshot QA targets | Tutorial desktop/mobile, Cinderfen Crossing launch/tablet, shrine, Watch launch, pressure views, Results if unit panels change. |
| Asset needs | No new art for constants-only work, but meaningful scale normalization is limited by inconsistent source sprites. |
| Why now | v0.8 identified scale mismatch as a real future risk. |
| Why not now | Current screenshots show tactical readability remains acceptable. Source sprite inconsistency means constants alone cannot create production coherence. |
| Smallest safe first implementation | Add or refine scale metadata/reporting first; defer runtime scale changes until a tested readability issue appears. |

## Option D - UI/HUD Visual Consistency Pass

Summary: improve panels, resources, objectives, minimap, status, inventory, Results, and Asset Gallery styling without full redesign.

| Category | Assessment |
| --- | --- |
| Player value | Medium-high. UI/HUD is what players constantly touch, and mobile density is a real screenshot watchpoint. |
| Risk | Medium-high. It can easily become a broad redesign and distract from asset/source safety. |
| Files likely touched | `src/game/styles/*.css`, HUD/render helpers, `ResultsScene`, `HeroProgressionScene`, `AssetGalleryScene`, layout docs, screenshot review docs. |
| Tests needed | `npm test`, `npm run build`, `npm run validate:content`, `npm run test:e2e:smoke`, `npm run test:e2e:layout`, `npm run visual:qa`, `git diff --check`. |
| Screenshot QA targets | Main menu, campaign map, route-complete campaign, tutorial mobile, tablet battle HUD, Results victory/defeat, Inventory, Asset Gallery, Skirmish Setup. |
| Asset needs | No new art if CSS-only, but final polish likely needs reviewed UI frame/icon assets. |
| Why now | v0.8.2 screenshots show Results, Inventory, Gallery, and mobile battle density clearly. |
| Why not now | UI changes without art-direction decisions can churn the interface while the battlefield still carries larger visual debt. |
| Smallest safe first implementation | Do a docs-first mobile/HUD density review and only apply one CSS/readability fix if screenshot evidence shows an actual overlap or unreachable control. |

## Recommendation

Recommended v0.9 direction: Option A - Cinderfen Style-Frame Sprint.

Rationale:

- It directly addresses the highest current visual debt without touching runtime gameplay or assets.
- It is source/license safe because it can remain prompts/specs/docs only.
- It keeps original-IP guardrails explicit before any future manual or generated art work.
- It prepares better decisions for Options B, C, and D by defining what Cinderfen should look like before tweaking the renderer, unit scale, or UI skin.

Options B and D should wait for human screenshot review and a specific, reproducible readability issue. Option C should wait until scale mismatch becomes a tested gameplay-readability problem or until replacement sprite sheets/models exist.

## First Safe v0.9 Implementation

Create a Cinderfen style-frame packet:

1. Terrain material sheet: ash-glass wetland, blackened causeway, wet reflective pools, dead reeds, cinder fog.
2. Capture-site landmark sheet: Cinder Shrine and Watch Road toll identity that remains readable without relying only on rings/icons.
3. Ashen outpost architecture sheet: original stronghold/watch structures and faction silhouette language.

Each sheet should include:

- original-IP requirement,
- no copying protected games or references,
- intended screenshot QA targets,
- manifest metadata required if an asset is later produced,
- source/license evidence required before runtime use,
- explicit statement that no generated image or runtime replacement is part of the first step.
