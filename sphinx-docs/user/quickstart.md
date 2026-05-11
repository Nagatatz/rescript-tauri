# Quick Start

```{note}
All `@rescript-tauri/core` modules are feature-complete in `main`.
The samples below reflect the actual `.resi` signatures shipped on
`main`. The package is awaiting its first npm publish (`v0.1.0`);
until then, consume `@rescript-tauri/core` via the source repository
or a workspace link.
```

## Prerequisites

- Completed [Installation](installation.md)
- A Tauri 2.x project with at least one `#[tauri::command]` defined on the Rust side

## Layer 1 — Raw `invoke`

The lowest layer mirrors `@tauri-apps/api/core` 1:1. Use it when you want to start as thin as possible or as an escape hatch from the typed layer.

```rescript
let greeting: string =
  await Tauri.Core.Raw.invoke("greet", ~args={"name": "ReScript"})
```

## Layer 2 — typed `Command`

Layer 2 wraps a single command name with an explicit encoder and decoder, giving you an end-to-end typed `Command.t<'args, 'result>`.

```rescript
module Commands = {
  let greet = Core.Command.make(
    ~name="greet",
    ~encodeArgs=({name}) =>
      JSON.Encode.object([("name", JSON.Encode.string(name))]),
    ~decodeResult=json =>
      switch json->JSON.Decode.string {
      | Some(s) => Ok(s)
      | None => Error("expected string")
      },
  )
}

switch await Commands.greet->Core.Command.invoke({name: "ReScript"}) {
| Ok(message) => Console.log(message)
| Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
| Error(RustError(json)) => Console.error2("rust error:", json)
}
```

`Core.Command.invokeExn` is provided for callers that prefer exception-based control flow.

## Event subscription

`Event.make` declares a typed event handle once; `Event.listen` subscribes and returns an `unlisten` function.

```rescript
let fileChanged = Event.make(
  ~name="file-changed",
  ~decode=json =>
    switch json->JSON.Decode.string {
    | Some(s) => Ok(s)
    | None => Error("expected string")
    },
)

let unlisten = await fileChanged->Event.listen(result =>
  switch result {
  | Ok(evt) => Console.log(evt.payload)
  | Error(_) => () // ignore decode failures
  }
)
// ... later
unlisten()
```

## Window operations

`Window.t` is opaque; instance methods are pipe-first.

```rescript
open Tauri

let win = Window.getCurrent()
await win->Window.setTitle("Hello, ReScript")
await win->Window.maximize

let size = Dpi.LogicalSize.make(~width=1024.0, ~height=768.0)
await win->Window.setSize(size)
```

A complete buttoned demo is in
[`examples/window-management`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/window-management).

## Spawning a `WebviewWindow`

```rescript
open Tauri

let secondary = WebviewWindow.make(
  "secondary",
  ~options={
    url: "/",
    title: "Secondary",
    width: 480.0,
    height: 320.0,
  },
)

// Same instance can be viewed as a Window for window-only methods.
await secondary->WebviewWindow.asWindow->Window.setAlwaysOnTop(true)
```

## Streaming with `Channel`

`Core.Channel` provides one-way Rust-to-frontend streaming. Each
callback receives a `result<'message, string>` so decoder failures
are surfaced explicitly — pattern match on `Ok(...)` / `Error(_)` to
choose how to handle them.

```rescript
let counter = Core.Channel.make(~decode=json =>
  switch json->JSON.Decode.float {
  | Some(f) => Ok(Float.toInt(f))
  | None => Error("expected number")
  }
)

counter->Core.Channel.onMessage(result =>
  switch result {
  | Ok(n) => Console.log2("recv", n)
  | Error(_) => () // ignore decode failures
  }
)

let countTo = Core.Command.make(
  ~name="count_to",
  ~encodeArgs=({channel, target}) =>
    JSON.Encode.object(
      Dict.fromArray([
        ("channel", Obj.magic(channel)),
        ("target", JSON.Encode.float(Int.toFloat(target))),
      ]),
    ),
  ~decodeResult=_ => Ok(),
)

let _ = await countTo->Core.Command.invoke({channel: counter, target: 10})
```

A complete demo (with the matching Rust handler) is in
[`examples/streaming-ipc`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/streaming-ipc).

## Path / App utilities

```rescript
let configDir = await Path.appConfigDir()
let appName = await App.getName()
Console.log3("ready:", appName, configDir)
```

`Path` is intentionally **not** re-exported by `Tauri`, so reach for
it explicitly (`Path.appConfigDir()`) instead of `open Tauri`'ing it
into scope alongside Window / Event.

## What's next?

- [Configuration](configuration.md) — `rescript.json`, peerDeps, compatibility
- [Changelog](changelog.md) — Release notes
- [`docs/functional-design.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md) — Per-module API specifications (Japanese)
- [Layer 3 (Schema integration)](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0001-core-api-design.md) — `Command.fromSchemas` helper, provided by `@rescript-tauri/schema`
