import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createCampaignBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { getCampaignNextAction } from "../core/FirstExperienceGuidance";
import type { BattleStats, CampaignNodeDefinition } from "../core/GameTypes";
import {
  applyCampaignChoice,
  completeCampaignNodeWithRewards,
  createStartedCampaignSave,
  getCampaignNodeStatus,
  refreshCampaignUnlocks
} from "../core/CampaignRules";
import { getStrongholdLaunchModifiers, purchaseStrongholdUpgrade } from "../core/StrongholdRules";
import { getRivalBattleLaunchModifiers } from "../core/RivalRules";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { HERO_CLASS_BY_ID, ORIGIN_BY_ID } from "../data/contentIndex";
import { consumeBattleCampaignModifiers } from "../data/campaignModifiers";
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
import { escapeHtml, toCssColor } from "../campaign/CampaignPresentationTypes";
import {
  renderActiveModifiers,
  renderCampaignResourceBank,
  renderReputation
} from "../campaign/CampaignResourcePanel";
import { renderRetinuePanel } from "../campaign/RetinuePanel";
import { renderRivalIntelPanel } from "../campaign/RivalIntelPanel";
import { renderStrongholdPanel } from "../campaign/StrongholdPanel";
import { dismissRetinueUnit, retinueDeploymentUnits } from "../core/RetinueRules";

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

      const retinueDismissButton = target.closest<HTMLButtonElement>("button[data-retinue-dismiss]");
      if (retinueDismissButton) {
        this.dismissRetinueUnit(retinueDismissButton.dataset.retinueDismiss ?? "");
        return;
      }

      const action = target.closest<HTMLButtonElement>("button[data-campaign-action]")?.dataset.campaignAction;
      if (action === "start") {
        this.startSelectedNode();
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
            ...modifierResult.launchModifiers,
            ...getReputationBattleLaunchModifiers(this.heroSave, node),
            ...getStrongholdLaunchModifiers(this.campaignSave),
            ...getRivalBattleLaunchModifiers(this.campaignSave, node)
          ],
          retinueUnits: retinueDeploymentUnits(this.campaignSave)
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

  private dismissRetinueUnit(retinueUnitId: string): void {
    if (!retinueUnitId) {
      return;
    }
    this.campaignSave = dismissRetinueUnit(this.campaignSave, retinueUnitId);
    this.message = "Retinue unit dismissed.";
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
        <section class="menu-panel extra-wide campaign-panel">
          <div class="progression-header">
            <div>
              <p class="eyebrow">Campaign Map</p>
              <h1>Border Marches</h1>
              <p class="menu-copy">${escapeHtml(viewModel.progressSummary)}</p>
            </div>
            <div class="skill-points">
              <span>Campaign</span>
              <strong>${viewModel.campaignStateLabel}</strong>
            </div>
          </div>
          <div class="status-box" data-testid="campaign-status">${escapeHtml(this.message)}</div>
          ${this.renderNextActionPanel()}
          <div class="campaign-layout">
            <section>
              <h2>Hero</h2>
              ${this.renderHeroSummary()}
              <h2>Campaign Bank</h2>
              ${renderCampaignResourceBank(this.campaignSave)}
              ${renderStrongholdPanel(this.campaignSave, this.heroSave)}
              ${renderRetinuePanel(this.campaignSave)}
              ${renderRivalIntelPanel(this.campaignSave)}
              <h2>Reputation</h2>
              ${renderReputation(viewModel.reputation)}
              <h2>Active Modifiers</h2>
              ${renderActiveModifiers(this.campaignSave)}
              <h2>Campaign Chapters</h2>
              ${renderCampaignChapterPanel(viewModel.chapters)}
              <h2>Nodes</h2>
              <div class="campaign-map-grid">
                ${viewModel.nodes.map((node) => renderNodeButton(node)).join("")}
              </div>
            </section>
            <section>
              <h2>Selected Node</h2>
              ${viewModel.selectedNode ? renderNodeDetails({ node: viewModel.selectedNode, campaignSave: this.campaignSave, heroSave: this.heroSave }) : `<p class="quiet">No campaign node selected.</p>`}
            </section>
          </div>
          ${this.renderCampaignActions()}
        </section>
      </main>
    `;
  }

  private renderCampaignActions(): string {
    const node = this.selectedNode();
    const hasChoices = Boolean(node?.choices?.length);
    const isReplay = Boolean(node && node.nodeType === "battle" && getCampaignNodeStatus(node, this.campaignSave) === "completed");
    const primaryLabel = node?.nodeType === "battle" ? (isReplay ? "Replay Battle" : "Start Battle") : "Resolve Node";
    return `
      <div class="menu-actions row">
        ${hasChoices ? "" : `<button data-testid="campaign-start-node" data-campaign-action="start" ${this.canStartSelectedNode() ? "" : "disabled"}>${primaryLabel}</button>`}
        <button data-testid="campaign-inventory" data-campaign-action="inventory">Hero Inventory</button>
        <button data-testid="campaign-main-menu" data-campaign-action="menu">Main Menu</button>
      </div>
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
