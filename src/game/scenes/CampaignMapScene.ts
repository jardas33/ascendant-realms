import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createCampaignBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { getCampaignNextAction } from "../core/FirstExperienceGuidance";
import type { BattleStats, CampaignNodeDefinition, TacticalPlanId } from "../core/GameTypes";
import {
  applyCampaignChoice,
  completeCampaignNodeWithRewards,
  createStartedCampaignSave,
  getCampaignNodeStatus,
  refreshCampaignUnlocks
} from "../core/CampaignRules";
import { getStrongholdLaunchModifiers, purchaseStrongholdUpgrade } from "../core/StrongholdRules";
import { getRivalBattleLaunchModifiers } from "../core/RivalRules";
import {
  getCampaignMissionBriefing,
  getCampaignMissionRewardState,
  getCampaignScenarioLaunchModifiers
} from "../core/campaign/CampaignMissionRules";
import { getCampaignActStepForNode, getCampaignNodeLockedReason } from "../core/campaign/CampaignActSpineRules";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { HERO_CLASS_BY_ID, ORIGIN_BY_ID } from "../data/contentIndex";
import { consumeBattleCampaignModifiers } from "../data/campaignModifiers";
import { DEFAULT_TACTICAL_PLAN_ID, getTacticalPlan, normalizeTacticalPlanId } from "../data/tacticalPlans";
import { getReputationBattleLaunchModifiers } from "../data/reputation";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import { formatCampaignChoiceResultMessage } from "../campaign/CampaignChoiceResultMessage";
import { renderCampaignChapterPanel } from "../campaign/CampaignChapterPanel";
import { createCampaignMapViewModel } from "../campaign/CampaignMapViewModel";
import {
  canStartCampaignNode,
  firstAvailableNodeId,
  messageForCampaignMapData,
  selectedCampaignNode
} from "../campaign/CampaignNavigation";
import { formatNodeRewardSummary, renderGuidanceMessage, renderNodeButton, renderNodeDetails } from "../campaign/CampaignNodePanel";
import { escapeHtml, toCssColor, type CampaignMapViewModel, type CampaignNodeViewModel } from "../campaign/CampaignPresentationTypes";
import {
  renderActiveModifiers,
  renderCampaignResourceBank,
  renderReputation
} from "../campaign/CampaignResourcePanel";
import { renderRetinuePanel } from "../campaign/RetinuePanel";
import { renderRivalIntelPanel } from "../campaign/RivalIntelPanel";
import { renderStrongholdPanel } from "../campaign/StrongholdPanel";
import { dismissRetinueUnit, retinueDeploymentUnits, retinueReserveUnits, toggleRetinueDeployment } from "../core/RetinueRules";
import { isPrivatePlaytestToolsEnabled, PRIVATE_LUME_DEMO_ID, PRIVATE_LUME_DEMO_NOTICE } from "../playtest/PrivatePlaytestTools";

type CampaignTabId = "map" | "stronghold" | "hero" | "inventory" | "intel" | "reputation";

const CAMPAIGN_TABS: Array<{ id: CampaignTabId; label: string }> = [
  { id: "map", label: "Map" },
  { id: "stronghold", label: "Stronghold" },
  { id: "hero", label: "Hero" },
  { id: "inventory", label: "Inventory" },
  { id: "intel", label: "Intel" },
  { id: "reputation", label: "Reputation" }
];

interface CampaignMapData {
  heroSave?: HeroSaveData;
  campaignSave?: CampaignSaveData;
  completedNodeId?: string;
  wasReplay?: boolean;
  stats?: BattleStats;
  message?: string;
}

export class CampaignMapScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private heroSave: HeroSaveData = createFallbackHeroSave();
  private campaignSave: CampaignSaveData = createStartedCampaignSave();
  private selectedNodeId = CAMPAIGN_NODES[0]?.id ?? "";
  private selectedTacticalPlanId: TacticalPlanId = DEFAULT_TACTICAL_PLAN_ID;
  private activeTab: CampaignTabId = "map";
  private message = "Choose an available campaign node.";

  constructor() {
    super(SCENE_KEYS.campaignMap);
  }

  init(data: CampaignMapData): void {
    const stored = SaveSystem.load();
    this.heroSave = data.heroSave ?? stored?.hero ?? createFallbackHeroSave();
    this.campaignSave = refreshCampaignUnlocks(data.campaignSave ?? stored?.campaign ?? createStartedCampaignSave());
    if (!this.campaignSave.started) {
      this.campaignSave = createStartedCampaignSave(this.campaignSave);
    }
    this.selectedNodeId = data.completedNodeId ?? this.campaignSave.selectedNodeId ?? firstAvailableNodeId(this.campaignSave);
    this.message = data.message ?? messageForCampaignMapData(data);
    SaveSystem.saveGame(this.heroSave, this.campaignSave);
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }

    this.handler = (event) => {
      const target = event.target as HTMLElement;
      const nodeButton = target.closest<HTMLButtonElement>("button[data-campaign-node]");
      if (nodeButton) {
        this.selectedNodeId = nodeButton.dataset.campaignNode ?? this.selectedNodeId;
        const selectedNode = this.selectedNode();
        this.campaignSave = {
          ...this.campaignSave,
          selectedNodeId: this.selectedNodeId,
          selectedChapterId: selectedNode?.chapterId ?? this.campaignSave.selectedChapterId
        };
        SaveSystem.saveCampaign(this.campaignSave, this.heroSave);
        this.render();
        return;
      }

      const choiceButton = target.closest<HTMLButtonElement>("button[data-campaign-choice]");
      if (choiceButton) {
        this.applySelectedChoice(choiceButton.dataset.campaignChoice ?? "");
        return;
      }

      const strongholdButton = target.closest<HTMLButtonElement>("button[data-stronghold-upgrade]");
      if (strongholdButton) {
        this.purchaseStrongholdUpgrade(strongholdButton.dataset.strongholdUpgrade ?? "");
        return;
      }

      const tacticalPlanButton = target.closest<HTMLButtonElement>("button[data-tactical-plan]");
      if (tacticalPlanButton) {
        this.selectTacticalPlan(tacticalPlanButton.dataset.tacticalPlan);
        return;
      }

      const tabButton = target.closest<HTMLButtonElement>("button[data-campaign-tab]");
      if (tabButton) {
        this.selectTab(tabButton.dataset.campaignTab);
        return;
      }

      const retinueDismissButton = target.closest<HTMLButtonElement>("button[data-retinue-dismiss]");
      if (retinueDismissButton) {
        this.dismissRetinueUnit(retinueDismissButton.dataset.retinueDismiss ?? "");
        return;
      }

      const retinueDeployButton = target.closest<HTMLButtonElement>("button[data-retinue-deploy-toggle]");
      if (retinueDeployButton) {
        this.toggleRetinueDeployment(retinueDeployButton.dataset.retinueDeployToggle ?? "");
        return;
      }

      const action = target.closest<HTMLButtonElement>("button[data-campaign-action]")?.dataset.campaignAction;
      if (action === "start") {
        this.startSelectedNode();
      }
      if (action === "private-lume-demo") {
        this.startPrivateLumeDemo();
      }
      if (action === "menu") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
      if (action === "inventory") {
        this.scene.start(SCENE_KEYS.heroProgression, {
          heroSave: this.heroSave,
          returnMode: "campaign"
        });
      }
    };

    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private startSelectedNode(): void {
    const node = this.selectedNode();
    if (!node) {
      return;
    }
    const status = getCampaignNodeStatus(node, this.campaignSave);
    if (node.isPlaceholder) {
      this.message = node.placeholderDescription ?? "That campaign node is a future placeholder.";
      this.render();
      return;
    }
    const canReplay = node.nodeType === "battle" && status === "completed";
    if (status !== "available" && !canReplay) {
      this.message = "That node is not available yet.";
      this.render();
      return;
    }

    if (node.nodeType === "battle") {
      const modifierResult = consumeBattleCampaignModifiers({
        campaign: this.campaignSave,
        node
      });
      this.campaignSave = modifierResult.campaign;
      SaveSystem.saveCampaign(this.campaignSave, this.heroSave);
      this.scene.start(SCENE_KEYS.battle, {
        launchRequest: createCampaignBattleLaunchRequest(this.heroSave, node, {
          modifiers: [
            ...getCampaignScenarioLaunchModifiers(node),
            ...modifierResult.launchModifiers,
            ...getReputationBattleLaunchModifiers(this.heroSave, node),
            ...getStrongholdLaunchModifiers(this.campaignSave),
            ...getRivalBattleLaunchModifiers(this.campaignSave, node)
          ],
          tacticalPlanId: this.selectedTacticalPlanId,
          retinueUnits: retinueDeploymentUnits(this.campaignSave),
          retinueReserveUnits: retinueReserveUnits(this.campaignSave)
        })
      });
      return;
    }

    if (node.choices && node.choices.length > 0) {
      this.message = "Choose an event option.";
      this.render();
      return;
    }

    const completed = completeCampaignNodeWithRewards({
      campaign: this.campaignSave,
      hero: this.heroSave,
      node
    });
    this.heroSave = completed.hero;
    this.campaignSave = completed.campaign;
    this.message = `${node.name} completed. ${formatNodeRewardSummary(node)}`;
    SaveSystem.saveGame(this.heroSave, this.campaignSave);
    this.render();
  }

  private startPrivateLumeDemo(): void {
    if (!isPrivatePlaytestToolsEnabled()) {
      this.message = "Private playtest tools are not available in this build.";
      this.render();
      return;
    }
    const node = selectedCampaignNode("aether_well_ruins");
    if (!node || node.nodeType !== "battle") {
      this.message = "Aether Well Lume demo is unavailable.";
      this.render();
      return;
    }

    this.scene.start(SCENE_KEYS.battle, {
      launchRequest: createCampaignBattleLaunchRequest(this.heroSave, node, {
        requestId: `private-playtest:${PRIVATE_LUME_DEMO_ID}:${node.mapId}`,
        sourceId: "private_playtest_aether_well_lume_demo",
        rewardsDisabled: true,
        privatePlaytestDemoId: PRIVATE_LUME_DEMO_ID,
        privatePlaytestNotice: PRIVATE_LUME_DEMO_NOTICE,
        modifiers: getCampaignScenarioLaunchModifiers(node),
        retinueUnits: [],
        retinueReserveUnits: []
      })
    });
  }

  private dismissRetinueUnit(retinueUnitId: string): void {
    if (!retinueUnitId) {
      return;
    }
    this.campaignSave = dismissRetinueUnit(this.campaignSave, retinueUnitId);
    this.message = "Retinue unit dismissed.";
    SaveSystem.saveGame(this.heroSave, this.campaignSave);
    this.render();
  }

  private selectTacticalPlan(value: string | undefined): void {
    this.selectedTacticalPlanId = normalizeTacticalPlanId(value);
    const plan = getTacticalPlan(this.selectedTacticalPlanId);
    this.message = `Tactical plan selected: ${plan.name}. ${plan.effectSummary}`;
    this.render();
  }

  private selectTab(value: string | undefined): void {
    if (!isCampaignTabId(value)) {
      return;
    }
    this.activeTab = value;
    this.render();
  }

  private toggleRetinueDeployment(retinueUnitId: string): void {
    if (!retinueUnitId) {
      return;
    }
    const result = toggleRetinueDeployment(this.campaignSave, retinueUnitId);
    this.campaignSave = result.campaign;
    this.message = result.ok
      ? result.selected
        ? "Retinue unit selected for deployment."
        : "Retinue unit moved to reserve."
      : result.reason ?? "Retinue deployment could not change.";
    SaveSystem.saveGame(this.heroSave, this.campaignSave);
    this.render();
  }

  private purchaseStrongholdUpgrade(upgradeId: string): void {
    const result = purchaseStrongholdUpgrade(this.campaignSave, upgradeId, this.heroSave);
    if (!result.ok) {
      this.message = result.reason ?? "That stronghold upgrade is locked.";
      this.render();
      return;
    }

    this.campaignSave = result.campaign;
    this.message = `${result.upgrade?.name ?? "Stronghold upgrade"} upgraded. Effects apply to future battles.`;
    SaveSystem.saveGame(this.heroSave, this.campaignSave);
    this.render();
  }

  private applySelectedChoice(choiceId: string): void {
    const node = this.selectedNode();
    const choice = node?.choices?.find((entry) => entry.id === choiceId);
    if (!node || !choice) {
      return;
    }

    const result = applyCampaignChoice({
      campaign: this.campaignSave,
      hero: this.heroSave,
      node,
      choice
    });
    if (!result.ok) {
      this.message = result.reason ?? "That choice is locked.";
      this.render();
      return;
    }

    this.heroSave = result.hero;
    this.campaignSave = result.campaign;
    this.message = formatCampaignChoiceResultMessage({ node, choice, heroSave: this.heroSave, result });
    SaveSystem.saveGame(this.heroSave, this.campaignSave);
    this.render();
  }

  private render(): void {
    if (!this.root) {
      return;
    }

    const viewModel = createCampaignMapViewModel({
      heroSave: this.heroSave,
      campaignSave: this.campaignSave,
      selectedNodeId: this.selectedNodeId
    });
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell campaign-shell asset-screen-bg" data-testid="campaign-map" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel extra-wide campaign-panel campaign-map-panel">
          <div class="progression-header campaign-top-strip">
            <div>
              <p class="eyebrow">Campaign Map</p>
              <h1>The Barrosan Marches</h1>
              <p class="menu-copy">${escapeHtml(viewModel.progressSummary)}</p>
            </div>
            <div class="skill-points">
              <span>Campaign</span>
              <strong>${viewModel.campaignStateLabel}</strong>
            </div>
          </div>
          <div class="status-box" data-testid="campaign-status">${escapeHtml(this.message)}</div>
          ${this.renderPrivatePlaytestTools()}
          ${this.renderCampaignTabs()}
          ${this.renderActiveTab(viewModel)}
          ${this.renderCampaignActions()}
        </section>
      </main>
    `;
  }

  private renderCampaignActions(): string {
    return `
      <div class="menu-actions row campaign-secondary-actions">
        <button data-testid="campaign-inventory" data-campaign-action="inventory">Hero Inventory</button>
        <button data-testid="campaign-main-menu" data-campaign-action="menu">Main Menu</button>
      </div>
    `;
  }

  private renderSelectedPrimaryAction(): string {
    const node = this.selectedNode();
    const hasChoices = Boolean(node?.choices?.length);
    const isReplay = Boolean(node && node.nodeType === "battle" && getCampaignNodeStatus(node, this.campaignSave) === "completed");
    const primaryLabel = node?.nodeType === "battle" ? (isReplay ? "Replay Battle" : "Start Battle") : "Resolve Node";
    return hasChoices
      ? ""
      : `<button class="campaign-primary-action" data-testid="campaign-start-node" data-campaign-action="start" ${this.canStartSelectedNode() ? "" : "disabled"}>${primaryLabel}</button>`;
  }

  private renderCampaignTabs(): string {
    return `
      <nav class="campaign-tabs" data-testid="campaign-tabs" aria-label="Campaign sections">
        ${CAMPAIGN_TABS.map(
          (tab) => `
            <button
              class="campaign-tab ${this.activeTab === tab.id ? "selected" : ""}"
              data-testid="campaign-tab-${tab.id}"
              data-campaign-tab="${tab.id}"
              aria-pressed="${this.activeTab === tab.id ? "true" : "false"}"
            >${escapeHtml(tab.label)}</button>
          `
        ).join("")}
      </nav>
    `;
  }

  private renderActiveTab(viewModel: ReturnType<typeof createCampaignMapViewModel>): string {
    if (this.activeTab === "stronghold") {
      return `
        <div class="campaign-tab-panel" data-testid="campaign-tab-panel-stronghold">
          <section class="campaign-support-grid">
            <div class="campaign-support-card">
              <h2>Campaign Bank</h2>
              ${renderCampaignResourceBank(this.campaignSave)}
              <details class="campaign-card-details">
                <summary>Active Modifiers</summary>
                ${renderActiveModifiers(this.campaignSave)}
              </details>
            </div>
            <div class="campaign-support-card">${renderStrongholdPanel(this.campaignSave, this.heroSave)}</div>
          </section>
        </div>
      `;
    }
    if (this.activeTab === "hero") {
      return `
        <div class="campaign-tab-panel" data-testid="campaign-tab-panel-hero">
          <section class="campaign-support-grid">
            <div class="campaign-support-card">
              <h2>Hero</h2>
              ${this.renderHeroSummary()}
              <details class="campaign-card-details" open>
                <summary>Next Step</summary>
                ${this.renderNextActionPanel()}
              </details>
            </div>
            <div class="campaign-support-card">${renderRetinuePanel(this.campaignSave)}</div>
          </section>
        </div>
      `;
    }
    if (this.activeTab === "inventory") {
      return `
        <div class="campaign-tab-panel compact" data-testid="campaign-tab-panel-inventory">
          <section class="campaign-support-card">
          <h2>Inventory And Progression</h2>
          ${this.renderHeroSummary()}
          <p class="quiet">Open Hero Inventory to equip rewards, inspect relic synergy, and spend skill points before launching the next battle.</p>
          <button data-testid="campaign-inventory-inline" data-campaign-action="inventory">Open Hero Inventory</button>
          <details class="campaign-card-details">
            <summary>Why Visit Inventory?</summary>
            <p class="quiet">Use this before harder missions to equip relics, spend skill points, and compare hero build support without changing campaign state.</p>
          </details>
          </section>
        </div>
      `;
    }
    if (this.activeTab === "intel") {
      return `
        <div class="campaign-tab-panel" data-testid="campaign-tab-panel-intel">
          <section class="campaign-support-grid">
            <div class="campaign-support-card">
              ${renderRivalIntelPanel(this.campaignSave)}
              <h2>Campaign Chapters</h2>
              ${renderCampaignChapterPanel(viewModel.chapters)}
            </div>
            <div class="campaign-support-card">
              <details class="campaign-card-details" open>
                <summary>Active Modifiers</summary>
                ${renderActiveModifiers(this.campaignSave)}
              </details>
            </div>
          </section>
        </div>
      `;
    }
    if (this.activeTab === "reputation") {
      return `
        <div class="campaign-tab-panel" data-testid="campaign-tab-panel-reputation">
          <section class="campaign-support-card">
          <h2>Reputation</h2>
          ${renderReputation(viewModel.reputation)}
          </section>
        </div>
      `;
    }
    return `
      <div class="campaign-map-workspace" data-testid="campaign-tab-panel-map">
        <section class="campaign-map-stage" aria-label="Campaign node map">
          <div class="campaign-map-grid" data-testid="campaign-map-grid">
            ${this.renderCampaignMapLanes(viewModel)}
            ${this.renderCampaignRouteLayer(viewModel.nodes)}
            <div class="campaign-node-layer">
              ${viewModel.nodes.map((node) => renderNodeButton(node)).join("")}
            </div>
          </div>
        </section>
        <aside class="campaign-selected-panel" data-testid="campaign-selected-panel">
          ${viewModel.selectedNode ? this.renderSelectedNodePanel(viewModel.selectedNode) : `<p class="quiet">No campaign node selected.</p>`}
        </aside>
      </div>
    `;
  }

  private renderSelectedNodePanel(node: CampaignNodeDefinition): string {
    const status = getCampaignNodeStatus(node, this.campaignSave);
    const missionReward = getCampaignMissionRewardState(this.campaignSave, node);
    const briefing = getCampaignMissionBriefing(node);
    const actStep = getCampaignActStepForNode(node.id);
    const description = shortDescription(node.description);
    const stateLabel = node.isPlaceholder ? "upcoming" : status === "completed" && node.nodeType === "battle" ? "completed / replayable" : status;
    const lockReason = status === "locked" || node.isPlaceholder ? getCampaignNodeLockedReason(node, this.campaignSave) : "";
    const pacingLabel = actStep ? `${actStep.pacingTier} - ${actStep.mechanicFocus}` : node.difficulty;
    const hasChoices = Boolean(node.choices?.length);
    const detailOpen = hasChoices ? " open" : "";
    return `
      <div class="campaign-selected-summary">
        <p class="eyebrow">${escapeHtml(node.nodeType)} - ${escapeHtml(stateLabel)}</p>
        <h2>${escapeHtml(node.name)}</h2>
        <p>${escapeHtml(description)}</p>
        <div class="campaign-selected-actions">
          ${this.renderSelectedPrimaryAction()}
        </div>
        <div class="results-grid compact campaign-selected-facts">
          <span>Mission type</span><strong>${escapeHtml(briefing?.missionType?.name ?? "Campaign node")}</strong>
          <span>Status</span><strong>${escapeHtml(missionReward.statusLabel)}</strong>
          <span>Primary objective</span><strong>${escapeHtml(briefing?.primaryObjective ?? "Complete the mission.")}</strong>
          <span>Reward</span><strong>${escapeHtml(briefing?.rewardPreview ?? missionReward.rewardLabel)}</strong>
          <span>Difficulty / pacing</span><strong>${escapeHtml(pacingLabel)}</strong>
          ${lockReason ? `<span>Lock reason</span><strong>${escapeHtml(lockReason)}</strong>` : ""}
        </div>
      </div>
      <details class="campaign-node-more"${detailOpen}>
        <summary>${hasChoices ? "Choices And Details" : "More Details"}</summary>
        ${renderNodeDetails({
          node,
          campaignSave: this.campaignSave,
          heroSave: this.heroSave,
          selectedTacticalPlanId: this.selectedTacticalPlanId
        })}
      </details>
    `;
  }

  private renderCampaignMapLanes(viewModel: CampaignMapViewModel): string {
    const border = viewModel.chapters.find((chapter) => chapter.chapter.id === "border_marches");
    const cinderfen = viewModel.chapters.find((chapter) => chapter.chapter.id === "cinderfen_road");
    return `
      <div class="campaign-map-lane lane-border-marches" data-testid="campaign-lane-border_marches">
        <strong data-testid="campaign-chapter-border_marches">${escapeHtml(border?.chapter.title ?? "Chapter 1: The Barrosan Marches")}</strong>
        <span>${escapeHtml(border?.statusLabel ?? "Unlocked")} - main Act 1 route</span>
      </div>
      <div class="campaign-map-lane lane-cinderfen-road" data-testid="campaign-lane-cinderfen_road">
        <strong data-testid="campaign-chapter-cinderfen_road">${escapeHtml(cinderfen?.chapter.title ?? "Chapter 2: Cinderfen Road")}</strong>
        <span>${escapeHtml(cinderfen?.statusLabel ?? "Locked")} - later route</span>
      </div>
    `;
  }

  private renderCampaignRouteLayer(nodes: CampaignNodeViewModel[]): string {
    const nodeById = new Map(nodes.map((node) => [node.node.id, node]));
    const routeKeys = new Set<string>();
    const lines: string[] = [];
    for (const source of nodes) {
      for (const unlockId of source.node.unlocks) {
        const target = nodeById.get(unlockId);
        if (!target || routeKeys.has(`${source.node.id}->${target.node.id}`)) {
          continue;
        }
        routeKeys.add(`${source.node.id}->${target.node.id}`);
        const complete = source.status === "completed";
        const available = source.status === "completed" || target.status === "available" || target.status === "completed";
        lines.push(
          `<line class="campaign-route ${complete ? "completed" : available ? "available" : "locked"}" x1="${source.mapX}%" y1="${source.mapY}%" x2="${target.mapX}%" y2="${target.mapY}%" />`
        );
      }
    }
    return `
      <svg class="campaign-route-layer" data-testid="campaign-route-layer" aria-hidden="true" focusable="false">
        ${lines.join("")}
      </svg>
    `;
  }

  private renderPrivatePlaytestTools(): string {
    if (!isPrivatePlaytestToolsEnabled()) {
      return "";
    }
    return `
      <section class="campaign-private-tools" data-testid="campaign-private-playtest-tools">
        <div>
          <strong>Private playtest tools</strong>
          <p>${escapeHtml(PRIVATE_LUME_DEMO_NOTICE)}</p>
        </div>
        <button data-testid="campaign-private-lume-demo" data-campaign-action="private-lume-demo">Launch Aether Well Lume Demo</button>
      </section>
    `;
  }

  private renderNextActionPanel(): string {
    const guidance = getCampaignNextAction(this.campaignSave, this.heroSave);
    return renderGuidanceMessage(guidance.title, guidance.body, guidance.actions);
  }

  private renderHeroSummary(): string {
    const heroClass = HERO_CLASS_BY_ID[this.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[this.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    const portraitId = heroPortraitAssetId(heroClass.id);
    const hasPortrait = AssetLoader.hasAsset(portraitId);
    return `
      <div class="hero-summary-card">
        <div class="portrait large ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, toCssColor(heroClass.color))}></div>
        <div>
          <strong>${escapeHtml(this.heroSave.heroName)} L${this.heroSave.level}</strong>
          <span>${escapeHtml(heroClass.name)} - ${escapeHtml(origin.name)}</span>
          <small>${this.heroSave.completedBattles} battles completed - ${this.heroSave.skillPoints} skill points</small>
        </div>
      </div>
    `;
  }

  private selectedNode(): CampaignNodeDefinition | undefined {
    return selectedCampaignNode(this.selectedNodeId);
  }

  private canStartSelectedNode(): boolean {
    return canStartCampaignNode(this.selectedNode(), this.campaignSave);
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}

function isCampaignTabId(value: string | undefined): value is CampaignTabId {
  return CAMPAIGN_TABS.some((tab) => tab.id === value);
}

function shortDescription(value: string): string {
  const trimmed = value.trim();
  if (trimmed.length <= 118) {
    return trimmed;
  }
  const sentenceEnd = trimmed.slice(0, 140).search(/[.!?]\s/u);
  if (sentenceEnd >= 52) {
    return trimmed.slice(0, sentenceEnd + 1);
  }
  return `${trimmed.slice(0, 115).trimEnd()}...`;
}
