import type { RetinueUnitSaveData } from "../save/SaveTypes";
import type { PlaytestStrongholdProfileDefinition } from "./PlaytestTypes";

export const DEFAULT_PLAYTEST_STRONGHOLD_PROFILES: PlaytestStrongholdProfileDefinition[] = [
  {
    id: "no_stronghold",
    name: "No Stronghold upgrades",
    description: "Baseline campaign battles with no persistent Stronghold purchases.",
    targetUpgradeIds: []
  },
  {
    id: "training_yard_path",
    name: "Training Yard path",
    description: "Buys Training Yard I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["training_yard_i"]
  },
  {
    id: "defensive_watch_post_path",
    name: "Defensive Watch Post path",
    description: "Buys Watch Post I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["watch_post_i"]
  },
  {
    id: "economy_quartermaster_path",
    name: "Economy Quartermaster path",
    description: "Buys Quartermaster Stores I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["quartermaster_stores_i"]
  },
  {
    id: "tier_two_quartermaster_path",
    name: "Tier II Quartermaster path",
    description: "Buys Quartermaster Stores I and II as soon as normal campaign rewards can fund them.",
    targetUpgradeIds: ["quartermaster_stores_i", "quartermaster_stores_ii"]
  },
  {
    id: "chapel_corner_path",
    name: "Chapel Corner path",
    description: "Buys Chapel Corner I as soon as normal campaign rewards can fund it.",
    targetUpgradeIds: ["chapel_corner_i"]
  },
  {
    id: "ranger_paths_path",
    name: "Ranger Paths path",
    description: "Buys Training Yard I and Ranger Paths I when normal campaign rewards can fund them.",
    targetUpgradeIds: ["training_yard_i", "ranger_paths_i"]
  },
  {
    id: "retinue_veteran_militia",
    name: "Retinue: Veteran Militia",
    description: "Baseline campaign battles with one saved Veteran Militia deployed from the retinue.",
    targetUpgradeIds: [],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-veteran-militia", "militia", "veteran", 140, 3)
    ]
  },
  {
    id: "retinue_veteran_ranger",
    name: "Retinue: Veteran Ranger",
    description: "Baseline campaign battles with one saved Veteran Ranger deployed from the retinue.",
    targetUpgradeIds: [],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-veteran-ranger", "ranger", "veteran", 140, 3)
    ]
  },
  {
    id: "retinue_mixed_veterans",
    name: "Retinue: Mixed Veterans",
    description: "Baseline campaign battles with one Veteran Militia and one Seasoned Ranger deployed from the retinue.",
    targetUpgradeIds: [],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-mixed-militia", "militia", "veteran", 140, 3),
      createSimRetinueUnit("sim-retinue-mixed-ranger", "ranger", "seasoned", 65, 1)
    ]
  },
  {
    id: "retinue_training_yard_path",
    name: "Retinue + Training Yard II",
    description: "Mixed retinue pressure combined with Training Yard I and II, including the third capacity slot once affordable.",
    targetUpgradeIds: ["training_yard_i", "training_yard_ii"],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-yard-militia", "militia", "veteran", 140, 3),
      createSimRetinueUnit("sim-retinue-yard-ranger", "ranger", "seasoned", 65, 1),
      createSimRetinueUnit("sim-retinue-yard-second-militia", "militia", "seasoned", 65, 1)
    ]
  },
  {
    id: "retinue_quartermaster_path",
    name: "Retinue + Quartermaster II",
    description: "Mixed retinue pressure combined with the Quartermaster I and II starter-resource path.",
    targetUpgradeIds: ["quartermaster_stores_i", "quartermaster_stores_ii"],
    retinueUnits: [
      createSimRetinueUnit("sim-retinue-quartermaster-militia", "militia", "veteran", 140, 3),
      createSimRetinueUnit("sim-retinue-quartermaster-ranger", "ranger", "seasoned", 65, 1)
    ]
  },
  {
    id: "waystation_shrine_attunement",
    name: "Waystation: Shrine Attunement",
    description: "Models the Cinderfen Waystation Shrine Attunement service on Chapter 2 battles only.",
    targetUpgradeIds: [],
    campaignModifierIds: ["shrine_attunement"]
  }
];


function createSimRetinueUnit(
  retinueUnitId: string,
  unitTypeId: string,
  rank: RetinueUnitSaveData["rank"],
  xp: number,
  kills: number
): RetinueUnitSaveData {
  return {
    retinueUnitId,
    unitTypeId,
    rank,
    xp,
    kills,
    sourceBattleId: "playtest_retinue",
    acquiredAt: "2026-05-02T00:00:00.000Z",
    status: "active"
  };
}
