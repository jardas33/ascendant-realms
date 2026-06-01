import type { CampaignNodeDefinition } from "../core/GameTypes";

export const BORDER_MARCHES_NODES: CampaignNodeDefinition[] = [
  {
    id: "border_village",
    name: "Salto Outskirts",
    description:
      "A first stand outside Salto: claim the Crown Shrine, raise production, and break the Ashen foothold.",
    chapterId: "border_marches",
    nodeType: "battle",
    missionTypeId: "skirmish_training",
    missionBriefing: {
      summary: "Start the persistent campaign at Salto with one clear loop: capture, build, train, defend, win.",
      primaryObjective: "Destroy the enemy Stronghold after securing Salto's Crown Shrine.",
      rewardPreview: "First clear: starter XP, Crowns, and the Weathered Command Sword.",
      afterActionSummary: "Salto's outskirts hold; Old Stone Road is the next push.",
      recommendedBuildHint: "Any build works here; focus on fundamentals."
    },
    difficulty: "easy",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "balanced_warlord",
    prerequisites: [],
    rewards: {
      xp: 30,
      resources: { crowns: 50 },
      itemIds: ["weathered_command_sword"]
    },
    unlocks: ["old_stone_road"],
    x: 12,
    y: 66
  },
  {
    id: "old_stone_road",
    name: "Old Stone Road",
    description:
      "The trade road tests a cleaner economy: more Workers, steadier production, and safer resource control.",
    chapterId: "border_marches",
    nodeType: "battle",
    missionTypeId: "control",
    missionBriefing: {
      summary: "Hold the old trade road by turning resources and Worker upkeep into a steadier army.",
      primaryObjective: "Destroy the enemy Stronghold after stabilizing road income.",
      rewardPreview: "First clear: XP and a balanced campaign resource bundle.",
      afterActionSummary: "The road opens into support choices and two deeper threats.",
      recommendedBuildHint: "Commander support helps turn resource control into a stable army."
    },
    scenarioModifierIds: ["mission_rich_veins"],
    difficulty: "easy",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "raider_rush",
    prerequisites: ["border_village"],
    rewards: {
      xp: 50,
      resources: { crowns: 60, stone: 45, iron: 15 }
    },
    unlocks: ["aether_well_ruins", "bandit_hillfort", "refugee_caravan", "marcher_camp"],
    x: 30,
    y: 52
  },
  {
    id: "marcher_camp",
    name: "Marcher Camp",
    description:
      "A Barrosan support camp where saved Crowns become rest, volunteers, supplies, or early gear.",
    chapterId: "border_marches",
    nodeType: "town",
    difficulty: "story",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "balanced_warlord",
    prerequisites: ["old_stone_road"],
    rewards: {},
    eventText:
      "Canvas tents, field kitchens, and forge smoke gather under Barrosan Freeholds banners. The quartermaster can turn saved Crowns into a little momentum before the next road.",
    choices: [
      {
        id: "rest_and_recovery",
        label: "Rest and Recovery",
        description: "Pay for healers, hot food, and a dry tent. Your hero begins the next battle with noticeably more staying power.",
        costs: { crowns: 30 },
        rewards: {
          modifierIds: ["well_rested"]
        },
        onceOnly: false,
        completesNode: false
      },
      {
        id: "hire_volunteers",
        label: "Hire Volunteers",
        description: "Hire local spearhands for one march. The next battle starts with one extra Militia near your Command Hall.",
        costs: { crowns: 50 },
        rewards: {
          modifierIds: ["inspired_militia"]
        },
        onceOnly: false,
        completesNode: false
      },
      {
        id: "buy_supplies",
        label: "Buy Supplies",
        description: "Trade coin for a compact bundle of Stone, Iron, and Aether for future campaign choices.",
        costs: { crowns: 40 },
        rewards: {
          resources: { stone: 30, iron: 18, aether: 10 }
        },
        onceOnly: false,
        completesNode: false
      },
      {
        id: "purchase_emberglass_wand",
        label: "Purchase Emberglass Wand",
        description: "Buy a common caster weapon from the camp's fixed stock.",
        costs: { crowns: 60 },
        rewards: {
          itemIds: ["emberglass_wand"]
        },
        stockItemId: "emberglass_wand",
        onceOnly: true,
        completesNode: false
      },
      {
        id: "purchase_marcher_plate",
        label: "Purchase Marcher Plate",
        description: "Commission a sturdy uncommon armor set from the camp smiths.",
        costs: { crowns: 75, iron: 15 },
        rewards: {
          itemIds: ["marcher_plate"]
        },
        stockItemId: "marcher_plate",
        onceOnly: true,
        completesNode: false
      },
      {
        id: "purchase_green_chapel_icon",
        label: "Purchase Green Chapel Icon",
        description: "Buy a trinket carried by healers and oathbound scouts.",
        costs: { crowns: 85, aether: 16 },
        rewards: {
          itemIds: ["green_chapel_icon"]
        },
        stockItemId: "green_chapel_icon",
        onceOnly: true,
        completesNode: false
      }
    ],
    unlocks: [],
    x: 36,
    y: 66
  },
  {
    id: "aether_well_ruins",
    name: "Aether Well Ruins",
    description:
      "A ruined well on Broken Ford pulls the fight toward site control, Worker assignment, and Lume pressure.",
    chapterId: "border_marches",
    nodeType: "battle",
    missionTypeId: "control",
    missionBriefing: {
      summary: "A tighter control mission around the ruined well, assigned Workers, and the Lume Surge.",
      primaryObjective: "Destroy the Ashen base after contesting the ruined well.",
      rewardPreview: "First clear: XP, Aether, Stone, and the Aether Lens.",
      afterActionSummary: "The well is guarded again, and the chapel route is exposed.",
      recommendedBuildHint: "Seer mana and cooldown support fit the longer aether fight."
    },
    scenarioModifierIds: ["mission_aether_surge"],
    difficulty: "normal",
    mapId: "broken_ford",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    enemyHeroId: "veyra_cinders",
    prerequisites: ["old_stone_road"],
    rewards: {
      xp: 80,
      resources: { stone: 45, aether: 65 },
      itemIds: ["aether_lens"]
    },
    unlocks: ["chapel_of_the_marches"],
    x: 52,
    y: 30
  },
  {
    id: "bandit_hillfort",
    name: "Bandit Hillfort",
    description:
      "A raider-backed hillfort forces a stable army timing before the rival pressure peaks.",
    chapterId: "border_marches",
    nodeType: "battle",
    missionTypeId: "assault",
    missionBriefing: {
      summary: "Treat the hillfort as a staged assault, not an early probe.",
      primaryObjective: "Defeat the commander threat and destroy the hillfort Stronghold.",
      rewardPreview: "First clear: XP, Iron-heavy resources, and the Captain's Seal.",
      afterActionSummary: "The hillfort falls, leaving the Ashen Outpost within reach.",
      recommendedBuildHint: "Warrior durability helps answer raider pressure and commander duels."
    },
    scenarioModifierIds: ["mission_enemy_patrols"],
    difficulty: "normal",
    mapId: "broken_ford",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "fortress_keeper",
    enemyHeroId: "gorak_emberhand",
    prerequisites: ["old_stone_road"],
    rewards: {
      xp: 80,
      resources: { crowns: 85, stone: 35, iron: 60 },
      itemIds: ["captains_seal"]
    },
    unlocks: ["ashen_outpost"],
    x: 56,
    y: 67
  },
  {
    id: "chapel_of_the_marches",
    name: "Chapel of the Barrosan Marches",
    description:
      "A roadside chapel offers one clear support choice before the outpost road.",
    chapterId: "border_marches",
    nodeType: "shrine",
    difficulty: "story",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "balanced_warlord",
    prerequisites: ["aether_well_ruins"],
    rewards: {},
    eventText:
      "Green candles still burn in the chapel crypt. The keeper offers one blessing freely, but deeper repairs will need stone, crowns, and a banner willing to be seen helping.",
    choices: [
      {
        id: "pray_for_strength",
        label: "Pray for Strength",
        description: "Take a quiet vigil with the wounded scouts. The chapel blesses the next road you march.",
        rewards: {
          xp: 40,
          resources: { aether: 20 },
          modifierIds: ["blessed_road"],
          reputationChanges: { old_faith: 3, common_folk: 1 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "repair_chapel",
        label: "Repair the Chapel",
        description: "Spend campaign supplies to restore the signal fire. The Barrosan Marches remember visible acts of stewardship.",
        costs: { crowns: 45, stone: 55 },
        rewards: {
          resources: { aether: 35 },
          itemIds: ["green_chapel_icon"],
          unlockNodeIds: ["ashen_outpost"],
          modifierIds: ["local_support"],
          removeModifierIds: ["angered_raiders"],
          reputationChanges: { free_marches: 2, old_faith: 6, common_folk: 2 },
          recoverHero: true
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "ask_for_guidance",
        label: "Ask for Guidance",
        description: "Scout the road ahead without closing the chapel. The keeper warns that Ashen Outpost needs a staged army, not an early probe.",
        rewards: {
          xp: 15,
          unlockNodeIds: ["refugee_caravan", "ashen_outpost"],
          reputationChanges: { old_faith: 1 }
        },
        onceOnly: true,
        completesNode: false
      }
    ],
    unlocks: ["ashen_outpost"],
    x: 74,
    y: 38
  },
  {
    id: "refugee_caravan",
    name: "Refugee Caravan",
    description:
      "A vulnerable caravan turns Act 1 into a reputation and resource choice, not another battle.",
    chapterId: "border_marches",
    nodeType: "event",
    difficulty: "story",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "balanced_warlord",
    prerequisites: ["old_stone_road"],
    rewards: {},
    eventText:
      "The caravan asks for protection before crossing open country. Your answer will travel faster than your army.",
    choices: [
      {
        id: "protect_them",
        label: "Protect Them",
        description: "Assign supplies and outriders to escort the families. It is costly, but the Barrosan Marches will know who stood guard.",
        costs: { crowns: 40 },
        rewards: {
          xp: 40,
          itemIds: ["scouts_bow"],
          modifierIds: ["inspired_militia"],
          reputationChanges: { common_folk: 8, free_marches: 2 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "recruit_volunteers",
        label: "Recruit Volunteers",
        description: "Offer food, order, and a banner. A few caravan guards become the seed of a stronger militia.",
        requirements: { heroLevel: 2 },
        costs: { crowns: 15 },
        rewards: {
          xp: 25,
          resources: { iron: 30 },
          itemIds: ["marcher_plate"],
          modifierIds: ["inspired_militia"],
          reputationChanges: { common_folk: -4, free_marches: 2 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "demand_tribute",
        label: "Demand Tribute",
        description: "Take coin for passage and leave the caravan to fend for itself. The purse grows; so does resentment.",
        rewards: {
          resources: { crowns: 65 },
          modifierIds: ["angered_raiders"],
          reputationChanges: { common_folk: -8, free_marches: -2, ashen_covenant: -3 }
        },
        onceOnly: true,
        completesNode: true
      }
    ],
    unlocks: [],
    x: 42,
    y: 80
  },
  {
    id: "ashen_outpost",
    name: "Ashen Outpost",
    description:
      "The Act 1 finale: secure a foothold, force Malrec's defense, and break the Ashen Outpost.",
    chapterId: "border_marches",
    nodeType: "battle",
    missionTypeId: "assault",
    missionBriefing: {
      summary: "A three-phase finale: foothold first, fortified line second, Captain Malrec last.",
      primaryObjective: "Defeat Captain Malrec and destroy the fortified Stronghold.",
      rewardPreview: "First clear: milestone XP/resources, Oathbound Aegis, Act 1 completion, and champion relic eligibility.",
      afterActionSummary: "Malrec's outpost is broken; Act 1 is complete and Cinderfen becomes reachable.",
      recommendedBuildHint: "Champion Hunt helps finish Malrec; Guarded Advance and Commander support help survive the fortified counter-pressure."
    },
    scenarioModifierIds: ["mission_fortified_enemy"],
    difficulty: "normal",
    mapId: "ashen_outpost",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    enemyHeroId: "captain_malrec",
    prerequisites: ["bandit_hillfort", "chapel_of_the_marches"],
    rewards: {
      xp: 100,
      resources: { crowns: 130, stone: 70, iron: 80, aether: 55 },
      itemIds: ["oathbound_aegis"]
    },
    unlocks: [],
    x: 88,
    y: 54
  }
];
