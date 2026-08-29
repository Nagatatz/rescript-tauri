# Changelog

```{note}
All ten `@rescript-tauri/*` packages are published on npm; the
current release is `0.1.2`. Each package keeps its own canonical
changelog under `packages/<name>/CHANGELOG.md`; this page collects
the highlights across all of them.
```

## Maintenance releases

Patch releases that only refresh development dependencies. The
published artifacts (compiled `.mjs`, `.res` / `.resi` sources) are
unaffected, and no API changes are involved.

### 0.1.2 (2026-08-30)

All ten packages. Development dependencies bumped to vitest 4.1.11,
@vitest/coverage-v8 4.1.11, happy-dom 20.11.13, @types/node 26.4.0,
rescript 12.3.1; `core` also tracks @tauri-apps/api 2.11.1,
`plugin-dialog` @tauri-apps/plugin-dialog 2.7.2, and `plugin-log`
@tauri-apps/plugin-log 2.9.0.

### 0.1.1 (2026-06-10)

All ten packages. Development dependencies bumped to ReScript 12.3,
@rescript/core 1.6.1, vitest 4.1.8, @vitest/coverage-v8 4.1.8,
happy-dom 20.10.2.

## `@rescript-tauri/core` 0.1.0 (2026-05-12)

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

## `@rescript-tauri/schema` 0.1.0 (2026-05-12)

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

## `@rescript-tauri/plugin-fs` 0.1.0 (2026-05-12)

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

## `@rescript-tauri/plugin-dialog` 0.1.0 (2026-05-12)

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

## `@rescript-tauri/plugin-shell` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-shell/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-shell/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-shell` v2.3.5 — 100% of the
  stable public surface (`openPath` / `Command.{create,createRaw,
  sidecar,sidecarRaw,spawn,execute,onClose,onError,onStdoutData,
  onStderrData}` / `Child.{pid,kill,write}` / `EventEmitter`).
- Runnable example
  [`examples/plugin-shell-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-shell-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-shell ^2.3.0`.

## `@rescript-tauri/plugin-notification` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-notification/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-notification/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-notification` v2.3.3 — 100% of
  the stable public surface (15 functions + 8 records +
  `Schedule` module + `Importance` / `Visibility` `@unboxed`
  variants).
- The upstream `sendNotification(Options | string)` overload is
  split into `sendNotification` / `sendNotificationText` so the
  argument type stays static.
- Runnable example
  [`examples/plugin-notification-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-notification-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-notification ^2.3.0`.

## `@rescript-tauri/plugin-log` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-log/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-log/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-log` v2.8.0 — 100% of the
  stable public surface (5 log functions + `attachLogger` +
  `attachConsole` + `LogLevel` `@unboxed` variant).
- `LogLevel.t` is an `@unboxed` polymorphic-variant wrapper over
  the upstream numeric enum (`Trace`=1 … `Error`=5) so the runtime
  representation stays wire-compatible.
- Runnable example
  [`examples/plugin-log-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-log-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-log ^2.0.0`.

## `@rescript-tauri/plugin-os` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-os/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-os/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-os` v2.3.2 — 100% of the
  stable public surface (6 sync getters + `OsType.get` (sync) +
  `locale` / `hostname` (async) + 4 polymorphic variants).
- `OsType.get` lives in an `OsType` submodule because `type` is
  reserved at the top level of a ReScript module.
- Runnable example
  [`examples/plugin-os-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-os-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-os ^2.0.0`.

## `@rescript-tauri/plugin-clipboard-manager` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-clipboard-manager/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-clipboard-manager/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-clipboard-manager` v2.3.2 —
  100% of the stable public surface (6 functions: `writeText` /
  `readText` / `writeImage` / `readImage` / `writeHtml` /
  `clear`).
- `readImage` returns `RescriptTauriCore.Image.t` (the existing
  core image handle, reused via `peerDependencies`).
- Runnable example
  [`examples/plugin-clipboard-manager-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-clipboard-manager-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-clipboard-manager ^2.0.0`.

## `@rescript-tauri/plugin-http` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-http/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-http/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-http` v2.5.9 — 100% of the
  stable public surface (`fetch` + 5 record / variant types:
  `proxy<'proxyValue>` / `proxyConfig` / `basicAuth` /
  `clientOptions<'proxyValue>` / `dangerousSettings`).
- The DOM `Request` / `Response` / `RequestInit` types are
  intentionally polymorphic; the call site picks a strategy
  (annotation / `Obj.magic` / external binding).
- Runnable example
  [`examples/plugin-http-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-http-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-http ^2.0.0`.

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
