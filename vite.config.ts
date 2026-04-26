import { defineConfig } from "vitest/config";

export default defineConfig({
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
