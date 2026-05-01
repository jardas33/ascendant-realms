import type {
  BattleDifficultyDefinition,
  BattlePhaseDefinition,
  EnemyAIConfig,
  EnemyAIPersonalityDefinition,
  EnemyAIPersonalityId
} from "../core/GameTypes";

export const DEFAULT_AI_PERSONALITY_ID: EnemyAIPersonalityId = "balanced_warlord";

export const AI_PERSONALITIES: EnemyAIPersonalityDefinition[] = [
  {
    id: "balanced_warlord",
    name: "Balanced Warlord",
    shortDescription: "Mixed expansion and attacks.",
    description: "A standard enemy commander that expands, trains a mixed force, and attacks on the normal battle rhythm.",
    aggressionLevel: 0.55,
    preferredUnitIds: ["raider", "hexer", "brute"],
    unitPlan: ["raider", "raider", "hexer", "raider", "brute"],
    timing: {
      firstAttackDelayMultiplier: 1,
      attackIntervalMultiplier: 1,
      expandIntervalMultiplier: 1,
      trainIntervalMultiplier: 1,
      commanderJoinDelayMultiplier: 1
    },
    economy: {
      incomeMultiplier: 1
    },
    waves: {
      attackWaveSizeMultiplier: 1,
      minAttackArmySizeDelta: 0,
      phaseOverrides: {}
    },
    defense: {
      defendRadiusMultiplier: 1,
      defenseSquadSizeDelta: 0,
      reserveDefenseUnits: 0,
      protectCaptureSites: false
    },
    commander: {
      joinsFirstAttack: false
    },
    behaviorNotes: ["Default mixed army behavior.", "Good baseline for new maps and campaign tutorial nodes."]
  },
  {
    id: "raider_rush",
    name: "Raider Rush",
    shortDescription: "Early aggression, lighter units.",
    description: "A greedy-player punish profile that expands and attacks sooner with mostly Raiders, but scales worse into late assaults.",
    aggressionLevel: 0.85,
    preferredUnitIds: ["raider", "hexer"],
    unitPlan: ["raider", "raider", "raider", "hexer", "raider"],
    timing: {
      firstAttackDelayMultiplier: 0.86,
      attackIntervalMultiplier: 0.88,
      expandIntervalMultiplier: 0.82,
      trainIntervalMultiplier: 0.9,
      commanderJoinDelayMultiplier: 1.12
    },
    economy: {
      incomeMultiplier: 0.88
    },
    waves: {
      attackWaveSizeMultiplier: 0.9,
      minAttackArmySizeDelta: -1,
      phaseOverrides: {
        expansion: {
          maxAttackWaveSize: 3,
          allowedAttackUnitIds: ["raider", "hexer"],
          preferredAttackUnitIds: ["raider", "raider", "raider"],
          trainUnitIds: ["raider", "hexer"],
          maxAttackByUnitId: { raider: 3, hexer: 1 }
        },
        pressure: {
          maxAttackWaveSize: 5,
          allowedAttackUnitIds: ["raider", "hexer"],
          preferredAttackUnitIds: ["raider", "raider", "raider", "hexer", "raider"],
          trainUnitIds: ["raider", "hexer"],
          maxAttackByUnitId: { raider: 4, hexer: 1 }
        },
        assault: {
          maxAttackWaveSize: 6,
          allowedAttackUnitIds: ["raider", "hexer", "enemy_commander"],
          preferredAttackUnitIds: ["raider", "raider", "hexer", "raider", "enemy_commander", "raider"],
          trainUnitIds: ["raider", "hexer"],
          maxAttackByUnitId: { raider: 4, hexer: 1, enemy_commander: 1 }
        }
      }
    },
    defense: {
      defendRadiusMultiplier: 0.85,
      defenseSquadSizeDelta: -1,
      reserveDefenseUnits: 0,
      protectCaptureSites: false
    },
    commander: {
      joinsFirstAttack: false
    },
    behaviorNotes: ["Attacks and expands faster.", "Relies on light units and loses some late-game staying power."]
  },
  {
    id: "fortress_keeper",
    name: "Fortress Keeper",
    shortDescription: "Slower attacks, stronger defense.",
    description: "A defensive commander that holds resources, keeps units near home, and waits for heavier waves before committing.",
    aggressionLevel: 0.35,
    preferredUnitIds: ["brute", "raider", "hexer"],
    unitPlan: ["raider", "brute", "raider", "hexer", "brute"],
    timing: {
      firstAttackDelayMultiplier: 1.22,
      attackIntervalMultiplier: 1.18,
      expandIntervalMultiplier: 1.12,
      trainIntervalMultiplier: 1.25,
      commanderJoinDelayMultiplier: 1.05
    },
    economy: {
      incomeMultiplier: 0.94
    },
    waves: {
      attackWaveSizeMultiplier: 1,
      minAttackArmySizeDelta: 1,
      phaseOverrides: {
        expansion: {
          maxAttackWaveSize: 2,
          allowedAttackUnitIds: ["raider"],
          preferredAttackUnitIds: ["raider", "raider"],
          trainUnitIds: ["raider", "brute"],
          maxAttackByUnitId: { raider: 2 }
        },
        pressure: {
          maxAttackWaveSize: 4,
          allowedAttackUnitIds: ["raider", "hexer", "brute"],
          preferredAttackUnitIds: ["brute", "raider", "raider", "hexer", "brute"],
          trainUnitIds: ["raider", "hexer", "brute"],
          maxAttackByUnitId: { raider: 2, hexer: 1, brute: 1 }
        },
        assault: {
          maxAttackWaveSize: 5,
          allowedAttackUnitIds: ["raider", "hexer", "brute", "enemy_commander"],
          preferredAttackUnitIds: ["brute", "raider", "hexer", "brute", "enemy_commander", "raider", "brute"],
          trainUnitIds: ["raider", "hexer", "brute"],
          maxAttackByUnitId: { raider: 3, hexer: 2, brute: 1, enemy_commander: 1 }
        }
      }
    },
    defense: {
      defendRadiusMultiplier: 1.18,
      defenseSquadSizeDelta: 1,
      reserveDefenseUnits: 1,
      protectCaptureSites: true
    },
    commander: {
      joinsFirstAttack: false
    },
    behaviorNotes: ["Keeps a small defensive reserve.", "Defends enemy-held capture sites as well as the base."]
  },
  {
    id: "hexfire_cult",
    name: "Hexfire Cult",
    shortDescription: "Magic bursts, weak frontline.",
    description: "A caster-heavy profile that fields more Hexers, fewer melee blockers, and dangerous burst waves after the opening.",
    aggressionLevel: 0.65,
    preferredUnitIds: ["hexer", "raider", "brute"],
    unitPlan: ["hexer", "raider", "hexer", "hexer", "brute"],
    timing: {
      firstAttackDelayMultiplier: 1.08,
      attackIntervalMultiplier: 1.08,
      expandIntervalMultiplier: 1,
      trainIntervalMultiplier: 1,
      commanderJoinDelayMultiplier: 1
    },
    economy: {
      incomeMultiplier: 0.98
    },
    waves: {
      attackWaveSizeMultiplier: 1,
      minAttackArmySizeDelta: 0,
      phaseOverrides: {
        expansion: {
          maxAttackWaveSize: 3,
          allowedAttackUnitIds: ["raider", "hexer"],
          preferredAttackUnitIds: ["hexer", "raider", "hexer"],
          trainUnitIds: ["hexer", "raider"],
          maxAttackByUnitId: { raider: 1, hexer: 2 }
        },
        pressure: {
          maxAttackWaveSize: 4,
          allowedAttackUnitIds: ["raider", "hexer", "brute"],
          preferredAttackUnitIds: ["hexer", "hexer", "raider", "brute", "hexer"],
          trainUnitIds: ["hexer", "raider", "brute"],
          maxAttackByUnitId: { raider: 2, hexer: 2, brute: 1 }
        },
        assault: {
          maxAttackWaveSize: 5,
          allowedAttackUnitIds: ["raider", "hexer", "brute", "enemy_commander"],
          preferredAttackUnitIds: ["hexer", "brute", "hexer", "enemy_commander", "raider", "hexer", "brute"],
          trainUnitIds: ["hexer", "raider", "brute"],
          maxAttackByUnitId: { raider: 2, hexer: 2, brute: 1, enemy_commander: 1 }
        }
      }
    },
    defense: {
      defendRadiusMultiplier: 0.95,
      defenseSquadSizeDelta: 0,
      reserveDefenseUnits: 1,
      protectCaptureSites: false
    },
    commander: {
      joinsFirstAttack: false
    },
    behaviorNotes: ["Prioritizes Hexers and aether-heavy pressure.", "Frontline is thinner than other profiles."]
  }
];

export const AI_PERSONALITY_BY_ID: Record<EnemyAIPersonalityId, EnemyAIPersonalityDefinition> = Object.fromEntries(
  AI_PERSONALITIES.map((personality) => [personality.id, personality])
) as Record<EnemyAIPersonalityId, EnemyAIPersonalityDefinition>;

export function getAIPersonality(id: EnemyAIPersonalityId | string | undefined): EnemyAIPersonalityDefinition {
  return (id ? AI_PERSONALITY_BY_ID[id as EnemyAIPersonalityId] : undefined) ?? AI_PERSONALITY_BY_ID[DEFAULT_AI_PERSONALITY_ID];
}

export function isAIPersonalityId(value: string): value is EnemyAIPersonalityId {
  return value in AI_PERSONALITY_BY_ID;
}

export function applyAIPersonalityToDifficulty(
  difficulty: BattleDifficultyDefinition,
  personality: EnemyAIPersonalityDefinition
): BattleDifficultyDefinition {
  return {
    ...difficulty,
    enemyIncomeMultiplier: difficulty.enemyIncomeMultiplier * personality.economy.incomeMultiplier,
    firstAttackDelay: scaledSeconds(difficulty.firstAttackDelay, personality.timing.firstAttackDelayMultiplier),
    attackInterval: scaledSeconds(difficulty.attackInterval, personality.timing.attackIntervalMultiplier),
    attackWaveSize: Math.max(1, Math.round(difficulty.attackWaveSize * personality.waves.attackWaveSizeMultiplier)),
    expandInterval: scaledSeconds(difficulty.expandInterval, personality.timing.expandIntervalMultiplier),
    trainInterval: scaledSeconds(difficulty.trainInterval, personality.timing.trainIntervalMultiplier),
    minAttackArmySize: Math.max(1, difficulty.minAttackArmySize + personality.waves.minAttackArmySizeDelta),
    expandSquadSize: Math.max(1, difficulty.expandSquadSize),
    commanderJoinDelay: scaledSeconds(difficulty.commanderJoinDelay, personality.timing.commanderJoinDelayMultiplier)
  };
}

export function applyAIPersonalityToConfig(
  config: EnemyAIConfig,
  personality: EnemyAIPersonalityDefinition
): EnemyAIConfig {
  return {
    ...config,
    trainInterval: scaledSeconds(config.trainInterval, personality.timing.trainIntervalMultiplier),
    expandInterval: scaledSeconds(config.expandInterval, personality.timing.expandIntervalMultiplier),
    initialExpandDelay: scaledSeconds(config.initialExpandDelay, personality.timing.expandIntervalMultiplier),
    attackInterval: scaledSeconds(config.attackInterval, personality.timing.attackIntervalMultiplier),
    initialAttackDelay: scaledSeconds(config.initialAttackDelay, personality.timing.firstAttackDelayMultiplier),
    minAttackArmySize: Math.max(1, config.minAttackArmySize + personality.waves.minAttackArmySizeDelta),
    attackWaveSize: Math.max(1, Math.round(config.attackWaveSize * personality.waves.attackWaveSizeMultiplier)),
    defenseSquadSize: Math.max(1, config.defenseSquadSize + personality.defense.defenseSquadSizeDelta),
    defendRadius: Math.max(120, Math.round(config.defendRadius * personality.defense.defendRadiusMultiplier)),
    unitPlan: personality.unitPlan.length > 0 ? [...personality.unitPlan] : [...config.unitPlan]
  };
}

export function applyAIPersonalityToPhase(
  phase: BattlePhaseDefinition,
  personality: EnemyAIPersonalityDefinition
): BattlePhaseDefinition {
  const override = personality.waves.phaseOverrides[phase.id];
  if (!override) {
    return phase;
  }
  return {
    ...phase,
    enemy: {
      ...phase.enemy,
      ...override,
      allowedAttackUnitIds: override.allowedAttackUnitIds ?? phase.enemy.allowedAttackUnitIds,
      preferredAttackUnitIds: override.preferredAttackUnitIds ?? phase.enemy.preferredAttackUnitIds,
      trainUnitIds: override.trainUnitIds ?? phase.enemy.trainUnitIds,
      maxAttackByUnitId: override.maxAttackByUnitId ?? phase.enemy.maxAttackByUnitId
    }
  };
}

function scaledSeconds(value: number, multiplier: number): number {
  return Math.max(1, Math.round(value * multiplier));
}
