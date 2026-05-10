# v0.9.1 Manual Style-Frame Preparation Guide

Audience: Emmanuel.

This guide explains how to prepare future Cinderfen style-frame candidates outside Codex so they can be reviewed safely later. It does not ask Codex to generate images, download images, scrape images, import art, or wire anything into the game.

## What To Make First

Start small. Make 1 to 3 images per category, not dozens.

Recommended first batch:

1. One Cinderfen terrain style frame.
2. One Cinder Shrine landmark sheet.
3. One Ashen outpost architecture sheet.

That is enough to test whether the future art direction works before spending time on production assets.

## Prompt Docs To Use

Use these v0.9 docs as your source material:

- `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`
- `docs/V09_CINDERFEN_VISUAL_PILLARS.md`
- `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`
- `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`
- `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`
- `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`
- `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`

Treat the prompts as original-IP direction, not as instructions to copy another game.

## Image Counts

For the first pass:

- Terrain style frame: 1 to 3 images.
- Cinder Shrine landmark sheet: 1 to 3 images.
- Ashen outpost architecture sheet: 1 to 3 images.

Stop after a small set. The next step is review, not mass generation.

## Required Format

Preferred format:

- PNG.
- Avoid huge files if possible.
- Use 16:9 for broad terrain style frames.
- Use square or tall/sheet layouts for landmark or architecture sheets when that makes the design easier to inspect.
- Use transparent background for icon, landmark, sprite, or cutout-oriented images when practical.
- Keep filenames simple and stable, such as `cinderfen_terrain_style_frame_01.png`.

Do not optimize for final runtime size yet. These are review images, not game-ready assets.

## Metadata To Fill

For every candidate, fill a copy of:

- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`
- or `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`

At minimum, record:

- Candidate ID.
- Title.
- File name and file path.
- Submitted by.
- Created by.
- Source type.
- Tool or software.
- Generation prompt, if generated.
- Negative prompt, if generated.
- Date created.
- Date submitted.
- License or ownership status.
- Usage permission.
- Whether commercial and derivative use are allowed.
- Attribution requirements.
- Reference sources.
- Protected-IP risk.
- Originality notes.
- Intended use.
- Visual family and asset category.
- Related v0.9 prompt/spec doc.
- Replacement target, if any, as future-only context.
- Scale and readability notes.

Unknown source or unknown license means the candidate is not production-safe.

## What Not To Use

Do not use:

- Copyrighted game screenshots.
- Warcraft lookalikes.
- Warlords Battlecry lookalikes.
- Any protected franchise names, factions, units, symbols, maps, UI, terrain, buildings, or recognizable art style.
- Unlicensed web images.
- Scraped reference boards.
- Images with unclear creator, tool, date, ownership, or license.
- AI outputs whose usage terms are unclear.

If you are unsure whether an image is safe, treat it as reference-only or reject it.

## Where To Place Files Later

When a future goal explicitly asks Codex to inspect candidate images, place the files here:

```text
art-review/cinderfen-style-frames/inbox/
```

Place metadata here:

```text
art-review/cinderfen-style-frames/metadata/
```

Raw candidate images in the inbox are ignored by git by default. That is intentional. Candidate binaries should only be committed later if you explicitly approve that and the metadata is present.

## What To Send Back To Codex Or ChatGPT

Send:

- The candidate image file names.
- The completed metadata records.
- The tool or app used to create them.
- The exact prompt and negative prompt, if generated.
- Any edits made after generation.
- Whether you own the image or have a license to use it.
- Whether the image is only for reference, for prototype review, or a possible future runtime test.
- Any worries you have about originality, readability, or franchise similarity.

If the image came from a commission or an external artist, include the agreement or license terms before asking for approval.

## What Happens Next

The next review step should be a future v0.9.2-style goal:

1. Codex inspects candidate files without moving or wiring them.
2. `npm run validate:art-intake` checks metadata.
3. Unsafe, unknown-source, or high-IP-risk candidates are rejected or kept reference-only.
4. Safe candidates may be catalogued in a non-runtime review manifest.
5. `npm run visual:qa` captures current screenshots.
6. A side-by-side review document compares candidates against Cinderfen screenshots.
7. At most one candidate may be proposed for a later runtime-test goal.

Runtime replacement is not part of this preparation guide. It should happen only in a future explicit scope after source/license proof, manifest validation, screenshot QA, and human approval.
