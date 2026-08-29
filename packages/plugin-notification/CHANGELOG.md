# Changelog

All notable changes to **`@rescript-tauri/plugin-notification`** are
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

- Bindings for `@tauri-apps/plugin-notification` v2.3.3 — 100% of the
  stable public surface (15 functions + 8 records + 1 polymorphic
  variant + `Schedule` module + `Importance` / `Visibility` `@unboxed`
  variants).
- 15 functions: `isPermissionGranted`, `requestPermission`,
  `sendNotification`, `sendNotificationText` (the upstream
  `Options | string` overload is split into two ReScript functions),
  `registerActionTypes`, `pending`, `cancel`, `cancelAll`,
  `active`, `removeActive`, `removeAllActive`, `createChannel`,
  `removeChannel`, `channels`, `onNotificationReceived`, `onAction`.
- `Schedule` module with `at` / `interval` / `every` static
  factories.
- `Importance.t` (`@unboxed` variant: `None` / `Min` / `Low` /
  `Default` / `High` with `@as(0)` … `@as(4)`) and `Visibility.t`
  (`@unboxed` variant: `Secret` / `Private` / `Public` with `@as(-1)`
  / `@as(0)` / `@as(1)`). Runtime representation is the bare integer
  so the variants are wire-compatible with upstream's
  `channel.importance` / `channel.visibility` / `options.visibility`
  fields.
- `notificationPermission` polymorphic variant
  (`#default` / `#granted` / `#denied`).
- Type-level signature test
  (`tests/plugin_notification_signature.res`) and vitest runtime
  tests (`tests/runtime/plugin_notification.test.mjs`).
- Runnable example
  [`examples/plugin-notification-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-notification-demo)
  exercising the full surface (permission / send / pending /
  active / action types / channels / live listeners) from
  button-driven UI.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-notification ^2.3.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-notification-types.yml` /
  `tests-plugin-notification-runtime.yml`, plus `release.yml`
  recognition of the `plugin-notification-v*` tag prefix and a
  `plugin-notification` entry in the `tests-coverage.yml` matrix.

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
### Changed
### Fixed
### Removed

-->
