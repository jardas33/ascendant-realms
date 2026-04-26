import type { BattleMapDefinition } from "../../core/GameTypes";

export const ASHEN_OUTPOST_MAP: BattleMapDefinition = {
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
  };
