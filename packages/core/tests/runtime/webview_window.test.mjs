// WebviewWindow exposes a thin wrapper over the upstream JS class.
// asWindow / asWebview are %identity casts (no runtime work), so we
// can verify them by calling Window.label / Webview.label on the
// recast handle.
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as Mocks from "../../src/Mocks.res.mjs"
import * as Webview from "../../src/Webview.res.mjs"
import * as WebviewWindow from "../../src/WebviewWindow.res.mjs"
import * as Window from "../../src/Window.res.mjs"

const installMetadata = (label) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = globalThis.window.__TAURI_INTERNALS__ ?? {}
  globalThis.window.__TAURI_INTERNALS__.metadata = {
    currentWindow: { label },
    currentWebview: { label },
  }
}

describe("WebviewWindow", () => {
  beforeEach(() => {
    Mocks.clearMocks()
    installMetadata("main")
  })
  afterEach(() => Mocks.clearMocks())

  it("make + label round-trips the constructor argument", () => {
    const w = WebviewWindow.make("settings", undefined)
    expect(WebviewWindow.label(w)).toBe("settings")
  })

  it("getCurrent uses the metadata-installed label", () => {
    const w = WebviewWindow.getCurrent()
    expect(WebviewWindow.label(w)).toBe("main")
  })

  it("getAll resolves to an array of WebviewWindow handles", async () => {
    // upstream getAllWebviewWindows hits plugin:window|get_all_windows.
    Mocks.mockIPC(async () => [{ windowLabel: "main", label: "main" }])
    const all = await WebviewWindow.getAll()
    expect(Array.isArray(all)).toBe(true)
    expect(all.length).toBe(1)
  })

  it("getByLabel returns null when no match exists", async () => {
    Mocks.mockIPC(async () => [])
    const found = await WebviewWindow.getByLabel("nope")
    expect(found === null || typeof found === "undefined").toBe(true)
  })

  // Note: WebviewWindow.asWindow / asWebview are %identity casts and
  // are erased at compile time (no runtime function exists). Their
  // behavior is verified by `tests/webview_window_signature.res` —
  // the cast types still type-check after every API change. Runtime
  // proof comes implicitly from `Window.label(handle)` / `Webview.label(handle)`
  // working on a WebviewWindow value, which is what the next
  // assertions exercise.

  it("a WebviewWindow value behaves like a Window for Window.label", () => {
    const w = WebviewWindow.make("alpha", undefined)
    // %identity-cast result is the same JS object — Window.label
    // (which compiles to `prim.label`) reads the upstream class field.
    expect(Window.label(w)).toBe("alpha")
  })

  it("a WebviewWindow value behaves like a Webview for Webview.label", () => {
    const w = WebviewWindow.make("beta", undefined)
    expect(Webview.label(w)).toBe("beta")
  })

  it("setTitle dispatches through IPC", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      return null
    })
    const w = WebviewWindow.make("title-test", undefined)
    await WebviewWindow.setTitle(w, "Hello")
    expect(calls.some((c) => c.includes("set_title"))).toBe(true)
  })

  it("close dispatches through IPC", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      return null
    })
    const w = WebviewWindow.make("close-test", undefined)
    await WebviewWindow.close(w)
    expect(calls.some((c) => c.includes("close"))).toBe(true)
  })

  it("setBackgroundColor accepts Nullable.null and a color value", async () => {
    // Each WebviewWindow.setBackgroundColor dispatches *two* IPC
    // commands upstream (`plugin:window|set_background_color` then
    // `plugin:webview|set_webview_background_color`). The constructor
    // also calls plugin:webview|create_webview_window. So 1 + 2 + 2 = 5.
    let bgCalls = 0
    Mocks.mockIPC(async (cmd) => {
      if (cmd.includes("background_color")) bgCalls += 1
      return null
    })
    const w = WebviewWindow.make("bg-test", undefined)
    await WebviewWindow.setBackgroundColor(w, null)
    await WebviewWindow.setBackgroundColor(w, { r: 0, g: 0, b: 0, a: 255 })
    expect(bgCalls).toBe(4) // 2 per setBackgroundColor call
  })
})
