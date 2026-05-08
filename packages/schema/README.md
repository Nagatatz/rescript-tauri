# @rescript-tauri/schema

[`rescript-schema`](https://github.com/DZakh/rescript-schema) integration for
[`@rescript-tauri/core`](../core). Implements **Layer 3** of the
[3-layer IPC stack](../../docs/architecture.md#3-ipc-3層構造) defined in
RFC-0001: declare a `Core.Command.t<'args, 'result>` from a single
`S.t<'args>` + `S.t<'result>` pair instead of writing the encoder and
decoder by hand.

## Status

Phase 2 — under active development. Awaiting first npm publish
(`schema-v0.1.0`).

## Install (planned)

```bash
pnpm add @rescript-tauri/schema @rescript-tauri/core @tauri-apps/api rescript-schema
```

Add to `rescript.json`:

```json
{
  "dependencies": ["@rescript/core", "@rescript-tauri/core", "@rescript-tauri/schema", "rescript-schema"]
}
```

## Quick example

```rescript
module Core = RescriptTauriCore.Core
module Schema = RescriptTauriSchema.Schema
module S = RescriptSchema.S

let greet = Schema.fromSchemas(
  ~name="greet",
  ~args=S.object(s => {name: s->S.field("name", S.string)}),
  ~result=S.string,
)

switch await greet->Core.Command.invoke({name: "ReScript"}) {
| Ok(message) => Console.log(message)
| Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
| Error(RustError(json)) => Console.error2("rust error:", json)
}
```

## Compatibility matrix

| `@rescript-tauri/schema` | `@rescript-tauri/core` | `rescript-schema` | `@tauri-apps/api` |
|---|---|---|---|
| `^0.1.0` | `^0.1.0` | `^9.0.0` | `^2.0.0` |

## Public API

| Symbol | Purpose |
|---|---|
| `Schema.toDecoder` | `S.t<'value>` → `Core.decoder<'value>` |
| `Schema.fromSchemas` | Builds a typed `Core.Command.t` from arg + result schemas |
| `Schema.channelFromSchema` | Builds a typed `Core.Channel.t` from a message schema |
| `Schema.eventFromSchema` | Builds a typed `Event.t` from a payload schema |

See `src/Schema.resi` for full doc comments and the linked Tauri /
rescript-schema upstream documentation.

## References

- [RFC-0002 Schema Integration](../../docs/ideas/RFC-0002-schema-integration.md)
- [`@rescript-tauri/core` README](../core/README.md)
- [rescript-schema docs](https://github.com/DZakh/rescript-schema)
