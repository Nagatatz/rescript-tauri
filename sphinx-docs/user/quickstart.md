# Quick Start

```{warning}
Target API. The samples below reflect the design defined in [RFC-0001](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0001-core-api-design.md) and [`docs/functional-design.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md) §2. Implementation is in progress in Phase 1.
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

let unlisten = await fileChanged->Event.listen(evt => Console.log(evt.payload))
// ... later
unlisten()
```

## What's next?

- [Configuration](configuration.md) — `rescript.json`, peerDeps, compatibility
- [Changelog](changelog.md) — Release notes
- [`docs/functional-design.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md) — Per-module API specifications (Japanese)
- [Layer 3 (Schema integration)](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0001-core-api-design.md) — `Command.fromSchemas` helper, planned for `@rescript-tauri/schema` (Phase 2)
