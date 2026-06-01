import { describe, expect, it } from "vitest";
import { createItemInstance } from "../core/HeroProgressionRules";
import { ITEM_BY_ID, HERO_CLASS_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { createNewHeroSave } from "../data/heroes";
import { SKILL_NODES, SKILL_TREES } from "../data/skillTrees";
import { createEquipmentViewModel, renderEquipmentPanel } from "./EquipmentPanel";
import { createInventoryViewModel, renderInventoryPanel } from "./InventoryPanel";
import { createSkillTreeViewModel, renderSkillTreesPanel } from "./SkillTreePanel";

const catalogs = {
  heroClassById: HERO_CLASS_BY_ID,
  originById: ORIGIN_BY_ID,
  skillNodeById: SKILL_NODE_BY_ID,
  itemById: ITEM_BY_ID
};

describe("meta-progression UX presentation", () => {
  it("groups equipment and inventory without changing equip state", () => {
    const sword = createItemInstance("weathered_command_sword", "test", "2026-06-01T00:00:00.000Z", { affixes: [] });
    const relic = createItemInstance("outpost_command_signet", "test", "2026-06-01T00:00:00.000Z", { affixes: [] });
    const stored = createItemInstance("emberglass_wand", "test", "2026-06-01T00:00:00.000Z", { affixes: [] });
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      inventory: [sword, relic, stored],
      equipment: {
        weapon: sword.instanceId,
        relic: relic.instanceId
      }
    };
    const beforeRender = JSON.stringify(hero);

    const equipmentHtml = renderEquipmentPanel(createEquipmentViewModel(hero, catalogs));
    const inventoryHtml = renderInventoryPanel(
      createInventoryViewModel({
        heroSave: hero,
        rewardItemIds: ["emberglass_wand"],
        catalogs
      })
    );

    expect(equipmentHtml).toContain("Equipped");
    expect(equipmentHtml).toContain("Relic");
    expect(equipmentHtml).toContain("Outpost Command Signet");
    expect(equipmentHtml).toContain("More Details");
    expect(equipmentHtml).toContain('data-progression-action="unequip"');
    expect(inventoryHtml).toContain('data-testid="inventory-equipped-group"');
    expect(inventoryHtml).toContain('data-testid="inventory-stored-group"');
    expect(inventoryHtml).toContain('data-testid="relic-list"');
    expect(inventoryHtml).toContain("Use Equipment to unequip.");
    expect(inventoryHtml).toContain("New reward");
    expect(inventoryHtml).toContain("Preview:");
    expect(JSON.stringify(hero)).toBe(beforeRender);
  });

  it("renders skill nodes with readable available, purchased, and locked states", () => {
    const hero = {
      ...createNewHeroSave("Aster", "warlord", "exiled_noble"),
      skillPoints: 1,
      allocatedSkills: {
        combat_drill: 1
      }
    };

    const html = renderSkillTreesPanel(
      createSkillTreeViewModel({
        heroSave: hero,
        skillTrees: SKILL_TREES,
        skillNodes: SKILL_NODES,
        catalogs
      })
    );

    expect(html).toContain('data-testid="skill-tree-combat"');
    expect(html).toContain("Purchased");
    expect(html).toContain("Available");
    expect(html).toContain("Requirement:");
    expect(html).toContain("More Details");
    expect(html).toContain("Cleave: +6 damage and -1s cooldown.");
  });
});
