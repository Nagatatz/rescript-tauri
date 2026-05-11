import {definePackageConfig} from "../../tools/vitest.shared.mjs"

// Thresholds set 2-3 pt below the value measured after the C/D/E
// residual cleanup (invokeExn Ok path, Window drag-drop variant
// interpretation, the Menu accessors that had been skipped). The
// remaining uncovered surface is the defensive-fallback category that
// won't fire under normal operation (Internal.exnToJson non-Error
// fallback, Event listen/once with-target wrapper closures). Raise
// this floor only after a corresponding test addition.
export default definePackageConfig({
  thresholds: {
    statements: 96,
    branches: 80,
    functions: 96,
    lines: 96,
  },
})
