# `@rescript-tauri/plugin-dialog`

ReScript bindings for the [Tauri 2.x native dialog
plugin](https://v2.tauri.app/plugin/dialog/) — open / save /
message / ask / confirm.

```{note}
{{ phase_2_note }}
```

## Install

```bash
pnpm add @rescript-tauri/plugin-dialog @tauri-apps/plugin-dialog
```

`@rescript-tauri/plugin-dialog` declares both
`@rescript-tauri/core` and `@tauri-apps/plugin-dialog` as
`peerDependencies`.

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-dialog"
  ]
}
```

Rust side:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-dialog = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

## Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "dialog:default"
  ]
}
```

`dialog:default` covers all dialog APIs.

## Minimal example

```rescript
open RescriptTauriPluginDialog

let pickedPath = await PluginDialog.openFile(~options={
  title: "Pick a file",
  filters: [{name: "Text", extensions: ["txt", "md"]}],
})
switch pickedPath->Nullable.toOption {
| Some(path) => Console.log("picked: " ++ path)
| None => Console.log("cancelled")
}
```

`openFile` returns `promise<Nullable.t<string>>`; `Nullable.null`
is the cancellation signal.

## Public API

The 8 public functions cover the upstream surface:

| Function | Returns | Notes |
|---|---|---|
| `openFile` | `Nullable.t<string>` | Single-file picker |
| `openFiles` | `Nullable.t<array<string>>` | Multi-file picker |
| `openDirectory` | `Nullable.t<string>` | Single directory |
| `openDirectories` | `Nullable.t<array<string>>` | Multi directory |
| `save` | `Nullable.t<string>` | Save-as path |
| `message` | `messageResult` (`string`) | Info / warning / error popup |
| `ask` | `bool` | Yes / No question |
| `confirm` | `bool` | OK / Cancel question |

### Why four `open*` functions?

Upstream's TypeScript `open(options)` returns a different type
depending on `multiple` / `directory` flags:

```typescript
open({ multiple: true })
  // → string[] | null
open({ directory: false })
  // → string | null
```

ReScript bindings can't express that conditional return without
phantom types or runtime branching. We split the surface into
four uncurried functions whose return types are pinned at the
binding level. The corresponding option flags (`multiple`,
`directory`) are intentionally **not** exposed in the
`openOptions` record — pick the function that matches the shape
you need.

### Mobile-only options

`openOptions.pickerMode` (`#document` / `#media` / `#image` /
`#video`) and `openOptions.fileAccessMode` (`#copy` / `#scoped`)
are kept in the binding so iOS / Android builds can use them
later. They're harmless on desktop where the underlying plugin
ignores them.

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-dialog` | `^2.7.0` (peer) |
| Rust `tauri-plugin-dialog` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## See also

- Live demo:
  [`examples/plugin-dialog-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-dialog-demo)
- Source:
  [`packages/plugin-dialog`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-dialog)
- Upstream docs:
  [Tauri 2.x dialog plugin](https://v2.tauri.app/plugin/dialog/)
