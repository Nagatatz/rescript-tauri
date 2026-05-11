import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import { installOsPluginInternals } from "../../../../tools/tauri-mocks.mjs"
import * as PluginOs from "../../src/PluginOs.res.mjs"

describe("PluginOs", () => {
  let cleanup
  beforeEach(() => {
    cleanup = installOsPluginInternals()
    Mocks.clearMocks()
  })
  afterEach(() => {
    Mocks.clearMocks()
    cleanup()
  })

  describe("sync getters", () => {
    it("eol returns the string from __TAURI_OS_PLUGIN_INTERNALS__", () => {
      expect(PluginOs.eol()).toBe("\n")
    })

    it("platform returns the upstream platform value", () => {
      expect(PluginOs.platform()).toBe("macos")
    })

    it("version returns the upstream version string", () => {
      expect(PluginOs.version()).toBe("14.0")
    })

    it("family returns the upstream family value", () => {
      expect(PluginOs.family()).toBe("unix")
    })

    it("OsType.get returns the upstream os_type value", () => {
      expect(PluginOs.OsType.get()).toBe("macos")
    })

    it("arch returns the upstream arch value", () => {
      expect(PluginOs.arch()).toBe("aarch64")
    })

    it("exeExtension returns the upstream exe_extension string", () => {
      expect(PluginOs.exeExtension()).toBe("")
    })
  })

  describe("async getters", () => {
    it("locale dispatches plugin:os|locale", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd) => {
        captured = cmd
        return "en-US"
      })
      const result = await PluginOs.locale()
      expect(captured).toBe("plugin:os|locale")
      expect(result).toBe("en-US")
    })

    it("locale returns Nullable.null when upstream returns null", async () => {
      Mocks.mockIPC(async () => null)
      const result = await PluginOs.locale()
      expect(result).toBeNull()
    })

    it("hostname dispatches plugin:os|hostname", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd) => {
        captured = cmd
        return "my-machine"
      })
      const result = await PluginOs.hostname()
      expect(captured).toBe("plugin:os|hostname")
      expect(result).toBe("my-machine")
    })
  })
})
