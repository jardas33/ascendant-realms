import Phaser from "phaser";
import { ASSET_MANIFEST_CACHE_KEY, UI_KIT_CSS_VARIABLES } from "./AssetKeys";
import type { RuntimeAssetManifest } from "./AssetManifestTypes";

const EMPTY_MANIFEST: RuntimeAssetManifest = {
  version: 1,
  generatedAt: "",
  priorityOrder: ["final", "manual", "placeholder"],
  assets: {}
};

let activeManifest: RuntimeAssetManifest = EMPTY_MANIFEST;

export class AssetLoader {
  static manifestUrl(): string {
    return "/assets/manifests/assetManifest.json";
  }

  static readCachedManifest(scene: Phaser.Scene): RuntimeAssetManifest {
    const cached = scene.cache.json.get(ASSET_MANIFEST_CACHE_KEY);
    return normalizeManifest(cached);
  }

  static setManifest(manifest: RuntimeAssetManifest): void {
    activeManifest = normalizeManifest(manifest);
  }

  static getManifest(): RuntimeAssetManifest {
    return activeManifest;
  }

  static getAssetUrl(assetId: string | undefined): string | undefined {
    if (!assetId) {
      return undefined;
    }
    const entry = activeManifest.assets[assetId];
    if (!entry?.available || !entry.path) {
      return undefined;
    }
    return entry.path;
  }

  static hasAsset(assetId: string | undefined): boolean {
    return Boolean(this.getAssetUrl(assetId));
  }

  static cssUrl(assetId: string | undefined): string | undefined {
    const url = this.getAssetUrl(assetId);
    return url ? `url('${escapeCssUrl(url)}')` : undefined;
  }

  static backgroundStyle(assetId: string | undefined): string {
    const url = this.cssUrl(assetId);
    return url ? `style="--asset-bg:${url}"` : "";
  }

  static screenStyle(options: { backgroundAssetId?: string }): string {
    const declarations = [
      cssVariableDeclaration("--asset-bg", this.cssUrl(options.backgroundAssetId))
    ].filter((declaration): declaration is string => Boolean(declaration));

    return declarations.length > 0 ? `style="${declarations.join(";")}"` : "";
  }

  static portraitStyle(assetId: string | undefined, fallbackColor: string): string {
    const url = this.cssUrl(assetId);
    const image = url ? `;--portrait-url:${url}` : "";
    return `style="--hero-color:${fallbackColor}${image}"`;
  }

  static imageHtml(assetId: string | undefined, alt: string, className: string): string {
    const url = this.getAssetUrl(assetId);
    if (!url) {
      return "";
    }
    return `<img class="${escapeAttribute(className)}" src="${escapeAttribute(url)}" alt="${escapeAttribute(alt)}" />`;
  }

  static applyUiKitCssVariables(target: HTMLElement = document.documentElement): void {
    Object.entries(UI_KIT_CSS_VARIABLES).forEach(([assetId, cssVariable]) => {
      const url = this.cssUrl(assetId);
      if (url) {
        target.style.setProperty(cssVariable, url);
        return;
      }
      target.style.removeProperty(cssVariable);
    });
  }

  static queueAvailableImages(scene: Phaser.Scene, manifest = activeManifest, onlyAssetIds?: Set<string>): number {
    let queued = 0;
    Object.values(manifest.assets).forEach((entry) => {
      if (onlyAssetIds && !onlyAssetIds.has(entry.id)) {
        return;
      }
      if (!entry.available || !entry.path || scene.textures.exists(entry.id)) {
        return;
      }
      scene.load.image(entry.id, entry.path);
      queued += 1;
    });
    return queued;
  }
}

function normalizeManifest(value: unknown): RuntimeAssetManifest {
  if (!isRuntimeAssetManifest(value)) {
    return EMPTY_MANIFEST;
  }
  return value;
}

function isRuntimeAssetManifest(value: unknown): value is RuntimeAssetManifest {
  return (
    isRecord(value) &&
    value.version === 1 &&
    Array.isArray(value.priorityOrder) &&
    typeof value.generatedAt === "string" &&
    isRecord(value.assets)
  );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function escapeCssUrl(value: string): string {
  return value.replaceAll("\\", "\\\\").replaceAll("'", "\\'").replaceAll("\n", "");
}

function cssVariableDeclaration(name: string, value: string | undefined): string | undefined {
  return value ? `${name}:${value}` : undefined;
}

function escapeAttribute(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
