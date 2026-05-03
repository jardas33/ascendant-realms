import type { CampaignNodeDefinition } from "../core/GameTypes";

export const CINDERFEN_ROAD_NODES: CampaignNodeDefinition[] = [
  {
    id: "cinderfen_overlook",
    name: "Cinderfen Road",
    description:
      "Chapter 2 event. From the last dry rise before the ash marsh, choose how the army prepares for the Cinderfen Causeway.",
    chapterId: "cinderfen_road",
    nodeType: "event",
    difficulty: "story",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    prerequisites: ["ashen_outpost"],
    rewards: {},
    eventText:
      "Black reeds bend around a glassy causeway. The scouts have found Ashen carts, refugee tracks, and old cinder-signs in the same marsh. There is time for one preparation before forcing the crossing.",
    choices: [
      {
        id: "scout_the_causeway",
        label: "Scout the Causeway",
        description:
          "Pay outriders to mark the burned road and Ashen supply caches. Their report warns of Hexfire cultists, a towered camp, and a central aether crossing worth holding.",
        costs: { crowns: 30 },
        rewards: {
          xp: 20,
          resources: { stone: 8 },
          modifierIds: ["local_support"],
          reputationChanges: { free_marches: 3, common_folk: 1 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "aid_marsh_refugees",
        label: "Aid the Marsh Refugees",
        description:
          "Spend coin and food to move stranded families off the blackwater path. A few local guides and spearhands pledge to march for one battle.",
        costs: { crowns: 55 },
        rewards: {
          xp: 25,
          resources: { iron: 10 },
          modifierIds: ["inspired_militia"],
          reputationChanges: { common_folk: 6, free_marches: 2 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "study_the_cinders",
        label: "Study the Cinders",
        description:
          "Offer Aether to the Old Faith readers and sift the hexfire residue. They find a safe omen, a reclaimed focus, and signs that no named Ashen rival commands the crossing yet.",
        costs: { aether: 24 },
        rewards: {
          xp: 20,
          itemIds: ["emberglass_wand"],
          modifierIds: ["blessed_road"],
          reputationChanges: { old_faith: 5, ashen_covenant: -2 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "raise_malrecs_standard",
        label: "Raise Malrec's Standard",
        description:
          "Unfurl Malrec's captured outpost banner at the marsh edge. The Ashen scouts remember the fortress falling, and the column marches with steadier hearts.",
        requirements: { rivalTrophyIds: ["trophy_malrec_outpost_standard"] },
        rewards: {
          xp: 10,
          modifierIds: ["well_rested"],
          reputationChanges: { free_marches: 3 }
        },
        onceOnly: true,
        completesNode: true
      }
    ],
    unlocks: ["cinderfen_waystation", "cinderfen_crossing"],
    x: 72,
    y: 84
  },
  {
    id: "cinderfen_waystation",
    name: "Cinderfen Waystation",
    description:
      "Chapter 2 support node. A cramped frontier stop trades marsh maps, ash filters, scouts, and shrine rites for one-battle Cinderfen preparation.",
    chapterId: "cinderfen_road",
    nodeType: "town",
    difficulty: "story",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    prerequisites: ["cinderfen_overlook"],
    rewards: {},
    eventText:
      "Lanterns burn behind reed screens while guides argue over drowned paths. The waystation can ready the army for Cinderfen, but every favor costs coin, Aether, or trust.",
    choices: [
      {
        id: "marsh_guides",
        label: "Marsh Guides",
        description:
          "Hire local pathfinders to mark firm ground and signal Ashen movement. The next Cinderfen battle gains earlier enemy warnings and wider base vision.",
        costs: { crowns: 35 },
        rewards: {
          modifierIds: ["marsh_guides"]
        },
        onceOnly: false,
        completesNode: false
      },
      {
        id: "ash_filters",
        label: "Ash Filters",
        description:
          "Fit the hero's guard with charcoal charms and gauze masks. The next Cinderfen battle starts your hero with a small HP and Mana buffer.",
        costs: { crowns: 35, aether: 15 },
        rewards: {
          modifierIds: ["ash_filters"]
        },
        onceOnly: false,
        completesNode: false
      },
      {
        id: "refugee_scouts",
        label: "Refugee Scouts",
        description:
          "Pay the families who know which causeway stones still hold. They confirm the Cinder Shrine and central guardians, and the Common Folk remember the help.",
        costs: { crowns: 25 },
        rewards: {
          xp: 10,
          reputationChanges: { common_folk: 2 }
        },
        onceOnly: true,
        completesNode: false
      },
      {
        id: "shrine_attunement",
        label: "Shrine Attunement",
        description:
          "Let Old Faith readers tune the army's focus to the ash-glass shrine. The next Cinderfen battle's Cinder Shrine Surge grants +5 extra Aether on first capture.",
        costs: { aether: 12 },
        rewards: {
          modifierIds: ["shrine_attunement"]
        },
        onceOnly: false,
        completesNode: false
      }
    ],
    unlocks: [],
    x: 58,
    y: 58
  },
  {
    id: "cinderfen_crossing",
    name: "Cinderfen Crossing",
    description:
      "First Chapter 2 battle. Cross the ash-glass wetlands, claim the Cinder Shrine for a one-time Aether surge, clear the central guardians, and break the Ashen staging camp across the causeway.",
    chapterId: "cinderfen_road",
    nodeType: "battle",
    difficulty: "normal",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    prerequisites: ["ashen_outpost", "cinderfen_overlook"],
    rewards: {
      xp: 60,
      resources: { crowns: 40, stone: 20, iron: 20, aether: 12 },
      itemIds: ["scouts_bow"]
    },
    unlocks: ["cinderfen_watch"],
    x: 82,
    y: 70
  },
  {
    id: "cinderfen_watch",
    name: "Cinderfen Watch",
    description:
      "Second Chapter 2 battle. Break an Ashen watchpost on the raised road, using fog scouting, the watch-road toll, and Waystation preparation to blunt a slightly stronger staging camp.",
    chapterId: "cinderfen_road",
    nodeType: "battle",
    difficulty: "normal",
    mapId: "cinderfen_watchpost",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    prerequisites: ["cinderfen_crossing"],
    rewards: {
      xp: 62,
      resources: { crowns: 40, stone: 22, iron: 18, aether: 10 }
    },
    unlocks: [],
    x: 92,
    y: 32
  }
];
