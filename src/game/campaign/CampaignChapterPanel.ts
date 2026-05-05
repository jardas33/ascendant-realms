import type { CampaignChapterViewModel } from "./CampaignPresentationTypes";
import { escapeHtml } from "./CampaignPresentationTypes";

export function renderCampaignChapterPanel(chapters: CampaignChapterViewModel[]): string {
  return `
      <div class="chapter-list" data-testid="campaign-chapters">
        ${chapters.map(renderCampaignChapterCard).join("")}
      </div>
    `;
}

function renderCampaignChapterCard(entry: CampaignChapterViewModel): string {
  return `
      <article class="${entry.cssClass}" data-testid="${entry.testId}">
        <div>
          <strong>${escapeHtml(entry.chapter.title)}</strong>
          <span>${escapeHtml(entry.statusLabel)}</span>
        </div>
        <p>${escapeHtml(entry.chapter.shortDescription)}</p>
        <small>${escapeHtml(entry.progressText)}</small>
      </article>
    `;
}
