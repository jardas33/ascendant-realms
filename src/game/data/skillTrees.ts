import type { SkillNodeDefinition, SkillTreeDefinition } from "../core/GameTypes";

export const SKILL_TREES: SkillTreeDefinition[] = [
  {
    id: "combat",
    name: "Warrior",
    description: "Damage, durability, and melee ability support.",
    buildArchetype: "warrior"
  },
  {
    id: "magic",
    name: "Seer",
    description: "Mana, cooldown, and ability support.",
    buildArchetype: "seer"
  },
  {
    id: "leadership",
    name: "Commander",
    description: "Army support, economy presence, and leadership aura support.",
    buildArchetype: "commander"
  }
];

export const SKILL_NODES: SkillNodeDefinition[] = [
  {
    id: "combat_drill",
    treeId: "combat",
    buildArchetype: "warrior",
    name: "Warrior Drill",
    description: "Warrior passive: +2 damage and +1 Might per rank.",
    maxRank: 3,
    costPerRank: 1,
    statModsPerRank: {
      damage: 2,
      might: 1
    }
  },
  {
    id: "combat_endurance",
    treeId: "combat",
    buildArchetype: "warrior",
    name: "Iron Endurance",
    description: "Warrior passive: +24 HP per rank.",
    maxRank: 3,
    costPerRank: 1,
    statModsPerRank: {
      maxHp: 24
    }
  },
  {
    id: "warlord_cleave",
    treeId: "combat",
    buildArchetype: "warrior",
    classId: "warlord",
    name: "Cleave",
    description: "Unlocks Cleave and upgrades it with +6 damage and -1s cooldown.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "cleave",
    abilityUpgrade: {
      abilityIds: ["cleave"],
      amountDelta: 6,
      cooldownDelta: -1,
      effectSummary: "Cleave: +6 damage and -1s cooldown."
    },
    requires: [{ skillId: "combat_drill", rank: 1 }]
  },
  {
    id: "magic_focus",
    treeId: "magic",
    buildArchetype: "seer",
    name: "Seer Focus",
    description: "Seer passive: +18 Mana and +1 Arcana per rank.",
    maxRank: 3,
    costPerRank: 1,
    statModsPerRank: {
      maxMana: 18,
      arcana: 1
    }
  },
  {
    id: "magic_warding",
    treeId: "magic",
    buildArchetype: "seer",
    name: "Aether Flow",
    description: "Seer support: +10 Mana per rank and learned abilities cost 4 less Mana.",
    maxRank: 2,
    costPerRank: 1,
    statModsPerRank: {
      maxMana: 10
    },
    abilityUpgrade: {
      abilityIds: "all",
      manaCostDelta: -4,
      effectSummary: "Learned abilities: -4 Mana cost."
    },
    requires: [{ skillId: "magic_focus", rank: 1 }]
  },
  {
    id: "arcanist_arcane_burst",
    treeId: "magic",
    buildArchetype: "seer",
    classId: "arcanist",
    name: "Arcane Burst",
    description: "Unlocks Arcane Burst and upgrades it with +4 damage and -1s cooldown.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "arcane_burst",
    abilityUpgrade: {
      abilityIds: ["arcane_burst"],
      amountDelta: 4,
      cooldownDelta: -1,
      effectSummary: "Arcane Burst: +4 damage and -1s cooldown."
    },
    requires: [{ skillId: "magic_focus", rank: 1 }]
  },
  {
    id: "arcanist_blink",
    treeId: "magic",
    buildArchetype: "seer",
    classId: "arcanist",
    name: "Blink",
    description: "Unlocks a short tactical teleport.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "blink",
    requires: [{ skillId: "magic_focus", rank: 2 }],
    hidden: true
  },
  {
    id: "leadership_presence",
    treeId: "leadership",
    buildArchetype: "commander",
    name: "Command Presence",
    description: "Commander passive: +1 Command and +8 HP per rank; Warlord Rally Banner reaches slightly farther.",
    maxRank: 3,
    costPerRank: 1,
    statModsPerRank: {
      command: 1,
      maxHp: 8
    },
    abilityUpgrade: {
      abilityIds: ["rally_banner"],
      radiusDelta: 8,
      durationDelta: 0.5,
      effectSummary: "Rally Banner: +8 radius and +0.5s duration per rank."
    }
  },
  {
    id: "leadership_field_rites",
    treeId: "leadership",
    buildArchetype: "commander",
    name: "Field Orders",
    description: "Commander support: +1 Faith and +10 Mana per rank.",
    maxRank: 3,
    costPerRank: 1,
    statModsPerRank: {
      faith: 1,
      maxMana: 10
    }
  },
  {
    id: "warlord_war_cry",
    treeId: "leadership",
    buildArchetype: "commander",
    classId: "warlord",
    name: "War Cry",
    description: "Unlocks War Cry and improves command bursts with +1s War Cry duration.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "war_cry",
    abilityUpgrade: {
      abilityIds: ["war_cry"],
      durationDelta: 1,
      effectSummary: "War Cry: +1s allied rally duration."
    },
    requires: [{ skillId: "leadership_presence", rank: 2 }]
  },
  {
    id: "shepherd_blessing",
    treeId: "leadership",
    buildArchetype: "commander",
    classId: "shepherd",
    name: "Blessing",
    description: "Unlocks an area support pulse for nearby allies.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "blessing",
    requires: [{ skillId: "leadership_field_rites", rank: 1 }],
    hidden: true
  },
  {
    id: "shepherd_sanctify_ground",
    treeId: "magic",
    buildArchetype: "seer",
    classId: "shepherd",
    name: "Sanctify Ground",
    description: "Unlocks a holy pulse that heals allies and harms enemies.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "sanctify_ground",
    requires: [{ skillId: "leadership_field_rites", rank: 2 }],
    hidden: true
  }
];
