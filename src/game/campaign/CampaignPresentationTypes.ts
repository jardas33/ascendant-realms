import type { CampaignChapterStatus, CampaignNodeDefinition, CampaignNodeStatus } from "../core/GameTypes";
import type { RivalIntelEntry, RivalTrophyIntelEntry } from "../core/RivalRules";
import type { CampaignChapterViewModel as CampaignChapterRulesViewModel } from "../core/campaign/CampaignChapterRules";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";

export interface CampaignNodeViewModel {
  node: CampaignNodeDefinition;
  status: CampaignNodeStatus;
  selected: boolean;
}

export interface CampaignReputationRowViewModel {
  factionId: string;
  factionName: string;
  value: number;
  rankLabel: string;
}

export interface CampaignReputationEffectViewModel {
  id: string;
  factionId: string;
  factionName: string;
  name: string;
  description: string;
}

export interface CampaignReputationViewModel {
  rows: CampaignReputationRowViewModel[];
  activeEffects: CampaignReputationEffectViewModel[];
}

export interface CampaignChapterViewModel extends CampaignChapterRulesViewModel {
  status: CampaignChapterStatus;
}

export interface CampaignMapViewModel {
  heroSave: HeroSaveData;
  campaignSave: CampaignSaveData;
  selectedNode?: CampaignNodeDefinition;
  nodes: CampaignNodeViewModel[];
  chapters: CampaignChapterViewModel[];
  progressSummary: string;
  campaignStateLabel: string;
  reputation: CampaignReputationViewModel;
  rivalIntel: RivalIntelEntry[];
  rivalTrophies: RivalTrophyIntelEntry[];
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
