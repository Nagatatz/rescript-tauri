// App exposes thin wrappers over @tauri-apps/api/app. Each upstream
// function calls invoke('plugin:app|...'), which we intercept via
// Mocks.mockIPC. We assert the value flows back to the caller; the
// exact command name is verified loosely (substring match) so an
// upstream rename (e.g. plugin:app|name -> plugin:app|get_name)
// doesn't ratchet false negatives.
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import * as App from "../../src/App.res.mjs"
import * as Mocks from "../../src/Mocks.res.mjs"

describe("App", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("getName forwards the rust-side string", async () => {
    Mocks.mockIPC(async () => "rescript-tauri-demo")
    expect(await App.getName()).toBe("rescript-tauri-demo")
  })

  it("getVersion forwards the rust-side string", async () => {
    Mocks.mockIPC(async () => "0.1.0")
    expect(await App.getVersion()).toBe("0.1.0")
  })

  it("getTauriVersion forwards the rust-side string", async () => {
    Mocks.mockIPC(async () => "2.0.0")
    expect(await App.getTauriVersion()).toBe("2.0.0")
  })

  it("getIdentifier forwards the rust-side bundle id", async () => {
    Mocks.mockIPC(async () => "com.example.app")
    expect(await App.getIdentifier()).toBe("com.example.app")
  })

  it("show resolves without throwing", async () => {
    Mocks.mockIPC(async () => null)
    // Mocks return null; ReScript's `promise<unit>` doesn't coerce.
    await expect(App.show()).resolves.toBeNull()
  })

  it("hide resolves without throwing", async () => {
    Mocks.mockIPC(async () => null)
    await expect(App.hide()).resolves.toBeNull()
  })

  it("defaultWindowIcon returns null when the rust side has none", async () => {
    Mocks.mockIPC(async () => null)
    const icon = await App.defaultWindowIcon()
    expect(icon === null || typeof icon === "undefined").toBe(true)
  })

  it("defaultWindowIcon returns an Image handle when a rid comes back", async () => {
    // upstream wraps the rid in `new Image(rid)`, so a non-null
    // mocked rid produces a non-null handle.
    Mocks.mockIPC(async () => 42)
    const icon = await App.defaultWindowIcon()
    expect(icon).not.toBeNull()
  })

  it("setTheme(null) defers to the OS setting", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await App.setTheme(null)
    expect(captured.cmd).toContain("theme")
    expect(captured.args).toEqual({ theme: null })
  })

  it('setTheme("dark") forwards the polymorphic-variant value', async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await App.setTheme("dark")
    expect(captured.args).toEqual({ theme: "dark" })
  })

  it("setDockVisibility forwards the boolean", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await App.setDockVisibility(true)
    expect(captured.args).toEqual({ visible: true })
  })
})

describe("App extras", () => {
  let AppExtras
  let MocksExtras

  beforeEach(async () => {
    AppExtras = await import("../../src/App.res.mjs")
    MocksExtras = await import("../../src/Mocks.res.mjs")
  })

  afterEach(() => {
    MocksExtras.clearMocks()
  })

  it("getBundleType dispatches plugin:app|bundle_type and decodes the variant", async () => {
    MocksExtras.mockIPC(async (cmd, _args) => {
      expect(cmd).toBe("plugin:app|bundle_type")
      return "msi"
    })
    const got = await AppExtras.getBundleType()
    expect(got).toBe("msi")
  })

  it("supportsMultipleWindows dispatches plugin:app|supports_multiple_windows", async () => {
    MocksExtras.mockIPC(async (cmd, _args) => {
      expect(cmd).toBe("plugin:app|supports_multiple_windows")
      return true
    })
    expect(await AppExtras.supportsMultipleWindows()).toBe(true)
  })

  it("fetchDataStoreIdentifiers and removeDataStore dispatch the upstream commands", async () => {
    const seen = []
    MocksExtras.mockIPC(async (cmd, args) => {
      seen.push([cmd, args])
      if (cmd === "plugin:app|fetch_data_store_identifiers") {
        return [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]]
      }
      return null
    })
    const ids = await AppExtras.fetchDataStoreIdentifiers()
    expect(ids).toHaveLength(1)
    expect(ids[0]).toHaveLength(16)

    await AppExtras.removeDataStore(ids[0])
    expect(seen.map(([c]) => c)).toEqual([
      "plugin:app|fetch_data_store_identifiers",
      "plugin:app|remove_data_store",
    ])
  })

  it("onBackButtonPress registers a plugin listener", async () => {
    MocksExtras.mockIPC(async (cmd, _args) => {
      if (cmd === "plugin:app|on_back_button_press") return 0
      if (cmd === "plugin:app|register_listener") return 0
      return null
    })
    const handler = vi.fn()
    const listener = await AppExtras.onBackButtonPress(handler)
    // PluginListener handles are returned; smoke-test the accessors.
    expect(typeof listener).toBe("object")
  })
})
