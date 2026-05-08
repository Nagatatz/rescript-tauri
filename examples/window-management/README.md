# window-management

Demonstrates `@rescript-tauri/core`'s `Window` and `WebviewWindow`
APIs from a single ReScript frontend.

## What it shows

| Button | API |
|---|---|
| Set random title | `Window.setTitle` |
| Maximize / Unmaximize | `Window.maximize` / `Window.unmaximize` |
| Minimize | `Window.minimize` |
| Center | `Window.center` |
| 800 × 600 / 1200 × 900 | `Window.setSize` with `Dpi.LogicalSize.make` |
| Open second window | `WebviewWindow.make` |
| Close second window | `WebviewWindow.getByLabel` + `WebviewWindow.close` |

## Run locally

Requires the [Tauri 2.x prerequisites](https://v2.tauri.app/start/prerequisites/).

```bash
cd examples/window-management
pnpm install
pnpm tauri dev
```

CI builds the frontend (`pnpm --filter window-management build`) and
`cargo check`s the Rust side on Ubuntu / macOS / Windows.

## Files of interest

| File | Role |
|---|---|
| `src/App.res` | ReScript entry — Window / WebviewWindow operations |
| `src/main.mjs` | Plain JS entry that imports the compiled ReScript |
| `index.html` | HTML host with buttons |
| `src-tauri/src/main.rs` | Tauri Rust shell (no custom commands) |
