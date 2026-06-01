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
