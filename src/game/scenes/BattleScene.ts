import Phaser from "phaser";
import type {
  BattleSecondaryObjectiveType,
  FactionModifierDefinition,
  Position,
  ResourceBag,
  ResourceKey,
  Team,
  UpgradeDefinition
} from "../core/GameTypes";
import { completeCampaignNodeWithRewards, createStartedCampaignSave } from "../core/CampaignRules";
import { formatTime } from "../core/MathUtils";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import {
  BUILDING_BY_ID,
  AI_PERSONALITY_BY_ID,
  CAMPAIGN_MODIFIER_BY_ID,
  FACTION_BY_ID,
  UPGRADE_BY_ID,
  requireBuilding,
  requireCampaignNode,
  requireHeroClass,
  requireOrigin,
  requireUnit
} from "../data/contentIndex";
import { getBattleDifficulty } from "../data/battlePacing";
import { DEFAULT_MAP_ID, MAPS } from "../data/maps";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { EnemyAIController } from "../ai/EnemyAIController";
import { BattleRuntime, createBattleRuntime } from "../battle/BattleRuntime";
import {
  cloneBattleLaunchRequestWithHero,
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
import { HUD } from "../ui/HUD";
import { FloatingText } from "../ui/FloatingText";
import type { MinimapPing, MinimapSnapshot } from "../ui/MinimapView";
import { AbilitySystem } from "../systems/AbilitySystem";
import { AISystem } from "../systems/AISystem";
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

interface TrackedEnemyWave {
  id: number;
  unitIds: string[];
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
    this.uiSystem.update(deltaSeconds, {
      resources: this.resources.player,
      hero: this.hero,
      selected: this.selectedUnitOrBuildings(),
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
    this.cameras.main.setBounds(0, 0, this.activeMap.width, this.activeMap.height);
    const graphics = this.add.graphics().setDepth(-20);
    this.drawBaseTerrain(graphics);
    this.drawBattleRoads(graphics);

    this.activeMap.terrainZones.forEach((zone) => {
      if (zone.type === "buildable") {
        this.drawBuildableGround(graphics, zone);
      }
      if (zone.type === "blocked") {
        this.drawBlockedGround(graphics, zone);
      }
      if (zone.type === "water") {
        this.drawWaterGround(graphics, zone);
      }
    });

    this.drawCaptureSiteGrounds(graphics);
    this.drawTerrainDetails(graphics);
    this.drawMapBorder(graphics);
  }

  private drawBaseTerrain(graphics: Phaser.GameObjects.Graphics): void {
    graphics.fillStyle(0x17261b, 1);
    graphics.fillRect(0, 0, this.activeMap.width, this.activeMap.height);

    graphics.fillStyle(0x213923, 0.6);
    graphics.fillEllipse(570, 780, 980, 720);
    graphics.fillStyle(0x243223, 0.54);
    graphics.fillEllipse(1650, 770, 1220, 760);
    graphics.fillStyle(0x1a2e27, 0.46);
    graphics.fillEllipse(1160, 230, 620, 300);
    graphics.fillStyle(0x263827, 0.42);
    graphics.fillEllipse(1250, 1370, 840, 280);

    for (let index = 0; index < 260; index += 1) {
      const x = this.noise01(index + 11) * this.activeMap.width;
      const y = this.noise01(index + 97) * this.activeMap.height;
      const width = 10 + this.noise01(index + 211) * 34;
      const height = 4 + this.noise01(index + 307) * 13;
      const colorRoll = this.noise01(index + 409);
      const color = colorRoll > 0.72 ? 0x385036 : colorRoll > 0.38 ? 0x203922 : 0x293f2c;
      graphics.fillStyle(color, 0.13 + this.noise01(index + 503) * 0.17);
      graphics.fillEllipse(x, y, width, height);
    }
  }

  private drawBattleRoads(graphics: Phaser.GameObjects.Graphics): void {
    this.activeMap.visualPaths.forEach((path) => this.drawPath(graphics, path.points, path.width));
  }

  private drawBuildableGround(
    graphics: Phaser.GameObjects.Graphics,
    zone: { x: number; y: number; width: number; height: number }
  ): void {
    graphics.fillStyle(0x2c3f2b, 0.55);
    graphics.fillRect(zone.x, zone.y, zone.width, zone.height);
    graphics.fillStyle(0x6b5837, 0.16);
    graphics.fillRect(zone.x + 18, zone.y + 18, zone.width - 36, zone.height - 36);
    graphics.lineStyle(3, 0xd6c37d, 0.24);
    graphics.strokeRect(zone.x + 16, zone.y + 16, zone.width - 32, zone.height - 32);

    graphics.lineStyle(1, 0xf0d978, 0.08);
    for (let x = zone.x + 74; x < zone.x + zone.width - 40; x += 92) {
      this.strokePolyline(graphics, [
        { x, y: zone.y + 34 },
        { x: x - 18, y: zone.y + zone.height - 34 }
      ]);
    }
    for (let y = zone.y + 68; y < zone.y + zone.height - 40; y += 86) {
      this.strokePolyline(graphics, [
        { x: zone.x + 34, y },
        { x: zone.x + zone.width - 34, y: y + 12 }
      ]);
    }

    graphics.fillStyle(0x0f1710, 0.55);
    graphics.fillCircle(zone.x + 26, zone.y + 26, 6);
    graphics.fillCircle(zone.x + zone.width - 26, zone.y + 26, 6);
    graphics.fillCircle(zone.x + 26, zone.y + zone.height - 26, 6);
    graphics.fillCircle(zone.x + zone.width - 26, zone.y + zone.height - 26, 6);
  }

  private drawBlockedGround(
    graphics: Phaser.GameObjects.Graphics,
    zone: { x: number; y: number; width: number; height: number }
  ): void {
    const centerX = zone.x + zone.width / 2;
    const centerY = zone.y + zone.height / 2;
    graphics.fillStyle(0x211f1b, 0.45);
    graphics.fillEllipse(centerX + 8, centerY + 12, zone.width * 1.2, zone.height * 1.08);
    graphics.fillStyle(0x514f43, 0.94);
    graphics.fillEllipse(centerX, centerY, zone.width * 1.03, zone.height * 0.86);
    graphics.fillStyle(0x77705c, 0.72);
    graphics.fillEllipse(centerX - zone.width * 0.22, centerY - zone.height * 0.1, zone.width * 0.32, zone.height * 0.46);
    graphics.fillEllipse(centerX + zone.width * 0.18, centerY + zone.height * 0.04, zone.width * 0.36, zone.height * 0.42);
    graphics.lineStyle(4, 0x191712, 0.42);
    graphics.strokeEllipse(centerX, centerY, zone.width * 1.03, zone.height * 0.86);
  }

  private drawWaterGround(
    graphics: Phaser.GameObjects.Graphics,
    zone: { x: number; y: number; width: number; height: number }
  ): void {
    const centerX = zone.x + zone.width / 2;
    const centerY = zone.y + zone.height / 2;
    graphics.fillStyle(0x10241f, 0.42);
    graphics.fillEllipse(centerX + 8, centerY + 10, zone.width * 1.16, zone.height * 1.22);
    graphics.fillStyle(0x1d5564, 0.92);
    graphics.fillEllipse(centerX, centerY, zone.width * 1.06, zone.height * 1.1);
    graphics.fillStyle(0x276c78, 0.5);
    graphics.fillEllipse(centerX - zone.width * 0.12, centerY - zone.height * 0.08, zone.width * 0.58, zone.height * 0.38);
    graphics.lineStyle(8, 0xa2b077, 0.18);
    graphics.strokeEllipse(centerX, centerY, zone.width * 1.1, zone.height * 1.15);
    graphics.lineStyle(2, 0xbfe9df, 0.22);
    for (let index = 0; index < 4; index += 1) {
      const y = centerY - zone.height * 0.23 + index * (zone.height * 0.15);
      this.strokePolyline(graphics, [
        { x: centerX - zone.width * 0.3, y },
        { x: centerX - zone.width * 0.08, y: y + 8 },
        { x: centerX + zone.width * 0.22, y: y - 2 }
      ]);
    }
  }

  private drawCaptureSiteGrounds(graphics: Phaser.GameObjects.Graphics): void {
    this.activeMap.captureSites.forEach((site, index) => {
      const accent = [0xd8c76f, 0x9fa079, 0xb08059, 0x74d3f2][index] ?? 0xd8c76f;
      graphics.fillStyle(0x0e1510, 0.28);
      graphics.fillCircle(site.x, site.y + 6, site.radius + 30);
      graphics.fillStyle(accent, 0.08);
      graphics.fillCircle(site.x, site.y, site.radius + 18);
      graphics.lineStyle(3, accent, 0.26);
      graphics.strokeCircle(site.x, site.y, site.radius + 16);
      graphics.lineStyle(2, 0xf0d978, 0.11);
      graphics.strokeCircle(site.x, site.y, site.radius + 4);
    });
  }

  private drawTerrainDetails(graphics: Phaser.GameObjects.Graphics): void {
    for (let index = 0; index < 110; index += 1) {
      const x = this.noise01(index + 701) * this.activeMap.width;
      const y = this.noise01(index + 809) * this.activeMap.height;
      const height = 12 + this.noise01(index + 877) * 18;
      graphics.lineStyle(2, 0x54724a, 0.25);
      this.strokePolyline(graphics, [
        { x, y },
        { x: x + 4, y: y - height }
      ]);
      this.strokePolyline(graphics, [
        { x: x + 5, y: y + 1 },
        { x: x + 11, y: y - height * 0.72 }
      ]);
    }

    for (let index = 0; index < 72; index += 1) {
      const x = this.noise01(index + 1013) * this.activeMap.width;
      const y = this.noise01(index + 1117) * this.activeMap.height;
      const radius = 2 + this.noise01(index + 1223) * 5;
      graphics.fillStyle(0x8b8265, 0.24);
      graphics.fillCircle(x, y, radius);
    }
  }

  private drawMapBorder(graphics: Phaser.GameObjects.Graphics): void {
    graphics.lineStyle(28, 0x070a08, 0.34);
    graphics.strokeRect(0, 0, this.activeMap.width, this.activeMap.height);
    graphics.lineStyle(6, 0x101712, 1);
    graphics.strokeRect(0, 0, this.activeMap.width, this.activeMap.height);
  }

  private drawPath(graphics: Phaser.GameObjects.Graphics, points: Position[], width: number): void {
    graphics.lineStyle(width + 18, 0x10140f, 0.34);
    this.strokePolyline(graphics, points);
    graphics.lineStyle(width + 8, 0x5b462d, 0.38);
    this.strokePolyline(graphics, points);
    graphics.lineStyle(width, 0x8a6a3f, 0.42);
    this.strokePolyline(graphics, points);
    graphics.lineStyle(2, 0xd6bd76, 0.12);
    this.strokePolyline(graphics, points);
  }

  private strokePolyline(graphics: Phaser.GameObjects.Graphics, points: Position[]): void {
    if (points.length === 0) {
      return;
    }
    graphics.beginPath();
    graphics.moveTo(points[0].x, points[0].y);
    points.slice(1).forEach((point) => graphics.lineTo(point.x, point.y));
    graphics.strokePath();
  }

  private noise01(seed: number): number {
    const value = Math.sin(seed * 12.9898) * 43758.5453;
    return value - Math.floor(value);
  }

  private spawnScenario(): void {
    const scenario = this.activeMap.scenario;
    scenario.buildingSpawns.forEach((spawn) => {
      this.addBuilding(new Building(this, requireBuilding(spawn.buildingId), spawn.team, spawn.x, spawn.y));
    });

    const heroClass = requireHeroClass(this.heroSave.classId);
    const origin = requireOrigin(this.heroSave.originId);
    this.hero = new Hero(this, this.heroSave, heroClass, origin, scenario.heroSpawn.x, scenario.heroSpawn.y);
    this.addUnit(this.hero);
    this.applyHeroLaunchModifiers();

    const difficulty = getBattleDifficulty(this.launch.request.difficulty);
    const enemyStartingSpawns = new Set(difficulty.enemyStartingUnitSpawnIds);
    scenario.unitSpawns.forEach((spawn) => {
      if (spawn.team === "enemy" && !enemyStartingSpawns.has(spawn.id)) {
        return;
      }
      this.spawnUnit(spawn.unitId, spawn.team, spawn.x, spawn.y);
    });
    this.spawnLaunchModifierUnits();

    this.activeMap.captureSites.forEach((siteDefinition) => {
      this.captureSites.push(new CaptureSite(this, siteDefinition));
    });

    this.activeMap.neutralCamps.forEach((camp) => {
      camp.unitIds.forEach((unitId, index) => {
        const angle = index * 2.1;
        this.spawnUnit(unitId, "neutral", camp.x + Math.cos(angle) * 34, camp.y + Math.sin(angle) * 34);
      });
      this.add
        .text(camp.x, camp.y - 58, camp.name, {
          fontFamily: "Verdana, Arial, sans-serif",
          fontSize: "12px",
          color: "#d7cf9f",
          stroke: "#101511",
          strokeThickness: 4
        })
        .setOrigin(0.5)
        .setDepth(1);
    });
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
        }
      },
      onBuilt: (building) => {
        if (building.team === "player") {
          this.runtime.recordBuildingBuilt(building.definition.id);
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
        const definition = BUILDING_BY_ID[buildingId];
        this.showMessage(`Placing ${definition?.name ?? "building"}`);
      },
      onTrain: (unitId, sourceBuildingId) => {
        const building = this.buildings.find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          this.trainingSystem.queueTraining(building, unitId, this.resources.player);
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
          this.upgradeSystem.queueUpgrade(building, upgradeId, this.resources.player);
        }
      },
      onCancelUpgrade: (sourceBuildingId, queueIndex) => {
        const building = this.buildings.find((entry) => entry.id === sourceBuildingId && entry.alive && entry.team === "player");
        if (building) {
          this.upgradeSystem.cancelUpgrade(building, queueIndex, this.resources.player);
        }
      },
      onAbility: (abilityId) => this.abilitySystem.castAbility(this.hero, abilityId, this.selectionSystem.getSelected()),
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
      cancelPlacement: () => this.buildingSystem.cancelPlacement(),
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

  private spawnUnit(unitId: string, team: "player" | "enemy" | "neutral", x: number, y: number): Unit {
    const unit = new Unit(this, requireUnit(unitId), team, x, y);
    this.addUnit(unit);
    return unit;
  }

  private applyHeroLaunchModifiers(): void {
    const manaMultiplier = this.launch.request.modifiers.reduce((multiplier, modifier) => {
      const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
      return Math.max(multiplier, definition?.effects.heroManaMultiplier ?? multiplier);
    }, 1);
    if (manaMultiplier <= 1) {
      return;
    }
    this.hero.maxMana = Math.round(this.hero.maxMana * manaMultiplier);
    this.hero.mana = this.hero.maxMana;
  }

  private spawnLaunchModifierUnits(): void {
    this.launch.request.modifiers.forEach((modifier, modifierIndex) => {
      const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id];
      if (!definition) {
        return;
      }
      definition.effects.extraPlayerUnitIds?.forEach((unitId, index) => {
        this.spawnUnit(unitId, "player", this.activeMap.playerStart.x + 92 + index * 34, this.activeMap.playerStart.y + 72 + modifierIndex * 24);
      });
      definition.effects.extraEnemyUnitIds?.forEach((unitId, index) => {
        this.spawnUnit(unitId, "enemy", this.activeMap.enemyStart.x - 92 - index * 34, this.activeMap.enemyStart.y + 72 + modifierIndex * 24);
      });
    });
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
    return getBattleDifficulty(this.launch.request.difficulty).fogOfWarEnabled && !this.fogDebugDisabled;
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
    const camera = this.cameras.main;
    const cameraWidth = Math.min(this.activeMap.width, camera.width / camera.zoom);
    const cameraHeight = Math.min(this.activeMap.height, camera.height / camera.zoom);
    const fogEnabled = this.isFogActive();
    const markers: MinimapSnapshot["markers"] = [
      ...this.captureSites
        .filter((site) => this.isPointExploredByPlayer(site.position))
        .map((site) => ({
          id: site.id,
          kind: "capture-site" as const,
          team: site.owner,
          x: site.position.x,
          y: site.position.y,
          resource: site.definition.resource,
          resourceColor: this.resourceColor(site.definition.resource)
        })),
      ...this.activeMap.neutralCamps
        .filter((camp) =>
          this.isPointExploredByPlayer(camp) &&
          this.units.some(
            (unit) =>
              unit.alive &&
              unit.team === "neutral" &&
              Phaser.Math.Distance.Between(unit.position.x, unit.position.y, camp.x, camp.y) <= 150
          )
        )
        .map((camp) => ({
          id: camp.id,
          kind: "camp" as const,
          team: "neutral" as const,
          x: camp.x,
          y: camp.y,
          size: 2.5
        })),
      ...this.buildings
        .filter((building) => building.alive && isEntityVisibleToPlayer(building, this.fogOfWar!, fogEnabled))
        .map((building) => ({
          id: building.id,
          kind: "building" as const,
          team: building.team,
          x: building.position.x,
          y: building.position.y,
          size: Math.max(2.8, Math.min(5, Math.max(building.definition.size.width, building.definition.size.height) / 38))
        })),
      ...this.units
        .filter((unit) => unit.alive && isEntityVisibleToPlayer(unit, this.fogOfWar!, fogEnabled))
        .map((unit) => ({
          id: unit.id,
          kind: "unit" as const,
          team: unit.team,
          x: unit.position.x,
          y: unit.position.y,
          size: unit === this.hero ? 2.1 : 1.35
        })),
      ...this.selectedRallyBuildings()
        .filter((building) => building.rallyPoint)
        .map((building) => ({
          id: `rally-${building.id}`,
          kind: "rally" as const,
          team: "player" as const,
          x: building.rallyPoint?.x ?? building.position.x,
          y: building.rallyPoint?.y ?? building.position.y,
          size: 2.3
        }))
    ];

    return {
      mapWidth: this.activeMap.width,
      mapHeight: this.activeMap.height,
      markers,
      camera: {
        x: Phaser.Math.Clamp(camera.scrollX, 0, this.activeMap.width - cameraWidth),
        y: Phaser.Math.Clamp(camera.scrollY, 0, this.activeMap.height - cameraHeight),
        width: cameraWidth,
        height: cameraHeight
      },
      pings: this.minimapPings,
      fog: {
        enabled: fogEnabled,
        cells: fogEnabled ? this.fogOfWar?.cells() : undefined
      }
    };
  }

  private selectedUnitOrBuildings(): Array<Unit | Building> {
    return this.selectionSystem
      .getSelected()
      .filter((entity): entity is Unit | Building => entity instanceof Unit || entity instanceof Building);
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
    const objective = this.activeMap.scenario.objectives.secondaryObjectives?.find(
      (entry) => entry.type === type && entry.targetId === targetId
    );
    if (!objective || !this.runtime.recordSecondaryObjective(objective.id)) {
      return;
    }
    this.showMessage(`Objective complete: ${objective.name}`, point?.x, point ? point.y - 78 : undefined, "#f6e27d");
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
    const startingHeroSave = this.launch.request.heroSave;
    const completion = this.runtime.completeBattle({
      outcome,
      heroSave: this.hero.toSaveData()
    });
    if (!completion) {
      return;
    }
    if (completion.shouldSaveHero && this.launch.request.mode !== "campaign_node") {
      SaveSystem.saveHero(completion.heroSave);
    }

    if (outcome === "victory" && this.launch.request.mode === "campaign_node" && this.launch.request.campaignNodeId) {
      const node = requireCampaignNode(this.launch.request.campaignNodeId);
      const storedCampaign = SaveSystem.load()?.campaign ?? createStartedCampaignSave();
      const unlockedBefore = new Set(storedCampaign.unlockedNodeIds);
      const campaignCompletion = completeCampaignNodeWithRewards({
        campaign: storedCampaign,
        hero: completion.heroSave,
        node
      });
      const stats = {
        ...completion.stats,
        xpGained: completion.stats.xpGained + campaignCompletion.nodeReward.xp
      };
      SaveSystem.saveGame(campaignCompletion.hero, campaignCompletion.campaign);
      this.scene.start(SCENE_KEYS.results, {
        stats,
        heroSave: campaignCompletion.hero,
        startingHeroSave,
        rewardItemIds: completion.rewardItemIds,
        reward: completion.reward,
        rewardLevelUp: completion.rewardLevelUp,
        launchRequest: cloneBattleLaunchRequestWithHero(this.launch.request, campaignCompletion.hero),
        campaignResult: {
          completedNodeId: node.id,
          completedNodeName: node.name,
          unlockedNodeIds: campaignCompletion.campaign.unlockedNodeIds.filter((nodeId) => !unlockedBefore.has(nodeId) && nodeId !== node.id),
          unlockedNodeNames: campaignCompletion.campaign.unlockedNodeIds
            .filter((nodeId) => !unlockedBefore.has(nodeId) && nodeId !== node.id)
            .map((nodeId) => requireCampaignNode(nodeId).name),
          nodeReward: campaignCompletion.nodeReward,
          nodeLevelUp: campaignCompletion.nodeLevelUp,
          campaignResources: campaignCompletion.campaign.resources
        }
      });
      return;
    }

    this.scene.start(SCENE_KEYS.results, {
      stats: completion.stats,
      heroSave: completion.heroSave,
      startingHeroSave,
      rewardItemIds: completion.rewardItemIds,
      reward: completion.reward,
      rewardLevelUp: completion.rewardLevelUp,
      launchRequest: cloneBattleLaunchRequestWithHero(this.launch.request, outcome === "victory" ? completion.heroSave : startingHeroSave)
    });
  }

  private castAbilitySlot(slot: number): void {
    const abilityId = this.hero.unlockedAbilities[slot];
    if (!abilityId) {
      this.showMessage("No ability in that slot");
      return;
    }
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
    this.minimapPings = this.minimapPings
      .map((ping) => ({ ...ping, ageSeconds: ping.ageSeconds + deltaSeconds }))
      .filter((ping) => ping.ageSeconds < ping.durationSeconds);
  }

  private addMinimapPing(x: number, y: number, color: string, label: string): void {
    this.minimapPings.push({
      id: this.nextMinimapPingId,
      x,
      y,
      color,
      label,
      ageSeconds: 0,
      durationSeconds: 2.8
    });
    this.nextMinimapPingId += 1;
    this.minimapPings = this.minimapPings.slice(-12);
  }

  private updateResourceSiteWarnings(deltaSeconds: number): void {
    this.resourceSiteWarningCooldowns.forEach((remaining, siteId) => {
      const nextRemaining = remaining - deltaSeconds;
      if (nextRemaining <= 0) {
        this.resourceSiteWarningCooldowns.delete(siteId);
        return;
      }
      this.resourceSiteWarningCooldowns.set(siteId, nextRemaining);
    });

    this.captureSites.forEach((site) => {
      if (site.owner !== "player" || (this.resourceSiteWarningCooldowns.get(site.definition.id) ?? 0) > 0) {
        return;
      }

      const enemyThreateningSite = this.units.some(
        (unit) =>
          unit.alive &&
          unit.team === "enemy" &&
          Phaser.Math.Distance.Between(unit.position.x, unit.position.y, site.position.x, site.position.y) <=
            site.definition.radius + 24
      );
      if (!enemyThreateningSite) {
        return;
      }

      this.resourceSiteWarningCooldowns.set(site.definition.id, 10);
      this.addMinimapPing(site.position.x, site.position.y, "#f0d978", `${site.definition.name} under attack`);
      this.showMessage(`${site.definition.name} is under attack.`, site.position.x, site.position.y - 70, "#f0d978");
    });
  }

  private trackEnemyWave(units: Unit[]): void {
    if (units.length === 0) {
      return;
    }
    this.applyFactionWaveModifiers(units);
    const waveId = this.nextEnemyWaveId;
    const center = units.reduce(
      (sum, unit) => ({
        x: sum.x + unit.position.x,
        y: sum.y + unit.position.y
      }),
      { x: 0, y: 0 }
    );
    this.addMinimapPing(center.x / units.length, center.y / units.length, "#ff7268", `Enemy wave ${waveId} incoming`);
    this.trackedEnemyWaves.push({
      id: waveId,
      unitIds: units.map((unit) => unit.id)
    });
    this.nextEnemyWaveId += 1;
  }

  private applyFactionWaveModifiers(units: Unit[]): void {
    units.forEach((unit) => {
      this.factionModifiersFor(unit)
        .filter((modifier) => modifier.type === "wave-speed" && this.modifierAppliesToUnit(modifier, unit))
        .forEach((modifier) => {
          unit.factionSpeedMultiplier = Math.max(unit.factionSpeedMultiplier, modifier.speedMultiplier ?? 1);
        });
    });
  }

  private factionModifiersFor(unit: Unit): FactionModifierDefinition[] {
    return FACTION_BY_ID[unit.definition.factionId]?.mechanics.factionModifiers ?? [];
  }

  private modifierAppliesToUnit(modifier: FactionModifierDefinition, unit: Unit): boolean {
    return !modifier.unitIds || modifier.unitIds.includes(unit.definition.id);
  }

  private updateTrackedEnemyWaves(): void {
    this.trackedEnemyWaves = this.trackedEnemyWaves.filter((wave) => {
      const aliveWaveUnits = this.units.filter((unit) => wave.unitIds.includes(unit.id) && unit.alive);
      if (aliveWaveUnits.length > 0) {
        return true;
      }
      this.runtime.recordEnemyWaveSurvived();
      this.showMessage(`Enemy wave ${wave.id} defeated`, this.hero.position.x, this.hero.position.y - 80, "#aef7b7");
      return false;
    });
  }

  private updateTutorialHint(): void {
    if (!this.isFirstBattle()) {
      this.tutorialHint = "";
      return;
    }

    const selected = this.selectionSystem.getSelected();
    const commandHall = this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player");
    const crownShrine = this.captureSites.find((site) => site.definition.id === "crown_shrine");
    const heroSelected = selected.includes(this.hero);
    const commandHallSelected = commandHall ? selected.includes(commandHall) : false;
    const barracks = this.buildings.find((building) => building.alive && building.team === "player" && building.definition.id === "barracks");
    const hasBarracks = Boolean(barracks?.isCompleted());

    if (!heroSelected && this.runtime.elapsedSeconds < 20) {
      this.tutorialHint = "Select your hero.";
      return;
    }
    if (crownShrine?.owner !== "player") {
      this.tutorialHint =
        crownShrine && this.hero.alive && Phaser.Math.Distance.Between(this.hero.position.x, this.hero.position.y, crownShrine.position.x, crownShrine.position.y) <= crownShrine.radius
          ? "Hold the Crown Shrine circle until it turns green."
          : "Right-click the Crown Shrine with your hero and troops.";
      return;
    }
    if (!hasBarracks && !commandHallSelected) {
      this.tutorialHint = "Select your Command Hall.";
      return;
    }
    if (!hasBarracks) {
      if (barracks?.isUnderConstruction()) {
        this.tutorialHint = "Barracks is under construction. Hold near your base until it completes.";
        return;
      }
      this.tutorialHint = "Build a Barracks to train troops.";
      return;
    }
    if (this.runtime.stats.unitsTrained === 0) {
      this.tutorialHint = "Train Militia from your Barracks.";
      return;
    }
    if (this.runtime.stats.enemyWavesSurvived === 0) {
      this.tutorialHint = "Defend against the first attack near your Command Hall.";
      return;
    }
    this.tutorialHint = "Gather your army and destroy the enemy Stronghold.";
  }

  private warnIfCommandHallUnderAttack(target: BaseEntity): void {
    if (
      this.commandHallWarningCooldown > 0 ||
      !(target instanceof Building) ||
      target.team !== "player" ||
      target.definition.id !== this.activeMap.scenario.objectives.playerBaseBuildingId
    ) {
      return;
    }
    this.commandHallWarningCooldown = 8;
    this.addMinimapPing(target.position.x, target.position.y, "#ff7268", "Command Hall under attack");
    this.showMessage("Your Command Hall is under attack.", target.position.x, target.position.y - 74, "#ffb1a9");
  }

  private resourceColor(resource: ResourceKey): string {
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
