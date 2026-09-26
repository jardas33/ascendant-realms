# Clan Levy visual candidate R2

This isolated branch changes only the production Clan Levy GLB. The unit ID,
definition, external animation library, skeleton bone names, collision and
combat logic remain untouched. The original 302,132-byte GLB from baseline
`0052293df291121335a8cb0087eb39a06c2ff7d9` is preserved in
`sources/barrosan_clan_levy_base.glb` (SHA-256
`538209788069F07C64C8D26F2AD0D8342B4C4EB7A57A7C7806E468E2BD4A3645`).

`build_clan_levy_astra_r2.py` uses Blender 5.2.1 to add a weighted split
indigo cloak and a curved oak-backed shield with an aged bronze rim. R2
replaces R1's flat shield face and geometric chevron with a painted Sunblade
heraldic texture, refines the cloak folds and hem, and removes the rigid front
tabard that obscured the source armor. The unit uses the existing 34-bone
production rig, existing animation tracks, and unmodified selection/gameplay
dimensions. The script saves an editable `.blend` and exports directly to the
game asset path. The resulting GLB has 4,045 triangles, six meshes, five
materials, five embedded images, and the same 34-bone skin. It also excludes
the source GLB's hidden Icosphere helper from export.

`textures/clan_levy_sunblade_shield.png` was generated with the built-in
image generation tool using this prompt: "Use case: stylized-concept. Create a square flat orthographic
albedo texture for the front of a medieval infantry shield. Entire image is
deep worn ultramarine painted wood with an elegant small antique gold rising
sun above a vertical sword in the central half. Straight-on 2D surface design
only: no shield silhouette, no border, no perspective, no environment, no
highlights, no text. Premium fantasy strategy game material texture, subtly
weathered and readable at 64 pixels." The source is copied into this folder;
the GLB embeds it for the runtime.

Rebuild from the repository root:

```powershell
& 'D:\CodexData\tools\blender-5.2.1-windows-x64\blender.exe' --background --python 'tools\character_art\build_clan_levy_astra_r2.py'
```

The Blender review stills and real Godot captures are in
`D:\CodexData\evidence\astra-character-quality-r2`. The Godot test script
`production/ascendant-realms-godot/tests/astra_clan_levy_visual_review.gd`
spawns the real unit, selects it, captures normal/near views, orders a move,
verifies the existing Walk clip runs, and samples the attack pose. It passed
at 1920×1080 and 1366×768 after the certified Godot 4.6.3 importer completed.
Movement during the 20-frame samples was 3.02m at 1366×768 and 2.22m at
1920×1080. Godot exited 0 in both runs; shutdown printed a resource-leak
warning unrelated to the asset import or animation checks.

Visual classification: **local candidate, awaiting independent review**.
The shield and dark cloth separate the Clan Levy from the grass at gameplay
scale, but the inherited low-detail body and limited gameplay camera scale
remain below the final character-art target. Do not promote this branch based on an
automated pass alone. The generic `validate:art-intake` and
`validate:runtime-art-slots` npm scripts in this baseline reference missing
`tools/art-intake/validateArtIntake.ts` and
`tools/runtime-art-slots/validateRuntimeArtSlots.ts`; their invocation failed
with `ERR_MODULE_NOT_FOUND`. Godot import and headed interaction proof passed.
