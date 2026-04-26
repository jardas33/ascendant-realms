import type { FactionDefinition } from "../core/GameTypes";

export const FACTIONS: FactionDefinition[] = [
  {
    id: "free_marches",
    name: "The Free Marches",
    fantasy: "Border-town militias, scouts, and oathbound mystics fighting for self-rule.",
    color: 0x4f8f68,
    mechanics: {
      economyStyle: "Balanced site economy with strong campaign support from trusted local communities.",
      militaryStyle: "Reliable infantry, Rangers, defensive Watchtowers, and leadership scaling.",
      magicStyle: "Supportive Acolytes and hero-led blessings rather than raw burst damage.",
      availableUnitIds: ["militia", "ranger", "acolyte"],
      availableBuildingIds: ["command_hall", "barracks", "mystic_lodge", "watchtower"],
      availableUpgradeIds: ["infantry_weapons_1", "ranger_training_1", "reinforced_armor_1", "aether_study_1"],
      aiPersonalityPreferences: ["balanced_warlord", "fortress_keeper"],
      campaignReputationHooks: ["free_marches", "common_folk", "old_faith"],
      factionModifiers: []
    }
  },
  {
    id: "ashen_covenant",
    name: "Ashen Covenant",
    fantasy: "A ruthless warband culture built around raiders, hex-magic, and brutal champions.",
    color: 0xb64b42,
    mechanics: {
      economyStyle: "Aggressive low-cost early pressure with less interest in defensive staying power.",
      militaryStyle: "Cheap Raiders, hard-hitting waves, fragile casters, and Brutes as the durable exception.",
      magicStyle: "Hexfire pressure applies burn damage and punishes clumped or wounded troops.",
      availableUnitIds: ["raider", "hexer", "brute", "enemy_commander"],
      availableBuildingIds: ["enemy_stronghold", "enemy_barracks"],
      availableUpgradeIds: ["ember_blades_trait"],
      aiPersonalityPreferences: ["raider_rush", "hexfire_cult", "balanced_warlord"],
      campaignReputationHooks: ["ashen_covenant", "common_folk"],
      factionModifiers: [
        {
          id: "hexfire_burn",
          name: "Hexfire Burn",
          description: "Hexers apply a short burn that deals damage over time.",
          type: "burn-on-hit",
          unitIds: ["hexer"],
          burn: {
            damagePerSecond: 3,
            durationSeconds: 4,
            tickInterval: 1
          }
        },
        {
          id: "ashen_fury",
          name: "Ashen Fury",
          description: "Ashen units deal more damage while below half health.",
          type: "low-health-damage",
          unitIds: ["raider", "hexer", "brute", "enemy_commander"],
          hpThreshold: 0.5,
          damageMultiplier: 1.15
        },
        {
          id: "smoke_march",
          name: "Smoke March",
          description: "Ashen attack waves are trained for faster forward pressure.",
          type: "wave-speed",
          unitIds: ["raider", "hexer"],
          speedMultiplier: 1.06
        }
      ]
    }
  },
  {
    id: "sylvan_concord",
    name: "Sylvan Concord",
    fantasy: "Future faction: forest spirits, wardens, beasts, and living sanctuaries.",
    color: 0x6ab06e,
    mechanics: {
      economyStyle: "Future nature economy placeholder.",
      militaryStyle: "Future resilient wardens, beasts, and living sanctuaries.",
      magicStyle: "Future growth, roots, and restoration magic.",
      availableUnitIds: [],
      availableBuildingIds: [],
      availableUpgradeIds: [],
      aiPersonalityPreferences: ["balanced_warlord"],
      campaignReputationHooks: ["sylvan_concord"],
      factionModifiers: []
    }
  },
  {
    id: "common_folk",
    name: "Common Folk",
    fantasy: "Villagers, caravan families, refugees, and town elders whose trust shapes the border roads.",
    color: 0xd6b46f,
    mechanics: {
      economyStyle: "Campaign reputation group, not a battle faction.",
      militaryStyle: "Provides local support and volunteers through campaign choices.",
      magicStyle: "None.",
      availableUnitIds: [],
      availableBuildingIds: [],
      availableUpgradeIds: [],
      aiPersonalityPreferences: ["balanced_warlord"],
      campaignReputationHooks: ["common_folk"],
      factionModifiers: []
    }
  },
  {
    id: "old_faith",
    name: "Old Faith",
    fantasy: "Chapel keepers, road shrines, and quiet rural rites that still bind the Marches together.",
    color: 0x8ed6bb,
    mechanics: {
      economyStyle: "Campaign reputation group, not a battle faction.",
      militaryStyle: "Blessings, recovery, and guidance through shrine choices.",
      magicStyle: "Protective rites and road blessings.",
      availableUnitIds: [],
      availableBuildingIds: [],
      availableUpgradeIds: [],
      aiPersonalityPreferences: ["balanced_warlord"],
      campaignReputationHooks: ["old_faith"],
      factionModifiers: []
    }
  },
  {
    id: "wilds",
    name: "Untamed Wilds",
    fantasy: "Neutral beasts and wandering monsters that guard old places of power.",
    color: 0x8b6f43,
    mechanics: {
      economyStyle: "Neutral camps guard resources rather than using economy.",
      militaryStyle: "Small territorial monster packs.",
      magicStyle: "None yet.",
      availableUnitIds: ["wild_hound", "stone_imp"],
      availableBuildingIds: [],
      availableUpgradeIds: [],
      aiPersonalityPreferences: ["balanced_warlord"],
      campaignReputationHooks: [],
      factionModifiers: []
    }
  }
];
