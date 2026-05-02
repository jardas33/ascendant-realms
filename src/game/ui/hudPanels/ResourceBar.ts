import type { ResourceBag } from "../../core/GameTypes";
import { RESOURCE_DEFINITIONS } from "../../data/resources";
import { escapeHtml, toCssColor } from "./HudFormatting";

export function renderResources(resources: ResourceBag): string {
  return RESOURCE_DEFINITIONS.map(
    (resource) =>
      `<span class="resource-pill" style="--resource-color:${toCssColor(resource.color)}"><span>${escapeHtml(resource.name)}</span><strong>${Math.floor(resources[resource.id])}</strong></span>`
  ).join("");
}
