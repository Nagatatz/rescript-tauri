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
      // Thresholds set 2-3 pt below the value measured after the
      // C/D/E residual cleanup (invokeExn Ok path, Window drag-drop
      // variant interpretation, the Menu accessors that had been
      // skipped). The remaining uncovered surface is the
      // defensive-fallback category that won't fire under normal
      // operation (Internal.exnToJson non-Error fallback, Event
      // listen/once with-target wrapper closures). Raise this floor
      // only after a corresponding test addition.
      thresholds: {
        statements: 96,
        branches: 80,
        functions: 96,
        lines: 96,
      },
    },
  },
})
