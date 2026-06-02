import { mkdirSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { describe, expect, it } from "vitest";
import {
  EXPECTED_SALTO_SLICE_ASSET_IDS,
  SALTO_SLICE_MANIFEST_PATH,
  VISUAL_ASSET_REGISTRY_PATH,
  expectedSaltoSlicePacketFiles,
  generateSaltoSlicePacket,
  loadSaltoSliceManifest,
  loadVisualAssetRegistryForSaltoSlice,
  validateSaltoSliceManifest
} from "./saltoSliceManifest";

type MutableManifest = Awaited<ReturnType<typeof loadSaltoSliceManifest>>;

describe("v0.107 Salto vertical slice manifest and packet", () => {
  it("parses the manifest and preserves deterministic ordering", async () => {
    const manifest = await loadSaltoSliceManifest();
    const registry = await loadVisualAssetRegistryForSaltoSlice();
    const validation = validateSaltoSliceManifest(manifest, {
      registryAssetIds: new Set(registry.assets.map((asset) => asset.assetId))
    });

    expect(validation.errors).toEqual([]);
    expect(manifest.assets.map((asset) => asset.assetId)).toEqual([...EXPECTED_SALTO_SLICE_ASSET_IDS]);
    expect(manifest.dependencyOrder.filter((entry) => entry.assetId).map((entry) => entry.assetId)).toEqual([
      ...EXPECTED_SALTO_SLICE_ASSET_IDS
    ]);
  });

  it("maps every planned asset to registry assets and known runtime slots", async () => {
    const manifest = await loadSaltoSliceManifest();
    const registry = await loadVisualAssetRegistryForSaltoSlice();
    const registryAssetIds = new Set(registry.assets.map((asset) => asset.assetId));
    const validation = validateSaltoSliceManifest(manifest, { registryAssetIds });

    expect(validation.errors).toEqual([]);
    for (const asset of manifest.assets) {
      expect(asset.registryAssetIds.every((assetId) => registryAssetIds.has(assetId))).toBe(true);
      expect(asset.runtimeSlotIds.length).toBeGreaterThan(0);
    }
  });

  it("does not include generated image paths or runtime integration approval", async () => {
    const manifest = await loadSaltoSliceManifest();
    const validation = validateSaltoSliceManifest(manifest);

    expect(validation.errors).toEqual([]);
    expect(manifest.generatedAssetsIncluded).toBe(false);
    expect(manifest.runtimeIntegrationApproved).toBe(false);
    expect(manifest.generatedImagePaths).toEqual([]);
    expect(manifest.assets.every((asset) => asset.runtimePosture === "reference-only:not-runtime")).toBe(true);
  });

  it("generates a deterministic metadata-only Salto slice packet", async () => {
    const projectRoot = createTempProject();
    const first = await generateSaltoSlicePacket(projectRoot);
    const firstFiles = readPacketFiles(projectRoot, first.files);
    const second = await generateSaltoSlicePacket(projectRoot);
    const secondFiles = readPacketFiles(projectRoot, second.files);

    expect(first.files.map((file) => path.basename(file))).toEqual(expectedSaltoSlicePacketFiles());
    expect(second.files).toEqual(first.files);
    expect(secondFiles).toEqual(firstFiles);
    expect(firstFiles["asset-dimension-contracts.json"]).toContain('"runtimeIntegrationApproved": false');
    expect(firstFiles["runtime-slot-map.json"]).toContain('"runtimePosture": "reference-only:not-runtime"');
    expect(Object.values(firstFiles).some((content) => /(?:public|assets|images)[^\n"]+\.(?:png|jpe?g|webp|avif|svg)/iu.test(content))).toBe(false);
  });

  it("rejects a missing dimension contract", async () => {
    const manifest = await mutableManifest();
    manifest.assets[0].canvasSize.width = 0;

    const validation = validateSaltoSliceManifest(manifest);

    expect(validation.errors.some((error) => error.path.endsWith(".canvasSize"))).toBe(true);
  });

  it("rejects a missing QA scenario", async () => {
    const manifest = await mutableManifest();
    manifest.assets[0].visualQaScenarioId = "missing_scenario";

    const validation = validateSaltoSliceManifest(manifest);

    expect(validation.errors.some((error) => error.path.endsWith(".visualQaScenarioId"))).toBe(true);
  });

  it("rejects a missing fallback contract", async () => {
    const manifest = await mutableManifest();
    manifest.assets[0].fallbackBehavior.owner = "";

    const validation = validateSaltoSliceManifest(manifest);

    expect(validation.errors.some((error) => error.path.endsWith(".fallbackBehavior"))).toBe(true);
  });

  it("rejects dependency cycles", async () => {
    const manifest = await mutableManifest();
    manifest.assets[0].assetDependencyIds = [manifest.assets[1].assetId];
    manifest.assets[1].assetDependencyIds = [manifest.assets[0].assetId];

    const validation = validateSaltoSliceManifest(manifest);

    expect(validation.errors.some((error) => error.message.includes("Dependency cycle detected"))).toBe(true);
  });

  it("keeps optional mock composition private when implemented", async () => {
    const manifest = await mutableManifest();
    expect(validateSaltoSliceManifest(manifest).errors).toEqual([]);

    manifest.privateMockComposition.implemented = true;
    manifest.privateMockComposition.visibility = "public";

    const validation = validateSaltoSliceManifest(manifest);

    expect(validation.errors.some((error) => error.path === "privateMockComposition.visibility")).toBe(true);
  });
});

async function mutableManifest(): Promise<MutableManifest> {
  return JSON.parse(JSON.stringify(await loadSaltoSliceManifest())) as MutableManifest;
}

function createTempProject(): string {
  const projectRoot = mkdtempSync(path.join(tmpdir(), "ascendant-realms-salto-slice-"));
  copyFixture(projectRoot, SALTO_SLICE_MANIFEST_PATH);
  copyFixture(projectRoot, VISUAL_ASSET_REGISTRY_PATH);
  return projectRoot;
}

function copyFixture(projectRoot: string, relativePath: string): void {
  const target = path.join(projectRoot, relativePath);
  mkdirSync(path.dirname(target), { recursive: true });
  writeFileSync(target, readFileSync(path.join(process.cwd(), relativePath)));
}

function readPacketFiles(projectRoot: string, files: string[]): Record<string, string> {
  return Object.fromEntries(files.map((file) => [path.basename(file), readFileSync(path.join(projectRoot, file), "utf8")]));
}
