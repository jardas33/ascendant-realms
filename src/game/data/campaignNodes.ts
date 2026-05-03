import type { CampaignNodeDefinition } from "../core/GameTypes";

export const CAMPAIGN_NODES: CampaignNodeDefinition[] = [
  {
    id: "border_village",
    name: "Border Village",
    description: "Tutorial battle. Secure a Free Marches village by learning the core loop: capture the Crown Shrine, build a Barracks, train troops, defend the first wave, and destroy the enemy Stronghold.",
    chapterId: "border_marches",
    nodeType: "battle",
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
    description: "First real battle. The old trade road gives you less breathing room than Border Village, but it is still an Easy fight built to reward cleaner expansion and better use of your hero rewards.",
    chapterId: "border_marches",
    nodeType: "battle",
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
      "Allied town node. Spend campaign resources between battles for rest, volunteers, supplies, or a small fixed stock of early equipment. Services keep the camp open for later visits.",
    chapterId: "border_marches",
    nodeType: "town",
    difficulty: "story",
    mapId: "first_claim",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "balanced_warlord",
    prerequisites: ["old_stone_road"],
    rewards: {},
    eventText:
      "Canvas tents, field kitchens, and forge smoke gather under Free Marches banners. The quartermaster can turn saved Crowns into a little momentum before the next road.",
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
    description: "Harder battle. Broken Ford introduces tighter lanes, fog pressure, and a dangerous central objective. Prepare your hero before taking the well.",
    chapterId: "border_marches",
    nodeType: "battle",
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
    description: "Harder battle. A raider-backed hillfort checks whether you can build a stable army while holding resources under pressure.",
    chapterId: "border_marches",
    nodeType: "battle",
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
    name: "Chapel of the Marches",
    description: "Campaign choice node. A roadside chapel shelters wounded scouts and old oaths. Choose a blessing, spend campaign resources, or ask for guidance before the next fight.",
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
        description: "Spend campaign supplies to restore the signal fire. The Marches remember visible acts of stewardship.",
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
    description: "Campaign choice node. A weary caravan carries news, hungry families, and a few hands still able to hold a spear. Your decision trades resources, reputation, and rewards.",
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
        description: "Assign supplies and outriders to escort the families. It is costly, but the Marches will know who stood guard.",
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
      "Milestone battle. Assault the Ashen fortress map, capture the Burned Shrine if you can, break enemy production, and destroy the fortified Stronghold.",
    chapterId: "border_marches",
    nodeType: "battle",
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
  },
  {
    id: "cinderfen_overlook",
    name: "Cinderfen Road",
    description:
      "Chapter 2 scaffold. Scouts can see the ash-glass wetlands beyond Ashen Outpost, but this route is not playable in the current prototype.",
    chapterId: "cinderfen_road",
    nodeType: "event",
    difficulty: "story",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    isPlaceholder: true,
    placeholderLabel: "Chapter 2 upcoming",
    placeholderDescription:
      "The Cinderfen Road will become the v0.3 Chapter 2 vertical slice. This placeholder is visible for planning only and cannot be resolved yet.",
    futureMapName: "Cinderfen Causeway",
    prerequisites: ["ashen_outpost"],
    rewards: {},
    eventText:
      "Black reeds bend around a glassy causeway. Marcher scouts mark a future route, but the campaign does not enter the Cinderfen yet.",
    unlocks: ["cinderfen_crossing"],
    x: 72,
    y: 84
  },
  {
    id: "cinderfen_crossing",
    name: "Cinderfen Crossing",
    description:
      "Future Chapter 2 battle placeholder. The planned Cinderfen Causeway map is intentionally not implemented yet, so this node stays locked and cannot launch combat.",
    chapterId: "cinderfen_road",
    nodeType: "battle",
    difficulty: "normal",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    isPlaceholder: true,
    placeholderLabel: "Future battle locked",
    placeholderDescription:
      "Requires the future Cinderfen Causeway battle map. This node exists only so Chapter 2 can be previewed safely before content implementation.",
    futureMapName: "Cinderfen Causeway",
    prerequisites: ["ashen_outpost", "cinderfen_overlook"],
    rewards: {},
    unlocks: [],
    x: 82,
    y: 70
  }
];
