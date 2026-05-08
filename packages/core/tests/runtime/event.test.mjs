import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

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
    _deliver: (eventName, id, payload) =>
      callbacks.get(id)?.({ event: eventName, id, payload }),
    _captured: callbacks,
  }
}
const clear = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

const Ok = (v) => ({ TAG: "Ok", _0: v })
const Err = (m) => ({ TAG: "Error", _0: m })

describe("Event", () => {
  beforeEach(installInternals)
  afterEach(clear)

  it("listen captures a callback via transformCallback and forwards decoded events", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("file-changed", (raw) =>
      typeof raw === "string" ? Ok(raw) : Err("expected string"),
    )

    const received = []
    const unlisten = await Event.listen(ch, (evt) => received.push(evt))

    const captured = globalThis.window.__TAURI_INTERNALS__._captured
    // The most recently captured callback id is what listen used.
    const ids = Array.from(captured.keys())
    expect(ids.length).toBeGreaterThan(0)
    const id = ids[ids.length - 1]

    globalThis.window.__TAURI_INTERNALS__._deliver("file-changed", id, "/tmp/x")
    expect(received).toHaveLength(1)
    expect(received[0].event).toBe("file-changed")
    expect(received[0].payload).toBe("/tmp/x")
    expect(typeof unlisten).toBe("function")
  })

  it("listen drops messages whose decode fails", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("topic", (raw) =>
      typeof raw === "string" ? Ok(raw) : Err("not a string"),
    )

    const received = []
    await Event.listen(ch, (evt) => received.push(evt))

    const captured = globalThis.window.__TAURI_INTERNALS__._captured
    const ids = Array.from(captured.keys())
    const id = ids[ids.length - 1]

    globalThis.window.__TAURI_INTERNALS__._deliver("topic", id, 42)
    globalThis.window.__TAURI_INTERNALS__._deliver("topic", id, "ok")

    expect(received.map((e) => e.payload)).toEqual(["ok"])
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
