import { defineConfig } from "vitest/config"

export default defineConfig({
  test: {
    environment: "happy-dom",
    include: ["tests/runtime/**/*.test.mjs"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.res.mjs"],
      exclude: ["src/**/*.test.mjs", "tests/**", "node_modules/**", "lib/**"],
      reporter: ["text-summary", "json-summary", "lcov", "html"],
      reportsDirectory: "./coverage",
      reportOnFailure: false,
      // PluginDialog statements / functions / lines hit 100% — must
      // stay there. Branches at 60% reflect the optional argument
      // shape; raise as additional default-branch combinations get
      // exercised.
      thresholds: {
        statements: 100,
        branches: 55,
        functions: 100,
        lines: 100,
      },
    },
  },
})
