# 設計: Core.Channel

## ファイル変更

### `packages/core/src/Core.res` (Command の後に追記)

```rescript
module Channel = {
  type internal

  type t<'message> = {
    instance: internal,
    decode: JSON.t => result<'message, string>,
  }

  @module("@tauri-apps/api/core") @new
  external _make: unit => internal = "Channel"

  @set external _setOnmessage: (internal, JSON.t => unit) => unit = "onmessage"

  @get external _getId: internal => int = "id"

  let make = (~decode) => {
    instance: _make(),
    decode,
  }

  let onMessage = (chan, callback) => {
    chan.instance->_setOnmessage(raw =>
      switch chan.decode(raw) {
      | Ok(msg) => callback(msg)
      | Error(_) => ()
      }
    )
  }

  let id = chan => chan.instance->_getId
}
```

### `packages/core/src/Core.resi` (末尾に追記)

```rescript
module Channel: {
  /** A typed handle to a Tauri Channel — a one-way streaming bridge
      from Rust to the frontend.

      Pass the channel as an argument to `Command.invoke`; the Rust
      side calls `channel.send(...)` and each call surfaces here as
      a `callback(msg)` invocation registered with `onMessage`.

      Decoder failures (Rust sends a value that `decode` cannot
      interpret) are silently dropped on purpose: a malformed message
      is an infrastructure issue, and surfacing it through the user
      callback would force every call site to handle a parallel
      error channel.

      See: https://v2.tauri.app/develop/calling-rust/#channels
  */
  type t<'message>

  /** Creates a new Channel handle with its decoder. The underlying
      JS Channel is constructed eagerly so the Rust side can be told
      the channel id immediately. */
  let make: (~decode: JSON.t => result<'message, string>) => t<'message>

  /** Registers (or replaces) the message handler. Tauri delivers each
      Rust-side `channel.send(...)` here. */
  let onMessage: (t<'message>, 'message => unit) => unit

  /** Returns the integer id of the underlying JS Channel, useful
      when correlating with Rust-side logs. */
  let id: t<'message> => int
}
```

### `packages/core/tests/core_channel_signature.res`

```rescript
let _check_make: (~decode: JSON.t => result<'message, string>) => Core.Channel.t<'message> =
  Core.Channel.make

let _check_on_message: (Core.Channel.t<'message>, 'message => unit) => unit =
  Core.Channel.onMessage

let _check_id: Core.Channel.t<'message> => int = Core.Channel.id
```

### `packages/core/tests/runtime/core_channel.test.mjs`

Tauri の `Channel` class は `window.__TAURI_INTERNALS__.transformCallback(callback) → number` を内部で呼んで id を採番する。テスト用には `__TAURI_INTERNALS__.transformCallback` を mock し、また `Channel` クラスが `onmessage` setter で内部 callback を呼ぶ振る舞いを直接シミュレートする。

```javascript
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

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
    // helper used by tests to drive a message
    _deliver: (id, msg) => callbacks.get(id)?.(msg),
  }
}
const clear = () => { if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__ }

describe("Core.Channel", () => {
  beforeEach(installInternals)
  afterEach(clear)

  it("make + id returns the channel's auto-assigned numeric id", async () => {
    const { Channel } = await import("../../src/Core.res.mjs")
    const ch = Channel.make((raw) =>
      typeof raw === "string"
        ? { TAG: "Ok", _0: raw }
        : { TAG: "Error", _0: "expected string" })
    expect(typeof Channel.id(ch)).toBe("number")
    expect(Channel.id(ch)).toBeGreaterThanOrEqual(100)
  })

  it("onMessage forwards decoded messages to the callback", async () => {
    const { Channel } = await import("../../src/Core.res.mjs")
    const ch = Channel.make((raw) =>
      typeof raw === "string"
        ? { TAG: "Ok", _0: raw.toUpperCase() }
        : { TAG: "Error", _0: "expected string" })

    const received = []
    Channel.onMessage(ch, (msg) => received.push(msg))

    globalThis.window.__TAURI_INTERNALS__._deliver(Channel.id(ch), "hello")
    globalThis.window.__TAURI_INTERNALS__._deliver(Channel.id(ch), "world")

    expect(received).toEqual(["HELLO", "WORLD"])
  })

  it("decode failures are silently dropped", async () => {
    const { Channel } = await import("../../src/Core.res.mjs")
    const ch = Channel.make((raw) =>
      typeof raw === "string"
        ? { TAG: "Ok", _0: raw }
        : { TAG: "Error", _0: "not a string" })

    const received = []
    Channel.onMessage(ch, (msg) => received.push(msg))

    globalThis.window.__TAURI_INTERNALS__._deliver(Channel.id(ch), 42)
    globalThis.window.__TAURI_INTERNALS__._deliver(Channel.id(ch), "ok")

    expect(received).toEqual(["ok"])
  })
})
```

> **Note**: 上の test は Tauri の Channel class が `transformCallback` 経由で id を採番する前提。実装の挙動が異なる場合（例: Channel コンストラクタが内部で id を別経路で取得する）、test の mock を実装に合わせて調整する。

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-012 (core-channel) |
| 2 | ✨ Add Core.Channel binding |
| 3 | ✅ Add type-level + runtime tests for Core.Channel |
| 4 | 📝 Mark steering 20260508-012 complete |

## worktree

`EnterWorktree(name="core-channel")`。
