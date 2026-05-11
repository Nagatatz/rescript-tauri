import { definePackageConfig } from "../../tools/vitest.shared.mjs"

// PluginFs is a thin wrapper of 14 single-shot IO functions —
// statements / functions / lines hit 100% and must stay there.
// Branches sit at 50% because each function carries an optional
// `~options` arg whose absent branch isn't always exercised; raise
// the branch floor as more option permutations get covered.
export default definePackageConfig({
  thresholds: {
    statements: 100,
    branches: 45,
    functions: 100,
    lines: 100,
  },
})
