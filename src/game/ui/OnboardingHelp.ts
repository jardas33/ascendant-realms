export interface OnboardingHelpSurfaceOptions {
  testId: string;
  className?: string;
  summary?: string;
  includeLume?: boolean;
}

interface HelpGroup {
  title: string;
  copy: string;
}

const CORE_HELP_GROUPS: HelpGroup[] = [
  { title: "Camera", copy: "Pan with WASD or arrow keys. Space centers the hero." },
  { title: "Selection", copy: "Click units or drag a box. H selects the hero." },
  { title: "Movement", copy: "Right-click clear ground to move selected friendly units." },
  { title: "Combat", copy: "Right-click enemies to attack. Group units before pushing." },
  { title: "Workers And Sites", copy: "Capture sites first, then assign Workers for stronger income." },
  { title: "Construction And Training", copy: "Command Hall trains Workers. Workers build. Barracks trains army." },
  { title: "Control Groups", copy: "Ctrl+1 through Ctrl+5 assigns; 1 through 5 recalls." },
  { title: "Patrol", copy: "Use Patrol with combat units, then click a patrol point." }
];

const LUME_HELP_GROUP: HelpGroup = {
  title: "Lume",
  copy: "Lume links appear only in eligible missions and private demo routes."
};

export function renderOnboardingHelpSurface(options: OnboardingHelpSurfaceOptions): string {
  const groups = options.includeLume ? [...CORE_HELP_GROUPS, LUME_HELP_GROUP] : CORE_HELP_GROUPS;
  return `
    <details class="onboarding-help ${escapeHelpHtml(options.className ?? "")}" data-testid="${escapeHelpHtml(options.testId)}">
      <summary>${escapeHelpHtml(options.summary ?? "Quick Help")}</summary>
      <div class="onboarding-help-grid">
        ${groups
          .map(
            (group) => `
              <div class="onboarding-help-card">
                <strong>${escapeHelpHtml(group.title)}</strong>
                <span>${escapeHelpHtml(group.copy)}</span>
              </div>
            `
          )
          .join("")}
      </div>
    </details>
  `;
}

function escapeHelpHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}
