# plugin-dialog-demo

Tauri 2.x desktop example exercising every public function of
[`@rescript-tauri/plugin-dialog`](../../packages/plugin-dialog).

## Status

Phase 2 — shipped (added 2026-05-09 via steering 036). The frontend
ReScript piece builds with `pnpm --filter plugin-dialog-demo build`;
the Rust side requires the Tauri toolchain (`pnpm tauri dev` from
this directory). The example is included in the `examples-build` CI
matrix and is exercised on Linux / macOS / Windows on every PR.

## Run locally

```bash
cd examples/plugin-dialog-demo
pnpm install
pnpm tauri dev
```

## What it does

The window shows nine buttons. Each one calls one
`@rescript-tauri/plugin-dialog` API and writes the result into the
`<pre id="result">` element below the buttons.

| Button id | Function | Notes |
|---|---|---|
| `btn-open-file` | `openFile` | Single-file picker with a text-file `dialogFilter`. |
| `btn-open-files` | `openFiles` | Multi-file picker. |
| `btn-open-dir` | `openDirectory` | No options — exercises the all-defaults path. |
| `btn-open-dirs` | `openDirectories` | Sets `recursive: true`. |
| `btn-save` | `save` | Save-as dialog with default filename + filter. |
| `btn-message-info` | `message` | `kind: #info`, `buttons: #Ok`. |
| `btn-message-error` | `message` | `kind: #error`, `buttons: #OkCancel`, custom OK label. |
| `btn-ask` | `ask` | `kind: #warning` with custom button labels. |
| `btn-confirm` | `confirm` | Default OK / Cancel buttons. |

The mobile-only options `pickerMode` and `fileAccessMode` are
referenced by `let _demo*` bindings inside `App.res` so they show up
in jump-to-definition without driving an actual mobile build.

## Files of interest

| File | Role |
|---|---|
| `src/App.res` | ReScript entry calling plugin-dialog. |
| `src/main.mjs` | Plain-JS entry that imports the compiled ReScript. |
| `index.html` | HTML host page with the nine buttons + result `<pre>`. |
| `src-tauri/src/main.rs` | Rust entry registering `tauri_plugin_dialog::init()`. |
| `src-tauri/Cargo.toml` | Pulls in `tauri-plugin-dialog = "2"`. |
| `src-tauri/tauri.conf.json` | App config (productName, identifier, window). |
| `src-tauri/capabilities/default.json` | Allows `core:default` + `dialog:default`. |

## Compatibility

- Upstream JS plugin: `@tauri-apps/plugin-dialog ^2.7.0` (peer of
  `@rescript-tauri/plugin-dialog`).
- Rust crate: `tauri-plugin-dialog 2.x`.
- ReScript: `>=12.0.0` with `@rescript/core >=1.6.0`.

## Notes

- `App.res` calls plugin-dialog through its full namespace
  (`RescriptTauriPluginDialog.PluginDialog.*`). A consolidated
  top-level re-export module hasn't been added yet for plugin
  packages.
- The icon set under `src-tauri/icons/` is reused from
  `examples/hello-world/`; replacing them with a dedicated icon set
  is not Phase 2 scope.
- `frontendDist` points at `../` so Tauri serves `index.html`
  directly without a bundler. Real apps would route through Vite.
