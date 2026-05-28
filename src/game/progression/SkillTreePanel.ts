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
          statusText: rank > 0 ? (rank >= node.maxRank ? "Unlocked" : "Improved") : "Locked",
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
      <section class="skill-tree">
        <h3>${escapeHtml(tree.name)}</h3>
        <p>${escapeHtml(tree.description)}</p>
        <small>${escapeHtml(tree.buildArchetypeLabel)} branch</small>
        ${tree.synergyText ? `<small class="synergy-line">${escapeHtml(tree.synergyText)}</small>` : ""}
        ${tree.nodes.map(renderSkillNode).join("")}
      </section>
    `;
}

function renderSkillNode(node: SkillNodeViewModel): string {
  return `
      <div class="skill-node">
        <div>
          <strong>${escapeHtml(node.name)} <span>${node.rank}/${node.maxRank}</span></strong>
          <small>Branch: ${escapeHtml(node.branchLabel)} - Cost: ${escapeHtml(node.costText)} - State: ${escapeHtml(node.statusText)}</small>
          <small>${escapeHtml(node.description)}</small>
          ${node.statModsPerRankText ? `<small>${escapeHtml(node.statModsPerRankText)} per rank</small>` : ""}
          ${node.abilityUpgradeText ? `<small>${escapeHtml(node.abilityUpgradeText)}</small>` : ""}
          ${!node.canSpend && node.rank < node.maxRank ? `<small>${escapeHtml(node.message)}</small>` : ""}
        </div>
        <button data-progression-action="skill" data-id="${escapeHtml(node.id)}" ${node.canSpend ? "" : "disabled"}>${
          node.rank > 0 ? "Improve" : "Unlock"
        }</button>
      </div>
    `;
}
