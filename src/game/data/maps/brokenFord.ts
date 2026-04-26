import type { BattleMapDefinition } from "../../core/GameTypes";
import { STARTING_ENEMY_RESOURCES, STARTING_PLAYER_RESOURCES } from "../../core/Constants";

export const BROKEN_FORD_MAP: BattleMapDefinition = {
    id: "broken_ford",
    name: "Broken Ford",
    role: "Contested river crossing skirmish",
    description: "A ruined ford splits two attack lanes around a dangerous center, with safer but slower resource routes on the flanks.",
    strategicNotes: [
      "The central ford is valuable and exposed; claiming it early risks fighting neutral monsters and enemy patrols.",
      "Side resources are easier to hold, but their slower income rewards patient expansion.",
      "Blocked ruins and water pockets make army staging and base exits feel tighter than First Claim."
    ],
    width: 2600,
    height: 1700,
    playerStart: { x: 290, y: 1320 },
    enemyStart: { x: 2320, y: 330 },
    visualPaths: [
      {
        id: "southwest_lane",
        width: 46,
        points: [
          { x: 120, y: 1370 },
          { x: 420, y: 1290 },
          { x: 735, y: 1170 },
          { x: 1040, y: 990 },
          { x: 1300, y: 850 },
          { x: 1600, y: 690 },
          { x: 1960, y: 505 },
          { x: 2450, y: 355 }
        ]
      },
      {
        id: "northwest_lane",
        width: 38,
        points: [
          { x: 260, y: 1160 },
          { x: 555, y: 980 },
          { x: 850, y: 800 },
          { x: 1110, y: 700 },
          { x: 1370, y: 760 },
          { x: 1660, y: 910 },
          { x: 2040, y: 720 },
          { x: 2360, y: 510 }
        ]
      },
      {
        id: "ford_crossing",
        width: 58,
        points: [
          { x: 1090, y: 1040 },
          { x: 1210, y: 940 },
          { x: 1320, y: 845 },
          { x: 1445, y: 740 },
          { x: 1560, y: 625 }
        ]
      },
      {
        id: "southern_resource_track",
        width: 28,
        points: [
          { x: 610, y: 1330 },
          { x: 890, y: 1430 },
          { x: 1130, y: 1390 },
          { x: 1320, y: 1265 }
        ]
      }
    ],
    terrainZones: [
      { id: "broken_ford_grass", type: "grass", x: 0, y: 0, width: 2600, height: 1700 },
      { id: "player_build", type: "buildable", x: 70, y: 1120, width: 620, height: 500 },
      { id: "enemy_build", type: "buildable", x: 1960, y: 110, width: 560, height: 500 },
      { id: "north_river_bend", type: "water", x: 850, y: 470, width: 560, height: 170 },
      { id: "south_river_bend", type: "water", x: 1300, y: 960, width: 620, height: 180 },
      { id: "ford_shallows", type: "water", x: 1190, y: 740, width: 270, height: 120 },
      { id: "western_ruin_wall", type: "blocked", x: 780, y: 650, width: 250, height: 180 },
      { id: "central_broken_piers", type: "blocked", x: 1210, y: 835, width: 150, height: 130 },
      { id: "eastern_rockfall", type: "blocked", x: 1660, y: 640, width: 260, height: 170 },
      { id: "southern_old_keep", type: "blocked", x: 820, y: 1260, width: 190, height: 180 },
      { id: "northern_watch_ruins", type: "blocked", x: 1510, y: 300, width: 210, height: 160 }
    ],
    captureSites: [
      {
        id: "ford_toll",
        name: "Ford Toll",
        resource: "crowns",
        x: 1300,
        y: 850,
        radius: 82,
        incomeAmount: 34,
        incomeInterval: 5
      },
      {
        id: "west_stone_cut",
        name: "West Stone Cut",
        resource: "stone",
        x: 690,
        y: 1125,
        radius: 76,
        incomeAmount: 22,
        incomeInterval: 6
      },
      {
        id: "south_iron_cache",
        name: "South Iron Cache",
        resource: "iron",
        x: 1130,
        y: 1390,
        radius: 76,
        incomeAmount: 18,
        incomeInterval: 6
      },
      {
        id: "north_aether_spring",
        name: "North Aether Spring",
        resource: "aether",
        x: 1570,
        y: 430,
        radius: 76,
        incomeAmount: 14,
        incomeInterval: 6
      }
    ],
    neutralCamps: [
      {
        id: "west_bank_pack",
        name: "West Bank Pack",
        x: 820,
        y: 1290,
        unitIds: ["wild_hound", "wild_hound", "stone_imp"]
      },
      {
        id: "east_bank_imps",
        name: "East Bank Imps",
        x: 1740,
        y: 555,
        unitIds: ["stone_imp", "stone_imp", "wild_hound"]
      },
      {
        id: "ford_guardians",
        name: "Ford Guardians",
        x: 1320,
        y: 760,
        unitIds: ["stone_imp", "stone_imp", "wild_hound", "wild_hound"]
      }
    ],
    scenario: {
      startingResources: {
        player: STARTING_PLAYER_RESOURCES,
        enemy: STARTING_ENEMY_RESOURCES
      },
      heroSpawn: { x: 360, y: 1270 },
      buildingSpawns: [
        { id: "player_command_hall", buildingId: "command_hall", team: "player", x: 290, y: 1320 },
        { id: "enemy_stronghold", buildingId: "enemy_stronghold", team: "enemy", x: 2320, y: 330 },
        { id: "enemy_barracks", buildingId: "enemy_barracks", team: "enemy", x: 2190, y: 435 }
      ],
      unitSpawns: [
        { id: "player_militia_1", unitId: "militia", team: "player", x: 385, y: 1370 },
        { id: "player_militia_2", unitId: "militia", team: "player", x: 430, y: 1350 },
        { id: "player_ranger_1", unitId: "ranger", team: "player", x: 405, y: 1235 },
        { id: "enemy_raider_1", unitId: "raider", team: "enemy", x: 2235, y: 295 },
        { id: "enemy_raider_2", unitId: "raider", team: "enemy", x: 2200, y: 330 },
        { id: "enemy_hexer_1", unitId: "hexer", team: "enemy", x: 2265, y: 405 },
        { id: "enemy_brute_1", unitId: "brute", team: "enemy", x: 2345, y: 465 },
        { id: "enemy_commander_1", unitId: "enemy_commander", team: "enemy", x: 2365, y: 245 }
      ],
      objectives: {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold"
      },
      enemyAI: {
        incomeInterval: 5,
        incomePerTick: { crowns: 95, stone: 48, iron: 48, aether: 36 },
        trainInterval: 5.7,
        expandInterval: 24,
        initialExpandDelay: 20,
        attackInterval: 66,
        initialAttackDelay: 190,
        minAttackArmySize: 2,
        attackWaveSize: 7,
        expandSquadSize: 2,
        defenseSquadSize: 6,
        defendRadius: 430,
        baseBuildingId: "enemy_stronghold",
        productionBuildingId: "enemy_barracks",
        attackTargetBuildingId: "command_hall",
        unitPlan: ["raider", "raider", "hexer", "raider", "brute"]
      },
      rewardTableId: "broken_ford_rewards"
    }
  };
