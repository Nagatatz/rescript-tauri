// Webview class wraps the upstream JS class. `getCurrentWebview` reads
// `window.__TAURI_INTERNALS__.metadata.currentWebview.label` directly,
// so we install both `metadata` and a mockIPC handler.
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
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
    const calls = []
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

  it("clearAllBrowsingData (steering 049) dispatches plugin:webview|clear_all_browsing_data", async () => {
    let captured
    Mocks.mockIPC(async (cmd) => {
      captured = cmd
      return null
    })
    const w = Webview.getCurrentWebview()
    await Webview.clearAllBrowsingData(w)
    expect(captured).toContain("clear_all_browsing_data")
  })

  it("getByLabel (steering 049) returns null when the label is absent", async () => {
    Mocks.mockIPC(async () => [])
    const result = await Webview.getByLabel("does-not-exist")
    expect(result === null || typeof result === "undefined").toBe(true)
  })

  it("setFocus / setAutoResize / hide / show / setZoom / close dispatch through IPC", async () => {
    const calls = []
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
    const captures = []
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

// onDragDropEvent's variant translation lives in the ReScript wrapper:
// `Webview.onDragDropEvent(webview, handler)` calls
// `webview.onDragDropEvent(<wrapper>)` upstream, where `<wrapper>` is
// a closure that switches on `payload.type` and projects onto our
// `dragDropEvent` variants. To exercise that closure directly we
// monkey-patch the upstream class method to capture the closure
// ReScript passes in, then invoke it with synthetic payloads.
describe("Webview drag-drop variant interpretation", () => {
  let savedOnDragDropEvent
  let warnSpy

  beforeEach(async () => {
    Mocks.clearMocks()
    globalThis.window = globalThis.window ?? {}
    globalThis.window.__TAURI_INTERNALS__ = globalThis.window.__TAURI_INTERNALS__ ?? {}
    globalThis.window.__TAURI_INTERNALS__.metadata = {
      currentWindow: { label: "main" },
      currentWebview: { label: "main" },
    }

    // Monkey-patch upstream Webview.prototype.onDragDropEvent so
    // ReScript's wrapper is captured rather than registered with
    // Tauri. We restore the original in afterEach.
    const upstream = await import("@tauri-apps/api/webview")
    savedOnDragDropEvent = upstream.Webview.prototype.onDragDropEvent
    warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {})
  })

  afterEach(async () => {
    Mocks.clearMocks()
    if (savedOnDragDropEvent) {
      const upstream = await import("@tauri-apps/api/webview")
      upstream.Webview.prototype.onDragDropEvent = savedOnDragDropEvent
    }
    warnSpy.mockRestore()
  })

  // Capture the ReScript wrapper closure passed into upstream.
  const captureWrapper = async () => {
    const upstream = await import("@tauri-apps/api/webview")
    let captured
    upstream.Webview.prototype.onDragDropEvent = (handler) => {
      captured = handler
      return Promise.resolve(() => {}) // unlisten thunk
    }
    const w = Webview.getCurrentWebview()
    const state = { received: null }
    await Webview.onDragDropEvent(w, (event) => {
      state.received = event
    })
    return { state, wrapper: captured }
  }

  const samplePos = { x: 10, y: 20 }

  it('switches on type:"enter" → Enter({paths, position})', async () => {
    const t = await captureWrapper()
    t.wrapper({
      event: "tauri://drag-enter",
      id: 1,
      payload: { type: "enter", paths: ["/a.txt"], position: samplePos },
    })
    expect(t.state.received.TAG).toBe("Enter")
    expect(t.state.received.paths).toEqual(["/a.txt"])
    expect(t.state.received.position).toEqual(samplePos)
  })

  it('switches on type:"over" → Over({position})', async () => {
    const t = await captureWrapper()
    t.wrapper({
      event: "tauri://drag-over",
      id: 2,
      payload: { type: "over", position: samplePos },
    })
    expect(t.state.received.TAG).toBe("Over")
    expect(t.state.received.position).toEqual(samplePos)
  })

  it('switches on type:"drop" → Drop({paths, position})', async () => {
    const t = await captureWrapper()
    t.wrapper({
      event: "tauri://drag-drop",
      id: 3,
      payload: {
        type: "drop",
        paths: ["/a.txt", "/b.txt"],
        position: samplePos,
      },
    })
    expect(t.state.received.TAG).toBe("Drop")
    expect(t.state.received.paths).toHaveLength(2)
  })

  it('switches on type:"leave" → Leave', async () => {
    const t = await captureWrapper()
    t.wrapper({
      event: "tauri://drag-leave",
      id: 4,
      payload: { type: "leave", position: samplePos },
    })
    // ReScript variants without payload (`Leave`) compile to the
    // string "Leave" in JS.
    expect(t.state.received).toBe("Leave")
  })

  it("logs Console.warn and ignores unknown payload types", async () => {
    const t = await captureWrapper()
    t.wrapper({
      event: "tauri://drag-future",
      id: 5,
      payload: {
        type: "future-unknown-variant",
        position: samplePos,
      },
    })
    // The user handler should NOT be called for unknown kinds.
    expect(t.state.received).toBeNull()
    // Console.warn should be called with the unknown kind.
    expect(warnSpy).toHaveBeenCalledOnce()
    expect(warnSpy).toHaveBeenCalledWith(
      "[rescript-tauri] Unknown drag-drop event type:",
      "future-unknown-variant",
    )
  })
})
