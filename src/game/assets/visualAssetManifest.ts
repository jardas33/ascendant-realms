import type { VisualAssetManifest, VisualAssetManifestEntry } from "./VisualAssetManifestTypes";

type VisualAssetDefaultField =
  | "currentStatus"
  | "sourceType"
  | "licenseStatus"
  | "reviewStatus"
  | "silhouetteReadability"
  | "styleConsistency"
  | "replacementPriority"
  | "sourceReviewNotes"
  | "allowedInProduction"
  | "needsReview";

type VisualAssetDraft = Omit<VisualAssetManifestEntry, VisualAssetDefaultField> &
  Partial<Pick<VisualAssetManifestEntry, VisualAssetDefaultField>>;

const BATTLE_PRELOAD = "src/game/scenes/BootScene.ts";
const UNIT_RENDERER = "src/game/entities/Unit.ts";
const BUILDING_RENDERER = "src/game/entities/Building.ts";
const CAPTURE_SITE_RENDERER = "src/game/entities/CaptureSite.ts";
const HERO_HUD = "src/game/ui/hudPanels/HeroHudPanel.ts";
const UI_ASSET_LOADER = "src/game/assets/AssetLoader.ts";
const ASSET_PIPELINE = "tools/manual-asset-pipeline";

function visualAsset(input: VisualAssetDraft): VisualAssetManifestEntry {
  return {
    currentStatus: "prototype",
    sourceType: "manual",
    licenseStatus: "unknown",
    reviewStatus: "needs-source-proof",
    silhouetteReadability: "unknown",
    styleConsistency: "low",
    replacementPriority: "medium",
    sourceReviewNotes:
      "No explicit author, generation method, or license proof is attached yet. Keep prototype-only until source/license evidence is reviewed.",
    allowedInProduction: false,
    needsReview: true,
    ...input
  };
}

const heroSprites = [
  ["warlord_hero_battle_sprite", "Warlord Hero Battle Sprite", "warlord"],
  ["arcanist_hero_battle_sprite", "Arcanist Hero Battle Sprite", "arcanist"],
  ["shepherd_hero_battle_sprite", "Shepherd Hero Battle Sprite", "shepherd"]
].map(([id, displayName, filename]) =>
  visualAsset({
    id,
    filePath: `public/assets/final/units/${filename}_hero_battle_sprite.png`,
    category: "hero-sprite",
    displayName,
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", BATTLE_PRELOAD, UNIT_RENDERER],
    visualFamily: "Barrosan Freeholds hero",
    scaleClass: "hero",
    intendedWorldHeightPx: 82.65,
    currentRenderHeightPx: 82.65,
    silhouetteReadability: "medium",
    styleConsistency: "medium",
    replacementPriority: "medium",
    notes: "Current in-battle hero sprite. Usable for prototype readability, but source/license review and class style-sheet review remain required."
  })
);

const unitSprites = [
  ["militia_unit_sprite", "Militia Unit Battle Sprite", "militia", "Barrosan Freeholds infantry", "infantry", 47.45],
  ["ranger_unit_sprite", "Ranger Unit Battle Sprite", "ranger", "Barrosan Freeholds infantry", "ranged", 43.8],
  ["acolyte_unit_sprite", "Acolyte Unit Battle Sprite", "acolyte", "Barrosan Freeholds infantry", "caster", 43.8],
  ["raider_unit_sprite", "Raider Unit Battle Sprite", "raider", "Ashen Covenant enemy", "infantry", 47.45],
  ["hexer_unit_sprite", "Hexer Unit Battle Sprite", "hexer", "Ashen Covenant enemy", "caster", 43.8],
  ["brute_unit_sprite", "Brute Unit Battle Sprite", "brute", "Ashen Covenant enemy", "large-enemy", 58.4],
  [
    "enemy_commander_unit_sprite",
    "Enemy Commander Battle Sprite",
    "enemy_commander",
    "Ashen Covenant commander",
    "enemy-commander",
    65.7
  ],
  ["wild_hound_unit_sprite", "Wild Hound Battle Sprite", "wild_hound", "Wilds creature", "small-monster", 43.8],
  ["stone_imp_unit_sprite", "Stone Imp Battle Sprite", "stone_imp", "Wilds creature", "small-monster", 51.1]
] as const;

const unitSpriteAssets = unitSprites.map(([id, displayName, filename, visualFamily, scaleClass, height]) =>
  visualAsset({
    id,
    filePath: `public/assets/final/units/${filename}_unit_sprite.png`,
    category: "unit-sprite",
    displayName,
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", BATTLE_PRELOAD, UNIT_RENDERER],
    visualFamily,
    scaleClass,
    intendedWorldHeightPx: height,
    currentRenderHeightPx: height,
    silhouetteReadability: "medium",
    styleConsistency: "low",
    replacementPriority: scaleClass === "enemy-commander" ? "high" : "medium",
    notes:
      scaleClass === "enemy-commander"
        ? "Enemy commander is readable but not yet on the same future hero/elite visual scale standard as the player hero."
        : "Current unit sprite is readable through labels, bars, and selection rings, but source/style consistency still needs review."
  })
);

const unitConceptAssets = [
  ["militia_unit_concept", "Militia Unit Concept", "militia", "Barrosan Freeholds infantry"],
  ["ranger_unit_concept", "Ranger Unit Concept", "ranger", "Barrosan Freeholds infantry"],
  ["acolyte_unit_concept", "Acolyte Unit Concept", "acolyte", "Barrosan Freeholds infantry"]
].map(([id, displayName, filename, visualFamily]) =>
  visualAsset({
    id,
    filePath: `public/assets/final/units/${filename}_unit_concept.png`,
    category: "unit-concept",
    displayName,
    currentStatus: "reference",
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", BATTLE_PRELOAD, UNIT_RENDERER],
    visualFamily,
    scaleClass: "reference",
    silhouetteReadability: "medium",
    styleConsistency: "low",
    replacementPriority: "low",
    notes: "Concept art is preloaded as a fallback/reference path, but should not be treated as final in-battle art."
  })
);

const buildingSprites = [
  ["command_hall_building_sprite", "Command Hall Battle Sprite", "command_hall", "Barrosan Freeholds command building", "building-large", 116.44],
  ["barracks_building_sprite", "Barracks Battle Sprite", "barracks", "Barrosan Freeholds production building", "building-medium", 90.88],
  ["mystic_lodge_building_sprite", "Mystic Lodge Battle Sprite", "mystic_lodge", "Barrosan Freeholds production building", "building-medium", 88.04],
  ["watchtower_building_sprite", "Watchtower Battle Sprite", "watchtower", "Barrosan Freeholds defense building", "building-small", 102.24],
  [
    "enemy_stronghold_building_sprite",
    "Enemy Stronghold Battle Sprite",
    "enemy_stronghold",
    "Ashen Covenant stronghold",
    "building-large",
    124.96
  ],
  ["enemy_barracks_building_sprite", "Enemy Barracks Battle Sprite", "enemy_barracks", "Ashen Covenant building", "building-medium", 90.88]
] as const;

const buildingSpriteAssets = buildingSprites.map(([id, displayName, filename, visualFamily, scaleClass, height]) =>
  visualAsset({
    id,
    filePath: `public/assets/final/buildings/${filename}_building_sprite.png`,
    category: "building-sprite",
    displayName,
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", BATTLE_PRELOAD, BUILDING_RENDERER],
    visualFamily,
    scaleClass,
    intendedWorldHeightPx: height,
    currentRenderHeightPx: height,
    silhouetteReadability: "medium",
    styleConsistency: "low",
    replacementPriority: visualFamily.includes("stronghold") ? "high" : "medium",
    notes: "Current building sprite is footprint-scaled and readable, but needs source/license and architectural style review."
  })
);

const buildingConceptAssets = [
  ["command_hall_concept", "Command Hall Concept", "command_hall", "Barrosan Freeholds command building", "building-large"],
  ["barracks_concept", "Barracks Concept", "barracks", "Barrosan Freeholds production building", "building-medium"],
  ["mystic_lodge_concept", "Mystic Lodge Concept", "mystic_lodge", "Barrosan Freeholds production building", "building-medium"],
  ["watchtower_concept", "Watchtower Concept", "watchtower", "Barrosan Freeholds defense building", "building-small"]
] as const;

const buildingConceptVisualAssets = buildingConceptAssets.map(([id, displayName, filename, visualFamily, scaleClass]) =>
  visualAsset({
    id,
    filePath: `public/assets/final/buildings/${filename}_concept.png`,
    category: "building-concept",
    displayName,
    currentStatus: "reference",
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", BATTLE_PRELOAD, BUILDING_RENDERER],
    visualFamily,
    scaleClass,
    silhouetteReadability: "medium",
    styleConsistency: "low",
    replacementPriority: "low",
    notes: "Concept art is available as runtime fallback/reference, but should not be treated as final building art."
  })
);

const portraits = [
  ["warlord_hero_portrait", "Warlord Hero Portrait", "Warlord Hero Portrait.png", "Barrosan Freeholds hero"],
  ["arcanist_hero_portrait", "Arcanist Hero Portrait", "Arcanist Hero Portrait.png", "Arcanist hero"],
  ["shepherd_hero_portrait", "Shepherd Hero Portrait", "Shepherd Hero Portrait.png", "Shepherd hero"],
  ["enemy_commander_portrait", "Enemy Commander Portrait", "Enemy Commander Portrait.png", "Ashen Covenant commander"]
].map(([id, displayName, filename, visualFamily]) =>
  visualAsset({
    id,
    filePath: `public/assets/manual/portraits/${filename}`,
    category: "portrait",
    displayName,
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", BATTLE_PRELOAD, HERO_HUD, "src/game/scenes/HeroCreationScene.ts"],
    visualFamily,
    scaleClass: "portrait",
    silhouetteReadability: "medium",
    styleConsistency: "medium",
    replacementPriority: "medium",
    notes: "Portrait is visible in menus or as fallback presentation. Source/license metadata still needs explicit review."
  })
);

const abilityIcons = [
  ["rally_banner_icon", "Rally Banner Icon", "Rally Banner Icon.png"],
  ["cleave_icon", "Cleave Icon", "Cleave Icon.png"],
  ["war_cry_icon", "War Cry Icon", "War Cry Icon.png"],
  ["firebolt_icon", "Firebolt Icon", "Firebolt Icon.png"],
  ["arcane_burst_icon", "Arcane Burst Icon", "Arcane Burst Icon.png"],
  ["blink_icon", "Blink Icon", "Blink Icon.png"],
  ["heal_icon", "Heal Icon", "Heal Icon.png"],
  ["blessing_icon", "Blessing Icon", "Blessing Icon.png"],
  ["sanctify_ground_icon", "Sanctify Ground Icon", "Sanctify Ground Icon.png"]
].map(([id, displayName, filename]) =>
  visualAsset({
    id,
    filePath: `public/assets/manual/icons/${filename}`,
    category: "ability-icon",
    displayName,
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", HERO_HUD],
    visualFamily: "Hero ability icon",
    scaleClass: "ui",
    silhouetteReadability: "medium",
    styleConsistency: "medium",
    replacementPriority: "medium",
    notes: "Current hero ability icon. It is useful for HUD readability but still needs source/license review."
  })
);

const resourceIcons = [
  ["crown_shrine_icon", "Crown Shrine Icon", "Crown Shrine Icon.png", "Crowns capture site"],
  ["stone_quarry_icon", "Stone Quarry Icon", "Stone Quarry Icon.png", "Stone capture site"],
  ["iron_vein_icon", "Iron Vein Icon", "Iron Vein Icon.png", "Iron capture site"],
  ["aether_well_icon", "Aether Well Icon", "Aether Well Icon.png", "Aether capture site"]
].map(([id, displayName, filename, visualFamily]) =>
  visualAsset({
    id,
    filePath: `public/assets/manual/icons/${filename}`,
    category: id === "crown_shrine_icon" ? "capture-site-icon" : "resource-icon",
    displayName,
    usage: "runtime",
    usedBy: ["src/game/assets/AssetKeys.ts", BATTLE_PRELOAD, CAPTURE_SITE_RENDERER],
    visualFamily,
    scaleClass: "capture-site",
    intendedWorldHeightPx: 42,
    currentRenderHeightPx: 42,
    silhouetteReadability: "medium",
    styleConsistency: "low",
    replacementPriority: id === "crown_shrine_icon" ? "high" : "medium",
    notes:
      id === "crown_shrine_icon"
        ? "Current Cinder Shrine/crowns icon is functional but too icon-like for future Cinderfen landmark identity."
        : "Current resource-site icon is readable but needs future landmark/material alignment."
  })
);

const factionEmblems = [
  ["free_marches_emblem", "Barrosan Freeholds Emblem", "Free Marches Emblem.png", "Barrosan Freeholds", "runtime"],
  ["ashen_covenant_emblem", "Ashen Covenant Emblem", "Ashen Covenant Emblem.png", "Ashen Covenant", "manual-reference"],
  ["sylvan_concord_emblem", "Rootbound Concord Emblem", "Sylvan Concord Emblem.png", "Rootbound Concord", "manual-reference"]
].map(([id, displayName, filename, visualFamily, usage]) =>
  visualAsset({
    id,
    filePath: `public/assets/manual/icons/${filename}`,
    category: "faction-emblem",
    displayName,
    currentStatus: usage === "runtime" ? "prototype" : "reference",
    usage: usage as "runtime" | "manual-reference",
    usedBy: usage === "runtime" ? ["src/game/scenes/MainMenuScene.ts"] : [ASSET_PIPELINE, "docs/ART_DIRECTION_2026_BIBLE.md"],
    visualFamily,
    scaleClass: "ui",
    silhouetteReadability: "medium",
    styleConsistency: "medium",
    replacementPriority: "low",
    notes: "Faction emblem is useful as current/future identity reference, but source/license review remains required."
  })
);

const uiAssets = [
  ["main_menu_background", "Main Menu Background", "Main Menu Background.png", "ui-background", "Main menu background", "src/game/scenes/MainMenuScene.ts"],
  ["battle_hud_panel", "Battle HUD Panel", "Battle HUD Panel.png", "ui-frame", "Battle HUD frame", "src/game/styles/battle-hud.css"],
  [
    "victory_screen_background",
    "Victory Screen Background",
    "Victory Screen Background.png",
    "ui-background",
    "Results background",
    "src/game/results/ResultsViewModel.ts"
  ],
  [
    "defeat_screen_background",
    "Defeat Screen Background",
    "Defeat Screen Background.png",
    "ui-background",
    "Results background",
    "src/game/results/ResultsViewModel.ts"
  ],
  ["ui_panel_frame", "Reusable Panel Frame", "ui_panel_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/main-menu.css"],
  ["ui_button_idle", "Button Idle Frame", "ui_button_idle.png", "ui-frame", "Prototype UI kit", "src/game/styles/base.css"],
  ["ui_button_hover", "Button Hover Frame", "ui_button_hover.png", "ui-frame", "Prototype UI kit", "src/game/styles/base.css"],
  ["ui_button_pressed", "Button Pressed Frame", "ui_button_pressed.png", "ui-frame", "Prototype UI kit", "src/game/styles/base.css"],
  ["ui_resource_frame", "Resource Counter Frame", "ui_resource_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/battle-hud.css"],
  ["ui_divider_ornament", "Ornate Section Divider", "ui_divider_ornament.png", "ui-frame", "Prototype UI kit", "src/game/styles/inventory.css"],
  ["ui_tooltip_frame", "Tooltip And Info Frame", "ui_tooltip_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/inventory.css"],
  ["ui_minimap_frame", "Minimap Frame", "ui_minimap_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/minimap.css"],
  ["ui_ability_slot_frame", "Ability Slot Frame", "ui_ability_slot_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/battle-hud.css"],
  ["ui_inventory_slot_frame", "Inventory Slot Frame", "ui_inventory_slot_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/inventory.css"],
  ["ui_victory_panel_frame", "Victory Panel Frame", "ui_victory_panel_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/results.css"],
  ["ui_defeat_panel_frame", "Defeat Panel Frame", "ui_defeat_panel_frame.png", "ui-frame", "Prototype UI kit", "src/game/styles/results.css"]
] as const;

const uiVisualAssets = uiAssets.map(([id, displayName, filename, category, visualFamily, usedBy]) =>
  visualAsset({
    id,
    filePath: `public/assets/manual/ui/${filename}`,
    category,
    displayName,
    usage: "runtime",
    usedBy: [UI_ASSET_LOADER, usedBy],
    visualFamily,
    scaleClass: "ui",
    silhouetteReadability: "medium",
    styleConsistency: "medium",
    replacementPriority: id.includes("background") ? "high" : "medium",
    notes: "Current UI asset is functional for prototype presentation, but source/license and final UI-system review remain required."
  })
);

const splashAndReferenceAssets = [
  visualAsset({
    id: "ascendant_realms_key_art",
    filePath: "public/assets/manual/splash/Ascendant Realms Key Art.png",
    category: "splash",
    displayName: "Ascendant Realms Key Art",
    currentStatus: "reference",
    usage: "docs-reference",
    usedBy: [ASSET_PIPELINE, "docs/ART_DIRECTION_2026_BIBLE.md"],
    visualFamily: "Key art reference",
    scaleClass: "reference",
    silhouetteReadability: "medium",
    styleConsistency: "medium",
    replacementPriority: "low",
    notes: "Future-facing key art/reference image. It is not currently used by runtime screens."
  }),
  visualAsset({
    id: "asset_prompt_book",
    filePath: "public/assets/manual/ASSET_PROMPT_BOOK.md",
    category: "reference",
    displayName: "Manual Asset Prompt Book",
    currentStatus: "reference",
    sourceType: "original",
    licenseStatus: "owned",
    reviewStatus: "approved-for-prototype",
    usage: "docs-reference",
    usedBy: [ASSET_PIPELINE],
    visualFamily: "Asset pipeline reference",
    scaleClass: "reference",
    silhouetteReadability: "unknown",
    styleConsistency: "unknown",
    replacementPriority: "low",
    notes: "Prompt/reference document generated by the local manual asset pipeline. It is metadata, not shipped art.",
    sourceReviewNotes: "Owned local prompt/reference metadata generated by the repo pipeline. Not a runtime art asset.",
    allowedInProduction: false,
    needsReview: false
  }),
  visualAsset({
    id: "procedural_battle_terrain",
    filePath: "procedural:src/game/battle/BattleSceneMapRenderer.ts",
    category: "terrain",
    displayName: "Procedural Battle Terrain And Roads",
    currentStatus: "placeholder",
    sourceType: "original",
    licenseStatus: "owned",
    reviewStatus: "approved-for-prototype",
    usage: "runtime",
    usedBy: ["src/game/battle/BattleSceneMapRenderer.ts"],
    visualFamily: "Procedural terrain",
    scaleClass: "terrain",
    silhouetteReadability: "medium",
    styleConsistency: "low",
    replacementPriority: "critical",
    notes: "Current maps use procedural roads, water/swamp, boundaries, and capture-site ground marks. This is the largest visual debt area.",
    sourceReviewNotes:
      "Original project renderer code, source-safe for prototype use, but still visually placeholder and not production art.",
    allowedInProduction: false,
    needsReview: true
  })
];

const manualSourceAssets = [
  ["manual_source_barracks_concept", "public/assets/manual/buildings/Barracks Concept.png", "building-concept", "Barracks Concept Manual Source"],
  ["manual_source_barracks_building_sprite", "public/assets/manual/buildings/barracks_building_sprite.png", "building-sprite", "Barracks Building Sprite Manual Source"],
  ["manual_source_command_hall_concept", "public/assets/manual/buildings/Command Hall Concept.png", "building-concept", "Command Hall Concept Manual Source"],
  ["manual_source_command_hall_building_sprite", "public/assets/manual/buildings/command_hall_building_sprite.png", "building-sprite", "Command Hall Building Sprite Manual Source"],
  ["manual_source_enemy_barracks_building_sprite", "public/assets/manual/buildings/enemy_barracks_building_sprite.png", "building-sprite", "Enemy Barracks Building Sprite Manual Source"],
  ["manual_source_enemy_stronghold_building_sprite", "public/assets/manual/buildings/enemy_stronghold_building_sprite.png", "building-sprite", "Enemy Stronghold Building Sprite Manual Source"],
  ["manual_source_mystic_lodge_concept", "public/assets/manual/buildings/Mystic Lodge Concept.png", "building-concept", "Mystic Lodge Concept Manual Source"],
  ["manual_source_mystic_lodge_building_sprite", "public/assets/manual/buildings/mystic_lodge_building_sprite.png", "building-sprite", "Mystic Lodge Building Sprite Manual Source"],
  ["manual_source_watchtower_concept", "public/assets/manual/buildings/Watchtower Concept.png", "building-concept", "Watchtower Concept Manual Source"],
  ["manual_source_watchtower_building_sprite", "public/assets/manual/buildings/watchtower_building_sprite.png", "building-sprite", "Watchtower Building Sprite Manual Source"],
  ["manual_source_acolyte_unit_concept", "public/assets/manual/units/Acolyte Unit Concept.png", "unit-concept", "Acolyte Unit Concept Manual Source"],
  ["manual_source_acolyte_unit_sprite", "public/assets/manual/units/acolyte_unit_sprite.png", "unit-sprite", "Acolyte Unit Sprite Manual Source"],
  ["manual_source_arcanist_hero_battle_sprite", "public/assets/manual/units/arcanist_hero_battle_sprite.png", "hero-sprite", "Arcanist Hero Sprite Manual Source"],
  ["manual_source_brute_unit_sprite", "public/assets/manual/units/brute_unit_sprite.png", "unit-sprite", "Brute Unit Sprite Manual Source"],
  ["manual_source_enemy_commander_unit_sprite", "public/assets/manual/units/enemy_commander_unit_sprite.png", "unit-sprite", "Enemy Commander Unit Sprite Manual Source"],
  ["manual_source_hexer_unit_sprite", "public/assets/manual/units/hexer_unit_sprite.png", "unit-sprite", "Hexer Unit Sprite Manual Source"],
  ["manual_source_militia_unit_concept", "public/assets/manual/units/Militia Unit Concept.png", "unit-concept", "Militia Unit Concept Manual Source"],
  ["manual_source_militia_unit_sprite", "public/assets/manual/units/militia_unit_sprite.png", "unit-sprite", "Militia Unit Sprite Manual Source"],
  ["manual_source_raider_unit_sprite", "public/assets/manual/units/raider_unit_sprite.png", "unit-sprite", "Raider Unit Sprite Manual Source"],
  ["manual_source_ranger_unit_concept", "public/assets/manual/units/Ranger Unit Concept.png", "unit-concept", "Ranger Unit Concept Manual Source"],
  ["manual_source_ranger_unit_sprite", "public/assets/manual/units/ranger_unit_sprite.png", "unit-sprite", "Ranger Unit Sprite Manual Source"],
  ["manual_source_shepherd_hero_battle_sprite", "public/assets/manual/units/shepherd_hero_battle_sprite.png", "hero-sprite", "Shepherd Hero Sprite Manual Source"],
  ["manual_source_stone_imp_unit_sprite", "public/assets/manual/units/stone_imp_unit_sprite.png", "unit-sprite", "Stone Imp Unit Sprite Manual Source"],
  ["manual_source_warlord_hero_battle_sprite", "public/assets/manual/units/warlord_hero_battle_sprite.png", "hero-sprite", "Warlord Hero Sprite Manual Source"],
  ["manual_source_wild_hound_unit_sprite", "public/assets/manual/units/wild_hound_unit_sprite.png", "unit-sprite", "Wild Hound Unit Sprite Manual Source"]
] as const;

const manualReferenceAssets = manualSourceAssets.map(([id, filePath, category, displayName]) =>
  visualAsset({
    id,
    filePath,
    category,
    displayName,
    currentStatus: "reference",
    usage: "manual-reference",
    usedBy: ["tools/manual-asset-pipeline/processBattleSprites.ts"],
    visualFamily: "Manual source asset",
    scaleClass: "reference",
    silhouetteReadability: "unknown",
    styleConsistency: "unknown",
    replacementPriority: "low",
    notes: "Manual source/reference file preserved for the processed final asset. Do not delete without a dedicated asset-pruning review."
  })
);

export const VISUAL_ASSET_MANIFEST: VisualAssetManifest = {
  version: 1,
  updatedAt: "2026-05-10",
  notes:
    "v0.8.2 visual metadata manifest with explicit source-review status fields. It is additive metadata only and does not replace the runtime asset manifest.",
  assets: [
    ...heroSprites,
    ...unitSpriteAssets,
    ...unitConceptAssets,
    ...buildingSpriteAssets,
    ...buildingConceptVisualAssets,
    ...portraits,
    ...abilityIcons,
    ...resourceIcons,
    ...factionEmblems,
    ...uiVisualAssets,
    ...splashAndReferenceAssets,
    ...manualReferenceAssets
  ]
};
