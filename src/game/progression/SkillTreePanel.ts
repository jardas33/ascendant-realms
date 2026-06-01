import type { SkillNodeDefinition, SkillTreeDefinition } from "../core/GameTypes";
import { buildArchetypeLabel, canAllocateSkill, getActiveHeroBuildSynergy } from "../core/HeroProgressionRules";
import type { HeroSaveData } from "../save/SaveTypes";
import type { HeroProgressionCatalogs } from "./HeroProgressionViewModel";
import { escapeHtml, formatStatMods } from "./ItemComparison";

export interface SkillTreesPanelViewModel {
  trees: SkillTreeViewModel[];
}

export interface SkillTreeViewModel {
  id: string;
  name: string;
  description: string;
  buildArchetypeLabel: string;
  synergyText?: string;
  nodes: SkillNodeViewModel[];
}

export interface SkillNodeViewModel {
  id: string;
  name: string;
  description: string;
  branchLabel: string;
  rank: number;
  maxRank: number;
  canSpend: boolean;
  message: string;
  costText: string;
  statusText: string;
  stateClassName: string;
  statModsPerRankText: string;
  abilityUpgradeText: string;
}

export interface SkillTreePanelOptions {
  heroSave: HeroSaveData;
  skillTrees: SkillTreeDefinition[];
  skillNodes: SkillNodeDefinition[];
  catalogs: HeroProgressionCatalogs;
}

export function createSkillTreeViewModel({ heroSave, skillTrees, skillNodes, catalogs }: SkillTreePanelOptions): SkillTreesPanelViewModel {
  const activeSynergy = getActiveHeroBuildSynergy(heroSave, catalogs.skillNodeById, catalogs.itemById);
  const trees = skillTrees.map((tree) => {
    const nodes = skillNodes
      .filter((node) => node.treeId === tree.id && !node.hidden && (!node.classId || node.classId === heroSave.classId))
      .map((node) => {
        const rank = heroSave.allocatedSkills[node.id] ?? 0;
        const check = canAllocateSkill(heroSave, node, catalogs.skillNodeById);
        return {
          id: node.id,
          name: node.name,
          description: node.description,
          branchLabel: buildArchetypeLabel(node.buildArchetype ?? tree.buildArchetype),
          rank,
          maxRank: node.maxRank,
          canSpend: check.ok,
          message: check.message,
          costText: `${node.costPerRank} skill point${node.costPerRank === 1 ? "" : "s"}`,
          statusText: rank > 0 ? "Purchased" : check.ok ? "Available" : "Locked",
          stateClassName: rank > 0 ? "purchased" : check.ok ? "available" : "locked",
          statModsPerRankText: node.statModsPerRank ? formatStatMods(node.statModsPerRank) : "",
          abilityUpgradeText: node.abilityUpgrade?.effectSummary ?? ""
        };
      });

    return {
      id: tree.id,
      name: tree.name,
      description: tree.description,
      buildArchetypeLabel: buildArchetypeLabel(tree.buildArchetype),
      synergyText:
        activeSynergy?.archetype === tree.buildArchetype ? `${activeSynergy.summary} ${activeSynergy.abilitySummary}` : undefined,
      nodes
    };
  });

  return { trees };
}

export function renderSkillTreesPanel(viewModel: SkillTreesPanelViewModel): string {
  return viewModel.trees.map(renderSkillTree).join("");
}

function renderSkillTree(tree: SkillTreeViewModel): string {
  return `
      <section class="skill-tree" data-testid="skill-tree-${escapeHtml(tree.id)}">
        <div class="skill-tree-header">
          <div>
            <h3>${escapeHtml(tree.name)}</h3>
            <p>${escapeHtml(tree.description)}</p>
          </div>
          <span class="tag">${escapeHtml(tree.buildArchetypeLabel)}</span>
        </div>
        ${tree.synergyText ? `<small class="synergy-line">${escapeHtml(tree.synergyText)}</small>` : ""}
        <div class="skill-node-list">
          ${tree.nodes.map(renderSkillNode).join("")}
        </div>
      </section>
    `;
}

function renderSkillNode(node: SkillNodeViewModel): string {
  return `
      <div class="skill-node ${escapeHtml(node.stateClassName)}" data-testid="skill-node-${escapeHtml(node.id)}">
        <div>
          <div class="skill-node-title">
            <strong>${escapeHtml(node.name)}</strong>
            <span>${node.rank}/${node.maxRank}</span>
          </div>
          <div class="skill-node-chip-row">
            <span class="tag">${escapeHtml(node.statusText)}</span>
            <span class="tag">${escapeHtml(node.costText)}</span>
          </div>
          <small class="skill-node-effect">${escapeHtml(node.abilityUpgradeText || node.statModsPerRankText || node.description)}</small>
          <small>Requirement: ${node.canSpend || node.rank >= node.maxRank ? "Met" : escapeHtml(node.message)}</small>
          <details class="support-card-details skill-node-details">
            <summary>More Details</summary>
            <small>Branch: ${escapeHtml(node.branchLabel)}</small>
            <small>${escapeHtml(node.description)}</small>
            ${node.statModsPerRankText ? `<small>${escapeHtml(node.statModsPerRankText)} per rank</small>` : ""}
            ${node.abilityUpgradeText ? `<small>${escapeHtml(node.abilityUpgradeText)}</small>` : ""}
          </details>
        </div>
        <button data-progression-action="skill" data-id="${escapeHtml(node.id)}" ${node.canSpend ? "" : "disabled"}>${
          node.rank > 0 ? "Improve" : "Unlock"
        }</button>
      </div>
    `;
}
