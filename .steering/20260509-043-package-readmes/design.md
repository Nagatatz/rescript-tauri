# Design: Package READMEs (Phase 2 互換マトリクス整備)

## 1. 統一フォーマット

すべての README で以下のセクション順を採用:

```
# @rescript-tauri/<name>

(1 〜 2 行サマリ)

## Status
## Install (planned)
## Quick example
## Compatibility
## Public API
## See also
```

セクション名は固定。順序固定。

## 2. Compatibility テーブルの列構成

すべての README で同じ列構成を採用:

```markdown
| Component | Supported range |
|---|---|
| `@rescript-tauri/<name>` | `^0.1.0` (this package) |
| `@rescript-tauri/core` | (peer)                       ※ core README ではこの行は不要
| `@tauri-apps/api`       | `^2.0.0`                     ※ core 以外は (transitive) の注記つき
| (上流 plugin / schema) | `^X.Y.Z` (peer)              ※ 該当パッケージのみ
| `rescript`              | `>=12.0.0`                   |
| `@rescript/core`        | `>=1.6.0`                    |
| OS                      | Linux / macOS / Windows      |
```

**core**:
| Component | Supported range |
|---|---|
| `@rescript-tauri/core` | this package |
| `@tauri-apps/api` | `^2.0.0` (peer) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

**schema**:
| Component | Supported range |
|---|---|
| `@rescript-tauri/schema` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `rescript-schema` | `^9.0.0` (peer) |
| `@tauri-apps/api` | `^2.0.0` (transitive via core) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |

**plugin-fs**:
| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-fs` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-fs` | `^2.5.0` (peer) |
| `@tauri-apps/api` | `^2.0.0` (transitive via core) |
| Rust `tauri-plugin-fs` | `2.x` |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

**plugin-dialog**:
| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-dialog` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-dialog` | `^2.7.0` (peer) |
| `@tauri-apps/api` | `^2.0.0` (transitive via core) |
| Rust `tauri-plugin-dialog` | `2.x` |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## 3. ページごとの差分

### 3.1 `packages/core/README.md`

ほぼ全面書き換え。

```markdown
# @rescript-tauri/core

Production-ready ReScript bindings for Tauri 2.x's official JS SDK
(`@tauri-apps/api`). The **core** package of the rescript-tauri
monorepo, exposing the entire Tauri public API surface (IPC, Event,
Window, Webview, Menu, Tray, ...) from ReScript.

## Status

Phase 1 — feature-complete on `main` (12 modules + curated `Tauri`
re-export). Awaiting first npm publish (`v0.1.0`).

## Install (planned)

```bash
pnpm add @rescript-tauri/core @tauri-apps/api
```

Add to `rescript.json`:
... (既存形式踏襲) ...

## Quick example

```rescript
open RescriptTauriCore.Tauri

let greeting: string =
  await Core.Raw.invoke("greet", ~args={"name": "World"})

let win = Window.getCurrent()
await win->Window.setTitle("Hello, ReScript")
```

For the typed `Command` layer, channels, events, and full window /
webview / menu coverage, see the
[user guide](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/quickstart.md)
or the runnable
[examples](https://github.com/Nagatatz/rescript-tauri/tree/main/examples).

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/core` | this package |
| `@tauri-apps/api` | `^2.0.0` (peer) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## Public API

| Module | Purpose |
|---|---|
| `Tauri` | `open Tauri` re-export of the 5 most common modules |
| `Core` | IPC bridge — `Raw.invoke`, typed `Command`, streaming `Channel`, `convertFileSrc` |
| `Event` | Pub/sub event bus (`make`, `listen`, `once`, `emit`, `emitTo`) |
| `Window` | Window class — opaque handle + ~80 methods, full type set |
| `Webview` | Webview class — handle + 14 methods + drag-drop variant |
| `WebviewWindow` | Combined Window + Webview surface; `asWindow` / `asWebview` casts |
| `Menu` | Application menu hierarchy (`MenuItem` / `Submenu` / ...) |
| `Tray` | System tray icon (`TrayIcon`) |
| `Path` | Path utilities — 31 helpers + `BaseDirectory` enum |
| `App` | Application metadata + lifecycle |
| `Image` | RGBA-image opaque handle |
| `Dpi` | DPI-aware size and position |
| `Mocks` | Test helpers (`mockIPC`, `mockWindows`, `clearMocks`) |

## See also

- [User guide (English)](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/index.md)
- [Quick start](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/quickstart.md)
- [Functional design (内部設計, 日本語)](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md)
- Runnable examples:
  [`hello-world`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/hello-world),
  [`window-management`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/window-management),
  [`ipc-typed`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/ipc-typed),
  [`streaming-ipc`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/streaming-ipc)

## Development

(既存の development 節を維持 — pnpm filter コマンド)
```

### 3.2 `packages/schema/README.md`

既存 README を以下の差分で更新:

- Status: "under active development" → "Phase 2 — feature-complete on `main`. Awaiting first npm publish (`schema-v0.1.0`)."
- Compatibility matrix を 6 行版に拡張 (toolchain 行追加)
- 末尾の References 節を See also に整理:
  - `user/schema.md` (sphinx-docs)
  - `examples/ipc-typed-with-schema/` (絶対 URL)

Quick example の `s->S.field("name", S.string)` → `s.field("name", S.string)`
に修正 (rescript-schema 9.x の正しい記法。sphinx-docs/user/schema.md と
整合させる)。

### 3.3 `packages/plugin-fs/README.md`

差分:

- Status の文言は維持 ("Phase 2, first iteration. Awaiting first npm publish")
- Compatibility matrix を 7 行版に拡張 (Rust crate / toolchain 行追加)
- 落とし穴節を追加:
  - 単一フィールド record の punning
  - `TypedArray.length`
- See also 節:
  - `user/plugin-fs.md` (sphinx-docs)
  - `examples/plugin-fs-demo/`
  - 上流 plugin docs

### 3.4 `packages/plugin-dialog/README.md`

差分:

- Status: "deferred to follow-up sub-steerings" のうち
  - "A `plugin-dialog` example app" → 完了済 (steering 036)
  - "a dedicated CI job" → 完了済 (steering 041)
  に変更し、残るは "MessageDialogButtonsYesNoCustom 等のカスタム
  ボタンラベル" のみとする
- Compatibility matrix を 7 行版に拡張
- See also 節:
  - `user/plugin-dialog.md`
  - `examples/plugin-dialog-demo/`
  - 上流 plugin docs

## 4. リンク方針

README は npm 公開時に npm ページに表示される。npm 上では相対パスは
適切に解決されないため、**新規追加リンクは GitHub の絶対 URL を使う**。
既存の `../../docs/...` 相対リンクは npm でも「リポジトリ内ファイルへの
参照」として表示されるため、本 steering での既存リンクの一括書き換えは
行わず、Should スコープに留める。

新規追加リンクパターン:

```markdown
[user guide](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/<page>.md)
[examples/<demo>](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/<demo>)
```

## 5. 検証手順

1. 4 README を text-check (タブ無し、heading 階層、リンク URL の体裁)。
2. リンク先が main 上に存在することを確認:
   - `sphinx-docs/user/{plugin-fs,plugin-dialog,schema,quickstart,index}.md`
   - `examples/{plugin-fs-demo,plugin-dialog-demo,ipc-typed-with-schema,hello-world,window-management,ipc-typed,streaming-ipc}/`
3. `pnpm --recursive build` / `pnpm --recursive test` で regression
   が無いこと (実コード未変更のため自動的に通る)。
4. 互換マトリクスのバージョン値を package.json と一致させる (peer
   ranges を grep して目視確認)。

## 6. リスクと対応

| リスク | 対応 |
|---|---|
| README リンクが npm で broken | 新規リンクは GitHub 絶対 URL |
| 互換マトリクスのバージョン値が package.json と不整合 | 各 package.json の peerDependencies を grep してから記載 |
| sphinx-docs と README で同じ落とし穴を重複記載 | README は要点のみ、詳細は sphinx-docs ガイドへ誘導 |
