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
      // Schema's surface is 4 helper functions (toDecoder /
      // fromSchemas / channelFromSchema / eventFromSchema) plus the
      // S re-export. Functions hit 100%; statements / lines floor
      // sits a hair below the measured 90.9 / 90 to absorb v8 jitter.
      thresholds: {
        statements: 88,
        branches: 45,
        functions: 95,
        lines: 88,
      },
    },
  },
})
