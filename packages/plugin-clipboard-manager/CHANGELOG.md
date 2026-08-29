# Changelog

All notable changes to **`@rescript-tauri/plugin-clipboard-manager`**
are documented in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## 0.1.2 (2026-08-30)

Maintenance release — no runtime or API changes.

### Changed

- Bumped development dependencies to their latest patch / minor releases
  (@types/node 26.4.0, vitest 4.1.11, @vitest/coverage-v8 4.1.11, happy-
  dom 20.11.13, rescript 12.3.1). The published artifacts are
  unaffected.

## 0.1.1 (2026-06-10)

Maintenance release — no runtime or API changes.

### Changed

- Updated development dependencies to their latest patch / minor
  releases (ReScript 12.3, @rescript/core 1.6.1, vitest 4.1.8,
  @vitest/coverage-v8 4.1.8, happy-dom 20.10.2). The published
  artifacts are unaffected.

## 0.1.0 (2026-05-12)

### Added

- Bindings for `@tauri-apps/plugin-clipboard-manager` v2.3.2 — 100%
  of the stable public surface (6 functions + 1 record type).
- 6 functions: `writeText` / `readText` / `writeImage` / `readImage`
  / `writeHtml` / `clear`.
- `readImage` returns `RescriptTauriCore.Image.t` (the existing core
  image handle, reused via the `@rescript-tauri/core` peer
  dependency).
- `writeImage` accepts a polymorphic `'image` argument matching the
  upstream union (`string | Image | Uint8Array | ArrayBuffer |
  number[]`).
- `writeTextOptions` record type (`{label?: string}`).
- Runnable example
  [`examples/plugin-clipboard-manager-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-clipboard-manager-demo)
  exercising the full surface (text / image round-trip via
  `Image.t` / HTML / clear) from button-driven UI.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-clipboard-manager ^2.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows:
  `tests-plugin-clipboard-manager-types.yml` /
  `tests-plugin-clipboard-manager-runtime.yml`, plus `release.yml`
  recognition of the `plugin-clipboard-manager-v*` tag prefix and a
  `plugin-clipboard-manager` entry in the `tests-coverage.yml`
  matrix.
