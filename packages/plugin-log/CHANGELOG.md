# Changelog

All notable changes to **`@rescript-tauri/plugin-log`** are
documented in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## Unreleased

Maintenance — no runtime or API changes.

### Changed

- Bumped development dependencies to their latest patch / minor
  releases (@types/node 26.1.0, vitest 4.1.9, @vitest/coverage-v8
  4.1.9, happy-dom 20.10.6). The published artifacts are unaffected.

## 0.1.1 (2026-06-10)

Maintenance release — no runtime or API changes.

### Changed

- Updated development dependencies to their latest patch / minor
  releases (ReScript 12.3, @rescript/core 1.6.1, vitest 4.1.8,
  @vitest/coverage-v8 4.1.8, happy-dom 20.10.2). The published
  artifacts are unaffected.

## 0.1.0 (2026-05-12)

### Added

- Bindings for `@tauri-apps/plugin-log` v2.8.0 — 100% of the stable
  public surface (7 functions + 3 types + `LogLevel` variant module).
- 7 functions: `error` / `warn` / `info` / `debug` / `trace` (each
  takes a `message` plus optional `~options=?: logOptions`),
  `attachLogger` (subscribe via callback), `attachConsole` (stream
  to the JS console).
- `LogLevel.t` — `@unboxed` variant with constructors
  `Trace` / `Debug` / `Info` / `Warn` / `Error` carrying the upstream
  numeric enum (`@as(1)` … `@as(5)`). Runtime representation is the
  bare integer so the variant is wire-compatible with upstream's
  `recordPayload.level` field.
- `logOptions` (`{file?, line?, keyValues?}`), `recordPayload`
  (`{level: LogLevel.t, message}` delivered to `attachLogger`'s
  callback), and `unlisten` (`unit => unit`).
- Runnable example
  [`examples/plugin-log-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-log-demo)
  exercising the full surface (5 log levels + `attachLogger` /
  `attachConsole` listeners + Detach) from button-driven UI.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-log ^2.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-log-types.yml` /
  `tests-plugin-log-runtime.yml`, plus `release.yml` recognition of
  the `plugin-log-v*` tag prefix and a `plugin-log` entry in the
  `tests-coverage.yml` matrix.
