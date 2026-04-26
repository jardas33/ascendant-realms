import type { BattleMapDefinition } from "../core/GameTypes";
import { STARTING_ENEMY_RESOURCES, STARTING_PLAYER_RESOURCES } from "../core/Constants";

export const MAPS: BattleMapDefinition[] = [
  {
    id: "first_claim",
    name: "First Claim",
    role: "Balanced tutorial skirmish",
    description: "A readable first battlefield with a safe opening claim, nearby resources, and direct pressure lanes.",
    strategicNotes: [
      "Best first map for learning hero selection, capture sites, construction, training, and first-wave defense.",
      "The central Crown Shrine is close enough to teach expansion before the enemy becomes dangerous.",
      "Neutral camps sit near side resources so early exploration has clear risk and reward."
    ],
    width: 2400,
    height: 1600,
    playerStart: { x: 260, y: 800 },
    enemyStart: { x: 2140, y: 800 },
    visualPaths: [
      {
        id: "main_road",
        width: 48,
        points: [
          { x: 150, y: 840 },
          { x: 540, y: 830 },
          { x: 870, y: 760 },
          { x: 1160, y: 720 },
          { x: 1510, y: 690 },
          { x: 1870, y: 760 },
          { x: 2260, y: 805 }
        ]
      },
      {
        id: "north_spur",
        width: 30,
        points: [
          { x: 590, y: 1035 },
          { x: 740, y: 930 },
          { x: 845, y: 780 },
          { x: 1030, y: 555 },
          { x: 1180, y: 390 }
        ]
      },
      {
        id: "south_spur",
        width: 30,
        points: [
          { x: 1530, y: 1110 },
          { x: 1430, y: 1010 },
          { x: 1510, y: 810 },
          { x: 1580, y: 610 },
          { x: 1780, y: 585 }
        ]
      }
    ],
    terrainZones: [
      { id: "central_grass", type: "grass", x: 0, y: 0, width: 2400, height: 1600 },
      { id: "player_build", type: "buildable", x: 70, y: 590, width: 520, height: 440 },
      { id: "enemy_build", type: "buildable", x: 1800, y: 560, width: 520, height: 480 },
      { id: "north_water", type: "water", x: 720, y: 160, width: 380, height: 140 },
      { id: "south_water", type: "water", x: 1280, y: 1250, width: 420, height: 130 },
      { id: "broken_ridge", type: "blocked", x: 1060, y: 660, width: 260, height: 100 },
      { id: "old_ruins", type: "blocked", x: 820, y: 1030, width: 160, height: 140 }
    ],
    captureSites: [
      {
        id: "crown_shrine",
        name: "Crown Shrine",
        resource: "crowns",
        x: 850,
        y: 780,
        radius: 76,
        incomeAmount: 30,
        incomeInterval: 5
      },
      {
        id: "stone_quarry",
        name: "Stone Quarry",
        resource: "stone",
        x: 1180,
        y: 390,
        radius: 76,
        incomeAmount: 25,
        incomeInterval: 5
      },
      {
        id: "iron_vein",
        name: "Iron Vein",
        resource: "iron",
        x: 1390,
        y: 1010,
        radius: 76,
        incomeAmount: 20,
        incomeInterval: 5
      },
      {
        id: "aether_well",
        name: "Aether Well",
        resource: "aether",
        x: 1580,
        y: 610,
        radius: 76,
        incomeAmount: 15,
        incomeInterval: 5
      }
    ],
    neutralCamps: [
      {
        id: "sunken_road_pack",
        name: "Sunken Road Pack",
        x: 710,
        y: 1110,
        unitIds: ["wild_hound", "wild_hound", "stone_imp"]
      },
      {
        id: "quarry_imps",
        name: "Quarry Imps",
        x: 1160,
        y: 520,
        unitIds: ["stone_imp", "stone_imp"]
      },
      {
        id: "old_well_guard",
        name: "Old Well Guard",
        x: 1650,
        y: 760,
        unitIds: ["wild_hound", "stone_imp", "wild_hound"]
      }
    ],
    scenario: {
      startingResources: {
        player: STARTING_PLAYER_RESOURCES,
        enemy: STARTING_ENEMY_RESOURCES
      },
      heroSpawn: { x: 340, y: 760 },
      buildingSpawns: [
        { id: "player_command_hall", buildingId: "command_hall", team: "player", x: 260, y: 800 },
        { id: "enemy_stronghold", buildingId: "enemy_stronghold", team: "enemy", x: 2140, y: 800 },
        { id: "enemy_barracks", buildingId: "enemy_barracks", team: "enemy", x: 2010, y: 890 }
      ],
      unitSpawns: [
        { id: "player_militia_1", unitId: "militia", team: "player", x: 350, y: 845 },
        { id: "player_militia_2", unitId: "militia", team: "player", x: 390, y: 835 },
        { id: "player_ranger_1", unitId: "ranger", team: "player", x: 370, y: 715 },
        { id: "enemy_raider_1", unitId: "raider", team: "enemy", x: 2050, y: 740 },
        { id: "enemy_raider_2", unitId: "raider", team: "enemy", x: 2010, y: 760 },
        { id: "enemy_hexer_1", unitId: "hexer", team: "enemy", x: 2045, y: 825 },
        { id: "enemy_brute_1", unitId: "brute", team: "enemy", x: 2100, y: 870 },
        { id: "enemy_commander_1", unitId: "enemy_commander", team: "enemy", x: 2110, y: 705 }
      ],
      objectives: {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold"
      },
      enemyAI: {
        incomeInterval: 5,
        incomePerTick: { crowns: 90, stone: 45, iron: 45, aether: 35 },
        trainInterval: 5.4,
        expandInterval: 21,
        initialExpandDelay: 18,
        attackInterval: 62,
        initialAttackDelay: 180,
        minAttackArmySize: 2,
        attackWaveSize: 7,
        expandSquadSize: 2,
        defenseSquadSize: 6,
        defendRadius: 400,
        baseBuildingId: "enemy_stronghold",
        productionBuildingId: "enemy_barracks",
        attackTargetBuildingId: "command_hall",
        unitPlan: ["raider", "raider", "hexer", "raider", "brute"]
      },
      rewardTableId: "first_claim_rewards"
    }
  },
  {
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
  },
  {
    id: "ashen_outpost",
    name: "Ashen Outpost",
    role: "Mini-campaign fortress assault",
    description:
      "A scorched frontier outpost with ash roads, a burned central shrine, side supply paths, and a fortified Ashen base guarding the upper ridge.",
    strategicNotes: [
      "This is the current mini-campaign milestone map: the player should arrive with gear, skill points, and a working build order.",
      "The Burned Shrine is valuable but exposed to enemy towers and the central neutral camp.",
      "Side resources are safer staging points for a slower siege against the Ashen Stronghold."
    ],
    width: 2600,
    height: 1800,
    playerStart: { x: 300, y: 1500 },
    enemyStart: { x: 2320, y: 300 },
    visualPaths: [
      {
        id: "main_ash_road",
        width: 56,
        points: [
          { x: 110, y: 1540 },
          { x: 430, y: 1420 },
          { x: 720, y: 1240 },
          { x: 990, y: 1060 },
          { x: 1290, y: 900 },
          { x: 1570, y: 720 },
          { x: 1880, y: 560 },
          { x: 2260, y: 360 },
          { x: 2500, y: 255 }
        ]
      },
      {
        id: "northern_supply_path",
        width: 34,
        points: [
          { x: 560, y: 1320 },
          { x: 780, y: 1080 },
          { x: 1020, y: 820 },
          { x: 1240, y: 630 },
          { x: 1440, y: 500 },
          { x: 1680, y: 425 }
        ]
      },
      {
        id: "southern_cinder_path",
        width: 34,
        points: [
          { x: 470, y: 1580 },
          { x: 800, y: 1635 },
          { x: 1110, y: 1540 },
          { x: 1340, y: 1360 },
          { x: 1600, y: 1210 },
          { x: 1850, y: 1050 }
        ]
      },
      {
        id: "fortress_causeway",
        width: 46,
        points: [
          { x: 1720, y: 650 },
          { x: 1900, y: 570 },
          { x: 2050, y: 500 },
          { x: 2200, y: 420 },
          { x: 2380, y: 325 }
        ]
      }
    ],
    terrainZones: [
      { id: "ashen_outpost_grass", type: "grass", x: 0, y: 0, width: 2600, height: 1800 },
      { id: "player_build", type: "buildable", x: 60, y: 1260, width: 650, height: 470 },
      { id: "enemy_build", type: "buildable", x: 1940, y: 80, width: 600, height: 560 },
      { id: "northern_ember_scar", type: "water", x: 760, y: 420, width: 500, height: 150 },
      { id: "southern_cinder_marsh", type: "water", x: 1180, y: 1330, width: 560, height: 150 },
      { id: "western_burned_ridge", type: "blocked", x: 710, y: 900, width: 260, height: 210 },
      { id: "shrine_rubble_west", type: "blocked", x: 1140, y: 790, width: 150, height: 125 },
      { id: "shrine_rubble_east", type: "blocked", x: 1415, y: 900, width: 160, height: 130 },
      { id: "eastern_blackstone_outcrop", type: "blocked", x: 1660, y: 610, width: 280, height: 210 },
      { id: "outpost_outer_wall", type: "blocked", x: 1910, y: 750, width: 180, height: 280 },
      { id: "northern_watch_ruin", type: "blocked", x: 1510, y: 265, width: 220, height: 150 }
    ],
    captureSites: [
      {
        id: "burned_shrine",
        name: "Burned Shrine",
        resource: "aether",
        x: 1320,
        y: 900,
        radius: 86,
        incomeAmount: 26,
        incomeInterval: 5
      },
      {
        id: "west_supply_pyre",
        name: "West Supply Pyre",
        resource: "crowns",
        x: 720,
        y: 1250,
        radius: 76,
        incomeAmount: 30,
        incomeInterval: 6
      },
      {
        id: "south_iron_pit",
        name: "South Iron Pit",
        resource: "iron",
        x: 1160,
        y: 1540,
        radius: 76,
        incomeAmount: 22,
        incomeInterval: 6
      },
      {
        id: "north_stone_scar",
        name: "North Stone Scar",
        resource: "stone",
        x: 1460,
        y: 500,
        radius: 76,
        incomeAmount: 26,
        incomeInterval: 6
      }
    ],
    neutralCamps: [
      {
        id: "west_cinder_pack",
        name: "West Cinder Pack",
        x: 850,
        y: 1330,
        unitIds: ["wild_hound", "wild_hound", "stone_imp"]
      },
      {
        id: "north_ash_imps",
        name: "North Ash Imps",
        x: 1410,
        y: 630,
        unitIds: ["stone_imp", "stone_imp", "wild_hound"]
      },
      {
        id: "shrine_ember_guardians",
        name: "Shrine Ember Guardians",
        x: 1320,
        y: 790,
        unitIds: ["stone_imp", "stone_imp", "wild_hound", "wild_hound", "stone_imp"]
      }
    ],
    scenario: {
      startingResources: {
        player: {
          crowns: 420,
          stone: 280,
          iron: 150,
          aether: 90
        },
        enemy: {
          crowns: 320,
          stone: 230,
          iron: 190,
          aether: 150
        }
      },
      heroSpawn: { x: 370, y: 1445 },
      buildingSpawns: [
        { id: "player_command_hall", buildingId: "command_hall", team: "player", x: 300, y: 1500 },
        { id: "enemy_stronghold", buildingId: "enemy_stronghold", team: "enemy", x: 2320, y: 300 },
        { id: "enemy_barracks", buildingId: "enemy_barracks", team: "enemy", x: 2180, y: 430 },
        { id: "enemy_gate_watchtower", buildingId: "watchtower", team: "enemy", x: 2040, y: 570 },
        { id: "enemy_shrine_watchtower", buildingId: "watchtower", team: "enemy", x: 1780, y: 760 }
      ],
      unitSpawns: [
        { id: "player_militia_1", unitId: "militia", team: "player", x: 390, y: 1540 },
        { id: "player_militia_2", unitId: "militia", team: "player", x: 430, y: 1520 },
        { id: "player_militia_3", unitId: "militia", team: "player", x: 470, y: 1500 },
        { id: "player_ranger_1", unitId: "ranger", team: "player", x: 405, y: 1410 },
        { id: "enemy_raider_1", unitId: "raider", team: "enemy", x: 2235, y: 285 },
        { id: "enemy_raider_2", unitId: "raider", team: "enemy", x: 2200, y: 330 },
        { id: "enemy_hexer_1", unitId: "hexer", team: "enemy", x: 2265, y: 405 },
        { id: "enemy_brute_1", unitId: "brute", team: "enemy", x: 2345, y: 470 },
        { id: "enemy_commander_1", unitId: "enemy_commander", team: "enemy", x: 2365, y: 245 }
      ],
      objectives: {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold",
        secondaryObjectives: [
          {
            id: "capture_burned_shrine",
            name: "Capture the Burned Shrine",
            description: "Seize the central aether shrine before assaulting the fortress.",
            type: "capture_site",
            targetId: "burned_shrine"
          },
          {
            id: "destroy_enemy_barracks",
            name: "Destroy Enemy Barracks",
            description: "Break the outpost's production before the final push.",
            type: "destroy_building",
            targetId: "enemy_barracks"
          },
          {
            id: "defeat_outpost_captain",
            name: "Defeat the Outpost Captain",
            description: "Defeat the Ashen commander guarding the upper ridge.",
            type: "defeat_unit",
            targetId: "enemy_commander"
          }
        ]
      },
      enemyAI: {
        incomeInterval: 5,
        incomePerTick: { crowns: 110, stone: 55, iron: 55, aether: 45 },
        trainInterval: 5.2,
        expandInterval: 22,
        initialExpandDelay: 22,
        attackInterval: 60,
        initialAttackDelay: 205,
        minAttackArmySize: 3,
        attackWaveSize: 8,
        expandSquadSize: 2,
        defenseSquadSize: 8,
        defendRadius: 560,
        baseBuildingId: "enemy_stronghold",
        productionBuildingId: "enemy_barracks",
        attackTargetBuildingId: "command_hall",
        unitPlan: ["hexer", "raider", "hexer", "raider", "brute", "hexer"]
      },
      rewardTableId: "ashen_outpost_rewards"
    }
  }
];

export const DEFAULT_MAP_ID = "first_claim";
