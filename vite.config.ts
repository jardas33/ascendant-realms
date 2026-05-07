import { defineConfig } from "vitest/config";

export default defineConfig({
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
});
