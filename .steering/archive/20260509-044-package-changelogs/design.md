# Design: Per-package CHANGELOGs

## 1. 共通テンプレート (Keep a Changelog 1.1.0)

```markdown
# Changelog

All notable changes to **`@rescript-tauri/<name>`** are documented
in this file.

The format is based on
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and
this package adheres to
[Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- ...

### Changed

- ...

### Fixed

- ...

### Removed

- ...

<!-- Template for new releases (do not remove)

## x.y.z (YYYY-MM-DD)

### Added
### Changed
### Fixed
### Removed

-->
```

セクション順 (`Added` / `Changed` / `Fixed` / `Removed`) と空節は
それぞれ "(none yet)" でなくセクション自体を省略するスタイルを採用
(より簡潔)。`Removed` は initial release では基本不要なため省略可。

## 2. ファイルごとの内容

### 2.1 `packages/core/CHANGELOG.md`

Unreleased セクションは sphinx-docs/user/changelog.md の Phase 1
記述を移植・整理。

```markdown
## Unreleased

### Added

- 12 Phase-1 ReScript modules under `src/`, every one paired with a
  `.resi` signature file and Tauri-upstream doc-comment links:
  - `Core` — IPC bridge: `Raw.invoke`, typed `Command`
    (`make` / `invoke` / `invokeExn`), streaming `Channel`,
    `convertFileSrc`. Exposes a public `decoder<'value>` type alias
    for downstream packages.
  - `Event` — typed pub/sub (`make` / `listen` / `once` / `emit` /
    `emitTo`) with an `eventTarget` discriminator. Listener
    callbacks receive `result<event<'payload>, string>` so decode
    failures are explicit.
  - `Window` — opaque handle plus ~80 instance / static methods
    (theme, cursorIcon, monitor helpers, drag/resize, six `on*`
    handlers, ...).
  - `Webview` — opaque handle, 14 instance methods, and a
    `dragDropEvent` variant.
  - `WebviewWindow` — combined Window + Webview surface with
    zero-cost `asWindow` / `asWebview` casts.
  - `Menu` — full menu hierarchy (`MenuItem`, `CheckMenuItem`,
    `IconMenuItem`, `PredefinedMenuItem`, `Submenu`, `Menu`) with
    `itemKind` and `predefinedItem` variants.
  - `Tray` — `TrayIcon` opaque handle + `trayIconEvent` variant
    (`Click` / `DoubleClick` / `Enter` / `Move` / `Leave`).
  - `Path` — 31 path helpers + `BaseDirectory` enum.
  - `App` — `getName`, `getVersion`, `getTauriVersion`,
    `defaultWindowIcon`, `setTheme`, ... (stable subset).
  - `Image` — RGBA-image opaque handle (`fromPath` / `fromBytes` /
    `new_` / `rgba` / `size`).
  - `Dpi` — `LogicalSize`, `PhysicalSize`, `LogicalPosition`,
    `PhysicalPosition`, `Size`, `Position` as opaque JS-class
    bindings.
  - `Mocks` — `mockIPC`, `mockWindows`, `clearMocks`.
- `Tauri.res` umbrella module re-exporting `Core`, `Event`,
  `Window`, `Webview`, `WebviewWindow` (PRD §10 row 1, confirmed
  2026-05-09).
- Type-level signature tests under `tests/*_signature.res` and
  vitest runtime tests under `tests/runtime/*.test.mjs`.
- Four buildable examples gated by 3-OS CI (`hello-world`,
  `window-management`, `ipc-typed`, `streaming-ipc`).
- GitHub Actions workflows for build, type-level tests, runtime
  tests, examples build, doc-link lint, Tauri / ReScript
  compatibility nightlies, lint-format, coverage, and release.
```

### 2.2 `packages/schema/CHANGELOG.md`

```markdown
## Unreleased

### Added

- `Schema.fromSchemas` — declares a typed
  `Core.Command.t<'args, 'result>` from a single `S.t<'args>` +
  `S.t<'result>` pair. Encoding goes through
  `S.reverseConvertToJsonOrThrow`; decoding through
  `S.parseJsonOrThrow`, with `S.Raised` exceptions surfaced as
  `Error(DecodeError(message))`.
- `Schema.channelFromSchema` — schema-decoded
  `Core.Channel.t<'message>`.
- `Schema.eventFromSchema` — schema-decoded `Event.t<'payload>`.
- `Schema.toDecoder` — lower-level `S.t<'value>` →
  `Core.decoder<'value>` helper.
- `Schema.S` re-exports `RescriptSchema.S` for ergonomic access.
- Type-level signature test (`tests/schema_signature.res`) and
  vitest runtime tests (`tests/runtime/schema.test.mjs`, 5 cases).
- Runnable example `examples/ipc-typed-with-schema/` showing the
  same `greet` / `add` commands as `examples/ipc-typed/` written
  through `Schema.fromSchemas`, plus a record-shaped `summarize`
  command and a schema-decoded `count_to` channel.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `rescript-schema ^9.0.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`. `rescript-struct` is intentionally
  unsupported (deprecated upstream — RFC-0002 §2.1).
- GitHub Actions workflows: `tests-schema-types.yml` /
  `tests-schema-runtime.yml`, plus `release.yml` recognition of
  the `schema-v*` tag prefix.
```

### 2.3 `packages/plugin-fs/CHANGELOG.md`

```markdown
## Unreleased

### Added

- 14 single-shot filesystem functions under `PluginFs`:
  `readTextFile` / `writeTextFile` / `readFile` / `writeFile` /
  `exists` / `remove` / `rename` / `mkdir` / `readDir` / `stat` /
  `lstat` / `truncate` / `copyFile` / `size`.
- Option records (`readFileOptions`, `writeFileOptions`,
  `mkdirOptions`, `removeOptions`, `renameOptions`,
  `copyFileOptions`, `statOptions`, `existsOptions`,
  `readDirOptions`, `truncateOptions`) plus `fileInfo` / `dirEntry`
  result types.
- `PluginFs.BaseDirectory` re-exported from
  `@rescript-tauri/core`'s `Path.BaseDirectory.t` so the same
  `private int` enum is shared across packages.
- Type-level signature test (`tests/plugin_fs_signature.res`) and
  vitest runtime tests (`tests/runtime/plugin_fs.test.mjs`,
  6 cases).
- Runnable example `examples/plugin-fs-demo/` exercising the full
  surface in five UI steps (setup / read / list / modify /
  cleanup).
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
```

### 2.4 `packages/plugin-dialog/CHANGELOG.md`

```markdown
## Unreleased

### Added

- 8 native-dialog functions under `PluginDialog`:
  `openFile` / `openFiles` / `openDirectory` / `openDirectories` /
  `save` / `message` / `ask` / `confirm`.
- The TypeScript-level conditional return type of upstream's
  `open(options)` is unrolled into four ReScript functions so
  result types stay static.
- Option records (`openOptions`, `saveOptions`, `messageOptions`,
  `confirmOptions`, `dialogFilter`) plus `pickerMode`,
  `fileAccessMode`, `dialogKind`, `messageButtons` polymorphic
  variants and a `messageResult` string alias.
- Type-level signature test (`tests/plugin_dialog_signature.res`)
  and vitest runtime tests (`tests/runtime/plugin_dialog.test.mjs`,
  10 cases).
- Runnable example `examples/plugin-dialog-demo/` driving every
  public function from one button each.
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-dialog ^2.7.0`, `rescript >=12.0.0`,
  `@rescript/core >=1.6.0`.
- GitHub Actions workflows: `tests-plugin-dialog-types.yml` /
  `tests-plugin-dialog-runtime.yml`, plus `release.yml`
  recognition of the `plugin-dialog-v*` tag prefix.

### Deferred to follow-up sub-steerings

- `MessageDialogButtonsYesNoCustom` and other custom-button label
  variants for `message`.
```

## 3. README cross-link

各 README の See also 節に 1 行追加:

```markdown
- [Changelog](./CHANGELOG.md)
```

(配置場所: 既存 See also 節の先頭 — package-local リンクであり
GitHub 上で確実に解決するため最初に置く)。

## 4. `sphinx-docs/user/changelog.md` の更新

既存の Unreleased (core 単独) を以下のような構造に分割:

```markdown
# Changelog

```{note}
The Phase 1 / Phase 2 module sets are feature-complete in `main`.
First publishes (`v0.1.0`, `schema-v0.1.0`, `plugin-fs-v0.1.0`,
`plugin-dialog-v0.1.0`) are pending. Each package keeps its own
canonical changelog under `packages/<name>/CHANGELOG.md`; this
page collects the highlights for the pre-release state.
```

## `@rescript-tauri/core` (Unreleased)

Canonical: [`packages/core/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/core/CHANGELOG.md)

### Added

- (既存の Phase 1 リスト)

## `@rescript-tauri/schema` (Unreleased)

Canonical: [`packages/schema/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/schema/CHANGELOG.md)

### Added

- (Phase 2 schema ハイライト)

## `@rescript-tauri/plugin-fs` (Unreleased)

Canonical: [`packages/plugin-fs/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-fs/CHANGELOG.md)

### Added

- (Phase 2 plugin-fs ハイライト)

## `@rescript-tauri/plugin-dialog` (Unreleased)

Canonical: [`packages/plugin-dialog/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-dialog/CHANGELOG.md)

### Added

- (Phase 2 plugin-dialog ハイライト)
```

各パッケージのハイライトは package-local CHANGELOG より短く、
パッケージのコア機能を 3〜5 行程度で要約する。

## 5. 検証手順

1. 4 CHANGELOG が text-check (タブ無し / heading 階層 / 必須節)
2. README から `./CHANGELOG.md` 相対リンクが解決
3. sphinx-docs/user/changelog.md の絶対 GitHub URL が
   `packages/<pkg>/CHANGELOG.md` を指している
4. `pnpm --recursive build` / `pnpm --recursive test` 全件パス
   (ドキュメント変更のみで実コード非変更)

## 6. リスクと対応

| リスク | 対応 |
|---|---|
| 内容の誤記 / 既存 sphinx 文章との乖離 | 既存 sphinx-docs/user/changelog.md を base にして core 内容を書く |
| README リンクが npm で `./CHANGELOG.md` のまま broken | npm は `repository.directory` を尊重して相対リンクを解決するため OK |
| sphinx-docs/user/changelog.md の翻訳遅延 | 042 と同様、英語ソースのみ。日本語 .po は別 |
