export const SCENE_KEYS = {
  boot: "BootScene",
  mainMenu: "MainMenuScene",
  assetGallery: "AssetGalleryScene",
  heroCreation: "HeroCreationScene",
  skirmishSetup: "SkirmishSetupScene",
  battle: "BattleScene",
  results: "ResultsScene",
  heroProgression: "HeroProgressionScene"
} as const;

export type SceneKey = (typeof SCENE_KEYS)[keyof typeof SCENE_KEYS];
