import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// Tauri's event API uses two layers underneath:
//   - listen() / once(): register a callback through transformCallback
//     and inform Rust via invoke("plugin:event|listen", ...).
//   - emit() / emitTo(): call invoke("plugin:event|emit", ...).
//
// We mock both so the wrapper can be exercised end-to-end:
//  - transformCallback captures the inner callback so a test can
//    deliver `{event, id, payload}` payloads from the outside.
//  - invoke is a vi.fn so we can assert it was called.

const installInternals = () => {
  globalThis.window = globalThis.window ?? {}
  let nextId = 1000
  const callbacks = new Map()
  globalThis.window.__TAURI_INTERNALS__ = {
    transformCallback: (cb) => {
      const id = nextId++
      callbacks.set(id, cb)
      return id
    },
    invoke: vi.fn(async () => undefined),
    _deliver: (eventName, id, payload) => callbacks.get(id)?.({ event: eventName, id, payload }),
    _captured: callbacks,
  }
  // `Event.once` auto-unsubscribes after the first delivery by calling
  // window.__TAURI_EVENT_PLUGIN_INTERNALS__.unregisterListener. Stub it
  // so the auto-unsubscribe path doesn't blow up the test runner.
  globalThis.window.__TAURI_EVENT_PLUGIN_INTERNALS__ = {
    unregisterListener: vi.fn(),
  }
}
const clear = () => {
  if (globalThis.window) {
    delete globalThis.window.__TAURI_INTERNALS__
    delete globalThis.window.__TAURI_EVENT_PLUGIN_INTERNALS__
  }
}

const Ok = (v) => ({ TAG: "Ok", _0: v })
const Err = (m) => ({ TAG: "Error", _0: m })

const lastCapturedId = () => {
  const ids = Array.from(globalThis.window.__TAURI_INTERNALS__._captured.keys())
  expect(ids.length).toBeGreaterThan(0)
  return ids[ids.length - 1]
}

describe("Event", () => {
  beforeEach(installInternals)
  afterEach(clear)

  it("listen forwards a successfully decoded event as Ok", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("file-changed", (raw) =>
      typeof raw === "string" ? Ok(raw) : Err("expected string"),
    )

    const received = []
    const unlisten = await Event.listen(ch, (result) => received.push(result))

    const id = lastCapturedId()
    globalThis.window.__TAURI_INTERNALS__._deliver("file-changed", id, "/tmp/x")
    expect(received).toHaveLength(1)
    expect(received[0].TAG).toBe("Ok")
    expect(received[0]._0.event).toBe("file-changed")
    expect(received[0]._0.payload).toBe("/tmp/x")
    expect(typeof unlisten).toBe("function")
  })

  it("listen surfaces decode failures as Error(msg)", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("topic", (raw) =>
      typeof raw === "string" ? Ok(raw) : Err("not a string"),
    )

    const received = []
    await Event.listen(ch, (result) => received.push(result))

    const id = lastCapturedId()
    globalThis.window.__TAURI_INTERNALS__._deliver("topic", id, 42)
    globalThis.window.__TAURI_INTERNALS__._deliver("topic", id, "ok")

    expect(received).toHaveLength(2)
    expect(received[0].TAG).toBe("Error")
    expect(received[0]._0).toBe("not a string")
    expect(received[1].TAG).toBe("Ok")
    expect(received[1]._0.payload).toBe("ok")
  })

  it("once delivers Error(msg) when the single emission fails to decode", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("ping", (raw) =>
      typeof raw === "string" ? Ok(raw) : Err("expected string"),
    )

    const received = []
    await Event.once(ch, (result) => received.push(result))

    const id = lastCapturedId()
    globalThis.window.__TAURI_INTERNALS__._deliver("ping", id, 99)

    expect(received).toHaveLength(1)
    expect(received[0].TAG).toBe("Error")
    expect(received[0]._0).toBe("expected string")
  })

  it("emit calls __TAURI_INTERNALS__.invoke at least once", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("ping", (_) => Ok())
    await Event.emit(ch, { hello: "world" })

    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    expect(calls.length).toBeGreaterThan(0)
  })

  it("emitTo calls __TAURI_INTERNALS__.invoke at least once", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("ping", (_) => Ok())
    await Event.emitTo(ch, "App", { hello: "world" })
    await Event.emitTo(ch, { TAG: "Window", _0: "main" }, { hello: "world" })

    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    expect(calls.length).toBeGreaterThanOrEqual(2)
  })

  it("listen with ~target invokes plugin:event|listen with the target option", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("scoped", (raw) =>
      typeof raw === "string" ? Ok(raw) : Err("expected string"),
    )
    await Event.listen(ch, () => {}, { TAG: "Window", _0: "main" })

    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    const listenCall = calls.find(([name]) => name === "plugin:event|listen")
    expect(listenCall).toBeDefined()
    expect(listenCall[1].target).toEqual({ kind: "Window", label: "main" })
  })

  it("Event.TauriEvent values match upstream string literals", async () => {
    const Event = await import("../../src/Event.res.mjs")
    expect(Event.TauriEvent.windowResized).toBe("tauri://resize")
    expect(Event.TauriEvent.dragDrop).toBe("tauri://drag-drop")
    expect(Event.TauriEvent.windowCloseRequested).toBe("tauri://close-requested")
  })

  it("Event.TauriEvent exposes all 16 predefined event names", async () => {
    const Event = await import("../../src/Event.res.mjs")
    // Cover every TauriEvent constant so each line in the enum block
    // shows up as covered.
    expect(Event.TauriEvent.windowResized).toBe("tauri://resize")
    expect(Event.TauriEvent.windowMoved).toBe("tauri://move")
    expect(Event.TauriEvent.windowCloseRequested).toBe("tauri://close-requested")
    expect(Event.TauriEvent.windowDestroyed).toBe("tauri://destroyed")
    expect(Event.TauriEvent.windowFocus).toBe("tauri://focus")
    expect(Event.TauriEvent.windowBlur).toBe("tauri://blur")
    expect(Event.TauriEvent.windowScaleFactorChanged).toBe("tauri://scale-change")
    expect(Event.TauriEvent.windowThemeChanged).toBe("tauri://theme-changed")
    expect(Event.TauriEvent.windowCreated).toBe("tauri://window-created")
    expect(Event.TauriEvent.windowSuspended).toBe("tauri://suspended")
    expect(Event.TauriEvent.windowResumed).toBe("tauri://resumed")
    expect(Event.TauriEvent.webviewCreated).toBe("tauri://webview-created")
    expect(Event.TauriEvent.dragEnter).toBe("tauri://drag-enter")
    expect(Event.TauriEvent.dragOver).toBe("tauri://drag-over")
    expect(Event.TauriEvent.dragDrop).toBe("tauri://drag-drop")
    expect(Event.TauriEvent.dragLeave).toBe("tauri://drag-leave")
  })

  it("once with ~target invokes plugin:event|listen with the target option", async () => {
    // Upstream's `once` is built on top of `listen` (it wraps the
    // handler in an auto-unsubscribe and forwards options), so the
    // IPC dispatch goes to plugin:event|listen, not plugin:event|once.
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("once-scoped", (raw) =>
      typeof raw === "string" ? Ok(raw) : Err("expected string"),
    )
    await Event.once(ch, () => {}, { TAG: "Webview", _0: "secondary" })

    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    const listenCall = calls.find(
      ([name, args]) => name === "plugin:event|listen" && args.event === "once-scoped",
    )
    expect(listenCall).toBeDefined()
    expect(listenCall[1].target).toEqual({ kind: "Webview", label: "secondary" })
  })

  it("emitTo accepts every eventTarget variant", async () => {
    // _targetToJs covers Any / AnyLabel / App / Window / Webview /
    // WebviewWindow. The first two test cases above already cover
    // Any (via no ~target = none) and Window. This run hits the
    // remaining variants explicitly.
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("ping", (_) => Ok())

    await Event.emitTo(ch, "Any", { hello: "world" })
    await Event.emitTo(ch, { TAG: "AnyLabel", _0: "label" }, { hello: "world" })
    await Event.emitTo(ch, "App", { hello: "world" })
    await Event.emitTo(ch, { TAG: "Window", _0: "main" }, { hello: "world" })
    await Event.emitTo(ch, { TAG: "Webview", _0: "wv" }, { hello: "world" })
    await Event.emitTo(ch, { TAG: "WebviewWindow", _0: "ww" }, { hello: "world" })

    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    expect(calls.length).toBeGreaterThanOrEqual(6)
  })
})
