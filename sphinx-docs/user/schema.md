# `@rescript-tauri/schema`

Layer 3 typed IPC for `@rescript-tauri/core`. Declare a Tauri
command from a single
[rescript-schema](https://github.com/DZakh/rescript-schema)
schema pair instead of writing the encoder and decoder by hand.

```{note}
This package is feature-complete in `main`. The first npm publish
(`schema-v0.1.0`) is scheduled alongside the other packages. Until
then, consume `@rescript-tauri/schema` via the source repository or
a workspace link.
```

## Install

```bash
pnpm add @rescript-tauri/schema rescript-schema
```

`@rescript-tauri/schema` declares both `@rescript-tauri/core` and
`rescript-schema` as `peerDependencies`. Add it to your
`rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/schema",
    "rescript-schema"
  ]
}
```

No Rust side change is required — schema is purely a
frontend-side helper.

## Why Layer 3?

Layer 2 (`Core.Command.make`) wraps a single command name with an
explicit encoder and decoder:

```rescript
let greet = Core.Command.make(
  ~name="greet",
  ~encodeArgs=(name: string) => JSON.Encode.object(
    Dict.fromArray([("name", JSON.Encode.string(name))])
  ),
  ~decodeResult=json =>
    switch json->JSON.Decode.string {
    | Some(s) => Ok(s)
    | None => Error("expected string")
    },
)
```

Layer 3 collapses the same command into a single declaration:

```rescript
open RescriptTauriSchema

let greet = Schema.fromSchemas(
  ~name="greet",
  ~args=Schema.S.object(s => {name: s.field("name", Schema.S.string)}),
  ~result=Schema.S.string,
)
```

Both layers return `Core.Command.t<'args, 'result>`, so callers
of `Core.Command.invoke` don't have to care which layer was used
to declare the command.

## Minimal example

```rescript
open RescriptTauriCore.Tauri
open RescriptTauriSchema

type greetArgs = {name: string}

let greet = Schema.fromSchemas(
  ~name="greet",
  ~args=Schema.S.object(s => {name: s.field("name", Schema.S.string)}),
  ~result=Schema.S.string,
)

switch await greet->Core.Command.invoke({name: "ReScript"}) {
| Ok(message) => Console.log(message)
| Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
| Error(RustError(json)) => Console.error2("rust error:", json)
}
```

`S.parseJsonOrThrow` failures are caught inside `toDecoder` and
surfaced as `Error(DecodeError(message))`, matching the existing
`Core.Command.invoke` error variant.

## Public API

| Entry point | Purpose |
|---|---|
| `Schema.fromSchemas` | Typed command from a `S.t<'args>` + `S.t<'result>` pair |
| `Schema.channelFromSchema` | Schema-decoded `Core.Channel.t<'message>` |
| `Schema.eventFromSchema` | Schema-decoded `Event.t<'payload>` |
| `Schema.toDecoder` | Lower-level helper that returns the `Core.decoder<_>` used internally — useful when you want to plug a schema decoder into a hand-rolled `Core.Command.make` |

`Schema.S` re-exports `RescriptSchema.S`, so a caller only
imports `@rescript-tauri/schema` and reaches the schema DSL
through one path.

### Channel example

The receive side of a Tauri `Channel<u32>` becomes a one-liner:

```rescript
let countChannel = Schema.channelFromSchema(~message=Schema.S.int)

Core.Channel.onMessage(countChannel, result =>
  switch result {
  | Ok(n) => Console.log2("recv", n)
  | Error(_msg) => () // ignore decode failures
  }
)
```

The command that opens the channel still needs a hand-written
encoder because `Core.Channel.t` is opaque to schemas — see
[`examples/ipc-typed-with-schema`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/ipc-typed-with-schema)
for the full pattern.

## rescript-schema DSL pitfalls

### `field` is a method, not a top-level function

rescript-schema 9.x exposes the field builder as a method on the
`Object.s` argument. Use the dot syntax:

```rescript
// ✅
let s1 = Schema.S.object(s => {
  name: s.field("name", Schema.S.string),
})

// ❌ compile error: `field` not in `Schema.S`
let s2 = Schema.S.object(s => {
  name: s->Schema.S.field("name", Schema.S.string),
})
```

### Tauri command argument flattening

Tauri 2.x's `tauri::command` flattens single-record arguments into
the args object's top-level keys. A Rust signature like

```rust
#[tauri::command]
fn summarize(title: &str, items: Vec<String>) -> Summary { /* … */ }
```

expects an args JSON of `{"title": ..., "items": ...}`, not a
nested `{"args": {"title": ...}}`. Author your `S.object` schema
against the flat shape.

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `rescript-schema` | `^9.0.0` (peer) |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |

`rescript-struct` is **not** supported. The upstream package was
deprecated in favor of `rescript-schema` (confirmed 2026-05-09 —
recorded in [RFC-0002 §2.1](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0002-schema-integration.md)).

## See also

- Live demo:
  [`examples/ipc-typed-with-schema`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/ipc-typed-with-schema)
  — pairs against `examples/ipc-typed/` to show the same commands
  in both Layer 2 and Layer 3 form.
- Source:
  [`packages/schema`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/schema)
- RFC-0002:
  [Schema integration design](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0002-schema-integration.md)
