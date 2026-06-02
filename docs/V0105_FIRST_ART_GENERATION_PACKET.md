# v0.105 First Art Generation Packet

Status: first controlled review packet only. These candidates are reference-only and not runtime art.

v0.107 update: before generating any first Salto slice candidate, also run `npm run art:packet:salto-slice` and follow `docs/V0107_GENERATION_DEPENDENCY_ORDER.md`. The four v0.105 starter IDs remain useful first examples, but v0.107 is now the source of truth for the broader one-slice order, dimensions, fallback owners, QA scenarios, and Results/campaign/Lume coverage.

## Summary

Use this packet for the first tiny candidate batch after Emmanuel approves the prompt text. Do not generate a whole roster, full UI kit, final terrain set, runtime sprites, runtime buildings, icons, factions, maps, or replacement battle assets.

Initial asset IDs:

1. `v088_salto_environment_style_frame`
2. `v088_barrosan_worker_concept_sheet`
3. `v088_barrosan_militia_concept_sheet`
4. `v088_hud_frame_style_frame`

## Approved Prompt References

Use:

- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md#style-frame-prompt-template`
- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md#unit-concept-sheet-template`
- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md#hud-frame-template`
- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md#negative-prompt-guidance`

Record the exact final prompt in each workspace `prompt-reference.json` before setting candidate metadata to `candidate-ready`.

## Negative Prompt Guidance

Every prompt must include the v0.88 negative block:

- no protected franchise imitation;
- no Warcraft-like silhouettes;
- no Warlords Battlecry copying;
- no generic mobile strategy UI;
- no AI text artifacts;
- no logos;
- no watermarks;
- no unreadable silhouettes;
- no overdark low-contrast image;
- no neon fantasy soup;
- no unapproved modern objects or weapons.

## Aspect Ratio

- Environment style frame: 16:9.
- Unit concept sheets: 4:3.
- HUD frame style exploration: 16:9.

Vertical mobile ratios are not approved for this packet.

## Camera Rule

- Environment style frame: high three-quarter RTS camera with readable walkable and blocked areas.
- Unit concept sheet: front three-quarter pose plus side silhouette and a small RTS-scale thumbnail.
- HUD frame: flat orthographic UI board, not a fake gameplay screenshot.

Avoid dramatic worm-eye views, heavy lens blur, splash-art crops, and cinematic-only compositions.

## Thumbnail Readability

Every candidate must remain readable when reduced to a small review thumbnail. The silhouette, role, material anchors, and functional shape must read before beauty or rendering polish.

## Rejection Triggers

Reject immediately if a candidate has:

- unclear source, tool, model, generated-by, or license terms;
- protected-IP resemblance;
- unreadable RTS-scale silhouette;
- broken anatomy, tools, hands, construction, or material logic;
- fake text, logos, watermarks, or glyph noise;
- mobile-game UI drift;
- overdark terrain or clutter;
- implied unapproved gameplay systems, factions, maps, engine choices, or runtime replacements.

## Metadata Instructions

For each candidate workspace:

1. Run `npm run art:review:init -- --asset <assetId>`.
2. Paste the final prompt into `prompt-reference.json`.
3. Place candidate images manually under `artifacts/art-review/candidates/<assetId>/images/`.
4. Fill `candidate-metadata.json` with source tool, model, generated-by, license terms, prompt version, protected-IP assessment, candidate file list, and review state.
5. Run `npm run art:review:validate`.
6. Generate `npm run art:review:contact-sheet -- --asset <assetId>`.
7. Generate `npm run art:review:report -- --asset <assetId>`.

## Emmanuel Review

Emmanuel should review source/license posture, protected-IP safety, faction fit, thumbnail readability, camera/aspect compliance, and whether the candidate is only a style reference or needs revision.

Any approval from this packet is reference-only. Runtime integration requires a separate future gate.
