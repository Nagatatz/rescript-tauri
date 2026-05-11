# Changelog

```{note}
All packages are feature-complete in `main`. First publishes
(`v0.1.0`, `schema-v0.1.0`, `plugin-fs-v0.1.0`,
`plugin-dialog-v0.1.0`) are pending. Each package keeps its own
canonical changelog under `packages/<name>/CHANGELOG.md`; this
page collects the highlights of the pre-release state across all
of them.
```

## `@rescript-tauri/core` (Unreleased)

Canonical: [`packages/core/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/core/CHANGELOG.md)

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

## `@rescript-tauri/schema` (Unreleased)

Canonical: [`packages/schema/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/schema/CHANGELOG.md)

### Added

- `Schema.fromSchemas` — typed `Core.Command.t<'args, 'result>`
  from a single `S.t<'args>` + `S.t<'result>` pair.
- `Schema.channelFromSchema` / `Schema.eventFromSchema` —
  schema-decoded `Core.Channel` and `Event` handles.
- `Schema.toDecoder` — lower-level `S.t<'value>` →
  `Core.decoder<'value>` helper.
- `Schema.S` re-exports `RescriptSchema.S` for ergonomic access.
- Runnable example
  [`examples/ipc-typed-with-schema`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/ipc-typed-with-schema)
  pairing against `examples/ipc-typed/` to compare Layer 2 vs
  Layer 3.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `rescript-schema ^9.0.0`. `rescript-struct` is intentionally
  unsupported (RFC-0002 §2.1).

## `@rescript-tauri/plugin-fs` (Unreleased)

Canonical: [`packages/plugin-fs/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-fs/CHANGELOG.md)

### Added

- 14 single-shot filesystem functions (`readTextFile` /
  `writeTextFile` / `readFile` / `writeFile` / `exists` / `remove` /
  `rename` / `mkdir` / `readDir` / `stat` / `lstat` / `truncate` /
  `copyFile` / `size`).
- `PluginFs.BaseDirectory` re-exported from
  `@rescript-tauri/core`'s `Path.BaseDirectory.t`.
- Runnable example
  [`examples/plugin-fs-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-fs-demo)
  exercising the full surface inside the `$APPLOCALDATA` sandbox.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-fs ^2.5.0`.

## `@rescript-tauri/plugin-dialog` (Unreleased)

Canonical: [`packages/plugin-dialog/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-dialog/CHANGELOG.md)

### Added

- 8 native-dialog functions (`openFile` / `openFiles` /
  `openDirectory` / `openDirectories` / `save` / `message` / `ask` /
  `confirm`).
- The TypeScript-level conditional return type of upstream's
  `open(options)` is unrolled into four ReScript functions so the
  result type stays static.
- Runnable example
  [`examples/plugin-dialog-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-dialog-demo)
  driving every public function from one button each.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-dialog ^2.7.0`.

## Repository-level updates

These changes affect the monorepo as a whole and don't belong to a
single package CHANGELOG.

### Added

- GitHub Actions workflows: per-package
  `tests-{core,schema,plugin-fs,plugin-dialog}-{types,runtime}.yml`,
  `examples-build` matrix covering 7 examples on Linux / macOS /
  Windows, `lint-format` (Biome), `tests-coverage` (vitest v8),
  `compat-tauri-latest` and `compat-rescript-prerelease` nightlies,
  `release.yml` recognizing `v*` / `schema-v*` / `plugin-fs-v*` /
  `plugin-dialog-v*` tag prefixes.
- User guide pages for each add-on package
  ([plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
  [schema](schema.md)).

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
