# Changelog

All notable changes to **`@rescript-tauri/plugin-os`** are documented
in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## 0.1.1 (2026-06-10)

Maintenance release — no runtime or API changes.

### Changed

- Updated development dependencies to their latest patch / minor
  releases (ReScript 12.3, @rescript/core 1.6.1, vitest 4.1.8,
  @vitest/coverage-v8 4.1.8, happy-dom 20.10.2). The published
  artifacts are unaffected.

## 0.1.0 (2026-05-12)

### Added

- Bindings for `@tauri-apps/plugin-os` v2.3.2 — 100% of the stable
  public surface (9 functions + 4 polymorphic variants).
- 6 top-level sync getters: `eol` / `platform` / `version` / `family`
  / `arch` / `exeExtension`.
- `OsType.get` (sync) — the upstream `type()` accessor lives in an
  `OsType` submodule because `type` is reserved at the top level of a
  ReScript module.
- 2 async getters: `locale` / `hostname` (return
  `promise<Nullable.t<string>>`).
- 4 polymorphic variants matching the upstream string-literal types:
  `platform` (10 variants), `osType` (5 variants), `arch` (11
  variants), `family` (`unix` / `windows`).
- Runnable example
  [`examples/plugin-os-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-os-demo)
  exercising the full surface (7 sync getters + 2 async getters)
  from button-driven UI with polymorphic-variant decoders.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-os ^2.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-os-types.yml` /
  `tests-plugin-os-runtime.yml`, plus `release.yml` recognition of
  the `plugin-os-v*` tag prefix and a `plugin-os` entry in the
  `tests-coverage.yml` matrix.
