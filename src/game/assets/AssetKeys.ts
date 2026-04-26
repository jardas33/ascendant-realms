export const ASSET_MANIFEST_CACHE_KEY = "asset-manifest";

export const ASSET_IDS = {
  portraits: {
    warlord: "warlord_hero_portrait",
    arcanist: "arcanist_hero_portrait",
    shepherd: "shepherd_hero_portrait",
    enemyCommander: "enemy_commander_portrait"
  },
  heroBattle: {
    warlord: "warlord_hero_battle_sprite",
    arcanist: "arcanist_hero_battle_sprite",
    shepherd: "shepherd_hero_battle_sprite"
  },
  factions: {
    freeMarches: "free_marches_emblem",
    ashenCovenant: "ashen_covenant_emblem",
    sylvanConcord: "sylvan_concord_emblem"
  },
  abilities: {
    rally_banner: "rally_banner_icon",
    cleave: "cleave_icon",
    war_cry: "war_cry_icon",
    firebolt: "firebolt_icon",
    arcane_burst: "arcane_burst_icon",
    blink: "blink_icon",
    heal: "heal_icon",
    blessing: "blessing_icon",
    sanctify_ground: "sanctify_ground_icon"
  },
  resources: {
    crownShrine: "crown_shrine_icon",
    stoneQuarry: "stone_quarry_icon",
    ironVein: "iron_vein_icon",
    aetherWell: "aether_well_icon"
  },
  units: {
    militiaSprite: "militia_unit_sprite",
    rangerSprite: "ranger_unit_sprite",
    acolyteSprite: "acolyte_unit_sprite",
    raiderSprite: "raider_unit_sprite",
    hexerSprite: "hexer_unit_sprite",
    bruteSprite: "brute_unit_sprite",
    enemyCommanderSprite: "enemy_commander_unit_sprite",
    wildHoundSprite: "wild_hound_unit_sprite",
    stoneImpSprite: "stone_imp_unit_sprite",
    militiaConcept: "militia_unit_concept",
    rangerConcept: "ranger_unit_concept",
    acolyteConcept: "acolyte_unit_concept"
  },
  buildings: {
    commandHallSprite: "command_hall_building_sprite",
    barracksSprite: "barracks_building_sprite",
    mysticLodgeSprite: "mystic_lodge_building_sprite",
    watchtowerSprite: "watchtower_building_sprite",
    enemyStrongholdSprite: "enemy_stronghold_building_sprite",
    enemyBarracksSprite: "enemy_barracks_building_sprite",
    commandHallConcept: "command_hall_concept",
    barracksConcept: "barracks_concept",
    mysticLodgeConcept: "mystic_lodge_concept",
    watchtowerConcept: "watchtower_concept"
  },
  ui: {
    mainMenuBackground: "main_menu_background",
    battleHudPanel: "battle_hud_panel",
    victoryScreenBackground: "victory_screen_background",
    defeatScreenBackground: "defeat_screen_background"
  },
  uiKit: {
    panelFrame: "ui_panel_frame",
    buttonIdle: "ui_button_idle",
    buttonHover: "ui_button_hover",
    buttonPressed: "ui_button_pressed",
    resourceFrame: "ui_resource_frame",
    dividerOrnament: "ui_divider_ornament",
    tooltipFrame: "ui_tooltip_frame",
    minimapFrame: "ui_minimap_frame",
    abilitySlotFrame: "ui_ability_slot_frame",
    inventorySlotFrame: "ui_inventory_slot_frame",
    victoryPanelFrame: "ui_victory_panel_frame",
    defeatPanelFrame: "ui_defeat_panel_frame"
  },
  splash: {
    keyArt: "ascendant_realms_key_art"
  }
} as const;

export const UI_KIT_CSS_VARIABLES: Record<string, string> = {
  [ASSET_IDS.uiKit.panelFrame]: "--ui-panel-frame",
  [ASSET_IDS.uiKit.buttonIdle]: "--ui-button-idle",
  [ASSET_IDS.uiKit.buttonHover]: "--ui-button-hover",
  [ASSET_IDS.uiKit.buttonPressed]: "--ui-button-pressed",
  [ASSET_IDS.uiKit.resourceFrame]: "--ui-resource-frame",
  [ASSET_IDS.uiKit.dividerOrnament]: "--ui-divider-ornament",
  [ASSET_IDS.uiKit.tooltipFrame]: "--ui-tooltip-frame",
  [ASSET_IDS.uiKit.minimapFrame]: "--ui-minimap-frame",
  [ASSET_IDS.uiKit.abilitySlotFrame]: "--ui-ability-slot-frame",
  [ASSET_IDS.uiKit.inventorySlotFrame]: "--ui-inventory-slot-frame",
  [ASSET_IDS.uiKit.victoryPanelFrame]: "--ui-victory-panel-frame",
  [ASSET_IDS.uiKit.defeatPanelFrame]: "--ui-defeat-panel-frame",
  [ASSET_IDS.ui.battleHudPanel]: "--ui-battle-hud-panel"
};

export const BATTLE_TEXTURE_ASSET_IDS = [
  ASSET_IDS.portraits.warlord,
  ASSET_IDS.portraits.arcanist,
  ASSET_IDS.portraits.shepherd,
  ASSET_IDS.portraits.enemyCommander,
  ASSET_IDS.heroBattle.warlord,
  ASSET_IDS.heroBattle.arcanist,
  ASSET_IDS.heroBattle.shepherd,
  ASSET_IDS.resources.crownShrine,
  ASSET_IDS.resources.stoneQuarry,
  ASSET_IDS.resources.ironVein,
  ASSET_IDS.resources.aetherWell,
  ASSET_IDS.units.militiaSprite,
  ASSET_IDS.units.rangerSprite,
  ASSET_IDS.units.acolyteSprite,
  ASSET_IDS.units.raiderSprite,
  ASSET_IDS.units.hexerSprite,
  ASSET_IDS.units.bruteSprite,
  ASSET_IDS.units.enemyCommanderSprite,
  ASSET_IDS.units.wildHoundSprite,
  ASSET_IDS.units.stoneImpSprite,
  ASSET_IDS.units.militiaConcept,
  ASSET_IDS.units.rangerConcept,
  ASSET_IDS.units.acolyteConcept,
  ASSET_IDS.buildings.commandHallSprite,
  ASSET_IDS.buildings.barracksSprite,
  ASSET_IDS.buildings.mysticLodgeSprite,
  ASSET_IDS.buildings.watchtowerSprite,
  ASSET_IDS.buildings.enemyStrongholdSprite,
  ASSET_IDS.buildings.enemyBarracksSprite,
  ASSET_IDS.buildings.commandHallConcept,
  ASSET_IDS.buildings.barracksConcept,
  ASSET_IDS.buildings.mysticLodgeConcept,
  ASSET_IDS.buildings.watchtowerConcept
] as const;

export function heroPortraitAssetId(classId: string): string | undefined {
  if (classId === "warlord" || classId === "arcanist" || classId === "shepherd") {
    return ASSET_IDS.portraits[classId];
  }
  return undefined;
}

export function abilityIconAssetId(abilityId: string): string | undefined {
  return ASSET_IDS.abilities[abilityId as keyof typeof ASSET_IDS.abilities];
}

export function unitBattleAssetIds(unitId: string): string[] {
  if (unitId.startsWith("hero_")) {
    const classId = unitId.replace("hero_", "");
    const spriteId = ASSET_IDS.heroBattle[classId as keyof typeof ASSET_IDS.heroBattle];
    return [spriteId, heroPortraitAssetId(classId)].filter((assetId): assetId is string => Boolean(assetId));
  }
  if (unitId === "enemy_commander") {
    return [ASSET_IDS.units.enemyCommanderSprite, ASSET_IDS.portraits.enemyCommander];
  }
  const map: Record<string, string[]> = {
    militia: [ASSET_IDS.units.militiaSprite, ASSET_IDS.units.militiaConcept],
    ranger: [ASSET_IDS.units.rangerSprite, ASSET_IDS.units.rangerConcept],
    acolyte: [ASSET_IDS.units.acolyteSprite, ASSET_IDS.units.acolyteConcept],
    raider: [ASSET_IDS.units.raiderSprite],
    hexer: [ASSET_IDS.units.hexerSprite],
    brute: [ASSET_IDS.units.bruteSprite],
    wild_hound: [ASSET_IDS.units.wildHoundSprite],
    stone_imp: [ASSET_IDS.units.stoneImpSprite]
  };
  return map[unitId] ?? [];
}

export function buildingBattleAssetIds(buildingId: string): string[] {
  const map: Record<string, string[]> = {
    command_hall: [ASSET_IDS.buildings.commandHallSprite, ASSET_IDS.buildings.commandHallConcept],
    barracks: [ASSET_IDS.buildings.barracksSprite, ASSET_IDS.buildings.barracksConcept],
    mystic_lodge: [ASSET_IDS.buildings.mysticLodgeSprite, ASSET_IDS.buildings.mysticLodgeConcept],
    watchtower: [ASSET_IDS.buildings.watchtowerSprite, ASSET_IDS.buildings.watchtowerConcept],
    enemy_stronghold: [ASSET_IDS.buildings.enemyStrongholdSprite],
    enemy_barracks: [ASSET_IDS.buildings.enemyBarracksSprite]
  };
  return map[buildingId] ?? [];
}

export function resourceIconAssetId(resourceId: string): string | undefined {
  const map: Record<string, string> = {
    crowns: ASSET_IDS.resources.crownShrine,
    stone: ASSET_IDS.resources.stoneQuarry,
    iron: ASSET_IDS.resources.ironVein,
    aether: ASSET_IDS.resources.aetherWell
  };
  return map[resourceId];
}
