# Changelog

All notable changes to **`@rescript-tauri/plugin-http`** are
documented in this file.

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

- Bindings for `@tauri-apps/plugin-http` v2.5.9 — 100% of the
  stable public surface (1 function + 5 record / variant types).
- `fetch(input, ~init=?)` — polymorphic Web-Fetch wrapper that
  bypasses webview CORS by routing through the Rust side. Returns
  `'response` (the DOM `Response` type is intentionally not bound).
- `proxy<'proxyValue>` (parameterized over the proxy value type so
  `string` / `proxyConfig` both type-check), `proxyConfig`,
  `basicAuth`, `clientOptions<'proxyValue>`, and
  `dangerousSettings` records covering the Tauri-specific options.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-http ^2.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-http-types.yml` /
  `tests-plugin-http-runtime.yml`, plus `release.yml` recognition
  of the `plugin-http-v*` tag prefix and a `plugin-http` entry in
  the `tests-coverage.yml` matrix.
- Runnable example app
  [`examples/plugin-http-demo/`](../../examples/plugin-http-demo)
  — 4 step buttons (GET, POST, clientOptions, headers/status)
  driving JSONPlaceholder; included in the `examples-build` CI
  matrix on Linux / macOS / Windows (steering 20260511-009).
- sphinx-docs `user/plugin-http.md` page (steering 20260511-007).

### Deferred to follow-up sub-steerings

- Typed Web Fetch API surface (`Request` / `Response` / etc.).
