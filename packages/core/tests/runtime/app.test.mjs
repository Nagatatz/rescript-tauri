import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

describe("App extras", () => {
  let App
  let Mocks

  beforeEach(async () => {
    App = await import("../../src/App.res.mjs")
    Mocks = await import("../../src/Mocks.res.mjs")
  })

  afterEach(() => {
    Mocks.clearMocks()
  })

  it("getBundleType dispatches plugin:app|bundle_type and decodes the variant", async () => {
    Mocks.mockIPC(async (cmd, _args) => {
      expect(cmd).toBe("plugin:app|bundle_type")
      return "msi"
    })
    const got = await App.getBundleType()
    expect(got).toBe("msi")
  })

  it("supportsMultipleWindows dispatches plugin:app|supports_multiple_windows", async () => {
    Mocks.mockIPC(async (cmd, _args) => {
      expect(cmd).toBe("plugin:app|supports_multiple_windows")
      return true
    })
    expect(await App.supportsMultipleWindows()).toBe(true)
  })

  it("fetchDataStoreIdentifiers and removeDataStore dispatch the upstream commands", async () => {
    const seen = []
    Mocks.mockIPC(async (cmd, args) => {
      seen.push([cmd, args])
      if (cmd === "plugin:app|fetch_data_store_identifiers") {
        return [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]]
      }
      return null
    })
    const ids = await App.fetchDataStoreIdentifiers()
    expect(ids).toHaveLength(1)
    expect(ids[0]).toHaveLength(16)

    await App.removeDataStore(ids[0])
    expect(seen.map(([c]) => c)).toEqual([
      "plugin:app|fetch_data_store_identifiers",
      "plugin:app|remove_data_store",
    ])
  })

  it("onBackButtonPress registers a plugin listener", async () => {
    Mocks.mockIPC(async (cmd, _args) => {
      if (cmd === "plugin:app|on_back_button_press") return 0
      if (cmd === "plugin:app|register_listener") return 0
      return null
    })
    const handler = vi.fn()
    const listener = await App.onBackButtonPress(handler)
    // PluginListener handles are returned; smoke-test the accessors.
    expect(typeof listener).toBe("object")
  })
})
