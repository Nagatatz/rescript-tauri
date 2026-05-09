# @rescript-tauri/core

Production-ready ReScript bindings for Tauri 2.x's official JS SDK
(`@tauri-apps/api`). The **core** package of the rescript-tauri
monorepo, exposing the entire Tauri public API surface (IPC, Event,
Window, Webview, Menu, Tray, ...) from ReScript.

## Status

Phase 1 — feature-complete on `main` (12 modules + curated `Tauri`
re-export). Awaiting first npm publish (`v0.1.0`).

## Install (planned, post Phase 1 release)

```bash
pnpm add @rescript-tauri/core @tauri-apps/api
```

`@tauri-apps/api` is declared as a `peerDependency` so you control
the upstream Tauri version.

Add `@rescript-tauri/core` to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": ["@rescript/core", "@rescript-tauri/core"],
  "package-specs": [{ "module": "esmodule", "in-source": true }]
}
```

## Quick example

```rescript
open RescriptTauriCore.Tauri

let greeting: string =
  await Core.Raw.invoke("greet", ~args={"name": "World"})

let win = Window.getCurrent()
await win->Window.setTitle("Hello, ReScript")
```

For the typed `Command` layer, channels, events, and full window /
webview / menu coverage, see the
[user guide](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/quickstart.md)
and the runnable
[examples](https://github.com/Nagatatz/rescript-tauri/tree/main/examples).

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/core` | this package |
| `@tauri-apps/api` | `^2.0.0` (peer) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## Public API

| Module | Purpose |
|---|---|
| `Tauri` | `open Tauri` re-export of the 5 most common modules (Core / Event / Window / Webview / WebviewWindow) |
| `Core` | IPC bridge — `Raw.invoke`, typed `Command`, streaming `Channel`, `convertFileSrc`, `isTauri`, `Resource`, `PluginListener`, `addPluginListener`, `checkPermissions` / `requestPermissions`, `LowLevel` (transformCallback / SERIALIZE_TO_IPC_FN) |
| `Event` | Pub/sub event bus (`make`, `listen`, `once`, `emit`, `emitTo`); `tauriEvent` polymorphic variant + `TauriEvent` named values; `~target` option on `listen` / `once` |
| `Window` | Window class — opaque handle + ~90 instance / static methods (incl. `activityName`, `sceneIdentifier`, `setFocusable`, `setSimpleFullscreen`, `toggleMaximize`, `unminimize`, `onDragDropEvent`), full type set |
| `Webview` | Webview class — handle + 16 instance methods (incl. `getByLabel`, `clearAllBrowsingData`) + drag-and-drop variant |
| `WebviewWindow` | Combined Window + Webview surface; zero-cost `asWindow` / `asWebview` casts |
| `Menu` | Application menu hierarchy (`MenuItem`, `CheckMenuItem`, `IconMenuItem`, `PredefinedMenuItem`, `Submenu`, `Menu`); `nativeIcon` polymorphic variant for macOS system icons |
| `Tray` | System tray icon (`TrayIcon`) with click-event variant |
| `Path` | Path utilities — 31 helpers + `BaseDirectory` enum |
| `App` | Application metadata + lifecycle — full coverage incl. `bundleType` / `getBundleType`, `dataStoreIdentifier` / `fetchDataStoreIdentifiers` / `removeDataStore`, `onBackButtonPress`, `supportsMultipleWindows` |
| `Image` | RGBA-image opaque handle (`fromPath`, `fromBytes`, `new_`, `rgba`, `size`) |
| `Dpi` | DPI-aware size and position (`LogicalSize`, `PhysicalSize`, `LogicalPosition`, `PhysicalPosition`, `Size`, `Position`) |
| `Mocks` | Test helpers (`mockIPC` with `~options=?`, `mockWindows`, `mockConvertFileSrc`, `clearMocks`); `mockIPCOptions` type |

**Coverage**: 100% of the stable public surface of `@tauri-apps/api`
v2.11.0. The only intentionally-omitted symbol is
`Image.transformImage`, which upstream documents as "API signature is
not stable and might change."

See `src/<Module>.resi` for full doc comments and links to the
matching upstream Tauri pages.

## See also

- [Changelog](./CHANGELOG.md)
- [User guide (English)](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/index.md)
- [Quick start](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/quickstart.md)
- [Functional design (内部設計, 日本語)](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md)
- Runnable examples:
  [`hello-world`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/hello-world),
  [`window-management`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/window-management),
  [`ipc-typed`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/ipc-typed),
  [`streaming-ipc`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/streaming-ipc)

## Development

This package is part of the rescript-tauri monorepo. From the
repository root:

```bash
pnpm install                                  # install all workspaces
pnpm --filter @rescript-tauri/core build      # incremental build
pnpm --filter @rescript-tauri/core test       # type-level + vitest
pnpm --filter @rescript-tauri/core run clean  # clean build artifacts
```
