import type { ResourceBag } from "./GameTypes";

export const SAVE_KEY = "ascendant-realms-save-v1";

export const STARTING_PLAYER_RESOURCES: ResourceBag = {
  crowns: 380,
  stone: 255,
  iron: 140,
  aether: 75
};

export const STARTING_ENEMY_RESOURCES: ResourceBag = {
  crowns: 220,
  stone: 160,
  iron: 120,
  aether: 80
};

export const EMPTY_RESOURCES: ResourceBag = {
  crowns: 0,
  stone: 0,
  iron: 0,
  aether: 0
};

export const LEVEL_XP_THRESHOLDS: Record<number, number> = {
  2: 100,
  3: 250,
  4: 450,
  5: 700
};

export const HERO_HP_PER_LEVEL = 18;
export const HERO_MANA_PER_LEVEL = 10;
export const HERO_DAMAGE_PER_LEVEL = 2;
export const HERO_ARMOR_LEVEL_INTERVAL = 2;
export const HERO_CAPTURE_SITE_XP = 10;
export const CAMERA_PAN_SPEED = 520;
export const CAPTURE_TIME_SECONDS = 4;
export const HERO_XP_SHARE_RADIUS = 460;
export const ATTACK_MOVE_SEARCH_RADIUS = 260;
export const DEFAULT_AGGRO_RADIUS = 260;
export const FORMATION_SPACING = 34;
export const RESOURCE_TICK_FLOAT_TIME = 1300;
export const BUILD_RADIUS_FROM_OWNED_BUILDING = 560;
