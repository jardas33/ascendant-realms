import Phaser from "phaser";
import { ASSET_MANIFEST_CACHE_KEY, BATTLE_TEXTURE_ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { SCENE_KEYS } from "../core/SceneKeys";
import { validateContent } from "../data/contentValidation";

export class BootScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.boot);
  }

  preload(): void {
    this.load.json(ASSET_MANIFEST_CACHE_KEY, AssetLoader.manifestUrl());
  }

  create(): void {
    const root = document.getElementById("ui-root");
    if (root) {
      root.innerHTML = "";
      root.className = "ui-root";
    }
    const manifest = AssetLoader.readCachedManifest(this);
    AssetLoader.setManifest(manifest);
    AssetLoader.applyUiKitCssVariables();

    const contentErrors = validateContent();
    if (contentErrors.length > 0) {
      this.renderContentError(contentErrors);
      return;
    }

    const queuedImages = AssetLoader.queueAvailableImages(this, manifest, new Set(BATTLE_TEXTURE_ASSET_IDS));
    if (queuedImages > 0) {
      this.load.once(Phaser.Loader.Events.COMPLETE, () => this.scene.start(SCENE_KEYS.mainMenu));
      this.load.start();
      return;
    }

    this.scene.start(SCENE_KEYS.mainMenu);
  }

  private renderContentError(errors: string[]): void {
    const root = document.getElementById("ui-root");
    if (!root) {
      return;
    }
    root.className = "ui-root menu-ui";
    root.innerHTML = `
      <main class="menu-shell">
        <section class="menu-panel wide">
          <p class="eyebrow">Content Data Error</p>
          <h1>Ascendant Realms could not start</h1>
          <p class="menu-copy">One or more data files contain a problem. Fix these entries, then refresh the browser.</p>
          <div class="info-box">${errors.map((error) => `<p>${escapeHtml(error)}</p>`).join("")}</div>
        </section>
      </main>
    `;
  }
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
