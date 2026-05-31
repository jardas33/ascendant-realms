# v0.88 Emmanuel Visual Review Packet

Status: review packet only. v0.88 generated no images and imported no art.

## What Needs Approval Before Generation

Please review and approve or revise:

- `docs/V088_SCREEN_BY_SCREEN_VISUAL_FOUNDATION.md`
- `docs/V088_UI_DESIGN_TOKEN_PROPOSAL.md`
- `docs/V088_BARROSAN_STYLE_FRAME_BRIEF.md`
- `docs/V088_ASHEN_STYLE_FRAME_BRIEF.md`
- `docs/V088_WOLFVEIL_SILHOUETTE_BRIEF.md`
- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md`
- `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`
- `docs/V088_ART_INTAKE_AND_REVIEW_GATE.md`

No generation should begin until the relevant brief and prompt template are approved.

## First Images To Generate Later

Recommended first controlled batch:

1. Salto battlefield/environment style frame.
2. Barrosan Worker concept sheet.
3. Barrosan Militia or Ranger concept sheet.
4. Barrosan Command Hall or Barracks concept sheet.
5. HUD frame style exploration.
6. Lume-link style frame.

Hold Ashen and Wolfveil generation until Barrosan readability is approved, unless you want a side-by-side contrast review first.

## What Should Remain Placeholder

- Runtime unit sprites.
- Runtime buildings.
- Runtime terrain tiles.
- Runtime HUD CSS/assets.
- Campaign map art.
- Lume effects.
- Results art.
- Any image not yet source/license/review approved.

## Visual Risks

- Barrosan can become generic medieval humans or royal knights.
- Ashen can become generic demons, lava soldiers, or copied chaos armor.
- Wolfveil can become humans in wolf masks or protected-style beastfolk.
- Lume teal can become generic magic blue.
- Generated UI can drift into mobile game cards, shop surfaces, and oversized rounded controls.
- A pile of attractive unreviewed AI images can make the game less coherent.

## Prohibited Shortcuts

- No image generation during v0.88.
- No direct import into `public/assets/final` from generated output.
- No runtime replacement before manifest/source/license/human review.
- No prompts asking for the style of a named protected game, film, artist, or franchise.
- No whole-roster generation before the first style frame is approved.
- No UI frame that hides the RTS playfield or copies mobile patterns.

## How To Prevent AI-Art Flooding

- Approve one brief at a time.
- Generate one planned asset ID at a time.
- Review thumbnail readability before beauty.
- Reject unclear source/license candidates immediately.
- Keep rejected candidates out of runtime folders.
- Record every candidate in the manifest/review log.
- Do not expand to additional factions until Barrosan visual rules hold together.

## Decision Checklist

For each future candidate, answer:

- Does it match the approved brief?
- Is the silhouette readable at RTS scale?
- Does it feel original?
- Does it avoid protected-IP resemblance?
- Does it preserve the current game systems instead of implying new mechanics?
- Does it improve desktop readability?
- Is source/license metadata complete?
- Is it approved only as reference, or approved for a future runtime-candidate pass?
