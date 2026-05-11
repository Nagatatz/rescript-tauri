# `@rescript-tauri/plugin-os`

ReScript bindings for the [Tauri 2.x OS info
plugin](https://v2.tauri.app/plugin/os-info/) — synchronous
getters for `platform` / `version` / `arch` / `family` and async
getters for `locale` / `hostname`. The 100% stable public surface
of `@tauri-apps/plugin-os` v2.3.x is covered, surfaced through
four polymorphic-variant types that mirror the upstream
string-literal unions.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-os-v0.1.0`) is scheduled alongside the
other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-os` via the source repository or a
workspace link.
```

## Install

```bash
pnpm add @rescript-tauri/plugin-os @tauri-apps/plugin-os
```

`@rescript-tauri/plugin-os` declares both `@rescript-tauri/core`
and `@tauri-apps/plugin-os` as `peerDependencies`, so you control
each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-os"
  ]
}
```

On the Rust side, register the plugin on the builder:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-os = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

`tauri_plugin_os::init()` takes no configuration — the default
builder is sufficient for every API exposed by this binding.

## Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "os:default"
  ]
}
```

`os:default` grants the IPC permissions `allow-locale` and
`allow-hostname` that the two async getters require. The seven
synchronous getters do **not** travel over IPC (see [Sync
getters](#sync-getters) below) and therefore do not consume a
capability — but the plugin must still be registered on the Rust
builder for the JavaScript globals to be initialized.
