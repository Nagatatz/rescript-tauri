import {definePackageConfig} from "../../tools/vitest.shared.mjs"

// PluginShell currently runs in observe-only mode (no thresholds);
// add a `thresholds: {...}` arg once an initial floor is agreed on.
export default definePackageConfig()
