import Phaser from "phaser";
import { ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";

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

    this.handler = (event) => {
      const button = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-menu-action]");
      if (!button) {
        return;
      }
      const action = button.dataset.menuAction;
      if (action === "new") {
        this.scene.start(SCENE_KEYS.heroCreation);
      }
      if (action === "continue") {
        const save = SaveSystem.load();
        if (save) {
          this.scene.start(SCENE_KEYS.skirmishSetup, { heroSave: save.hero });
        }
      }
      if (action === "inventory") {
        const save = SaveSystem.load();
        if (save) {
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
      if (action === "credits") {
        this.render(true);
      }
    };
    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private render(showInfo = false): void {
    const hasSave = SaveSystem.hasSave();
    if (!this.root) {
      return;
    }
    const emblem = AssetLoader.imageHtml(ASSET_IDS.factions.freeMarches, "Free Marches emblem", "menu-emblem");
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel">
          ${emblem}
          <p class="eyebrow">Prototype v0.1</p>
          <h1>Ascendant Realms</h1>
          <p class="menu-copy">Create a persistent fantasy hero, capture resource sites, raise a small army, and break the enemy stronghold.</p>
          <div class="menu-actions">
            <button data-menu-action="new">Start Skirmish</button>
            <button data-menu-action="continue" ${hasSave ? "" : "disabled"}>Continue Hero</button>
            <button data-menu-action="inventory" ${hasSave ? "" : "disabled"}>Hero Inventory</button>
            <button data-menu-action="assets">Asset Gallery</button>
            <button data-menu-action="reset" ${hasSave ? "" : "disabled"}>Reset Save</button>
            <button data-menu-action="credits">Credits / Info</button>
          </div>
          ${
            showInfo
              ? `<div class="info-box">Original prototype inspired by classic RTS/RPG hybrids. Uses local manual art when files exist, then falls back to placeholders. No copyrighted assets, names, factions, maps, music, or API image calls are included.</div>`
              : ""
          }
        </section>
      </main>
    `;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}
