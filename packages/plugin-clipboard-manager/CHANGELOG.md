# Changelog

All notable changes to **`@rescript-tauri/plugin-clipboard-manager`**
are documented in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## Unreleased

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
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-clipboard-manager ^2.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows:
  `tests-plugin-clipboard-manager-types.yml` /
  `tests-plugin-clipboard-manager-runtime.yml`, plus `release.yml`
  recognition of the `plugin-clipboard-manager-v*` tag prefix and a
  `plugin-clipboard-manager` entry in the `tests-coverage.yml`
  matrix.

### Deferred to follow-up sub-steerings

- Runnable example app (`examples/plugin-clipboard-manager-demo/`).
- sphinx-docs `user/plugin-clipboard-manager.md` page.
