# plugin-os demo

Minimal Tauri 2.x desktop app that exercises every public function
of [`@rescript-tauri/plugin-os`](../../packages/plugin-os).

## Run

```bash
pnpm install
pnpm --filter plugin-os-demo tauri dev
```

## Buttons

| Button | Calls |
|---|---|
| **Show all OS info** | 7 sync getters: `eol` / `platform` / `version` / `family` / `OsType.get` / `arch` / `exeExtension` |
| **Get locale** | `PluginOs.locale()` (async, `Nullable.t<string>`) |
| **Get hostname** | `PluginOs.hostname()` (async, `Nullable.t<string>`) |

The polymorphic variants (`platform` / `osType` / `arch` / `family`)
are decoded into human-readable strings via switch-based helpers in
`src/App.res`.

The upstream `os.type()` is exposed under the `OsType` submodule
(as `OsType.get()`) because `type` is reserved at the top level
in ReScript.

## Capabilities

The demo uses `os:default`. See
[`src-tauri/capabilities/default.json`](./src-tauri/capabilities/default.json).

## See also

- [plugin-os user guide](../../sphinx-docs/user/plugin-os.md)
- [`@rescript-tauri/plugin-os` README](../../packages/plugin-os/README.md)
- Upstream: [Tauri 2.x OS info plugin](https://v2.tauri.app/plugin/os-info/)
