import Phaser from "phaser";
import type {
  BattleMapDefinition,
  BattleSecondaryObjectiveType,
  CaptureSiteFirstCaptureBonusDefinition,
  Position,
  ResourceBag,
  ResourceKey,
  Team,
  UpgradeDefinition
} from "../core/GameTypes";
import { BUILDING_BY_ID } from "../data/contentIndex";
import { applyTutorialEnemyAIPacing } from "../data/battlePacing";
import { applyCampaignEnemyAIModifierEffects } from "../data/campaignModifiers";
import { selectEnemyDoctrineForBattleLaunch } from "../data/enemyDoctrines";
import { getStrongholdBattleEffects, type StrongholdBattleEffects } from "../data/strongholdUpgrades";
import { EnemyAIController } from "../ai/EnemyAIController";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { CaptureSite } from "../entities/CaptureSite";
import { Hero } from "../entities/Hero";
import { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";
import { AudioManager } from "../systems/AudioManager";
import { AbilitySystem } from "../systems/AbilitySystem";
import { AISystem } from "../systems/AISystem";
import { behaviourModeDefinition, setBehaviourMode, type BehaviourMode } from "../systems/BehaviourModeSystem";
import { BuildingSystem } from "../systems/BuildingSystem";
import { CameraSystem } from "../systems/CameraSystem";
import { CombatSystem } from "../systems/CombatSystem";
import { ControlGroupSystem } from "../systems/ControlGroupSystem";
import { FogOfWarSystem } from "../systems/FogOfWarSystem";
import { EnemyHeroAbilitySystem } from "../systems/EnemyHeroAbilitySystem";
import { createFormationMoveTargets } from "../systems/FormationMovement";
import { InputSystem } from "../systems/InputSystem";
import { MovementSystem } from "../systems/MovementSystem";
import { isPatrolEligibleUnit, patrolEligibilityMessage } from "../systems/PatrolRules";
import type { TechState } from "../systems/PrerequisiteSystem";
import { ResourceSystem } from "../systems/ResourceSystem";
import { RepairSystem } from "../systems/RepairSystem";
import { SelectionSystem } from "../systems/SelectionSystem";
import { findWalkableTrainedUnitSpawnPoint, TrainingSystem } from "../systems/TrainingSystem";
import { UISystem } from "../systems/UISystem";
import { UpgradeSystem } from "../systems/UpgradeSystem";
import { XPSystem } from "../systems/XPSystem";
import { FloatingText } from "../ui/FloatingText";
import { showDamageFeedback } from "../ui/DamageFeedback";
import { HUD } from "../ui/HUD";
import type { ResolvedBattleLaunch } from "./BattleLaunchRequest";
import type { BattleRuntime } from "./BattleRuntime";
import type { BattleStatusOptions } from "./BattleStatusPriority";

const BATTLE_FOG_CELL_SIZE = 96;

export interface BattleSceneSystems {
  movementSystem: MovementSystem;
  combatSystem: CombatSystem;
  resourceSystem: ResourceSystem;
  repairSystem: RepairSystem;
  buildingSystem: BuildingSystem;
  trainingSystem: TrainingSystem;
  upgradeSystem: UpgradeSystem;
  selectionSystem: SelectionSystem;
  controlGroupSystem: ControlGroupSystem;
  abilitySystem: AbilitySystem;
  enemyHeroAbilitySystem: EnemyHeroAbilitySystem;
  cameraSystem: CameraSystem;
  inputSystem: InputSystem;
  uiSystem: UISystem;
  xpSystem: XPSystem;
  aiSystem: AISystem;
}

interface CreateBattleSceneSystemsOptions {
  scene: Phaser.Scene;
  activeMap: BattleMapDefinition;
  launch: ResolvedBattleLaunch;
  runtime: BattleRuntime;
  resources: Record<"player" | "enemy", ResourceBag>;
  hero: Hero;
  getUnits: () => Unit[];
  getBuildings: () => Building[];
  getProjectiles: () => Projectile[];
  getCaptureSites: () => CaptureSite[];
  addUnit: (unit: Unit) => void;
  addBuilding: (building: Building) => void;
  addProjectile: (projectile: Projectile) => void;
  showMessage: (message: string, x?: number, y?: number, color?: string, options?: BattleStatusOptions) => void;
  addMinimapPing: (x: number, y: number, color: string, label: string) => void;
  warnIfCommandHallUnderAttack: (target: BaseEntity) => void;
  handleUnitDamage: (source: Unit, target: BaseEntity, amount: number) => void;
  applyEnemyHeroDamage: (source: Unit, target: BaseEntity, amount: number) => void;
  handleKill: (killer: Unit | Building | Projectile, target: BaseEntity) => void;
  completeSecondaryObjective: (type: BattleSecondaryObjectiveType, targetId: string, point?: Position) => void;
  selectedRallyBuildings: () => Building[];
  setRallyPoint: (point: Position, buildings: Building[]) => boolean;
  findWorldEntityAt: (point: Position) => BaseEntity | undefined;
  centerCameraFromMinimap: (normalizedX: number, normalizedY: number) => void;
  castAbilitySlot: (slot: number) => void;
  refreshHud: () => void;
  advanceTutorialStep: () => void;
  toggleFogDebug: () => void;
  getTechState: (team: Team) => TechState;
  isUpgradeResearched: (team: Team, upgradeId: string) => boolean;
  markUpgradeResearched: (team: Team, upgradeId: string) => void;
  applyUpgradeEffects: (team: Team, upgrade: UpgradeDefinition) => void;
  isFirstBattle: () => boolean;
  hasPlayerProductionBuilding: () => boolean;
  findPlayerBaseBuilding: () => Building | undefined;
  trackEnemyWave: (units: Unit[]) => void;
  showBattleStartSummary: () => void;
  onPlayerCapturedSite?: (siteId: string) => void;
  onPlayerUnitTrained?: (unitId: string) => void;
  openMainMenu: () => void;
  resumeBattle: () => void;
  exitToMainMenu: () => void;
  callRetinueReinforcement?: () => boolean;
}

// BattleScene owns Phaser lifecycle, runtime state, and live entity arrays.
// This helper owns only constructor ordering and callback wiring between systems.
export function createBattleSceneSystems(options: CreateBattleSceneSystemsOptions): BattleSceneSystems {
  const {
    scene,
    activeMap,
    launch,
    runtime,
    resources,
    hero,
    getUnits,
    getBuildings,
    getProjectiles,
    getCaptureSites,
    addUnit,
    addBuilding,
    addProjectile,
    showMessage,
    addMinimapPing,
    warnIfCommandHallUnderAttack,
    handleUnitDamage,
    applyEnemyHeroDamage,
    handleKill,
    completeSecondaryObjective,
    selectedRallyBuildings,
    setRallyPoint,
    findWorldEntityAt,
    centerCameraFromMinimap,
    castAbilitySlot,
    refreshHud,
    advanceTutorialStep,
    toggleFogDebug,
    getTechState,
    isUpgradeResearched,
    markUpgradeResearched,
    applyUpgradeEffects,
    isFirstBattle,
    hasPlayerProductionBuilding,
    findPlayerBaseBuilding,
    trackEnemyWave,
    showBattleStartSummary,
    onPlayerCapturedSite,
    onPlayerUnitTrained,
    openMainMenu,
    resumeBattle,
    exitToMainMenu,
    callRetinueReinforcement
  } = options;
  const strongholdEffects = getStrongholdBattleEffects(launch.request.modifiers);

  const selectionSystem = new SelectionSystem(() => [
    ...getUnits().filter((unit) => unit.team === "player"),
    ...getBuildings().filter((building) => building.team === "player"),
    ...getCaptureSites()
  ]);
  const controlGroupSystem = new ControlGroupSystem();

  const movementSystem = new MovementSystem({
    onPathFailed: (unit, target) => {
      if (unit.team !== "player" || unit.attackTargetId) {
        return;
      }
      showMessage("No clear path. Moving as close as possible.", target.x, target.y - 24, "#f0d978", {
        priority: "command"
      });
    }
  });

  const trainingSystem = new TrainingSystem({
    scene,
    addUnit,
    onMessage: (message, x, y, color, options) => showMessage(message, x, y, color, options),
    onUnitTrained: (unit) => {
      if (unit.team === "player") {
        runtime.recordUnitTrained(unit.definition.id);
        onPlayerUnitTrained?.(unit.definition.id);
        AudioManager.play("unit_trained");
      }
    },
    getTechState,
    strongholdEffects,
    resolveSpawnPoint: (context) =>
      findWalkableTrainedUnitSpawnPoint({
        ...context,
        map: activeMap,
        buildings: getBuildings()
      })
  });

  const buildingSystem = new BuildingSystem({
    scene,
    map: activeMap,
    getBuildings,
    getUnits,
    getCaptureSites,
    addBuilding,
    onMessage: (message, x, y, color, options) => showMessage(message, x, y, color, options),
    strongholdEffects,
    onConstructionStarted: (building) => {
      if (building.team === "player") {
        selectionSystem.setSelection([building]);
        AudioManager.play("build_started");
      }
    },
    onBuilt: (building) => {
      if (building.team === "player") {
        runtime.recordBuildingBuilt(building.definition.id);
        AudioManager.play("build_complete");
      }
    }
  });

  const repairSystem = new RepairSystem({
    map: activeMap,
    getUnits,
    getBuildings,
    onMessage: (message, x, y, color, messageOptions) => showMessage(message, x, y, color, messageOptions)
  });

  const upgradeSystem = new UpgradeSystem({
    getTechState,
    isResearched: isUpgradeResearched,
    markResearched: markUpgradeResearched,
    onMessage: (message, x, y, color, options) => showMessage(message, x, y, color, options),
    onUpgradeCompleted: applyUpgradeEffects
  });

  const xpSystem = new XPSystem(hero, (amount, leveledUp) => {
    runtime.recordXpGained(amount);
    showMessage(leveledUp ? `Level up! +${amount} XP` : `+${amount} XP`, hero.position.x, hero.position.y - 54, "#f6e27d");
  });

  const combatSystem = new CombatSystem({
    scene,
    getUnits,
    getBuildings,
    getProjectiles,
    addProjectile,
    onDamage: (target, amount, source) => {
      showDamageFeedback(scene, target, amount, { threshold: damageFeedbackThresholdFor(source, target) });
      warnIfCommandHallUnderAttack(target);
    },
    onUnitDamage: handleUnitDamage,
    onStatusApplied: (target, statusName) => {
      FloatingText.show(scene, statusName, target.position.x, target.position.y - target.radius - 18, "#ff9a64");
    },
    onKill: handleKill
  });

  const resourceSystem = new ResourceSystem({
    resources,
    getCaptureSites,
    onCapture: (site, owner) => {
      if (owner === "player") {
        runtime.recordResourceCaptured(site.definition.id);
        onPlayerCapturedSite?.(site.definition.id);
        showMessage(`${site.definition.name} captured`, site.position.x, site.position.y - 70, "#aef7b7");
        completeSecondaryObjective("capture_site", site.definition.id, site.position);
        if (!launch.request.rewardsDisabled) {
          xpSystem.awardForCaptureSite(site);
        }
        return;
      }
      if (owner === "enemy") {
        addMinimapPing(site.position.x, site.position.y, "#f0d978", `${site.definition.name} captured by enemy`);
        showMessage(`${site.definition.name} captured by enemy.`, site.position.x, site.position.y - 70, "#f0d978", {
          priority: "pressure"
        });
      }
    },
    onIncome: (site, owner, amount, breakdown) => {
      if (owner === "player") {
        const bonusParts = [
          breakdown && breakdown.upgradeBonusAmount > 0 ? `Upgrade +${breakdown.upgradeBonusAmount}` : "",
          breakdown && breakdown.workerBonusAmount > 0 ? `Worker +${breakdown.workerBonusAmount}` : ""
        ].filter(Boolean);
        const bonusText = bonusParts.length > 0 ? ` (${bonusParts.join(", ")})` : "";
        showMessage(`+${amount} ${site.definition.resource}${bonusText}`, site.position.x, site.position.y - 64, "#f5efc2");
      }
    },
    onMessage: (message, x, y, color, options) => showMessage(message, x, y, color, options),
    onCaptureBonus: (site, owner, bonus) => {
      if (owner === "player") {
        const resourceText = formatResourceBonus(bonus.resources);
        const message = resourceText ? `${bonus.label}: ${resourceText}` : bonus.label;
        addMinimapPing(site.position.x, site.position.y, "#f6e27d", bonus.label);
        showMessage(message, site.position.x, site.position.y - 96, "#f6e27d", { priority: "objective" });
      }
    },
    adjustFirstCaptureBonus: (site, owner, bonus) => {
      return applyFirstCaptureBonusAdditions(site.definition.id, owner, bonus, strongholdEffects);
    }
  });

  const abilitySystem = new AbilitySystem({
    scene,
    getUnits,
    getBuildings,
    addProjectile,
    onDamage: (target, amount) => {
      showDamageFeedback(scene, target, amount);
      warnIfCommandHallUnderAttack(target);
    },
    onKill: handleKill,
    onMessage: showMessage
  });

  const enemyHeroAbilitySystem = new EnemyHeroAbilitySystem({
    getUnits,
    getBuildings,
    getElapsedSeconds: () => runtime.elapsedSeconds,
    getEnemyBase: () => getBuildings().find((building) => building.alive && building.team === "enemy" && building.definition.id === activeMap.scenario.objectives.enemyBaseBuildingId),
    applyDamage: applyEnemyHeroDamage,
    onStatusApplied: (target, statusName) => {
      FloatingText.show(scene, statusName, target.position.x, target.position.y - target.radius - 18, "#ff9a64");
    },
    onMessage: showMessage
  });

  const cameraSystem = new CameraSystem(scene, activeMap);
  let inputSystem: InputSystem;
  const uiSystem = new UISystem(
    new HUD({
      onBuild: (buildingId, sourceBuildingId) => {
        const builder = getUnits().find(
          (entry) =>
            entry.id === sourceBuildingId &&
            entry.alive &&
            entry.team === "player" &&
            Boolean(entry.definition.buildOptions?.includes(buildingId))
        );
        const definition = BUILDING_BY_ID[buildingId];
        if (!builder) {
          showMessage(
            `Select a Worker to build ${definition?.name ?? "this structure"}.`,
            undefined,
            undefined,
            "#ffd27a",
            {
              priority: "command"
            }
          );
          return;
        }
        buildingSystem.startPlacement(buildingId, {
          anchor: builder.position,
          resources: resources.player,
          assignedWorkerId: builder.id
        });
        AudioManager.play("ui_click");
        showMessage(
          `${builder.definition.name} ready to build ${definition?.name ?? "building"} - place the site near your base.`,
          undefined,
          undefined,
          "#d9eee8",
          {
            priority: "command"
          }
        );
      },
      onTrain: (unitId, sourceBuildingId) => {
        const building = getBuildings().find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building && trainingSystem.queueTraining(building, unitId, resources.player)) {
          AudioManager.play("ui_click");
        }
      },
      onCancelTrain: (sourceBuildingId, queueIndex) => {
        const building = getBuildings().find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          trainingSystem.cancelTraining(building, queueIndex, resources.player);
        }
      },
      onUpgrade: (upgradeId, sourceBuildingId) => {
        const building = getBuildings().find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building && upgradeSystem.queueUpgrade(building, upgradeId, resources.player)) {
          AudioManager.play("ui_click");
        }
      },
      onCancelUpgrade: (sourceBuildingId, queueIndex) => {
        const building = getBuildings().find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          upgradeSystem.cancelUpgrade(building, queueIndex, resources.player);
        }
      },
      onRepair: (targetBuildingId, sourceUnitId) => {
        const worker = getUnits().find((entry) => entry.id === sourceUnitId && entry.alive && entry.team === "player");
        const building = getBuildings().find((entry) => entry.id === targetBuildingId && entry.alive);
        if (repairSystem.requestRepair(worker, building)) {
          AudioManager.play("ui_click");
        }
      },
      onAssignResourceSite: (targetSiteId, sourceUnitId) => {
        const worker = getUnits().find((entry) => entry.id === sourceUnitId && entry.alive && entry.team === "player");
        const site = getCaptureSites().find((entry) => entry.id === targetSiteId && entry.alive);
        if (resourceSystem.requestWorkerAssignment(worker, site, getCaptureSites())) {
          AudioManager.play("ui_click");
        }
      },
      onUpgradeResourceSite: (targetSiteId) => {
        const site = getCaptureSites().find((entry) => entry.id === targetSiteId && entry.alive);
        if (resourceSystem.requestSiteUpgrade(site, resources.player)) {
          AudioManager.play("ui_click");
        }
      },
      onAbility: (abilityId) => {
        if (abilitySystem.castAbility(hero, abilityId, selectionSystem.getSelected())) {
          AudioManager.play("ability_cast");
        }
      },
      onBehaviourMode: (mode: BehaviourMode) => {
        const selectedUnits = selectionSystem.getSelected().filter(
          (entity): entity is Unit => entity instanceof Unit && entity.team === "player" && entity.alive
        );
        const changed = setBehaviourMode(selectedUnits, mode);
        if (changed > 0) {
          const definition = behaviourModeDefinition(mode);
          showMessage(`${definition.label}: ${changed === 1 ? "unit" : `${changed} units`} updated.`, undefined, undefined, "#d9eee8", {
            priority: "command"
          });
          AudioManager.play("ui_click");
        }
      },
      onStopCommand: () => {
        const selectedUnits = selectionSystem
          .getSelected()
          .filter((entity): entity is Unit => entity instanceof Unit && isPatrolEligibleUnit(entity));
        selectedUnits.forEach((unit) => unit.commandStop());
        if (selectedUnits.length > 0) {
          showMessage(
            `Stop: ${selectedUnits.length === 1 ? "unit" : `${selectedUnits.length} units`} awaiting orders.`,
            undefined,
            undefined,
            "#d9eee8",
            { priority: "command" }
          );
          AudioManager.play("ui_click");
        } else {
          showMessage("Stop needs selected combat units.", undefined, undefined, "#ffd27a", { priority: "command" });
        }
      },
      onPatrolCommand: () => {
        if (inputSystem.beginPatrolCommand()) {
          AudioManager.play("ui_click");
        }
      },
      onRetinueReinforcement: () => {
        if (callRetinueReinforcement?.()) {
          AudioManager.play("ui_click");
        }
      },
      onTutorialNext: advanceTutorialStep,
      onMinimapMove: centerCameraFromMinimap,
      onMenu: openMainMenu,
      onResume: resumeBattle,
      onExitToMainMenu: exitToMainMenu
    })
  );

  inputSystem = new InputSystem({
    scene,
    selection: selectionSystem,
    findWorldEntityAt,
    isPlacingBuilding: () => Boolean(buildingSystem.pendingBuildingId),
    updateBuildingGhost: (point) => buildingSystem.updateGhost(point.x, point.y, resources.player),
    placeBuilding: (point) => buildingSystem.tryPlace(point.x, point.y, resources.player),
    cancelPlacement: () => {
      buildingSystem.cancelPlacement();
      showMessage("Building placement cancelled", undefined, undefined, undefined, { priority: "command" });
    },
    getSelectedUnits: () => selectionSystem.getSelected().filter((entity): entity is Unit => entity instanceof Unit),
    getSelectedRallyBuildings: selectedRallyBuildings,
    setRallyPoint,
    issueConstructionOrder: (target, selectedUnits) => buildingSystem.issueConstructionOrder(target, selectedUnits),
    issueRepairOrder: (target, selectedUnits) => repairSystem.issueRepairOrder(target, selectedUnits),
    issueResourceSiteAssignmentOrder: (target, selectedUnits) =>
      resourceSystem.issueWorkerAssignmentOrder(target, selectedUnits),
    resolveMoveTargets: (point, selectedUnits) =>
      createFormationMoveTargets(point, selectedUnits, {
        map: activeMap,
        buildings: getBuildings()
      }),
    assignControlGroup: (slot, selectedUnits) => controlGroupSystem.assign(slot, selectedUnits),
    recallControlGroup: (slot) => {
      const result = controlGroupSystem.recall(slot, getUnits());
      if (result.count > 0) {
        selectionSystem.setSelection(result.units);
        refreshHud();
      }
      return result;
    },
    canStartPatrolCommand: (selectedUnits) => {
      const message = patrolEligibilityMessage(selectedUnits);
      return { ok: selectedUnits.some(isPatrolEligibleUnit), message };
    },
    issuePatrolOrder: (point, selectedUnits) => {
      const patrolUnits = selectedUnits.filter(isPatrolEligibleUnit);
      const targets = createFormationMoveTargets(point, patrolUnits, {
        map: activeMap,
        buildings: getBuildings()
      });
      patrolUnits.forEach((unit, index) => unit.commandPatrol(targets[index] ?? point));
      return patrolUnits.length;
    },
    selectHero: () => {
      if (hero.alive) {
        selectionSystem.setSelection([hero]);
        refreshHud();
      }
    },
    centerOnHero: () => cameraSystem.centerOn(hero.position),
    castAbilitySlot,
    toggleFogDebug,
    showMessage: (message, x, y, color, options) => showMessage(message, x, y, color, options)
  });

  showBattleStartSummary();

  const enemyAIConfig = applyCampaignEnemyAIModifierEffects(
    launch.request.mode === "tutorial" ? applyTutorialEnemyAIPacing(activeMap.scenario.enemyAI) : activeMap.scenario.enemyAI,
    launch.request.mode === "tutorial" ? [] : launch.request.modifiers
  );
  const enemyDoctrine = selectEnemyDoctrineForBattleLaunch({
    mode: launch.request.mode,
    campaignNodeId: launch.request.campaignNodeId,
    modifierIds: launch.request.modifiers.map((modifier) => modifier.id),
    enemyHeroId: launch.request.enemyHeroId,
    difficulty: launch.request.difficulty,
    retinueUnitCount: launch.request.retinueUnits?.length ?? 0,
    retinueReserveCount: launch.request.retinueReserveUnits?.length ?? 0,
    rewardsDisabled: launch.request.rewardsDisabled
  });
  runtime.recordEnemyDoctrine(enemyDoctrine?.id);
  const aiController = new EnemyAIController({
    resources: resources.enemy,
    getUnits,
    getBuildings,
    getCaptureSites,
    resourceSystem,
    training: trainingSystem,
    upgradeSystem,
    isUpgradeResearched: (upgradeId) => isUpgradeResearched("enemy", upgradeId),
    getAttackTarget: findPlayerBaseBuilding,
    getElapsedSeconds: () => runtime.elapsedSeconds,
    getPlayerMilestones: () => ({
      isFirstBattle: isFirstBattle(),
      hasCapturedSite: runtime.stats.resourcesCaptured > 0,
      hasBuiltProduction: hasPlayerProductionBuilding()
    }),
    onAlert: (message, x, y) => showMessage(message, x, y, "#f6e27d"),
    onWaveLaunched: trackEnemyWave,
    difficulty: launch.request.difficulty,
    config: enemyAIConfig,
    doctrine: enemyDoctrine,
    modifierIds: launch.request.modifiers.map((modifier) => modifier.id),
    onDoctrineAction: (label) => runtime.recordEnemyDoctrineAction(label),
    aiPersonalityId: launch.request.aiPersonalityId,
    attackWarningLeadSeconds: strongholdEffects.enemyWarningLeadSeconds
  });
  const aiSystem = new AISystem(aiController);

  return {
    movementSystem,
    combatSystem,
    resourceSystem,
    repairSystem,
    buildingSystem,
    trainingSystem,
    upgradeSystem,
    selectionSystem,
    controlGroupSystem,
    abilitySystem,
    enemyHeroAbilitySystem,
    cameraSystem,
    inputSystem,
    uiSystem,
    xpSystem,
    aiSystem
  };
}

export function createBattleFogOfWar(activeMap: BattleMapDefinition): FogOfWarSystem {
  return new FogOfWarSystem(activeMap.width, activeMap.height, BATTLE_FOG_CELL_SIZE);
}

export function applyFirstCaptureBonusAdditions(
  siteId: string,
  owner: Team,
  bonus: CaptureSiteFirstCaptureBonusDefinition,
  strongholdEffects: Pick<StrongholdBattleEffects, "firstCaptureBonusResourceAdditions">
): CaptureSiteFirstCaptureBonusDefinition {
  const additions = owner === "player" ? strongholdEffects.firstCaptureBonusResourceAdditions[siteId] : undefined;
  if (!additions || !Object.values(additions).some((amount) => (amount ?? 0) > 0)) {
    return bonus;
  }
  return {
    ...bonus,
    description: `${bonus.description} Waystation attunement adds a small extra surge.`,
    resources: {
      crowns: (bonus.resources.crowns ?? 0) + (additions.crowns ?? 0),
      stone: (bonus.resources.stone ?? 0) + (additions.stone ?? 0),
      iron: (bonus.resources.iron ?? 0) + (additions.iron ?? 0),
      aether: (bonus.resources.aether ?? 0) + (additions.aether ?? 0)
    }
  };
}

function formatResourceBonus(resources: CaptureSiteFirstCaptureBonusDefinition["resources"]): string {
  const labels: Record<ResourceKey, string> = {
    crowns: "Crowns",
    stone: "Stone",
    iron: "Iron",
    aether: "Aether"
  };
  return (Object.keys(labels) as ResourceKey[])
    .flatMap((resource) => {
      const amount = resources[resource] ?? 0;
      return amount > 0 ? [`+${amount} ${labels[resource]}`] : [];
    })
    .join(", ");
}

function damageFeedbackThresholdFor(source: Unit | Building | Projectile, target: BaseEntity): number | undefined {
  if (source instanceof Unit && source.definition.id === "worker" && target instanceof Building && source.attackTargetId === target.id) {
    return 1;
  }
  return undefined;
}
