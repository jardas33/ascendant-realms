import { visualizer } from "rollup-plugin-visualizer";
import { defineConfig } from "vitest/config";

export default defineConfig(({ mode }) => ({
  plugins:
    mode === "analyze"
      ? [
          visualizer({
            filename: "bundle-analysis/stats.html",
            gzipSize: true,
            brotliSize: true,
            template: "treemap",
            title: "Ascendant Realms Bundle Analysis"
          }),
          visualizer({
            filename: "bundle-analysis/stats.json",
            gzipSize: true,
            brotliSize: true,
            template: "raw-data"
          })
        ]
      : [],
  build: {
    rollupOptions: {
      output: {
        manualChunks(id: string) {
          if (id.includes("node_modules/phaser")) {
            return "vendor-phaser";
          }
        }
      }
    }
  },
  server: {
    port: 5173
  },
  preview: {
    port: 4173
  },
  test: {
    exclude: ["node_modules/**", "dist/**", "tests/e2e/**"]
  }
}));
