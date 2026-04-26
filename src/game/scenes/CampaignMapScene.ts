import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createCampaignBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { BattleStats, CampaignNodeDefinition, CampaignNodeStatus } from "../core/GameTypes";
import {
  completeCampaignNodeWithRewards,
  createStartedCampaignSave,
  getCampaignNodeStatus,
  getCampaignProgressSummary,
  refreshCampaignUnlocks
} from "../core/CampaignRules";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { FACTION_BY_ID, HERO_CLASS_BY_ID, ITEM_BY_ID, MAP_BY_ID, ORIGIN_BY_ID } from "../data/contentIndex";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";

interface CampaignMapData {
  heroSave?: HeroSaveData;
  campaignSave?: CampaignSaveData;
  completedNodeId?: string;
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
    this.message = data.message ?? this.messageForData(data);
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
        this.campaignSave = { ...this.campaignSave, selectedNodeId: this.selectedNodeId };
        SaveSystem.saveCampaign(this.campaignSave, this.heroSave);
        this.render();
        return;
      }

      const action = target.closest<HTMLButtonElement>("button[data-campaign-action]")?.dataset.campaignAction;
      if (action === "start") {
        this.startSelectedNode();
      }
      if (action === "menu") {
        this.scene.start(SCENE_KEYS.mainMenu);
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
    if (status !== "available") {
      this.message = "That node is not available yet.";
      this.render();
      return;
    }

    if (node.nodeType === "battle") {
      this.scene.start(SCENE_KEYS.battle, {
        launchRequest: createCampaignBattleLaunchRequest(this.heroSave, node)
      });
      return;
    }

    const completed = completeCampaignNodeWithRewards({
      campaign: this.campaignSave,
      hero: this.heroSave,
      node
    });
    this.heroSave = completed.hero;
    this.campaignSave = completed.campaign;
    this.message = `${node.name} completed. ${this.formatNodeRewardSummary(node)}`;
    SaveSystem.saveGame(this.heroSave, this.campaignSave);
    this.render();
  }

  private render(): void {
    if (!this.root) {
      return;
    }

    const selectedNode = this.selectedNode();
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell campaign-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel extra-wide campaign-panel">
          <div class="progression-header">
            <div>
              <p class="eyebrow">Campaign Map</p>
              <h1>Border Marches</h1>
              <p class="menu-copy">${escapeHtml(getCampaignProgressSummary(this.campaignSave))}</p>
            </div>
            <div class="skill-points">
              <span>Campaign</span>
              <strong>${this.campaignSave.started ? "Live" : "New"}</strong>
            </div>
          </div>
          <div class="status-box">${escapeHtml(this.message)}</div>
          <div class="campaign-layout">
            <section>
              <h2>Hero</h2>
              ${this.renderHeroSummary()}
              <h2>Nodes</h2>
              <div class="campaign-map-grid">
                ${CAMPAIGN_NODES.map((node) => this.renderNodeButton(node)).join("")}
              </div>
            </section>
            <section>
              <h2>Selected Node</h2>
              ${selectedNode ? this.renderNodeDetails(selectedNode) : `<p class="quiet">No campaign node selected.</p>`}
            </section>
          </div>
          <div class="menu-actions row">
            <button data-campaign-action="start" ${this.canStartSelectedNode() ? "" : "disabled"}>${this.selectedNode()?.nodeType === "battle" ? "Start Battle" : "Resolve Node"}</button>
            <button data-campaign-action="menu">Main Menu</button>
          </div>
        </section>
      </main>
    `;
  }

  private renderHeroSummary(): string {
    const heroClass = HERO_CLASS_BY_ID[this.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[this.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    const portraitId = heroPortraitAssetId(heroClass.id);
    const hasPortrait = AssetLoader.hasAsset(portraitId);
    return `
      <div class="hero-summary-card">
        <div class="portrait large ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, this.toCssColor(heroClass.color))}></div>
        <div>
          <strong>${escapeHtml(this.heroSave.heroName)} L${this.heroSave.level}</strong>
          <span>${escapeHtml(heroClass.name)} - ${escapeHtml(origin.name)}</span>
          <small>${this.heroSave.completedBattles} battles completed - ${this.heroSave.skillPoints} skill points</small>
        </div>
      </div>
    `;
  }

  private renderNodeButton(node: CampaignNodeDefinition): string {
    const status = getCampaignNodeStatus(node, this.campaignSave);
    const selected = node.id === this.selectedNodeId;
    return `
      <button
        class="campaign-node ${status} ${selected ? "selected" : ""}"
        data-campaign-node="${node.id}"
        style="--node-x: ${node.x}%; --node-y: ${node.y}%"
      >
        <strong>${escapeHtml(node.name)}</strong>
        <span>${titleCase(node.nodeType)} - ${titleCase(status)}</span>
      </button>
    `;
  }

  private renderNodeDetails(node: CampaignNodeDefinition): string {
    const status = getCampaignNodeStatus(node, this.campaignSave);
    const map = MAP_BY_ID[node.mapId];
    const faction = FACTION_BY_ID[node.enemyFactionId];
    return `
      <div class="campaign-node-details ${status}">
        <p class="eyebrow">${titleCase(node.nodeType)} - ${titleCase(status)}</p>
        <h3>${escapeHtml(node.name)}</h3>
        <p>${escapeHtml(node.description)}</p>
        <div class="results-grid compact">
          <span>Map</span><strong>${escapeHtml(map?.name ?? node.mapId)}</strong>
          <span>Difficulty</span><strong>${titleCase(node.difficulty)}</strong>
          <span>Enemy</span><strong>${escapeHtml(faction?.name ?? node.enemyFactionId)}</strong>
          <span>Prerequisites</span><strong>${escapeHtml(this.formatNodeList(node.prerequisites) || "None")}</strong>
          <span>Unlocks</span><strong>${escapeHtml(this.formatNodeList(node.unlocks) || "None")}</strong>
          <span>Rewards</span><strong>${escapeHtml(this.formatNodeRewardSummary(node))}</strong>
        </div>
      </div>
    `;
  }

  private selectedNode(): CampaignNodeDefinition | undefined {
    return CAMPAIGN_NODES.find((node) => node.id === this.selectedNodeId) ?? CAMPAIGN_NODES[0];
  }

  private canStartSelectedNode(): boolean {
    const node = this.selectedNode();
    return Boolean(node && getCampaignNodeStatus(node, this.campaignSave) === "available");
  }

  private formatNodeList(nodeIds: string[]): string {
    return nodeIds
      .map((nodeId) => CAMPAIGN_NODES.find((node) => node.id === nodeId)?.name ?? nodeId)
      .join(", ");
  }

  private formatNodeRewardSummary(node: CampaignNodeDefinition): string {
    const itemNames = (node.rewards.itemIds ?? []).map((itemId) => ITEM_BY_ID[itemId]?.name ?? itemId);
    const resources = Object.entries(node.rewards.resources ?? {})
      .filter(([, amount]) => typeof amount === "number" && amount > 0)
      .map(([resource, amount]) => `${amount} ${titleCase(resource)}`);
    const rewards = [...itemNames, ...resources];
    if (node.rewards.xp) {
      rewards.unshift(`${node.rewards.xp} XP`);
    }
    return rewards.length > 0 ? rewards.join(", ") : "No listed reward";
  }

  private messageForData(data: CampaignMapData): string {
    if (data.completedNodeId) {
      const node = CAMPAIGN_NODES.find((entry) => entry.id === data.completedNodeId);
      return node ? `${node.name} completed. New paths may be available.` : "Campaign progress saved.";
    }
    if (data.stats?.outcome === "defeat") {
      return "Defeat recorded. Choose the same node to retry when ready.";
    }
    return "Choose an available campaign node.";
  }

  private toCssColor(value: number): string {
    return `#${value.toString(16).padStart(6, "0")}`;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}

function firstAvailableNodeId(save: CampaignSaveData): string {
  return CAMPAIGN_NODES.find((node) => getCampaignNodeStatus(node, save) === "available")?.id ?? CAMPAIGN_NODES[0]?.id ?? "";
}

function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
