# Changelog

All notable changes to **`@rescript-tauri/plugin-shell`** are
documented in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## Unreleased

Maintenance — no runtime or API changes.

### Changed

- Bumped development dependencies to their latest patch / minor
  releases (@types/node 26.1.1, vitest 4.1.10, @vitest/coverage-v8
  4.1.10, happy-dom 20.10.6). The published artifacts are unaffected.

## 0.1.1 (2026-06-10)

Maintenance release — no runtime or API changes.

### Changed

- Updated development dependencies to their latest patch / minor
  releases (ReScript 12.3, @rescript/core 1.6.1, vitest 4.1.8,
  @vitest/coverage-v8 4.1.8, happy-dom 20.10.2). The published
  artifacts are unaffected.

## 0.1.0 (2026-05-12)

### Added

- Bindings for `@tauri-apps/plugin-shell` v2.3.5 — 100% of the stable
  public surface:
  - `openPath(path, ~openWith=?)` — opens a URL / file with the OS
    default (or specified) application. Renamed from upstream `open`
    to avoid clashing with ReScript's `open` keyword.
  - `Command` module with `create` / `createRaw` / `sidecar` /
    `sidecarRaw` factory functions (the TypeScript conditional
    return type of `encoding: "raw"` is split into dedicated
    `*Raw` functions so the `Uint8Array.t` result type stays
    static).
  - `Command.spawn` / `Command.execute` lifecycle methods.
  - `Command.onClose` / `Command.onError` /
    `Command.onStdoutData` / `Command.onStderrData` /
    `Command.removeAllListeners` event subscription helpers.
  - `Command.stdout` / `Command.stderr` accessors returning the
    underlying `EventEmitter` for advanced usage.
  - `Child` module — `pid` / `write` / `kill`.
  - `EventEmitter` module — 9 generic methods (`on`, `once`, `off`,
    `addListener`, `removeListener`, `removeAllListeners`,
    `listenerCount`, `prependListener`, `prependOnceListener`).
- Type aliases: `spawnOptions`, `childProcess<'o>`,
  `terminatedPayload`.
- Type-level signature test
  (`tests/plugin_shell_signature.res`) and vitest runtime tests
  (`tests/runtime/plugin_shell.test.mjs`).
- Runnable example
  [`examples/plugin-shell-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-shell-demo)
  exercising the full surface (openPath / Command / Child /
  EventEmitter chains) from button-driven UI.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-shell ^2.3.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-shell-types.yml` /
  `tests-plugin-shell-runtime.yml`, plus `release.yml`
  recognition of the `plugin-shell-v*` tag prefix and a
  `plugin-shell` entry in the `tests-coverage.yml` matrix.

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
### Changed
### Fixed
### Removed

-->
