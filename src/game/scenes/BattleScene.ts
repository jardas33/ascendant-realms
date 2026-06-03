import Phaser from "phaser";
import type {
  Act1FinalePhaseId,
  BattleSecondaryObjectiveType,
  BattlefieldEventId,
  Position,
  ResourceBag,
  ResourceKey,
  Team,
  UpgradeDefinition,
  UnitVeterancyRankUpEvent,
  EnemyDoctrineDefinition,
  LumeNetworkCurrentLinkState,
  LumeNetworkVisibilityMode
} from "../core/GameTypes";
import { addResources, formatTime, payCost } from "../core/MathUtils";
import { formatRetinueDeploymentLabel } from "../core/RetinueRules";
import { formatRivalBattleStartCopy, rivalLaunchModifierName } from "../core/RivalRules";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { DEFAULT_SETTINGS, applySettingsToDocument, normalizeSettingsData } from "../core/Settings";
import {
  AI_PERSONALITY_BY_ID,
  CAMPAIGN_NODE_BY_ID,
  CAMPAIGN_MODIFIER_BY_ID,
  FACTION_BY_ID,
  requireBuilding,
  requireUnit,
  UPGRADE_BY_ID
} from "../data/contentIndex";
import { getBattleDifficulty } from "../data/battlePacing";
import {
  ENEMY_ELITE_SQUAD_BY_ID,
  selectEnemyDoctrineForBattleLaunch,
  selectEnemyEliteSquadForBattle
} from "../data/enemyDoctrines";
import { ENEMY_HERO_BY_ID } from "../data/enemyHeroes";
import { DEFAULT_MAP_ID, MAPS } from "../data/maps";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { getStrongholdBattleEffects, strongholdUpgradeForModifier } from "../data/strongholdUpgrades";
import { ACT1_FINALE_NODE_ID, ACT1_FINALE_PHASE_BY_ID, isAct1FinaleBattle } from "../data/act1Finale";
import { getTacticalPlan, tacticalPlanFromLaunchModifiers } from "../data/tacticalPlans";
import { TUTORIALS } from "../data/tutorials";
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
import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import { BattleRuntime, createBattleRuntime } from "../battle/BattleRuntime";
import {
  BattlefieldEventDirector,
  type ActiveBattlefieldEvent,
  type BattlefieldEventDirectorContext,
  type BattlefieldEventTransition
} from "../battle/BattlefieldEventDirector";
import {
  resolveLumeLinkPresentation,
  type LumeRenderEmphasis,
  type LumeRenderLinkStyle,
  type LumeRenderPresentation,
  type LumeRenderPulse,
  type LumeRenderPulseKind
} from "../battle/LumeNetworkRendering";
import { Act1FinaleDirector, type Act1FinaleDirectorContext, type Act1FinaleTransition } from "../battle/Act1FinaleDirector";
import { createEnemyPressureRuntime, type EnemyPressureRuntime } from "../battle/EnemyPressureRuntime";
import {
  battleStatusCategory,
  battleStatusDedupeSeconds,
  battleStatusDurationSeconds,
  formatBattleStatusMessage,
  shouldReplaceBattleStatus,
  shouldDisplayBattleStatus,
  type BattleStatusOptions,
  type BattleStatusPriority
} from "../battle/BattleStatusPriority";
import { drawBattleMap } from "../battle/BattleSceneMapRenderer";
import { endBattleAndOpenResults } from "../battle/BattleSceneResults";
import { createBattleMinimapSnapshot } from "../battle/BattleSceneSnapshots";
import { completeBattleSecondaryObjective } from "../battle/BattleSceneObjectives";
import { applySecondaryObjectiveBattleEffect } from "../battle/SecondaryObjectiveEffects";
import { spawnBattleScenario, spawnRetinueUnitFromSave, type NeutralCampLabel } from "../battle/BattleSceneSpawner";
import {
  applyFirstCaptureBonusAdditions,
  createBattleFogOfWar,
  createBattleSceneSystems,
  type BattleSceneSystems
} from "../battle/BattleSceneSystems";
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
import { completedEnemyTechBuildingIds } from "../ai/EnemyBaseDevelopmentStrategy";
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
import { showDamageFeedback } from "../ui/DamageFeedback";
import { resolveFogCellPresentation } from "../ui/FogPresentation";
import type { MinimapPing, MinimapSnapshot } from "../ui/MinimapView";
import {
  createHudDensityControls,
  normalizeHudDensityMode,
  shouldRenderHudDebugCounters
} from "../ui/hudPanels/HudDensity";
import type { HudDensityMode } from "../ui/hudPanels/HudTypes";
import {
  commandFeedbackMarkerPresentation,
  type CommandFeedbackMarkerEvent,
  type CommandFeedbackMarkerPresentation
} from "../ui/CommandFeedbackMarker";
import {
  advanceTutorialStep,
  createTutorialStepViewModel,
  firstTutorialStepId,
  type TutorialCompletionSignals,
  type TutorialStepViewModel
} from "../tutorial/TutorialStepModel";
import type { TutorialDefinition, TutorialFocusTargetDefinition } from "../core/GameTypes";
import { AudioManager } from "../systems/AudioManager";
import { CollisionSystem } from "../systems/CollisionSystem";
import { isEntityVisibleToPlayer, type FogOfWarSystem, type VisionSource } from "../systems/FogOfWarSystem";
import { canUseRallyPoint, setRallyPointForBuildings } from "../systems/RallyPointSystem";
import { evaluateRetinueReinforcement, selectRetinueReinforcementUnit } from "../systems/RetinueReinforcementRules";
import { tickStatusEffects } from "../systems/StatusEffectSystem";
import { findWalkableTrainedUnitSpawnPoint } from "../systems/TrainingSystem";
import { applyUpgradeToBuilding, applyUpgradeToUnit } from "../systems/UpgradeEffects";
import type { TechState } from "../systems/PrerequisiteSystem";
import {
  isPrivateLumeDemoLaunch,
  isPrivatePlaytestHubLaunch,
  isPrivatePlaytestToolsEnabled,
  PRIVATE_PLAYTEST_HUB_NOTICE,
  restorePrivatePlaytestHubSave
} from "../playtest/PrivatePlaytestTools";
import {
  registerPrivatePerformanceCounterProvider,
  type PrivatePerformanceCounters
} from "../playtest/PrivatePerformanceProfiler";
import { representativeBattleTierForScenario } from "../playtest/RepresentativeBattleBenchmark";
import {
  createDefaultTrustedDiagnostics,
  normalizeTrustedDiagnostics,
  type TrustedBenchmarkDiagnostics
} from "../playtest/TrustedBrowserBenchmark";
import {
  BattleLoopPhaseProfiler,
  V0110_BATTLE_LOOP_SCENARIOS,
  battleLoopDiagnosticsForScenario,
  createDefaultBattleLoopDiagnostics,
  normalizeBattleLoopDiagnostics,
  type BattleLoopCountSnapshot,
  type BattleLoopDiagnostics,
  type BattleLoopPhaseId,
  type BattleLoopPhaseSummary
} from "../playtest/BattleLoopPhaseProfiler";

const WORLD_ENTITY_INTERACTION_MIN_RADIUS = 26;
const WORLD_ENTITY_UNIT_HIT_PADDING = 6;
const WORLD_ENTITY_UNIT_TOP_HIT_PADDING = 8;
const WORLD_ENTITY_BUILDING_TOP_HIT_PADDING = 8;
const BATTLE_HUD_REFRESH_INTERVAL_SECONDS = 0.1;

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
  captureSite?: (siteId: string) => {
    siteId: string;
    owner: Team;
    beforeResources: ResourceBag;
    afterResources: ResourceBag;
    completedObjectiveIds: string[];
    status: string;
    firstCaptureBonus?: {
      id: string;
      label: string;
      resources: Partial<ResourceBag>;
    };
  } | null;
  scoutEnemyHero?: () => { enemyHeroId: string; name: string; title: string } | null;
  defeatEnemyHero?: () => {
    enemyHeroId: string;
    name: string;
    title: string;
    completedObjectiveIds: string[];
    xpGained: number;
    enemyHeroDefeated: boolean;
  } | null;
  triggerBattlefieldEvent?: (eventId: BattlefieldEventId) => {
    eventId: BattlefieldEventId;
    title: string;
    objective: string;
    progress: string;
  } | null;
  resolveBattlefieldEvent?: (outcome?: "completed" | "failed") => {
    eventId: BattlefieldEventId;
    outcome: "completed" | "failed";
    telemetry: string;
  } | null;
  getAct1FinaleState?: () => {
    activePhaseId?: Act1FinalePhaseId;
    activePhaseTitle?: string;
    completedPhaseIds: Act1FinalePhaseId[];
    commanderReleased: boolean;
    commanderReleasedAtSeconds?: number;
    completed: boolean;
  } | null;
  getLumeNetworkSnapshot?: () => {
    hud: ReturnType<NonNullable<BattleSceneSystems["lumeNetworkDirector"]>["hudSummary"]>;
    state: ReturnType<NonNullable<BattleSceneSystems["lumeNetworkDirector"]>["currentState"]>;
    render: LumeRenderSnapshot;
  } | null;
  focusLumeSite?: (siteId: string) => boolean;
  setLumeVisibilityMode?: (mode: LumeNetworkVisibilityMode) => boolean;
  finishPrivateDemo?: () => boolean;
  showCommandFeedbackMarker?: (kind: CommandFeedbackMarkerEvent["kind"], x?: number, y?: number) => number;
  getCommandFeedbackMarkerCount?: () => number;
  focusSelectedOrHero?: () => { x: number; y: number; label: string } | null;
  getPrivatePerformanceCounters?: () => Partial<PrivatePerformanceCounters>;
  getTrustedBenchmarkDiagnostics?: () => TrustedBenchmarkDiagnostics;
  setTrustedBenchmarkDiagnostics?: (diagnostics: Partial<TrustedBenchmarkDiagnostics>) => TrustedBenchmarkDiagnostics | null;
  selectTrustedBenchmarkTarget?: (target: "hero" | "worker" | "building") => { x: number; y: number; label: string } | null;
  resetTrustedBenchmarkDiagnostics?: () => TrustedBenchmarkDiagnostics | null;
  getBattleLoopDiagnostics?: () => BattleLoopDiagnostics;
  setBattleLoopDiagnostics?: (diagnostics: Partial<BattleLoopDiagnostics>) => BattleLoopDiagnostics | null;
  getBattleLoopPhaseSummary?: () => BattleLoopPhaseSummary;
  resetBattleLoopPhaseProfiler?: () => BattleLoopPhaseSummary;
}

interface LumeRenderLinkSnapshot {
  id: string;
  state: string;
  style: LumeRenderLinkStyle;
  emphasis: LumeRenderEmphasis;
  visible: boolean;
  fromSiteId: string;
  toSiteId: string;
  from: Position;
  to: Position;
  color: number;
  alpha: number;
  width: number;
  pulseKind?: LumeRenderPulseKind;
  layerDepth: number;
}

interface LumeRenderSiteMarkerSnapshot {
  siteId: string;
  state: string;
  emphasis: LumeRenderEmphasis;
  position: Position;
  radius: number;
  color: number;
  alpha: number;
  layerDepth: number;
}

interface LumeRenderSnapshot {
  links: LumeRenderLinkSnapshot[];
  siteMarkers: LumeRenderSiteMarkerSnapshot[];
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
  private repairSystem!: BattleSceneSystems["repairSystem"];
  private buildingSystem!: BattleSceneSystems["buildingSystem"];
  private trainingSystem!: BattleSceneSystems["trainingSystem"];
  private upgradeSystem!: BattleSceneSystems["upgradeSystem"];
  private selectionSystem!: BattleSceneSystems["selectionSystem"];
  private controlGroupSystem!: BattleSceneSystems["controlGroupSystem"];
  private abilitySystem!: BattleSceneSystems["abilitySystem"];
  private enemyHeroAbilitySystem!: BattleSceneSystems["enemyHeroAbilitySystem"];
  private cameraSystem!: BattleSceneSystems["cameraSystem"];
  private inputSystem!: BattleSceneSystems["inputSystem"];
  private uiSystem!: BattleSceneSystems["uiSystem"];
  private xpSystem!: BattleSceneSystems["xpSystem"];
  private aiSystem!: BattleSceneSystems["aiSystem"];
  private lumeNetworkDirector?: BattleSceneSystems["lumeNetworkDirector"];
  private lumeLinkGraphics?: Phaser.GameObjects.Graphics;
  private lumeVisibilityMode: LumeNetworkVisibilityMode = "auto";
  private lumeRenderPulses = new Map<string, LumeRenderPulse>();
  private previousLumeRenderStates?: Map<string, LumeNetworkCurrentLinkState>;
  private lastLumeRenderSignature = "";
  private enemyPressureRuntime?: EnemyPressureRuntime;
  private enemyDoctrine?: EnemyDoctrineDefinition;
  private battlefieldEventDirector?: BattlefieldEventDirector;
  private act1FinaleDirector?: Act1FinaleDirector;

  private statusMessage = "Capture resource sites to grow your army.";
  private statusTimer = 4;
  private statusPriority: BattleStatusPriority = "normal";
  private recentStatusMessages = new Map<string, number>();
  private tutorialHint = "Select your hero, then right-click the Crown Shrine to begin.";
  private tutorialStepId?: string;
  private tutorialDefeatedUnitIds = new Set<string>();
  private tutorialGuidanceDismissed = false;
  private commandHallWarningCooldown = 0;
  private minimapPings: MinimapPing[] = [];
  private nextMinimapPingId = 1;
  private rallyMarkers = new Map<string, Phaser.GameObjects.Container>();
  private commandFeedbackMarkers = new Set<Phaser.GameObjects.Container>();
  private fogOfWar?: FogOfWarSystem;
  private fogOverlay?: Phaser.GameObjects.Graphics;
  private neutralCampLabels: NeutralCampLabel[] = [];
  private fogUpdateTimer = 0;
  private lastFogRenderSignature = "";
  private fogDebugDisabled = false;
  private settings: SaveSettingsData = DEFAULT_SETTINGS;
  private lastSelectionAudioKey = "";
  private resourceSiteWarningCooldowns = new Map<string, number>();
  private trackedEnemyWaves: TrackedEnemyWave[] = [];
  private nextEnemyWaveId = 1;
  private unitVeterancyRankUps: UnitVeterancyRankUpEvent[] = [];
  private lostRetinueUnitIds = new Set<string>();
  private retinueReinforcementUsed = false;
  private scoutedEnemyHeroIds = new Set<string>();
  private menuPaused = false;
  private performanceCounters = this.createEmptyPerformanceCounters();
  private hudDensityMode: HudDensityMode = "minimal";
  private trustedBenchmarkDiagnostics = createDefaultTrustedDiagnostics();
  private battleLoopDiagnostics = createDefaultBattleLoopDiagnostics();
  private battleLoopPhaseProfiler = new BattleLoopPhaseProfiler();
  private trustedDiagnosticsPanel?: HTMLElement;
  private trustedDiagnosticsPanelExpanded = false;
  private trustedDiagnosticsHandler?: (event: MouseEvent) => void;
  private cachedMinimapSnapshot?: MinimapSnapshot;
  private cachedMinimapSnapshotAtSeconds = 0;
  private lastFogDiagnosticRedrawAtSeconds = 0;
  private lastAppliedTrustedDiagnosticsSignature = "";
  private lastAppliedBattleLoopDiagnosticsSignature = "";
  private hudRefreshAccumulatorSeconds = 0;
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
    this.renderLumeNetworkLinks();
    this.updateFogOfWar(0, true);
    this.cameraSystem.centerOn(this.hero.position);
    this.selectionSystem.setSelection(this.initialPlayerSelection());
    this.applyPrivatePlaytestHubScenarioSetup();
    this.updateAct1Finale();
    this.installTestHooks();
    if (isPrivatePlaytestToolsEnabled()) {
      registerPrivatePerformanceCounterProvider(() => this.createPrivatePerformanceCounters());
    }
    this.installTrustedBenchmarkDiagnosticsPanel();
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
  }

  update(_time: number, deltaMs: number): void {
    if (this.runtime.ended || !this.hero) {
      return;
    }

    const deltaSeconds = deltaMs / 1000;
    this.prepareBattleLoopPhaseFrame();
    try {
      if (this.menuPaused) {
        this.measureBattleLoopPhase("hudDom", () => this.refreshBattleHud(deltaSeconds));
        return;
      }

      const simulationPaused = this.isBattleLoopDiagnosticPaused("simulation");
      this.measureBattleLoopPhase("simulationClock", () => {
        if (simulationPaused) {
          return;
        }
        this.runtime.tick(deltaSeconds);
        this.statusTimer = Math.max(0, this.statusTimer - deltaSeconds);
        this.commandHallWarningCooldown = Math.max(0, this.commandHallWarningCooldown - deltaSeconds);
        this.updateMinimapPings(deltaSeconds);
        if (this.statusTimer === 0) {
          this.statusMessage = this.buildingSystem.pendingBuildingId
            ? this.buildingSystem.placementMessage || "Click valid ground near your base to place the building."
            : `AI: ${this.aiSystem.state} - Time ${formatTime(this.runtime.elapsedSeconds)}`;
          this.statusPriority = "normal";
        }
      });

      this.measureBattleLoopPhase("camera", () => {
        if (!simulationPaused && !this.isBattleLoopDiagnosticPaused("camera")) {
          this.cameraSystem.update(deltaSeconds);
        }
      });
      this.measureBattleLoopPhase("abilities", () => {
        if (!simulationPaused) {
          this.abilitySystem.update(deltaSeconds, this.hero);
          this.enemyHeroAbilitySystem.update(deltaSeconds);
        }
      });
      this.measureBattleLoopPhase("movementPathing", () => {
        if (!simulationPaused && !this.isBattleLoopDiagnosticPaused("movement") && !this.isBattleLoopDiagnosticPaused("path")) {
          this.movementSystem.update(deltaSeconds, this.units, this.activeMap, this.buildings);
        }
      });
      this.measureBattleLoopPhase("combatProjectiles", () => {
        if (!simulationPaused && !this.isBattleLoopDiagnosticPaused("combat") && !this.isBattleLoopDiagnosticPaused("projectiles")) {
          this.combatSystem.update(deltaSeconds);
        }
      });
      this.measureBattleLoopPhase("statusEffects", () => {
        if (!simulationPaused) {
          this.updateStatusEffects(deltaSeconds);
        }
      });
      this.measureBattleLoopPhase("economyProduction", () => {
        if (!simulationPaused) {
          this.buildingSystem.update(deltaSeconds);
          this.repairSystem.update(deltaSeconds);
          this.resourceSystem.update(deltaSeconds, this.captureSites, this.units);
          this.updateResourceSiteWarnings(deltaSeconds);
          this.trainingSystem.update(deltaSeconds, this.buildings);
          this.upgradeSystem.update(deltaSeconds, this.buildings);
        }
      });
      this.measureBattleLoopPhase("lumeSimulation", () => {
        if (!simulationPaused) {
          this.lumeNetworkDirector?.update();
        }
      });
      this.measureBattleLoopPhase("lumePresentation", () => this.renderLumeNetworkLinks());
      this.measureBattleLoopPhase("aiStrategy", () => {
        if (!simulationPaused && !this.isBattleLoopDiagnosticPaused("ai")) {
          this.enemyPressureRuntime?.update();
          this.updateAct1Finale();
          this.aiSystem.update(deltaSeconds);
          this.updateBattlefieldEvents(deltaSeconds);
        }
      });
      this.measureBattleLoopPhase("eventsCleanup", () => {
        if (!simulationPaused) {
          this.cleanupDeadEntities();
          this.updateTrackedEnemyWaves();
          this.updateTutorialHint();
        }
      });
      this.updateFogOfWar(deltaSeconds);
      this.measureBattleLoopPhase("lumePresentation", () => {
        this.applyTrustedBenchmarkDiagnosticVisuals();
        this.applyBattleLoopDiagnosticVisuals();
      });
      this.measureBattleLoopPhase("hudDom", () => {
        if (!this.isBattleLoopDiagnosticPaused("hudDomPatches")) {
          this.refreshBattleHud(deltaSeconds);
        }
      });
      this.measureBattleLoopPhase("endConditions", () => {
        if (!simulationPaused) {
          this.checkEndConditions();
        }
      });
    } finally {
      this.battleLoopPhaseProfiler.endFrame();
    }
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
    this.lastFogRenderSignature = "";
    this.fogDebugDisabled = false;
    this.lastSelectionAudioKey = "";
    this.runtime = createBattleRuntime({ launch: this.launch });
    this.enemyPressureRuntime = undefined;
    this.battlefieldEventDirector = undefined;
    this.lumeNetworkDirector = undefined;
    this.lumeLinkGraphics?.destroy();
    this.lumeLinkGraphics = undefined;
    this.lumeVisibilityMode = "auto";
    this.lumeRenderPulses.clear();
    this.previousLumeRenderStates = undefined;
    this.lastLumeRenderSignature = "";
    this.act1FinaleDirector = isAct1FinaleBattle({
      mode: this.launch.request.mode,
      campaignNodeId: this.launch.request.campaignNodeId,
      mapId: this.activeMap.id,
      rewardsDisabled: this.launch.request.rewardsDisabled
    })
      ? new Act1FinaleDirector()
      : undefined;
    this.enemyDoctrine = selectEnemyDoctrineForBattleLaunch({
      mode: this.launch.request.mode,
      campaignNodeId: this.launch.request.campaignNodeId,
      modifierIds: this.launch.request.modifiers.map((modifier) => modifier.id),
      enemyHeroId: this.launch.request.enemyHeroId,
      difficulty: this.launch.request.difficulty,
      retinueUnitCount: this.launch.request.retinueUnits?.length ?? 0,
      retinueReserveCount: this.launch.request.retinueReserveUnits?.length ?? 0,
      rewardsDisabled: this.launch.request.rewardsDisabled
    });
    this.runtime.recordEnemyDoctrine(this.enemyDoctrine?.id);
    this.resources = this.runtime.resources;
    this.units = [];
    this.buildings = [];
    this.projectiles = [];
    this.captureSites = [];
    this.neutralCampLabels = [];
    this.statusMessage = "Capture resource sites to grow your army.";
    this.statusTimer = 4;
    this.statusPriority = "normal";
    this.recentStatusMessages.clear();
    this.performanceCounters = this.createEmptyPerformanceCounters();
    this.hudDensityMode = defaultHudDensityModeForLaunch(this.launch.request, isPrivatePlaytestToolsEnabled());
    this.trustedBenchmarkDiagnostics = createDefaultTrustedDiagnostics();
    this.battleLoopDiagnostics = createDefaultBattleLoopDiagnostics();
    this.battleLoopPhaseProfiler.reset();
    this.trustedDiagnosticsPanelExpanded = false;
    this.cachedMinimapSnapshot = undefined;
    this.cachedMinimapSnapshotAtSeconds = 0;
    this.lastFogDiagnosticRedrawAtSeconds = 0;
    this.lastAppliedTrustedDiagnosticsSignature = "";
    this.lastAppliedBattleLoopDiagnosticsSignature = "";
    this.hudRefreshAccumulatorSeconds = 0;
    this.tutorialHint = "Select your hero, then right-click the Crown Shrine to begin.";
    this.tutorialStepId = undefined;
    this.tutorialDefeatedUnitIds = new Set<string>();
    this.tutorialGuidanceDismissed = false;
    this.commandHallWarningCooldown = 0;
    this.minimapPings = [];
    this.nextMinimapPingId = 1;
    this.rallyMarkers.forEach((marker) => marker.destroy(true));
    this.rallyMarkers = new Map<string, Phaser.GameObjects.Container>();
    this.clearCommandFeedbackMarkers();
    this.resourceSiteWarningCooldowns = new Map<string, number>();
    this.trackedEnemyWaves = [];
    this.nextEnemyWaveId = 1;
    this.unitVeterancyRankUps = [];
    this.lostRetinueUnitIds = new Set<string>();
    this.retinueReinforcementUsed = false;
    this.scoutedEnemyHeroIds = new Set<string>();
    this.menuPaused = false;
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
    this.applyCaptureSiteObjectiveEmphasis();
    this.neutralCampLabels = spawned.neutralCampLabels;
    this.enemyHeroUnits().forEach((unit) => this.runtime.recordEnemyHeroPresence(unit.enemyHeroId, unit.enemyHeroName));
  }

  private applyCaptureSiteObjectiveEmphasis(): void {
    const objectiveSiteIds = new Set(
      (this.activeMap.scenario.objectives.secondaryObjectives ?? [])
        .filter((objective) => objective.type === "capture_site")
        .map((objective) => objective.targetId)
    );
    this.captureSites.forEach((site) => site.setObjectiveRelevant(objectiveSiteIds.has(site.definition.id)));
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
      showMessage: (message, x, y, color, options) => this.showMessage(message, x, y, color, options),
      addMinimapPing: (x, y, color, label) => this.addMinimapPing(x, y, color, label),
      warnIfCommandHallUnderAttack: (target) => this.warnIfCommandHallUnderAttack(target),
      handleUnitDamage: (source, target, amount) => this.handleUnitDamage(source, target, amount),
      applyEnemyHeroDamage: (source, target, amount) => this.applyEnemyHeroDamage(source, target, amount),
      handleKill: (killer, target) => this.handleKill(killer, target),
      completeSecondaryObjective: (type, targetId, point) => this.completeSecondaryObjective(type, targetId, point),
      selectedRallyBuildings: () => this.selectedRallyBuildings(),
      setRallyPoint: (point, buildings) => this.setRallyPoint(point, buildings),
      findWorldEntityAt: (point) => this.findWorldEntityAt(point),
      centerCameraFromMinimap: (normalizedX, normalizedY) => this.centerCameraFromMinimap(normalizedX, normalizedY),
      showCommandFeedbackMarker: (event) => this.showCommandFeedbackMarker(event),
      castAbilitySlot: (slot) => this.castAbilitySlot(slot),
      refreshHud: () => this.refreshBattleHud(0),
      advanceTutorialStep: () => this.advanceTutorialStep(),
      dismissTutorialGuidance: () => this.dismissTutorialGuidance(),
      reopenTutorialGuidance: () => this.reopenTutorialGuidance(),
      focusTutorialObjective: () => this.focusTutorialObjective(),
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
      onPlayerCapturedSite: (siteId) => this.enemyPressureRuntime?.recordPlayerCapturedSite(siteId),
      onPlayerUnitTrained: (unitId) => this.enemyPressureRuntime?.recordPlayerTrainedUnit(unitId),
      openMainMenu: () => this.openBattleMenu(),
      resumeBattle: () => this.resumeBattle(),
      exitToMainMenu: () => this.exitToMainMenu(),
      callRetinueReinforcement: () => this.callRetinueReinforcement(),
      focusLumeSite: (siteId) => this.focusLumeSite(siteId),
      setLumeVisibilityMode: (mode) => this.setLumeVisibilityMode(mode),
      setHudDensityMode: (mode) => this.setHudDensityMode(mode),
      exitPrivateDemo: () => this.exitPrivateDemo(),
      finishPrivateDemo: () => this.finishPrivateDemo(),
      canEnemyHeroJoinAttack: (unit) => this.canEnemyHeroJoinAttack(unit)
    });

    this.movementSystem = systems.movementSystem;
    this.combatSystem = systems.combatSystem;
    this.resourceSystem = systems.resourceSystem;
    this.repairSystem = systems.repairSystem;
    this.buildingSystem = systems.buildingSystem;
    this.trainingSystem = systems.trainingSystem;
    this.upgradeSystem = systems.upgradeSystem;
    this.selectionSystem = systems.selectionSystem;
    this.controlGroupSystem = systems.controlGroupSystem;
    this.abilitySystem = systems.abilitySystem;
    this.enemyHeroAbilitySystem = systems.enemyHeroAbilitySystem;
    this.cameraSystem = systems.cameraSystem;
    this.inputSystem = systems.inputSystem;
    this.uiSystem = systems.uiSystem;
    this.xpSystem = systems.xpSystem;
    this.aiSystem = systems.aiSystem;
    this.lumeNetworkDirector = systems.lumeNetworkDirector;
    this.enemyPressureRuntime = createEnemyPressureRuntime({
      planId: this.launch.request.enemyPressurePlanId,
      mode: this.launch.request.mode,
      mapId: this.activeMap.id,
      campaignNodeId: this.launch.request.campaignNodeId,
      runtime: this.runtime,
      showWarning: (message) =>
        this.showMessage(message, this.hero.position.x, this.hero.position.y - 112, "#f6e27d", { priority: "pressure" }),
      adjustNextWaveTiming: (seconds) => this.aiSystem.adjustNextAttackTiming(seconds)
    });
    this.battlefieldEventDirector = new BattlefieldEventDirector();
  }

  private showBattleStartSummary(): void {
    const faction = FACTION_BY_ID[this.launch.request.enemyProfileId ?? "ashen_covenant"];
    const personality = AI_PERSONALITY_BY_ID[this.launch.request.aiPersonalityId ?? "balanced_warlord"];
    const difficulty = getBattleDifficulty(this.launch.request.difficulty);
    const names = this.launch.request.modifiers
      .map(
        (modifier) =>
          CAMPAIGN_MODIFIER_BY_ID[modifier.id]?.name ??
          strongholdUpgradeForModifier(modifier.id)?.name ??
          rivalLaunchModifierName(modifier.id)
      )
      .filter((name): name is string => Boolean(name));
    const modifierText = names.length > 0 ? ` Modifiers: ${names.join(", ")}.` : "";
    const tacticalPlan = this.launch.request.tacticalPlanId
      ? getTacticalPlan(this.launch.request.tacticalPlanId)
      : tacticalPlanFromLaunchModifiers(this.launch.request.modifiers);
    const planText = tacticalPlan ? ` Tactical plan: ${tacticalPlan.name}. ${tacticalPlan.hudSummary}` : "";
    const retinueNames = (this.launch.request.mode === "campaign_node" ? this.launch.request.retinueUnits ?? [] : [])
      .map(formatRetinueDeploymentLabel);
    const retinueText = retinueNames.length > 0 ? `Retinue deployed: ${retinueNames.join(", ")}. ` : "";
    const enemyHero = this.launch.request.enemyHeroId ? ENEMY_HERO_BY_ID[this.launch.request.enemyHeroId] : undefined;
    const rivalText = formatRivalBattleStartCopy(this.launch.request.enemyHeroId, this.launch.request.modifiers);
    const enemyHeroText = enemyHero
      ? ` Enemy commander: ${enemyHero.name}, ${enemyHero.title}.${rivalText ? ` ${rivalText}` : ""}`
      : "";
    const enemyText = faction
      ? `${faction.name} (${personality?.name ?? "Balanced Warlord"})`
      : personality?.name ?? "Unknown enemy";
    const doctrineText = this.enemyDoctrine
      ? ` Doctrine: ${this.enemyDoctrine.name}. ${this.enemyDoctrine.threatWarning} Counterplay: ${this.enemyDoctrine.counterplay}`
      : "";
    const eliteSquad = selectEnemyEliteSquadForBattle({
      mode: this.launch.request.mode,
      campaignNodeId: this.launch.request.campaignNodeId,
      modifierIds: this.launch.request.modifiers.map((modifier) => modifier.id),
      enemyHeroId: this.launch.request.enemyHeroId,
      difficulty: this.launch.request.difficulty,
      rewardsDisabled: this.launch.request.rewardsDisabled
    });
    const eliteText = eliteSquad ? ` Elite squad possible: ${eliteSquad.name}.` : "";
    this.showMessage(
      `${retinueText}${this.activeMap.name} - ${difficulty.name}. Enemy: ${enemyText}.${enemyHeroText}${modifierText}${planText}${doctrineText}${eliteText}`,
      this.hero.position.x,
      this.hero.position.y - 96,
      "#f6e27d"
    );
    if (retinueNames.length > 0 || enemyHero || this.enemyDoctrine || tacticalPlan) {
      this.statusTimer = 4.5;
    }
  }

  private addUnit(unit: Unit): void {
    this.units.push(unit);
    this.applyResearchedUpgradesToUnit(unit);
    if (unit.team === "enemy" && unit.enemyEliteSquadId) {
      this.runtime.recordEnemyEliteSquad(unit.enemyEliteSquadId);
    }
  }

  private addBuilding(building: Building): void {
    this.buildings.push(building);
    this.applyResearchedUpgradesToBuilding(building);
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
      this.lastFogRenderSignature = "";
      this.applyFogEntityVisibility(false);
      return;
    }

    this.fogUpdateTimer = Math.max(0, this.fogUpdateTimer - deltaSeconds);
    if (!force && this.fogUpdateTimer > 0) {
      return;
    }

    this.fogUpdateTimer = 0.12;
    this.measureBattleLoopPhase("fogSimulation", () => {
      if (!this.isBattleLoopDiagnosticPaused("fogSimulation")) {
        fog.update(this.createVisionSources());
      }
    });
    this.measureBattleLoopPhase("fogPresentation", () => {
      if (this.isBattleLoopDiagnosticPaused("fogPresentation")) {
        return;
      }
      this.renderFogOverlay();
      this.applyFogEntityVisibility(true);
    });
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
    const capturedSiteSources = this.captureSites
      .filter((site) => site.owner === "player")
      .map((site) => ({
        x: site.position.x,
        y: site.position.y,
        radius: Math.max(160, site.definition.radius + 84)
      }));
    return [...unitSources, ...buildingSources, ...capturedSiteSources];
  }

  private renderFogOverlay(): void {
    if (!this.fogOverlay || !this.fogOfWar) {
      return;
    }

    const signature = this.createFogRenderSignature();
    if (signature === this.lastFogRenderSignature && this.fogOverlay.visible) {
      return;
    }
    if (
      this.canUseTrustedBenchmarkDiagnostics() &&
      this.trustedBenchmarkDiagnostics.fogRedraw === "reduced" &&
      this.fogOverlay.visible &&
      this.runtime.elapsedSeconds - this.lastFogDiagnosticRedrawAtSeconds < 0.5
    ) {
      return;
    }
    this.lastFogRenderSignature = signature;
    this.lastFogDiagnosticRedrawAtSeconds = this.runtime.elapsedSeconds;
    this.performanceCounters.fogRedraws += 1;
    this.fogOverlay.clear().setVisible(true);
    this.fogOfWar.cells().forEach((cell) => {
      if (cell.state === "visible") {
        return;
      }
      const presentation = resolveFogCellPresentation(cell.state);
      this.fogOverlay?.fillStyle(presentation.fillColor, presentation.fillAlpha);
      this.fogOverlay?.fillRoundedRect(cell.x - 1, cell.y - 1, cell.width + 2, cell.height + 2, presentation.cornerRadius);
      if (presentation.strokeAlpha > 0) {
        this.fogOverlay?.lineStyle(1, presentation.strokeColor, presentation.strokeAlpha);
        this.fogOverlay?.strokeRoundedRect(cell.x + 1, cell.y + 1, cell.width - 2, cell.height - 2, presentation.cornerRadius);
      }
    });
  }

  private createFogRenderSignature(): string {
    if (!this.fogOfWar) {
      return "none";
    }
    return this.fogOfWar
      .cells()
      .filter((cell) => cell.state !== "visible")
      .map((cell) => `${Math.round(cell.x)}:${Math.round(cell.y)}:${cell.state}`)
      .join("|");
  }

  private applyFogEntityVisibility(fogEnabled: boolean): void {
    const fog = this.fogOfWar;
    if (!fog || !fogEnabled) {
      [...this.units, ...this.buildings, ...this.captureSites, ...this.projectiles].forEach((entity) => entity.view?.setVisible(true));
      this.neutralCampLabels.forEach((entry) => entry.label.setVisible(true));
      this.enemyHeroUnits().forEach((unit) => this.handleEnemyHeroVisible(unit));
      return;
    }

    this.units.forEach((unit) => {
      const visible = isEntityVisibleToPlayer(unit, fog, true);
      unit.view?.setVisible(visible);
      if (visible && unit.enemyHeroId) {
        this.handleEnemyHeroVisible(unit);
      }
    });
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
    this.showCommandFeedbackMarker({ kind: "rally", point: assignment.rallyPoint, count: assignment.updatedCount });
    this.addMinimapPing(assignment.rallyPoint.x, assignment.rallyPoint.y, "#9cf7b1", "Rally point set");
    this.showMessage(
      assignment.updatedCount === 1 ? "Rally point set" : `Rally point set for ${assignment.updatedCount} buildings`,
      assignment.rallyPoint.x,
      assignment.rallyPoint.y - 28,
      "#b9f7c7",
      { priority: "command" }
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

  private showCommandFeedbackMarker(event: CommandFeedbackMarkerEvent): void {
    if (this.commandFeedbackMarkers.size >= 18) {
      const [oldest] = this.commandFeedbackMarkers;
      oldest?.destroy(true);
      if (oldest) {
        this.commandFeedbackMarkers.delete(oldest);
      }
    }

    const presentation = commandFeedbackMarkerPresentation(event, {
      reducedMotion: this.settings.reducedMotionEnabled
    });
    const marker = this.add.container(event.point.x, event.point.y).setDepth(88).setAlpha(0.96).setName(`command-feedback-${event.kind}`);
    const graphics = this.add.graphics();
    this.drawCommandFeedbackMarker(graphics, presentation, event);
    marker.add(graphics);

    const label = this.add
      .text(0, -presentation.radius - 20, presentation.label, {
        fontFamily: "Verdana, Arial, sans-serif",
        fontSize: "10px",
        color: presentation.textColor,
        backgroundColor: "#08100c",
        stroke: "#101511",
        strokeThickness: 3
      })
      .setOrigin(0.5)
      .setPadding(5, 2, 5, 2);
    marker.add(label);
    this.commandFeedbackMarkers.add(marker);

    let destroyed = false;
    const destroyMarker = () => {
      if (destroyed) {
        return;
      }
      destroyed = true;
      this.commandFeedbackMarkers.delete(marker);
      marker.destroy(true);
    };

    if (this.settings.reducedMotionEnabled) {
      this.time.delayedCall(presentation.durationMs, destroyMarker);
      globalThis.setTimeout(destroyMarker, presentation.durationMs + 100);
      return;
    }

    this.tweens.add({
      targets: marker,
      alpha: 0,
      scale: 1.14,
      duration: presentation.durationMs,
      ease: "Sine.easeOut",
      onComplete: destroyMarker
    });
    globalThis.setTimeout(destroyMarker, presentation.durationMs + 350);
  }

  private drawCommandFeedbackMarker(
    graphics: Phaser.GameObjects.Graphics,
    presentation: CommandFeedbackMarkerPresentation,
    event: CommandFeedbackMarkerEvent
  ): void {
    const radius = presentation.radius;
    graphics.lineStyle(presentation.strokeWidth, presentation.strokeColor, 0.92);
    graphics.fillStyle(presentation.fillColor, 0.18);

    if (event.origin) {
      graphics.lineStyle(2, presentation.strokeColor, 0.62);
      graphics.lineBetween(event.origin.x - event.point.x, event.origin.y - event.point.y, 0, 0);
      graphics.fillStyle(presentation.strokeColor, 0.72);
      graphics.fillCircle(event.origin.x - event.point.x, event.origin.y - event.point.y, 4);
      graphics.lineStyle(presentation.strokeWidth, presentation.strokeColor, 0.92);
      graphics.fillStyle(presentation.fillColor, 0.18);
    }

    switch (presentation.shape) {
      case "cross":
        graphics.strokeCircle(0, 0, radius);
        graphics.lineBetween(-radius * 0.58, -radius * 0.58, radius * 0.58, radius * 0.58);
        graphics.lineBetween(-radius * 0.58, radius * 0.58, radius * 0.58, -radius * 0.58);
        break;
      case "hostile":
        graphics.fillCircle(0, 0, radius);
        graphics.strokeCircle(0, 0, radius);
        graphics.lineBetween(-radius - 5, 0, radius + 5, 0);
        graphics.lineBetween(0, -radius - 5, 0, radius + 5);
        break;
      case "route":
        graphics.fillCircle(0, 0, radius * 0.58);
        graphics.strokeCircle(0, 0, radius);
        graphics.lineBetween(-radius * 0.72, radius * 0.58, radius * 0.72, radius * 0.58);
        break;
      case "banner":
        graphics.fillCircle(0, 0, radius * 0.56);
        graphics.strokeCircle(0, 0, radius);
        graphics.lineBetween(0, 0, 0, -radius * 1.35);
        graphics.fillTriangle(1, -radius * 1.35, radius * 0.95, -radius * 1.08, 1, -radius * 0.8);
        break;
      case "square":
        graphics.fillRect(-radius, -radius, radius * 2, radius * 2);
        graphics.strokeRect(-radius, -radius, radius * 2, radius * 2);
        graphics.lineBetween(-radius * 0.55, 0, radius * 0.55, 0);
        graphics.lineBetween(0, -radius * 0.55, 0, radius * 0.55);
        break;
      case "spark":
        graphics.strokeCircle(0, 0, radius);
        graphics.lineBetween(-radius, 0, radius, 0);
        graphics.lineBetween(0, -radius, 0, radius);
        graphics.lineBetween(-radius * 0.62, -radius * 0.62, radius * 0.62, radius * 0.62);
        graphics.lineBetween(-radius * 0.62, radius * 0.62, radius * 0.62, -radius * 0.62);
        break;
      case "focus":
        graphics.strokeCircle(0, 0, radius);
        graphics.strokeCircle(0, 0, radius * 0.48);
        graphics.lineBetween(-radius - 4, 0, -radius * 0.45, 0);
        graphics.lineBetween(radius * 0.45, 0, radius + 4, 0);
        graphics.lineBetween(0, -radius - 4, 0, -radius * 0.45);
        graphics.lineBetween(0, radius * 0.45, 0, radius + 4);
        break;
      case "ring":
      default:
        graphics.fillCircle(0, 0, radius * 0.7);
        graphics.strokeCircle(0, 0, radius);
        graphics.lineBetween(-radius * 0.5, 0, radius * 0.5, 0);
        graphics.lineBetween(0, -radius * 0.5, 0, radius * 0.5);
        break;
    }
  }

  private clearCommandFeedbackMarkers(): void {
    this.commandFeedbackMarkers.forEach((marker) => marker.destroy(true));
    this.commandFeedbackMarkers.clear();
  }

  private findWorldEntityAt(point: Position): BaseEntity | undefined {
    const visibleCombatEntities = [...this.units, ...this.buildings].filter(
      (entity) => entity.team === "player" || this.isPointVisibleToPlayer(entity.position)
    );
    const combatEntity = CollisionSystem.findEntityAt(
      point.x,
      point.y,
      visibleCombatEntities,
      {
        minimumRadius: WORLD_ENTITY_INTERACTION_MIN_RADIUS,
        padding: (entity) => (entity instanceof Unit ? WORLD_ENTITY_UNIT_HIT_PADDING : 0),
        topPadding: (entity) =>
          entity instanceof Unit ? WORLD_ENTITY_UNIT_TOP_HIT_PADDING : WORLD_ENTITY_BUILDING_TOP_HIT_PADDING,
        footprint: (entity) =>
          entity instanceof Building
            ? {
                x: entity.position.x - entity.definition.size.width / 2,
                y: entity.position.y - entity.definition.size.height / 2,
                width: entity.definition.size.width,
                height: entity.definition.size.height
              }
            : undefined
      }
    );
    const siteEntity = CollisionSystem.findEntityAt(
      point.x,
      point.y,
      this.captureSites.filter((site) => this.isPointExploredByPlayer(site.position)),
      { minimumRadius: WORLD_ENTITY_INTERACTION_MIN_RADIUS }
    );
    if (combatEntity instanceof Unit && combatEntity.team === "player" && siteEntity) {
      return siteEntity;
    }
    return combatEntity ?? siteEntity;
  }

  private centerCameraFromMinimap(normalizedX: number, normalizedY: number): void {
    const point = {
      x: Phaser.Math.Clamp(normalizedX, 0, 1) * this.activeMap.width,
      y: Phaser.Math.Clamp(normalizedY, 0, 1) * this.activeMap.height
    };
    this.cameraSystem.centerOn(point);
    this.addMinimapPing(point.x, point.y, "#74d3f2", "Camera focus");
    this.showCommandFeedbackMarker({ kind: "focus", point, label: "Map Focus" });
    this.showMessage("Camera focus updated.", point.x, point.y - 42, "#74d3f2", { priority: "command" });
  }

  private isPrivateLumeDemo(): boolean {
    return isPrivateLumeDemoLaunch(this.launch.request) && Boolean(this.lumeNetworkDirector);
  }

  private isPrivatePlaytestHubPreview(): boolean {
    return isPrivatePlaytestHubLaunch(this.launch.request);
  }

  private focusLumeSite(siteId: string): boolean {
    if (!this.isPrivateLumeDemo()) {
      return false;
    }
    const site = this.captureSites.find((entry) => entry.definition.id === siteId || entry.id === siteId);
    if (!site) {
      this.showMessage("Lume focus target unavailable.", undefined, undefined, "#ffd27a", { priority: "command" });
      return false;
    }
    this.cameraSystem.centerOn(site.position);
    this.addMinimapPing(site.position.x, site.position.y, "#74d3f2", site.definition.name);
    this.showCommandFeedbackMarker({ kind: "focus", point: site.position, label: "Lume Focus" });
    this.showMessage(`Focus: ${site.definition.name}`, site.position.x, site.position.y - 86, "#74d3f2", {
      priority: "command"
    });
    this.refreshBattleHud(0);
    return true;
  }

  private setLumeVisibilityMode(mode: LumeNetworkVisibilityMode): boolean {
    if (!this.lumeNetworkDirector) {
      return false;
    }
    this.lumeVisibilityMode = mode;
    this.lastLumeRenderSignature = "";
    const label = mode === "always" ? "Always" : mode === "hidden" ? "Hidden" : "Auto";
    this.showMessage(`Lume links: ${label}`, undefined, undefined, "#74d3f2", { priority: "command" });
    this.renderLumeNetworkLinks();
    this.refreshBattleHud(0);
    return true;
  }

  private setHudDensityMode(mode: HudDensityMode): boolean {
    if (!this.canUsePrivateHudDensityControls()) {
      return false;
    }
    const nextMode = normalizeHudDensityMode(mode, true);
    if (nextMode === this.hudDensityMode) {
      return true;
    }
    this.hudDensityMode = nextMode;
    this.showMessage(`HUD density: ${hudDensityLabel(nextMode)}`, undefined, undefined, "#74d3f2", {
      priority: "command"
    });
    this.refreshBattleHud(0);
    return true;
  }

  private canUsePrivateHudDensityControls(): boolean {
    return isPrivatePlaytestToolsEnabled() && (this.isPrivatePlaytestHubPreview() || this.isPrivateLumeDemo());
  }

  private canUseTrustedBenchmarkDiagnostics(): boolean {
    return isPrivatePlaytestToolsEnabled() && this.isPrivatePlaytestHubPreview();
  }

  private canUseBattleLoopDiagnostics(): boolean {
    return isPrivatePlaytestToolsEnabled() && this.isPrivatePlaytestHubPreview();
  }

  private setTrustedBenchmarkDiagnostics(
    diagnostics: Partial<TrustedBenchmarkDiagnostics>
  ): TrustedBenchmarkDiagnostics | null {
    if (!this.canUseTrustedBenchmarkDiagnostics()) {
      return null;
    }
    this.trustedBenchmarkDiagnostics = normalizeTrustedDiagnostics({
      ...this.trustedBenchmarkDiagnostics,
      ...diagnostics
    });
    this.battleLoopDiagnostics = normalizeBattleLoopDiagnostics({
      ...this.battleLoopDiagnostics,
      labels: this.trustedBenchmarkDiagnostics.labels,
      captureRings: this.trustedBenchmarkDiagnostics.captureRings,
      lume: this.trustedBenchmarkDiagnostics.lume,
      minimap: this.trustedBenchmarkDiagnostics.minimapRefresh === "paused" ? "paused" : "normal",
      notifications: this.trustedBenchmarkDiagnostics.notifications,
      profilerOverlay: this.trustedBenchmarkDiagnostics.profilerOverlay
    });
    this.cachedMinimapSnapshot = undefined;
    if (diagnostics.lume) {
      this.setLumeVisibilityMode(this.trustedBenchmarkDiagnostics.lume);
    }
    this.setHudDensityMode(this.trustedBenchmarkDiagnostics.hudDensity);
    this.applyTrustedBenchmarkDiagnosticVisuals();
    this.applyTrustedProfilerOverlayDiagnostic();
    this.renderTrustedBenchmarkDiagnosticsPanel();
    this.refreshBattleHud(0);
    return { ...this.trustedBenchmarkDiagnostics };
  }

  private resetTrustedBenchmarkDiagnostics(): TrustedBenchmarkDiagnostics | null {
    return this.setTrustedBenchmarkDiagnostics(createDefaultTrustedDiagnostics());
  }

  private setBattleLoopDiagnostics(diagnostics: Partial<BattleLoopDiagnostics>): BattleLoopDiagnostics | null {
    if (!this.canUseBattleLoopDiagnostics()) {
      return null;
    }
    this.battleLoopDiagnostics = normalizeBattleLoopDiagnostics({
      ...this.battleLoopDiagnostics,
      ...diagnostics
    });
    this.trustedBenchmarkDiagnostics = normalizeTrustedDiagnostics({
      ...this.trustedBenchmarkDiagnostics,
      labels: this.battleLoopDiagnostics.labels,
      captureRings: this.battleLoopDiagnostics.captureRings,
      lume: this.battleLoopDiagnostics.lume,
      minimapRefresh: this.battleLoopDiagnostics.minimap === "paused" ? "paused" : this.trustedBenchmarkDiagnostics.minimapRefresh,
      notifications: this.battleLoopDiagnostics.notifications,
      profilerOverlay: this.battleLoopDiagnostics.profilerOverlay
    });
    this.battleLoopPhaseProfiler.setEnabled(this.battleLoopDiagnostics.phaseProfiler === "on");
    this.cachedMinimapSnapshot = undefined;
    this.setLumeVisibilityMode(this.battleLoopDiagnostics.lume);
    this.applyTrustedBenchmarkDiagnosticVisuals();
    this.applyBattleLoopDiagnosticVisuals();
    this.applyTrustedProfilerOverlayDiagnostic();
    this.renderTrustedBenchmarkDiagnosticsPanel();
    if (this.battleLoopDiagnostics.hudDomPatches === "normal") {
      this.refreshBattleHud(0);
    }
    return { ...this.battleLoopDiagnostics };
  }

  private resetBattleLoopPhaseProfiler(): BattleLoopPhaseSummary {
    return this.battleLoopPhaseProfiler.reset();
  }

  private prepareBattleLoopPhaseFrame(): void {
    const enabled = this.canUseBattleLoopDiagnostics() && this.battleLoopDiagnostics.phaseProfiler === "on";
    this.battleLoopPhaseProfiler.setEnabled(enabled);
    this.battleLoopPhaseProfiler.beginFrame(this.createBattleLoopCountSnapshot());
  }

  private measureBattleLoopPhase<T>(phaseId: BattleLoopPhaseId, work: () => T): T {
    return this.battleLoopPhaseProfiler.measure(phaseId, work);
  }

  private isBattleLoopDiagnosticPaused(key: keyof BattleLoopDiagnostics): boolean {
    return this.canUseBattleLoopDiagnostics() && this.battleLoopDiagnostics[key] === "paused";
  }

  private applyTrustedBenchmarkDiagnosticVisuals(): void {
    if (!this.canUseTrustedBenchmarkDiagnostics()) {
      return;
    }
    const signature = JSON.stringify({
      labels: this.trustedBenchmarkDiagnostics.labels,
      captureRings: this.trustedBenchmarkDiagnostics.captureRings
    });
    if (signature === this.lastAppliedTrustedDiagnosticsSignature) {
      return;
    }
    this.lastAppliedTrustedDiagnosticsSignature = signature;
    const hideLabels = this.trustedBenchmarkDiagnostics.labels === "hidden";
    [...this.units, ...this.buildings, ...this.captureSites].forEach((entity) => entity.setDiagnosticLabelHidden(hideLabels));
    this.neutralCampLabels.forEach((entry) => entry.label.setVisible(!hideLabels));
    this.captureSites.forEach((site) => site.setDiagnosticRingMode(this.trustedBenchmarkDiagnostics.captureRings));
  }

  private applyBattleLoopDiagnosticVisuals(): void {
    if (!this.canUseBattleLoopDiagnostics()) {
      return;
    }
    const signature = JSON.stringify({
      entityGraphics: this.battleLoopDiagnostics.entityGraphics,
      labels: this.battleLoopDiagnostics.labels,
      captureRings: this.battleLoopDiagnostics.captureRings
    });
    if (signature === this.lastAppliedBattleLoopDiagnosticsSignature) {
      return;
    }
    this.lastAppliedBattleLoopDiagnosticsSignature = signature;
    const hideLabels = this.battleLoopDiagnostics.labels === "hidden";
    const hideEntityGraphics = this.battleLoopDiagnostics.entityGraphics === "hidden";
    [...this.units, ...this.buildings, ...this.captureSites, ...this.projectiles].forEach((entity) => {
      entity.view?.setVisible(!hideEntityGraphics);
      entity.setDiagnosticLabelHidden(hideLabels);
    });
    this.neutralCampLabels.forEach((entry) => entry.label.setVisible(!hideLabels && !hideEntityGraphics));
    this.captureSites.forEach((site) => site.setDiagnosticRingMode(this.battleLoopDiagnostics.captureRings));
    if (!hideEntityGraphics) {
      this.applyFogEntityVisibility(this.isFogActive());
    }
  }

  private applyTrustedProfilerOverlayDiagnostic(): void {
    const profiler = typeof window === "undefined" ? undefined : window.__ASCENDANT_PERFORMANCE_PROFILER__;
    if (!profiler) {
      return;
    }
    if (this.trustedBenchmarkDiagnostics.profilerOverlay === "on" && !profiler.isActive()) {
      profiler.start("v0109_trusted_diagnostic_overlay");
      return;
    }
    if (this.trustedBenchmarkDiagnostics.profilerOverlay === "off" && profiler.isActive()) {
      profiler.stop();
    }
  }

  private installTrustedBenchmarkDiagnosticsPanel(): void {
    if (!this.canUseTrustedBenchmarkDiagnostics()) {
      this.removeTrustedBenchmarkDiagnosticsPanel();
      return;
    }
    if (!this.trustedDiagnosticsPanel) {
      this.trustedDiagnosticsPanel = document.createElement("aside");
      this.trustedDiagnosticsPanel.className = "trusted-benchmark-diagnostics";
      this.trustedDiagnosticsPanel.dataset.testid = "trusted-diagnostic-toggles";
      this.trustedDiagnosticsHandler = (event) => this.handleTrustedBenchmarkDiagnosticsClick(event);
      this.trustedDiagnosticsPanel.addEventListener("click", this.trustedDiagnosticsHandler);
      document.body.append(this.trustedDiagnosticsPanel);
    }
    this.renderTrustedBenchmarkDiagnosticsPanel();
  }

  private removeTrustedBenchmarkDiagnosticsPanel(): void {
    if (this.trustedDiagnosticsPanel && this.trustedDiagnosticsHandler) {
      this.trustedDiagnosticsPanel.removeEventListener("click", this.trustedDiagnosticsHandler);
    }
    this.trustedDiagnosticsPanel?.remove();
    this.trustedDiagnosticsPanel = undefined;
    this.trustedDiagnosticsHandler = undefined;
  }

  private handleTrustedBenchmarkDiagnosticsClick(event: MouseEvent): void {
    const target = event.target as HTMLElement | null;
    const toggle = target?.closest<HTMLButtonElement>("button[data-trusted-panel]");
    if (toggle) {
      this.trustedDiagnosticsPanelExpanded = !this.trustedDiagnosticsPanelExpanded;
      this.renderTrustedBenchmarkDiagnosticsPanel();
      return;
    }
    const button = target?.closest<HTMLButtonElement>("button[data-trusted-diagnostic]");
    if (!button) {
      const battleLoopButton = target?.closest<HTMLButtonElement>("button[data-battle-loop-diagnostic]");
      if (!battleLoopButton) {
        return;
      }
      const key = battleLoopButton.dataset.battleLoopDiagnostic as keyof BattleLoopDiagnostics | undefined;
      const value = battleLoopButton.dataset.battleLoopValue;
      if (!key || !value) {
        return;
      }
      this.setBattleLoopDiagnostics({ [key]: value } as Partial<BattleLoopDiagnostics>);
      return;
    }
    const key = button.dataset.trustedDiagnostic as keyof TrustedBenchmarkDiagnostics | undefined;
    const value = button.dataset.trustedValue;
    if (!key || !value) {
      return;
    }
    this.setTrustedBenchmarkDiagnostics({ [key]: value } as Partial<TrustedBenchmarkDiagnostics>);
  }

  private renderTrustedBenchmarkDiagnosticsPanel(): void {
    if (!this.trustedDiagnosticsPanel) {
      return;
    }
    const diagnostics = this.trustedBenchmarkDiagnostics;
    const battleLoop = this.battleLoopDiagnostics;
    this.trustedDiagnosticsPanel.innerHTML = `
      <div class="trusted-diagnostics-header">
        <strong>Trusted Diagnostics</strong>
        <button type="button" data-testid="trusted-diagnostic-toggle" data-trusted-panel="toggle" aria-expanded="${
          this.trustedDiagnosticsPanelExpanded ? "true" : "false"
        }">${this.trustedDiagnosticsPanelExpanded ? "Collapse" : "Expand"}</button>
      </div>
      <p>Private, session-only, non-production visual isolation. No save, reward, progression, balance, fog simulation, or capture-rule changes.</p>
      <div class="trusted-diagnostics-summary" data-testid="trusted-diagnostic-summary">
        Labels ${diagnostics.labels}; rings ${diagnostics.captureRings}; Lume ${diagnostics.lume}; minimap ${diagnostics.minimapRefresh}; fog ${diagnostics.fogRedraw}; HUD ${diagnostics.hudDensity}; notifications ${diagnostics.notifications}; overlay ${diagnostics.profilerOverlay}; phase profiler ${battleLoop.phaseProfiler}.
      </div>
      ${
        this.trustedDiagnosticsPanelExpanded
          ? `
            ${this.renderTrustedDiagnosticButtons("labels", ["normal", "hidden"], diagnostics.labels)}
            ${this.renderTrustedDiagnosticButtons("captureRings", ["normal", "minimal"], diagnostics.captureRings)}
            ${this.renderTrustedDiagnosticButtons("lume", ["hidden", "auto", "always"], diagnostics.lume)}
            ${this.renderTrustedDiagnosticButtons("minimapRefresh", ["normal", "reduced", "paused"], diagnostics.minimapRefresh)}
            ${this.renderTrustedDiagnosticButtons("fogRedraw", ["normal", "reduced"], diagnostics.fogRedraw)}
            ${this.renderTrustedDiagnosticButtons("hudDensity", ["minimal", "standard", "debug"], diagnostics.hudDensity)}
            ${this.renderTrustedDiagnosticButtons("notifications", ["normal", "suppressed"], diagnostics.notifications)}
            ${this.renderTrustedDiagnosticButtons("profilerOverlay", ["off", "on"], diagnostics.profilerOverlay)}
            <div class="trusted-diagnostic-separator" data-testid="battle-loop-diag-section">v0.110 battle-loop isolation</div>
            ${this.renderBattleLoopDiagnosticButtons("phaseProfiler", ["off", "on"], battleLoop.phaseProfiler)}
            ${this.renderBattleLoopDiagnosticButtons("simulation", ["normal", "paused"], battleLoop.simulation)}
            ${this.renderBattleLoopDiagnosticButtons("ai", ["normal", "paused"], battleLoop.ai)}
            ${this.renderBattleLoopDiagnosticButtons("path", ["normal", "paused"], battleLoop.path)}
            ${this.renderBattleLoopDiagnosticButtons("movement", ["normal", "paused"], battleLoop.movement)}
            ${this.renderBattleLoopDiagnosticButtons("combat", ["normal", "paused"], battleLoop.combat)}
            ${this.renderBattleLoopDiagnosticButtons("projectiles", ["normal", "paused"], battleLoop.projectiles)}
            ${this.renderBattleLoopDiagnosticButtons("fogSimulation", ["normal", "paused"], battleLoop.fogSimulation)}
            ${this.renderBattleLoopDiagnosticButtons("fogPresentation", ["normal", "paused"], battleLoop.fogPresentation)}
            ${this.renderBattleLoopDiagnosticButtons("entityGraphics", ["normal", "hidden"], battleLoop.entityGraphics)}
            ${this.renderBattleLoopDiagnosticButtons("hudDomPatches", ["normal", "paused"], battleLoop.hudDomPatches)}
            ${this.renderBattleLoopDiagnosticButtons("camera", ["normal", "paused"], battleLoop.camera)}
          `
          : ""
      }
    `;
  }

  private renderTrustedDiagnosticButtons(key: keyof TrustedBenchmarkDiagnostics, values: string[], active: string): string {
    return `
      <div class="trusted-diagnostic-row" data-testid="trusted-diag-row-${key}">
        <span>${trustedDiagnosticLabel(key)}</span>
        <div>
          ${values
            .map(
              (value) => `
                <button type="button" data-testid="trusted-diag-${kebabCase(key)}-${kebabCase(value)}" data-trusted-diagnostic="${key}" data-trusted-value="${value}" aria-pressed="${
                value === active ? "true" : "false"
              }" class="${value === active ? "active" : ""}">${trustedDiagnosticValueLabel(value)}</button>
              `
            )
            .join("")}
        </div>
      </div>
    `;
  }

  private renderBattleLoopDiagnosticButtons(key: keyof BattleLoopDiagnostics, values: string[], active: string): string {
    return `
      <div class="trusted-diagnostic-row" data-testid="battle-loop-diag-row-${key}">
        <span>${battleLoopDiagnosticLabel(key)}</span>
        <div>
          ${values
            .map(
              (value) => `
                <button type="button" data-testid="battle-loop-diag-${kebabCase(key)}-${kebabCase(value)}" data-battle-loop-diagnostic="${key}" data-battle-loop-value="${value}" aria-pressed="${
                value === active ? "true" : "false"
              }" class="${value === active ? "active" : ""}">${trustedDiagnosticValueLabel(value)}</button>
              `
            )
            .join("")}
        </div>
      </div>
    `;
  }

  private exitPrivateDemo(): boolean {
    if (this.isPrivatePlaytestHubPreview()) {
      return this.exitPrivatePlaytestHubPreview();
    }
    if (!this.isPrivateLumeDemo()) {
      return false;
    }
    this.menuPaused = false;
    const saved = SaveSystem.load();
    this.scene.start(SCENE_KEYS.campaignMap, {
      heroSave: saved?.hero ?? this.launch.request.heroSave,
      campaignSave: saved?.campaign,
      message: "Private Lume demo exited. No rewards or campaign progress were saved."
    });
    return true;
  }

  private exitPrivatePlaytestHubPreview(): boolean {
    if (!this.isPrivatePlaytestHubPreview()) {
      return false;
    }
    this.menuPaused = false;
    restorePrivatePlaytestHubSave();
    this.scene.start(SCENE_KEYS.playtestHub);
    return true;
  }

  private finishPrivateDemo(): boolean {
    if (!this.isPrivateLumeDemo()) {
      return false;
    }
    if (!this.lumeNetworkDirector?.currentState().objectiveCompleted) {
      this.showMessage("Awaken the first Lume Ward link before finishing the demo.", undefined, undefined, "#ffd27a", {
        priority: "command"
      });
      return false;
    }
    this.endBattle("victory");
    return true;
  }

  private createMinimapSnapshot(): MinimapSnapshot {
    if (
      this.canUseTrustedBenchmarkDiagnostics() &&
      this.trustedBenchmarkDiagnostics.minimapRefresh === "paused" &&
      this.cachedMinimapSnapshot
    ) {
      return this.cachedMinimapSnapshot;
    }
    if (
      this.canUseTrustedBenchmarkDiagnostics() &&
      this.trustedBenchmarkDiagnostics.minimapRefresh === "reduced" &&
      this.cachedMinimapSnapshot &&
      this.runtime.elapsedSeconds - this.cachedMinimapSnapshotAtSeconds < 0.75
    ) {
      return this.cachedMinimapSnapshot;
    }
    this.performanceCounters.minimapRefreshes += 1;
    const snapshot = createBattleMinimapSnapshot({
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
    this.cachedMinimapSnapshot = snapshot;
    this.cachedMinimapSnapshotAtSeconds = this.runtime.elapsedSeconds;
    return snapshot;
  }

  private createObjectiveSnapshot() {
    const objectives = this.activeMap.scenario.objectives.secondaryObjectives ?? [];
    const completed = new Set(this.runtime.stats.completedObjectiveIds);
    const missionObjectives = objectives.map((objective) => ({
      id: objective.id,
      name: objective.name,
      description: objective.description,
      completed: completed.has(objective.id)
    }));
    const finalePhase = this.createAct1FinaleObjectiveSnapshot();
    return finalePhase ? [finalePhase, ...missionObjectives] : missionObjectives;
  }

  private createAct1FinaleObjectiveSnapshot() {
    const phase = this.act1FinaleDirector?.currentPhaseSnapshot(this.createAct1FinaleContext());
    if (!phase || this.act1FinaleDirector?.isCompleted) {
      return undefined;
    }
    return {
      id: `act1_finale_${phase.id}`,
      name: phase.title,
      description: `${phase.objective}${phase.planMatched ? " Tactical plan support active." : ""}`,
      completed: phase.completed
    };
  }

  private createBattlefieldEventSnapshot() {
    const event = this.battlefieldEventDirector?.getActiveEvent(this.createBattlefieldEventContext());
    if (!event) {
      return undefined;
    }
    return {
      title: event.name,
      objective: event.objectiveLabel,
      progress: event.progressLabel,
      counterplay: event.counterplay,
      remainingSeconds: event.remainingSeconds,
      planMatched: event.planMatched
    };
  }

  private createLumeSiteSummaries() {
    if (!this.lumeNetworkDirector) {
      return undefined;
    }
    const entries = this.captureSites.flatMap((site) => {
      const summary = this.lumeNetworkDirector?.siteSummary(site);
      return summary ? [[site.definition.id, summary] as const] : [];
    });
    return Object.fromEntries(entries);
  }

  private renderLumeNetworkLinks(): void {
    if (!this.lumeNetworkDirector) {
      this.lumeLinkGraphics?.clear();
      this.previousLumeRenderStates = undefined;
      this.lumeRenderPulses.clear();
      this.lastLumeRenderSignature = "";
      return;
    }
    const state = this.lumeNetworkDirector.currentState();
    this.updateLumeRenderPulses(state);
    const snapshot = this.createLumeRenderSnapshot(state);
    const graphics = this.lumeLinkGraphics ?? this.add.graphics().setDepth(1.2);
    this.lumeLinkGraphics = graphics;
    const signature = createLumeRenderSnapshotSignature(snapshot);
    if (signature === this.lastLumeRenderSignature) {
      return;
    }
    this.lastLumeRenderSignature = signature;
    graphics.clear();
    snapshot.links.forEach((link) => {
      graphics.lineStyle(link.width, link.color, link.alpha);
      graphics.strokeLineShape(new Phaser.Geom.Line(link.from.x, link.from.y, link.to.x, link.to.y));
      const midpoint = { x: (link.from.x + link.to.x) / 2, y: (link.from.y + link.to.y) / 2 };
      if (link.emphasis === "pulse" || link.emphasis === "selected" || link.emphasis === "overlay") {
        graphics.fillStyle(link.color, Math.min(0.18, link.alpha * 0.25));
        graphics.fillCircle(midpoint.x, midpoint.y, 16);
      }
    });
    snapshot.siteMarkers.forEach((marker) => {
      graphics.lineStyle(3, marker.color, marker.alpha);
      graphics.strokeCircle(marker.position.x, marker.position.y, marker.radius);
      graphics.lineStyle(1, marker.color, Math.min(0.38, marker.alpha));
      graphics.strokeCircle(marker.position.x, marker.position.y, Math.max(12, marker.radius - 12));
    });
  }

  private createLumeRenderSnapshot(state = this.lumeNetworkDirector?.currentState()): LumeRenderSnapshot {
    if (!this.lumeNetworkDirector) {
      return { links: [], siteMarkers: [] };
    }
    if (!state) {
      return { links: [], siteMarkers: [] };
    }
    const siteById = new Map(this.captureSites.map((site) => [site.definition.id, site]));
    const pulse = 0.5 + Math.sin(this.runtime.elapsedSeconds * 4.2) * 0.5;
    const selectedSiteIds = this.selectionSystem
      ? this.selectionSystem
          .getSelected()
          .filter((entity): entity is CaptureSite => entity instanceof CaptureSite)
          .map((site) => site.definition.id)
      : [];
    const firstLinkId = state.links[0]?.id;
    const optionalLinkId = state.links[1]?.id;
    const siteVisuals = new Map<string, Pick<LumeRenderSiteMarkerSnapshot, "color" | "alpha" | "emphasis">>();
    const links = state.links.flatMap((link): LumeRenderLinkSnapshot[] => {
      const from = siteById.get(link.fromSiteId);
      const to = siteById.get(link.toSiteId);
      if (!from || !to) {
        return [];
      }
      const visual = resolveLumeLinkPresentation(link, {
        visibilityMode: this.lumeVisibilityMode,
        privateDemo: this.isPrivateLumeDemo(),
        objectiveCompleted: state.objectiveCompleted,
        selectedSiteIds,
        firstLinkId,
        optionalLinkId,
        pulse: this.lumeRenderPulses.get(link.id),
        elapsedSeconds: this.runtime.elapsedSeconds,
        pulsePhase: pulse
      });
      if (!visual.visible) {
        return [];
      }
      mergeSiteVisual(siteVisuals, link.fromSiteId, visual);
      mergeSiteVisual(siteVisuals, link.toSiteId, visual);
      return [
        {
          id: link.id,
          state: link.state,
          style: visual.style,
          emphasis: visual.emphasis,
          visible: visual.visible,
          fromSiteId: link.fromSiteId,
          toSiteId: link.toSiteId,
          from: { ...from.position },
          to: { ...to.position },
          color: visual.color,
          alpha: visual.alpha,
          width: visual.width,
          pulseKind: visual.pulseKind,
          layerDepth: 1.2
        }
      ];
    });
    const siteMarkers = [...siteVisuals.entries()].flatMap(([siteId, visual]): LumeRenderSiteMarkerSnapshot[] => {
      const site = siteById.get(siteId);
      if (!site) {
        return [];
      }
      const touchingLinks = links.filter((link) => link.fromSiteId === siteId || link.toSiteId === siteId);
      const linkState = touchingLinks.some((link) => link.state === "active")
        ? "active"
        : touchingLinks.some((link) => link.state === "contested")
          ? "contested"
          : touchingLinks.some((link) => link.state === "severed")
            ? "severed"
            : "inactive";
      return [
        {
          siteId,
          state: linkState,
          emphasis: visual.emphasis,
          position: { ...site.position },
          radius: site.definition.radius + 9,
          color: visual.color,
          alpha: visual.alpha,
          layerDepth: 1.2
        }
      ];
    });
    return { links, siteMarkers };
  }

  private updateLumeRenderPulses(state: ReturnType<NonNullable<BattleSceneSystems["lumeNetworkDirector"]>["currentState"]>): void {
    const currentStates = new Map(state.links.map((link) => [link.id, link.state]));
    if (this.previousLumeRenderStates) {
      state.links.forEach((link) => {
        const previous = this.previousLumeRenderStates?.get(link.id);
        if (!previous || previous === link.state) {
          return;
        }
        this.lumeRenderPulses.set(link.id, {
          kind: lumePulseKind(previous, link.state, state.lifetimeSeveredLinkIds.includes(link.id)),
          startedAtSeconds: this.runtime.elapsedSeconds,
          durationSeconds: 2.8
        });
      });
    }
    [...this.lumeRenderPulses.entries()].forEach(([linkId, renderPulse]) => {
      if (this.runtime.elapsedSeconds - renderPulse.startedAtSeconds > renderPulse.durationSeconds) {
        this.lumeRenderPulses.delete(linkId);
      }
    });
    this.previousLumeRenderStates = currentStates;
  }

  private createEmptyPerformanceCounters() {
    return {
      fogRedraws: 0,
      minimapRefreshes: 0,
      hudUpdates: 0,
      notificationsEmitted: 0
    };
  }

  private createPrivatePerformanceCounters(): Partial<PrivatePerformanceCounters> {
    const lume = this.lumeNetworkDirector ? this.createLumeRenderSnapshot() : { links: [], siteMarkers: [] };
    const fogVisibleCells = this.fogOfWar
      ? Array.from(this.fogOfWar.states).filter((value) => value === 2).length
      : 0;
    const textObjects = this.children.list.filter((entry) => entry instanceof Phaser.GameObjects.Text);
    const domNodes = typeof document === "undefined" ? 0 : document.querySelectorAll("*").length;
    const memory = (performance as Performance & { memory?: { usedJSHeapSize?: number } }).memory?.usedJSHeapSize;
    return {
      displayObjects: this.children.list.length,
      graphicsObjects: this.children.list.filter((entry) => entry instanceof Phaser.GameObjects.Graphics).length,
      units: this.units.filter((unit) => unit.alive).length,
      buildings: this.buildings.filter((building) => building.alive).length,
      captureSites: this.captureSites.length,
      labels: textObjects.filter((entry) => entry.visible).length,
      totalLabels: textObjects.length,
      captureRings: this.captureSites.length,
      lumeLinks: lume.links.length,
      lumeEndpoints: lume.siteMarkers.length,
      fogRedraws: this.performanceCounters.fogRedraws,
      fogVisibleCells,
      minimapRefreshes: this.performanceCounters.minimapRefreshes,
      hudUpdates: this.performanceCounters.hudUpdates,
      notificationsEmitted: this.performanceCounters.notificationsEmitted,
      notificationsVisible: this.statusTimer > 0 ? 1 : 0,
      domNodes,
      ...(memory === undefined ? {} : { memoryUsedMb: Number((memory / 1024 / 1024).toFixed(2)) })
    };
  }

  private createBattleLoopCountSnapshot(): BattleLoopCountSnapshot {
    const textObjects = this.children.list.filter((entry) => entry instanceof Phaser.GameObjects.Text);
    return {
      displayObjects: this.children.list.length,
      graphicsObjects: this.children.list.filter((entry) => entry instanceof Phaser.GameObjects.Graphics).length,
      units: this.units.filter((unit) => unit.alive).length,
      buildings: this.buildings.filter((building) => building.alive).length,
      captureSites: this.captureSites.length,
      projectiles: this.projectiles.filter((projectile) => projectile.alive).length,
      labels: textObjects.filter((entry) => entry.visible).length,
      domNodes: typeof document === "undefined" ? 0 : document.querySelectorAll("*").length
    };
  }

  private selectTrustedBenchmarkTarget(target: "hero" | "worker" | "building"): { x: number; y: number; label: string } | null {
    if (!this.canUseTrustedBenchmarkDiagnostics()) {
      return null;
    }
    const entity =
      target === "hero"
        ? this.hero
        : target === "worker"
          ? this.units.find((unit) => unit.alive && unit.team === "player" && unit.definition.id === "worker")
          : this.findBuilding("barracks", "player") ?? this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player");
    if (!entity) {
      return null;
    }
    this.selectionSystem.setSelection([entity]);
    this.cameraSystem.centerOn(entity.position);
    this.showCommandFeedbackMarker({ kind: "focus", point: entity.position, label: trustedDiagnosticValueLabel(target) });
    this.refreshBattleHud(0);
    return {
      x: entity.position.x,
      y: entity.position.y,
      label: target === "hero" ? "Aster" : entity.definition.name
    };
  }

  private selectedEntities(): Array<Unit | Building | CaptureSite> {
    return this.selectionSystem
      .getSelected()
      .filter((entity): entity is Unit | Building | CaptureSite => entity instanceof Unit || entity instanceof Building || entity instanceof CaptureSite);
  }

  private initialPlayerSelection(): Unit[] {
    if (this.launch.request.mode === "tutorial") {
      return [];
    }
    const playerUnits = this.units.filter((unit) => unit.alive && unit.team === "player");
    return playerUnits.length > 0 ? playerUnits : [this.hero];
  }

  private applyPrivatePlaytestHubScenarioSetup(): void {
    const scenarioId = this.launch.request.privatePlaytestHubScenarioId;
    if (!scenarioId) {
      return;
    }
    this.hudDensityMode = normalizeHudDensityMode(hudDensityModeForPrivateScenario(scenarioId), isPrivatePlaytestToolsEnabled());

    this.showMessage(PRIVATE_PLAYTEST_HUB_NOTICE, undefined, undefined, "#74d3f2", {
      priority: "important",
      durationSeconds: 5
    });

    const commandHall = this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player");
    const battleLoopScenario = V0110_BATTLE_LOOP_SCENARIOS.find((entry) => entry.id === scenarioId);
    let representativeBenchmarkHandled = false;
    if (scenarioId.startsWith("benchmark_battle")) {
      representativeBenchmarkHandled = this.applyRepresentativeBattleBenchmarkSetup(scenarioId, commandHall);
    } else if (battleLoopScenario?.launchScenarioId.startsWith("benchmark_battle")) {
      representativeBenchmarkHandled = this.applyRepresentativeBattleBenchmarkSetup(battleLoopScenario.launchScenarioId, commandHall);
    }

    const selectedHeroScenarios = new Set(["battle_selected_hero", "salto_outskirts_start", "perf_selected_hero", "perf_hud_minimal", "perf_hud_standard", "perf_hud_debug", "art_slot_unit_fallback", "art_slot_hud_fallback", "art_slot_mock_routing"]);
    const selectedWorkerScenarios = new Set(["battle_selected_worker", "perf_selected_worker", "perf_hud_minimal_worker"]);
    const selectedSquadScenarios = new Set(["battle_selected_squad", "perf_selected_squad", "perf_large_unit_cluster"]);
    const selectedBuildingScenarios = new Set(["battle_selected_building", "perf_selected_command_hall", "art_slot_building_fallback"]);
    const sitePressureScenarios = new Set(["battle_contested_site", "perf_label_heavy_site_cluster"]);
    const fogScenarios = new Set(["battle_fog_minimap", "perf_fog_heavy_camera", "perf_minimap_interaction", "art_slot_battlefield_terrain_fallback"]);
    const notificationScenarios = new Set(["battle_notification_priority", "perf_notification_heavy"]);
    let playerUnits = this.units.filter((unit) => unit.alive && unit.team === "player");
    let worker = playerUnits.find((unit) => unit.definition.id === "worker");
    if (selectedWorkerScenarios.has(scenarioId) && !worker) {
      const anchor = commandHall?.position ?? this.hero.position;
      worker = new Unit(this, requireUnit("worker"), "player", anchor.x + 72, anchor.y + 42, { id: "private-hub-worker" });
      this.addUnit(worker);
      playerUnits = this.units.filter((unit) => unit.alive && unit.team === "player");
    }
    const focusSite =
      this.captureSites.find((site) => site.definition.id === "west_stone_cut") ??
      this.captureSites.find((site) => site.definition.id === "crown_shrine") ??
      this.captureSites[0];

    if (representativeBenchmarkHandled) {
      playerUnits = this.units.filter((unit) => unit.alive && unit.team === "player");
    } else if (selectedHeroScenarios.has(scenarioId)) {
      this.selectAndFocusPrivatePreview([this.hero], "Hero selected for private review.");
    } else if (selectedWorkerScenarios.has(scenarioId) && worker) {
      this.selectAndFocusPrivatePreview([worker], "Worker selected for private review.");
    } else if (selectedSquadScenarios.has(scenarioId)) {
      const squad = this.ensurePrivatePerformanceSquad(playerUnits, commandHall).filter((unit) => unit.definition.id !== "worker").slice(0, 8);
      this.selectAndFocusPrivatePreview(squad.length > 0 ? squad : playerUnits.slice(0, 4), "Squad selected for private review.");
    } else if (selectedBuildingScenarios.has(scenarioId) && commandHall) {
      this.selectAndFocusPrivatePreview([commandHall], "Command Hall selected for private review.");
    } else if (sitePressureScenarios.has(scenarioId) && focusSite) {
      focusSite.capturingTeam = "enemy";
      focusSite.captureProgress = 0.58;
      focusSite.setObjectiveRelevant(true);
      focusSite.updateVisuals();
      this.selectAndFocusPrivatePreview([focusSite], "Resource site pressure preview.");
    } else if (fogScenarios.has(scenarioId)) {
      const point = { x: this.activeMap.width * 0.5, y: this.activeMap.height * 0.48 };
      this.cameraSystem.centerOn(point);
      this.addMinimapPing(point.x, point.y, "#74d3f2", "Fog/minimap sample");
      this.showCommandFeedbackMarker({ kind: "focus", point, label: "Minimap" });
      this.showMessage("Fog and minimap sample centered.", point.x, point.y - 42, "#74d3f2", { priority: "command" });
    } else if (notificationScenarios.has(scenarioId)) {
      this.showMessage("Critical: protect Workers and resource sites.", this.hero.position.x, this.hero.position.y - 96, "#ffd27a", {
        priority: "critical",
        durationSeconds: 5
      });
    }

    if (scenarioId.startsWith("lume") || scenarioId.startsWith("perf_lume") || scenarioId.startsWith("art_slot_lume") || scenarioId.startsWith("benchmark_battle")) {
      this.applyPrivateLumeScenarioSetup(scenarioId);
    }
    if (battleLoopScenario?.launchScenarioId.startsWith("benchmark_battle")) {
      this.applyPrivateLumeScenarioSetup(battleLoopScenario.launchScenarioId);
    }
    const battleLoopDiagnostics = battleLoopDiagnosticsForScenario(scenarioId);
    if (battleLoopDiagnostics) {
      this.setBattleLoopDiagnostics(battleLoopDiagnostics);
      this.showMessage(`v0.110 phase profile: ${battleLoopScenario?.title ?? scenarioId}`, undefined, undefined, "#74d3f2", {
        priority: "command",
        durationSeconds: 5
      });
    }

    this.refreshBattleHud(0);
  }

  private ensurePrivatePerformanceSquad(playerUnits: Unit[], commandHall?: Building): Unit[] {
    const combatUnits = playerUnits.filter((unit) => unit !== this.hero && unit.definition.id !== "worker");
    if (combatUnits.length >= 6) {
      return playerUnits;
    }
    const anchor = commandHall?.position ?? this.hero.position;
    const unitTypeIds = ["militia", "ranger", "acolyte", "militia", "ranger", "acolyte"] as const;
    const needed = 6 - combatUnits.length;
    for (let index = 0; index < needed; index += 1) {
      const angle = (index / Math.max(1, needed)) * Math.PI * 2;
      const radius = 72 + index * 8;
      const unit = new Unit(this, requireUnit(unitTypeIds[index % unitTypeIds.length]), "player", anchor.x + Math.cos(angle) * radius, anchor.y + Math.sin(angle) * radius, {
        id: `private-perf-squad-${index + 1}`
      });
      this.addUnit(unit);
    }
    return this.units.filter((unit) => unit.alive && unit.team === "player");
  }

  private applyRepresentativeBattleBenchmarkSetup(scenarioId: string, commandHall?: Building): boolean {
    const profile = representativeBattleTierForScenario(scenarioId);
    const playerAnchor = commandHall?.position ?? this.hero.position;
    const playerBarracks = this.ensurePrivateBenchmarkBarracks(playerAnchor);
    const worker = this.ensurePrivateBenchmarkUnits("worker", "player", profile.player.workers, playerAnchor, "worker", 58)[0];
    const militia = this.ensurePrivateBenchmarkUnits("militia", "player", profile.player.militia, playerAnchor, "militia", 96);
    const rangers = this.ensurePrivateBenchmarkUnits("ranger", "player", profile.player.rangers, playerAnchor, "ranger", 132);
    const enemyAnchor = this.findBuilding(this.activeMap.scenario.objectives.enemyBaseBuildingId, "enemy")?.position ?? {
      x: this.activeMap.enemyStart.x,
      y: this.activeMap.enemyStart.y
    };
    this.ensurePrivateBenchmarkUnits("raider", "enemy", profile.enemy.raiders, enemyAnchor, "raider", 108);
    this.ensurePrivateBenchmarkUnits("hexer", "enemy", profile.enemy.hexers, enemyAnchor, "hexer", 148);
    this.ensurePrivateBenchmarkUnits("brute", "enemy", profile.enemy.brutes, enemyAnchor, "brute", 188);
    this.ensurePrivateBenchmarkUnits("enemy_commander", "enemy", profile.enemy.commanders, enemyAnchor, "commander", 220);

    const mineSite = this.captureSites.find((site) => site.definition.id === profile.siteInfrastructure.mineEquivalentSiteId);
    const shrineSite = this.captureSites.find((site) => site.definition.id === profile.siteInfrastructure.shrineEquivalentSiteId);
    if (mineSite) {
      mineSite.setOwner("player");
      mineSite.setObjectiveRelevant(true);
      mineSite.updateVisuals();
    }
    if (shrineSite) {
      shrineSite.setOwner("player");
      shrineSite.setObjectiveRelevant(true);
      shrineSite.updateVisuals();
    }
    this.lumeNetworkDirector?.update();
    this.renderLumeNetworkLinks();

    this.stageRepresentativeBenchmarkPressure(profile.pressure.nearbyEnemyCount, shrineSite ?? mineSite);
    const playerSelection = [this.hero, worker, ...militia.slice(0, 5), ...rangers.slice(0, 4)].filter(
      (entity): entity is Unit | Hero => Boolean(entity)
    );

    if (scenarioId === "benchmark_battle_lume_hidden") {
      this.lumeVisibilityMode = "hidden";
    } else if (scenarioId === "benchmark_battle_lume_always") {
      this.lumeVisibilityMode = "always";
    } else {
      this.lumeVisibilityMode = "auto";
    }

    if (scenarioId === "benchmark_battle_fog_heavy") {
      const point = { x: this.activeMap.width * 0.48, y: this.activeMap.height * 0.48 };
      this.cameraSystem.centerOn(point);
      this.addMinimapPing(point.x, point.y, "#74d3f2", "Benchmark fog");
      this.showCommandFeedbackMarker({ kind: "focus", point, label: "Fog" });
      this.showMessage("Representative benchmark: fog-heavy posture.", point.x, point.y - 42, "#74d3f2", {
        priority: "command"
      });
      return true;
    }

    if (scenarioId === "benchmark_battle_notification_heavy") {
      this.showMessage("Critical: Ashen pressure approaching the Lume link.", this.hero.position.x, this.hero.position.y - 96, "#ffd27a", {
        priority: "critical",
        durationSeconds: 5
      });
      this.showMessage("Routine: hold Worker, Barracks, mine, and shrine posture.", this.hero.position.x + 40, this.hero.position.y - 56, "#74d3f2", {
        priority: "routine",
        durationSeconds: 5
      });
    }

    if (scenarioId === "benchmark_battle_minimap_interaction") {
      const focus = shrineSite?.position ?? mineSite?.position ?? playerAnchor;
      this.cameraSystem.centerOn(focus);
      this.addMinimapPing(focus.x, focus.y, "#74d3f2", "Benchmark minimap");
      this.showCommandFeedbackMarker({ kind: "focus", point: focus, label: "Minimap" });
      this.selectAndFocusPrivatePreview([playerBarracks], "Representative benchmark minimap and Barracks focus.");
      return true;
    }

    if (scenarioId === "benchmark_battle_results_transition") {
      this.selectAndFocusPrivatePreview(playerSelection, "Representative benchmark Results transition setup.");
      return true;
    }

    this.selectAndFocusPrivatePreview(playerSelection, `Representative benchmark ${profile.label}.`);
    return true;
  }

  private ensurePrivateBenchmarkBarracks(anchor: Position): Building {
    const existing = this.findBuilding("barracks", "player");
    if (existing) {
      return existing;
    }
    const barracks = new Building(this, requireBuilding("barracks"), "player", anchor.x + 150, anchor.y - 88, {
      constructionState: "completed",
      constructionProgress: 1
    });
    this.addBuilding(barracks);
    return barracks;
  }

  private ensurePrivateBenchmarkUnits(
    unitId: string,
    team: Team,
    desiredCount: number,
    anchor: Position,
    idPrefix: string,
    radius: number
  ): Unit[] {
    const existing = this.units.filter((unit) => unit.alive && unit.team === team && unit.definition.id === unitId);
    const missing = Math.max(0, desiredCount - existing.length);
    for (let index = 0; index < missing; index += 1) {
      const sequence = existing.length + index + 1;
      const angle = (sequence / Math.max(1, desiredCount)) * Math.PI * 2;
      const unit = new Unit(
        this,
        requireUnit(unitId),
        team,
        anchor.x + Math.cos(angle) * radius,
        anchor.y + Math.sin(angle) * radius,
        { id: `private-benchmark-${idPrefix}-${sequence}` }
      );
      this.addUnit(unit);
    }
    return this.units.filter((unit) => unit.alive && unit.team === team && unit.definition.id === unitId);
  }

  private stageRepresentativeBenchmarkPressure(nearbyEnemyCount: number, focusSite?: CaptureSite): void {
    const focus = focusSite?.position ?? { x: this.hero.position.x + 520, y: this.hero.position.y - 220 };
    const enemies = this.units.filter((unit) => unit.alive && unit.team === "enemy").slice(0, nearbyEnemyCount);
    enemies.forEach((unit, index) => {
      const angle = (index / Math.max(1, enemies.length)) * Math.PI * 2;
      const radius = 110 + (index % 3) * 34;
      unit.setPosition(focus.x + Math.cos(angle) * radius, focus.y + Math.sin(angle) * radius);
      unit.moveTarget = undefined;
      unit.attackTargetId = undefined;
      unit.attackMove = false;
    });
    if (focusSite) {
      focusSite.capturingTeam = "enemy";
      focusSite.captureProgress = Math.max(focusSite.captureProgress, 0.35);
      focusSite.updateVisuals();
    }
  }

  private applyPrivateLumeScenarioSetup(scenarioId: string): void {
    const westStoneCut = this.captureSites.find((site) => site.definition.id === "west_stone_cut");
    const fordToll = this.captureSites.find((site) => site.definition.id === "ford_toll");
    const firstLinkScenario = scenarioId === "lume_first_link" || scenarioId === "perf_lume_activation_pulse";

    if (firstLinkScenario && westStoneCut && fordToll) {
      westStoneCut.setOwner("player");
      fordToll.setOwner("player");
      westStoneCut.setObjectiveRelevant(true);
      fordToll.setObjectiveRelevant(true);
      this.lumeNetworkDirector?.update();
      this.renderLumeNetworkLinks();
      const point = {
        x: (westStoneCut.position.x + fordToll.position.x) / 2,
        y: (westStoneCut.position.y + fordToll.position.y) / 2
      };
      this.cameraSystem.centerOn(point);
      this.addMinimapPing(point.x, point.y, "#74d3f2", "First Lume link");
      this.showCommandFeedbackMarker({ kind: "focus", point, label: "Lume Link" });
      return;
    }

    if (scenarioId === "perf_lume_contested_severed" && westStoneCut && fordToll) {
      westStoneCut.setOwner("player");
      fordToll.setOwner("player");
      westStoneCut.setObjectiveRelevant(true);
      fordToll.setObjectiveRelevant(true);
      this.lumeNetworkDirector?.update();
      fordToll.setOwner("enemy");
      fordToll.capturingTeam = "enemy";
      fordToll.captureProgress = 0;
      fordToll.updateVisuals();
      this.lumeNetworkDirector?.update();
      const point = {
        x: (westStoneCut.position.x + fordToll.position.x) / 2,
        y: (westStoneCut.position.y + fordToll.position.y) / 2
      };
      this.cameraSystem.centerOn(point);
      this.addMinimapPing(point.x, point.y, "#e6635a", "Lume severed");
      this.showCommandFeedbackMarker({ kind: "attack", point, label: "Severed" });
      this.renderLumeNetworkLinks();
      return;
    }

    if (scenarioId === "lume_overlay_hidden" || scenarioId === "perf_lume_hidden" || scenarioId === "benchmark_battle_lume_hidden") {
      this.lumeVisibilityMode = "hidden";
    }
    if (scenarioId === "lume_overlay_always" || scenarioId === "perf_lume_always" || scenarioId === "benchmark_battle_lume_always") {
      this.lumeVisibilityMode = "always";
    }
    if (scenarioId === "lume_overlay_auto" || scenarioId === "perf_lume_auto" || scenarioId === "benchmark_battle_lume_auto") {
      this.lumeVisibilityMode = "auto";
    }

    const focusSite = westStoneCut ?? fordToll ?? this.captureSites[0];
    if (focusSite) {
      this.cameraSystem.centerOn(focusSite.position);
      this.addMinimapPing(focusSite.position.x, focusSite.position.y, "#74d3f2", "Lume preview");
    }
    this.lumeNetworkDirector?.update();
    this.renderLumeNetworkLinks();
  }

  private selectAndFocusPrivatePreview(entities: Array<Unit | Building | CaptureSite>, message: string): void {
    const aliveEntities = entities.filter((entity) => entity.alive);
    if (aliveEntities.length === 0) {
      return;
    }
    this.selectionSystem.setSelection(aliveEntities);
    const focus = aliveEntities[0];
    this.cameraSystem.centerOn(focus.position);
    this.addMinimapPing(focus.position.x, focus.position.y, "#74d3f2", "Playtest focus");
    this.showCommandFeedbackMarker({ kind: "focus", point: focus.position, label: "Review" });
    this.showMessage(message, focus.position.x, focus.position.y - 78, "#74d3f2", { priority: "command" });
  }

  private playSelectionAudio(selected: Array<Unit | Building | CaptureSite>): void {
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
          showDamageFeedback(this, entity, actual, { threshold: 1 });
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
    if (killer instanceof Unit && killer.enemyHeroId && target.team === "player") {
      this.runtime.recordEnemyHeroPressure(killer.enemyHeroId, killer.enemyHeroName);
    }
    if (target.team !== "player") {
      if (target instanceof Building) {
        this.runtime.recordBuildingDestroyed();
        this.enemyPressureRuntime?.recordPlayerDestroyedStructure(target.definition.id);
        this.completeSecondaryObjective("destroy_building", target.definition.id, target.position);
      } else if (target instanceof Unit) {
        this.runtime.recordUnitKilled();
        this.completeSecondaryObjective("defeat_unit", target.definition.id, target.position);
        if (this.launch.request.mode === "tutorial") {
          this.tutorialDefeatedUnitIds.add(target.definition.id);
        }
        if (target.enemyHeroId) {
          this.runtime.recordEnemyHeroDefeated(target.enemyHeroId, target.enemyHeroName, this.runtime.elapsedSeconds);
          this.enemyPressureRuntime?.recordEnemyHeroDefeated(target.enemyHeroId);
        }
        if (target.enemyEliteSquadId) {
          this.runtime.recordEnemyEliteUnitDefeated(target.enemyEliteSquadId);
          this.showMessage(
            `${target.enemyEliteSquadName ?? target.enemyEliteSquadLabel ?? "Elite squad"} defeated`,
            target.position.x,
            target.position.y - 58,
            "#f6e27d",
            { priority: "objective" }
          );
        }
      }
    }
    if (!this.launch.request.rewardsDisabled && target.team !== "player" && killer instanceof Unit && this.isUnitVeterancyEligible(killer)) {
      killer.veterancy = recordUnitVeterancyKill(killer.veterancy);
      const xpValue = target instanceof Unit || target instanceof Building ? target.definition.xpValue : 0;
      this.awardUnitVeterancyXp(killer, getUnitVeterancyXpForKill(xpValue));
    }
    if (!this.launch.request.rewardsDisabled) {
      this.xpSystem.awardForKill(killer, target);
    }
  }

  private applyEnemyHeroDamage(source: Unit, target: BaseEntity, amount: number): void {
    const wasAlive = target.alive;
    const actual = target.takeDamage(amount);
    if (actual > 0) {
      showDamageFeedback(this, target, actual);
      this.warnIfCommandHallUnderAttack(target);
      this.handleUnitDamage(source, target, actual);
    }
    if (wasAlive && !target.alive) {
      this.handleKill(source, target);
      target.destroyView();
    }
  }

  private handleUnitDamage(source: Unit, target: BaseEntity, amount: number): void {
    if (!this.isUnitVeterancyEligible(source) || target.team === "player") {
      return;
    }
    source.veterancy = recordUnitVeterancyDamage(source.veterancy, amount);
    this.awardUnitVeterancyXp(source, getUnitVeterancyXpForDamage(amount));
  }

  private enemyHeroUnits(): Unit[] {
    return this.units.filter((unit) => unit.alive && unit.enemyHeroId);
  }

  private handleEnemyHeroVisible(unit: Unit): void {
    if (!unit.enemyHeroId || this.scoutedEnemyHeroIds.has(unit.enemyHeroId)) {
      return;
    }
    this.scoutedEnemyHeroIds.add(unit.enemyHeroId);
    this.runtime.recordEnemyHeroPresence(unit.enemyHeroId, unit.enemyHeroName);
    const name = unit.enemyHeroName ?? unit.definition.name;
    const title = unit.enemyHeroTitle ?? unit.definition.role;
    this.addMinimapPing(unit.position.x, unit.position.y, "#ff9a64", `Enemy commander: ${name}`);
    this.showMessage(`Enemy commander sighted: ${name}, ${title}`, unit.position.x, unit.position.y - 72, "#ff9a64");
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
    if (!this.shouldRefreshBattleHud(deltaSeconds)) {
      return;
    }
    this.performanceCounters.hudUpdates += 1;
    const selected = this.selectedEntities();
    this.playSelectionAudio(selected);
    const isPlacing = Boolean(this.buildingSystem.pendingBuildingId);
    const placementStatus =
      this.buildingSystem.placementMessage || "Click valid ground near your base to place the building.";
    this.uiSystem.update(deltaSeconds, {
      resources: this.resources.player,
      hero: this.hero,
      selected,
      elapsedSeconds: this.runtime.elapsedSeconds,
      isPlacing,
      status: isPlacing ? placementStatus : this.statusMessage,
      statusCategory: isPlacing ? "routine" : battleStatusCategory(this.statusPriority),
      hint: isPlacing ? "" : this.tutorialHint,
      tutorial: this.createTutorialStepSnapshot(),
      techState: this.getTechState("player"),
      repairTargets: this.repairSystem.repairTargetSummaries(),
      resourceSites: this.resourceSystem.resourceSiteSummaries(this.captureSites),
      minimap: this.createMinimapSnapshot(),
      objectives: this.createObjectiveSnapshot(),
      battlefieldEvent: this.createBattlefieldEventSnapshot(),
      lumeNetwork: this.lumeNetworkDirector?.hudSummary({
        privateDemo: this.isPrivateLumeDemo(),
        visibilityMode: this.lumeVisibilityMode
      }),
      lumeSiteSummaries: this.createLumeSiteSummaries(),
      privatePlaytestNotice: this.launch.request.privatePlaytestNotice,
      privatePlaytestHub: this.isPrivatePlaytestHubPreview(),
      controlGroups: this.controlGroupSystem.summaries(this.units),
      enemyDoctrine: this.createEnemyDoctrineSnapshot(),
      retinueReinforcement: this.createRetinueReinforcementSnapshot(),
      hudDensity: this.hudDensityMode,
      hudDensityControls: createHudDensityControls(this.hudDensityMode, this.canUsePrivateHudDensityControls()),
      hudDebugCounters: shouldRenderHudDebugCounters(this.hudDensityMode, this.canUsePrivateHudDensityControls())
        ? this.createPrivatePerformanceCounters()
        : undefined,
      pauseMenu: this.menuPaused
        ? {
            visible: true,
            title: "Paused",
            description: "Battle simulation is paused. Resume when ready, or exit to the main menu after confirming this is what you want.",
            includeLumeHelp: Boolean(this.lumeNetworkDirector)
          }
        : undefined
    });
  }

  private shouldRefreshBattleHud(deltaSeconds: number): boolean {
    if (deltaSeconds <= 0) {
      this.hudRefreshAccumulatorSeconds = 0;
      return true;
    }
    this.hudRefreshAccumulatorSeconds += deltaSeconds;
    if (this.hudRefreshAccumulatorSeconds < BATTLE_HUD_REFRESH_INTERVAL_SECONDS) {
      return false;
    }
    this.hudRefreshAccumulatorSeconds = 0;
    return true;
  }

  private openBattleMenu(): void {
    if (this.runtime.ended) {
      return;
    }
    this.menuPaused = true;
    this.statusMessage = "Paused";
    this.statusTimer = 60;
    this.statusPriority = "command";
    this.refreshBattleHud(0);
  }

  private resumeBattle(): void {
    if (!this.menuPaused) {
      return;
    }
    this.menuPaused = false;
    this.showMessage("Resumed", undefined, undefined, "#d9eee8", { priority: "command" });
    this.refreshBattleHud(0);
  }

  private exitToMainMenu(): void {
    this.menuPaused = false;
    this.scene.start(SCENE_KEYS.mainMenu);
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
    this.updateAct1Finale();
    this.finalizeBattlefieldEventForResults(outcome);
    this.lumeNetworkDirector?.update();
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
    this.runtime.recordRetinueSurvivorHealth(
      this.units
        .filter((unit) => unit.alive && unit.retinueUnitId)
        .map((unit) => ({
          retinueUnitId: unit.retinueUnitId!,
          hpRatio: unit.maxHp > 0 ? unit.hp / unit.maxHp : 0
        }))
    );
  }

  private createEnemyDoctrineSnapshot() {
    if (!this.enemyDoctrine) {
      return undefined;
    }
    const eliteSquadIds = this.runtime.stats.enemyEliteSquadIds ?? [];
    const eliteNames = eliteSquadIds
      .map((squadId) => ENEMY_ELITE_SQUAD_BY_ID[squadId]?.name ?? ENEMY_ELITE_SQUAD_BY_ID[squadId]?.shortLabel ?? squadId)
      .filter((name, index, names) => names.indexOf(name) === index);
    return {
      name: this.enemyDoctrine.name,
      status: this.enemyDoctrine.statusLabel,
      warning: this.enemyDoctrine.threatWarning,
      counterplay: this.enemyDoctrine.counterplay,
      elite: eliteNames.length > 0 ? eliteNames.join(", ") : undefined
    };
  }

  private createRetinueReinforcementSnapshot() {
    if (this.launch.request.mode !== "campaign_node" || this.launch.request.rewardsDisabled) {
      return undefined;
    }
    const availability = evaluateRetinueReinforcement({
      mode: this.launch.request.mode,
      rewardsDisabled: this.launch.request.rewardsDisabled,
      alreadyUsed: this.retinueReinforcementUsed,
      commandHallAlive: Boolean(this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player")),
      resources: this.resources.player,
      reserveUnits: this.launch.request.retinueReserveUnits ?? [],
      modifiers: this.launch.request.modifiers
    });
    return {
      available: availability.ok,
      reason: availability.reason,
      cost: availability.cost,
      reserveCount: availability.reserveCount,
      readyReserveCount: availability.readyReserveCount,
      used: availability.used
    };
  }

  private canEnemyHeroJoinAttack(unit: Unit): boolean {
    if (!unit.enemyHeroId || !this.act1FinaleDirector) {
      return true;
    }
    return this.act1FinaleDirector.isCommanderReleased;
  }

  private callRetinueReinforcement(): boolean {
    const reserveUnits = this.launch.request.retinueReserveUnits ?? [];
    const commandHall = this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player");
    const availability = evaluateRetinueReinforcement({
      mode: this.launch.request.mode,
      rewardsDisabled: this.launch.request.rewardsDisabled,
      alreadyUsed: this.retinueReinforcementUsed,
      commandHallAlive: Boolean(commandHall),
      resources: this.resources.player,
      reserveUnits,
      modifiers: this.launch.request.modifiers
    });
    if (!availability.ok || !commandHall) {
      this.showMessage(`Call Retinue unavailable: ${availability.reason ?? "Unavailable"}`, undefined, undefined, "#ffd27a", {
        priority: "command"
      });
      return false;
    }
    const retinueUnit = selectRetinueReinforcementUnit(reserveUnits);
    if (!retinueUnit) {
      this.showMessage("Call Retinue unavailable: no Ready reserve.", undefined, undefined, "#ffd27a", {
        priority: "command"
      });
      return false;
    }
    if (!payCost(this.resources.player, availability.cost)) {
      this.showMessage("Call Retinue unavailable: insufficient Crowns.", undefined, undefined, "#ffd27a", {
        priority: "command"
      });
      return false;
    }
    const definition = requireUnit(retinueUnit.unitTypeId);
    const preferredPoint = {
      x: commandHall.position.x + commandHall.radius + definition.radius + 24,
      y: commandHall.position.y
    };
    const spawnPoint = findWalkableTrainedUnitSpawnPoint({
      building: commandHall,
      unitDefinition: definition,
      preferredPoint,
      spawnIndex: this.units.length,
      map: this.activeMap,
      buildings: this.buildings
    });
    const unit = spawnRetinueUnitFromSave({
      scene: this,
      addUnit: (entry) => this.addUnit(entry),
      retinueUnit,
      x: spawnPoint.x,
      y: spawnPoint.y
    });
    this.retinueReinforcementUsed = true;
    this.runtime.recordRetinueReinforcement(retinueUnit.retinueUnitId);
    this.selectionSystem.setSelection([unit]);
    this.addMinimapPing(unit.position.x, unit.position.y, "#9cf7b1", "Retinue reinforcement");
    this.showMessage(
      `Retinue reinforcement arrived: ${formatRetinueDeploymentLabel(retinueUnit)}`,
      unit.position.x,
      unit.position.y - 42,
      "#d9eee8",
      { priority: "command" }
    );
    this.refreshBattleHud(0);
    return true;
  }

  private castAbilitySlot(slot: number): void {
    const abilityId = this.hero.unlockedAbilities[slot];
    if (!abilityId) {
      this.showMessage("No ability in that slot");
      return;
    }
    if (this.abilitySystem.castAbility(this.hero, abilityId, this.selectionSystem.getSelected())) {
      AudioManager.play("ability_cast");
      this.refreshBattleHud(0);
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
    if (team === "enemy") {
      return {
        completedBuildingIds: completedEnemyTechBuildingIds(this.buildings),
        researchedUpgradeIds,
        heroLevel: this.hero?.level ?? 1
      };
    }
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
    this.buildings
      .filter((building) => building.alive && building.team === team)
      .forEach((building) => applyUpgradeToBuilding(building, upgrade));
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

  private applyResearchedUpgradesToBuilding(building: Building): void {
    if (building.team !== "player" && building.team !== "enemy") {
      return;
    }
    this.researchedUpgradeIds[building.team].forEach((upgradeId) => {
      const upgrade = UPGRADE_BY_ID[upgradeId];
      if (upgrade) {
        applyUpgradeToBuilding(building, upgrade);
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
      showMessage: (message, x, y, color, options) => this.showMessage(message, x, y, color, options)
    });
  }

  private updateBattlefieldEvents(deltaSeconds: number): void {
    const result = this.battlefieldEventDirector?.update(deltaSeconds, this.createBattlefieldEventContext());
    if (!result || result.transitions.length === 0) {
      return;
    }
    this.applyBattlefieldEventTransitions(result.transitions);
  }

  private updateAct1Finale(): void {
    if (!this.act1FinaleDirector) {
      return;
    }
    const result = this.act1FinaleDirector.update(this.createAct1FinaleContext());
    if (result.transitions.length === 0) {
      return;
    }
    this.applyAct1FinaleTransitions(result.transitions);
  }

  private createAct1FinaleContext(): Act1FinaleDirectorContext {
    const playerOwnedSiteCount = this.captureSites.filter((site) => site.alive && site.owner === "player").length;
    const enemyProductionId = this.activeMap.scenario.enemyAI.productionBuildingId;
    return {
      elapsedSeconds: this.runtime.elapsedSeconds,
      tacticalPlanId: this.launch.request.tacticalPlanId,
      completedObjectiveIds: this.runtime.stats.completedObjectiveIds,
      resourcesCaptured: this.runtime.stats.resourcesCaptured,
      playerOwnedSiteCount,
      enemyProductionAlive: this.buildings.some(
        (building) => building.alive && building.team === "enemy" && building.definition.id === enemyProductionId
      ),
      enemyCommanderAlive: this.enemyHeroUnits().some((unit) => unit.enemyHeroId === this.launch.request.enemyHeroId),
      enemyCommanderDefeated: Boolean(this.runtime.stats.enemyHeroDefeated)
    };
  }

  private applyAct1FinaleTransitions(transitions: Act1FinaleTransition[]): void {
    transitions.forEach((transition) => {
      if (transition.type === "phase_started") {
        this.runtime.recordAct1FinalePhaseStarted({
          nodeId: ACT1_FINALE_NODE_ID,
          phaseId: transition.phase.id,
          telemetryLabel: transition.telemetryLabel,
          planMatched: transition.planMatched
        });
        this.showAct1FinaleMessage(`${transition.phase.title}: ${transition.phase.objective}`, transition.phase.id);
        if (transition.phase.id !== "secure_foothold") {
          this.tryStartAct1FinaleEvent(transition.eventIds);
        }
        return;
      }
      if (transition.type === "phase_completed") {
        this.runtime.recordAct1FinalePhaseCompleted({
          nodeId: ACT1_FINALE_NODE_ID,
          phaseId: transition.phase.id,
          telemetryLabel: transition.telemetryLabel,
          planMatched: transition.planMatched
        });
        this.showAct1FinaleMessage(transition.phase.completionHint, transition.phase.id);
        this.tryStartAct1FinaleEvent(transition.eventIds);
        return;
      }
      if (transition.type === "commander_released") {
        this.runtime.recordAct1FinaleCommanderReleased(transition.telemetryLabel, this.runtime.elapsedSeconds);
        this.showAct1FinaleMessage("Captain Malrec commits to the final defense.", transition.phase.id);
        const commander = this.enemyHeroUnits().find((unit) => unit.enemyHeroId === this.launch.request.enemyHeroId);
        if (commander) {
          this.addMinimapPing(commander.position.x, commander.position.y, "#ff9a64", "Captain Malrec committed");
        }
        this.tryStartAct1FinaleEvent(transition.eventIds);
        return;
      }
      this.runtime.recordAct1FinaleCompleted(transition.telemetryLabel);
      this.showAct1FinaleMessage("Act 1 finale completed. Captain Malrec is defeated.", transition.phase.id);
    });
    this.refreshBattleHud(0);
  }

  private tryStartAct1FinaleEvent(eventIds: readonly BattlefieldEventId[] | undefined): void {
    if (!eventIds || eventIds.length === 0 || !this.battlefieldEventDirector) {
      return;
    }
    for (const eventId of eventIds) {
      const transition = this.battlefieldEventDirector.forceStartEvent(eventId, this.createBattlefieldEventContext());
      if (transition) {
        this.applyBattlefieldEventTransitions([transition]);
        return;
      }
    }
  }

  private showAct1FinaleMessage(message: string, phaseId: Act1FinalePhaseId): void {
    const point = this.act1FinaleMessagePoint(phaseId);
    this.addMinimapPing(point.x, point.y, "#f6e27d", ACT1_FINALE_PHASE_BY_ID[phaseId]?.title ?? "Act 1 finale");
    this.showMessage(message, point.x, point.y - 84, "#f6e27d", { priority: "objective", durationSeconds: 5.5 });
  }

  private act1FinaleMessagePoint(phaseId: Act1FinalePhaseId): Position {
    if (phaseId === "secure_foothold") {
      const targetSite = this.captureSites.find((site) => site.definition.id === "burned_shrine") ?? this.captureSites[0];
      return targetSite?.position ?? this.hero.position;
    }
    if (phaseId === "break_fortified_line") {
      return (
        this.buildings.find(
          (building) =>
            building.alive &&
            building.team === "enemy" &&
            building.definition.id === this.activeMap.scenario.enemyAI.productionBuildingId
        )?.position ?? this.activeMap.enemyStart
      );
    }
    return this.enemyHeroUnits().find((unit) => unit.enemyHeroId === this.launch.request.enemyHeroId)?.position ?? this.activeMap.enemyStart;
  }

  private createBattlefieldEventContext(): BattlefieldEventDirectorContext {
    const campaignNode = this.launch.request.campaignNodeId ? CAMPAIGN_NODE_BY_ID[this.launch.request.campaignNodeId] : undefined;
    return {
      elapsedSeconds: this.runtime.elapsedSeconds,
      mode: this.launch.request.mode,
      rewardsDisabled: this.launch.request.rewardsDisabled,
      missionTypeId: campaignNode?.missionTypeId,
      modifierIds: this.launch.request.modifiers.map((modifier) => modifier.id),
      doctrineId: this.enemyDoctrine?.id,
      tacticalPlanId: this.launch.request.tacticalPlanId,
      captureSites: this.captureSites.map((site) => ({
        siteId: site.definition.id,
        name: site.definition.name,
        owner: site.owner,
        position: { ...site.position },
        incomeAmount: site.definition.incomeAmount,
        siteLevel: site.siteLevel,
        workerCount: site.workerAssignments.length
      })),
      units: this.units.map((unit) => ({
        id: unit.id,
        unitTypeId: unit.definition.id,
        name: unit.definition.name,
        team: unit.team,
        alive: unit.alive,
        position: { ...unit.position },
        enemyEliteSquadId: unit.enemyEliteSquadId,
        enemyEliteSquadName: unit.enemyEliteSquadName ?? unit.enemyEliteSquadLabel
      })),
      buildings: this.buildings.map((building) => ({
        id: building.id,
        buildingId: building.definition.id,
        name: building.definition.name,
        team: building.team,
        alive: building.alive,
        position: { ...building.position }
      })),
      commandHallAlive: Boolean(this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player")),
      retinueReinforcementAvailable: Boolean(this.createRetinueReinforcementSnapshot()?.available),
      retinueReinforcementUsed: this.retinueReinforcementUsed,
      usedAbilityIds: Object.entries(this.hero?.abilityCooldowns ?? {})
        .filter(([, remainingSeconds]) => remainingSeconds > 0)
        .map(([abilityId]) => abilityId)
    };
  }

  private applyBattlefieldEventTransitions(transitions: BattlefieldEventTransition[]): void {
    transitions.forEach((transition) => {
      if (transition.type === "started") {
        this.runtime.recordBattlefieldEventStarted({
          eventId: transition.event.id,
          objectiveLabel: transition.event.objectiveLabel,
          telemetryLabel: transition.telemetryLabel,
          planMatched: transition.event.planMatched
        });
        this.applyBattlefieldEventStartEffects(transition);
        this.applyBattlefieldEventPressure(transition.event);
        const supportText = transition.event.planMatched ? " Plan support active." : "";
        this.showBattlefieldEventMessage(`${transition.event.name}: ${transition.event.objectiveLabel}.${supportText}`, transition.event);
        return;
      }
      if (transition.type === "completed") {
        this.runtime.recordBattlefieldEventCompleted(transition.event.id, transition.telemetryLabel);
        this.applyBattlefieldEventCompletionBonus(transition);
        this.showBattlefieldEventMessage(`${transition.event.name} completed.`, transition.event);
        return;
      }
      this.runtime.recordBattlefieldEventFailed(transition.event.id, transition.telemetryLabel);
      this.showBattlefieldEventMessage(`${transition.event.name}: opportunity missed.`, transition.event);
    });
    this.refreshBattleHud(0);
  }

  private applyBattlefieldEventStartEffects(transition: BattlefieldEventTransition): void {
    if ((transition.pressureNudgeSeconds ?? 0) > 0) {
      this.aiSystem.adjustNextAttackTiming(transition.pressureNudgeSeconds ?? 0);
    }
    if ((transition.heroManaGain ?? 0) > 0) {
      this.grantHeroMana(transition.heroManaGain ?? 0);
    }
  }

  private applyBattlefieldEventCompletionBonus(transition: BattlefieldEventTransition): void {
    if (transition.resourceBonus && Object.values(transition.resourceBonus).some((amount) => (amount ?? 0) > 0)) {
      addResources(this.resources.player, transition.resourceBonus);
      this.showMessage(
        `Objective bonus: ${formatResourceBonusText(transition.resourceBonus)}`,
        undefined,
        undefined,
        "#f6e27d",
        { priority: "objective" }
      );
    }
  }

  private grantHeroMana(amount: number): void {
    if (!Number.isFinite(amount) || amount <= 0) {
      return;
    }
    const before = this.hero.mana;
    this.hero.mana = Math.min(this.hero.maxMana, this.hero.mana + amount);
    const gained = Math.floor(this.hero.mana - before);
    if (gained > 0) {
      this.showMessage(`Lume Surge: +${gained} Mana`, this.hero.position.x, this.hero.position.y - 58, "#74d3f2", {
        priority: "objective"
      });
    }
  }

  private applyBattlefieldEventPressure(event: ActiveBattlefieldEvent): void {
    if (event.id === "site_under_threat" && event.targetPosition) {
      this.enemyEventSquad(event.targetPosition, 2).forEach((unit, index) => {
        unit.commandMove({ x: event.targetPosition!.x + index * 18, y: event.targetPosition!.y + index * 14 }, true);
      });
      this.addMinimapPing(event.targetPosition.x, event.targetPosition.y, "#f0d978", event.name);
      this.runtime.recordEnemyDoctrineAction(`Battlefield event: ${event.name}`);
      return;
    }
    if (event.id === "hold_the_line") {
      const commandHall = this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player");
      if (!commandHall) {
        return;
      }
      this.enemyEventSquad(commandHall.position, 3).forEach((unit) => unit.commandAttack(commandHall.id, commandHall.definition.name));
      this.addMinimapPing(commandHall.position.x, commandHall.position.y, "#f0d978", event.name);
      this.runtime.recordEnemyDoctrineAction(`Battlefield event: ${event.name}`);
      return;
    }
    if (event.id === "elite_strike" && event.eliteSquadId) {
      const target = this.findBuilding(this.activeMap.scenario.objectives.playerBaseBuildingId, "player") ?? this.hero;
      this.units
        .filter((unit) => unit.alive && unit.team === "enemy" && unit.enemyEliteSquadId === event.eliteSquadId)
        .forEach((unit) => unit.commandAttack(target.id, target.definition.name));
      this.addMinimapPing(target.position.x, target.position.y, "#ff9a64", event.name);
      this.runtime.recordEnemyDoctrineAction(`Battlefield event: ${event.name}`);
    }
  }

  private enemyEventSquad(target: Position, count: number): Unit[] {
    return this.units
      .filter((unit) => unit.alive && unit.team === "enemy" && unit.kind === "unit")
      .sort((left, right) => distanceBetween(left.position, target) - distanceBetween(right.position, target))
      .slice(0, count);
  }

  private showBattlefieldEventMessage(message: string, event: ActiveBattlefieldEvent): void {
    const point = event.targetPosition ?? this.hero.position;
    this.showMessage(message, point.x, point.y - 82, "#f6e27d", { priority: "objective" });
  }

  private finalizeBattlefieldEventForResults(_outcome: "victory" | "defeat"): void {
    const transition = this.battlefieldEventDirector?.finishActiveForBattleEnd(this.createBattlefieldEventContext());
    if (transition) {
      this.applyBattlefieldEventTransitions([transition]);
    }
  }

  private trackEnemyWave(units: Unit[]): void {
    units
      .filter((unit) => unit.enemyHeroId)
      .forEach((unit) => this.runtime.recordEnemyHeroJoinedAttack(unit.enemyHeroId, this.runtime.elapsedSeconds));
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
      showMessage: (message, x, y, color, options) => this.showMessage(message, x, y, color, options)
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

  private createTutorialStepSnapshot(): TutorialStepViewModel | undefined {
    if (this.launch.request.mode !== "tutorial") {
      return undefined;
    }
    const tutorial = this.activeTutorial();
    const stepId = this.tutorialStepId ?? firstTutorialStepId(tutorial);
    if (!stepId) {
      return undefined;
    }
    return {
      ...createTutorialStepViewModel(tutorial, stepId, this.createTutorialCompletionSignals(tutorial, stepId)),
      dismissed: this.tutorialGuidanceDismissed
    };
  }

  private activeTutorial(): TutorialDefinition {
    return TUTORIALS.find((entry) => entry.id === this.launch.request.sourceId) ?? TUTORIALS[0];
  }

  private createTutorialCompletionSignals(tutorial: TutorialDefinition, stepId?: string): TutorialCompletionSignals {
    const step = tutorial.steps.find((entry) => entry.id === stepId);
    const selected = this.selectionSystem?.getSelected() ?? [];
    const selectedTroops = selected.filter(
      (entity): entity is Unit =>
        entity instanceof Unit && !(entity instanceof Hero) && entity.team === "player" && entity.alive && entity.definition.id !== "worker"
    );
    const movedDistance = this.hero
      ? Phaser.Math.Distance.Between(
          this.hero.position.x,
          this.hero.position.y,
          this.activeMap.scenario.heroSpawn.x,
          this.activeMap.scenario.heroSpawn.y
        )
      : 0;

    return {
      acknowledged: step?.requiredAction === "readInstructions",
      heroSelected: selected.some((entity) => entity === this.hero || entity instanceof Hero),
      troopsSelected: selectedTroops.length > 0,
      heroMoved: movedDistance >= 48,
      capturedSiteIds: this.captureSites
        .filter((site) => site.owner === "player")
        .map((site) => site.definition.id),
      resourceAmounts: {
        crowns: this.resources.player.crowns - this.activeMap.scenario.startingResources.player.crowns,
        stone: this.resources.player.stone - this.activeMap.scenario.startingResources.player.stone,
        iron: this.resources.player.iron - this.activeMap.scenario.startingResources.player.iron,
        aether: this.resources.player.aether - this.activeMap.scenario.startingResources.player.aether
      },
      selectedBuildingIds: selected
        .filter((entity): entity is Building => entity instanceof Building)
        .map((building) => building.definition.id),
      completedBuildingIds: this.buildings
        .filter((building) => building.alive && building.team === "player" && building.isCompleted())
        .map((building) => building.definition.id),
      assignedWorkerSiteIds: this.captureSites
        .filter((site) => site.owner === "player" && site.workerAssignments.length > 0)
        .map((site) => site.definition.id),
      trainedUnitIds: [...this.runtime.stats.trainedUnitIds],
      rallyBuildingIds: this.buildings
        .filter((building) => building.alive && building.team === "player" && Boolean(building.rallyPoint))
        .map((building) => building.definition.id),
      usedAbilityIds: Object.entries(this.hero?.abilityCooldowns ?? {})
        .filter(([, remainingSeconds]) => remainingSeconds > 0)
        .map(([abilityId]) => abilityId),
      defeatedUnitIds: [...this.tutorialDefeatedUnitIds],
      finished: step?.requiredAction === "finish"
    };
  }

  private advanceTutorialStep(): void {
    if (this.launch.request.mode !== "tutorial") {
      return;
    }
    const tutorial = this.activeTutorial();
    const stepId = this.tutorialStepId ?? firstTutorialStepId(tutorial);
    if (!stepId) {
      return;
    }
    const viewModel = createTutorialStepViewModel(tutorial, stepId, this.createTutorialCompletionSignals(tutorial, stepId));
    if (!viewModel.isComplete) {
      this.showMessage(viewModel.completionConditionLabel);
      return;
    }
    if (viewModel.isFinalStep) {
      this.showMessage("Training complete. No rewards or save changes granted.");
      this.endBattle("victory");
      return;
    }
    this.tutorialStepId = advanceTutorialStep(tutorial, stepId);
    this.tutorialGuidanceDismissed = false;
    this.showMessage("Tutorial objective updated");
    this.refreshBattleHud(0);
  }

  private dismissTutorialGuidance(): void {
    if (this.launch.request.mode !== "tutorial") {
      return;
    }
    this.tutorialGuidanceDismissed = true;
    this.showMessage("Tutorial guidance hidden. Use Show Tutorial Help to reopen.", undefined, undefined, "#d9eee8", {
      priority: "command"
    });
    this.refreshBattleHud(0);
  }

  private reopenTutorialGuidance(): void {
    if (this.launch.request.mode !== "tutorial") {
      return;
    }
    this.tutorialGuidanceDismissed = false;
    this.refreshBattleHud(0);
  }

  private focusTutorialObjective(): void {
    if (this.launch.request.mode !== "tutorial") {
      return;
    }
    const tutorial = this.activeTutorial();
    const stepId = this.tutorialStepId ?? firstTutorialStepId(tutorial);
    const target = tutorial.steps.find((entry) => entry.id === stepId)?.focusTarget;
    const point = target ? this.resolveTutorialFocusPoint(target) : undefined;
    if (!target || !point) {
      this.showMessage("Tutorial focus target unavailable.", undefined, undefined, "#ffd27a", { priority: "command" });
      return;
    }
    this.cameraSystem.centerOn(point);
    this.addMinimapPing(point.x, point.y, "#f6e27d", target.label);
    this.showMessage(target.label, point.x, point.y - 72, "#f6e27d", { priority: "command" });
    this.refreshBattleHud(0);
  }

  private resolveTutorialFocusPoint(target: TutorialFocusTargetDefinition): Position | undefined {
    if (target.type === "hero") {
      return this.hero?.position;
    }
    if (target.type === "friendlyTroops") {
      return this.units.find((unit) => unit.alive && unit.team === "player" && unit.definition.id !== "worker")?.position;
    }
    if (target.type === "worker") {
      return this.units.find((unit) => unit.alive && unit.team === "player" && unit.definition.id === (target.id ?? "worker"))?.position;
    }
    if (target.type === "captureSite") {
      return this.captureSites.find((site) => site.definition.id === target.id || site.id === target.id)?.position;
    }
    if (target.type === "building") {
      return this.buildings.find((building) => building.alive && building.team === "player" && building.definition.id === target.id)?.position;
    }
    if (target.type === "enemy") {
      return this.units.find((unit) => unit.alive && unit.team === "enemy" && unit.definition.id === target.id)?.position;
    }
    return undefined;
  }

  private warnIfCommandHallUnderAttack(target: BaseEntity): void {
    this.commandHallWarningCooldown = warnCommandHallUnderAttack({
      target,
      cooldown: this.commandHallWarningCooldown,
      playerBaseBuildingId: this.activeMap.scenario.objectives.playerBaseBuildingId,
      addMinimapPing: (x, y, color, label) => this.addMinimapPing(x, y, color, label),
      showMessage: (message, x, y, color, options) => this.showMessage(message, x, y, color, options)
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

  private showMessage(message: string, x?: number, y?: number, color = "#f5efc2", options: BattleStatusOptions = {}): void {
    const priority = options.priority ?? "normal";
    if (!shouldDisplayBattleStatus(priority, false)) {
      return;
    }
    const displayMessage = formatBattleStatusMessage(message, priority);
    if (this.shouldSuppressRecentStatus(displayMessage, priority)) {
      return;
    }
    this.performanceCounters.notificationsEmitted += 1;
    if (this.canUseTrustedBenchmarkDiagnostics() && this.trustedBenchmarkDiagnostics.notifications === "suppressed") {
      return;
    }
    const replaceStatus = shouldReplaceBattleStatus({
      currentPriority: this.statusPriority,
      currentTimerSeconds: this.statusTimer,
      incomingPriority: priority
    });
    if (replaceStatus) {
      this.statusMessage = displayMessage;
      this.statusTimer = options.durationSeconds ?? battleStatusDurationSeconds(priority);
      this.statusPriority = priority;
    }
    if (x !== undefined && y !== undefined) {
      FloatingText.show(this, displayMessage, x, y, color);
    }
    if (replaceStatus && this.uiSystem && this.hero && !this.runtime.ended) {
      this.refreshBattleHud(0);
    }
  }

  private shouldSuppressRecentStatus(message: string, priority: BattleStatusPriority): boolean {
    const dedupeSeconds = battleStatusDedupeSeconds(priority);
    if (dedupeSeconds <= 0) {
      return false;
    }
    const now = this.runtime?.elapsedSeconds ?? 0;
    const category = battleStatusCategory(priority);
    const key = `${category}:${message}`;
    const previous = this.recentStatusMessages.get(key);
    this.recentStatusMessages.set(key, now);
    for (const [entryKey, lastSeen] of this.recentStatusMessages.entries()) {
      if (now - lastSeen > 5) {
        this.recentStatusMessages.delete(entryKey);
      }
    }
    return previous !== undefined && now - previous < dedupeSeconds;
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
      },
      captureSite: (siteId: string) => {
        if (this.runtime.ended) {
          return null;
        }
        const site = this.captureSites.find((entry) => entry.definition.id === siteId);
        const playerUnit = this.units.find((unit) => unit.alive && unit.team === "player");
        if (!site || !playerUnit) {
          return null;
        }
        const beforeResources = { ...this.resources.player };
        playerUnit.setPosition(site.position.x, site.position.y);
        playerUnit.moveTarget = undefined;
        playerUnit.attackTargetId = undefined;
        playerUnit.attackMove = false;
        const step = CAPTURE_TIME_SECONDS / 12;
        for (let index = 0; index < 12 && site.owner !== "player"; index += 1) {
          this.resourceSystem.update(step, [site], this.units);
        }
        this.lumeNetworkDirector?.update();
        this.renderLumeNetworkLinks();
        this.refreshBattleHud(0);
        const strongholdEffects = getStrongholdBattleEffects(this.launch.request.modifiers);
        const firstCaptureBonus = site.definition.firstCaptureBonus
          ? applyFirstCaptureBonusAdditions(site.definition.id, "player", site.definition.firstCaptureBonus, strongholdEffects)
          : undefined;
        return {
          siteId: site.definition.id,
          owner: site.owner,
          beforeResources,
          afterResources: { ...this.resources.player },
          completedObjectiveIds: [...this.runtime.stats.completedObjectiveIds],
          status: this.statusMessage,
          firstCaptureBonus: firstCaptureBonus
            ? {
                id: firstCaptureBonus.id,
                label: firstCaptureBonus.label,
                resources: { ...firstCaptureBonus.resources }
              }
            : undefined
        };
      },
      scoutEnemyHero: () => {
        const enemyHero = this.enemyHeroUnits()[0];
        if (!enemyHero?.enemyHeroId) {
          return null;
        }
        const name = enemyHero.enemyHeroName ?? enemyHero.definition.name;
        const title = enemyHero.enemyHeroTitle ?? enemyHero.definition.role;
        this.fogDebugDisabled = true;
        this.updateFogOfWar(0, true);
        this.cameraSystem.centerOn(enemyHero.position);
        this.handleEnemyHeroVisible(enemyHero);
        this.showMessage(`Enemy commander sighted: ${name}, ${title}`, enemyHero.position.x, enemyHero.position.y - 72, "#ff9a64");
        this.refreshBattleHud(0);
        return {
          enemyHeroId: enemyHero.enemyHeroId,
          name,
          title
        };
      },
      defeatEnemyHero: () => {
        const enemyHero = this.enemyHeroUnits()[0];
        if (!enemyHero?.enemyHeroId) {
          return null;
        }
        const wasAlive = enemyHero.alive;
        enemyHero.takeDamage(enemyHero.maxHp + enemyHero.armor + 9999);
        if (wasAlive && !enemyHero.alive) {
          this.handleKill(this.hero, enemyHero);
          enemyHero.destroyView();
          this.cleanupDeadEntities();
        }
        this.refreshBattleHud(0);
        return {
          enemyHeroId: enemyHero.enemyHeroId,
          name: enemyHero.enemyHeroName ?? enemyHero.definition.name,
          title: enemyHero.enemyHeroTitle ?? enemyHero.definition.role,
          completedObjectiveIds: [...this.runtime.stats.completedObjectiveIds],
          xpGained: this.runtime.stats.xpGained,
          enemyHeroDefeated: Boolean(this.runtime.stats.enemyHeroDefeated)
        };
      },
      triggerBattlefieldEvent: (eventId: BattlefieldEventId) => {
        if (this.runtime.ended || !this.battlefieldEventDirector) {
          return null;
        }
        const transition = this.battlefieldEventDirector.forceStartEvent(eventId, this.createBattlefieldEventContext());
        if (!transition) {
          return null;
        }
        this.applyBattlefieldEventTransitions([transition]);
        const active = this.battlefieldEventDirector.getActiveEvent(this.createBattlefieldEventContext());
        return active
          ? {
              eventId: active.id,
              title: active.name,
              objective: active.objectiveLabel,
              progress: active.progressLabel
            }
          : null;
      },
      resolveBattlefieldEvent: (outcome = "completed") => {
        if (this.runtime.ended || !this.battlefieldEventDirector) {
          return null;
        }
        const transition = this.battlefieldEventDirector.resolveActiveEvent(outcome, this.createBattlefieldEventContext());
        if (!transition) {
          return null;
        }
        this.applyBattlefieldEventTransitions([transition]);
        return {
          eventId: transition.event.id,
          outcome,
          telemetry: transition.telemetryLabel
        };
      },
      getAct1FinaleState: () => {
        if (!this.act1FinaleDirector) {
          return null;
        }
        const active = this.act1FinaleDirector.currentPhaseSnapshot(this.createAct1FinaleContext());
        return {
          activePhaseId: active?.id,
          activePhaseTitle: active?.title,
          completedPhaseIds: [...(this.runtime.stats.act1FinaleCompletedPhaseIds ?? [])],
          commanderReleased: this.act1FinaleDirector.isCommanderReleased,
          commanderReleasedAtSeconds: this.runtime.stats.act1FinaleCommanderReleasedAtSeconds,
          completed: this.act1FinaleDirector.isCompleted
        };
      },
      getLumeNetworkSnapshot: () => {
        if (!this.lumeNetworkDirector) {
          return null;
        }
        return {
          hud: this.lumeNetworkDirector.hudSummary({
            privateDemo: this.isPrivateLumeDemo(),
            visibilityMode: this.lumeVisibilityMode
          }),
          state: this.lumeNetworkDirector.currentState(),
          render: this.createLumeRenderSnapshot()
        };
      },
      focusLumeSite: (siteId: string) => this.focusLumeSite(siteId),
      setLumeVisibilityMode: (mode: LumeNetworkVisibilityMode) => this.setLumeVisibilityMode(mode),
      finishPrivateDemo: () => this.finishPrivateDemo(),
      showCommandFeedbackMarker: (kind, x = this.hero.position.x, y = this.hero.position.y) => {
        this.showCommandFeedbackMarker({ kind, point: { x, y } });
        return this.commandFeedbackMarkers.size;
      },
      getCommandFeedbackMarkerCount: () => this.commandFeedbackMarkers.size,
      focusSelectedOrHero: () => {
        const focus = this.selectionSystem.getSelected().find((entity) => entity.alive) ?? (this.hero.alive ? this.hero : undefined);
        if (!focus) {
          return null;
        }
        this.cameraSystem.centerOn(focus.position);
        this.showCommandFeedbackMarker({ kind: "focus", point: focus.position });
        return {
          x: focus.position.x,
          y: focus.position.y,
          label: focus instanceof Unit || focus instanceof Building || focus instanceof CaptureSite ? focus.definition.name : "selection"
        };
      },
      getPrivatePerformanceCounters: () => this.createPrivatePerformanceCounters(),
      getTrustedBenchmarkDiagnostics: () => ({ ...this.trustedBenchmarkDiagnostics }),
      setTrustedBenchmarkDiagnostics: (diagnostics) => this.setTrustedBenchmarkDiagnostics(diagnostics),
      resetTrustedBenchmarkDiagnostics: () => this.resetTrustedBenchmarkDiagnostics(),
      selectTrustedBenchmarkTarget: (target) => this.selectTrustedBenchmarkTarget(target),
      getBattleLoopDiagnostics: () => ({ ...this.battleLoopDiagnostics }),
      setBattleLoopDiagnostics: (diagnostics) => this.setBattleLoopDiagnostics(diagnostics),
      getBattleLoopPhaseSummary: () => this.battleLoopPhaseProfiler.summary(),
      resetBattleLoopPhaseProfiler: () => this.resetBattleLoopPhaseProfiler()
    };
  }

  private removeTestHooks(): void {
    const target = globalThis as typeof globalThis & { __ASCENDANT_TEST_HOOKS__?: AscendantBattleTestHooks };
    if (!target.__ASCENDANT_TEST_HOOKS__) {
      return;
    }
    delete target.__ASCENDANT_TEST_HOOKS__.grantSelectedUnitVeterancyXp;
    delete target.__ASCENDANT_TEST_HOOKS__.forceBattleVictory;
    delete target.__ASCENDANT_TEST_HOOKS__.captureSite;
    delete target.__ASCENDANT_TEST_HOOKS__.scoutEnemyHero;
    delete target.__ASCENDANT_TEST_HOOKS__.defeatEnemyHero;
    delete target.__ASCENDANT_TEST_HOOKS__.triggerBattlefieldEvent;
    delete target.__ASCENDANT_TEST_HOOKS__.resolveBattlefieldEvent;
    delete target.__ASCENDANT_TEST_HOOKS__.getAct1FinaleState;
    delete target.__ASCENDANT_TEST_HOOKS__.getLumeNetworkSnapshot;
    delete target.__ASCENDANT_TEST_HOOKS__.focusLumeSite;
    delete target.__ASCENDANT_TEST_HOOKS__.setLumeVisibilityMode;
    delete target.__ASCENDANT_TEST_HOOKS__.finishPrivateDemo;
    delete target.__ASCENDANT_TEST_HOOKS__.showCommandFeedbackMarker;
    delete target.__ASCENDANT_TEST_HOOKS__.getCommandFeedbackMarkerCount;
    delete target.__ASCENDANT_TEST_HOOKS__.focusSelectedOrHero;
    delete target.__ASCENDANT_TEST_HOOKS__.getPrivatePerformanceCounters;
    delete target.__ASCENDANT_TEST_HOOKS__.getTrustedBenchmarkDiagnostics;
    delete target.__ASCENDANT_TEST_HOOKS__.setTrustedBenchmarkDiagnostics;
    delete target.__ASCENDANT_TEST_HOOKS__.selectTrustedBenchmarkTarget;
    delete target.__ASCENDANT_TEST_HOOKS__.resetTrustedBenchmarkDiagnostics;
    delete target.__ASCENDANT_TEST_HOOKS__.getBattleLoopDiagnostics;
    delete target.__ASCENDANT_TEST_HOOKS__.setBattleLoopDiagnostics;
    delete target.__ASCENDANT_TEST_HOOKS__.getBattleLoopPhaseSummary;
    delete target.__ASCENDANT_TEST_HOOKS__.resetBattleLoopPhaseProfiler;
  }

  private cleanup(): void {
    registerPrivatePerformanceCounterProvider(undefined);
    this.removeTrustedBenchmarkDiagnosticsPanel();
    this.removeTestHooks();
    this.inputSystem?.destroy();
    this.uiSystem?.destroy();
    this.buildingSystem?.cancelPlacement();
    this.rallyMarkers.forEach((marker) => marker.destroy(true));
    this.rallyMarkers.clear();
    this.clearCommandFeedbackMarkers();
    this.neutralCampLabels.forEach((entry) => entry.label.destroy());
    this.neutralCampLabels = [];
    this.lumeLinkGraphics?.destroy();
    this.lumeLinkGraphics = undefined;
    this.lumeRenderPulses.clear();
    this.previousLumeRenderStates = undefined;
    this.lastLumeRenderSignature = "";
    this.fogOverlay?.destroy();
    this.fogOverlay = undefined;
    this.lastFogRenderSignature = "";
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

function defaultHudDensityModeForLaunch(request: BattleLaunchRequest, privateToolsEnabled: boolean): HudDensityMode {
  const privateReviewLaunch = isPrivatePlaytestHubLaunch(request) || isPrivateLumeDemoLaunch(request);
  return normalizeHudDensityMode(undefined, privateToolsEnabled && privateReviewLaunch);
}

function hudDensityModeForPrivateScenario(scenarioId: string | undefined): string | undefined {
  if (!scenarioId) {
    return undefined;
  }
  if (scenarioId.includes("hud_debug")) {
    return "debug";
  }
  if (scenarioId.includes("hud_minimal")) {
    return "minimal";
  }
  if (scenarioId.includes("hud_standard")) {
    return "standard";
  }
  return undefined;
}

function hudDensityLabel(mode: HudDensityMode): string {
  if (mode === "debug") {
    return "Debug";
  }
  if (mode === "standard") {
    return "Standard";
  }
  return "Minimal";
}

function trustedDiagnosticLabel(key: keyof TrustedBenchmarkDiagnostics): string {
  const labels: Record<keyof TrustedBenchmarkDiagnostics, string> = {
    labels: "Labels",
    captureRings: "Capture Rings",
    lume: "Lume",
    minimapRefresh: "Minimap Refresh",
    fogRedraw: "Fog Visual Redraw",
    hudDensity: "HUD Density",
    notifications: "Notifications",
    profilerOverlay: "Profiler Overlay"
  };
  return labels[key];
}

function battleLoopDiagnosticLabel(key: keyof BattleLoopDiagnostics): string {
  const labels: Record<keyof BattleLoopDiagnostics, string> = {
    phaseProfiler: "Phase Profiler",
    simulation: "Simulation",
    ai: "AI",
    path: "Path",
    movement: "Movement",
    combat: "Combat",
    projectiles: "Projectiles",
    fogSimulation: "Fog Simulation",
    fogPresentation: "Fog Presentation",
    entityGraphics: "Entity Graphics",
    labels: "Labels",
    captureRings: "Capture Rings",
    lume: "Lume",
    minimap: "Minimap",
    hudDomPatches: "HUD DOM Patches",
    notifications: "Notifications",
    camera: "Camera",
    profilerOverlay: "Profiler Overlay"
  };
  return labels[key];
}

function trustedDiagnosticValueLabel(value: string): string {
  return value
    .split(/[-_]/u)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function kebabCase(value: string): string {
  return value.replace(/[A-Z]/gu, (letter) => `-${letter.toLowerCase()}`).replace(/_/gu, "-");
}

function createLumeRenderSnapshotSignature(snapshot: LumeRenderSnapshot): string {
  const links = snapshot.links
    .map(
      (link) =>
        `${link.id}:${link.state}:${link.style}:${link.emphasis}:${pointSignature(link.from)}:${pointSignature(link.to)}:${link.color}:${roundRenderMetric(
          link.alpha
        )}:${roundRenderMetric(link.width)}:${link.pulseKind ?? ""}`
    )
    .join("|");
  const markers = snapshot.siteMarkers
    .map(
      (marker) =>
        `${marker.siteId}:${marker.state}:${marker.emphasis}:${pointSignature(marker.position)}:${roundRenderMetric(marker.radius)}:${marker.color}:${roundRenderMetric(
          marker.alpha
        )}`
    )
    .join("|");
  return `${links}::${markers}`;
}

function pointSignature(point: Position): string {
  return `${roundRenderMetric(point.x)},${roundRenderMetric(point.y)}`;
}

function roundRenderMetric(value: number): string {
  return Number(value.toFixed(2)).toString();
}

function distanceBetween(left: Position, right: Position): number {
  return Math.hypot(left.x - right.x, left.y - right.y);
}

function formatResourceBonusText(resources: Partial<ResourceBag>): string {
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

function mergeSiteVisual(
  siteVisuals: Map<string, Pick<LumeRenderSiteMarkerSnapshot, "color" | "alpha" | "emphasis">>,
  siteId: string,
  linkVisual: LumeRenderPresentation
): void {
  const next = {
    color: linkVisual.color,
    alpha: linkVisual.markerAlpha,
    emphasis: linkVisual.emphasis
  };
  const existing = siteVisuals.get(siteId);
  if (!existing || next.alpha > existing.alpha) {
    siteVisuals.set(siteId, next);
  }
}

function lumePulseKind(
  previous: LumeNetworkCurrentLinkState,
  current: LumeNetworkCurrentLinkState,
  wasPreviouslySevered: boolean
): LumeRenderPulseKind {
  if (current === "contested") {
    return "contested";
  }
  if (current === "severed") {
    return "severed";
  }
  if (current === "active" && (previous === "severed" || wasPreviouslySevered)) {
    return "restored";
  }
  return "activated";
}
