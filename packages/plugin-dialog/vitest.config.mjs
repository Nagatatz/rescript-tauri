import {definePackageConfig} from "../../tools/vitest.shared.mjs"

// PluginDialog statements / functions / lines hit 100% — must stay
// there. Branches at 60% reflect the optional argument shape; raise
// as additional default-branch combinations get exercised.
export default definePackageConfig({
  thresholds: {
    statements: 100,
    branches: 55,
    functions: 100,
    lines: 100,
  },
})
