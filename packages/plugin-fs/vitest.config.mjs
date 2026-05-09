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
      // PluginFs is a thin wrapper of 14 single-shot IO functions —
      // statements / functions / lines hit 100% and must stay there.
      // Branches sit at 50% because each function carries an optional
      // `~options` arg whose absent branch isn't always exercised;
      // raise the branch floor as more option permutations get covered.
      thresholds: {
        statements: 100,
        branches: 45,
        functions: 100,
        lines: 100,
      },
    },
  },
})
