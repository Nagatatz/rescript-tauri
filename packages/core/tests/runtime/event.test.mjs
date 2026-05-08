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
})
