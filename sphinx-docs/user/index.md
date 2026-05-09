# User Guide

Everything you need to start writing Tauri 2.x desktop apps with ReScript.

## Getting Started

- [Installation](installation.md) — Add `@rescript-tauri/core` to a Tauri project
- [Quick Start](quickstart.md) — Try the 3-layer IPC API in a minimal example

## Reference

- [Configuration](configuration.md) — `rescript.json`, `peerDependencies`, compatibility matrix
- [Changelog](changelog.md) — Release notes

## Modules at a glance

`@rescript-tauri/core` ships with 12 Phase-1 modules plus a curated
`Tauri` umbrella for the most common imports. Each module has its
own `.resi` and a doc-comment line linking to the matching Tauri
upstream page.

| Module | Purpose |
|---|---|
| `Tauri` | `open Tauri` re-export of the 5 most common modules (Core / Event / Window / Webview / WebviewWindow) |
| `Core` | IPC bridge — `Raw.invoke`, typed `Command`, streaming `Channel`, `convertFileSrc` |
| `Event` | Pub/sub event bus (`make`, `listen`, `once`, `emit`, `emitTo`) |
| `Window` | Window class — opaque handle + ~80 instance / static methods, full type set (theme, cursorIcon, effects, monitor, ...) |
| `Webview` | Webview class — opaque handle + 14 instance methods + drag-and-drop event variant |
| `WebviewWindow` | Combined Window + Webview surface; zero-cost `asWindow` / `asWebview` casts |
| `Menu` | Application menu hierarchy (`MenuItem`, `CheckMenuItem`, `IconMenuItem`, `PredefinedMenuItem`, `Submenu`, `Menu`) |
| `Tray` | System tray icon (`TrayIcon`) with click-event variant |
| `Path` | Path utilities — 31 helpers + `BaseDirectory` enum |
| `App` | Application metadata + lifecycle (`getName`, `getVersion`, `setTheme`, `defaultWindowIcon`, ...) |
| `Image` | RGBA-image opaque handle (`fromPath`, `fromBytes`, `new_`, `rgba`, `size`) |
| `Dpi` | DPI-aware size and position (`LogicalSize`, `PhysicalSize`, `LogicalPosition`, `PhysicalPosition`, `Size`, `Position`) |
| `Mocks` | Test helpers (`mockIPC`, `mockWindows`, `clearMocks`) |

## Phase 2 packages

Phase 2 introduces three add-on packages that build on the Phase 1
core. Each ships independently and pulls the matching upstream
plugin / schema library through `peerDependencies`.

| Package | Purpose | Guide |
|---|---|---|
| `@rescript-tauri/plugin-fs` | Filesystem operations (read / write / dir / stat) | [plugin-fs](plugin-fs.md) |
| `@rescript-tauri/plugin-dialog` | Native dialogs (open / save / message / ask / confirm) | [plugin-dialog](plugin-dialog.md) |
| `@rescript-tauri/schema` | Layer 3 typed IPC via `rescript-schema` | [schema](schema.md) |

```{toctree}
:hidden:
:maxdepth: 2

installation
quickstart
configuration
plugin-fs
plugin-dialog
schema
changelog
```
