import { getKnownRivalIntel, getRivalTrophyIntel } from "../core/RivalRules";
import type { CampaignSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./CampaignPresentationTypes";

export function renderRivalIntelPanel(campaign: CampaignSaveData): string {
  const rivals = getKnownRivalIntel(campaign);
  const trophies = getRivalTrophyIntel(campaign);
  return `
    <section class="stronghold-panel rival-intel-panel" data-testid="rival-intel-panel">
      <div class="stronghold-heading">
        <div>
          <h2>Rival Intel</h2>
          <p class="quiet">Known enemy commanders remember campaign encounters. First-defeat rewards are claimed once; escapes or defeats can affect their next appearance.</p>
        </div>
        <span class="tag">${rivals.length} known</span>
      </div>
      ${
        rivals.length === 0
          ? `<p class="quiet">No rivals are known yet. Scout or fight named enemy commanders to reveal their campaign state.</p>`
          : `<div class="stronghold-grid">
              ${rivals
                .map(
                  (rival) => `
                    <article class="stronghold-card purchased" data-testid="rival-intel-${escapeHtml(rival.enemyHeroId)}">
                      <div class="stronghold-title">
                        <strong>${escapeHtml(rival.name)}</strong>
                        <span>${escapeHtml(rival.dispositionLabel)}</span>
                      </div>
                      <p>${escapeHtml(rival.title)}</p>
                      <p>${rival.encounters} encounters - ${rival.defeats} defeats - ${rival.victoriesAgainstPlayer} victories against you</p>
                      <small>Last seen: ${escapeHtml(rival.lastSeen)} - ${escapeHtml(rival.lastOutcomeLabel)}</small>
                      <small>One-time first-defeat reward: ${rival.firstDefeatRewardClaimed ? `Claimed${rival.trophyLabel ? ` - ${escapeHtml(rival.trophyLabel)}` : ""}` : "Unclaimed"}</small>
                      <small>${escapeHtml(rival.effectText)}</small>
                    </article>
                  `
                )
                .join("")}
            </div>`
      }
      <div class="rival-trophy-panel" data-testid="rival-trophy-panel">
        <div class="stronghold-heading compact">
          <div>
            <h3>Rival Trophies</h3>
            <p class="quiet">First-defeat trophies are cosmetic records claimed once and stay on the campaign save.</p>
          </div>
          <span class="tag">${trophies.length} earned</span>
        </div>
        ${
          trophies.length === 0
            ? `<p class="quiet">No rival trophies earned yet.</p>`
            : `<div class="stronghold-grid">
                ${trophies
                  .map(
                    (trophy) => `
                      <article class="stronghold-card purchased" data-testid="rival-trophy-${escapeHtml(trophy.trophyId)}">
                        <div class="stronghold-title">
                          <strong>${escapeHtml(trophy.label)}</strong>
                          <span>${escapeHtml(trophy.enemyHeroName)}</span>
                        </div>
                        <p>${escapeHtml(trophy.description)}</p>
                        <small>Won at ${escapeHtml(trophy.sourceNodeName)}</small>
                        ${trophy.effect ? `<small>${escapeHtml(trophy.effect)}</small>` : ""}
                      </article>
                    `
                  )
                  .join("")}
              </div>`
        }
      </div>
    </section>
  `;
}
