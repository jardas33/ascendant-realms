import Phaser from "phaser";
import { AssetGalleryScene } from "./scenes/AssetGalleryScene";
import { BattleScene } from "./scenes/BattleScene";
import { BootScene } from "./scenes/BootScene";
import { HeroCreationScene } from "./scenes/HeroCreationScene";
import { HeroProgressionScene } from "./scenes/HeroProgressionScene";
import { MainMenuScene } from "./scenes/MainMenuScene";
import { ResultsScene } from "./scenes/ResultsScene";
import { SkirmishSetupScene } from "./scenes/SkirmishSetupScene";

export const gameConfig: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  parent: "game-root",
  backgroundColor: "#18221d",
  scale: {
    mode: Phaser.Scale.RESIZE,
    autoCenter: Phaser.Scale.CENTER_BOTH,
    width: 1280,
    height: 720
  },
  render: {
    antialias: true,
    pixelArt: false
  },
  scene: [
    BootScene,
    MainMenuScene,
    AssetGalleryScene,
    HeroCreationScene,
    SkirmishSetupScene,
    BattleScene,
    ResultsScene,
    HeroProgressionScene
  ]
};
