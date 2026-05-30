import { existsSync } from "node:fs";
import { validateContent } from "../src/game/data/contentValidation";
import { validateVisualAssetManifest } from "../src/game/data/validation/validateVisualAssets";

const errors = validateContent();

validateVisualAssetManifest(errors, {
  fileExists: (filePath) => existsSync(filePath)
});

if (errors.length > 0) {
  console.error(`Ascendant Realms content validation failed with ${errors.length} error(s):`);
  errors.forEach((error) => console.error(`- ${error}`));
  process.exitCode = 1;
} else {
  console.log("Ascendant Realms content validation passed.");
  console.log(
    [
      "Checked units, buildings, abilities, hero classes, skills, items, affixes, origins,",
      "resources, factions, reward tables, rival rewards, relic rewards, Stronghold upgrades, campaign chapters,",
      "campaign nodes, reputation effects, upgrades, difficulties, AI personalities, campaign",
      "modifiers, enemy doctrines, elite squads, enemy heroes, enemy pressure plans, maps, tutorial metadata, and visual asset metadata."
    ].join(" ")
  );
}
