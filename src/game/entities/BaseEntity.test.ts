import type Phaser from "phaser";
import { describe, expect, it, vi } from "vitest";
import { UNIT_BY_ID } from "../data/contentIndex";
import { createBurnStatus } from "../systems/StatusEffectSystem";
import { Unit } from "./Unit";

interface SceneStub extends Phaser.Scene {
  __objects: {
    circles: Array<StubGameObject & { radius: number }>;
    rectangles: StubGameObject[];
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
  it("keeps the burn status badge outside the laid-out health bar after damage", () => {
    const scene = createSceneStub();
    const worker = new Unit(scene, UNIT_BY_ID.worker, "player", 100, 100);
    const healthBack = scene.__objects.rectangles[0];
    const statusBadge = scene.__objects.circles[0];

    worker.takeDamage(9);
    worker.applyStatusEffect(createBurnStatus({ damagePerSecond: 1, durationSeconds: 2, tickInterval: 1 }));

    const healthBackRight = healthBack.x + healthBack.displayWidth;
    const statusBadgeLeft = statusBadge.x - statusBadge.radius;
    expect(statusBadge.visible).toBe(true);
    expect(statusBadge.y).toBe(healthBack.y);
    expect(statusBadgeLeft).toBeGreaterThan(healthBackRight);
  });
});

function createSceneStub(): SceneStub {
  const objects = {
    circles: [] as Array<StubGameObject & { radius: number }>,
    rectangles: [] as StubGameObject[]
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
      text: vi.fn(() => makeObject())
    }
  } as unknown as SceneStub;
}
