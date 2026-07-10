# Changelog

All notable changes to **`@rescript-tauri/plugin-dialog`** are
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

- 8 native-dialog functions under `PluginDialog`:
  `openFile` / `openFiles` / `openDirectory` / `openDirectories` /
  `save` / `message` / `ask` / `confirm`.
- The TypeScript-level conditional return type of upstream's
  `open(options)` is unrolled into four ReScript functions so the
  result type stays static. The corresponding `multiple` /
  `directory` flags are intentionally not exposed in `openOptions`
  — pick the function that matches the shape you need.
- Option records (`openOptions`, `saveOptions`, `messageOptions`,
  `confirmOptions`, `dialogFilter`) plus `pickerMode`,
  `fileAccessMode`, `dialogKind`, `messageButtons` polymorphic
  variants and a `messageResult` string alias.
- Type-level signature test
  (`tests/plugin_dialog_signature.res`) and vitest runtime tests
  (`tests/runtime/plugin_dialog.test.mjs`, 10 cases).
- Runnable example
  [`examples/plugin-dialog-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-dialog-demo)
  driving every public function from one button each.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-dialog ^2.7.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-dialog-types.yml` /
  `tests-plugin-dialog-runtime.yml`, plus `release.yml`
  recognition of the `plugin-dialog-v*` tag prefix.

### Deferred to follow-up sub-steerings

- `MessageDialogButtonsYesNoCustom` and other custom-button label
  variants for `message`.

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
### Changed
### Fixed
### Removed

-->
