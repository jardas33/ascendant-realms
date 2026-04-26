import Phaser from "phaser";
import { AssetLoader } from "../assets/AssetLoader";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { DEFAULT_SETTINGS, applySettingsToDocument, normalizeSettingsData } from "../core/Settings";
import { currentItemInSlot, equipResultsRewardItem, previewEquipDeltas } from "../results/ResultsEquipActions";
import { escapeHtml } from "../results/ResultsFormatting";
import {
  createCampaignMapReturnData,
  createInventorySceneData,
  createRetryBattleData,
  renderPrimaryActions
} from "../results/ResultsNavigation";
import { renderBattleSummary } from "../results/ResultsObjectiveSummary";
import { renderDefeatTips, renderHeroStats, renderVictoryRewards } from "../results/ResultsRewardPanel";
import type { ResultsData } from "../results/ResultsTypes";
import { createResultsViewModel, initialResultsStatus, type ResultsGuidanceViewModel } from "../results/ResultsViewModel";
import { AudioManager } from "../systems/AudioManager";

export class ResultsScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private dataSnapshot?: ResultsData;
  private status = "";

  constructor() {
    super(SCENE_KEYS.results);
  }

  init(data: ResultsData): void {
    this.dataSnapshot = data;
    this.status = initialResultsStatus(data);
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root || !this.dataSnapshot) {
      this.scene.start(SCENE_KEYS.mainMenu);
      return;
    }
    const settings = normalizeSettingsData(SaveSystem.load()?.settings ?? DEFAULT_SETTINGS);
    applySettingsToDocument(settings);
    AudioManager.configure(settings);
    AudioManager.play(this.dataSnapshot.stats.outcome === "victory" ? "victory" : "defeat");

    this.handler = (event) => this.handleResultsClick(event);
    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private handleResultsClick(event: MouseEvent): void {
    const button = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-results-action]");
    if (!button) {
      return;
    }
    AudioManager.play("ui_click");
    const action = button.dataset.resultsAction;
    const itemId = button.dataset.itemId ?? "";
    if (action === "equip") {
      this.equipRewardItem(itemId);
    }
    if (action === "retry") {
      this.retryBattle();
    }
    if (action === "campaign") {
      this.returnToCampaign();
    }
    if (action === "skirmish") {
      this.scene.start(SCENE_KEYS.skirmishSetup, {
        heroSave: this.dataSnapshot?.heroSave,
        launchRequest: this.dataSnapshot?.launchRequest
      });
    }
    if (action === "inventory" && this.dataSnapshot) {
      this.scene.start(SCENE_KEYS.heroProgression, createInventorySceneData(this.dataSnapshot));
    }
    if (action === "menu") {
      this.scene.start(SCENE_KEYS.mainMenu);
    }
  }

  private retryBattle(): void {
    if (!this.dataSnapshot) {
      return;
    }
    this.scene.start(SCENE_KEYS.battle, createRetryBattleData(this.dataSnapshot));
  }

  private returnToCampaign(): void {
    if (!this.dataSnapshot) {
      this.scene.start(SCENE_KEYS.mainMenu);
      return;
    }
    const save = SaveSystem.load();
    if (save) {
      this.scene.start(SCENE_KEYS.campaignMap, createCampaignMapReturnData(this.dataSnapshot, save));
      return;
    }
    this.scene.start(SCENE_KEYS.mainMenu);
  }

  private equipRewardItem(itemId: string): void {
    if (!this.dataSnapshot) {
      return;
    }
    const result = equipResultsRewardItem(this.dataSnapshot, itemId);
    this.status = result.message;
    if (result.ok) {
      this.dataSnapshot = result.data;
      SaveSystem.saveHero(result.data.heroSave);
    }
    this.render();
  }

  private render(): void {
    if (!this.root || !this.dataSnapshot) {
      return;
    }
    const data = this.dataSnapshot;
    const viewModel = createResultsViewModel(data);
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell progression-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: viewModel.backgroundId })}>
        <section class="menu-panel extra-wide results-panel ${data.stats.outcome}">
          <p class="eyebrow">Battle Results</p>
          <div class="results-title-row">
            <div>
              <h1>${viewModel.title}</h1>
              <p class="menu-copy">${escapeHtml(viewModel.subtitle)}</p>
            </div>
            <div class="skill-points compact">
              <span>Hero Level</span>
              <strong>${data.heroSave.level}</strong>
            </div>
          </div>
          ${renderBattleSummary(data, viewModel)}
          ${this.renderGuidancePanel(viewModel.guidance)}
          ${
            viewModel.isVictory
              ? renderVictoryRewards(data, {
                  currentItemInSlot: (slot) => currentItemInSlot(data, slot),
                  previewEquipDeltas: (itemInstanceId) => previewEquipDeltas(data, itemInstanceId)
                })
              : renderDefeatTips(data)
          }
          <div class="status-box">${escapeHtml(this.status)}</div>
          ${renderHeroStats(data)}
          <div class="menu-actions row">
            ${renderPrimaryActions(data)}
          </div>
        </section>
      </main>
    `;
  }

  private renderGuidancePanel(guidance: ResultsGuidanceViewModel): string {
    return `
      <section class="guidance-card results-guidance">
        <strong>${escapeHtml(guidance.title)}</strong>
        <p>${escapeHtml(guidance.body)}</p>
        <div class="tag-row">
          ${guidance.actions.map((action) => `<span class="tag">${escapeHtml(action)}</span>`).join("")}
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
