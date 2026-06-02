import Phaser from "phaser";
import { gameConfig } from "./game/config";
import { installPrivatePerformanceProfiler } from "./game/playtest/PrivatePerformanceProfiler";
import { isPrivatePlaytestToolsEnabled } from "./game/playtest/PrivatePlaytestTools";
import "./game/styles/ui.css";

declare global {
  interface Window {
    ascendantRealmsGame?: Phaser.Game;
  }
}

window.addEventListener("contextmenu", (event) => event.preventDefault());

window.ascendantRealmsGame = new Phaser.Game(gameConfig);
installPrivatePerformanceProfiler({ enabled: isPrivatePlaytestToolsEnabled(), defaultScenarioId: "manual_private_review" });
