import type Phaser from "phaser";
import { describe, expect, it, vi } from "vitest";
import { BUILDING_BY_ID, UNIT_BY_ID } from "../data/contentIndex";
import { createBurnStatus } from "../systems/StatusEffectSystem";
import { Unit } from "./Unit";
import { Building } from "./Building";
import { getCommonPresentationDefaults } from "../ui/EntityPresentationConfig";

interface SceneStub extends Phaser.Scene {
  __objects: {
    circles: Array<StubGameObject & { radius: number }>;
    rectangles: StubGameObject[];
    texts: Array<StubGameObject & { text: string }>;
  };
}

interface StubGameObject {
  x: number;
  y: number;
  width: number;
  height: number;
  displayWidth: number;
  displayHeight: number;
  visible: boolean;
  add: ReturnType<typeof vi.fn>;
  addAt: ReturnType<typeof vi.fn>;
  moveTo: ReturnType<typeof vi.fn>;
  setAlpha: ReturnType<typeof vi.fn>;
  setColor: ReturnType<typeof vi.fn>;
  setDepth: ReturnType<typeof vi.fn>;
  setDisplaySize: ReturnType<typeof vi.fn>;
  setFillStyle: ReturnType<typeof vi.fn>;
  setOrigin: ReturnType<typeof vi.fn>;
  setPosition: ReturnType<typeof vi.fn>;
  setScale: ReturnType<typeof vi.fn>;
  setSize: ReturnType<typeof vi.fn>;
  setSmoothness: ReturnType<typeof vi.fn>;
  setStrokeStyle: ReturnType<typeof vi.fn>;
  setTint: ReturnType<typeof vi.fn>;
  setVisible: ReturnType<typeof vi.fn>;
  setY: ReturnType<typeof vi.fn>;
  clearTint: ReturnType<typeof vi.fn>;
  destroy: ReturnType<typeof vi.fn>;
}

describe("BaseEntity view layout", () => {
  it("keeps common layout defaults presentation-only and legacy-equivalent", () => {
    const common = getCommonPresentationDefaults();

    expect(common.selection.radiusAddPx).toBe(7);
    expect(common.selection.widthRadiusMultiplier).toBe(2.1);
    expect(common.selection.heightRadiusMultiplier).toBe(0.62);
    expect(common.health.widthRadiusMultiplier).toBe(2.4);
    expect(common.depth).toEqual({ building: 5, nonBuilding: 10 });
  });

  it("keeps the burn status marker labeled and clear of the health bar after damage", () => {
    const scene = createSceneStub();
    const worker = new Unit(scene, UNIT_BY_ID.worker, "player", 100, 100);
    const healthBack = scene.__objects.rectangles[0];
    const healthFill = scene.__objects.rectangles[1];
    const statusBadge = scene.__objects.circles[0];
    const statusBadgeLabel = scene.__objects.texts.find((text) => text.text === "BURN");

    worker.takeDamage(9);
    worker.applyStatusEffect(createBurnStatus({ damagePerSecond: 1, durationSeconds: 2, tickInterval: 1 }));

    const healthBackTop = healthBack.y - healthBack.displayHeight / 2;
    expect(statusBadge.visible).toBe(true);
    expect(statusBadge.radius).toBeGreaterThanOrEqual(5);
    expect(statusBadge.y + statusBadge.radius).toBeLessThan(healthBackTop);
    expect(statusBadgeLabel).toBeDefined();
    expect(statusBadgeLabel?.visible).toBe(true);
    expect(statusBadgeLabel?.x).toBeGreaterThan(statusBadge.x);
    expect(statusBadgeLabel?.y).toBe(statusBadge.y);
    expect(healthFill.displayWidth).toBeLessThan(42);
  });

  it("shows selected or damaged health bars in player density and restores them after healing", () => {
    const scene = createSceneStub();
    const worker = new Unit(scene, UNIT_BY_ID.worker, "player", 100, 100);
    const healthBack = scene.__objects.rectangles[0];
    const healthFill = scene.__objects.rectangles[1];

    expect(healthBack.visible).toBe(false);
    expect(healthFill.visible).toBe(false);

    worker.setSelected(true);
    expect(healthBack.visible).toBe(true);
    expect(healthFill.visible).toBe(true);

    worker.setSelected(false);
    worker.takeDamage(9);
    expect(healthBack.visible).toBe(true);
    expect(healthFill.displayWidth).toBeLessThan(42);

    worker.heal(1000);
    expect(healthBack.visible).toBe(false);
    expect(healthFill.visible).toBe(false);
  });

  it("keeps full-health bars available in debug and hides them again in minimal", () => {
    const scene = createSceneStub();
    const worker = new Unit(scene, UNIT_BY_ID.worker, "player", 100, 100);
    const healthBack = scene.__objects.rectangles[0];

    worker.setHealthPresentationMode("debug");
    expect(healthBack.visible).toBe(true);

    worker.setHealthPresentationMode("minimal");
    expect(healthBack.visible).toBe(false);
  });

  it("uses the same truthful visibility contract for selected and damaged buildings", () => {
    const scene = createSceneStub();
    const hall = new Building(scene, BUILDING_BY_ID.command_hall, "player", 220, 180);
    const healthBack = scene.__objects.rectangles[0];

    expect(healthBack.visible).toBe(false);
    hall.setSelected(true);
    expect(healthBack.visible).toBe(true);

    hall.setSelected(false);
    hall.takeDamage(20);
    expect(healthBack.visible).toBe(true);

    hall.heal(1000);
    expect(healthBack.visible).toBe(false);
  });
});

function createSceneStub(): SceneStub {
  const objects = {
    circles: [] as Array<StubGameObject & { radius: number }>,
    rectangles: [] as StubGameObject[],
    texts: [] as Array<StubGameObject & { text: string }>
  };

  const makeObject = (overrides: Partial<StubGameObject> = {}): StubGameObject => {
    const object = {
      x: 0,
      y: 0,
      width: 48,
      height: 48,
      displayWidth: 0,
      displayHeight: 0,
      visible: true,
      add: vi.fn(() => object),
      addAt: vi.fn(() => object),
      moveTo: vi.fn(() => object),
      setAlpha: vi.fn(() => object),
      setColor: vi.fn(() => object),
      setDepth: vi.fn(() => object),
      setDisplaySize: vi.fn((width: number, height: number) => {
        object.displayWidth = width;
        object.displayHeight = height;
        return object;
      }),
      setFillStyle: vi.fn(() => object),
      setOrigin: vi.fn(() => object),
      setPosition: vi.fn((x: number, y: number) => {
        object.x = x;
        object.y = y;
        return object;
      }),
      setScale: vi.fn(() => object),
      setSize: vi.fn((width: number, height: number) => {
        object.width = width;
        object.height = height;
        return object;
      }),
      setSmoothness: vi.fn(() => object),
      setStrokeStyle: vi.fn(() => object),
      setTint: vi.fn(() => object),
      setVisible: vi.fn((visible: boolean) => {
        object.visible = visible;
        return object;
      }),
      setY: vi.fn((y: number) => {
        object.y = y;
        return object;
      }),
      clearTint: vi.fn(() => object),
      destroy: vi.fn()
    };
    return Object.assign(object, overrides);
  };

  return {
    __objects: objects,
    textures: {
      exists: vi.fn(() => false)
    },
    add: {
      circle: vi.fn((x: number, y: number, radius: number) => {
        const object = Object.assign(makeObject({ x, y }), { radius });
        objects.circles.push(object);
        return object;
      }),
      container: vi.fn((x: number, y: number) => makeObject({ x, y })),
      ellipse: vi.fn(() => makeObject()),
      image: vi.fn(() => makeObject()),
      rectangle: vi.fn((x: number, y: number, width: number, height: number) => {
        const object = makeObject({ x, y, width, height, displayWidth: width, displayHeight: height });
        objects.rectangles.push(object);
        return object;
      }),
      text: vi.fn((x: number, y: number, text: string) => {
        const object = Object.assign(makeObject({ x, y }), { text });
        objects.texts.push(object);
        return object;
      })
    }
  } as unknown as SceneStub;
}
