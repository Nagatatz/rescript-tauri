# Design: sphinx-docs plugin-shell user guide

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-001 |
| 関連 | `requirements.md`, `packages/plugin-shell/{README.md, src/PluginShell.resi}`, `sphinx-docs/user/plugin-fs.md`, `sphinx-docs/user/plugin-dialog.md` |

---

## 1. アプローチ

既存の `plugin-fs.md` / `plugin-dialog.md` を雛形とし、章構成・MyST ディレクティブ・テーブル形式を踏襲する。新規執筆ではなくスタイル準拠の **派生** として扱うため、独自構造は持ち込まない。

## 2. ページ構成 (`sphinx-docs/user/plugin-shell.md`)

セクション順は plugin-fs.md と揃える:

```
# `@rescript-tauri/plugin-shell`
  ├ 概要 (1〜3 文)
  ├ ```{note}``` Phase 2 publish 予告ブロック
  ├ ## Install
  │   ├ pnpm add コマンド
  │   ├ peerDependencies の説明
  │   └ rescript.json への追加
  ├ ## Rust setup
  │   ├ Cargo.toml
  │   └ src-tauri/src/main.rs
  ├ ## Capabilities
  │   └ shell:default + scope/open 例
  ├ ## Minimal example
  │   └ openPath の単純呼び出し
  ├ ## Public API (表)
  ├ ## Running commands
  │   ├ Command.execute (完了待ち)
  │   ├ Command.spawn + Child (長時間ジョブ)
  │   └ Raw 変種 (Uint8Array.t)
  ├ ## Streaming output (event chaining)
  ├ ## Sidecar binaries
  ├ ## Opening paths / URLs
  ├ ## Pitfalls
  │   ├ openPath rename 理由
  │   ├ Uint8Array length アクセス
  │   └ scope 設定漏れ時のエラー挙動
  ├ ## Compatibility (表)
  └ ## See also
```

## 3. 各セクションの具体仕様

### 3.1 概要文 + note

```markdown
# `@rescript-tauri/plugin-shell`

ReScript bindings for the [Tauri 2.x shell
plugin](https://v2.tauri.app/plugin/shell/) — spawn child
processes, stream stdout / stderr, and open files / URLs with the
OS-default app.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-shell-v0.1.0`) is scheduled alongside
the other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-shell` via the source repository or a
workspace link.
```
```

### 3.2 Install / Rust setup

`plugin-fs.md` §Install と同型。`pnpm add @rescript-tauri/plugin-shell @tauri-apps/plugin-shell`、`rescript.json` の dependencies に `@rescript-tauri/plugin-shell` を追加。Rust 側は `tauri-plugin-shell = "2"` と `.plugin(tauri_plugin_shell::init())`。

### 3.3 Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:default",
    {
      "identifier": "shell:allow-execute",
      "allow": [{ "name": "ls", "cmd": "ls", "args": true }]
    },
    {
      "identifier": "shell:allow-open",
      "allow": [{ "url": "^https?://" }]
    }
  ]
}
```

scope / open regex が upstream 仕様（`https://v2.tauri.app/plugin/shell/#scope-and-permissions`）と一致するよう、コメント付きで提示する。

### 3.4 Minimal example

```rescript
open RescriptTauriPluginShell

await PluginShell.openPath("https://tauri.app/")
```

`openPath` は `promise<unit>`。失敗時は upstream が reject する旨を 1 文添える。

### 3.5 Public API 表

`packages/plugin-shell/README.md` の Public API テーブルを **そのまま転載しない** で、エンドユーザー視点で再編成:

| Symbol | Returns | Purpose |
|---|---|---|
| `openPath` | `promise<unit>` | Open URL / path with OS default app |
| `Command.create` / `sidecar` | `Command.t<string>` | Build a UTF-8 command |
| `Command.createRaw` / `sidecarRaw` | `Command.t<Uint8Array.t>` | Build a bytes command |
| `Command.execute` | `promise<childProcess<'o>>` | Run to completion, collect output |
| `Command.spawn` | `promise<Child.t>` | Start in background, get handle |
| `Command.onClose` / `onError` | `Command.t<'o>` | Subscribe to lifecycle events |
| `Command.onStdoutData` / `onStderrData` | `Command.t<'o>` | Subscribe to streamed data |
| `Command.removeAllListeners` | `Command.t<'o>` | Detach Command-level listeners |
| `Child.pid` / `kill` / `write` | `int` / `promise<unit>` | Child process accessors |
| `EventEmitter.*` | `t<'events>` | 9 generic methods for low-level subscription |

### 3.6 Running commands

3 つの例を示す:

1. `Command.execute` で 1 ショット実行（README §Quick example の `listFiles` を流用）
2. `Command.spawn` + `Child.write` + `Child.kill` で対話的に使う例
3. `Command.createRaw` + `TypedArray.length` で生バイトを扱う例

### 3.7 Streaming output

README の `tail` 例を拡張し、`onClose` の payload (`{code, signal}`) を `Nullable.toOption` で取り出す書き方も併記する。

### 3.8 Sidecar binaries

`Command.sidecar("my-sidecar", ~args=[...])` の最小例 + `tauri.conf.json > bundle > externalBin` の説明を 2〜3 行で。

### 3.9 Opening paths / URLs

`openPath` の `~openWith` 例（`Shell.openPath("/tmp/note.txt", ~openWith="firefox")`）。scope の `open` regex に一致しないと reject する旨を注記。

### 3.10 Pitfalls

3 つの落とし穴を列挙:

- **`openPath` の rename**: upstream は `open` だが ReScript 予約語との衝突回避。
- **`Uint8Array.t` の length**: `plugin-fs.md` §Pitfalls と同じ表記で `TypedArray.length` を案内。
- **scope 漏れ**: capability に program を allowlist 追加していないと spawn 時にエラー。`shell:allow-execute` の `name` 一致が必要。

### 3.11 Compatibility 表

`packages/plugin-shell/README.md` §Compatibility と一致させる:

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-shell` | `^2.3.0` (peer) |
| Rust `tauri-plugin-shell` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

### 3.12 See also

```markdown
- Source:
  [`packages/plugin-shell`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-shell)
- Upstream docs:
  [Tauri 2.x shell plugin](https://v2.tauri.app/plugin/shell/)
- [`@rescript-tauri/core` user guide](installation.md)
```

`examples/plugin-shell-demo` は未存在のため live demo 行は **入れない**。後続 steering で example を追加した時点でこのセクションに追記する。

## 4. `sphinx-docs/user/index.md` の変更

### 4.1 Phase 2 packages テーブル

```markdown
| Package | Purpose | Guide |
|---|---|---|
| `@rescript-tauri/plugin-fs` | Filesystem operations (read / write / dir / stat) | [plugin-fs](plugin-fs.md) |
| `@rescript-tauri/plugin-dialog` | Native dialogs (open / save / message / ask / confirm) | [plugin-dialog](plugin-dialog.md) |
| `@rescript-tauri/plugin-shell` | Spawn child processes, open URLs / files with OS default | [plugin-shell](plugin-shell.md) |
| `@rescript-tauri/schema` | Layer 3 typed IPC via `rescript-schema` | [schema](schema.md) |
```

### 4.2 toctree

```markdown
```{toctree}
:hidden:
:maxdepth: 2

installation
quickstart
configuration
plugin-fs
plugin-dialog
plugin-shell
schema
changelog
```
```

`plugin-shell` を `plugin-dialog` と `schema` の間に挿入する（package 系を並べてから schema を最後）。

## 5. `docs/repository-structure.md` の更新

§5 末尾の以下の記述を変更:

**変更前:**
> **未追加のユーザーガイド:** `user/plugin-shell.md`, `user/plugin-notification.md` は後続 sub-steering で追加予定（現状は各パッケージの `README.md` を参照）。

**変更後:**
> **未追加のユーザーガイド:** `user/plugin-notification.md` は後続 sub-steering で追加予定（現状は `packages/plugin-notification/README.md` を参照）。

`plugin-shell.md` の追加完了を反映し、`plugin-notification.md` のみ残す。

## 6. 影響範囲

| ファイル | 変更内容 |
|---|---|
| `sphinx-docs/user/plugin-shell.md` | 新規追加 |
| `sphinx-docs/user/index.md` | Phase 2 packages テーブル + toctree に 1 行追加 |
| `docs/repository-structure.md` | §5 末尾の「未追加のユーザーガイド」記述から `plugin-shell.md` を削除 |
| `sphinx-docs/locale/ja/**.po` | **本ステアリングでは触らない**（別 steering）|
| コード (`packages/`, `src/`) | 変更なし |

## 7. 検証

1. `pnpm run check`（Biome — `.md` は対象外なので影響無いことの確認）
2. CI 上で `doc-link-lint.yml` 相当の検証（相対リンクと upstream URL の正当性）
3. Sphinx ビルド (`sphinx-docs/Makefile`) を手元で実行可能だが、本ステアリングでは CI に委ねる（uv install を避けて disk pressure を回避）

## 8. ロールバック

ドキュメントのみの変更のため、問題があれば該当コミットを revert するだけで原状復帰可能。
