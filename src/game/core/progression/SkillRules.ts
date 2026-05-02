import type {
  HeroClassDefinition,
  HeroStatMods,
  SkillNodeDefinition
} from "../GameTypes";
import type { HeroSaveData } from "../../save/SaveTypes";
import { mergeHeroStatMods, multiplyHeroStatMods } from "./HeroStatRules";

export interface ProgressionActionResult {
  ok: boolean;
  hero: HeroSaveData;
  message: string;
  unlockedAbilityId?: string;
}

export function calculateSkillStatMods(
  allocatedSkills: Record<string, number>,
  skillById: Record<string, SkillNodeDefinition>
): HeroStatMods {
  return Object.entries(allocatedSkills).reduce<HeroStatMods>((mods, [skillId, rawRank]) => {
    const node = skillById[skillId];
    if (!node?.statModsPerRank) {
      return mods;
    }
    const rank = Math.max(0, Math.min(rawRank, node.maxRank));
    return mergeHeroStatMods(mods, multiplyHeroStatMods(node.statModsPerRank, rank));
  }, {});
}

export function getUnlockedAbilityIds(
  save: HeroSaveData,
  heroClass: HeroClassDefinition,
  skillById: Record<string, SkillNodeDefinition>
): string[] {
  const unlocked = new Set<string>([heroClass.primaryAbilityId, ...save.unlockedAbilities]);
  Object.entries(save.allocatedSkills).forEach(([skillId, rank]) => {
    const node = skillById[skillId];
    if (node?.unlockAbilityId && rank > 0) {
      unlocked.add(node.unlockAbilityId);
    }
  });

  return heroClass.abilityIds.filter((abilityId) => unlocked.has(abilityId));
}

export function canAllocateSkill(
  save: HeroSaveData,
  node: SkillNodeDefinition | undefined,
  skillById: Record<string, SkillNodeDefinition>
): { ok: boolean; message: string } {
  if (!node) {
    return { ok: false, message: "Unknown skill." };
  }
  if (node.classId && node.classId !== save.classId) {
    return { ok: false, message: "This skill belongs to another hero class." };
  }
  const currentRank = save.allocatedSkills[node.id] ?? 0;
  if (currentRank >= node.maxRank) {
    return { ok: false, message: "This skill is already maxed." };
  }
  if (save.skillPoints < node.costPerRank) {
    return { ok: false, message: "Not enough skill points." };
  }
  const missingRequirement = node.requires?.find((requirement) => {
    const requiredNode = skillById[requirement.skillId];
    return !requiredNode || (save.allocatedSkills[requirement.skillId] ?? 0) < requirement.rank;
  });
  if (missingRequirement) {
    const requiredNode = skillById[missingRequirement.skillId];
    return { ok: false, message: `Requires ${requiredNode?.name ?? missingRequirement.skillId} rank ${missingRequirement.rank}.` };
  }
  return { ok: true, message: "Skill can be learned." };
}

export function allocateSkillPoint(
  save: HeroSaveData,
  nodeId: string,
  skillById: Record<string, SkillNodeDefinition>
): ProgressionActionResult {
  const node = skillById[nodeId];
  const check = canAllocateSkill(save, node, skillById);
  if (!check.ok || !node) {
    return { ok: false, hero: save, message: check.message };
  }

  const currentRank = save.allocatedSkills[node.id] ?? 0;
  const unlocked = new Set(save.unlockedAbilities);
  if (node.unlockAbilityId) {
    unlocked.add(node.unlockAbilityId);
  }

  return {
    ok: true,
    hero: {
      ...save,
      skillPoints: save.skillPoints - node.costPerRank,
      allocatedSkills: {
        ...save.allocatedSkills,
        [node.id]: currentRank + 1
      },
      unlockedAbilities: [...unlocked]
    },
    message: node.unlockAbilityId ? `${node.name} learned. Ability unlocked.` : `${node.name} improved.`,
    unlockedAbilityId: node.unlockAbilityId
  };
}
