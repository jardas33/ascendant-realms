import type { BattleMapDefinition } from "../../core/GameTypes";

export const CINDERFEN_WATCHPOST_MAP: BattleMapDefinition = {
  id: "cinderfen_watchpost",
  name: "Cinderfen Watchpost",
  role: "Chapter 2 ash-marsh watchpost",
  description:
    "A raised road through the cinder marsh, watched by an Ashen tower and a compact staging camp on the far bank.",
  strategicNotes: [
    "The raised watch road is the safest first capture and gives enough Crowns to prepare before the tower push.",
    "Fog hides the central watchtower and the marsh raider camp until scouts commit to the road.",
    "Waystation services are useful preparation here, especially earlier warnings, wider base vision, and the hero buffer, but the battle does not require them."
  ],
  width: 2400,
  height: 1550,
  playerStart: { x: 285, y: 1285 },
  enemyStart: { x: 2145, y: 285 },
  visualPaths: [
    {
      id: "raised_watch_road",
      width: 52,
      points: [
        { x: 120, y: 1365 },
        { x: 395, y: 1265 },
        { x: 650, y: 1115 },
        { x: 910, y: 960 },
        { x: 1190, y: 810 },
        { x: 1480, y: 650 },
        { x: 1785, y: 485 },
        { x: 2110, y: 315 },
        { x: 2315, y: 220 }
      ]
    },
    {
      id: "blackreed_stone_path",
      width: 34,
      points: [
        { x: 520, y: 1195 },
        { x: 700, y: 1065 },
        { x: 930, y: 900 },
        { x: 1180, y: 840 }
      ]
    },
    {
      id: "ash_cistern_spur",
      width: 34,
      points: [
        { x: 1130, y: 810 },
        { x: 1295, y: 690 },
        { x: 1470, y: 595 }
      ]
    }
  ],
  terrainZones: [
    { id: "watchpost_grass", type: "grass", x: 0, y: 0, width: 2400, height: 1550 },
    { id: "player_build", type: "buildable", x: 70, y: 1070, width: 650, height: 420 },
    { id: "enemy_build", type: "buildable", x: 1830, y: 95, width: 520, height: 480 },
    { id: "west_blackwater", type: "water", x: 360, y: 805, width: 340, height: 170 },
    { id: "central_cinder_mire", type: "water", x: 930, y: 520, width: 420, height: 150 },
    { id: "south_reed_sink", type: "water", x: 850, y: 1110, width: 520, height: 150 },
    { id: "east_ash_pool", type: "water", x: 1540, y: 710, width: 430, height: 160 },
    { id: "roadside_glass_spines", type: "blocked", x: 760, y: 790, width: 160, height: 145 },
    { id: "watchpost_cairn", type: "blocked", x: 1395, y: 515, width: 170, height: 145 },
    { id: "sunken_road_cart", type: "blocked", x: 585, y: 1295, width: 175, height: 130 },
    { id: "north_burned_palisade", type: "blocked", x: 1760, y: 335, width: 200, height: 145 }
  ],
  captureSites: [
    {
      id: "watch_road_toll",
      name: "Watch Road Toll",
      resource: "crowns",
      x: 650,
      y: 1115,
      radius: 78,
      incomeAmount: 28,
      incomeInterval: 5
    },
    {
      id: "blackreed_stonecut",
      name: "Blackreed Stonecut",
      resource: "stone",
      x: 965,
      y: 910,
      radius: 74,
      incomeAmount: 20,
      incomeInterval: 6
    },
    {
      id: "ash_cistern",
      name: "Ash Cistern",
      resource: "aether",
      x: 1300,
      y: 690,
      radius: 76,
      incomeAmount: 14,
      incomeInterval: 6
    }
  ],
  neutralCamps: [
    {
      id: "marsh_raider_camp",
      name: "Marsh Raider Camp",
      x: 1135,
      y: 990,
      unitIds: ["raider", "brute"]
    },
    {
      id: "watch_road_pickets",
      name: "Watch Road Pickets",
      x: 1510,
      y: 620,
      unitIds: ["raider", "hexer"]
    }
  ],
  scenario: {
    startingResources: {
      player: {
        crowns: 500,
        stone: 335,
        iron: 205,
        aether: 115
      },
      enemy: {
        crowns: 280,
        stone: 210,
        iron: 155,
        aether: 110
      }
    },
    heroSpawn: { x: 365, y: 1235 },
    buildingSpawns: [
      { id: "player_command_hall", buildingId: "command_hall", team: "player", x: 285, y: 1285 },
      { id: "enemy_stronghold", buildingId: "enemy_stronghold", team: "enemy", x: 2145, y: 285 },
      { id: "enemy_barracks", buildingId: "enemy_barracks", team: "enemy", x: 2005, y: 400 },
      { id: "enemy_watchpost_tower", buildingId: "watchtower", team: "enemy", x: 1690, y: 575 }
    ],
    unitSpawns: [
      { id: "player_militia_1", unitId: "militia", team: "player", x: 385, y: 1328 },
      { id: "player_militia_2", unitId: "militia", team: "player", x: 430, y: 1306 },
      { id: "player_militia_3", unitId: "militia", team: "player", x: 455, y: 1266 },
      { id: "player_ranger_1", unitId: "ranger", team: "player", x: 405, y: 1192 },
      { id: "enemy_raider_1", unitId: "raider", team: "enemy", x: 2065, y: 280 },
      { id: "enemy_raider_2", unitId: "raider", team: "enemy", x: 2030, y: 320 },
      { id: "enemy_hexer_1", unitId: "hexer", team: "enemy", x: 2090, y: 390 },
      { id: "enemy_commander_1", unitId: "enemy_commander", team: "enemy", x: 2195, y: 245 }
    ],
    objectives: {
      playerBaseBuildingId: "command_hall",
      enemyBaseBuildingId: "enemy_stronghold",
      secondaryObjectives: [
        {
          id: "capture_watch_road",
          name: "Capture the Watch Road",
          description: "Claim the raised-road toll before pushing into the fog around the watchtower.",
          type: "capture_site",
          targetId: "watch_road_toll"
        },
        {
          id: "clear_marsh_raider_camp",
          name: "Clear the Marsh Raider Camp",
          description: "Defeat the Brute leading the raider camp on the lower road.",
          type: "defeat_unit",
          targetId: "brute"
        },
        {
          id: "destroy_watchpost_tower",
          name: "Destroy the Watchpost Tower",
          description: "Bring down the central Ashen Watchtower before the Stronghold assault.",
          type: "destroy_building",
          targetId: "watchtower"
        }
      ]
    },
    enemyAI: {
      incomeInterval: 5,
      incomePerTick: { crowns: 80, stone: 40, iron: 36, aether: 30 },
      trainInterval: 6.4,
      expandInterval: 23,
      initialExpandDelay: 23,
      attackInterval: 74,
      initialAttackDelay: 195,
      minAttackArmySize: 3,
      attackWaveSize: 6,
      expandSquadSize: 2,
      defenseSquadSize: 4,
      defendRadius: 445,
      baseBuildingId: "enemy_stronghold",
      productionBuildingId: "enemy_barracks",
      attackTargetBuildingId: "command_hall",
      unitPlan: ["raider", "hexer", "raider", "hexer", "raider"]
    },
    rewardTableId: "cinderfen_watchpost_rewards"
  }
};
