# `@rescript-tauri/plugin-log`

ReScript bindings for the [Tauri 2.x logging
plugin](https://v2.tauri.app/plugin/logging/) — five log levels
(`error` / `warn` / `info` / `debug` / `trace`) plus log-stream
subscription via `attachLogger` and `attachConsole`. The 100%
stable public surface of `@tauri-apps/plugin-log` v2.8.x is
covered.

```{note}
{{ phase_2_note }}
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

## Public API

All seven functions are exposed under `PluginLog`, together with
the numeric-enum module `LogLevel`:

| Symbol | Purpose |
|---|---|
| `error` / `warn` / `info` / `debug` / `trace` | Emit a record at the given level |
| `attachLogger` | Subscribe a callback to every record |
| `attachConsole` | Forward every record to the JS console |
| `LogLevel.{Trace, Debug, Info, Warn, Error}` | `@unboxed` variant carrying the numeric level (1..5) |
| `logOptions` | Optional metadata record passed to a log call |
| `recordPayload` | `{level, message}` delivered to `attachLogger`'s callback |
| `unlisten` | `unit => unit` returned by `attachLogger` / `attachConsole` |

### Level functions

Each of the five level functions has the same shape:

```rescript
let error: (string, ~options: logOptions=?) => promise<unit>
let warn:  (string, ~options: logOptions=?) => promise<unit>
let info:  (string, ~options: logOptions=?) => promise<unit>
let debug: (string, ~options: logOptions=?) => promise<unit>
let trace: (string, ~options: logOptions=?) => promise<unit>
```

The labeled `~options` argument is optional. When provided it
attaches per-call metadata that the Rust side records alongside
the message:

```rescript
await PluginLog.warn(
  "queue draining slowly",
  ~options={
    file: "Worker.res",
    line: 42,
    keyValues: Dict.fromArray([
      ("queue", "ingest"),
      ("backlog", "1872"),
    ]),
  },
)
```

`logOptions` fields:

| Field | Type | Notes |
|---|---|---|
| `file` | `string` (optional) | Source file the call originated from |
| `line` | `int` (optional) | Source line number |
| `keyValues` | `Dict.t<string>` (optional) | Free-form structured fields appended to the record |

`@rescript/core`'s `Dict.t<string>` maps to a plain JS object on
output, which the upstream plugin reads as the structured-fields
payload.

### `LogLevel.t` variant

`LogLevel` exposes the upstream numeric enum as an `@unboxed`
variant with `@as(N)` annotations, so the runtime representation is
the bare integer while ReScript code uses constructor names:

```rescript
PluginLog.LogLevel.Trace   // @as(1)
PluginLog.LogLevel.Debug   // @as(2)
PluginLog.LogLevel.Info    // @as(3)
PluginLog.LogLevel.Warn    // @as(4)
PluginLog.LogLevel.Error   // @as(5)
```

| Constructor | Wire value |
|---|---|
| `Trace` | `1` |
| `Debug` | `2` |
| `Info` | `3` |
| `Warn` | `4` |
| `Error` | `5` |

Use `switch` over `recordPayload.level` for exhaustive matching —
the compiler will warn if a case is missed when a new level is
added upstream.

### `attachLogger` / `attachConsole`

```rescript
let attachLogger: (recordPayload => unit) => promise<unlisten>
let attachConsole: unit => promise<unlisten>
```

`attachLogger` runs your callback for every record the Rust
side emits. Pattern-match on `record.level`:

```rescript
let unlisten = await PluginLog.attachLogger(record => {
  let label = switch record.level {
  | Error => "ERROR"
  | Warn => "WARN"
  | Info => "INFO"
  | Debug => "DEBUG"
  | Trace => "TRACE"
  }
  Console.log(label ++ ": " ++ record.message)
})

// ...later
unlisten()
```

`attachConsole` is a convenience helper that wires the records to
`console.log` / `console.warn` / `console.error` based on level —
useful for mirroring Rust-side logs in the webview devtools
without writing the dispatcher yourself.

Both functions return a `promise<unlisten>`. Always await the
promise before treating the subscription as live, and call the
returned `unlisten()` once when you're done — multiple listeners
can be attached in parallel but they are not de-duplicated.

## Pitfalls

### Log calls are async — await them

The five level functions return `promise<unit>`, not `unit`.
Forgetting to `await` swallows errors silently and can race
against process shutdown:

```rescript
// ❌ may be dropped if the program exits immediately
let _ = PluginLog.info("starting")

// ✅
await PluginLog.info("starting")
```

If you do not need to wait for delivery, bind the promise to
`_ignore` explicitly so the intent is visible at the call site.

### `attachLogger` / `attachConsole` are not covered by `Mocks.mockIPC`

The two attach helpers subscribe via
`__TAURI_INTERNALS__.transformCallback`, not the regular IPC
command bridge, so `Mocks.mockIPC` cannot intercept them. Runtime
tests that exercise log streaming stub
`globalThis.__TAURI_INTERNALS__` directly — see
`packages/plugin-log/tests/runtime/plugin_log.test.mjs` for the
working pattern.

The level functions themselves (`error` / `warn` / `info` /
`debug` / `trace`) go through the normal Tauri IPC
(`plugin:log|log`) and *are* mockable with `Mocks.mockIPC`.

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-log` | `^2.0.0` (peer) |
| Rust `tauri-plugin-log` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## See also

- Live demo:
  [`examples/plugin-log-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-log-demo)
- Source:
  [`packages/plugin-log`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-log)
- Package README:
  [`packages/plugin-log/README.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-log/README.md)
- Upstream docs:
  [Tauri 2.x logging plugin](https://v2.tauri.app/plugin/logging/)
- Upstream JS reference:
  [log module](https://v2.tauri.app/reference/javascript/log/)
