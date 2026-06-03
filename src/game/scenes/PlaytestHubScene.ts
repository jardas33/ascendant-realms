import Phaser from "phaser";
import { ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { SCENE_KEYS } from "../core/SceneKeys";
import {
  createPlaytestHubBattleLaunchRequest,
  createPlaytestHubCampaignSave,
  createPlaytestHubHeroSave,
  createPlaytestHubResultsData
} from "../playtest/PlaytestHubFixtures";
import {
  PLAYTEST_FAST_TOUR_SCENARIO_IDS,
  PLAYTEST_SCENARIO_GROUPS,
  PLAYTEST_SCENARIOS,
  scenarioById,
  type PlaytestScenarioDefinition
} from "../playtest/PlaytestScenarioGallery";
import {
  beginPrivatePlaytestHubSession,
  isPrivatePlaytestToolsEnabled,
  PRIVATE_PLAYTEST_HUB_NOTICE,
  resetPrivatePlaytestHubSession,
  restorePrivatePlaytestHubSave
} from "../playtest/PrivatePlaytestTools";
import {
  TRUSTED_DEFAULT_SAMPLE_MS,
  TRUSTED_DEFAULT_WARMUP_MS,
  V0109_ARTIFACT_DIR,
  createManualBenchmarkTemplate
} from "../playtest/TrustedBrowserBenchmark";

type TrustedManualBenchmarkPhaseId = "intro" | "warmup" | "steady" | "interaction" | "export";

interface TrustedManualBenchmarkPhase {
  id: TrustedManualBenchmarkPhaseId;
  title: string;
  body: string;
}

interface TrustedManualBenchmarkSession {
  active: boolean;
  phaseIndex: number;
  startedAtUtc?: string;
  exportedAtUtc?: string;
}

const TRUSTED_MANUAL_BENCHMARK_PHASES: TrustedManualBenchmarkPhase[] = [
  {
    id: "intro",
    title: "Integrity Check",
    body: "Private-only benchmark integrity lane. It records execution mode, visibility, viewport, overlay state, warm-up, sample duration, and save-isolation posture."
  },
  {
    id: "warmup",
    title: "Warm-Up",
    body: `Launch Tier M representative battle, then wait ${TRUSTED_DEFAULT_WARMUP_MS / 1000} seconds before scoring any frame data.`
  },
  {
    id: "steady",
    title: "Steady-State Sample",
    body: `Sample requestAnimationFrame intervals for ${TRUSTED_DEFAULT_SAMPLE_MS / 1000} seconds with screenshots and the old profiler overlay outside the timing window.`
  },
  {
    id: "interaction",
    title: "Interaction Samples",
    body: "Measure hero, Worker, building, minimap, Lume Hidden/Auto/Always, Results transition, reset, and return-to-hub separately from steady-state frame timing."
  },
  {
    id: "export",
    title: "Export Summary",
    body: "Copy the generated summary into the local v0.109 artifact folder. The template names every required field and avoids console-only instructions."
  }
];

let trustedManualBenchmarkSession: TrustedManualBenchmarkSession = {
  active: false,
  phaseIndex: 0
};

export class PlaytestHubScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private status = "Choose a private scenario. Your existing local save is restored when you return.";
  private tourStepIndex?: number;

  constructor() {
    super(SCENE_KEYS.playtestHub);
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }

    if (!isPrivatePlaytestToolsEnabled()) {
      this.scene.start(SCENE_KEYS.mainMenu);
      return;
    }

    beginPrivatePlaytestHubSession();
    this.handler = (event) => this.handleClick(event);
    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private handleClick(event: MouseEvent): void {
    const target = event.target as HTMLElement;
    const actionButton = target.closest<HTMLButtonElement>("button[data-playtest-action]");
    if (actionButton) {
      const action = actionButton.dataset.playtestAction;
      if (action === "main-menu") {
        resetPrivatePlaytestHubSession();
        this.scene.start(SCENE_KEYS.mainMenu);
      }
      if (action === "reset") {
        resetPrivatePlaytestHubSession();
        beginPrivatePlaytestHubSession();
        this.status = "Private preview reset. Your pre-hub save snapshot is restored.";
        this.render();
      }
      if (action === "tour-start") {
        this.tourStepIndex = 0;
        this.status = "8-minute visual tour started. Use Open Step, then return to the hub for Next.";
        this.render();
      }
      if (action === "tour-next" && this.tourStepIndex !== undefined) {
        this.tourStepIndex = Math.min(this.tourStepIndex + 1, PLAYTEST_FAST_TOUR_SCENARIO_IDS.length - 1);
        this.render();
      }
      if (action === "tour-back" && this.tourStepIndex !== undefined) {
        this.tourStepIndex = Math.max(this.tourStepIndex - 1, 0);
        this.render();
      }
      if (action === "tour-exit") {
        this.tourStepIndex = undefined;
        this.status = "Tour closed. Scenario gallery remains available.";
        this.render();
      }
      if (action === "tour-open" && this.tourStepIndex !== undefined) {
        const scenario = scenarioById(PLAYTEST_FAST_TOUR_SCENARIO_IDS[this.tourStepIndex]);
        if (scenario) {
          this.launchScenario(scenario);
        }
      }
      if (action === "trusted-benchmark-start") {
        trustedManualBenchmarkSession = {
          active: true,
          phaseIndex: 0,
          startedAtUtc: new Date().toISOString()
        };
        this.status = "Trusted manual benchmark flow started. Use the phase controls and existing private scenarios only.";
        this.render();
      }
      if (action === "trusted-benchmark-next" && trustedManualBenchmarkSession.active) {
        trustedManualBenchmarkSession.phaseIndex = Math.min(
          trustedManualBenchmarkSession.phaseIndex + 1,
          TRUSTED_MANUAL_BENCHMARK_PHASES.length - 1
        );
        this.render();
      }
      if (action === "trusted-benchmark-back" && trustedManualBenchmarkSession.active) {
        trustedManualBenchmarkSession.phaseIndex = Math.max(trustedManualBenchmarkSession.phaseIndex - 1, 0);
        this.render();
      }
      if (action === "trusted-benchmark-clear") {
        trustedManualBenchmarkSession = { active: false, phaseIndex: 0 };
        this.status = "Trusted manual benchmark flow cleared. Private scenario gallery remains unchanged.";
        this.render();
      }
      if (action === "trusted-benchmark-export" && trustedManualBenchmarkSession.active) {
        trustedManualBenchmarkSession = {
          ...trustedManualBenchmarkSession,
          phaseIndex: TRUSTED_MANUAL_BENCHMARK_PHASES.length - 1,
          exportedAtUtc: new Date().toISOString()
        };
        this.status = `Manual benchmark template ready for ${V0109_ARTIFACT_DIR}/manual-benchmark-template.json.`;
        this.render();
      }
      if (action === "trusted-benchmark-tier-m") {
        const scenario = scenarioById("benchmark_battle_tier_m_representative");
        if (scenario) {
          trustedManualBenchmarkSession = {
            active: true,
            phaseIndex: 1,
            startedAtUtc: trustedManualBenchmarkSession.startedAtUtc ?? new Date().toISOString()
          };
          this.launchScenario(scenario);
        }
      }
      if (action === "trusted-benchmark-results") {
        const scenario = scenarioById("benchmark_battle_results_transition");
        if (scenario) {
          trustedManualBenchmarkSession = {
            active: true,
            phaseIndex: 3,
            startedAtUtc: trustedManualBenchmarkSession.startedAtUtc ?? new Date().toISOString()
          };
          this.launchScenario(scenario);
        }
      }
      return;
    }

    const scenarioButton = target.closest<HTMLButtonElement>("button[data-playtest-scenario]");
    if (scenarioButton) {
      const scenario = scenarioById(scenarioButton.dataset.playtestScenario ?? "");
      if (!scenario) {
        this.status = "That private scenario is not available.";
        this.render();
        return;
      }
      this.launchScenario(scenario);
    }
  }

  private launchScenario(scenario: PlaytestScenarioDefinition): void {
    restorePrivatePlaytestHubSave();
    const heroSave = createPlaytestHubHeroSave();
    const scenarioData = {
      privatePlaytestHub: true,
      privatePlaytestScenarioId: scenario.id
    };

    if (scenario.launchKind === "main_menu") {
      this.scene.start(SCENE_KEYS.mainMenu, scenarioData);
      return;
    }

    if (scenario.launchKind === "hero_creation") {
      this.scene.start(SCENE_KEYS.heroCreation, { ...scenarioData, nextMode: "campaign" });
      return;
    }

    if (scenario.launchKind === "campaign") {
      this.scene.start(SCENE_KEYS.campaignMap, {
        ...scenarioData,
        heroSave,
        campaignSave: this.campaignSaveForScenario(scenario.id),
        privatePlaytestActiveTab: campaignTabForScenario(scenario.id),
        message: PRIVATE_PLAYTEST_HUB_NOTICE
      });
      return;
    }

    if (scenario.launchKind === "battle" || scenario.launchKind === "lume_battle") {
      this.scene.start(SCENE_KEYS.battle, {
        launchRequest: createPlaytestHubBattleLaunchRequest(scenario.id, heroSave)
      });
      return;
    }

    if (scenario.launchKind === "hero_progression") {
      this.scene.start(SCENE_KEYS.heroProgression, {
        ...scenarioData,
        heroSave,
        returnMode: "campaign"
      });
      return;
    }

    if (scenario.launchKind === "results") {
      const kind =
        scenario.id === "private_demo_results" ? "private-demo" : scenario.id === "defeat_results" ? "defeat" : "victory";
      this.scene.start(SCENE_KEYS.results, {
        ...createPlaytestHubResultsData(kind),
        ...scenarioData
      });
    }
  }

  private campaignSaveForScenario(scenarioId: string) {
    if (scenarioId === "campaign_locked_mission") {
      return createPlaytestHubCampaignSave({
        selectedNodeId: "aether_well_ruins",
        completedNodeIds: ["border_village"],
        unlockedNodeIds: ["border_village", "old_stone_road"]
      });
    }
    if (scenarioId === "meta_retinue_recovering") {
      return createPlaytestHubCampaignSave({ selectedNodeId: "old_stone_road", retinueMode: "recovering" });
    }
    if (scenarioId === "meta_retinue_ready") {
      return createPlaytestHubCampaignSave({ selectedNodeId: "old_stone_road", retinueMode: "ready" });
    }
    if (scenarioId === "campaign_fresh") {
      return createPlaytestHubCampaignSave({
        selectedNodeId: "border_village",
        completedNodeIds: [],
        unlockedNodeIds: ["border_village"]
      });
    }
    return createPlaytestHubCampaignSave({ selectedNodeId: "border_village" });
  }

  private render(): void {
    if (!this.root) {
      return;
    }
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell playtest-hub-shell asset-screen-bg" data-testid="playtest-hub" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel extra-wide playtest-hub-panel">
          <div class="progression-header playtest-hub-header">
            <div>
              <p class="eyebrow">Private Testing Only</p>
              <h1>Playtest Hub</h1>
              <p class="menu-copy">${PRIVATE_PLAYTEST_HUB_NOTICE}</p>
            </div>
            <div class="menu-actions row playtest-hub-actions">
              <button class="menu-primary-button" data-testid="playtest-tour-start" data-playtest-action="tour-start">Run 8-Minute Visual Tour</button>
              <button data-testid="playtest-reset" data-playtest-action="reset">Reset Private Preview</button>
              <button data-testid="playtest-main-menu" data-playtest-action="main-menu">Main Menu</button>
            </div>
          </div>
          <div class="status-box" data-testid="playtest-hub-status">${escapeHtml(this.status)}</div>
          ${this.renderTourPanel()}
          ${this.renderTrustedManualBenchmarkPanel()}
          <div class="playtest-gallery" data-testid="playtest-gallery">
            ${PLAYTEST_SCENARIO_GROUPS.map((group) => this.renderGroup(group.id, group.title)).join("")}
          </div>
        </section>
      </main>
    `;
  }

  private renderGroup(groupId: string, title: string): string {
    const scenarios = PLAYTEST_SCENARIOS.filter((scenario) => scenario.groupId === groupId);
    return `
      <section class="playtest-group" data-testid="playtest-group-${groupId}">
        <div class="playtest-group-heading">
          <h2>${escapeHtml(title)}</h2>
          <span class="tag">${scenarios.length} entries</span>
        </div>
        <div class="playtest-scenario-grid">
          ${scenarios.map((scenario) => this.renderScenarioCard(scenario)).join("")}
        </div>
      </section>
    `;
  }

  private renderScenarioCard(scenario: PlaytestScenarioDefinition): string {
    return `
      <article class="playtest-scenario-card">
        <div>
          <strong>${escapeHtml(scenario.title)}</strong>
          <p>${escapeHtml(scenario.purpose)}</p>
        </div>
        <small>${escapeHtml(scenario.manualReviewQuestion)}</small>
        <button data-testid="playtest-scenario-${scenario.id}" data-playtest-scenario="${scenario.id}">Open</button>
      </article>
    `;
  }

  private renderTourPanel(): string {
    if (this.tourStepIndex === undefined) {
      return "";
    }
    const scenario = scenarioById(PLAYTEST_FAST_TOUR_SCENARIO_IDS[this.tourStepIndex]);
    if (!scenario) {
      return "";
    }
    return `
      <section class="playtest-tour-panel" data-testid="playtest-tour-panel">
        <div>
          <p class="eyebrow">8-Minute Visual Tour</p>
          <h2>Step ${this.tourStepIndex + 1} of ${PLAYTEST_FAST_TOUR_SCENARIO_IDS.length}: ${escapeHtml(scenario.title)}</h2>
          <p>${escapeHtml(scenario.purpose)}</p>
          <p class="quiet">${escapeHtml(scenario.manualReviewQuestion)}</p>
        </div>
        <div class="menu-actions row">
          <button data-testid="playtest-tour-back" data-playtest-action="tour-back" ${this.tourStepIndex === 0 ? "disabled" : ""}>Back</button>
          <button class="menu-primary-button" data-testid="playtest-tour-open" data-playtest-action="tour-open">Open Step</button>
          <button data-testid="playtest-tour-next" data-playtest-action="tour-next" ${this.tourStepIndex >= PLAYTEST_FAST_TOUR_SCENARIO_IDS.length - 1 ? "disabled" : ""}>Next</button>
          <button data-testid="playtest-tour-exit" data-playtest-action="tour-exit">Exit Tour</button>
        </div>
      </section>
    `;
  }

  private renderTrustedManualBenchmarkPanel(): string {
    const session = trustedManualBenchmarkSession;
    const phase = TRUSTED_MANUAL_BENCHMARK_PHASES[session.phaseIndex] ?? TRUSTED_MANUAL_BENCHMARK_PHASES[0];
    const template = createManualBenchmarkTemplate();
    const summary = JSON.stringify(
      {
        ...template,
        manualSession: {
          active: session.active,
          phase: phase.id,
          startedAtUtc: session.startedAtUtc ?? "not-started",
          exportedAtUtc: session.exportedAtUtc ?? "not-exported",
          executionMode: "manual-in-app",
          warmupMs: TRUSTED_DEFAULT_WARMUP_MS,
          sampleMs: TRUSTED_DEFAULT_SAMPLE_MS,
          screenshotsDuringSample: false,
          profilerOverlayDefault: "off"
        }
      },
      null,
      2
    );
    return `
      <section class="trusted-manual-benchmark-panel" data-testid="trusted-manual-benchmark-panel">
        <div class="trusted-manual-benchmark-heading">
          <div>
            <p class="eyebrow">v0.109 Private Benchmark</p>
            <h2>Trusted Manual Benchmark</h2>
            <p>Session-only flow for integrity review, root-cause isolation, and Emmanuel retest. No save, reward, XP, progression, Retinue, relic, reputation, stable-ID, art, engine, or desktop-port change.</p>
          </div>
          <button class="menu-primary-button" data-testid="trusted-manual-benchmark-start" data-playtest-action="trusted-benchmark-start">RUN TRUSTED MANUAL BENCHMARK</button>
        </div>
        <div class="trusted-manual-benchmark-steps" data-testid="trusted-manual-benchmark-steps">
          ${TRUSTED_MANUAL_BENCHMARK_PHASES.map(
            (entry, index) =>
              `<span class="${index === session.phaseIndex ? "active" : ""}" data-testid="trusted-manual-phase-${entry.id}">${index + 1}. ${escapeHtml(entry.title)}</span>`
          ).join("")}
        </div>
        <div class="trusted-manual-benchmark-current" data-testid="trusted-manual-benchmark-current">
          <strong>${escapeHtml(phase.title)}</strong>
          <p>${escapeHtml(phase.body)}</p>
        </div>
        <div class="menu-actions row trusted-manual-benchmark-actions">
          <button data-testid="trusted-manual-benchmark-back" data-playtest-action="trusted-benchmark-back" ${!session.active || session.phaseIndex === 0 ? "disabled" : ""}>Back</button>
          <button data-testid="trusted-manual-benchmark-next" data-playtest-action="trusted-benchmark-next" ${!session.active || session.phaseIndex >= TRUSTED_MANUAL_BENCHMARK_PHASES.length - 1 ? "disabled" : ""}>Next Phase</button>
          <button data-testid="trusted-manual-benchmark-tier-m" data-playtest-action="trusted-benchmark-tier-m">Launch Tier M</button>
          <button data-testid="trusted-manual-benchmark-results" data-playtest-action="trusted-benchmark-results">Results Transition</button>
          <button data-testid="trusted-manual-benchmark-export" data-playtest-action="trusted-benchmark-export" ${!session.active ? "disabled" : ""}>Export Summary</button>
          <button data-testid="trusted-manual-benchmark-clear" data-playtest-action="trusted-benchmark-clear">Clear</button>
        </div>
        <textarea data-testid="trusted-manual-benchmark-template" readonly>${escapeHtml(summary)}</textarea>
      </section>
    `;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}

function campaignTabForScenario(scenarioId: string): string | undefined {
  if (scenarioId.includes("stronghold")) {
    return "stronghold";
  }
  if (scenarioId.includes("hero") || scenarioId.includes("retinue")) {
    return "hero";
  }
  if (scenarioId.includes("inventory")) {
    return "inventory";
  }
  if (scenarioId.includes("intel")) {
    return "intel";
  }
  if (scenarioId.includes("reputation")) {
    return "reputation";
  }
  return "map";
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
