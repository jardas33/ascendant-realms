import { access, mkdir, readdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { ASSET_REGISTRY } from "./assetRegistry.ts";

type ManifestAssetSource = "final" | "manual" | "placeholder" | "runtime";

interface ManifestAssetEntry {
  id: string;
  category: string;
  displayName: string;
  filename: string;
  targetFolder: string;
  usage: string;
  priority: number;
  required: boolean;
  available: boolean;
  source: ManifestAssetSource;
  path: string | null;
  resolvedFilename: string | null;
  preferredWidth: number;
  preferredHeight: number;
}

interface AssetManifest {
  version: 1;
  generatedAt: string;
  priorityOrder: Array<Exclude<ManifestAssetSource, "runtime">>;
  assets: Record<string, ManifestAssetEntry>;
}

const publicAssetsDir = path.join(process.cwd(), "public", "assets");
const manifestDir = path.join(publicAssetsDir, "manifests");
const manifestPath = path.join(manifestDir, "assetManifest.json");
const sourcePriority: Array<Exclude<ManifestAssetSource, "runtime">> = ["final", "manual", "placeholder"];
const supportedImageExtensions = new Set([".png", ".jpg", ".jpeg", ".webp"]);

async function main(): Promise<void> {
  await mkdir(manifestDir, { recursive: true });

  const assets: Record<string, ManifestAssetEntry> = {};
  for (const asset of ASSET_REGISTRY) {
    const match = await findBestAsset(asset);
    assets[asset.id] = {
      id: asset.id,
      category: asset.category,
      displayName: asset.displayName,
      filename: asset.filename,
      targetFolder: asset.targetFolder,
      usage: asset.usage,
      priority: asset.priority,
      required: asset.required,
      available: Boolean(match),
      source: match?.source ?? "runtime",
      path: match?.publicPath ?? null,
      resolvedFilename: match?.filename ?? null,
      preferredWidth: asset.preferredWidth,
      preferredHeight: asset.preferredHeight
    };
  }

  const manifest: AssetManifest = {
    version: 1,
    generatedAt: new Date().toISOString(),
    priorityOrder: sourcePriority,
    assets
  };

  await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");

  const available = Object.values(assets).filter((asset) => asset.available).length;
  console.log(`Built asset manifest with ${available}/${ASSET_REGISTRY.length} file-backed assets.`);
  console.log(`Manifest: ${path.relative(process.cwd(), manifestPath).replaceAll(path.sep, "/")}`);
}

async function findBestAsset(asset: {
  id: string;
  displayName: string;
  filename: string;
  targetFolder: string;
}): Promise<{ source: Exclude<ManifestAssetSource, "runtime">; publicPath: string; filename: string } | null> {
  for (const source of sourcePriority) {
    const sourceDir = path.join(publicAssetsDir, source, asset.targetFolder);
    const exactPath = path.join(sourceDir, asset.filename);
    if (await exists(exactPath)) {
      return buildMatch(source, asset.targetFolder, asset.filename);
    }

    const friendlyFilename = await findFriendlyFilename(sourceDir, asset);
    if (friendlyFilename) {
      return buildMatch(source, asset.targetFolder, friendlyFilename);
    }
  }
  return null;
}

async function findFriendlyFilename(
  sourceDir: string,
  asset: { id: string; displayName: string; filename: string }
): Promise<string | null> {
  const entries = await readdir(sourceDir, { withFileTypes: true }).catch(() => []);
  const files = entries
    .filter((entry) => entry.isFile() && supportedImageExtensions.has(path.extname(entry.name).toLowerCase()))
    .map((entry) => entry.name);

  const caseInsensitiveExact = files.find((filename) => filename.toLowerCase() === asset.filename.toLowerCase());
  if (caseInsensitiveExact) {
    return caseInsensitiveExact;
  }

  const desiredNames = new Set([
    normalizeName(path.parse(asset.filename).name),
    normalizeName(asset.displayName),
    normalizeName(asset.id)
  ]);

  return files.find((filename) => desiredNames.has(normalizeName(path.parse(filename).name))) ?? null;
}

function buildMatch(
  source: Exclude<ManifestAssetSource, "runtime">,
  targetFolder: string,
  filename: string
): { source: Exclude<ManifestAssetSource, "runtime">; publicPath: string; filename: string } {
  const encodedPath = ["/assets", source, ...targetFolder.split("/"), filename].map(encodePathPart).join("/");
  return {
    source,
    publicPath: encodedPath,
    filename
  };
}

function normalizeName(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "");
}

function encodePathPart(value: string): string {
  return value === "/assets" ? value : encodeURIComponent(value);
}

async function exists(filePath: string): Promise<boolean> {
  try {
    await access(filePath);
    return true;
  } catch {
    return false;
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
