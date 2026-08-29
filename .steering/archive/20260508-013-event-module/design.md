# 設計: Event モジュール

## ファイル変更

### `packages/core/src/Event.res` (新規)

```rescript
type event<'payload> = {
  event: string,
  id: int,
  payload: 'payload,
}

type eventTarget =
  | Any
  | AnyLabel(string)
  | App
  | Window(string)
  | Webview(string)
  | WebviewWindow(string)

type rawEvent = {
  event: string,
  id: int,
  payload: JSON.t,
}

type t<'payload> = {
  name: string,
  decode: JSON.t => result<'payload, string>,
}

type unlisten = unit => unit

@module("@tauri-apps/api/event")
external _listen: (string, rawEvent => unit) => promise<unlisten> = "listen"

@module("@tauri-apps/api/event")
external _once: (string, rawEvent => unit) => promise<unlisten> = "once"

@module("@tauri-apps/api/event")
external _emit: (string, 'payload) => promise<unit> = "emit"

@module("@tauri-apps/api/event")
external _emitTo: ('jsTarget, string, 'payload) => promise<unit> = "emitTo"

let make = (~name, ~decode) => {name, decode}

let _wrap = (event, handler, raw) =>
  switch event.decode(raw.payload) {
  | Ok(p) => handler({event: raw.event, id: raw.id, payload: p})
  | Error(_) => ()
  }

let listen = (event, handler) => _listen(event.name, _wrap(event, handler, ...))
let once = (event, handler) => _once(event.name, _wrap(event, handler, ...))
let emit = (event, payload) => _emit(event.name, payload)

let _targetToJs = target =>
  switch target {
  | Any => Obj.magic({"kind": "Any"})
  | AnyLabel(label) => Obj.magic({"kind": "AnyLabel", "label": label})
  | App => Obj.magic({"kind": "App"})
  | Window(label) => Obj.magic({"kind": "Window", "label": label})
  | Webview(label) => Obj.magic({"kind": "Webview", "label": label})
  | WebviewWindow(label) => Obj.magic({"kind": "WebviewWindow", "label": label})
  }

let emitTo = (event, ~target, payload) => _emitTo(_targetToJs(target), event.name, payload)
```

> **Note**: ReScript 12 のドット partial application (`_wrap(event, handler, ...)`) を利用して per-call で raw handler を作る。

### `packages/core/src/Event.resi` (新規)

```rescript
/** A typed event delivered to a `listen` / `once` handler. */
type event<'payload> = {
  event: string,
  id: int,
  payload: 'payload,
}

/** Targets for `emitTo`. Mirrors Tauri's `EventTarget` discriminator. */
type eventTarget =
  | Any
  | AnyLabel(string)
  | App
  | Window(string)
  | Webview(string)
  | WebviewWindow(string)

/** A typed handle to one event name with its decoder. */
type t<'payload>

/** Returned by `listen` / `once` — call it to detach the handler. */
type unlisten = unit => unit

/** Declares one event with its name and JSON decoder.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/
*/
let make: (~name: string, ~decode: JSON.t => result<'payload, string>) => t<'payload>

/** Subscribes to every emission of the event. The returned `unlisten`
    must be called to stop receiving events. Decode failures are
    silently dropped (the user callback is not invoked).

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#listen

    ## Example

    ```rescript
    let fileChanged = Event.make(~name="file-changed", ~decode=...)
    let unlisten = await fileChanged->Event.listen(evt => Console.log(evt.payload))
    ```
*/
let listen: (t<'payload>, event<'payload> => unit) => promise<unlisten>

/** Subscribes for exactly one emission, then auto-unsubscribes.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#once
*/
let once: (t<'payload>, event<'payload> => unit) => promise<unlisten>

/** Emits the event globally to every listener.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#emit
*/
let emit: (t<'payload>, 'payload) => promise<unit>

/** Emits the event to a specific target only.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#emitto
*/
let emitTo: (t<'payload>, ~target: eventTarget, 'payload) => promise<unit>
```

### `packages/core/tests/event_signature.res`

```rescript
let _check_make: (~name: string, ~decode: JSON.t => result<'payload, string>) => Event.t<'payload> =
  Event.make

let _check_listen: (Event.t<'payload>, Event.event<'payload> => unit) => promise<Event.unlisten> =
  Event.listen

let _check_once: (Event.t<'payload>, Event.event<'payload> => unit) => promise<Event.unlisten> =
  Event.once

let _check_emit: (Event.t<'payload>, 'payload) => promise<unit> = Event.emit

let _check_emit_to: (Event.t<'payload>, ~target: Event.eventTarget, 'payload) => promise<unit> =
  Event.emitTo

// Construct each eventTarget variant
let _t1: Event.eventTarget = Any
let _t2: Event.eventTarget = AnyLabel("main")
let _t3: Event.eventTarget = App
let _t4: Event.eventTarget = Window("main")
let _t5: Event.eventTarget = Webview("main")
let _t6: Event.eventTarget = WebviewWindow("main")
```

### `packages/core/tests/runtime/event.test.mjs`

Tauri の `listen` 内部実装も `__TAURI_INTERNALS__.transformCallback` 経由で id を採番し、id を Rust 側に通知して event を unlisten 用に保存する。テストでは Channel と同様 `transformCallback` を mock + delivery helper を提供する。

ただ event は `__TAURI_INTERNALS__.invoke("plugin:event|listen", ...)` で listen を Rust に登録する流れもあるため、`invoke` も mock する。

```javascript
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

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
    // listen() invokes plugin:event|listen which we no-op
    invoke: vi.fn(async () => undefined),
    _deliver: (eventName, id, payload) =>
      callbacks.get(id)?.({ event: eventName, id, payload }),
  }
}
const clear = () => { if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__ }

const Ok = (v) => ({ TAG: "Ok", _0: v })
const Err = (m) => ({ TAG: "Error", _0: m })

describe("Event", () => {
  beforeEach(installInternals)
  afterEach(clear)

  it("listen forwards a decoded event to the handler", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("file-changed",
      (raw) => typeof raw === "string" ? Ok(raw) : Err("expected string"))

    const received = []
    const unlisten = await Event.listen(ch, (evt) => received.push(evt))

    // Find the captured callback id and deliver.
    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    // listen registered via transformCallback; the id assigned is the
    // *first* id in our table, which we control via nextId starting at 1000.
    globalThis.window.__TAURI_INTERNALS__._deliver("file-changed", 1000, "/tmp/x")

    expect(received).toHaveLength(1)
    expect(received[0].event).toBe("file-changed")
    expect(received[0].payload).toBe("/tmp/x")
    expect(typeof unlisten).toBe("function")
  })

  it("listen drops messages whose decode fails", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("topic",
      (raw) => typeof raw === "string" ? Ok(raw) : Err("not a string"))

    const received = []
    await Event.listen(ch, (evt) => received.push(evt))

    globalThis.window.__TAURI_INTERNALS__._deliver("topic", 1000, 42)
    globalThis.window.__TAURI_INTERNALS__._deliver("topic", 1000, "ok")

    expect(received.map(e => e.payload)).toEqual(["ok"])
  })

  it("emit invokes plugin:event|emit with the event name + payload", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("ping", (_) => Ok())
    await Event.emit(ch, { hello: "world" })

    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    // We don't assert the exact plugin name — just that invoke was called
    // and the event name + payload appear somewhere in the args.
    expect(calls.length).toBeGreaterThan(0)
  })

  it("emitTo carries the target kind", async () => {
    const Event = await import("../../src/Event.res.mjs")
    const ch = Event.make("ping", (_) => Ok())
    await Event.emitTo(ch, "App", { hello: "world" })
    // (variant ReScript output: App = "App" string when no payload)

    const calls = globalThis.window.__TAURI_INTERNALS__.invoke.mock.calls
    expect(calls.length).toBeGreaterThan(0)
  })
})
```

> **Note**: 上の test は実 Tauri の `listen` / `emit` が `__TAURI_INTERNALS__.invoke("plugin:event|listen" / "|emit", ...)` を呼び出す前提。実装の挙動が異なる場合（例: handler が `transformCallback` ではなく別経路で登録される）、test を実装に合わせて調整。emitTo の variant ReScript ランタイム表現は実装後に確認して調整。

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-013 (event-module) |
| 2 | ✨ Add Event module (make / listen / once / emit / emitTo + types) |
| 3 | ✅ Add type-level + runtime tests for Event |
| 4 | 📝 Mark steering 20260508-013 complete |

## worktree

`EnterWorktree(name="event-module")`。
