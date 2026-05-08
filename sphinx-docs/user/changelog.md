# Changelog

```{note}
The Phase 1 module set is feature-complete in `main`. The first
published version of `@rescript-tauri/core` (`v0.1.0`) will appear
here at the Phase 1 release. Until then, the entries under
**Unreleased** describe what landed on `main` since the project's
inception.
```

## Unreleased

### Added

- 12 Phase-1 modules across `packages/core`, every one paired with a
  hand-written `.resi`:
  - `Core` — IPC bridge: `Raw.invoke`, typed `Command` (`make` /
    `invoke` / `invokeExn`), streaming `Channel`,
    `convertFileSrc`. Exposes a public `decoder<'value>` type alias
    for downstream packages.
  - `Event` — typed pub/sub with `make`, `listen`, `once`, `emit`,
    `emitTo`, and an `eventTarget` discriminator. Listener callbacks
    receive `result<event<'payload>, string>` so decode failures are
    explicit.
  - `Window` — opaque handle plus ~80 instance / static methods
    (theme, cursorIcon, monitor helpers, drag/resize, six `on*`
    handlers, ...).
  - `Webview` — opaque handle, 14 instance methods, and a
    `dragDropEvent` variant.
  - `WebviewWindow` — combined Window + Webview surface with
    zero-cost `asWindow` / `asWebview` casts.
  - `Menu` — full menu hierarchy (`MenuItem`, `CheckMenuItem`,
    `IconMenuItem`, `PredefinedMenuItem`, `Submenu`, `Menu`) with an
    `itemKind` variant and a `predefinedItem` variant.
  - `Tray` — `TrayIcon` opaque handle + `trayIconEvent` variant
    (`Click` / `DoubleClick` / `Enter` / `Move` / `Leave`).
  - `Path` — 31 path helpers + `BaseDirectory` enum.
  - `App` — `getName`, `getVersion`, `getTauriVersion`,
    `defaultWindowIcon`, `setTheme`, ... (stable subset).
  - `Image` — RGBA-image opaque handle with `fromPath`, `fromBytes`,
    `new_`, `rgba`, `size`.
  - `Dpi` — `LogicalSize`, `PhysicalSize`, `LogicalPosition`,
    `PhysicalPosition`, `Size`, `Position` as opaque JS-class
    bindings.
  - `Mocks` — `mockIPC`, `mockWindows`, `clearMocks`.
- `Tauri.res` umbrella module re-exporting `Core`, `Event`, `Window`,
  `Webview`, `WebviewWindow` (PRD §10 row 1, confirmed 2026-05-09).
- Four buildable examples gated by 3-OS CI: `hello-world`,
  `window-management`, `ipc-typed`, `streaming-ipc`.
- Nine GitHub Actions workflows (build-core, tests-core-types,
  tests-core-runtime, doc-link-lint, examples-build,
  compat-tauri-latest, compat-rescript-prerelease, release, docs).

### Changed

- (none yet)

### Fixed

- (none yet)

---

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
- New feature description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

### Removed
- Removed feature description

-->
