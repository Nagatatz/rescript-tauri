import {definePackageConfig} from "../../tools/vitest.shared.mjs"

// Thresholds set 5 pt below the value measured after the initial
// implementation. Branches sit at 50% because half the upstream
// sendNotification overload arms (string vs record) are exercised
// separately in two test cases — each one only sees one branch.
// Raise this floor only after a corresponding test addition.
export default definePackageConfig({
  thresholds: {
    statements: 95,
    branches: 45,
    functions: 95,
    lines: 95,
  },
})
