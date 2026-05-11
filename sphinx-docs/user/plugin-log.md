# `@rescript-tauri/plugin-log`

ReScript bindings for the [Tauri 2.x logging
plugin](https://v2.tauri.app/plugin/logging/) — five log levels
(`error` / `warn` / `info` / `debug` / `trace`) plus log-stream
subscription via `attachLogger` and `attachConsole`. The 100%
stable public surface of `@tauri-apps/plugin-log` v2.8.x is
covered.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-log-v0.1.0`) is scheduled alongside
the other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-log` via the source repository or a
workspace link.
```

## Install

```bash
pnpm add @rescript-tauri/plugin-log @tauri-apps/plugin-log
```

`@rescript-tauri/plugin-log` declares both
`@rescript-tauri/core` and `@tauri-apps/plugin-log` as
`peerDependencies`, so you control each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-log"
  ]
}
```

On the Rust side, add the plugin crate and register it on the
builder. `tauri_plugin_log::Builder` lets you select which sinks
(stdout, the webview console, a rotating log file) receive
records and the global level filter:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-log = "2"
log = "0.4"
```

```rust
// src-tauri/src/main.rs
use tauri_plugin_log::{Target, TargetKind};

fn main() {
    tauri::Builder::default()
        .plugin(
            tauri_plugin_log::Builder::new()
                .targets([
                    Target::new(TargetKind::Stdout),
                    Target::new(TargetKind::Webview),
                    Target::new(TargetKind::LogDir { file_name: None }),
                ])
                .level(log::LevelFilter::Info)
                .build(),
        )
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

The three `TargetKind` variants above are the most common combo:
`Stdout` prints to the host terminal, `Webview` forwards each
record so `attachConsole` can mirror it in the JS console, and
`LogDir` writes to a platform-appropriate `$APPLOG/<bundle>.log`
file.

## Capabilities

Tauri 2.x requires every plugin permission to be granted
explicitly. The minimal set for logging is:

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "log:default"
  ]
}
```

`log:default` covers every log API surfaced by this binding
(level functions, attach helpers, and the underlying
`plugin:log|log` IPC command).

## Minimal example

```rescript
open RescriptTauriPluginLog

let bootstrap = async () => {
  let _unlisten = await PluginLog.attachConsole()
  await PluginLog.info(
    "App started",
    ~options={file: "Main.res", line: 1},
  )
}
```

`attachConsole` subscribes a JS-console writer to the log stream
(useful while developing in a webview that doesn't show stdout).
The returned `unlisten` is a `unit => unit` callback — invoke it
to detach the subscription.
