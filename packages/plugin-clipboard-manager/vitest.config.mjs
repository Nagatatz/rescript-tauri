import {definePackageConfig} from "../../tools/vitest.shared.mjs"

export default definePackageConfig({
  thresholds: {
    statements: 95,
    branches: 50,
    functions: 95,
    lines: 95,
  },
})
