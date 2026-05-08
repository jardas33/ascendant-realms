import type { ResourceBag } from "../../core/GameTypes";
import type { Hero } from "../../entities/Hero";
import type { Building } from "../../entities/Building";
import type { Unit } from "../../entities/Unit";
import type { TechState } from "../../systems/PrerequisiteSystem";
import type { TutorialStepViewModel } from "../../tutorial/TutorialStepModel";
import type { MinimapSnapshot } from "../MinimapView";

export interface HUDCallbacks {
  onBuild: (buildingId: string, sourceBuildingId: string) => void;
  onTrain: (unitId: string, sourceBuildingId: string) => void;
  onCancelTrain: (sourceBuildingId: string, queueIndex: number) => void;
  onUpgrade: (upgradeId: string, sourceBuildingId: string) => void;
  onCancelUpgrade: (sourceBuildingId: string, queueIndex: number) => void;
  onAbility: (abilityId: string) => void;
  onMinimapMove: (normalizedX: number, normalizedY: number) => void;
  onMenu: () => void;
}

export interface HUDSnapshot {
  resources: ResourceBag;
  hero: Hero;
  selected: Array<Unit | Building>;
  elapsedSeconds: number;
  isPlacing: boolean;
  status: string;
  hint?: string;
  tutorial?: TutorialStepViewModel;
  techState: TechState;
  minimap: MinimapSnapshot;
  objectives?: HUDObjectiveSnapshot[];
}

export interface HUDObjectiveSnapshot {
  id: string;
  name: string;
  description: string;
  completed: boolean;
}
