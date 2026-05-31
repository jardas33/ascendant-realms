import { LUME_NETWORK_BY_ID } from "../data/contentIndex";
import { escapeHtml } from "./ResultsFormatting";
import type { ResultsData } from "./ResultsTypes";

export function renderPrivateDemoLumeSummary(data: ResultsData): string {
  const network = data.stats.lumeNetworkId ? LUME_NETWORK_BY_ID[data.stats.lumeNetworkId] : undefined;
  const activated = data.stats.lumeLinkActivatedIds ?? [];
  const severed = data.stats.lumeLinkSeveredIds ?? [];
  return `
    <section class="private-demo-summary-card" data-testid="private-demo-lume-summary">
      <h2>LUME NETWORK SUMMARY</h2>
      <div class="results-grid compact private-demo-grid">
        <span>Linked Ward awakened</span><strong>${data.stats.lumeObjectiveCompleted ? "Yes" : "No"}</strong>
        <span>Links awakened</span><strong>${activated.length}${network ? `/${network.maxActiveLinks}` : ""}</strong>
        <span>Links severed</span><strong>${severed.length}</strong>
        <span>Protected route</span><strong>${formatPrivateDemoRoute(data)}</strong>
        <span>Nearby allies</span><strong>8% less incoming damage</strong>
        <span>Rewards</span><strong>Disabled</strong>
        <span>Campaign progress</span><strong>Not saved</strong>
      </div>
      <p class="quiet">${escapeHtml(data.launchRequest?.privatePlaytestNotice ?? "Private Lume demo only.")}</p>
    </section>
  `;
}

export function renderPrivateDemoPrimaryActions(): string {
  return `
    <div class="menu-actions row private-demo-primary-actions" data-testid="private-demo-primary-actions">
      <button data-results-action="campaign">Return to Campaign Map</button>
      <button data-results-action="retry">Replay Lume Demo</button>
    </div>
  `;
}

export function formatPrivateDemoRoute(data: ResultsData): string {
  const network = data.stats.lumeNetworkId ? LUME_NETWORK_BY_ID[data.stats.lumeNetworkId] : undefined;
  if (!network) {
    return "None";
  }
  const activated = data.stats.lumeLinkActivatedIds ?? [];
  const primaryLink = network.links.find((link) => activated.includes(link.id)) ?? network.links[0];
  if (!primaryLink) {
    return "None";
  }
  const from = siteName(primaryLink.fromSiteId);
  const to = siteName(primaryLink.toSiteId);
  return `${escapeHtml(from)} &harr; ${escapeHtml(to)}`;
}

function siteName(siteId: string): string {
  if (siteId === "west_stone_cut") {
    return "West Stone Cut";
  }
  if (siteId === "ford_toll") {
    return "Ford Toll";
  }
  if (siteId === "north_aether_spring") {
    return "North Aether Spring";
  }
  return siteId
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}
