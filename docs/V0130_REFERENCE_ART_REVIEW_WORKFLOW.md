# v0.130 Reference-Art Review Workflow

Generated images stay outside runtime. They are reference candidates for Emmanuel's visual direction review only.

## Candidate Workspaces

Use the existing ignored art-review candidate folders:

| Reference asset | Asset ID | Candidate folder |
| --- | --- | --- |
| Salto 2.5D environment style frame | `v088_salto_environment_style_frame` | `artifacts/art-review/candidates/v088_salto_environment_style_frame/images/` |
| HUD style frame | `v088_hud_frame_style_frame` | `artifacts/art-review/candidates/v088_hud_frame_style_frame/images/` |
| Aster hero silhouette sheet | `v088_barrosan_hero_concept_sheet` | `artifacts/art-review/candidates/v088_barrosan_hero_concept_sheet/images/` |
| Worker silhouette sheet | `v088_barrosan_worker_concept_sheet` | `artifacts/art-review/candidates/v088_barrosan_worker_concept_sheet/images/` |

## Steps

1. Initialize each workspace:

```bash
npm run art:review:init -- --asset v088_salto_environment_style_frame
npm run art:review:init -- --asset v088_hud_frame_style_frame
npm run art:review:init -- --asset v088_barrosan_hero_concept_sheet
npm run art:review:init -- --asset v088_barrosan_worker_concept_sheet
```

2. Place generated images manually in the matching ignored `images/` folder.
3. Update each `candidate-metadata.json` and `prompt-reference.json` with source/model/tool, prompt version, date, creator, license/licence posture, usage permission, protected-IP assessment, and candidate file list.
4. Generate contact sheets:

```bash
npm run art:review:contact-sheet -- --asset v088_salto_environment_style_frame
npm run art:review:contact-sheet -- --asset v088_hud_frame_style_frame
npm run art:review:contact-sheet -- --asset v088_barrosan_hero_concept_sheet
npm run art:review:contact-sheet -- --asset v088_barrosan_worker_concept_sheet
```

5. Validate metadata:

```bash
npm run art:review:validate
```

6. Generate per-asset reports as needed:

```bash
npm run art:review:report -- --asset v088_salto_environment_style_frame
npm run art:review:report -- --asset v088_hud_frame_style_frame
npm run art:review:report -- --asset v088_barrosan_hero_concept_sheet
npm run art:review:report -- --asset v088_barrosan_worker_concept_sheet
```

## Approval Boundary

- Safe generated images may be marked `style-approved` only after human review and complete metadata.
- `style-approved` remains reference-only and not runtime-ready.
- Do not mark any image `runtime-integrated`.
- Do not add files to browser runtime assets, Godot resources, runtime art slots, public manifests, or package contents.
- A future separate runtime-integration milestone is required before any art can become loadable.
