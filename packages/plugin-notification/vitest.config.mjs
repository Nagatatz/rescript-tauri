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
      // Thresholds set 5 pt below the value measured after the
      // initial implementation. Branches sit at 50% because half the
      // upstream sendNotification overload arms (string vs record)
      // are exercised separately in two test cases — each one only
      // sees one branch. Raise this floor only after a corresponding
      // test addition.
      thresholds: {
        statements: 95,
        branches: 45,
        functions: 95,
        lines: 95,
      },
    },
  },
})
