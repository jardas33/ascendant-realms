import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import stableIdSnapshot from "../portable/stable-id-snapshot.json";
import { stableStringify, type StableIdSnapshot } from "../portable/PortableContentExport";
import { CURRENT_SAVE_VERSION } from "./SaveDefaults";
import {
  createSaveTranslationContractReport,
  translateBrowserSaveFixture,
  type SaveTranslationStatus
} from "./SaveTranslationContract";

interface FixtureManifestEntry {
  id: string;
  filename: string;
  expectedStatus: SaveTranslationStatus;
  expectedSaveVersion?: number;
  expectedUnknownContentIdCount?: number;
  expectedUnsafeFieldCount?: number;
  expectedRejectionReason?: string;
}

interface FixtureManifest {
  fixtures: FixtureManifestEntry[];
}

const fixtureDir = fileURLToPath(new URL("../../../tests/fixtures/saves/v0102", import.meta.url));
const manifest = readJson<FixtureManifest>("manifest.json");
const fixtures = manifest.fixtures.map((entry) => ({
  manifest: entry,
  input: {
    id: entry.id,
    raw: readFileSync(join(fixtureDir, entry.filename), "utf8")
  }
}));
const snapshot = stableIdSnapshot as StableIdSnapshot;

describe("save translation contract fixtures", () => {
  it("keeps fixture ids unique and every manifest file loadable", () => {
    const ids = fixtures.map((fixture) => fixture.manifest.id);
    expect(new Set(ids).size).toBe(ids.length);
    fixtures.forEach((fixture) => expect(fixture.input.raw.length).toBeGreaterThan(0));
  });

  it("translates or rejects every fixture according to the v0.102 manifest", () => {
    fixtures.forEach(({ input, manifest: fixtureManifest }) => {
      const { result } = translateBrowserSaveFixture(input, snapshot);

      expect(result.status).toBe(fixtureManifest.expectedStatus);
      if (fixtureManifest.expectedSaveVersion !== undefined) {
        expect(result.saveVersion).toBe(fixtureManifest.expectedSaveVersion);
      }
      if (fixtureManifest.expectedUnknownContentIdCount !== undefined) {
        expect(result.quarantine.unknownContentIds).toHaveLength(fixtureManifest.expectedUnknownContentIdCount);
      }
      if (fixtureManifest.expectedUnsafeFieldCount !== undefined) {
        expect(result.quarantine.unsafeFields).toHaveLength(fixtureManifest.expectedUnsafeFieldCount);
      }
      if (fixtureManifest.expectedRejectionReason) {
        expect(result.quarantine.rejectionReasons).toContain(fixtureManifest.expectedRejectionReason);
      }
    });
  });

  it("wraps valid saves in the proposed desktop envelope without changing CURRENT_SAVE_VERSION", () => {
    const { envelope, result } = translateBrowserSaveFixture(
      fixtures.find((fixture) => fixture.manifest.id === "v2_relic_equipment_state")!.input,
      snapshot
    );

    expect(CURRENT_SAVE_VERSION).toBe(2);
    expect(result.status).toBe("translated");
    expect(envelope?.saveVersion).toBe(CURRENT_SAVE_VERSION);
    expect(envelope?.sourceRuntime).toBe("browser-localStorage-prototype");
    expect(envelope?.payload.hero.equipment.relic).toBe("fixture:emberbrand_shard:1");
    expect(envelope?.payload.hero.inventory.map((item) => item.itemId)).toContain("emberbrand_shard");
  });

  it("migrates V1 fixtures while recording migration history", () => {
    const { envelope, result } = translateBrowserSaveFixture(
      fixtures.find((fixture) => fixture.manifest.id === "v1_campaign_in_progress")!.input,
      snapshot
    );

    expect(result.status).toBe("translated");
    expect(result.migrationHistory).toEqual([
      {
        fromVersion: 1,
        toVersion: CURRENT_SAVE_VERSION,
        action: "migrated_v1_to_v2"
      }
    ]);
    expect(envelope?.payload.campaign.completedNodeIds).toContain("border_village");
    expect(envelope?.payload.hero.inventory[0]).toMatchObject({
      instanceId: "fixture:v1:weathered-command-sword:1",
      itemId: "weathered_command_sword"
    });
  });

  it("reports unknown content ids and unsafe fields without rejecting otherwise loadable saves", () => {
    const unknownIds = translateBrowserSaveFixture(
      fixtures.find((fixture) => fixture.manifest.id === "v2_unknown_content_id")!.input,
      snapshot
    ).result;
    const unknownFields = translateBrowserSaveFixture(
      fixtures.find((fixture) => fixture.manifest.id === "v2_unknown_extra_field")!.input,
      snapshot
    ).result;

    expect(unknownIds.status).toBe("translated_with_quarantine");
    expect(unknownIds.quarantine.unknownContentIds.map((entry) => entry.id)).toEqual(
      expect.arrayContaining(["future_class", "future_item", "future_node", "future_rival"])
    );
    expect(unknownFields.status).toBe("translated_with_quarantine");
    expect(unknownFields.quarantine.unsafeFields.map((entry) => entry.path)).toEqual(
      expect.arrayContaining(["futureExpansion", "hero.futureHeroField", "campaign.futureCampaignField"])
    );
  });

  it("rejects corrupt, missing-object, and unsupported-future saves before envelope creation", () => {
    ["corrupt_json", "missing_required_object", "unsupported_future_version"].forEach((fixtureId) => {
      const { envelope, result } = translateBrowserSaveFixture(
        fixtures.find((fixture) => fixture.manifest.id === fixtureId)!.input,
        snapshot
      );
      expect(result.status).toBe("rejected");
      expect(envelope).toBeUndefined();
    });
  });

  it("produces deterministic summary output and does not touch localStorage", () => {
    const originalLocalStorage = globalThis.localStorage;
    const storage = createMemoryStorage();
    Object.defineProperty(globalThis, "localStorage", {
      configurable: true,
      value: storage
    });
    storage.setItem("sentinel", "unchanged");
    try {
      const reportA = createSaveTranslationContractReport(
        fixtures.map((fixture) => fixture.input),
        snapshot
      );
      const reportB = createSaveTranslationContractReport(
        fixtures.map((fixture) => fixture.input),
        snapshot
      );

      expect(stableStringify(reportA)).toBe(stableStringify(reportB));
      expect(reportA.fixtureCount).toBe(16);
      expect(reportA.translatedCount).toBe(11);
      expect(reportA.translatedWithQuarantineCount).toBe(2);
      expect(reportA.rejectedCount).toBe(3);
      expect(storage.getItem("sentinel")).toBe("unchanged");
      expect(storage.length).toBe(1);
    } finally {
      Object.defineProperty(globalThis, "localStorage", {
        configurable: true,
        value: originalLocalStorage
      });
    }
  });
});

function readJson<T>(filename: string): T {
  return JSON.parse(readFileSync(join(fixtureDir, filename), "utf8")) as T;
}

function createMemoryStorage(): Storage {
  const data = new Map<string, string>();
  return {
    get length() {
      return data.size;
    },
    clear: () => data.clear(),
    getItem: (key: string) => data.get(key) ?? null,
    key: (index: number) => [...data.keys()][index] ?? null,
    removeItem: (key: string) => {
      data.delete(key);
    },
    setItem: (key: string, value: string) => {
      data.set(key, value);
    }
  };
}
