import type { CampaignNodeDefinition } from "../core/GameTypes";

export const CINDERFEN_ROAD_NODES: CampaignNodeDefinition[] = [
  {
    id: "cinderfen_overlook",
    name: "Cinderfen Overlook",
    description:
      "Chapter 2 opens here. Pick one preparation from the dry overlook before the army forces the Cinderfen Crossing.",
    chapterId: "cinderfen_road",
    nodeType: "event",
    difficulty: "story",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    prerequisites: ["ashen_outpost"],
    rewards: {},
    eventText:
      "Black reeds bend around a glassy causeway. Scouts report Ashen carts, refugee tracks, and old cinder-signs in the same marsh. There is time for one clear preparation.",
    choices: [
      {
        id: "scout_the_causeway",
        label: "Scout the Causeway",
        description:
          "Pay outriders to mark side paths, Ashen caches, and the central Aether crossing. Best for safer route knowledge before the first battle.",
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
          "Move stranded families off the blackwater path. Local guides and spearhands return the favor for one battle.",
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
          "Let Old Faith readers sift the hexfire residue. They recover a focus, a safe omen, and signs that no named Ashen rival commands the crossing.",
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
          "Optional trophy use. Raise Malrec's captured banner for a modest morale boost; it costs nothing and replaces the other preparations.",
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
      "Chapter 2 support stop. Buy short, one-battle Cinderfen preparations before Crossing or Watch.",
    chapterId: "cinderfen_road",
    nodeType: "town",
    difficulty: "story",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    prerequisites: ["cinderfen_overlook"],
    rewards: {},
    eventText:
      "Lanterns burn behind reed screens. Each service is brief and clear: some can be bought again, one scout report can only be claimed once.",
    choices: [
      {
        id: "marsh_guides",
        label: "Marsh Guides",
        description:
          "Repeatable. Mark firm ground and Ashen movement. Next Cinderfen battle: wider base vision and earlier enemy warnings.",
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
          "Repeatable. Fit masks and charcoal charms. Next Cinderfen battle: the hero starts with a small HP and Mana buffer.",
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
          "One-time. Local scouts confirm the Cinder Shrine and central guardians, then spread word that the army paid fairly.",
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
          "Repeatable. Tune the first Cinder Shrine capture. Next Cinderfen battle: Cinder Shrine Surge grants +5 extra Aether.",
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
      "First Chapter 2 battle. Secure side income, claim the Cinder Shrine for its first-capture Aether surge, then break the Ashen staging camp.",
    chapterId: "cinderfen_road",
    nodeType: "battle",
    missionTypeId: "control",
    missionBriefing: {
      summary: "The causeway is a control mission around side income and the first Cinder Shrine surge.",
      primaryObjective: "Secure side income, claim the shrine if safe, and break the Ashen staging camp.",
      rewardPreview: "First clear grants XP, modest campaign resources, and a Scout's Bow.",
      afterActionSummary: "The crossing is held and the route toward the watchpost opens.",
      recommendedBuildHint: "Seer or Commander builds help stretch ability uptime and site control."
    },
    scenarioModifierIds: ["mission_rich_veins", "mission_aether_surge"],
    difficulty: "normal",
    mapId: "cinderfen_causeway",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    enemyPressurePlanId: "causeway_contest_pressure",
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
      "Second Chapter 2 battle. Hold the raised road, scout the enemy watchpost, and break the fortified camp before the tower grinds down the push.",
    chapterId: "cinderfen_road",
    nodeType: "battle",
    missionTypeId: "defense",
    missionBriefing: {
      summary: "The watch road asks you to hold under Ashen pressure before the final push.",
      primaryObjective: "Protect your Command Hall, scout the watchpost, and destroy the fortified camp.",
      rewardPreview: "First clear grants XP and a compact campaign resource bundle.",
      afterActionSummary: "The raised road is secure enough for the current Cinderfen arc to close.",
      recommendedBuildHint: "Commander defense and Warrior durability both fit the hold-and-counter rhythm."
    },
    scenarioModifierIds: ["mission_enemy_patrols", "mission_fortified_enemy"],
    difficulty: "normal",
    mapId: "cinderfen_watchpost",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    enemyPressurePlanId: "ashen_watch_captain_pressure",
    prerequisites: ["cinderfen_crossing"],
    rewards: {
      xp: 62,
      resources: { crowns: 40, stone: 22, iron: 18, aether: 10 }
    },
    unlocks: ["cinderfen_aftermath"],
    x: 92,
    y: 32
  },
  {
    id: "cinderfen_aftermath",
    name: "Cinderfen Aftermath",
    description:
      "Current v0.3 route finale. Choose how the Watch Road is secured after the second Cinderfen battle.",
    chapterId: "cinderfen_road",
    nodeType: "event",
    difficulty: "story",
    mapId: "cinderfen_watchpost",
    enemyFactionId: "ashen_covenant",
    aiPersonalityId: "hexfire_cult",
    prerequisites: ["cinderfen_watch"],
    rewards: {},
    eventText:
      "Ash cools on the raised road. One modest settlement choice will secure the route and close the current playable Cinderfen arc.",
    choices: [
      {
        id: "secure_watch_road",
        label: "Secure the Watch Road",
        description:
          "Build barricades and signal fires. The Watch Road becomes a steadier Barrosan Freeholds foothold, with a little local support banked.",
        costs: { crowns: 45, stone: 18 },
        rewards: {
          xp: 12,
          resources: { stone: 10 },
          modifierIds: ["local_support"],
          reputationChanges: { free_marches: 4 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "aid_the_fenfolk",
        label: "Aid the Fenfolk",
        description:
          "Turn captured stores toward reedcutters and refugees. They cannot spare soldiers, but they send salvage and safer path names.",
        costs: { crowns: 40 },
        rewards: {
          xp: 12,
          resources: { iron: 8 },
          reputationChanges: { common_folk: 5 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "study_ashen_marks",
        label: "Study the Ashen Marks",
        description:
          "Let Old Faith readers catalogue the burned watch-stone sigils. They recover a pilgrim focus and a little clean Aether.",
        costs: { aether: 18 },
        rewards: {
          xp: 12,
          resources: { aether: 6 },
          itemIds: ["pilgrim_crook"],
          reputationChanges: { old_faith: 4, ashen_covenant: -1 }
        },
        onceOnly: true,
        completesNode: true
      },
      {
        id: "display_malrecs_standard",
        label: "Display Malrec's Standard",
        description:
          "Optional trophy use. Raise Malrec's captured banner over the road as a small warning to Ashen stragglers, not a major payout.",
        requirements: { rivalTrophyIds: ["trophy_malrec_outpost_standard"] },
        rewards: {
          reputationChanges: { free_marches: 1 }
        },
        onceOnly: true,
        completesNode: true
      }
    ],
    unlocks: [],
    x: 88,
    y: 14
  }
];
