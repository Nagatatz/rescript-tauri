# Changelog

All notable changes to **`@rescript-tauri/core`** are documented in
this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- 12 Phase-1 ReScript modules under `src/`, every one paired with a
  hand-written `.resi` signature and Tauri-upstream doc-comment
  links:
  - `Core` — IPC bridge: `Raw.invoke`, typed `Command` (`make` /
    `invoke` / `invokeExn`), streaming `Channel`, `convertFileSrc`.
    Exposes a public `decoder<'value>` type alias for downstream
    packages.
  - `Event` — typed pub/sub (`make` / `listen` / `once` / `emit` /
    `emitTo`) with an `eventTarget` discriminator. Listener
    callbacks receive `result<event<'payload>, string>` so decode
    failures are explicit.
  - `Window` — opaque handle plus ~80 instance / static methods
    (theme, cursorIcon, monitor helpers, drag/resize, six `on*`
    handlers, ...).
  - `Webview` — opaque handle, 14 instance methods, and a
    `dragDropEvent` variant.
  - `WebviewWindow` — combined Window + Webview surface with
    zero-cost `asWindow` / `asWebview` casts.
  - `Menu` — full menu hierarchy (`MenuItem`, `CheckMenuItem`,
    `IconMenuItem`, `PredefinedMenuItem`, `Submenu`, `Menu`) with
    `itemKind` and `predefinedItem` variants.
  - `Tray` — `TrayIcon` opaque handle + `trayIconEvent` variant
    (`Click` / `DoubleClick` / `Enter` / `Move` / `Leave`).
  - `Path` — 31 path helpers + `BaseDirectory` enum.
  - `App` — `getName`, `getVersion`, `getTauriVersion`,
    `defaultWindowIcon`, `setTheme`, ... (stable subset).
  - `Image` — RGBA-image opaque handle (`fromPath` / `fromBytes` /
    `new_` / `rgba` / `size`).
  - `Dpi` — `LogicalSize`, `PhysicalSize`, `LogicalPosition`,
    `PhysicalPosition`, `Size`, `Position` as opaque JS-class
    bindings.
  - `Mocks` — `mockIPC`, `mockWindows`, `clearMocks`.
- `Tauri.res` umbrella module re-exporting `Core`, `Event`,
  `Window`, `Webview`, `WebviewWindow` (PRD §10 row 1, confirmed
  2026-05-09).
- Type-level signature tests under `tests/*_signature.res` and
  vitest runtime tests under `tests/runtime/*.test.mjs`.
- Four buildable examples gated by 3-OS CI: `hello-world`,
  `window-management`, `ipc-typed`, `streaming-ipc`.
- GitHub Actions workflows for build, type-level tests, runtime
  tests, examples build, doc-link lint, Tauri / ReScript
  compatibility nightlies, lint-format (Biome), coverage, and
  release.

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
### Changed
### Fixed
### Removed

-->
