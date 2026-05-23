import type {
  BattleDifficulty,
  BattleDifficultyDefinition,
  BattlePhaseDefinition,
  EnemyAIConfig,
  FirstMatchTutorialProtectionDefinition,
  ResourceBag
} from "../core/GameTypes";

export const DEFAULT_BATTLE_DIFFICULTY: BattleDifficulty = "normal";

export const BATTLE_PHASES: BattlePhaseDefinition[] = [
  {
    id: "opening",
    name: "Opening",
    startSeconds: 0,
    endSeconds: 120,
    enemy: {
      baseAttackAllowed: false,
      maxAttackWaveSize: 0,
      commanderAllowed: false,
      allowedAttackUnitIds: ["raider"],
      preferredAttackUnitIds: ["raider"],
      trainUnitIds: ["raider", "hexer"],
      maxAttackByUnitId: { raider: 1 }
    }
  },
  {
    id: "expansion",
    name: "Expansion",
    startSeconds: 120,
    endSeconds: 300,
    enemy: {
      baseAttackAllowed: true,
      maxAttackWaveSize: 3,
      commanderAllowed: false,
      allowedAttackUnitIds: ["raider", "hexer"],
      preferredAttackUnitIds: ["raider", "raider", "hexer"],
      trainUnitIds: ["raider", "hexer"],
      maxAttackByUnitId: { raider: 2, hexer: 1 }
    }
  },
  {
    id: "pressure",
    name: "Pressure",
    startSeconds: 300,
    endSeconds: 480,
    enemy: {
      baseAttackAllowed: true,
      maxAttackWaveSize: 5,
      commanderAllowed: false,
      allowedAttackUnitIds: ["raider", "hexer", "brute"],
      preferredAttackUnitIds: ["raider", "raider", "hexer", "brute", "raider"],
      trainUnitIds: ["raider", "hexer", "brute"],
      maxAttackByUnitId: { raider: 3, hexer: 1, brute: 1 }
    }
  },
  {
    id: "assault",
    name: "Assault",
    startSeconds: 480,
    enemy: {
      baseAttackAllowed: true,
      maxAttackWaveSize: 8,
      commanderAllowed: true,
      allowedAttackUnitIds: ["raider", "hexer", "brute", "enemy_commander"],
      preferredAttackUnitIds: ["raider", "brute", "hexer", "raider", "enemy_commander", "raider", "hexer", "brute"],
      trainUnitIds: ["raider", "hexer", "brute"],
      maxAttackByUnitId: { raider: 4, hexer: 2, brute: 2, enemy_commander: 1 }
    }
  }
];

export const BATTLE_DIFFICULTIES: BattleDifficultyDefinition[] = [
  {
    id: "story",
    name: "Story",
    description: "A gentle first run with long warning windows and small enemy groups.",
    enemyStartingUnitSpawnIds: ["enemy_raider_1"],
    enemyIncomeMultiplier: 0.45,
    firstAttackDelay: 300,
    attackInterval: 100,
    attackWaveSize: 2,
    expandInterval: 30,
    trainInterval: 9,
    minAttackArmySize: 2,
    expandSquadSize: 1,
    commanderJoinDelay: 840,
    fogOfWarEnabled: false
  },
  {
    id: "easy",
    name: "Easy",
    description: "A forgiving RTS/RPG tutorial pace with survivable attacks.",
    enemyStartingUnitSpawnIds: ["enemy_raider_1", "enemy_raider_2"],
    enemyIncomeMultiplier: 0.65,
    firstAttackDelay: 240,
    attackInterval: 82,
    attackWaveSize: 3,
    expandInterval: 27,
    trainInterval: 7,
    minAttackArmySize: 2,
    expandSquadSize: 2,
    commanderJoinDelay: 750,
    fogOfWarEnabled: true
  },
  {
    id: "normal",
    name: "Normal",
    description: "The intended first playable baseline: room to learn, danger after the opening.",
    enemyStartingUnitSpawnIds: ["enemy_raider_1", "enemy_raider_2", "enemy_hexer_1", "enemy_commander_1"],
    enemyIncomeMultiplier: 0.82,
    firstAttackDelay: 195,
    attackInterval: 72,
    attackWaveSize: 5,
    expandInterval: 21,
    trainInterval: 6.2,
    minAttackArmySize: 2,
    expandSquadSize: 2,
    commanderJoinDelay: 630,
    fogOfWarEnabled: true
  },
  {
    id: "hard",
    name: "Hard",
    description: "A sharper version for players who already know the opening build order.",
    enemyStartingUnitSpawnIds: [
      "enemy_raider_1",
      "enemy_raider_2",
      "enemy_hexer_1",
      "enemy_brute_1",
      "enemy_commander_1"
    ],
    enemyIncomeMultiplier: 1.15,
    firstAttackDelay: 150,
    attackInterval: 48,
    attackWaveSize: 8,
    expandInterval: 15,
    trainInterval: 3.8,
    minAttackArmySize: 3,
    expandSquadSize: 3,
    commanderJoinDelay: 480,
    fogOfWarEnabled: true
  }
];

export const FIRST_MATCH_TUTORIAL_PROTECTION: FirstMatchTutorialProtectionDefinition = {
  firstAttackAllowedAfterSeconds: 150,
  firstAttackForceAfterSeconds: 180,
  largeAttackAllowedAfterSeconds: 240,
  earlyAttackMaxWaveSize: 2
};

export function getBattlePhase(elapsedSeconds: number): BattlePhaseDefinition {
  const elapsed = Math.max(0, elapsedSeconds);
  return (
    BATTLE_PHASES.find((phase) => elapsed >= phase.startSeconds && (phase.endSeconds === undefined || elapsed < phase.endSeconds)) ??
    BATTLE_PHASES[BATTLE_PHASES.length - 1]
  );
}

export function getBattleDifficulty(difficulty: BattleDifficulty | undefined): BattleDifficultyDefinition {
  return BATTLE_DIFFICULTIES.find((preset) => preset.id === difficulty) ?? getBattleDifficulty(DEFAULT_BATTLE_DIFFICULTY);
}

export function isBattleDifficulty(value: string): value is BattleDifficulty {
  return BATTLE_DIFFICULTIES.some((preset) => preset.id === value);
}

export function scaledEnemyIncome(income: Partial<ResourceBag>, multiplier: number): Partial<ResourceBag> {
  return Object.fromEntries(
    Object.entries(income).map(([resource, amount]) => [resource, Math.max(0, Math.round((amount ?? 0) * multiplier))])
  ) as Partial<ResourceBag>;
}

export function applyTutorialEnemyAIPacing(config: EnemyAIConfig): EnemyAIConfig {
  const story = getBattleDifficulty("story");
  return {
    ...config,
    trainInterval: Math.max(config.trainInterval, story.trainInterval),
    expandInterval: Math.max(config.expandInterval, story.expandInterval),
    initialExpandDelay: Math.max(config.initialExpandDelay, story.expandInterval),
    attackInterval: Math.max(config.attackInterval, story.attackInterval),
    initialAttackDelay: Math.max(config.initialAttackDelay, story.firstAttackDelay),
    minAttackArmySize: Math.min(config.minAttackArmySize, story.minAttackArmySize),
    attackWaveSize: Math.min(config.attackWaveSize, story.attackWaveSize),
    expandSquadSize: Math.min(config.expandSquadSize, story.expandSquadSize)
  };
}
