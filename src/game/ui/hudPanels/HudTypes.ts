import type { ResourceBag } from "../../core/GameTypes";
import type { Cost } from "../../core/GameTypes";
import type { Hero } from "../../entities/Hero";
import type { Building } from "../../entities/Building";
import type { CaptureSite } from "../../entities/CaptureSite";
import type { Unit } from "../../entities/Unit";
import type { BehaviourMode } from "../../systems/BehaviourModeSystem";
import type { ControlGroupSummary } from "../../systems/ControlGroupSystem";
import type { TechState } from "../../systems/PrerequisiteSystem";
import type { RepairTargetSummary } from "../../systems/RepairSystem";
import type { ResourceSiteAssignmentSummary } from "../../systems/ResourceSystem";
import type { TutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import type { MinimapSnapshot } from "../MinimapView";

export interface HUDCallbacks {
  onBuild: (buildingId: string, sourceBuildingId: string) => void;
  onTrain: (unitId: string, sourceBuildingId: string) => void;
  onCancelTrain: (sourceBuildingId: string, queueIndex: number) => void;
  onUpgrade: (upgradeId: string, sourceBuildingId: string) => void;
  onCancelUpgrade: (sourceBuildingId: string, queueIndex: number) => void;
  onRepair: (targetBuildingId: string, sourceUnitId: string) => void;
  onAssignResourceSite: (targetSiteId: string, sourceUnitId: string) => void;
  onUpgradeResourceSite: (targetSiteId: string) => void;
  onAbility: (abilityId: string) => void;
  onBehaviourMode: (mode: BehaviourMode) => void;
  onStopCommand: () => void;
  onPatrolCommand: () => void;
  onRetinueReinforcement: () => void;
  onTutorialNext: () => void;
  onMinimapMove: (normalizedX: number, normalizedY: number) => void;
  onMenu: () => void;
  onResume: () => void;
  onExitToMainMenu: () => void;
}

export interface HUDSnapshot {
  resources: ResourceBag;
  hero: Hero;
  selected: Array<Unit | Building | CaptureSite>;
  elapsedSeconds: number;
  isPlacing: boolean;
  status: string;
  hint?: string;
  tutorial?: TutorialStepViewModel;
  techState: TechState;
  repairTargets: RepairTargetSummary[];
  resourceSites: ResourceSiteAssignmentSummary[];
  minimap: MinimapSnapshot;
  objectives?: HUDObjectiveSnapshot[];
  controlGroups?: ControlGroupSummary[];
  enemyDoctrine?: HUDEnemyDoctrineSnapshot;
  battlefieldEvent?: HUDBattlefieldEventSnapshot;
  retinueReinforcement?: HUDRetinueReinforcementSnapshot;
  pauseMenu?: HUDPauseMenuSnapshot;
}

export interface HUDEnemyDoctrineSnapshot {
  name: string;
  status: string;
  warning: string;
  counterplay: string;
  elite?: string;
}

export interface HUDRetinueReinforcementSnapshot {
  available: boolean;
  reason?: string;
  cost: Cost;
  reserveCount: number;
  readyReserveCount: number;
  used: boolean;
}

export interface HUDBattlefieldEventSnapshot {
  title: string;
  objective: string;
  progress: string;
  counterplay: string;
  remainingSeconds: number;
  planMatched: boolean;
}

export interface HUDPauseMenuSnapshot {
  visible: boolean;
  title: string;
  description: string;
}

export interface HUDObjectiveSnapshot {
  id: string;
  name: string;
  description: string;
  completed: boolean;
}
