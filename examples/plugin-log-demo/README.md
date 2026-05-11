# plugin-log demo

Minimal Tauri 2.x desktop app that exercises every public function
of [`@rescript-tauri/plugin-log`](../../packages/plugin-log).

## Run

```bash
pnpm install
pnpm --filter plugin-log-demo tauri dev
```

## Buttons

| Button | Calls |
|---|---|
| **error / warn / info / debug / trace** | `PluginLog.<level>(message)` for the matching log level |
| **attachLogger** | `PluginLog.attachLogger(callback)` — receives each record and appends it to the result pane |
| **attachConsole** | `PluginLog.attachConsole()` — pipes records to the JS console |
| **Detach all** | Calls both `unlisten` handles |

The numeric `level: int` field on `recordPayload` is mapped back to
its label via `PluginLog.LogLevel` constants (`error_` / `warn_` /
`info_` / `debug_` / `trace`) — the suffixed names avoid `$$debug`
etc. escapes in the JS output.

## Capabilities

The demo uses `log:default`, which permits all log APIs. See
[`src-tauri/capabilities/default.json`](./src-tauri/capabilities/default.json).

## See also

- [plugin-log user guide](../../sphinx-docs/user/plugin-log.md)
- [`@rescript-tauri/plugin-log` README](../../packages/plugin-log/README.md)
- Upstream: [Tauri 2.x logging plugin](https://v2.tauri.app/plugin/logging/)
