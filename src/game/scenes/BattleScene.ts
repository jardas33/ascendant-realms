import Phaser from "phaser";
import type {
  BattleSecondaryObjectiveType,
  Position,
  ResourceBag,
  ResourceKey,
  Team,
  UpgradeDefinition,
  UnitVeterancyRankUpEvent
} from "../core/GameTypes";
import { formatTime } from "../core/MathUtils";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { DEFAULT_SETTINGS, applySettingsToDocument, normalizeSettingsData } from "../core/Settings";
import {
  AI_PERSONALITY_BY_ID,
  CAMPAIGN_MODIFIER_BY_ID,
  FACTION_BY_ID,
  UPGRADE_BY_ID
} from "../data/contentIndex";
import { getBattleDifficulty } from "../data/battlePacing";
import { DEFAULT_MAP_ID, MAPS } from "../data/maps";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { getStrongholdBattleEffects, strongholdUpgradeForModifier } from "../data/strongholdUpgrades";
import {
  UNIT_VETERANCY_XP_RULES,
  createUnitVeterancyBattleSummary,
  createUnitVeterancyRankUpEvent,
  getUnitVeterancyRank,
  getUnitVeterancyXpForDamage,
  getUnitVeterancyXpForKill,
  markUnitVeterancySurvived,
  recordUnitVeterancyDamage,
  recordUnitVeterancyKill
} from "../data/unitVeterancy";
import { BattleRuntime, createBattleRuntime } from "../battle/BattleRuntime";
import { drawBattleMap } from "../battle/BattleSceneMapRenderer";
import { endBattleAndOpenResults } from "../battle/BattleSceneResults";
import { createBattleMinimapSnapshot } from "../battle/BattleSceneSnapshots";
import { completeBattleSecondaryObjective } from "../battle/BattleSceneObjectives";
import { applySecondaryObjectiveBattleEffect } from "../battle/SecondaryObjectiveEffects";
import { spawnBattleScenario, type NeutralCampLabel } from "../battle/BattleSceneSpawner";
import { createBattleFogOfWar, createBattleSceneSystems, type BattleSceneSystems } from "../battle/BattleSceneSystems";
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
import { FloatingText } from "../ui/FloatingText";
import type { MinimapPing, MinimapSnapshot } from "../ui/MinimapView";
import { AudioManager } from "../systems/AudioManager";
import { CollisionSystem } from "../systems/CollisionSystem";
import { isEntityVisibleToPlayer, type FogOfWarSystem, type VisionSource } from "../systems/FogOfWarSystem";
import { canUseRallyPoint, setRallyPointForBuildings } from "../systems/RallyPointSystem";
import { tickStatusEffects } from "../systems/StatusEffectSystem";
import { applyUpgradeToUnit } from "../systems/UpgradeEffects";
import type { TechState } from "../systems/PrerequisiteSystem";

interface BattleSceneData {
  launchRequest?: BattleLaunchRequest;
  heroSave?: HeroSaveData;
}

interface AscendantBattleTestHooks {
  grantSelectedUnitVeterancyXp?: (amount?: number) => {
    unitInstanceId: string;
    unitName: string;
    rank: string;
    xp: number;
    maxHp: number;
    damage: number;
    armor: number;
  } | null;
  forceBattleVictory?: () => boolean;
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

  private movementSystem!: BattleSceneSystems["movementSystem"];
  private combatSystem!: BattleSceneSystems["combatSystem"];
  private resourceSystem!: BattleSceneSystems["resourceSystem"];
  private buildingSystem!: BattleSceneSystems["buildingSystem"];
  private trainingSystem!: BattleSceneSystems["trainingSystem"];
  private upgradeSystem!: BattleSceneSystems["upgradeSystem"];
  private selectionSystem!: BattleSceneSystems["selectionSystem"];
  private abilitySystem!: BattleSceneSystems["abilitySystem"];
  private cameraSystem!: BattleSceneSystems["cameraSystem"];
  private inputSystem!: BattleSceneSystems["inputSystem"];
  private uiSystem!: BattleSceneSystems["uiSystem"];
  private xpSystem!: BattleSceneSystems["xpSystem"];
  private aiSystem!: BattleSceneSystems["aiSystem"];

  private statusMessage = "Capture resource sites to grow your army.";
  private statusTimer = 4;
  private tutorialHint = "Select your hero, then right-click the Crown Shrine to begin.";
  private commandHallWarningCooldown = 0;
  private minimapPings: MinimapPing[] = [];
  private nextMinimapPingId = 1;
  private rallyMarkers = new Map<string, Phaser.GameObjects.Container>();
  private fogOfWar?: FogOfWarSystem;
  private fogOverlay?: Phaser.GameObjects.Graphics;
  private neutralCampLabels: NeutralCampLabel[] = [];
  private fogUpdateTimer = 0;
  private fogDebugDisabled = false;
  private settings: SaveSettingsData = DEFAULT_SETTINGS;
  private lastSelectionAudioKey = "";
  private resourceSiteWarningCooldowns = new Map<string, number>();
  private trackedEnemyWaves: TrackedEnemyWave[] = [];
  private nextEnemyWaveId = 1;
  private unitVeterancyRankUps: UnitVeterancyRankUpEvent[] = [];
  private lostRetinueUnitIds = new Set<string>();
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
    this.selectionSystem.setSelection(this.initialPlayerSelection());
    this.installTestHooks();
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
    this.refreshBattleHud(deltaSeconds);
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
    this.fogOfWar = createBattleFogOfWar(this.activeMap);
    this.fogUpdateTimer = 0;
    this.fogDebugDisabled = false;
    this.lastSelectionAudioKey = "";
    this.runtime = createBattleRuntime({ launch: this.launch });
    this.resources = this.runtime.resources;
    this.units = [];
    this.buildings = [];
    this.projectiles = [];
    this.captureSites = [];
    this.neutralCampLabels = [];
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
    this.unitVeterancyRankUps = [];
    this.lostRetinueUnitIds = new Set<string>();
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
    this.neutralCampLabels = spawned.neutralCampLabels;
  }

  private createSystems(): void {
    // BattleScene keeps ownership of lifecycle state; BattleSceneSystems keeps constructor wiring in one place.
    const systems = createBattleSceneSystems({
      scene: this,
      activeMap: this.activeMap,
      launch: this.launch,
      runtime: this.runtime,
      resources: this.resources,
      hero: this.hero,
      getUnits: () => this.units,
      getBuildings: () => this.buildings,
      getProjectiles: () => this.projectiles,
      getCaptureSites: () => this.captureSites,
      addUnit: (unit) => this.addUnit(unit),
      addBuilding: (building) => this.addBuilding(building),
      addProjectile: (projectile) => this.projectiles.push(projectile),
      showMessage: (message, x, y, color) => this.showMessage(message, x, y, color),
      addMinimapPing: (x, y, color, label) => this.addMinimapPing(x, y, color, label),
      warnIfCommandHallUnderAttack: (target) => this.warnIfCommandHallUnderAttack(target),
      handleUnitDamage: (source, target, amount) => this.handleUnitDamage(source, target, amount),
      handleKill: (killer, target) => this.handleKill(killer, target),
      completeSecondaryObjective: (type, targetId, point) => this.completeSecondaryObjective(type, targetId, point),
      selectedRallyBuildings: () => this.selectedRallyBuildings(),
      setRallyPoint: (point, buildings) => this.setRallyPoint(point, buildings),
      findWorldEntityAt: (point) => this.findWorldEntityAt(point),
      centerCameraFromMinimap: (normalizedX, normalizedY) => this.centerCameraFromMinimap(normalizedX, normalizedY),
      castAbilitySlot: (slot) => this.castAbilitySlot(slot),
      toggleFogDebug: () => this.toggleFogDebug(),
      getTechState: (team) => this.getTechState(team),
      isUpgradeResearched: (team, upgradeId) => this.isUpgradeResearched(team, upgradeId),
      markUpgradeResearched: (team, upgradeId) => this.markUpgradeResearched(team, upgradeId),
      applyUpgradeEffects: (team, upgrade) => this.applyUpgradeEffects(team, upgrade),
      isFirstBattle: () => this.isFirstBattle(),
      hasPlayerProductionBuilding: () => this.hasPlayerProductionBuilding(),
      findPlayerBaseBuilding: () => this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player"),
      trackEnemyWave: (units) => this.trackEnemyWave(units),
      showBattleStartSummary: () => this.showBattleStartSummary(),
      openMainMenu: () => this.scene.start(SCENE_KEYS.mainMenu)
    });

    this.movementSystem = systems.movementSystem;
    this.combatSystem = systems.combatSystem;
    this.resourceSystem = systems.resourceSystem;
    this.buildingSystem = systems.buildingSystem;
    this.trainingSystem = systems.trainingSystem;
    this.upgradeSystem = systems.upgradeSystem;
    this.selectionSystem = systems.selectionSystem;
    this.abilitySystem = systems.abilitySystem;
    this.cameraSystem = systems.cameraSystem;
    this.inputSystem = systems.inputSystem;
    this.uiSystem = systems.uiSystem;
    this.xpSystem = systems.xpSystem;
    this.aiSystem = systems.aiSystem;
  }

  private showBattleStartSummary(): void {
    const faction = FACTION_BY_ID[this.launch.request.enemyProfileId ?? "ashen_covenant"];
    const personality = AI_PERSONALITY_BY_ID[this.launch.request.aiPersonalityId ?? "balanced_warlord"];
    const difficulty = getBattleDifficulty(this.launch.request.difficulty);
    const names = this.launch.request.modifiers
      .map((modifier) => CAMPAIGN_MODIFIER_BY_ID[modifier.id]?.name ?? strongholdUpgradeForModifier(modifier.id)?.name)
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

    this.fogUpdateTimer = 0.12;
    fog.update(this.createVisionSources());
    this.renderFogOverlay();
    this.applyFogEntityVisibility(true);
  }

  private createVisionSources(): VisionSource[] {
    const buildingVisionBonus = getStrongholdBattleEffects(this.launch.request.modifiers).buildingVisionBonus;
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
        radius:
          (building.isCompleted() ? building.definition.visionRadius : building.definition.visionRadius * 0.65) +
          buildingVisionBonus
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
      this.neutralCampLabels.forEach((entry) => entry.label.setVisible(true));
      return;
    }

    this.units.forEach((unit) => unit.view?.setVisible(isEntityVisibleToPlayer(unit, fog, true)));
    this.buildings.forEach((building) => building.view?.setVisible(isEntityVisibleToPlayer(building, fog, true)));
    this.projectiles.forEach((projectile) => projectile.view?.setVisible(projectile.team === "player" || fog.isVisible(projectile.position)));
    this.captureSites.forEach((site) =>
      site.view?.setVisible(site.owner === "player" || fog.isEntityVisible(site.position, site.definition.radius))
    );
    this.neutralCampLabels.forEach((entry) => entry.label.setVisible(fog.isEntityVisible(entry.position, 48)));
  }

  private isFogActive(): boolean {
    return this.isFogRequested() && !this.fogDebugDisabled;
  }

  private isFogRequested(): boolean {
    const difficultyFog = getBattleDifficulty(this.launch.request.difficulty).fogOfWarEnabled;
    return this.settings.fogEnabledOverride === "enabled"
      ? true
      : this.settings.fogEnabledOverride === "disabled"
        ? false
        : difficultyFog;
  }

  private isPointVisibleToPlayer(point: Position): boolean {
    return !this.isFogActive() || !this.fogOfWar || this.fogOfWar.isVisible(point);
  }

  private isPointExploredByPlayer(point: Position): boolean {
    return !this.isFogActive() || !this.fogOfWar || this.fogOfWar.isExplored(point);
  }

  private toggleFogDebug(): void {
    if (!this.isFogRequested()) {
      this.showMessage("Fog is disabled for this battle.");
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

  private createObjectiveSnapshot() {
    const objectives = this.activeMap.scenario.objectives.secondaryObjectives ?? [];
    const completed = new Set(this.runtime.stats.completedObjectiveIds);
    return objectives.map((objective) => ({
      id: objective.id,
      name: objective.name,
      description: objective.description,
      completed: completed.has(objective.id)
    }));
  }

  private selectedUnitOrBuildings(): Array<Unit | Building> {
    return this.selectionSystem
      .getSelected()
      .filter((entity): entity is Unit | Building => entity instanceof Unit || entity instanceof Building);
  }

  private initialPlayerSelection(): Unit[] {
    const playerUnits = this.units.filter((unit) => unit.alive && unit.team === "player");
    return playerUnits.length > 0 ? playerUnits : [this.hero];
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
    if (target.team !== "player" && killer instanceof Unit && this.isUnitVeterancyEligible(killer)) {
      killer.veterancy = recordUnitVeterancyKill(killer.veterancy);
      const xpValue = target instanceof Unit || target instanceof Building ? target.definition.xpValue : 0;
      this.awardUnitVeterancyXp(killer, getUnitVeterancyXpForKill(xpValue));
    }
    this.xpSystem.awardForKill(killer, target);
  }

  private handleUnitDamage(source: Unit, target: BaseEntity, amount: number): void {
    if (!this.isUnitVeterancyEligible(source) || target.team === "player") {
      return;
    }
    source.veterancy = recordUnitVeterancyDamage(source.veterancy, amount);
    this.awardUnitVeterancyXp(source, getUnitVeterancyXpForDamage(amount));
  }

  private isUnitVeterancyEligible(unit: Unit): boolean {
    return unit.alive && unit.team === "player" && unit.kind === "unit";
  }

  private awardUnitVeterancyXp(unit: Unit, amount: number): void {
    if (!this.isUnitVeterancyEligible(unit) || amount <= 0) {
      return;
    }
    const result = unit.addVeterancyXp(amount);
    if (result.rankedUp) {
      const event = createUnitVeterancyRankUpEvent(
        {
          state: unit.veterancy,
          unitName: unit.definition.name
        },
        result.previousRank.id,
        result.currentRank.id
      );
      this.unitVeterancyRankUps.push(event);
      this.showMessage(
        `${unit.definition.name} reached ${result.currentRank.name}`,
        unit.position.x,
        unit.position.y - 48,
        "#f6e27d"
      );
    }
    this.refreshBattleHud(0);
  }

  private completeSecondaryObjective(type: BattleSecondaryObjectiveType, targetId: string, point?: Position): void {
    const objective = completeBattleSecondaryObjective({
      activeMap: this.activeMap,
      runtime: this.runtime,
      type,
      targetId,
      point,
      showMessage: (message, x, y, color) => this.showMessage(message, x, y, color)
    });
    if (!objective) {
      return;
    }

    const effect = applySecondaryObjectiveBattleEffect({
      mapId: this.activeMap.id,
      objectiveId: objective.id,
      buildings: this.buildings
    });
    if (effect) {
      this.addMinimapPing(effect.point.x, effect.point.y, "#f6e27d", effect.message);
      this.showMessage(effect.message, effect.point.x, effect.point.y - 92, "#f6e27d");
    }

    this.refreshBattleHud(0);
  }

  private refreshBattleHud(deltaSeconds: number): void {
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
      minimap: this.createMinimapSnapshot(),
      objectives: this.createObjectiveSnapshot()
    });
  }

  private cleanupDeadEntities(): void {
    this.cleanupRallyMarkers();
    this.units.forEach((unit) => {
      if (!unit.alive && unit.retinueUnitId) {
        this.lostRetinueUnitIds.add(unit.retinueUnitId);
      }
    });
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
    this.finalizeUnitVeterancy(outcome);
    endBattleAndOpenResults({
      scene: this,
      runtime: this.runtime,
      hero: this.hero,
      launch: this.launch,
      outcome
    });
  }

  private finalizeUnitVeterancy(outcome: "victory" | "defeat"): void {
    const survivingUnits = this.units.filter((unit) => this.isUnitVeterancyEligible(unit));
    survivingUnits.forEach((unit) => {
      unit.veterancy = markUnitVeterancySurvived(unit.veterancy);
      if (outcome === "victory") {
        this.awardUnitVeterancyXp(unit, UNIT_VETERANCY_XP_RULES.survivalXp);
      }
    });
    this.runtime.recordVeterancySummary(
      createUnitVeterancyBattleSummary(
        survivingUnits.map((unit) => ({
          state: unit.veterancy,
          unitName: unit.definition.name
        })),
        this.unitVeterancyRankUps
      )
    );
    this.runtime.recordRetinueLosses([...this.lostRetinueUnitIds]);
  }

  private castAbilitySlot(slot: number): void {
    const abilityId = this.hero.unlockedAbilities[slot];
    if (!abilityId) {
      this.showMessage("No ability in that slot");
      return;
    }
    if (this.abilitySystem.castAbility(this.hero, abilityId, this.selectionSystem.getSelected())) {
      AudioManager.play("ability_cast");
    }
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
    if (this.buildingSystem?.pendingBuildingId) {
      this.tutorialHint = "";
      return;
    }

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

  private installTestHooks(): void {
    const target = globalThis as typeof globalThis & { __ASCENDANT_TEST_HOOKS__?: AscendantBattleTestHooks };
    target.__ASCENDANT_TEST_HOOKS__ = {
      ...(target.__ASCENDANT_TEST_HOOKS__ ?? {}),
      grantSelectedUnitVeterancyXp: (amount = 120) => {
        const selectedUnit =
          this.selectionSystem
            .getSelected()
            .find((entity): entity is Unit => entity instanceof Unit && this.isUnitVeterancyEligible(entity)) ??
          this.units.find((unit) => this.isUnitVeterancyEligible(unit));
        if (!selectedUnit) {
          return null;
        }

        this.selectionSystem.setSelection([selectedUnit]);
        this.awardUnitVeterancyXp(selectedUnit, amount);
        this.refreshBattleHud(0);
        const rank = getUnitVeterancyRank(selectedUnit.veterancy.rank);
        return {
          unitInstanceId: selectedUnit.unitInstanceId,
          unitName: selectedUnit.definition.name,
          rank: rank.name,
          xp: selectedUnit.veterancy.xp,
          maxHp: selectedUnit.maxHp,
          damage: selectedUnit.damage,
          armor: selectedUnit.armor
        };
      },
      forceBattleVictory: () => {
        if (this.runtime.ended) {
          return false;
        }
        this.endBattle("victory");
        return true;
      }
    };
  }

  private removeTestHooks(): void {
    const target = globalThis as typeof globalThis & { __ASCENDANT_TEST_HOOKS__?: AscendantBattleTestHooks };
    if (!target.__ASCENDANT_TEST_HOOKS__) {
      return;
    }
    delete target.__ASCENDANT_TEST_HOOKS__.grantSelectedUnitVeterancyXp;
    delete target.__ASCENDANT_TEST_HOOKS__.forceBattleVictory;
  }

  private cleanup(): void {
    this.removeTestHooks();
    this.inputSystem?.destroy();
    this.uiSystem?.destroy();
    this.buildingSystem?.cancelPlacement();
    this.rallyMarkers.forEach((marker) => marker.destroy(true));
    this.rallyMarkers.clear();
    this.neutralCampLabels.forEach((entry) => entry.label.destroy());
    this.neutralCampLabels = [];
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
