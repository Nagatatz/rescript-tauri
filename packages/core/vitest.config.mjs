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
      // Thresholds set 2-3 pt below the value measured at the close
      // of steering 051 so coverage cannot regress. To raise these,
      // re-run `pnpm --filter @rescript-tauri/core test:coverage`
      // and bump in lockstep with the new floor.
      thresholds: {
        statements: 92,
        branches: 73,
        functions: 95,
        lines: 92,
      },
    },
  },
})
