import {defineConfig} from "vitest/config"

/**
 * Shared vitest config for `@rescript-tauri/*` packages.
 *
 * Encodes the boilerplate every package's `vitest.config.mjs` has shared
 * verbatim — happy-dom test environment, `tests/runtime/**` test discovery,
 * v8 coverage scoped to `src/**\/*.res.mjs`, and the standard reporter set.
 *
 * @param {object} [opts]
 * @param {{statements?: number, branches?: number, functions?: number, lines?: number}} [opts.thresholds]
 *   When supplied, vitest fails the run if coverage drops below the floors.
 *   Omit to run coverage in observe-only mode (no CI gate).
 */
export function definePackageConfig({thresholds} = {}) {
  return defineConfig({
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
        ...(thresholds ? {thresholds} : {}),
      },
    },
  })
}
