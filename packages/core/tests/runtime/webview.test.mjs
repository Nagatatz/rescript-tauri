// Webview class wraps the upstream JS class. `getCurrentWebview` reads
// `window.__TAURI_INTERNALS__.metadata.currentWebview.label` directly,
// so we install both `metadata` and a mockIPC handler.
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as Mocks from "../../src/Mocks.res.mjs"
import * as Webview from "../../src/Webview.res.mjs"

const installMetadata = () => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = globalThis.window.__TAURI_INTERNALS__ ?? {}
  globalThis.window.__TAURI_INTERNALS__.metadata = {
    currentWindow: { label: "main" },
    currentWebview: { label: "main" },
  }
}

describe("Webview", () => {
  beforeEach(() => {
    Mocks.clearMocks()
    installMetadata()
  })
  afterEach(() => Mocks.clearMocks())

  it("getCurrentWebview returns a handle whose label matches the metadata", () => {
    const w = Webview.getCurrentWebview()
    expect(Webview.label(w)).toBe("main")
  })

  it("getAllWebviews resolves to an array of Webview handles", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toContain("webview")
      return [{ windowLabel: "main", label: "main" }]
    })
    const all = await Webview.getAllWebviews()
    expect(Array.isArray(all)).toBe(true)
    expect(all.length).toBe(1)
    expect(Webview.label(all[0])).toBe("main")
  })

  it("setSize / setPosition / position / size dispatch through IPC", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("position") && !cmd.includes("set_")) {
        return { x: 100, y: 200 }
      }
      if (cmd.includes("size") && !cmd.includes("set_")) {
        return { width: 800, height: 600 }
      }
      return null
    })
    const w = Webview.getCurrentWebview()
    const Dpi = await import("../../src/Dpi.res.mjs")
    const sz = Dpi.Size.fromLogical(Dpi.LogicalSize.make(640, 480))
    const pos = Dpi.Position.fromLogical(Dpi.LogicalPosition.make(50, 75))

    await Webview.setSize(w, sz)
    await Webview.setPosition(w, pos)
    const p = await Webview.position(w)
    const s = await Webview.size(w)

    expect(p).toBeDefined()
    expect(s).toBeDefined()
    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("set_webview_size"),
        expect.stringContaining("set_webview_position"),
        expect.stringContaining("webview_position"),
        expect.stringContaining("webview_size"),
      ]),
    )
  })

  it("setFocus / setAutoResize / hide / show / setZoom / close dispatch through IPC", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      return null
    })
    const w = Webview.getCurrentWebview()
    await Webview.setFocus(w)
    await Webview.setAutoResize(w, true)
    await Webview.hide(w)
    await Webview.show(w)
    await Webview.setZoom(w, 1.25)
    await Webview.close(w)

    expect(calls.length).toBeGreaterThanOrEqual(6)
  })

  it("setBackgroundColor accepts Nullable.null and Nullable.make({...})", async () => {
    let captures = []
    Mocks.mockIPC(async (cmd, args) => {
      captures.push({ cmd, args })
      return null
    })
    const w = Webview.getCurrentWebview()
    await Webview.setBackgroundColor(w, null)
    await Webview.setBackgroundColor(w, { r: 10, g: 20, b: 30, a: 255 })

    expect(captures.length).toBe(2)
  })

  it("reparent forwards the target window/label to plugin:webview|reparent", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    const w = Webview.getCurrentWebview()
    await Webview.reparent(w, "secondary")
    expect(captured.cmd).toContain("reparent")
  })

  it("onDragDropEvent registers a handler and resolves to an unlisten thunk", async () => {
    Mocks.mockIPC(async () => undefined)
    const w = Webview.getCurrentWebview()
    const unlisten = await Webview.onDragDropEvent(w, () => {})
    expect(typeof unlisten).toBe("function")
    // Calling the unlisten doesn't throw even when no events were
    // delivered.
    unlisten()
  })
})
