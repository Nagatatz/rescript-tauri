# ipc-typed-with-schema

Tauri 2.x desktop example demonstrating the Layer 3 IPC stack from
[`@rescript-tauri/schema`](../../packages/schema). Read alongside
[`examples/ipc-typed/`](../ipc-typed/) to see how
`Schema.fromSchemas` collapses the manual encoder/decoder pair into
a single schema declaration.

## Status

Phase 2 — added 2026-05-09 (steering 039). The frontend ReScript
piece builds today (`pnpm --filter ipc-typed-with-schema build`);
the Rust side requires the Tauri toolchain (`pnpm tauri dev` from
this directory) and is fully exercised once the CI matrix gets an
`ipc-typed-with-schema` job (scheduled for the next CI-extension
steering).

## Run locally

```bash
cd examples/ipc-typed-with-schema
pnpm install
pnpm tauri dev
```

## What it does

The window has four sections, each driving one Layer 3 feature.

| Button id | Schema feature | Rust command | Notes |
|---|---|---|---|
| `run-greet` | `Schema.fromSchemas` | `greet(name) -> String` | `{name: string} -> string`. |
| `run-add` | `Schema.fromSchemas` | `add(a, b) -> i32` | `{a: int, b: int} -> int`. |
| `run-summarize` | `Schema.fromSchemas` | `summarize(title, items) -> Summary` | record round-trip via `S.object` + `S.array`. |
| `run-count-to` | `Schema.channelFromSchema` + `Core.Command.make` | `count_to(channel, target) -> ()` | Channel<int> decoded with `S.int`. |

`Schema.eventFromSchema` and `Schema.toDecoder` are referenced at
the type level (`appStatusEvent`, `_stringDecoder`) so all four
public Schema entry points appear in the demo source.

## Comparison with `examples/ipc-typed/`

`examples/ipc-typed/` declares the same `greet` and `add` commands
the long way:

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

The schema-based version is one declaration:

```rescript
let greet = Schema.fromSchemas(
  ~name="greet",
  ~args=Schema.S.object(s => {name: s.field("name", Schema.S.string)}),
  ~result=Schema.S.string,
)
```

For the channel command the encoder still has to be hand-written —
`Core.Channel.t` is opaque to schemas, so the channel handle is
shipped through `Obj.magic` exactly as in `examples/streaming-ipc/`.
The receive side, however, is fully schema-decoded:

```rescript
let countChannel = Schema.channelFromSchema(~message=Schema.S.int)
```

## Files of interest

| File | Role |
|---|---|
| `src/App.res` | ReScript entry, schema declarations, command + channel wiring. |
| `src/main.mjs` | Plain-JS entry that imports the compiled ReScript. |
| `index.html` | HTML host page with the four sections. |
| `src-tauri/src/main.rs` | Rust handlers for `greet` / `add` / `summarize` / `count_to`. |
| `src-tauri/Cargo.toml` | Standard tauri 2.x deps; no extra plugins. |
| `src-tauri/tauri.conf.json` | App config (productName, identifier, window). |
| `src-tauri/capabilities/default.json` | Allows `core:default`. |

## Compatibility

- `@rescript-tauri/schema` (workspace)
- `rescript-schema ^9.0.0`
- ReScript: `>=12.0.0` with `@rescript/core >=1.6.0`.

## Notes

- The `S` DSL is reached through `Schema.S` (re-export of
  `RescriptSchema.S`) so a caller only imports
  `@rescript-tauri/schema` and not `rescript-schema` directly when
  writing schemas inline; both forms work.
- rescript-schema 9.x exposes `field` as a method on the object
  builder (`s.field("name", S.string)`), not a top-level function.
- Icons under `src-tauri/icons/` are reused from
  `examples/hello-world/`.
- `frontendDist` points at `../` so Tauri serves `index.html`
  directly without a bundler.
