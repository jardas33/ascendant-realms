import type { CampaignChapterViewModel } from "./CampaignPresentationTypes";
import { escapeHtml, titleCase } from "./CampaignPresentationTypes";

export function renderCampaignChapterPanel(chapters: CampaignChapterViewModel[]): string {
  return `
      <div class="chapter-list" data-testid="campaign-chapters">
        ${chapters.map(renderCampaignChapterCard).join("")}
      </div>
    `;
}

function renderCampaignChapterCard(entry: CampaignChapterViewModel): string {
  const currentProgress =
    entry.currentNodeCount > 0
      ? `${entry.completedNodeCount}/${entry.currentNodeCount} current nodes complete`
      : "Future content scaffold";
  return `
      <article class="chapter-card ${entry.status}" data-testid="campaign-chapter-${entry.chapter.id}">
        <div>
          <strong>${escapeHtml(entry.chapter.title)}</strong>
          <span>${titleCase(entry.status)}</span>
        </div>
        <p>${escapeHtml(entry.chapter.shortDescription)}</p>
        <small>${escapeHtml(currentProgress)}</small>
      </article>
    `;
}
