import type { BattleMapDefinition } from "../../core/GameTypes";

export const CINDERFEN_CAUSEWAY_MAP: BattleMapDefinition = {
    id: "cinderfen_causeway",
    name: "Cinderfen Causeway",
    role: "Chapter 2 ash-marsh crossing",
    description:
      "A burned road through ash marsh and cinder pools, with side economy routes and one contested Cinder Shrine at the crossing.",
    strategicNotes: [
      "The Cinder Shrine is a tempo prize: first capture releases a small one-time Aether surge, then the site becomes normal Aether income.",
      "The northern reed shelf gives a safer Stone route before the final push; the southern iron cache is useful but slower to secure.",
      "Swamp and ashglass pools shape the lanes without adding new terrain systems, workers, enemy construction, or new factions."
    ],
    width: 2600,
    height: 1700,
    playerStart: { x: 285, y: 1375 },
    enemyStart: { x: 2320, y: 315 },
    visualPaths: [
      {
        id: "burned_causeway",
        width: 54,
        points: [
          { x: 120, y: 1430 },
          { x: 430, y: 1345 },
          { x: 720, y: 1205 },
          { x: 1000, y: 1010 },
          { x: 1280, y: 850 },
          { x: 1570, y: 695 },
          { x: 1900, y: 520 },
          { x: 2220, y: 390 },
          { x: 2480, y: 280 }
        ]
      },
      {
        id: "north_reed_shelf",
        width: 34,
        points: [
          { x: 430, y: 1265 },
          { x: 640, y: 1095 },
          { x: 880, y: 930 },
          { x: 1120, y: 820 },
          { x: 1360, y: 735 },
          { x: 1640, y: 610 }
        ]
      },
      {
        id: "south_iron_embankment",
        width: 34,
        points: [
          { x: 520, y: 1450 },
          { x: 820, y: 1515 },
          { x: 1080, y: 1440 },
          { x: 1310, y: 1310 },
          { x: 1540, y: 1140 }
        ]
      },
      {
        id: "crossing_spur",
        width: 42,
        points: [
          { x: 1240, y: 940 },
          { x: 1375, y: 825 },
          { x: 1515, y: 735 }
        ]
      }
    ],
    terrainZones: [
      { id: "cinderfen_grass", type: "grass", x: 0, y: 0, width: 2600, height: 1700 },
      { id: "player_build", type: "buildable", x: 70, y: 1160, width: 650, height: 470 },
      { id: "enemy_build", type: "buildable", x: 1970, y: 95, width: 560, height: 500 },
      { id: "west_cinder_pool", type: "water", x: 380, y: 885, width: 330, height: 170 },
      { id: "north_ash_marsh", type: "water", x: 700, y: 520, width: 560, height: 170 },
      { id: "south_black_reeds", type: "water", x: 1010, y: 1235, width: 610, height: 170 },
      { id: "east_cinder_pool", type: "water", x: 1525, y: 835, width: 500, height: 160 },
      { id: "west_ashglass_outcrop", type: "blocked", x: 790, y: 760, width: 190, height: 175 },
      { id: "central_glass_ribs", type: "blocked", x: 1155, y: 885, width: 150, height: 120 },
      { id: "eastern_burned_cairn", type: "blocked", x: 1690, y: 565, width: 230, height: 160 },
      { id: "north_waystone_ruin", type: "blocked", x: 1435, y: 320, width: 220, height: 150 },
      { id: "south_sunken_cart", type: "blocked", x: 760, y: 1360, width: 190, height: 150 }
    ],
    captureSites: [
      {
        id: "causeway_toll",
        name: "Causeway Toll",
        resource: "crowns",
        x: 620,
        y: 1220,
        radius: 78,
        incomeAmount: 30,
        incomeInterval: 5
      },
      {
        id: "reedcut_quarry",
        name: "Reedcut Quarry",
        resource: "stone",
        x: 925,
        y: 965,
        radius: 76,
        incomeAmount: 22,
        incomeInterval: 6
      },
      {
        id: "sunken_iron_cache",
        name: "Sunken Iron Cache",
        resource: "iron",
        x: 1200,
        y: 1395,
        radius: 76,
        incomeAmount: 18,
        incomeInterval: 6
      },
      {
        id: "cinder_crossing",
        name: "Cinder Shrine",
        resource: "aether",
        x: 1430,
        y: 780,
        radius: 84,
        incomeAmount: 16,
        incomeInterval: 6,
        firstCaptureBonus: {
          id: "cinder_shrine_surge",
          label: "Cinder Shrine Surge",
          description: "First claim grants +20 Aether once; Shrine Attunement raises that first surge to +25. Later captures only restart normal income.",
          resources: { aether: 20 }
        }
      }
    ],
    neutralCamps: [
      {
        id: "reedcut_raiders",
        name: "Reedcut Raiders",
        x: 1050,
        y: 900,
        unitIds: ["raider", "raider"]
      },
      {
        id: "sunken_hexfire_pickets",
        name: "Sunken Hexfire Pickets",
        x: 1320,
        y: 1290,
        unitIds: ["raider", "hexer"]
      },
      {
        id: "cinder_guardians",
        name: "Cinder Guardians",
        x: 1510,
        y: 700,
        unitIds: ["hexer", "brute", "raider"]
      }
    ],
    scenario: {
      startingResources: {
        player: {
          crowns: 480,
          stone: 325,
          iron: 195,
          aether: 110
        },
        enemy: {
          crowns: 250,
          stone: 195,
          iron: 140,
          aether: 100
        }
      },
      heroSpawn: { x: 365, y: 1325 },
      buildingSpawns: [
        { id: "player_command_hall", buildingId: "command_hall", team: "player", x: 285, y: 1375 },
        { id: "enemy_stronghold", buildingId: "enemy_stronghold", team: "enemy", x: 2320, y: 315 },
        { id: "enemy_barracks", buildingId: "enemy_barracks", team: "enemy", x: 2185, y: 430 },
        { id: "enemy_causeway_watchtower", buildingId: "watchtower", team: "enemy", x: 2075, y: 535 }
      ],
      unitSpawns: [
        { id: "player_militia_1", unitId: "militia", team: "player", x: 385, y: 1418 },
        { id: "player_militia_2", unitId: "militia", team: "player", x: 430, y: 1398 },
        { id: "player_militia_3", unitId: "militia", team: "player", x: 455, y: 1356 },
        { id: "player_ranger_1", unitId: "ranger", team: "player", x: 405, y: 1282 },
        { id: "enemy_raider_1", unitId: "raider", team: "enemy", x: 2238, y: 300 },
        { id: "enemy_raider_2", unitId: "raider", team: "enemy", x: 2202, y: 335 },
        { id: "enemy_hexer_1", unitId: "hexer", team: "enemy", x: 2268, y: 405 },
        { id: "enemy_commander_1", unitId: "enemy_commander", team: "enemy", x: 2365, y: 258 }
      ],
      objectives: {
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold",
        secondaryObjectives: [
          {
            id: "capture_cinder_crossing",
            name: "Claim the Cinder Shrine",
            description: "Take side income if needed, then claim Cinder Shrine Surge (+20 Aether once) and hold the shrine.",
            type: "capture_site",
            targetId: "cinder_crossing"
          },
          {
            id: "clear_cinder_guardians",
            name: "Clear Cinder Guardians",
            description: "Defeat the Brute and Hexer so the center road stops splitting your army.",
            type: "defeat_unit",
            targetId: "brute"
          },
          {
            id: "destroy_cinderfen_barracks",
            name: "Destroy Enemy Barracks",
            description: "Break Ashen production before committing your army to the Stronghold.",
            type: "destroy_building",
            targetId: "enemy_barracks"
          }
        ]
      },
      enemyAI: {
        incomeInterval: 5,
        incomePerTick: { crowns: 80, stone: 40, iron: 36, aether: 30 },
        trainInterval: 6.4,
        expandInterval: 24,
        initialExpandDelay: 24,
        attackInterval: 76,
        initialAttackDelay: 210,
        minAttackArmySize: 3,
        attackWaveSize: 5,
        expandSquadSize: 2,
        defenseSquadSize: 5,
        defendRadius: 420,
        baseBuildingId: "enemy_stronghold",
        productionBuildingId: "enemy_barracks",
        attackTargetBuildingId: "command_hall",
        unitPlan: ["raider", "hexer", "raider", "hexer", "raider"]
      },
      rewardTableId: "cinderfen_causeway_rewards"
    }
  };
