import { AssetLoader } from "../assets/AssetLoader";
import { escapeHtml } from "./hudPanels/HudFormatting";

export type EntityPortraitKind = "hero" | "unit" | "building" | "resource-site";
export type EntityPortraitTeam = "player" | "enemy" | "neutral";

export interface EntityPortraitRequest {
  kind: EntityPortraitKind;
  name: string;
  role: string;
  team: EntityPortraitTeam;
  accent: string;
  assetIds: string[];
}

export interface EntityPortraitResolution {
  source: "asset" | "fallback";
  assetId?: string;
  initials: string;
  accessibleLabel: string;
}

export function resolveEntityPortrait(request: EntityPortraitRequest): EntityPortraitResolution {
  const manifest = AssetLoader.getManifest();
  const sourceRank = new Map<string, number>(manifest.priorityOrder.map((source, index) => [source, index]));
  const assetId = request.assetIds
    .map((candidate, index) => ({ candidate, index, entry: manifest.assets[candidate] }))
    .filter(({ entry }) => Boolean(entry?.available && entry.path))
    .sort(
      (left, right) =>
        (sourceRank.get(left.entry!.source) ?? Number.MAX_SAFE_INTEGER) -
          (sourceRank.get(right.entry!.source) ?? Number.MAX_SAFE_INTEGER) ||
        left.index - right.index
    )[0]?.candidate;
  return {
    source: assetId ? "asset" : "fallback",
    ...(assetId ? { assetId } : {}),
    initials: initialsFor(request.name),
    accessibleLabel: `Selected ${request.role} portrait for ${request.name}`
  };
}

export function renderEntityPortrait(request: EntityPortraitRequest): string {
  const resolution = resolveEntityPortrait(request);
  const source = resolution.assetId ? AssetLoader.getAssetUrl(resolution.assetId) : undefined;
  const teamLabel = request.team === "player" ? "Player" : request.team === "enemy" ? "Enemy" : "Neutral";
  const fallback = `<span class="selected-entity-portrait-fallback"${source ? " hidden" : ""} aria-hidden="true">${escapeHtml(
    resolution.initials
  )}</span>`;
  const image = source
    ? `<img class="selected-entity-portrait-image" src="${escapeHtml(source)}" alt="" aria-hidden="true" onerror="this.hidden=true;this.nextElementSibling.removeAttribute('hidden');this.closest('[data-testid=selected-entity-portrait]').dataset.portraitSource='fallback';this.parentElement.classList.remove('has-asset');this.parentElement.classList.add('is-fallback')" />`
    : "";

  return `
    <section class="selected-entity-portrait" data-testid="selected-entity-portrait" data-portrait-source="${resolution.source}" aria-label="${escapeHtml(
      resolution.accessibleLabel
    )}">
      <div class="selected-entity-portrait-frame ${resolution.source === "asset" ? "has-asset" : "is-fallback"}" style="--portrait-accent:${escapeHtml(
        request.accent
      )}">
        ${image}${fallback}
      </div>
      <div class="selected-entity-identity">
        <strong>${escapeHtml(request.name)}</strong>
        <span>${escapeHtml(request.role)}</span>
        <small>${teamLabel}</small>
      </div>
    </section>
  `;
}

function initialsFor(name: string): string {
  const words = name
    .trim()
    .split(/\s+/)
    .map((word) => word.replace(/[^\p{L}\p{N}]/gu, ""))
    .filter(Boolean);
  if (words.length === 0) {
    return "?";
  }
  return words
    .slice(0, 2)
    .map((word) => word[0]!.toUpperCase())
    .join("");
}
