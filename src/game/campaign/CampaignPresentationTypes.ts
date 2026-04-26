import type { CampaignNodeDefinition, CampaignNodeStatus } from "../core/GameTypes";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";

export interface CampaignNodeViewModel {
  node: CampaignNodeDefinition;
  status: CampaignNodeStatus;
  selected: boolean;
}

export interface CampaignMapViewModel {
  heroSave: HeroSaveData;
  campaignSave: CampaignSaveData;
  selectedNode?: CampaignNodeDefinition;
  nodes: CampaignNodeViewModel[];
  progressSummary: string;
  campaignStateLabel: string;
}

export function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}

export function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

export function toCssColor(value: number): string {
  return `#${value.toString(16).padStart(6, "0")}`;
}
