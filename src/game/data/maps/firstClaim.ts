import type { BattleMapDefinition } from "../../core/GameTypes";
import { STARTING_ENEMY_RESOURCES, STARTING_PLAYER_RESOURCES } from "../../core/Constants";

export const FIRST_CLAIM_MAP: BattleMapDefinition = {
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
  };
