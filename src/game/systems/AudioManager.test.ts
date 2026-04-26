import { describe, expect, it } from "vitest";
import { DEFAULT_SETTINGS } from "../core/Settings";
import { AudioManager } from "./AudioManager";

describe("AudioManager", () => {
  it("does not throw when browser audio APIs are unavailable", () => {
    AudioManager.configure({ ...DEFAULT_SETTINGS, masterVolume: 0.5, sfxVolume: 0.5 });

    expect(() => AudioManager.play("ui_click")).not.toThrow();
    expect(() => AudioManager.play("build_complete")).not.toThrow();
  });

  it("does not throw when volume is muted", () => {
    AudioManager.configure({ ...DEFAULT_SETTINGS, masterVolume: 0 });

    expect(() => AudioManager.play("victory")).not.toThrow();
  });
});
