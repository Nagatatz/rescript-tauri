# plugin-fs-demo

Tauri 2.x desktop example exercising every public function of
[`@rescript-tauri/plugin-fs`](../../packages/plugin-fs).

## Status

Phase 2 — added 2026-05-09 (steering 037). The frontend ReScript
piece builds today (`pnpm --filter plugin-fs-demo build`); the Rust
side requires the Tauri toolchain (`pnpm tauri dev` from this
directory) and is fully exercised once the CI matrix gets a
`plugin-fs-demo` job (scheduled for the next CI-extension steering).

## Run locally

```bash
cd examples/plugin-fs-demo
pnpm install
pnpm tauri dev
```

## What it does

The window walks through five steps, each driving multiple plugin-fs
APIs. All operations target the sandboxed
`$APPLOCALDATA/plugin-fs-demo/` directory so the demo stays
self-contained.

| Step | Button id | APIs exercised | Notes |
|---|---|---|---|
| 1 | `btn-setup` | `mkdir`, `writeTextFile`, `writeFile` | Creates `plugin-fs-demo/` and writes `notes.txt` (text) + `bytes.bin` (4 bytes). |
| 2 | `btn-read` | `exists`, `readTextFile`, `readFile`, `stat`, `size` | Confirms the files written in Step 1. |
| 3 | `btn-list` | `readDir`, `lstat` | Lists the demo directory and `lstat`s each entry. |
| 4 | `btn-modify` | `copyFile`, `rename`, `truncate` | Copies the text file, renames the copy, truncates the bytes file. |
| 5 | `btn-cleanup` | `remove` (recursive) | Removes the entire demo directory so Step 1 can run again. |

That covers all 14 public plugin-fs functions (`readTextFile`,
`writeTextFile`, `readFile`, `writeFile`, `exists`, `remove`,
`rename`, `mkdir`, `readDir`, `stat`, `lstat`, `truncate`, `copyFile`,
`size`).

## Files of interest

| File | Role |
|---|---|
| `src/App.res` | ReScript entry calling plugin-fs. |
| `src/main.mjs` | Plain-JS entry that imports the compiled ReScript. |
| `index.html` | HTML host page with the five step buttons + result `<pre>`. |
| `src-tauri/src/main.rs` | Rust entry registering `tauri_plugin_fs::init()`. |
| `src-tauri/Cargo.toml` | Pulls in `tauri-plugin-fs = "2"`. |
| `src-tauri/tauri.conf.json` | App config (productName, identifier, window). |
| `src-tauri/capabilities/default.json` | Allows `core:default` + `fs:default` + `fs:allow-applocaldata-{read,write,meta}-recursive`. |

## Compatibility

- Upstream JS plugin: `@tauri-apps/plugin-fs ^2.5.0` (peer of
  `@rescript-tauri/plugin-fs`).
- Rust crate: `tauri-plugin-fs 2.x`.
- ReScript: `>=12.0.0` with `@rescript/core >=1.6.0`.

## Notes

- `App.res` calls plugin-fs through its full namespace
  (`RescriptTauriPluginFs.PluginFs.*`). A consolidated top-level
  re-export module hasn't been added yet for plugin packages.
- `BaseDirectory.appLocalData` is re-exported by plugin-fs from
  `@rescript-tauri/core`'s `Path.BaseDirectory.t`, so callers don't
  need to add a separate import to choose the sandbox.
- `fs:allow-applocaldata-{read,write,meta}-recursive` extend
  `fs:default` to permit reading, writing, and stat/lstat under
  `$APPLOCALDATA` recursively. Without these, every operation in the
  demo would fail at the capability layer.
- `Uint8Array.length` lives on the parent `TypedArray` module in
  `@rescript/core`; the demo uses `TypedArray.length(bytes)` to
  match.
- Icons under `src-tauri/icons/` are reused from
  `examples/hello-world/`.
- `frontendDist` points at `../` so Tauri serves `index.html`
  directly without a bundler. Real apps would route through Vite.
