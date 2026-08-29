# Changelog

All notable changes to **`@rescript-tauri/schema`** are documented
in this file.

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

- `Schema.fromSchemas` — declares a typed
  `Core.Command.t<'args, 'result>` from a single `S.t<'args>` +
  `S.t<'result>` pair. Encoding goes through
  `S.reverseConvertToJsonOrThrow`; decoding through
  `S.parseJsonOrThrow`, with `S.Raised` exceptions surfaced as
  `Error(DecodeError(message))` to match `Core.Command.invoke`'s
  error variant.
- `Schema.channelFromSchema` — schema-decoded
  `Core.Channel.t<'message>`.
- `Schema.eventFromSchema` — schema-decoded `Event.t<'payload>`.
- `Schema.toDecoder` — lower-level helper that returns the
  `Core.decoder<_>` used internally.
- `Schema.S` re-exports `RescriptSchema.S` for ergonomic access.
- Type-level signature test (`tests/schema_signature.res`) and
  vitest runtime tests (`tests/runtime/schema.test.mjs`, 5 cases).
- Runnable example
  [`examples/ipc-typed-with-schema`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/ipc-typed-with-schema)
  showing the same `greet` / `add` commands as
  `examples/ipc-typed/` written through `Schema.fromSchemas`, plus
  a record-shaped `summarize` command and a schema-decoded
  `count_to` channel.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `rescript-schema ^9.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`. `rescript-struct` is intentionally
  unsupported (deprecated upstream — RFC-0002 §2.1).
- GitHub Actions workflows: `tests-schema-types.yml` /
  `tests-schema-runtime.yml`, plus `release.yml` recognition of
  the `schema-v*` tag prefix.

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
### Changed
### Fixed
### Removed

-->
