import type { SkillNodeDefinition, SkillTreeDefinition } from "../core/GameTypes";

export const SKILL_TREES: SkillTreeDefinition[] = [
  {
    id: "combat",
    name: "Combat",
    description: "Personal damage, toughness, and front-line presence."
  },
  {
    id: "magic",
    name: "Magic",
    description: "Mana, spell power, and battlefield control."
  },
  {
    id: "leadership",
    name: "Leadership",
    description: "Command, army support, and force multiplication."
  }
];

export const SKILL_NODES: SkillNodeDefinition[] = [
  {
    id: "combat_drill",
    treeId: "combat",
    name: "Battle Drill",
    description: "Passive: +2 damage and +1 Might per rank.",
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
    name: "Endurance",
    description: "Passive: +24 HP per rank.",
    maxRank: 3,
    costPerRank: 1,
    statModsPerRank: {
      maxHp: 24
    }
  },
  {
    id: "warlord_cleave",
    treeId: "combat",
    classId: "warlord",
    name: "Cleave",
    description: "Unlocks the Warlord's short-range area strike.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "cleave",
    requires: [{ skillId: "combat_drill", rank: 1 }]
  },
  {
    id: "magic_focus",
    treeId: "magic",
    name: "Aether Focus",
    description: "Passive: +18 Mana and +1 Arcana per rank.",
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
    name: "Warding",
    description: "Passive: +1 armor per rank.",
    maxRank: 2,
    costPerRank: 1,
    statModsPerRank: {
      armor: 1
    }
  },
  {
    id: "arcanist_arcane_burst",
    treeId: "magic",
    classId: "arcanist",
    name: "Arcane Burst",
    description: "Unlocks an area spell around the nearest enemy.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "arcane_burst",
    requires: [{ skillId: "magic_focus", rank: 1 }]
  },
  {
    id: "arcanist_blink",
    treeId: "magic",
    classId: "arcanist",
    name: "Blink",
    description: "Unlocks a short tactical teleport.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "blink",
    requires: [{ skillId: "magic_focus", rank: 2 }]
  },
  {
    id: "leadership_presence",
    treeId: "leadership",
    name: "Command Presence",
    description: "Passive: +1 Command and +8 HP per rank.",
    maxRank: 3,
    costPerRank: 1,
    statModsPerRank: {
      command: 1,
      maxHp: 8
    }
  },
  {
    id: "leadership_field_rites",
    treeId: "leadership",
    name: "Field Rites",
    description: "Passive: +1 Faith and +10 Mana per rank.",
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
    classId: "warlord",
    name: "War Cry",
    description: "Unlocks a command shout that damages enemies and rallies allies.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "war_cry",
    requires: [{ skillId: "leadership_presence", rank: 2 }]
  },
  {
    id: "shepherd_blessing",
    treeId: "leadership",
    classId: "shepherd",
    name: "Blessing",
    description: "Unlocks an area support pulse for nearby allies.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "blessing",
    requires: [{ skillId: "leadership_field_rites", rank: 1 }]
  },
  {
    id: "shepherd_sanctify_ground",
    treeId: "magic",
    classId: "shepherd",
    name: "Sanctify Ground",
    description: "Unlocks a holy pulse that heals allies and harms enemies.",
    maxRank: 1,
    costPerRank: 1,
    unlockAbilityId: "sanctify_ground",
    requires: [{ skillId: "leadership_field_rites", rank: 2 }]
  }
];
