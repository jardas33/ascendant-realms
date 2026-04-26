import Phaser from "phaser";
import { AssetLoader } from "../assets/AssetLoader";
import type { RuntimeAssetManifestEntry } from "../assets/AssetManifestTypes";
import { ASSET_IDS } from "../assets/AssetKeys";
import { SCENE_KEYS } from "../core/SceneKeys";

export class AssetGalleryScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;

  constructor() {
    super(SCENE_KEYS.assetGallery);
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }

    this.handler = (event) => {
      const action = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-gallery-action]")?.dataset
        .galleryAction;
      if (action === "back") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
    };

    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private render(): void {
    if (!this.root) {
      return;
    }

    const assets = Object.values(AssetLoader.getManifest().assets).sort((a, b) => a.priority - b.priority);
    const availableCount = assets.filter((asset) => asset.available).length;

    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell asset-gallery-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel extra-wide asset-gallery-panel">
          <div class="progression-header">
            <div>
              <p class="eyebrow">Manual Asset Gallery</p>
              <h1>Asset Check</h1>
              <p class="menu-copy">${availableCount}/${assets.length} assets found. This screen shows every manifest asset the game can currently see.</p>
            </div>
            <button class="hud-button compact" data-gallery-action="back">Back</button>
          </div>
          <div class="asset-gallery-grid">
            ${assets.map((asset) => this.renderAssetCard(asset)).join("")}
          </div>
        </section>
      </main>
    `;
    this.verifyGalleryImages();
  }

  private renderAssetCard(asset: RuntimeAssetManifestEntry): string {
    const url = AssetLoader.getAssetUrl(asset.id);
    const preview = url
      ? `<img class="asset-gallery-image" src="${escapeHtml(url)}" alt="${escapeHtml(asset.displayName)}" data-asset-id="${escapeHtml(asset.id)}" loading="eager" decoding="async" />`
      : `<div class="asset-gallery-fallback">Runtime fallback</div>`;
    const filename = asset.resolvedFilename ?? asset.filename;

    return `
      <article class="asset-gallery-card ${asset.available ? "available checking" : "missing"}" data-asset-card="${escapeHtml(asset.id)}">
        <div class="asset-gallery-preview">${preview}</div>
        <div class="asset-gallery-copy">
          <strong>${escapeHtml(asset.displayName)}</strong>
          <span>${escapeHtml(asset.category)} - ${escapeHtml(asset.source)}</span>
          <small>${escapeHtml(filename)}</small>
          <small data-gallery-status>${asset.available ? "Checking image load..." : "Runtime fallback"}</small>
        </div>
      </article>
    `;
  }

  private verifyGalleryImages(): void {
    const images = this.root?.querySelectorAll<HTMLImageElement>("img[data-asset-id]") ?? [];
    images.forEach((image) => {
      const card = image.closest<HTMLElement>(".asset-gallery-card");
      const status = card?.querySelector<HTMLElement>("[data-gallery-status]");
      const markLoaded = (): void => {
        card?.classList.remove("checking", "broken");
        card?.classList.add("loaded");
        if (status) {
          status.textContent = "Image loaded";
        }
      };
      const markBroken = (): void => {
        card?.classList.remove("checking", "loaded");
        card?.classList.add("broken");
        if (status) {
          status.textContent = "Image failed to load";
        }
      };

      image.addEventListener("load", markLoaded, { once: true });
      image.addEventListener("error", markBroken, { once: true });
      if (image.complete) {
        if (image.naturalWidth > 0) {
          markLoaded();
        } else {
          markBroken();
        }
      }
    });
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
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
