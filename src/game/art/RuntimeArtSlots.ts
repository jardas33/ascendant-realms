import type { RuntimeArtSlotDefinition } from "./RuntimeArtSlotTypes";

export const V0105_VISUAL_REGISTRY_ASSET_IDS = [
  "v088_ashen_enemy_concept_sheet",
  "v088_barrosan_barracks_concept_sheet",
  "v088_barrosan_command_hall_concept_sheet",
  "v088_barrosan_hero_concept_sheet",
  "v088_barrosan_militia_concept_sheet",
  "v088_barrosan_mine_concept_sheet",
  "v088_barrosan_ranger_concept_sheet",
  "v088_barrosan_shrine_concept_sheet",
  "v088_barrosan_worker_concept_sheet",
  "v088_battlefield_style_frame",
  "v088_hud_frame_style_frame",
  "v088_lume_link_style_frame",
  "v088_salto_environment_style_frame",
  "v088_wolfveil_silhouette_sheet"
] as const;

export const EXPECTED_RUNTIME_ART_SLOT_IDS = [
  "menu-background",
  "logo-lockup",
  "primary-button-frame",
  "campaign-background",
  "route-frame",
  "chapter-banner",
  "mission-node-frame",
  "selected-node-frame",
  "locked-node-frame",
  "terrain-ground",
  "terrain-road",
  "terrain-water",
  "terrain-ford",
  "terrain-bridge",
  "terrain-quarry",
  "terrain-shrine",
  "terrain-ruin",
  "fog-treatment",
  "selection-ring",
  "capture-ring-neutral",
  "capture-ring-friendly",
  "capture-ring-hostile",
  "capture-ring-contested",
  "objective-marker",
  "minimap-frame",
  "minimap-marker-family",
  "lume-endpoint",
  "lume-link",
  "lume-transition",
  "barrosan-hero",
  "barrosan-worker",
  "barrosan-militia",
  "barrosan-ranger",
  "barrosan-acolyte",
  "ashen-raider",
  "ashen-brute",
  "ashen-hexer",
  "ashen-commander",
  "barrosan-command-hall",
  "barrosan-barracks",
  "barrosan-shrine",
  "barrosan-watchtower",
  "barrosan-mine",
  "construction-state",
  "hud-frame",
  "command-panel-frame",
  "results-frame",
  "hero-frame",
  "relic-frame",
  "stronghold-frame",
  "intel-frame",
  "reputation-frame"
] as const;

const MAIN_MENU_REFERENCE = ["v088_salto_environment_style_frame", "v088_hud_frame_style_frame"];
const CAMPAIGN_REFERENCE = ["v088_salto_environment_style_frame", "v088_hud_frame_style_frame"];
const BATTLEFIELD_REFERENCE = ["v088_battlefield_style_frame", "v088_salto_environment_style_frame"];
const HUD_REFERENCE = ["v088_hud_frame_style_frame"];

export const RUNTIME_ART_SLOTS = [
  slot("menu-background", "main-menu", "Main Menu Background", "MainMenuScene", "css", "src/game/styles/main-menu.css", "main-menu", "Layered CSS scene background behind the title and campaign actions.", MAIN_MENU_REFERENCE),
  slot("logo-lockup", "main-menu", "Logo Lockup", "MainMenuScene", "dom-layout", "src/game/scenes/MainMenuScene.ts", "main-menu", "Text lockup remains the runtime fallback until an approved logo asset is integrated.", HUD_REFERENCE),
  slot("primary-button-frame", "main-menu", "Primary Button Frame", "MainMenuScene", "css", "src/game/styles/main-menu.css", "menu-new-campaign", "CSS border, focus, and hover states frame primary menu actions.", HUD_REFERENCE),

  slot("campaign-background", "campaign", "Campaign Background", "CampaignMapScene", "css", "src/game/styles/campaign.css", "campaign-map", "Layered CSS panels and procedural map backdrop carry campaign readability.", CAMPAIGN_REFERENCE),
  slot("route-frame", "campaign", "Route Frame", "CampaignMapScene", "dom-layout", "src/game/scenes/CampaignMapScene.ts", "campaign-map", "HTML/SVG route strokes remain deterministic and responsive.", CAMPAIGN_REFERENCE),
  slot("chapter-banner", "campaign", "Chapter Banner", "CampaignMapScene", "dom-layout", "src/game/scenes/CampaignMapScene.ts", "campaign-chapter-border_marches", "Campaign chapter copy and CSS frame are the fallback banner.", CAMPAIGN_REFERENCE),
  slot("mission-node-frame", "campaign", "Mission Node Frame", "CampaignMapScene", "dom-layout", "src/game/scenes/CampaignMapScene.ts", "campaign-node-border_village", "CSS mission-node cards and state classes remain the fallback.", CAMPAIGN_REFERENCE),
  slot("selected-node-frame", "campaign", "Selected Node Frame", "CampaignMapScene", "dom-layout", "src/game/scenes/CampaignMapScene.ts", "campaign-selected-panel", "Selected-panel border and node highlight are CSS fallbacks.", CAMPAIGN_REFERENCE),
  slot("locked-node-frame", "campaign", "Locked Node Frame", "CampaignMapScene", "dom-layout", "src/game/scenes/CampaignMapScene.ts", "campaign-node-aether_well_ruins", "Locked mission state uses disabled CSS and text affordances.", CAMPAIGN_REFERENCE),

  slot("terrain-ground", "battlefield", "Terrain Ground", "BattleSceneMapRenderer", "procedural", "src/game/battle/BattleSceneMapRenderer.ts", "battle-canvas", "Phaser procedural tiles render walkable ground without image dependencies.", BATTLEFIELD_REFERENCE),
  slot("terrain-road", "battlefield", "Terrain Road", "BattleSceneMapRenderer", "procedural", "src/game/battle/BattleSceneMapRenderer.ts", "battle-canvas", "Phaser procedural strokes render roads and route surfaces.", BATTLEFIELD_REFERENCE),
  slot("terrain-water", "battlefield", "Terrain Water", "BattleSceneMapRenderer", "procedural", "src/game/battle/BattleSceneMapRenderer.ts", "battle-canvas", "Phaser procedural fills render water and boundary contrast.", BATTLEFIELD_REFERENCE),
  slot("terrain-ford", "battlefield", "Terrain Ford", "BattleSceneMapRenderer", "procedural", "src/game/battle/BattleSceneMapRenderer.ts", "battle-canvas", "Ford markers are procedural overlays on terrain.", BATTLEFIELD_REFERENCE),
  slot("terrain-bridge", "battlefield", "Terrain Bridge", "BattleSceneMapRenderer", "procedural", "src/game/battle/BattleSceneMapRenderer.ts", "battle-canvas", "Bridge crossings use procedural geometry and map metadata.", BATTLEFIELD_REFERENCE),
  slot("terrain-quarry", "battlefield", "Terrain Quarry", "CaptureSite", "phaser-vector", "src/game/entities/CaptureSite.ts", "battle-resource-sites", "Quarry resource sites use vector rings and labels when art is absent.", BATTLEFIELD_REFERENCE),
  slot("terrain-shrine", "battlefield", "Terrain Shrine", "CaptureSite", "phaser-vector", "src/game/entities/CaptureSite.ts", "battle-resource-sites", "Shrine sites use capture ring vectors and procedural markers.", BATTLEFIELD_REFERENCE),
  slot("terrain-ruin", "battlefield", "Terrain Ruin", "BattleSceneMapRenderer", "procedural", "src/game/battle/BattleSceneMapRenderer.ts", "battle-canvas", "Ruin areas remain procedural and map-defined.", BATTLEFIELD_REFERENCE),
  slot("fog-treatment", "battlefield", "Fog Treatment", "FogPresentation", "procedural", "src/game/ui/FogPresentation.ts", "battle-canvas", "Fog of war uses procedural alpha overlays.", BATTLEFIELD_REFERENCE),
  slot("selection-ring", "battlefield", "Selection Ring", "SelectionPresentation", "phaser-vector", "src/game/ui/SelectionPresentation.ts", "battle-canvas", "Selected entities use vector rings and pulse treatment.", HUD_REFERENCE),
  slot("capture-ring-neutral", "battlefield", "Capture Ring Neutral", "CaptureSitePresentation", "phaser-vector", "src/game/ui/CaptureSitePresentation.ts", "battle-resource-sites", "Neutral resource sites use the shared vector ring fallback.", HUD_REFERENCE),
  slot("capture-ring-friendly", "battlefield", "Capture Ring Friendly", "CaptureSitePresentation", "phaser-vector", "src/game/ui/CaptureSitePresentation.ts", "battle-resource-sites", "Friendly resource sites use the shared vector ring fallback.", HUD_REFERENCE),
  slot("capture-ring-hostile", "battlefield", "Capture Ring Hostile", "CaptureSitePresentation", "phaser-vector", "src/game/ui/CaptureSitePresentation.ts", "battle-resource-sites", "Hostile resource sites use the shared vector ring fallback.", HUD_REFERENCE),
  slot("capture-ring-contested", "battlefield", "Capture Ring Contested", "CaptureSitePresentation", "phaser-vector", "src/game/ui/CaptureSitePresentation.ts", "battle-resource-sites", "Contested resource sites use progress-ring vectors.", HUD_REFERENCE),
  slot("objective-marker", "battlefield", "Objective Marker", "CaptureSite", "phaser-vector", "src/game/entities/CaptureSite.ts", "battle-objectives", "Objective markers use existing vector callouts and HUD copy.", HUD_REFERENCE),
  slot("minimap-frame", "battlefield", "Minimap Frame", "MinimapView", "css", "src/game/styles/minimap.css", "battle-minimap", "Minimap frame uses CSS shell styling.", HUD_REFERENCE),
  slot("minimap-marker-family", "battlefield", "Minimap Marker Family", "MinimapView", "procedural", "src/game/ui/MinimapView.ts", "battle-minimap", "Minimap entities use canvas/vector marker primitives.", HUD_REFERENCE),
  slot("lume-endpoint", "battlefield", "Lume Endpoint", "LumeNetworkRendering", "phaser-vector", "src/game/battle/LumeNetworkRendering.ts", "lume-network-status", "Lume endpoints use pulsing vector markers.", ["v088_lume_link_style_frame", "v088_battlefield_style_frame"]),
  slot("lume-link", "battlefield", "Lume Link", "LumeNetworkRendering", "phaser-vector", "src/game/battle/LumeNetworkRendering.ts", "lume-links-progress", "Lume links use procedural strokes and pulse fills.", ["v088_lume_link_style_frame", "v088_battlefield_style_frame"]),
  slot("lume-transition", "battlefield", "Lume Transition", "LumeNetworkRendering", "phaser-vector", "src/game/battle/LumeNetworkRendering.ts", "lume-visibility-controls", "Lume state changes use existing vector emphasis and HUD status.", ["v088_lume_link_style_frame", "v088_battlefield_style_frame"]),

  slot("barrosan-hero", "units", "Barrosan Hero", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-hero-panel", "Hero silhouette uses placeholder battlefield presentation.", ["v088_barrosan_hero_concept_sheet"]),
  slot("barrosan-worker", "units", "Barrosan Worker", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-hud", "Worker silhouette uses placeholder battlefield presentation.", ["v088_barrosan_worker_concept_sheet"]),
  slot("barrosan-militia", "units", "Barrosan Militia", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "unit-order-summary", "Militia silhouette uses placeholder battlefield presentation.", ["v088_barrosan_militia_concept_sheet"]),
  slot("barrosan-ranger", "units", "Barrosan Ranger", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "unit-order-summary", "Ranger silhouette uses placeholder battlefield presentation.", ["v088_barrosan_ranger_concept_sheet"]),
  slot("barrosan-acolyte", "units", "Barrosan Acolyte", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "unit-order-summary", "Acolyte caster silhouette uses placeholder battlefield presentation.", ["v088_barrosan_hero_concept_sheet"]),
  slot("ashen-raider", "units", "Ashen Raider", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-canvas", "Ashen raider silhouette uses placeholder battlefield presentation.", ["v088_ashen_enemy_concept_sheet"]),
  slot("ashen-brute", "units", "Ashen Brute", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-canvas", "Ashen brute silhouette uses placeholder battlefield presentation.", ["v088_ashen_enemy_concept_sheet"]),
  slot("ashen-hexer", "units", "Ashen Hexer", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-canvas", "Ashen caster silhouette uses placeholder battlefield presentation.", ["v088_ashen_enemy_concept_sheet"]),
  slot("ashen-commander", "units", "Ashen Commander", "Unit", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-canvas", "Ashen commander silhouette uses placeholder battlefield presentation.", ["v088_ashen_enemy_concept_sheet"]),

  slot("barrosan-command-hall", "buildings", "Barrosan Command Hall", "Building", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-hud", "Command Hall placeholder shape remains the runtime fallback.", ["v088_barrosan_command_hall_concept_sheet"]),
  slot("barrosan-barracks", "buildings", "Barrosan Barracks", "Building", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-hud", "Barracks placeholder shape remains the runtime fallback.", ["v088_barrosan_barracks_concept_sheet"]),
  slot("barrosan-shrine", "buildings", "Barrosan Shrine", "Building", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-hud", "Shrine placeholder shape remains the runtime fallback.", ["v088_barrosan_shrine_concept_sheet"]),
  slot("barrosan-watchtower", "buildings", "Barrosan Watchtower", "Building", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-hud", "Watchtower placeholder shape remains the runtime fallback.", ["v088_barrosan_barracks_concept_sheet"]),
  slot("barrosan-mine", "buildings", "Barrosan Mine", "Building", "phaser-vector", "src/game/ui/PlaceholderBattlefieldPresentation.ts", "battle-hud", "Mine placeholder shape remains the runtime fallback.", ["v088_barrosan_mine_concept_sheet"]),
  slot("construction-state", "buildings", "Construction State", "Building", "phaser-vector", "src/game/entities/Building.ts", "battle-hud", "Under-construction treatment uses progress bars and vector opacity.", ["v088_barrosan_command_hall_concept_sheet", "v088_barrosan_barracks_concept_sheet"]),

  slot("hud-frame", "ui", "HUD Frame", "HUD", "css", "src/game/styles/battle-hud.css", "battle-hud", "Battle HUD frame uses CSS panels and density classes.", HUD_REFERENCE),
  slot("command-panel-frame", "ui", "Command Panel Frame", "HUD", "css", "src/game/styles/battle-hud.css", "battle-hud", "Command panel uses CSS frame, icons, and layout fallbacks.", HUD_REFERENCE),
  slot("results-frame", "ui", "Results Frame", "ResultsScene", "css", "src/game/styles/results.css", "results-overview", "Results screen uses CSS cards and summary rows.", HUD_REFERENCE),
  slot("hero-frame", "ui", "Hero Frame", "HeroProgressionScene", "css", "src/game/styles/inventory.css", "hero-overview", "Hero overview uses CSS portrait/frame treatment.", ["v088_barrosan_hero_concept_sheet", "v088_hud_frame_style_frame"]),
  slot("relic-frame", "ui", "Relic Frame", "HeroProgressionScene", "css", "src/game/styles/inventory.css", "build-identity-panel", "Relic identity panel uses CSS frame fallback.", HUD_REFERENCE),
  slot("stronghold-frame", "ui", "Stronghold Frame", "CampaignMapScene", "css", "src/game/styles/campaign.css", "stronghold-overview", "Stronghold panel uses CSS frame fallback.", ["v088_barrosan_command_hall_concept_sheet", "v088_hud_frame_style_frame"]),
  slot("intel-frame", "ui", "Intel Frame", "CampaignMapScene", "css", "src/game/styles/campaign.css", "campaign-tab-panel-intel", "Intel panel uses CSS frame fallback.", HUD_REFERENCE),
  slot("reputation-frame", "ui", "Reputation Frame", "CampaignMapScene", "css", "src/game/styles/campaign.css", "campaign-tab-panel-reputation", "Reputation panel uses CSS frame fallback.", HUD_REFERENCE)
] as const satisfies readonly RuntimeArtSlotDefinition[];

export type RuntimeArtSlotId = (typeof RUNTIME_ART_SLOTS)[number]["slotId"];

export const RUNTIME_ART_SLOT_IDS = RUNTIME_ART_SLOTS.map((slot) => slot.slotId) as RuntimeArtSlotId[];

function slot(
  slotId: (typeof EXPECTED_RUNTIME_ART_SLOT_IDS)[number],
  group: RuntimeArtSlotDefinition["group"],
  label: string,
  runtimeSurface: string,
  fallbackKind: RuntimeArtSlotDefinition["fallback"]["kind"],
  owner: string,
  dataTestId: string,
  description: string,
  referenceAssetIds: string[]
): RuntimeArtSlotDefinition {
  return {
    slotId,
    group,
    label,
    runtimeSurface,
    fallback: {
      kind: fallbackKind,
      owner,
      proofSurface: runtimeSurface,
      dataTestId,
      description
    },
    registryMapping: {
      status: referenceAssetIds.length > 0 ? "mapped-to-v0105-reference" : "deferred-final-art-requirement",
      referenceAssetIds,
      notes:
        referenceAssetIds.length > 0
          ? "Uses the v0.105 reference-only visual registry as future art review context; this is not runtime approval."
          : "No v0.105 reference entry exists yet; the slot remains fallback-only until a future approved asset is added."
    },
    publicDiagnosticsAllowed: false
  };
}
