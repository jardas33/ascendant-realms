import { access, readFile } from "node:fs/promises";
import path from "node:path";
import { ASSET_REGISTRY, requiredAssetIds } from "./assetRegistry.ts";

interface ManifestEntry {
  id: string;
  available: boolean;
  source: "final" | "manual" | "placeholder" | "runtime";
  path: string | null;
  required: boolean;
  resolvedFilename?: string | null;
}

interface AssetManifest {
  version: number;
  assets: Record<string, ManifestEntry>;
}

const manifestPath = path.join(process.cwd(), "public", "assets", "manifests", "assetManifest.json");

async function main(): Promise<void> {
  const errors: string[] = [];
  const warnings: string[] = [];
  const notes: string[] = [];
  const registryIds = new Set(ASSET_REGISTRY.map((asset) => asset.id));
  const requiredIds = requiredAssetIds();

  const manifest = await readManifest(errors);
  if (!manifest) {
    printReport(errors, warnings, notes, 0, 0);
    process.exitCode = 1;
    return;
  }

  if (manifest.version !== 1) {
    errors.push(`Unsupported manifest version ${manifest.version}. Expected version 1.`);
  }

  requiredIds.forEach((assetId) => {
    if (!registryIds.has(assetId)) {
      errors.push(`Required core asset ${assetId} is missing from the registry.`);
    }
    if (!manifest.assets[assetId]) {
      errors.push(`Required core asset ${assetId} is missing from the manifest.`);
    }
  });

  Object.values(manifest.assets).forEach((entry) => {
    if (!registryIds.has(entry.id)) {
      warnings.push(`Manifest includes ${entry.id}, but it is not in the registry.`);
    }
    if (entry.available && !entry.path) {
      errors.push(`Manifest entry ${entry.id} is marked available but has no path.`);
    }
    if (!entry.available && entry.source !== "runtime") {
      errors.push(`Manifest entry ${entry.id} is unavailable but does not use runtime fallback.`);
    }
  });

  for (const asset of ASSET_REGISTRY) {
    const entry = manifest.assets[asset.id];
    if (!entry) {
      errors.push(`Registry asset ${asset.id} is missing from the manifest.`);
      continue;
    }
    if (!entry.available) {
      const message = `${asset.id} has no image file yet. Runtime shape/CSS fallback will be used.`;
      if (asset.required) {
        warnings.push(message);
      } else {
        notes.push(message);
      }
      continue;
    }
    if (entry.path && !(await publicPathExists(entry.path))) {
      errors.push(`Manifest path for ${asset.id} does not exist: ${entry.path}`);
    }
    if (entry.resolvedFilename && entry.resolvedFilename !== asset.filename) {
      notes.push(`${asset.id} is using ${entry.resolvedFilename}. This works; ${asset.filename} remains the recommended exact filename.`);
    }
  }

  const available = Object.values(manifest.assets).filter((asset) => asset.available).length;
  printReport(errors, warnings, notes, available, ASSET_REGISTRY.length);
  process.exitCode = errors.length > 0 ? 1 : 0;
}

async function readManifest(errors: string[]): Promise<AssetManifest | null> {
  try {
    const raw = await readFile(manifestPath, "utf8");
    return JSON.parse(raw) as AssetManifest;
  } catch {
    errors.push("Missing or unreadable public/assets/manifests/assetManifest.json. Run npm run assets:manifest.");
    return null;
  }
}

async function publicPathExists(publicPath: string): Promise<boolean> {
  const cleanPath = decodeURI(publicPath.replace(/^\/+/, ""));
  const diskPath = path.join(process.cwd(), "public", cleanPath.replaceAll("/", path.sep));
  try {
    await access(diskPath);
    return true;
  } catch {
    return false;
  }
}

function printReport(errors: string[], warnings: string[], notes: string[], available: number, total: number): void {
  console.log("Manual Asset Pipeline Validation");
  console.log("================================");
  console.log(`Registry assets: ${total}`);
  console.log(`File-backed assets found: ${available}`);
  console.log(`Runtime fallback coverage: ${errors.length === 0 ? "ok" : "needs attention"}`);

  if (warnings.length > 0) {
    console.log("");
    console.log("Warnings");
    warnings.forEach((warning) => console.log(`- ${warning}`));
  }

  if (notes.length > 0) {
    console.log("");
    console.log("Notes");
    notes.forEach((note) => console.log(`- ${note}`));
  }

  if (errors.length > 0) {
    console.log("");
    console.log("Errors");
    errors.forEach((error) => console.log(`- ${error}`));
    return;
  }

  console.log("");
  console.log("Validation passed. Missing art is allowed because runtime fallbacks are available.");
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
