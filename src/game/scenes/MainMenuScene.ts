import Phaser from "phaser";
import { ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createTutorialBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { DEFAULT_SETTINGS, applySettingsToDocument, normalizeSettingsData } from "../core/Settings";
import { createNewHeroSave } from "../data/heroes";
import { TUTORIALS } from "../data/tutorials";
import { AudioManager } from "../systems/AudioManager";

export class MainMenuScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;

  constructor() {
    super(SCENE_KEYS.mainMenu);
  }

  create(): void {
    this.cameras.main.setBackgroundColor("#17211c");
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }
    const settings = normalizeSettingsData(SaveSystem.load()?.settings ?? DEFAULT_SETTINGS);
    applySettingsToDocument(settings);
    AudioManager.configure(settings);

    this.handler = (event) => {
      const button = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-menu-action]");
      if (!button) {
        return;
      }
      AudioManager.play("ui_click");
      const action = button.dataset.menuAction;
      if (action === "campaign-new") {
        const save = SaveSystem.load();
        if (!save || SaveSystem.isSettingsOnlySave(save)) {
          this.scene.start(SCENE_KEYS.heroCreation, { nextMode: "campaign" });
          return;
        }
        const campaign = createStartedCampaignSave();
        SaveSystem.saveGame(save.hero, campaign);
        this.scene.start(SCENE_KEYS.campaignMap, { heroSave: save.hero, campaignSave: campaign });
      }
      if (action === "campaign-continue") {
        const save = SaveSystem.load();
        if (save && !SaveSystem.isSettingsOnlySave(save)) {
          this.scene.start(SCENE_KEYS.campaignMap, { heroSave: save.hero, campaignSave: save.campaign });
        }
      }
      if (action === "skirmish") {
        const save = SaveSystem.load();
        if (save && !SaveSystem.isSettingsOnlySave(save)) {
          this.scene.start(SCENE_KEYS.skirmishSetup, { heroSave: save.hero });
          return;
        }
        this.scene.start(SCENE_KEYS.heroCreation, { nextMode: "skirmish" });
      }
      if (action === "inventory") {
        const save = SaveSystem.load();
        if (save && !SaveSystem.isSettingsOnlySave(save)) {
          this.scene.start(SCENE_KEYS.heroProgression, { heroSave: save.hero });
        }
      }
      if (action === "assets") {
        this.scene.start(SCENE_KEYS.assetGallery);
      }
      if (action === "reset") {
        SaveSystem.reset();
        this.render();
      }
      if (action === "tutorial") {
        this.startTutorial();
      }
      if (action === "menu-home") {
        this.render();
      }
      if (action === "settings") {
        this.scene.start(SCENE_KEYS.settings);
      }
      if (action === "credits") {
        this.render(true);
      }
    };
    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private render(showInfo = false, showTutorialInfo = false): void {
    const save = SaveSystem.load();
    const hasSave = Boolean(save && !SaveSystem.isSettingsOnlySave(save));
    const hasAnySave = Boolean(save);
    const hasCampaign = Boolean(save?.campaign.started);
    if (!this.root) {
      return;
    }
    const emblem = AssetLoader.imageHtml(ASSET_IDS.factions.freeMarches, "Free Marches emblem", "menu-emblem");
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell asset-screen-bg" data-testid="main-menu" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel">
          ${emblem}
          <p class="eyebrow">Prototype v0.3</p>
          <h1>Ascendant Realms</h1>
          <p class="menu-copy">Cinderfen Route Baseline</p>
          <p class="menu-copy">Create a persistent fantasy hero, capture resource sites, raise a small army, and break the enemy stronghold.</p>
          <div class="menu-actions">
            <button data-testid="menu-new-campaign" data-menu-action="campaign-new">${hasSave ? "New Campaign" : "New Campaign"}</button>
            <button data-testid="menu-continue-campaign" data-menu-action="campaign-continue" ${hasCampaign ? "" : "disabled"}>Continue Campaign</button>
            <button data-testid="menu-tutorial" data-menu-action="tutorial">Tutorial</button>
            <button data-testid="menu-skirmish" data-menu-action="skirmish">Skirmish</button>
            <button data-testid="menu-inventory" data-menu-action="inventory" ${hasSave ? "" : "disabled"}>Hero Inventory</button>
            <button data-testid="menu-asset-gallery" data-menu-action="assets">Asset Gallery</button>
            <button data-testid="menu-settings" data-menu-action="settings">Settings</button>
            <button data-testid="menu-reset-save" data-menu-action="reset" ${hasAnySave ? "" : "disabled"}>Reset Save</button>
            <button data-menu-action="credits">Credits / Info</button>
          </div>
          ${
            showInfo
              ? `<div class="info-box">Original prototype inspired by classic RTS/RPG hybrids. Normal units gain ranks during battle; selected surviving Seasoned or better veterans can be saved to the Retinue Camp after campaign victories, then persist into future campaign battles. Retinue death is permanent in V1. Uses local manual art when files exist, then falls back to placeholders. No copyrighted assets, names, factions, maps, music, or API image calls are included.</div>`
              : ""
          }
          ${
            showTutorialInfo
              ? `<div class="info-box tutorial-info" data-testid="tutorial-info-panel">
                  <strong>Proving Grounds</strong>
                  <p>Learn camera, selection, movement, capture, building, training, rally points, and hero basics.</p>
                  <p>Playable tutorial coming next. This training path will not grant rewards or campaign progress.</p>
                  <button data-testid="tutorial-info-back" data-menu-action="menu-home">Back to Menu</button>
                </div>`
              : ""
          }
        </section>
      </main>
    `;
  }

  private startTutorial(): void {
    const tutorial = TUTORIALS.find((entry) => entry.id === "proving_grounds_basics");
    if (!tutorial || tutorial.status !== "playable") {
      this.render(false, true);
      return;
    }
    const heroSave = createNewHeroSave("Aster", "warlord", "exiled_noble");
    const launchRequest = createTutorialBattleLaunchRequest(heroSave, {
      mapId: tutorial.mapId,
      sourceId: tutorial.id
    });
    this.scene.start(SCENE_KEYS.battle, { heroSave, launchRequest });
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}
