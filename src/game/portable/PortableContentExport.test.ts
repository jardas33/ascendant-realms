import { mkdtemp, readFile, rm } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { describe, expect, it } from "vitest";
import {
  createPortableContentExport,
  createStableIdManifest,
  createStableIdSnapshot,
  PORTABLE_CONTENT_CATEGORY_IDS,
  stableStringify,
  validatePortableContentExport,
  writePortableContentExport,
  type PortableContentExport
} from "./PortableContentExport";

function cloneExport(contentExport: PortableContentExport): PortableContentExport {
  return JSON.parse(stableStringify(contentExport)) as PortableContentExport;
}

describe("portable content export", () => {
  it("exports the requested downstream-only content categories", () => {
    const contentExport = createPortableContentExport();
    const manifest = createStableIdManifest(contentExport);

    expect(Object.keys(contentExport.categories)).toEqual([...PORTABLE_CONTENT_CATEGORY_IDS].sort());
    expect(contentExport.authority).toBe("typescript-source");
    expect(contentExport.runtimeBehavior).toBe("unchanged-downstream-export");
    expect(contentExport.categories.factions.map((entry) => entry.id)).toEqual(
      expect.arrayContaining(["free_marches", "ashen_covenant", "sylvan_concord"])
    );
    expect(contentExport.categories.nodes.map((entry) => entry.id)).toContain("ashen_outpost");
    expect(contentExport.categories.relics.map((entry) => entry.id)).toEqual(
      expect.arrayContaining(["emberbrand_shard", "cinderseer_focus", "outpost_command_signet"])
    );
    expect(contentExport.categories.lumeNetworks.map((entry) => entry.id)).toEqual(["aether_well_ruins_lume_ward"]);
    expect(manifest.entries.length).toBeGreaterThan(200);
  });

  it("validates the current export against its stable ID snapshot", () => {
    const contentExport = createPortableContentExport();
    const snapshot = createStableIdSnapshot(contentExport);

    expect(validatePortableContentExport(contentExport, snapshot)).toEqual([]);
  });

  it("detects duplicate ids inside a portable category", () => {
    const contentExport = cloneExport(createPortableContentExport());
    contentExport.categories.abilities.push({ ...contentExport.categories.abilities[0] });

    expect(validatePortableContentExport(contentExport)).toContain("Duplicate portable content id in abilities: arcane_burst");
  });

  it("detects missing stable references", () => {
    const contentExport = cloneExport(createPortableContentExport());
    contentExport.categories.units[0].data = {
      ...(contentExport.categories.units[0].data as Record<string, unknown>),
      factionId: "missing_faction"
    };

    expect(validatePortableContentExport(contentExport)).toContain(
      "Portable content units:acolyte references unknown factions id missing_faction at factionId."
    );
  });

  it("detects stable ID snapshot drift", () => {
    const contentExport = createPortableContentExport();
    const snapshot = createStableIdSnapshot(contentExport);
    snapshot.categories.units = snapshot.categories.units.filter((id) => id !== "worker");

    expect(validatePortableContentExport(contentExport, snapshot).some((error) => error.includes("Stable ID snapshot mismatch for units."))).toBe(true);
  });

  it("writes deterministic artifacts byte-for-byte", async () => {
    const root = await mkdtemp(join(tmpdir(), "portable-content-test-"));
    const leftDir = join(root, "left");
    const rightDir = join(root, "right");
    try {
      await writePortableContentExport(leftDir);
      await writePortableContentExport(rightDir);
      await Promise.all(
        ["content-export.json", "stable-id-manifest.json", "content-export-summary.md", "content-export-hashes.json"].map(
          async (fileName) => {
            const left = await readFile(join(leftDir, fileName), "utf8");
            const right = await readFile(join(rightDir, fileName), "utf8");
            expect(left).toBe(right);
          }
        )
      );
    } finally {
      await rm(root, { force: true, recursive: true });
    }
  });
});
