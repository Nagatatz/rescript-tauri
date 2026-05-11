import {definePackageConfig} from "../../tools/vitest.shared.mjs"

// Schema's surface is 4 helper functions (toDecoder / fromSchemas /
// channelFromSchema / eventFromSchema) plus the S re-export. Functions
// hit 100%; statements / lines floor sits a hair below the measured
// 90.9 / 90 to absorb v8 jitter.
export default definePackageConfig({
  thresholds: {
    statements: 88,
    branches: 45,
    functions: 95,
    lines: 88,
  },
})
