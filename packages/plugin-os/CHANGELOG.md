# Changelog

All notable changes to **`@rescript-tauri/plugin-os`** are documented
in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Bindings for `@tauri-apps/plugin-os` v2.3.2 — 100% of the stable
  public surface (9 functions + 4 polymorphic variants).
- 7 sync getters: `eol` / `platform` / `version` / `family` /
  `osType_` / `arch` / `exeExtension`.
- 2 async getters: `locale` / `hostname` (return
  `promise<Nullable.t<string>>`).
- 4 polymorphic variants matching the upstream string-literal types:
  `platform` (10 variants), `osType` (5 variants), `arch` (11
  variants), `family` (`unix` / `windows`).
- The upstream `type()` function is renamed to `osType_()` because
  `type` is a reserved keyword in ReScript.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-os ^2.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-os-types.yml` /
  `tests-plugin-os-runtime.yml`, plus `release.yml` recognition of
  the `plugin-os-v*` tag prefix and a `plugin-os` entry in the
  `tests-coverage.yml` matrix.

### Deferred to follow-up sub-steerings

- Runnable example app (`examples/plugin-os-demo/`).
- sphinx-docs `user/plugin-os.md` page.
