// App exposes thin wrappers over @tauri-apps/api/app. Each upstream
// function calls invoke('plugin:app|...'), which we intercept via
// Mocks.mockIPC. We assert the value flows back to the caller; the
// exact command name is verified loosely (substring match) so an
// upstream rename (e.g. plugin:app|name -> plugin:app|get_name)
// doesn't ratchet false negatives.
import { afterEach, beforeEach, describe, expect, it } from "vitest"
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
