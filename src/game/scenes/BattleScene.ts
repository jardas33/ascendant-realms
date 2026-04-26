import Phaser from "phaser";
import type {
  BattleSecondaryObjectiveType,
  Position,
  ResourceBag,
  ResourceKey,
  Team,
  UpgradeDefinition
} from "../core/GameTypes";
import { formatTime } from "../core/MathUtils";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { DEFAULT_SETTINGS, applySettingsToDocument, normalizeSettingsData } from "../core/Settings";
import {
  BUILDING_BY_ID,
  AI_PERSONALITY_BY_ID,
  CAMPAIGN_MODIFIER_BY_ID,
  FACTION_BY_ID,
  UPGRADE_BY_ID
} from "../data/contentIndex";
import { getBattleDifficulty } from "../data/battlePacing";
import { DEFAULT_MAP_ID, MAPS } from "../data/maps";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { EnemyAIController } from "../ai/EnemyAIController";
import { BattleRuntime, createBattleRuntime } from "../battle/BattleRuntime";
import { drawBattleMap } from "../battle/BattleSceneMapRenderer";
import { endBattleAndOpenResults } from "../battle/BattleSceneResults";
import { createBattleMinimapSnapshot } from "../battle/BattleSceneSnapshots";
import { completeBattleSecondaryObjective } from "../battle/BattleSceneObjectives";
import { spawnBattleScenario } from "../battle/BattleSceneSpawner";
import {
  appendMinimapPing,
  firstBattleTutorialHint,
  trackEnemyWave as trackEnemyWaveAlert,
  updateMinimapPings,
  updateResourceSiteWarnings,
  updateTrackedEnemyWaves,
  warnIfCommandHallUnderAttack as warnCommandHallUnderAttack,
  type TrackedEnemyWave
} from "../battle/BattleSceneAlerts";
import {
  createSkirmishBattleLaunchRequest,
  resolveBattleLaunchRequest,
  type BattleLaunchRequest,
  type ResolvedBattleLaunch
} from "../battle/BattleLaunchRequest";
import type { BaseEntity } from "../entities/BaseEntity";
import { resetEntityIds } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { CaptureSite } from "../entities/CaptureSite";
import { Hero } from "../entities/Hero";
import { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";
import type { HeroSaveData } from "../save/SaveTypes";
import type { SaveSettingsData } from "../save/SaveTypes";
import { HUD } from "../ui/HUD";
import { FloatingText } from "../ui/FloatingText";
import type { MinimapPing, MinimapSnapshot } from "../ui/MinimapView";
import { AbilitySystem } from "../systems/AbilitySystem";
import { AISystem } from "../systems/AISystem";
import { AudioManager } from "../systems/AudioManager";
import { BuildingSystem } from "../systems/BuildingSystem";
import { CameraSystem } from "../systems/CameraSystem";
import { CollisionSystem } from "../systems/CollisionSystem";
import { CombatSystem } from "../systems/CombatSystem";
import { FogOfWarSystem, isEntityVisibleToPlayer, type VisionSource } from "../systems/FogOfWarSystem";
import { InputSystem } from "../systems/InputSystem";
import { MovementSystem } from "../systems/MovementSystem";
import { ResourceSystem } from "../systems/ResourceSystem";
import { SelectionSystem } from "../systems/SelectionSystem";
import { TrainingSystem } from "../systems/TrainingSystem";
import { canUseRallyPoint, setRallyPointForBuildings } from "../systems/RallyPointSystem";
import { tickStatusEffects } from "../systems/StatusEffectSystem";
import { UISystem } from "../systems/UISystem";
import { applyUpgradeToUnit } from "../systems/UpgradeEffects";
import { UpgradeSystem } from "../systems/UpgradeSystem";
import type { TechState } from "../systems/PrerequisiteSystem";
import { XPSystem } from "../systems/XPSystem";

interface BattleSceneData {
  launchRequest?: BattleLaunchRequest;
  heroSave?: HeroSaveData;
}

export class BattleScene extends Phaser.Scene {
  private heroSave: HeroSaveData = createFallbackHeroSave();
  private launchRequest: BattleLaunchRequest = createSkirmishBattleLaunchRequest(this.heroSave);
  private launch: ResolvedBattleLaunch = this.resolveLaunchOrFallback();
  private activeMap = this.launch.map;
  private runtime: BattleRuntime = createBattleRuntime({ launch: this.launch });
  private resources: Record<"player" | "enemy", ResourceBag> = this.runtime.resources;

  private units: Unit[] = [];
  private buildings: Building[] = [];
  private projectiles: Projectile[] = [];
  private captureSites: CaptureSite[] = [];
  private hero!: Hero;

  private movementSystem!: MovementSystem;
  private combatSystem!: CombatSystem;
  private resourceSystem!: ResourceSystem;
  private buildingSystem!: BuildingSystem;
  private trainingSystem!: TrainingSystem;
  private upgradeSystem!: UpgradeSystem;
  private selectionSystem!: SelectionSystem;
  private abilitySystem!: AbilitySystem;
  private cameraSystem!: CameraSystem;
  private inputSystem!: InputSystem;
  private uiSystem!: UISystem;
  private xpSystem!: XPSystem;
  private aiSystem!: AISystem;

  private statusMessage = "Capture resource sites to grow your army.";
  private statusTimer = 4;
  private tutorialHint = "Select your hero, then right-click the Crown Shrine to begin.";
  private commandHallWarningCooldown = 0;
  private minimapPings: MinimapPing[] = [];
  private nextMinimapPingId = 1;
  private rallyMarkers = new Map<string, Phaser.GameObjects.Container>();
  private fogOfWar?: FogOfWarSystem;
  private fogOverlay?: Phaser.GameObjects.Graphics;
  private fogUpdateTimer = 0;
  private fogDebugDisabled = false;
  private settings: SaveSettingsData = DEFAULT_SETTINGS;
  private lastSelectionAudioKey = "";
  private resourceSiteWarningCooldowns = new Map<string, number>();
  private trackedEnemyWaves: TrackedEnemyWave[] = [];
  private nextEnemyWaveId = 1;
  private researchedUpgradeIds: Record<"player" | "enemy", Set<string>> = {
    player: new Set<string>(),
    enemy: new Set<string>()
  };

  constructor() {
    super(SCENE_KEYS.battle);
  }

  init(data: BattleSceneData): void {
    if (data.launchRequest) {
      this.launchRequest = data.launchRequest;
      this.heroSave = data.launchRequest.heroSave;
      return;
    }

    this.heroSave = data.heroSave ?? SaveSystem.load()?.hero ?? createFallbackHeroSave();
    this.launchRequest = createSkirmishBattleLaunchRequest(this.heroSave, { sourceId: "legacy_scene_data" });
  }

  create(): void {
    this.resetRuntimeState();
    this.drawMap();
    this.spawnScenario();
    this.createFogOverlay();
    this.createSystems();
    this.updateFogOfWar(0, true);
    this.cameraSystem.centerOn(this.hero.position);
    this.selectionSystem.setSelection([this.hero]);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
  }

  update(_time: number, deltaMs: number): void {
    if (this.runtime.ended || !this.hero) {
      return;
    }

    const deltaSeconds = deltaMs / 1000;
    this.runtime.tick(deltaSeconds);
    this.statusTimer = Math.max(0, this.statusTimer - deltaSeconds);
    this.commandHallWarningCooldown = Math.max(0, this.commandHallWarningCooldown - deltaSeconds);
    this.updateMinimapPings(deltaSeconds);
    if (this.statusTimer === 0) {
      this.statusMessage = this.buildingSystem.pendingBuildingId
        ? this.buildingSystem.placementMessage || "Click valid ground near your base to place the building."
        : `AI: ${this.aiSystem.state} - Time ${formatTime(this.runtime.elapsedSeconds)}`;
    }

    this.cameraSystem.update(deltaSeconds);
    this.abilitySystem.update(deltaSeconds, this.hero);
    this.movementSystem.update(deltaSeconds, this.units, this.activeMap, this.buildings);
    this.combatSystem.update(deltaSeconds);
    this.updateStatusEffects(deltaSeconds);
    this.buildingSystem.update(deltaSeconds);
    this.resourceSystem.update(deltaSeconds, this.captureSites, this.units);
    this.updateResourceSiteWarnings(deltaSeconds);
    this.trainingSystem.update(deltaSeconds, this.buildings);
    this.upgradeSystem.update(deltaSeconds, this.buildings);
    this.aiSystem.update(deltaSeconds);
    this.cleanupDeadEntities();
    this.updateTrackedEnemyWaves();
    this.updateTutorialHint();
    this.updateFogOfWar(deltaSeconds);
    const selected = this.selectedUnitOrBuildings();
    this.playSelectionAudio(selected);
    this.uiSystem.update(deltaSeconds, {
      resources: this.resources.player,
      hero: this.hero,
      selected,
      elapsedSeconds: this.runtime.elapsedSeconds,
      isPlacing: Boolean(this.buildingSystem.pendingBuildingId),
      status: this.statusMessage,
      hint: this.tutorialHint,
      techState: this.getTechState("player"),
      minimap: this.createMinimapSnapshot()
    });
    this.checkEndConditions();
  }

  private resetRuntimeState(): void {
    document.getElementById("ui-root")?.replaceChildren();
    this.settings = normalizeSettingsData(SaveSystem.load()?.settings ?? DEFAULT_SETTINGS);
    applySettingsToDocument(this.settings);
    AudioManager.configure(this.settings);
    FloatingText.configure(this.settings);
    resetEntityIds();
    this.cameras.main.setBackgroundColor("#17241d");
    this.launch = this.resolveLaunchOrFallback();
    this.heroSave = this.launch.request.heroSave;
    this.activeMap = this.launch.map;
    this.fogOverlay?.destroy();
    this.fogOverlay = undefined;
    this.fogOfWar = new FogOfWarSystem(this.activeMap.width, this.activeMap.height);
    this.fogUpdateTimer = 0;
    this.fogDebugDisabled = false;
    this.lastSelectionAudioKey = "";
    this.runtime = createBattleRuntime({ launch: this.launch });
    this.resources = this.runtime.resources;
    this.units = [];
    this.buildings = [];
    this.projectiles = [];
    this.captureSites = [];
    this.statusMessage = "Capture resource sites to grow your army.";
    this.statusTimer = 4;
    this.tutorialHint = "Select your hero, then right-click the Crown Shrine to begin.";
    this.commandHallWarningCooldown = 0;
    this.minimapPings = [];
    this.nextMinimapPingId = 1;
    this.rallyMarkers.forEach((marker) => marker.destroy(true));
    this.rallyMarkers = new Map<string, Phaser.GameObjects.Container>();
    this.resourceSiteWarningCooldowns = new Map<string, number>();
    this.trackedEnemyWaves = [];
    this.nextEnemyWaveId = 1;
    this.researchedUpgradeIds = {
      player: new Set<string>(),
      enemy: new Set<string>()
    };
  }

  private drawMap(): void {
    drawBattleMap(this, this.activeMap);
  }

  private spawnScenario(): void {
    const spawned = spawnBattleScenario({
      scene: this,
      activeMap: this.activeMap,
      heroSave: this.heroSave,
      launch: this.launch,
      addUnit: (unit) => this.addUnit(unit),
      addBuilding: (building) => this.addBuilding(building)
    });
    this.hero = spawned.hero;
    this.captureSites = spawned.captureSites;
  }

  private createSystems(): void {
    this.selectionSystem = new SelectionSystem(() => [
      ...this.units.filter((unit) => unit.team === "player"),
      ...this.buildings.filter((building) => building.team === "player")
    ]);

    this.movementSystem = new MovementSystem({
      onPathFailed: (unit, target) => {
        if (unit.team === "player") {
          this.showMessage("No clear path. Moving as close as possible.", target.x, target.y - 24, "#f0d978");
        }
      }
    });
    this.trainingSystem = new TrainingSystem({
      scene: this,
      addUnit: (unit) => this.addUnit(unit),
      onMessage: (message, x, y) => this.showMessage(message, x, y),
      onUnitTrained: (unit) => {
        if (unit.team === "player") {
          this.runtime.recordUnitTrained(unit.definition.id);
          AudioManager.play("unit_trained");
        }
      },
      getTechState: (team) => this.getTechState(team)
    });
    this.buildingSystem = new BuildingSystem({
      scene: this,
      map: this.activeMap,
      getBuildings: () => this.buildings,
      getCaptureSites: () => this.captureSites,
      addBuilding: (building) => this.addBuilding(building),
      onMessage: (message, x, y) => this.showMessage(message, x, y),
      onConstructionStarted: (building) => {
        if (building.team === "player") {
          this.selectionSystem.setSelection([building]);
          AudioManager.play("build_started");
        }
      },
      onBuilt: (building) => {
        if (building.team === "player") {
          this.runtime.recordBuildingBuilt(building.definition.id);
          AudioManager.play("build_complete");
        }
      }
    });
    this.upgradeSystem = new UpgradeSystem({
      getTechState: (team) => this.getTechState(team),
      isResearched: (team, upgradeId) => this.isUpgradeResearched(team, upgradeId),
      markResearched: (team, upgradeId) => this.markUpgradeResearched(team, upgradeId),
      onMessage: (message, x, y) => this.showMessage(message, x, y),
      onUpgradeCompleted: (team, upgrade) => this.applyUpgradeEffects(team, upgrade)
    });
    this.xpSystem = new XPSystem(this.hero, (amount, leveledUp) => {
      this.runtime.recordXpGained(amount);
      this.showMessage(leveledUp ? `Level up! +${amount} XP` : `+${amount} XP`, this.hero.position.x, this.hero.position.y - 54, "#f6e27d");
    });
    this.combatSystem = new CombatSystem({
      scene: this,
      getUnits: () => this.units,
      getBuildings: () => this.buildings,
      getProjectiles: () => this.projectiles,
      addProjectile: (projectile) => this.projectiles.push(projectile),
      onDamage: (target, amount) => {
        if (amount >= 5) {
          FloatingText.show(this, `-${amount}`, target.position.x, target.position.y - target.radius, "#ffb1a9");
        }
        this.warnIfCommandHallUnderAttack(target);
      },
      onStatusApplied: (target, statusName) => {
        FloatingText.show(this, statusName, target.position.x, target.position.y - target.radius - 18, "#ff9a64");
      },
      onKill: (killer, target) => this.handleKill(killer, target)
    });
    this.resourceSystem = new ResourceSystem({
      resources: this.resources,
      onCapture: (site, owner) => {
        if (owner === "player") {
          this.runtime.recordResourceCaptured(site.definition.id);
          this.showMessage(`${site.definition.name} captured`, site.position.x, site.position.y - 70, "#aef7b7");
          this.completeSecondaryObjective("capture_site", site.definition.id, site.position);
          return;
        }
        if (owner === "enemy") {
          this.addMinimapPing(site.position.x, site.position.y, "#f0d978", `${site.definition.name} captured by enemy`);
        }
      },
      onIncome: (site, owner, amount) => {
        if (owner === "player") {
          this.showMessage(`+${amount} ${site.definition.resource}`, site.position.x, site.position.y - 64, "#f5efc2");
        }
      }
    });
    this.abilitySystem = new AbilitySystem({
      scene: this,
      getUnits: () => this.units,
      getBuildings: () => this.buildings,
      addProjectile: (projectile) => this.projectiles.push(projectile),
      onDamage: (target, amount) => {
        if (amount >= 5) {
          FloatingText.show(this, `-${amount}`, target.position.x, target.position.y - target.radius, "#ffb1a9");
        }
        this.warnIfCommandHallUnderAttack(target);
      },
      onKill: (killer, target) => this.handleKill(killer, target),
      onMessage: (message, x, y, color) => this.showMessage(message, x, y, color)
    });
    this.cameraSystem = new CameraSystem(this, this.activeMap);

    const hud = new HUD({
      onBuild: (buildingId) => {
        this.buildingSystem.startPlacement(buildingId);
        AudioManager.play("ui_click");
        const definition = BUILDING_BY_ID[buildingId];
        this.showMessage(`Placing ${definition?.name ?? "building"}`);
      },
      onTrain: (unitId, sourceBuildingId) => {
        const building = this.buildings.find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          if (this.trainingSystem.queueTraining(building, unitId, this.resources.player)) {
            AudioManager.play("ui_click");
          }
        }
      },
      onCancelTrain: (sourceBuildingId, queueIndex) => {
        const building = this.buildings.find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          this.trainingSystem.cancelTraining(building, queueIndex, this.resources.player);
        }
      },
      onUpgrade: (upgradeId, sourceBuildingId) => {
        const building = this.buildings.find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          if (this.upgradeSystem.queueUpgrade(building, upgradeId, this.resources.player)) {
            AudioManager.play("ui_click");
          }
        }
      },
      onCancelUpgrade: (sourceBuildingId, queueIndex) => {
        const building = this.buildings.find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          this.upgradeSystem.cancelUpgrade(building, queueIndex, this.resources.player);
        }
      },
      onAbility: (abilityId) => {
        AudioManager.play("ability_cast");
        this.abilitySystem.castAbility(this.hero, abilityId, this.selectionSystem.getSelected());
      },
      onMinimapMove: (normalizedX, normalizedY) => this.centerCameraFromMinimap(normalizedX, normalizedY),
      onMenu: () => this.scene.start(SCENE_KEYS.mainMenu)
    });
    this.uiSystem = new UISystem(hud);

    this.inputSystem = new InputSystem({
      scene: this,
      selection: this.selectionSystem,
      findWorldEntityAt: (point) => this.findWorldEntityAt(point),
      isPlacingBuilding: () => Boolean(this.buildingSystem.pendingBuildingId),
      updateBuildingGhost: (point) => this.buildingSystem.updateGhost(point.x, point.y, this.resources.player),
      placeBuilding: (point) => this.buildingSystem.tryPlace(point.x, point.y, this.resources.player),
      cancelPlacement: () => {
        this.buildingSystem.cancelPlacement();
        this.showMessage("Building placement cancelled");
      },
      getSelectedUnits: () => this.selectionSystem.getSelected().filter((entity): entity is Unit => entity instanceof Unit),
      getSelectedRallyBuildings: () => this.selectedRallyBuildings(),
      setRallyPoint: (point, buildings) => this.setRallyPoint(point, buildings),
      selectHero: () => {
        if (this.hero.alive) {
          this.selectionSystem.setSelection([this.hero]);
        }
      },
      centerOnHero: () => this.cameraSystem.centerOn(this.hero.position),
      castAbilitySlot: (slot) => this.castAbilitySlot(slot),
      toggleFogDebug: () => this.toggleFogDebug(),
      showMessage: (message) => this.showMessage(message)
    });
    this.showBattleStartSummary();

    const aiController = new EnemyAIController({
      resources: this.resources.enemy,
      getUnits: () => this.units,
      getBuildings: () => this.buildings,
      getCaptureSites: () => this.captureSites,
      training: this.trainingSystem,
      getAttackTarget: () => this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player"),
      getElapsedSeconds: () => this.runtime.elapsedSeconds,
      getPlayerMilestones: () => ({
        isFirstBattle: this.isFirstBattle(),
        hasCapturedSite: this.runtime.stats.resourcesCaptured > 0,
        hasBuiltProduction: this.hasPlayerProductionBuilding()
      }),
      onAlert: (message, x, y) => this.showMessage(message, x, y, "#f6e27d"),
      onWaveLaunched: (units) => this.trackEnemyWave(units),
      difficulty: this.launch.request.difficulty,
      config: this.activeMap.scenario.enemyAI,
      aiPersonalityId: this.launch.request.aiPersonalityId
    });
    this.aiSystem = new AISystem(aiController);
  }

  private showBattleStartSummary(): void {
    const faction = FACTION_BY_ID[this.launch.request.enemyProfileId ?? "ashen_covenant"];
    const personality = AI_PERSONALITY_BY_ID[this.launch.request.aiPersonalityId ?? "balanced_warlord"];
    const difficulty = getBattleDifficulty(this.launch.request.difficulty);
    const names = this.launch.request.modifiers
      .map((modifier) => CAMPAIGN_MODIFIER_BY_ID[modifier.id]?.name)
      .filter((name): name is string => Boolean(name));
    const modifierText = names.length > 0 ? ` Modifiers: ${names.join(", ")}.` : "";
    const enemyText = faction
      ? `${faction.name} (${personality?.name ?? "Balanced Warlord"})`
      : personality?.name ?? "Unknown enemy";
    this.showMessage(
      `${this.activeMap.name} - ${difficulty.name}. Enemy: ${enemyText}.${modifierText}`,
      this.hero.position.x,
      this.hero.position.y - 96,
      "#f6e27d"
    );
  }

  private addUnit(unit: Unit): void {
    this.units.push(unit);
    this.applyResearchedUpgradesToUnit(unit);
  }

  private addBuilding(building: Building): void {
    this.buildings.push(building);
  }

  private createFogOverlay(): void {
    this.fogOverlay?.destroy();
    this.fogOverlay = this.add.graphics().setDepth(21);
  }

  private updateFogOfWar(deltaSeconds: number, force = false): void {
    const fog = this.fogOfWar;
    if (!fog) {
      return;
    }

    if (!this.isFogActive()) {
      this.fogOverlay?.clear().setVisible(false);
      this.applyFogEntityVisibility(false);
      return;
    }

    this.fogUpdateTimer = Math.max(0, this.fogUpdateTimer - deltaSeconds);
    if (!force && this.fogUpdateTimer > 0) {
      return;
    }

    this.fogUpdateTimer = 0.24;
    fog.update(this.createVisionSources());
    this.renderFogOverlay();
    this.applyFogEntityVisibility(true);
  }

  private createVisionSources(): VisionSource[] {
    const unitSources = this.units
      .filter((unit) => unit.alive && unit.team === "player")
      .map((unit) => ({
        x: unit.position.x,
        y: unit.position.y,
        radius: unit.definition.visionRadius
      }));
    const buildingSources = this.buildings
      .filter((building) => building.alive && building.team === "player")
      .map((building) => ({
        x: building.position.x,
        y: building.position.y,
        radius: building.isCompleted() ? building.definition.visionRadius : building.definition.visionRadius * 0.65
      }));
    return [...unitSources, ...buildingSources];
  }

  private renderFogOverlay(): void {
    if (!this.fogOverlay || !this.fogOfWar) {
      return;
    }

    this.fogOverlay.clear().setVisible(true);
    this.fogOfWar.cells().forEach((cell) => {
      if (cell.state === "visible") {
        return;
      }
      const alpha = cell.state === "unseen" ? 0.86 : 0.48;
      this.fogOverlay?.fillStyle(0x020503, alpha);
      this.fogOverlay?.fillRect(cell.x, cell.y, cell.width, cell.height);
    });
  }

  private applyFogEntityVisibility(fogEnabled: boolean): void {
    const fog = this.fogOfWar;
    if (!fog || !fogEnabled) {
      [...this.units, ...this.buildings, ...this.captureSites, ...this.projectiles].forEach((entity) => entity.view?.setVisible(true));
      return;
    }

    this.units.forEach((unit) => unit.view?.setVisible(isEntityVisibleToPlayer(unit, fog, true)));
    this.buildings.forEach((building) => building.view?.setVisible(isEntityVisibleToPlayer(building, fog, true)));
    this.projectiles.forEach((projectile) => projectile.view?.setVisible(projectile.team === "player" || fog.isVisible(projectile.position)));
    this.captureSites.forEach((site) => site.view?.setVisible(fog.isExplored(site.position)));
  }

  private isFogActive(): boolean {
    const difficultyFog = getBattleDifficulty(this.launch.request.difficulty).fogOfWarEnabled;
    const requestedFog =
      this.settings.fogEnabledOverride === "enabled"
        ? true
        : this.settings.fogEnabledOverride === "disabled"
          ? false
          : difficultyFog;
    return requestedFog && !this.fogDebugDisabled;
  }

  private isPointVisibleToPlayer(point: Position): boolean {
    return !this.isFogActive() || !this.fogOfWar || this.fogOfWar.isVisible(point);
  }

  private isPointExploredByPlayer(point: Position): boolean {
    return !this.isFogActive() || !this.fogOfWar || this.fogOfWar.isExplored(point);
  }

  private toggleFogDebug(): void {
    const difficulty = getBattleDifficulty(this.launch.request.difficulty);
    if (!difficulty.fogOfWarEnabled) {
      this.showMessage("Fog is disabled for this difficulty.");
      return;
    }
    this.fogDebugDisabled = !this.fogDebugDisabled;
    this.showMessage(this.fogDebugDisabled ? "Fog debug: revealed" : "Fog debug: enabled");
    this.updateFogOfWar(0, true);
  }

  private selectedRallyBuildings(): Building[] {
    return this.selectionSystem
      .getSelected()
      .filter((entity): entity is Building => entity instanceof Building && canUseRallyPoint(entity));
  }

  private setRallyPoint(point: Position, buildings: Building[]): boolean {
    const assignment = setRallyPointForBuildings(buildings, point);
    if (assignment.updatedCount === 0) {
      return false;
    }

    buildings.filter((building) => canUseRallyPoint(building)).forEach((building) => {
      this.updateRallyMarker(building);
      this.showRallyLine(building, assignment.rallyPoint);
    });
    this.addMinimapPing(assignment.rallyPoint.x, assignment.rallyPoint.y, "#9cf7b1", "Rally point set");
    this.showMessage(
      assignment.updatedCount === 1 ? "Rally point set" : `Rally point set for ${assignment.updatedCount} buildings`,
      assignment.rallyPoint.x,
      assignment.rallyPoint.y - 28,
      "#b9f7c7"
    );
    return true;
  }

  private updateRallyMarker(building: Building): void {
    this.rallyMarkers.get(building.id)?.destroy(true);
    if (!building.alive || !building.rallyPoint) {
      this.rallyMarkers.delete(building.id);
      return;
    }

    const marker = this.add.container(building.rallyPoint.x, building.rallyPoint.y).setDepth(26);
    const base = this.add.circle(0, 0, 7, 0x14351f, 0.8).setStrokeStyle(2, 0x9cf7b1, 0.92);
    const pole = this.add.rectangle(0, -13, 3, 28, 0xf5efc2, 0.92).setOrigin(0.5, 1);
    const flag = this.add
      .triangle(7, -30, 0, 0, 22, 7, 0, 14, 0x78dc7b, 0.95)
      .setStrokeStyle(1, 0xf5efc2, 0.85);
    marker.add([base, pole, flag]);
    this.rallyMarkers.set(building.id, marker);
  }

  private showRallyLine(building: Building, point: Position): void {
    const line = this.add.graphics().setDepth(25);
    line.lineStyle(2, 0x9cf7b1, 0.82);
    line.lineBetween(building.position.x, building.position.y, point.x, point.y);
    this.tweens.add({
      targets: line,
      alpha: 0,
      duration: 850,
      onComplete: () => line.destroy()
    });
  }

  private findWorldEntityAt(point: Position): BaseEntity | undefined {
    return CollisionSystem.findEntityAt(
      point.x,
      point.y,
      [...this.units, ...this.buildings].filter((entity) => entity.team === "player" || this.isPointVisibleToPlayer(entity.position))
    );
  }

  private centerCameraFromMinimap(normalizedX: number, normalizedY: number): void {
    this.cameraSystem.centerOn({
      x: Phaser.Math.Clamp(normalizedX, 0, 1) * this.activeMap.width,
      y: Phaser.Math.Clamp(normalizedY, 0, 1) * this.activeMap.height
    });
  }

  private createMinimapSnapshot(): MinimapSnapshot {
    return createBattleMinimapSnapshot({
      activeMap: this.activeMap,
      camera: this.cameras.main,
      captureSites: this.captureSites,
      buildings: this.buildings,
      units: this.units,
      hero: this.hero,
      selectedRallyBuildings: this.selectedRallyBuildings(),
      fogOfWar: this.fogOfWar,
      fogEnabled: this.isFogActive(),
      colorblindPalette: this.settings.colorblindMinimapPalette,
      pings: this.minimapPings,
      isPointExploredByPlayer: (point) => this.isPointExploredByPlayer(point),
      resourceColor: (resource) => this.resourceColor(resource)
    });
  }

  private selectedUnitOrBuildings(): Array<Unit | Building> {
    return this.selectionSystem
      .getSelected()
      .filter((entity): entity is Unit | Building => entity instanceof Unit || entity instanceof Building);
  }

  private playSelectionAudio(selected: Array<Unit | Building>): void {
    const key = selected
      .map((entity) => entity.id)
      .sort()
      .join("|");
    if (key && key !== this.lastSelectionAudioKey) {
      AudioManager.play("unit_selected");
    }
    this.lastSelectionAudioKey = key;
  }

  private updateStatusEffects(deltaSeconds: number): void {
    [...this.units, ...this.buildings].forEach((entity) => {
      if (!entity.alive) {
        return;
      }
      const ticks = tickStatusEffects(entity, deltaSeconds);
      ticks.forEach((tick) => {
        if (!entity.alive) {
          return;
        }
        const wasAlive = entity.alive;
        const actual = entity.takeDamage(tick.damage);
        if (actual > 0) {
          FloatingText.show(this, `-${Math.round(actual)}`, entity.position.x, entity.position.y - entity.radius - 8, "#ff9a64");
          this.warnIfCommandHallUnderAttack(entity);
        }
        if (wasAlive && !entity.alive) {
          const source = tick.sourceId ? this.findEntityById(tick.sourceId) : undefined;
          if (source) {
            this.handleKill(source, entity);
          }
          entity.destroyView();
        }
      });
    });
  }

  private handleKill(killer: Unit | Building | Projectile, target: BaseEntity): void {
    if (target.team !== "player") {
      if (target instanceof Building) {
        this.runtime.recordBuildingDestroyed();
        this.completeSecondaryObjective("destroy_building", target.definition.id, target.position);
      } else if (target instanceof Unit) {
        this.runtime.recordUnitKilled();
        this.completeSecondaryObjective("defeat_unit", target.definition.id, target.position);
      }
    }
    this.xpSystem.awardForKill(killer, target);
  }

  private completeSecondaryObjective(type: BattleSecondaryObjectiveType, targetId: string, point?: Position): void {
    completeBattleSecondaryObjective({
      activeMap: this.activeMap,
      runtime: this.runtime,
      type,
      targetId,
      point,
      showMessage: (message, x, y, color) => this.showMessage(message, x, y, color)
    });
  }

  private cleanupDeadEntities(): void {
    this.cleanupRallyMarkers();
    this.units = this.units.filter((unit) => unit.alive);
    this.buildings = this.buildings.filter((building) => building.alive);
  }

  private cleanupRallyMarkers(): void {
    this.rallyMarkers.forEach((marker, buildingId) => {
      const building = this.buildings.find((entry) => entry.id === buildingId);
      if (!building?.alive || !building.rallyPoint) {
        marker.destroy(true);
        this.rallyMarkers.delete(buildingId);
      }
    });
  }

  private checkEndConditions(): void {
    const outcome = this.runtime.evaluateObjectives({
      playerBaseAlive: Boolean(this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player")),
      enemyBaseAlive: Boolean(this.findBuilding(this.activeMap.scenario.objectives.enemyBaseBuildingId, "enemy"))
    });
    if (outcome) {
      this.endBattle(outcome);
    }
  }

  private endBattle(outcome: "victory" | "defeat"): void {
    endBattleAndOpenResults({
      scene: this,
      runtime: this.runtime,
      hero: this.hero,
      launch: this.launch,
      outcome
    });
  }

  private castAbilitySlot(slot: number): void {
    const abilityId = this.hero.unlockedAbilities[slot];
    if (!abilityId) {
      this.showMessage("No ability in that slot");
      return;
    }
    AudioManager.play("ability_cast");
    this.abilitySystem.castAbility(this.hero, abilityId, this.selectionSystem.getSelected());
  }

  private findBuilding(id: string, team: "player" | "enemy"): Building | undefined {
    return this.buildings.find((building) => building.alive && building.team === team && building.definition.id === id);
  }

  private findEntityById(id: string): Unit | Building | undefined {
    return [...this.units, ...this.buildings].find((entity) => entity.id === id);
  }

  private isFirstBattle(): boolean {
    return this.launch.request.mode === "skirmish" && this.heroSave.completedBattles === 0 && this.activeMap.id === DEFAULT_MAP_ID;
  }

  private hasPlayerProductionBuilding(): boolean {
    return this.buildings.some(
      (building) =>
        building.alive &&
        building.isCompleted() &&
        building.team === "player" &&
        (building.definition.id === "barracks" || building.definition.id === "mystic_lodge")
    );
  }

  private getTechState(team: Team): TechState {
    const researchedUpgradeIds =
      team === "player" || team === "enemy" ? this.researchedUpgradeIds[team] : new Set<string>();
    return {
      completedBuildingIds: new Set(
        this.buildings
          .filter((building) => building.alive && building.team === team && building.isCompleted())
          .map((building) => building.definition.id)
      ),
      researchedUpgradeIds,
      heroLevel: this.hero?.level ?? 1
    };
  }

  private isUpgradeResearched(team: Team, upgradeId: string): boolean {
    return (team === "player" || team === "enemy") && this.researchedUpgradeIds[team].has(upgradeId);
  }

  private markUpgradeResearched(team: Team, upgradeId: string): void {
    if (team === "player" || team === "enemy") {
      this.researchedUpgradeIds[team].add(upgradeId);
    }
  }

  private applyUpgradeEffects(team: Team, upgrade: UpgradeDefinition): void {
    this.units
      .filter((unit) => unit.alive && unit.team === team)
      .forEach((unit) => applyUpgradeToUnit(unit, upgrade));
  }

  private applyResearchedUpgradesToUnit(unit: Unit): void {
    if (unit.team !== "player" && unit.team !== "enemy") {
      return;
    }
    this.researchedUpgradeIds[unit.team].forEach((upgradeId) => {
      const upgrade = UPGRADE_BY_ID[upgradeId];
      if (upgrade) {
        applyUpgradeToUnit(unit, upgrade);
      }
    });
  }

  private updateMinimapPings(deltaSeconds: number): void {
    this.minimapPings = updateMinimapPings(this.minimapPings, deltaSeconds);
  }

  private addMinimapPing(x: number, y: number, color: string, label: string): void {
    const result = appendMinimapPing(this.minimapPings, this.nextMinimapPingId, x, y, color, label);
    this.minimapPings = result.pings;
    this.nextMinimapPingId = result.nextId;
  }

  private updateResourceSiteWarnings(deltaSeconds: number): void {
    this.resourceSiteWarningCooldowns = updateResourceSiteWarnings({
      cooldowns: this.resourceSiteWarningCooldowns,
      deltaSeconds,
      captureSites: this.captureSites,
      units: this.units,
      addMinimapPing: (x, y, color, label) => this.addMinimapPing(x, y, color, label),
      showMessage: (message, x, y, color) => this.showMessage(message, x, y, color)
    });
  }

  private trackEnemyWave(units: Unit[]): void {
    const result = trackEnemyWaveAlert({
      waveUnits: units,
      waves: this.trackedEnemyWaves,
      nextWaveId: this.nextEnemyWaveId,
      addMinimapPing: (x, y, color, label) => this.addMinimapPing(x, y, color, label)
    });
    this.trackedEnemyWaves = result.waves;
    this.nextEnemyWaveId = result.nextWaveId;
  }

  private updateTrackedEnemyWaves(): void {
    this.trackedEnemyWaves = updateTrackedEnemyWaves({
      waves: this.trackedEnemyWaves,
      units: this.units,
      runtime: this.runtime,
      hero: this.hero,
      showMessage: (message, x, y, color) => this.showMessage(message, x, y, color)
    });
  }

  private updateTutorialHint(): void {
    this.tutorialHint = firstBattleTutorialHint({
      isFirstBattle: this.isFirstBattle(),
      selected: this.selectionSystem.getSelected(),
      commandHall: this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player"),
      crownShrine: this.captureSites.find((site) => site.definition.id === "crown_shrine"),
      hero: this.hero,
      buildings: this.buildings,
      elapsedSeconds: this.runtime.elapsedSeconds,
      unitsTrained: this.runtime.stats.unitsTrained,
      enemyWavesSurvived: this.runtime.stats.enemyWavesSurvived
    });
  }

  private warnIfCommandHallUnderAttack(target: BaseEntity): void {
    this.commandHallWarningCooldown = warnCommandHallUnderAttack({
      target,
      cooldown: this.commandHallWarningCooldown,
      playerBaseBuildingId: this.activeMap.scenario.objectives.playerBaseBuildingId,
      addMinimapPing: (x, y, color, label) => this.addMinimapPing(x, y, color, label),
      showMessage: (message, x, y, color) => this.showMessage(message, x, y, color)
    });
  }

  private resourceColor(resource: ResourceKey): string {
    if (this.settings.colorblindMinimapPalette) {
      const colorblindResourceColors: Partial<Record<ResourceKey, string>> = {
        crowns: "#f0e442",
        stone: "#999999",
        iron: "#56b4e9",
        aether: "#cc79a7"
      };
      return colorblindResourceColors[resource] ?? "#f5efc2";
    }
    const color = RESOURCE_DEFINITIONS.find((entry) => entry.id === resource)?.color ?? 0xf5efc2;
    return `#${color.toString(16).padStart(6, "0")}`;
  }

  private showMessage(message: string, x?: number, y?: number, color = "#f5efc2"): void {
    this.statusMessage = message;
    this.statusTimer = 2.5;
    if (x !== undefined && y !== undefined) {
      FloatingText.show(this, message, x, y, color);
    }
  }

  private cleanup(): void {
    this.inputSystem?.destroy();
    this.uiSystem?.destroy();
    this.buildingSystem?.cancelPlacement();
    this.rallyMarkers.forEach((marker) => marker.destroy(true));
    this.rallyMarkers.clear();
    this.fogOverlay?.destroy();
    this.fogOverlay = undefined;
  }

  private resolveLaunchOrFallback(): ResolvedBattleLaunch {
    const resolved = resolveBattleLaunchRequest(this.launchRequest);
    if (resolved.ok) {
      return resolved.launch;
    }

    console.warn("Falling back to default skirmish launch request.", resolved.errors);
    const fallbackMap = MAPS.find((map) => map.id === DEFAULT_MAP_ID) ?? MAPS[0];
    this.launchRequest = createSkirmishBattleLaunchRequest(this.heroSave, {
      mapId: fallbackMap.id,
      sourceId: "battle_scene_fallback"
    });
    const fallback = resolveBattleLaunchRequest(this.launchRequest);
    if (!fallback.ok) {
      throw new Error(`Fallback battle launch failed: ${fallback.errors.join(" ")}`);
    }
    return fallback.launch;
  }
}
