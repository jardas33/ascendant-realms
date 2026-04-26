import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createCampaignBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { getCampaignNextAction, getCampaignNodeGuidance } from "../core/FirstExperienceGuidance";
import type { BattleStats, CampaignNodeDefinition, CampaignNodeStatus, ResourceBag } from "../core/GameTypes";
import {
  applyCampaignChoice,
  completeCampaignNodeWithRewards,
  createStartedCampaignSave,
  getCampaignChoiceAvailability,
  getCampaignNodeStatus,
  getCampaignProgressSummary,
  refreshCampaignUnlocks
} from "../core/CampaignRules";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import {
  AI_PERSONALITY_BY_ID,
  CAMPAIGN_MODIFIER_BY_ID,
  FACTION_BY_ID,
  HERO_CLASS_BY_ID,
  ITEM_BY_ID,
  MAP_BY_ID,
  ORIGIN_BY_ID
} from "../data/contentIndex";
import { consumeBattleCampaignModifiers } from "../data/campaignModifiers";
import { RESOURCE_DEFINITIONS } from "../data/resources";
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

      const choiceButton = target.closest<HTMLButtonElement>("button[data-campaign-choice]");
      if (choiceButton) {
        this.applySelectedChoice(choiceButton.dataset.campaignChoice ?? "");
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
    if (status !== "available") {
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
          modifiers: modifierResult.launchModifiers
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
    this.message = `${node.name} completed. ${this.formatNodeRewardSummary(node)}`;
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
    const rewards = this.formatChoiceRewardSummary(choice);
    const unlocked = result.unlockedNodeIds.map((nodeId) => CAMPAIGN_NODES.find((entry) => entry.id === nodeId)?.name ?? nodeId);
    const locked = result.lockedNodeIds.map((nodeId) => CAMPAIGN_NODES.find((entry) => entry.id === nodeId)?.name ?? nodeId);
    const modifiers = result.grantedModifierIds.map((modifierId) => CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? modifierId);
    this.message = `${choice.label} chosen.${rewards ? ` ${rewards}.` : ""}${modifiers.length > 0 ? ` Modifier gained: ${modifiers.join(", ")}.` : ""}${unlocked.length > 0 ? ` New path: ${unlocked.join(", ")}.` : ""}${locked.length > 0 ? ` Path closed: ${locked.join(", ")}.` : ""}`;
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
          ${this.renderNextActionPanel()}
          <div class="campaign-layout">
            <section>
              <h2>Hero</h2>
              ${this.renderHeroSummary()}
              <h2>Campaign Bank</h2>
              ${this.renderCampaignResourceBank()}
              <h2>Reputation</h2>
              ${this.renderReputation()}
              <h2>Active Modifiers</h2>
              ${this.renderActiveModifiers()}
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
          ${this.renderCampaignActions()}
        </section>
      </main>
    `;
  }

  private renderCampaignActions(): string {
    const node = this.selectedNode();
    const hasChoices = Boolean(node?.choices?.length);
    const primaryLabel = node?.nodeType === "battle" ? "Start Battle" : "Resolve Node";
    return `
      <div class="menu-actions row">
        ${hasChoices ? "" : `<button data-campaign-action="start" ${this.canStartSelectedNode() ? "" : "disabled"}>${primaryLabel}</button>`}
        <button data-campaign-action="inventory">Hero Inventory</button>
        <button data-campaign-action="menu">Main Menu</button>
      </div>
    `;
  }

  private renderNextActionPanel(): string {
    const guidance = getCampaignNextAction(this.campaignSave, this.heroSave);
    return this.renderGuidanceMessage(guidance.title, guidance.body, guidance.actions);
  }

  private renderCampaignResourceBank(): string {
    return `
      <div class="campaign-bank">
        ${RESOURCE_DEFINITIONS.map(
          (resource) => `
            <div class="resource-pill campaign-bank-pill" style="--resource-color: #${resource.color.toString(16).padStart(6, "0")}">
              <span>${escapeHtml(resource.name)}</span>
              <strong>${this.campaignSave.resources[resource.id]}</strong>
            </div>
          `
        ).join("")}
      </div>
      <p class="quiet campaign-bank-note">Campaign resources are saved between nodes. Event choices can spend them now; future shops, mercenaries, repairs, upgrades, and stronghold development will use this bank too.</p>
    `;
  }

  private renderReputation(): string {
    const reputationIds = ["free_marches", "ashen_covenant", "sylvan_concord", "common_folk", "old_faith"];
    return `
      <div class="reputation-grid">
        ${reputationIds
          .map((factionId) => {
            const faction = FACTION_BY_ID[factionId];
            const value = this.heroSave.factionReputation[factionId] ?? 0;
            return `
              <div class="reputation-row">
                <span>${escapeHtml(faction?.name ?? titleCase(factionId))}</span>
                <strong class="${value < 0 ? "negative" : value > 0 ? "positive" : ""}">${value > 0 ? "+" : ""}${value}</strong>
              </div>
            `;
          })
          .join("")}
      </div>
    `;
  }

  private renderActiveModifiers(): string {
    const modifiers = this.campaignSave.activeModifierIds
      .map((modifierId) => CAMPAIGN_MODIFIER_BY_ID[modifierId])
      .filter(Boolean);
    if (modifiers.length === 0) {
      return `<p class="quiet">No active campaign modifiers.</p>`;
    }
    return `
      <div class="modifier-list">
        ${modifiers
          .map(
            (modifier) => `
              <div class="modifier-card">
                <strong>${escapeHtml(modifier.name)}</strong>
                <span>${escapeHtml(modifier.description)}</span>
                <small>${escapeHtml(modifier.durationLabel)}</small>
              </div>
            `
          )
          .join("")}
      </div>
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
    const personality = node.aiPersonalityId ? AI_PERSONALITY_BY_ID[node.aiPersonalityId] : undefined;
    const nodeGuidance = getCampaignNodeGuidance(node.id);
    return `
      <div class="campaign-node-details ${status}">
        <p class="eyebrow">${titleCase(node.nodeType)} - ${titleCase(status)}</p>
        <h3>${escapeHtml(node.name)}</h3>
        <p>${escapeHtml(node.description)}</p>
        ${this.renderGuidanceMessage(nodeGuidance.title, nodeGuidance.body, nodeGuidance.actions, "compact")}
        <div class="results-grid compact">
          <span>Map</span><strong>${escapeHtml(map?.name ?? node.mapId)}</strong>
          <span>Difficulty</span><strong>${titleCase(node.difficulty)}</strong>
          <span>Enemy</span><strong>${escapeHtml(faction?.name ?? node.enemyFactionId)}</strong>
          <span>Enemy Style</span><strong>${escapeHtml(personality ? `${personality.name}: ${personality.shortDescription}` : "Balanced Warlord: Mixed expansion and attacks.")}</strong>
          <span>Prerequisites</span><strong>${escapeHtml(this.formatNodeList(node.prerequisites) || "None")}</strong>
          <span>Unlocks</span><strong>${escapeHtml(this.formatNodeList(node.unlocks) || "None")}</strong>
          <span>XP reward</span><strong>${node.rewards.xp ?? 0}</strong>
          <span>Item reward</span><strong>${escapeHtml(this.formatNodeItemRewards(node).join(", ") || "None")}</strong>
          <span>Resource reward</span><strong>${escapeHtml(this.formatResourceRewards(node.rewards.resources ?? {}).join(", ") || "None")}</strong>
        </div>
        ${
          faction
            ? this.renderGuidanceMessage(
                `${faction.name} doctrine`,
                `${faction.mechanics.economyStyle} ${faction.mechanics.militaryStyle} ${faction.mechanics.magicStyle}`,
                faction.mechanics.factionModifiers.map((modifier) => modifier.name),
                "compact"
              )
            : ""
        }
        ${node.eventText ? `<div class="event-text">${escapeHtml(node.eventText)}</div>` : ""}
        ${node.choices?.length ? this.renderEventChoices(node, status) : ""}
      </div>
    `;
  }

  private renderGuidanceMessage(title: string, body: string, actions: string[], variant = ""): string {
    return `
      <div class="guidance-card ${variant}">
        <strong>${escapeHtml(title)}</strong>
        <p>${escapeHtml(body)}</p>
        <div class="tag-row">
          ${actions.map((action) => `<span class="tag">${escapeHtml(action)}</span>`).join("")}
        </div>
      </div>
    `;
  }

  private renderEventChoices(node: CampaignNodeDefinition, status: CampaignNodeStatus): string {
    return `
      <div class="event-choice-list">
        <h4>Choices</h4>
        ${node.choices
          ?.map((choice) => {
            const availability = getCampaignChoiceAvailability({
              campaign: this.campaignSave,
              hero: this.heroSave,
              node,
              choice
            });
            const locked = status === "locked" || !availability.ok;
            const reason = availability.reasons.join(", ");
            return `
              <button class="choice event-choice ${locked ? "locked" : ""}" data-campaign-choice="${choice.id}" ${locked ? "disabled" : ""}>
                <strong>${escapeHtml(choice.label)}</strong>
                <span>${escapeHtml(choice.description)}</span>
                <small>Cost: ${escapeHtml(this.formatResourceRewards(choice.costs ?? {}).join(", ") || "None")}</small>
                <small>Reward: ${escapeHtml(this.formatChoiceRewardSummary(choice) || "None")}</small>
                <small>${locked ? escapeHtml(reason || "Locked") : choice.completesNode === false ? "Keeps this node open." : "Completes this node."}</small>
              </button>
            `;
          })
          .join("")}
      </div>
    `;
  }

  private selectedNode(): CampaignNodeDefinition | undefined {
    return CAMPAIGN_NODES.find((node) => node.id === this.selectedNodeId) ?? CAMPAIGN_NODES[0];
  }

  private canStartSelectedNode(): boolean {
    const node = this.selectedNode();
    return Boolean(node && !node.choices?.length && getCampaignNodeStatus(node, this.campaignSave) === "available");
  }

  private formatNodeList(nodeIds: string[]): string {
    return nodeIds
      .map((nodeId) => CAMPAIGN_NODES.find((node) => node.id === nodeId)?.name ?? nodeId)
      .join(", ");
  }

  private formatNodeRewardSummary(node: CampaignNodeDefinition): string {
    const itemNames = this.formatNodeItemRewards(node);
    const resources = this.formatResourceRewards(node.rewards.resources ?? {});
    const rewards = [...itemNames, ...resources];
    if (node.rewards.xp) {
      rewards.unshift(`${node.rewards.xp} XP`);
    }
    return rewards.length > 0 ? rewards.join(", ") : "No listed reward";
  }

  private formatChoiceRewardSummary(choice: NonNullable<CampaignNodeDefinition["choices"]>[number]): string {
    const rewards: string[] = [];
    if (choice.rewards?.xp) {
      rewards.push(`${choice.rewards.xp} XP`);
    }
    rewards.push(...this.formatResourceRewards(choice.rewards?.resources ?? {}));
    (choice.rewards?.itemIds ?? []).forEach((itemId) => rewards.push(ITEM_BY_ID[itemId]?.name ?? itemId));
    [...(choice.modifierIds ?? []), ...(choice.rewards?.modifierIds ?? [])].forEach((modifierId) => {
      rewards.push(`Modifier: ${CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? titleCase(modifierId)}`);
    });
    const reputationChanges = {
      ...(choice.reputationChanges ?? {}),
      ...(choice.rewards?.reputationChanges ?? {})
    };
    Object.entries(reputationChanges).forEach(([factionId, amount]) => {
      rewards.push(`${amount > 0 ? "+" : ""}${amount} ${FACTION_BY_ID[factionId]?.name ?? titleCase(factionId)} reputation`);
    });
    (choice.unlockNodeIds ?? []).forEach((nodeId) => rewards.push(`Unlock ${this.formatNodeList([nodeId])}`));
    (choice.rewards?.unlockNodeIds ?? []).forEach((nodeId) => rewards.push(`Unlock ${this.formatNodeList([nodeId])}`));
    (choice.lockNodeIds ?? []).forEach((nodeId) => rewards.push(`Lock ${this.formatNodeList([nodeId])}`));
    (choice.rewards?.lockNodeIds ?? []).forEach((nodeId) => rewards.push(`Lock ${this.formatNodeList([nodeId])}`));
    [...(choice.removeModifierIds ?? []), ...(choice.rewards?.removeModifierIds ?? [])].forEach((modifierId) => {
      rewards.push(`Remove ${CAMPAIGN_MODIFIER_BY_ID[modifierId]?.name ?? titleCase(modifierId)}`);
    });
    if (choice.rewards?.recoverHero) {
      rewards.push("Recover hero");
    }
    return rewards.join(", ");
  }

  private formatNodeItemRewards(node: CampaignNodeDefinition): string[] {
    return (node.rewards.itemIds ?? []).map((itemId) => ITEM_BY_ID[itemId]?.name ?? itemId);
  }

  private formatResourceRewards(resources: Partial<ResourceBag>): string[] {
    return Object.entries(resources)
      .filter(([, amount]) => typeof amount === "number" && amount > 0)
      .map(([resource, amount]) => {
        const definition = RESOURCE_DEFINITIONS.find((entry) => entry.id === resource);
        return `${amount} ${definition?.name ?? titleCase(resource)}`;
      });
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
