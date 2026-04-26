import type { SkillNodeDefinition, SkillTreeDefinition } from "../core/GameTypes";
import { canAllocateSkill } from "../core/HeroProgressionRules";
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
  nodes: SkillNodeViewModel[];
}

export interface SkillNodeViewModel {
  id: string;
  name: string;
  description: string;
  rank: number;
  maxRank: number;
  canSpend: boolean;
  message: string;
  statModsPerRankText: string;
}

export interface SkillTreePanelOptions {
  heroSave: HeroSaveData;
  skillTrees: SkillTreeDefinition[];
  skillNodes: SkillNodeDefinition[];
  catalogs: HeroProgressionCatalogs;
}

export function createSkillTreeViewModel({ heroSave, skillTrees, skillNodes, catalogs }: SkillTreePanelOptions): SkillTreesPanelViewModel {
  const trees = skillTrees.map((tree) => {
    const nodes = skillNodes
      .filter((node) => node.treeId === tree.id && (!node.classId || node.classId === heroSave.classId))
      .map((node) => {
        const rank = heroSave.allocatedSkills[node.id] ?? 0;
        const check = canAllocateSkill(heroSave, node, catalogs.skillNodeById);
        return {
          id: node.id,
          name: node.name,
          description: node.description,
          rank,
          maxRank: node.maxRank,
          canSpend: check.ok,
          message: check.message,
          statModsPerRankText: node.statModsPerRank ? formatStatMods(node.statModsPerRank) : ""
        };
      });

    return {
      id: tree.id,
      name: tree.name,
      description: tree.description,
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
        ${tree.nodes.map(renderSkillNode).join("")}
      </section>
    `;
}

function renderSkillNode(node: SkillNodeViewModel): string {
  return `
      <div class="skill-node">
        <div>
          <strong>${escapeHtml(node.name)} <span>${node.rank}/${node.maxRank}</span></strong>
          <small>${escapeHtml(node.description)}</small>
          ${node.statModsPerRankText ? `<small>${escapeHtml(node.statModsPerRankText)} per rank</small>` : ""}
          ${!node.canSpend && node.rank < node.maxRank ? `<small>${escapeHtml(node.message)}</small>` : ""}
        </div>
        <button data-progression-action="skill" data-id="${escapeHtml(node.id)}" ${node.canSpend ? "" : "disabled"}>Spend</button>
      </div>
    `;
}
