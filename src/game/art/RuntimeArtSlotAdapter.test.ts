import { describe, expect, it } from "vitest";
import {
  isAllowedRuntimeAssetPath,
  resolveRuntimeArtSlot,
  resolveRuntimeArtSlots,
  validateRuntimeArtSlots
} from "./RuntimeArtSlotAdapter";
import { EXPECTED_RUNTIME_ART_SLOT_IDS, RUNTIME_ART_SLOTS } from "./RuntimeArtSlots";
import type { RuntimeArtSlotDefinition } from "./RuntimeArtSlotTypes";
import {
  isRuntimeArtSlotDiagnosticsEnabledForPosture,
  isRuntimeArtSlotMockModeEnabledForPosture
} from "../playtest/PrivateRuntimeArtSlotDiagnostics";

describe("RuntimeArtSlotAdapter", () => {
  it("preserves the v0.106 stable slot contract and fallback coverage", () => {
    const result = validateRuntimeArtSlots();
    expect(result.errors).toEqual([]);
    expect(result.slotCount).toBe(52);
    expect(RUNTIME_ART_SLOTS.map((slot) => slot.slotId)).toEqual(EXPECTED_RUNTIME_ART_SLOT_IDS);
    expect(resolveRuntimeArtSlots().every((resolution) => resolution.source === "fallback")).toBe(true);
  });

  it("records sprite-primary and vector-fallback truth for the four audited core families", () => {
    const audited = ["barrosan-hero", "barrosan-militia", "barrosan-ranger", "barrosan-command-hall"];
    const records = audited.map((slotId) => RUNTIME_ART_SLOTS.find((slot) => slot.slotId === slotId));

    expect(records.every((record) => record !== undefined)).toBe(true);
    for (const record of records) {
      expect(record?.runtimeSurface).toContain("loaded sprite primary when texture exists");
      expect(record?.fallback.kind).toBe("phaser-vector");
      expect(record?.fallback.owner).toBe("src/game/ui/PlaceholderBattlefieldPresentation.ts");
      expect(record?.fallback.description).toContain("only when");
      expect(record?.registryMapping.notes).toContain("Provenance, licence, and production approval remain incomplete.");
    }

    const aster = records[0];
    const militia = records[1];
    const ranger = records[2];
    const commandHall = records[3];
    expect(aster?.registryMapping.notes).toContain("warlord_hero_battle_sprite");
    expect(militia?.registryMapping.notes).toContain("militia_unit_sprite");
    expect(ranger?.registryMapping.notes).toContain("ranger_unit_sprite");
    expect(commandHall?.registryMapping.notes).toContain("command_hall_building_sprite");
    expect(RUNTIME_ART_SLOTS).toHaveLength(52);
    expect(RUNTIME_ART_SLOTS.find((slot) => slot.slotId === "barrosan-worker")?.fallback.owner).toBe(
      "src/game/ui/PlaceholderBattlefieldPresentation.ts"
    );
  });

  it("rejects unknown slots and never treats missing runtime art as a load blocker", () => {
    expect(() => resolveRuntimeArtSlot("missing-slot")).toThrow(/Unknown runtime art slot/u);
    const resolution = resolveRuntimeArtSlot("terrain-ground");
    expect(resolution.shouldLoadAsset).toBe(false);
    expect(resolution.source).toBe("fallback");
    expect(resolution.fallback.owner).toContain("BattleSceneMapRenderer");
  });

  it("loads only runtime-integrated assets from the allowed runtime-art path", () => {
    const slot = withApprovedAsset("terrain-ground", {
      reviewState: "runtime-integrated",
      path: "public/assets/runtime-art/terrain-ground.webp"
    });
    const resolution = resolveRuntimeArtSlot("terrain-ground", { slots: [slot], fileExists: () => true });
    expect(resolution.source).toBe("runtime-asset");
    expect(resolution.shouldLoadAsset).toBe(true);
    expect(validateRuntimeArtSlots({ slots: [slot], fileExists: () => true }).errors).toEqual([]);
  });

  it("keeps runtime-candidate-approved assets non-loadable until runtime-integrated", () => {
    const slot = withApprovedAsset("terrain-ground", {
      reviewState: "runtime-candidate-approved",
      path: "public/assets/runtime-art/terrain-ground.webp"
    });
    const resolution = resolveRuntimeArtSlot("terrain-ground", { slots: [slot], fileExists: () => true });
    const result = validateRuntimeArtSlots({ slots: [slot], fileExists: () => true });
    expect(resolution.source).toBe("fallback");
    expect(resolution.shouldLoadAsset).toBe(false);
    expect(result.errors.map((error) => error.message).join("\n")).toContain("runtime-integrated is required");
  });

  it("blocks candidate folders and direct final-art bypass paths", () => {
    expect(isAllowedRuntimeAssetPath("artifacts/art-review/candidates/foo.png")).toBe(false);
    expect(isAllowedRuntimeAssetPath("public/assets/final/foo.png")).toBe(false);
    expect(isAllowedRuntimeAssetPath("public/assets/runtime-art/foo.txt")).toBe(false);

    const candidateSlot = withApprovedAsset("terrain-ground", {
      reviewState: "runtime-integrated",
      path: "artifacts/art-review/candidates/foo.png"
    });
    const finalSlot = withApprovedAsset("terrain-road", {
      reviewState: "runtime-integrated",
      path: "public/assets/final/foo.png"
    });
    const result = validateRuntimeArtSlots({ slots: [candidateSlot, finalSlot], fileExists: () => true });
    expect(result.errors).toHaveLength(2);
    expect(result.errors.map((error) => error.message).join("\n")).toContain("must live under public/assets/runtime-art");
  });

  it("keeps diagnostics and mock routing private-only", () => {
    expect(isRuntimeArtSlotDiagnosticsEnabledForPosture(false, false)).toBe(false);
    expect(isRuntimeArtSlotDiagnosticsEnabledForPosture(false, undefined)).toBe(false);
    expect(isRuntimeArtSlotDiagnosticsEnabledForPosture(false, true)).toBe(true);
    expect(isRuntimeArtSlotDiagnosticsEnabledForPosture(true, false)).toBe(false);
    expect(isRuntimeArtSlotMockModeEnabledForPosture(false, false, true)).toBe(false);
    expect(isRuntimeArtSlotMockModeEnabledForPosture(false, true, true)).toBe(true);

    const publicResolution = resolveRuntimeArtSlot("hud-frame", { privateToolsEnabled: false, privateMockMode: true });
    const privateResolution = resolveRuntimeArtSlot("hud-frame", { privateToolsEnabled: true, privateMockMode: true });
    expect(publicResolution.source).toBe("fallback");
    expect(privateResolution.source).toBe("mock");
    expect(privateResolution.shouldLoadAsset).toBe(false);
  });
});

function withApprovedAsset(
  slotId: string,
  overrides: { reviewState: NonNullable<RuntimeArtSlotDefinition["approvedAsset"]>["reviewState"]; path: string }
): RuntimeArtSlotDefinition {
  const slot = RUNTIME_ART_SLOTS.find((entry) => entry.slotId === slotId);
  if (!slot) {
    throw new Error(`Missing test slot ${slotId}.`);
  }
  return {
    ...slot,
    approvedAsset: {
      assetId: `${slotId}-test-asset`,
      reviewState: overrides.reviewState,
      path: overrides.path,
      mimeType: "image/webp",
      width: 128,
      height: 128,
      integratedAtCheckpoint: "v0.106",
      proof: {
        humanApprovalDoc: "docs/V0106_ART_SLOT_VALIDATION_REPORT.md",
        validator: "npm run validate:runtime-art-slots"
      }
    }
  };
}
