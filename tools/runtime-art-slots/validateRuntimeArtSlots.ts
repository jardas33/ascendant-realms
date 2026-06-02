import { existsSync } from "node:fs";
import { resolve } from "node:path";
import { validateRuntimeArtSlots } from "../../src/game/art/RuntimeArtSlotAdapter";

function main(): void {
  const result = validateRuntimeArtSlots({ fileExists: runtimeAssetExists });
  for (const check of result.checks) {
    console.log(`[runtime-art-slots] OK ${check}`);
  }
  for (const warning of result.warnings) {
    console.warn(`[runtime-art-slots] WARN ${warning.path}: ${warning.message}`);
  }
  if (result.errors.length > 0) {
    for (const error of result.errors) {
      console.error(`[runtime-art-slots] ERROR ${error.path}: ${error.message}`);
    }
    process.exitCode = 1;
    return;
  }
  console.log(`[runtime-art-slots] validated ${result.slotCount} runtime art slots`);
}

function runtimeAssetExists(assetPath: string): boolean {
  const normalized = assetPath.replace(/\\/gu, "/");
  if (normalized.startsWith("public/")) {
    return existsSync(resolve(normalized));
  }
  if (normalized.startsWith("/assets/")) {
    return existsSync(resolve("public", normalized.slice(1)));
  }
  if (normalized.startsWith("assets/")) {
    return existsSync(resolve("public", normalized));
  }
  return existsSync(resolve(normalized));
}

main();
