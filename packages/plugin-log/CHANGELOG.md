# Changelog

All notable changes to **`@rescript-tauri/plugin-log`** are
documented in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Bindings for `@tauri-apps/plugin-log` v2.8.0 — 100% of the stable
  public surface (7 functions + 3 types + `LogLevel` numeric-enum
  module).
- 7 functions: `error` / `warn` / `info` / `debug` / `trace` (each
  takes a `message` plus optional `~options=?: logOptions`),
  `attachLogger` (subscribe via callback), `attachConsole` (stream
  to the JS console).
- `LogLevel` module exposing the upstream numeric enum
  (`Trace=1` / `Debug=2` / `Info=3` / `Warn=4` / `Error=5`) as `int`
  constants `trace` / `debug_` / `info_` / `warn_` / `error_`. The
  trailing underscore on `debug_` / `info_` / `warn_` / `error_`
  matches the convention used in `plugin-notification`'s
  `Visibility.{private_, public_}` to avoid the `$$` reserved-word
  escape ReScript would otherwise emit.
- `logOptions` (`{file?, line?, keyValues?}`), `recordPayload`
  (`{level, message}` delivered to `attachLogger`'s callback), and
  `unlisten` (`unit => unit`).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-log ^2.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-log-types.yml` /
  `tests-plugin-log-runtime.yml`, plus `release.yml` recognition of
  the `plugin-log-v*` tag prefix and a `plugin-log` entry in the
  `tests-coverage.yml` matrix.

### Deferred to follow-up sub-steerings

- Runnable example app (`examples/plugin-log-demo/`).
- sphinx-docs `user/plugin-log.md` page.
