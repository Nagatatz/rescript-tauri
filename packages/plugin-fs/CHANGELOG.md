# Changelog

All notable changes to **`@rescript-tauri/plugin-fs`** are
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

- 14 single-shot filesystem functions under `PluginFs`:
  `readTextFile` / `writeTextFile` / `readFile` / `writeFile` /
  `exists` / `remove` / `rename` / `mkdir` / `readDir` / `stat` /
  `lstat` / `truncate` / `copyFile` / `size`.
- Option records (`readFileOptions`, `writeFileOptions`,
  `mkdirOptions`, `removeOptions`, `renameOptions`,
  `copyFileOptions`, `statOptions`, `existsOptions`,
  `readDirOptions`, `truncateOptions`) plus `fileInfo` /
  `dirEntry` result types.
- `PluginFs.BaseDirectory` re-exported from
  `@rescript-tauri/core`'s `Path.BaseDirectory.t` so the same
  `private int` enum is shared across packages.
- Type-level signature test (`tests/plugin_fs_signature.res`) and
  vitest runtime tests (`tests/runtime/plugin_fs.test.mjs`, 6
  cases).
- Runnable example
  [`examples/plugin-fs-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-fs-demo)
  exercising the full surface in five UI steps (setup / read /
  list / modify / cleanup) inside the
  `$APPLOCALDATA/plugin-fs-demo/` sandbox.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-fs ^2.5.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-fs-types.yml` /
  `tests-plugin-fs-runtime.yml`, plus `release.yml` recognition of
  the `plugin-fs-v*` tag prefix.

### Deferred to follow-up sub-steerings

- `FileHandle` class (`open` / `create` + instance methods)
- `watch` / `watchImmediate` + `WatchEvent` variant tree
- `readTextFileLines` (AsyncIterable return)
- iOS-only security-scoped resource APIs

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
### Changed
### Fixed
### Removed

-->
