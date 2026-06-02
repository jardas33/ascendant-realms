# v0.107 First Slice Review Gate

Status: review gate only. Runtime integration is not approved.

## Entry Conditions

Before any candidate is generated:

- v0.107 docs and manifest are committed.
- `npm run art:packet:salto-slice` produces the metadata packet.
- `npm run art:review:validate` passes.
- The target asset is next in `docs/V0107_GENERATION_DEPENDENCY_ORDER.md`.
- Emmanuel has approved the exact prompt text for that one asset or tightly grouped sheet.

## Required Candidate Metadata

Each candidate must record:

- asset ID and registry mapping;
- source tool and model;
- generated-by and generated-at;
- license terms and usage permission;
- prompt version and final prompt text;
- negative prompt version;
- protected-IP assessment and risk;
- human reviewer and review status;
- runtime posture as `reference-only:not-runtime` unless a future milestone changes it.

## Human Review Questions

Emmanuel reviews:

- silhouette readability at the required thumbnail size;
- Barrosan, Ashen, Salto, or Lume identity fit;
- source/license clarity;
- protected-IP separation;
- camera and aspect compliance;
- safe crop and noise posture;
- fallback posture and no runtime-loading implication.

## Rejection Triggers

Reject a candidate if it has:

- unclear source, tool, model, license, or generated-by data;
- protected franchise resemblance;
- unreadable RTS-scale silhouette;
- overdark, over-noisy, or particle-heavy presentation;
- broken anatomy, tools, hands, construction, or material logic;
- mobile UI or gacha-card composition drift;
- fake text, logos, watermarks, or glyph noise;
- implied new gameplay systems, maps, factions, engine decisions, or runtime replacements.

## Runtime Gate

The runtime gate is closed during v0.107:

- `style-approved` remains reference-only.
- `runtime-candidate-approved` remains non-loadable.
- `runtime-integrated` requires a future explicit integration milestone.
- Candidate workspaces must not become runtime asset paths.
- Existing fallback owners remain valid.

## QA Scenarios

Use the manifest QA scenario IDs:

- `qa_salto_reference_composition`
- `qa_battlefield_terrain_readability`
- `qa_hud_and_results_frame`
- `qa_lume_link_readability`
- `qa_campaign_map_frame`
- `qa_barrosan_unit_thumbnail_readability`
- `qa_barrosan_building_footprint_readability`
- `qa_ashen_contrast_readability`
