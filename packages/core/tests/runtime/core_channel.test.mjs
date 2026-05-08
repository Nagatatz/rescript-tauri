import { afterEach, beforeEach, describe, expect, it } from "vitest"

// Tauri's Channel class auto-assigns an id by calling
// __TAURI_INTERNALS__.transformCallback(innerCallback) and stores the
// returned number on `this.id`. Each rust-side `channel.send(msg)`
// invokes the registered inner callback with `{index, message}` (or
// `{index, end: true}` for end-of-stream).
//
// To exercise our wrapper end-to-end inside happy-dom we mock
// transformCallback to: (a) return a fresh numeric id, and
// (b) capture the inner callback so the test can drive messages
// through it from the outside.

const installInternals = () => {
  globalThis.window = globalThis.window ?? {}
  let nextId = 100
  const callbacks = new Map()
  globalThis.window.__TAURI_INTERNALS__ = {
    transformCallback: (cb) => {
      const id = nextId++
      callbacks.set(id, cb)
      return id
    },
    // helper used by tests to drive a message through the captured callback
    _deliver: (id, message, index = 0) => {
      const cb = callbacks.get(id)
      if (cb) cb({ index, message })
    },
  }
}

const clear = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

const Ok = (v) => ({ TAG: "Ok", _0: v })
const Err = (msg) => ({ TAG: "Error", _0: msg })

describe("Core.Channel", () => {
  beforeEach(installInternals)
  afterEach(clear)

  it("make + id returns the channel's auto-assigned numeric id (>= 100)", async () => {
    const { Channel } = await import("../../src/Core.res.mjs")
    const ch = Channel.make((raw) => (typeof raw === "string" ? Ok(raw) : Err("expected string")))
    const id = Channel.id(ch)
    expect(typeof id).toBe("number")
    expect(id).toBeGreaterThanOrEqual(100)
  })

  it("onMessage forwards decoded messages as Ok(msg)", async () => {
    const { Channel } = await import("../../src/Core.res.mjs")
    const ch = Channel.make((raw) =>
      typeof raw === "string" ? Ok(raw.toUpperCase()) : Err("expected string"),
    )

    const received = []
    Channel.onMessage(ch, (result) => received.push(result))

    const id = Channel.id(ch)
    globalThis.window.__TAURI_INTERNALS__._deliver(id, "hello", 0)
    globalThis.window.__TAURI_INTERNALS__._deliver(id, "world", 1)

    expect(received).toHaveLength(2)
    expect(received[0]).toEqual(Ok("HELLO"))
    expect(received[1]).toEqual(Ok("WORLD"))
  })

  it("onMessage surfaces decode failures as Error(msg)", async () => {
    const { Channel } = await import("../../src/Core.res.mjs")
    const ch = Channel.make((raw) => (typeof raw === "string" ? Ok(raw) : Err("not a string")))

    const received = []
    Channel.onMessage(ch, (result) => received.push(result))

    const id = Channel.id(ch)
    globalThis.window.__TAURI_INTERNALS__._deliver(id, 42, 0)
    globalThis.window.__TAURI_INTERNALS__._deliver(id, "ok", 1)

    expect(received).toHaveLength(2)
    expect(received[0]).toEqual(Err("not a string"))
    expect(received[1]).toEqual(Ok("ok"))
  })
})
