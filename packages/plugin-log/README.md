# @rescript-tauri/plugin-log

ReScript bindings for [`@tauri-apps/plugin-log`](https://www.npmjs.com/package/@tauri-apps/plugin-log)
— Tauri 2.x's logging plugin (`error` / `warn` / `info` / `debug` /
`trace` levels with optional `file` / `line` / `keyValues` metadata,
plus log-stream listeners).

## Status

Phase 2+, first iteration. Awaiting first npm publish (`plugin-log-v0.1.0`).

100% coverage of the stable public surface of `@tauri-apps/plugin-log` v2.8.0.

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-log @rescript-tauri/core @tauri-apps/plugin-log @tauri-apps/api
```

## Quick example

```rescript
module L = RescriptTauriPluginLog.PluginLog

let bootstrap = async () => {
  let _unlisten = await L.attachConsole()
  await L.info("App started", ~options={file: "Main.res", line: 1})
}
```

## Public API

| Symbol | Purpose |
|---|---|
| `error` / `warn` / `info` / `debug` / `trace` | Log a message at the given level |
| `attachLogger` | Subscribe to all log records via callback |
| `attachConsole` | Stream every log record to the JS console |
| `LogLevel.{trace, debug_, info_, warn_, error_}` | Numeric level constants (1..5) |
| `logOptions` | `{file?, line?, keyValues?}` |
| `recordPayload` | `{level, message}` delivered to `attachLogger`'s callback |
| `unlisten` | `unit => unit` returned by `attachLogger` / `attachConsole` |

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-log` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-log` | `^2.0.0` (peer) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## See also

- [Changelog](./CHANGELOG.md)
- Upstream docs:
  [Tauri 2.x log plugin](https://v2.tauri.app/plugin/logging/)
- [`@rescript-tauri/core` README](../core/README.md)
