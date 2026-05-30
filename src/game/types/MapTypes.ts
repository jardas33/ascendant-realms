import type { UnitVeterancyBattleSummary } from "./CombatTypes";
import type { ResourceBag, ResourceKey } from "./EconomyTypes";
import type { Position, Team } from "./UITypes";

export type TerrainType = "grass" | "buildable" | "blocked" | "water";

export interface TerrainZoneDefinition {
  id: string;
  type: TerrainType;
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface CaptureSiteFirstCaptureBonusDefinition {
  id: string;
  label: string;
  description: string;
  resources: Partial<ResourceBag>;
}

export interface CaptureSiteDefinition {
  id: string;
  name: string;
  resource: ResourceKey;
  x: number;
  y: number;
  radius: number;
  incomeAmount: number;
  incomeInterval: number;
  firstCaptureBonus?: CaptureSiteFirstCaptureBonusDefinition;
}

export interface NeutralCampDefinition {
  id: string;
  name: string;
  x: number;
  y: number;
  unitIds: string[];
}

export interface UnitSpawnDefinition {
  id: string;
  unitId: string;
  team: Team;
  x: number;
  y: number;
}

export interface BuildingSpawnDefinition {
  id: string;
  buildingId: string;
  team: Exclude<Team, "neutral">;
  x: number;
  y: number;
}

export type BattleSecondaryObjectiveType = "capture_site" | "destroy_building" | "defeat_unit";

export interface BattleSecondaryObjectiveDefinition {
  id: string;
  name: string;
  description: string;
  type: BattleSecondaryObjectiveType;
  targetId: string;
}

export interface BattleObjectiveDefinition {
  playerBaseBuildingId: string;
  enemyBaseBuildingId: string;
  secondaryObjectives?: BattleSecondaryObjectiveDefinition[];
}

export interface BattleMapPathDefinition {
  id: string;
  width: number;
  points: Position[];
}

export interface EnemyAIConfig {
  incomeInterval: number;
  incomePerTick: Partial<ResourceBag>;
  trainInterval: number;
  expandInterval: number;
  initialExpandDelay: number;
  attackInterval: number;
  initialAttackDelay: number;
  minAttackArmySize: number;
  attackWaveSize: number;
  expandSquadSize: number;
  defenseSquadSize: number;
  defendRadius: number;
  baseBuildingId: string;
  productionBuildingId: string;
  attackTargetBuildingId: string;
  unitPlan: string[];
}

export interface BattleScenarioDefinition {
  startingResources: Record<"player" | "enemy", ResourceBag>;
  heroSpawn: Position;
  buildingSpawns: BuildingSpawnDefinition[];
  unitSpawns: UnitSpawnDefinition[];
  objectives: BattleObjectiveDefinition;
  enemyAI: EnemyAIConfig;
  rewardTableId: string;
}

export interface BattleMapDefinition {
  id: string;
  name: string;
  role: string;
  description: string;
  strategicNotes: string[];
  width: number;
  height: number;
  playerStart: Position;
  enemyStart: Position;
  visualPaths: BattleMapPathDefinition[];
  terrainZones: TerrainZoneDefinition[];
  captureSites: CaptureSiteDefinition[];
  neutralCamps: NeutralCampDefinition[];
  scenario: BattleScenarioDefinition;
}

export interface BattleStats {
  unitsKilled: number;
  buildingsDestroyed: number;
  resourcesCaptured: number;
  firstSiteCaptured?: string;
  buildingsBuilt: number;
  builtBuildingIds: string[];
  unitsTrained: number;
  trainedUnitIds: string[];
  enemyWavesSurvived: number;
  xpGained: number;
  timeSeconds: number;
  completedObjectiveIds: string[];
  outcome: "victory" | "defeat";
  veteranSummary?: UnitVeterancyBattleSummary;
  retinueUnitIdsLost?: string[];
  retinueParticipatingUnitIds?: string[];
  retinueUnitIdsRecovering?: string[];
  retinueUnitIdsReturnedReady?: string[];
  retinueSurvivorHealth?: Array<{ retinueUnitId: string; hpRatio: number }>;
  retinueReinforcementUsed?: boolean;
  retinueReinforcementUnitId?: string;
  enemyHeroId?: string;
  enemyHeroName?: string;
  enemyHeroDefeated?: boolean;
  enemyHeroDefeatedAtSeconds?: number;
  enemyHeroJoinedAttackAtSeconds?: number;
  lossesInvolvingEnemyHero?: number;
  enemyPressurePlanId?: string;
  enemyPressureTriggeredStageIds?: string[];
  enemyPressureCompletedStageIds?: string[];
  enemyPressureTelemetryLabels?: string[];
  enemyPressureWarningsShown?: number;
  enemyPressureFirstTriggeredAtSeconds?: number;
  enemyPressureReinforcementApplied?: boolean;
}
