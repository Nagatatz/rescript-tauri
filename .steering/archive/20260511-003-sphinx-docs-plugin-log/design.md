# Design: sphinx-docs/user/plugin-log.md

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-003 |
| 関連 | requirements.md, tasklist.md |
| 参考スタイル | `sphinx-docs/user/plugin-fs.md`, `sphinx-docs/user/plugin-dialog.md` |

## 1. ページ構造

`plugin-fs.md` の構造に厳密準拠する:

```
# `@rescript-tauri/plugin-log`

(イントロ 1〜2 段落)

```{note}
Status: Phase 2+, awaiting first npm publish.
```

## Install
  - JS 側 pnpm add コマンド
  - peerDeps 説明
  - rescript.json dependencies 追記
  - Rust 側 Cargo.toml + Builder 登録（targets サンプル）

## Capabilities
  - capability JSON

## Minimal example
  - ReScript コードブロック

## Public API
  - 関数表
  - LogLevel 節
  - logOptions / recordPayload 節
  - attachLogger / attachConsole 節

## Pitfalls
  - LogLevel suffix 命名理由
  - attachLogger は Tauri Event 経由（Mock 時の注意）

## Compatibility
  - 表

## See also
  - README link
  - source link
  - 上流 docs link
```

## 2. セクション別設計

### 2.1 Intro

```markdown
# `@rescript-tauri/plugin-log`

ReScript bindings for the [Tauri 2.x logging
plugin](https://v2.tauri.app/plugin/logging/) — 5 log levels
(`error` / `warn` / `info` / `debug` / `trace`) plus log-stream
subscription via `attachLogger` and `attachConsole`.
```

### 2.2 Status note

`plugin-dialog.md` と同じ文言テンプレートを `plugin-log-v0.1.0` 用に書き換え。

### 2.3 Install

- `pnpm add @rescript-tauri/plugin-log @tauri-apps/plugin-log`
- peerDeps: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-log ^2.0.0`
- `rescript.json` の `dependencies` に `@rescript-tauri/core` + `@rescript-tauri/plugin-log` を追加
- Rust 側:
  ```toml
  [dependencies]
  tauri-plugin-log = "2"
  ```
  ```rust
  fn main() {
      tauri::Builder::default()
          .plugin(
              tauri_plugin_log::Builder::new()
                  .targets([
                      tauri_plugin_log::Target::new(tauri_plugin_log::TargetKind::Stdout),
                      tauri_plugin_log::Target::new(tauri_plugin_log::TargetKind::Webview),
                  ])
                  .level(log::LevelFilter::Info)
                  .build(),
          )
          .run(tauri::generate_context!())
          .expect("error while running app");
  }
  ```
  - 「`Stdout` / `Webview` / `LogDir` の 3 target が定番」と 1 文添える

### 2.4 Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "log:default"
  ]
}
```

`log:default` で全 log API が許可される旨を 1 文。

### 2.5 Minimal example

```rescript
open RescriptTauriPluginLog

let bootstrap = async () => {
  let _unlisten = await PluginLog.attachConsole()
  await PluginLog.info(
    "App started",
    ~options={file: "Main.res", line: 1},
  )
}
```

- `attachConsole` で Rust 側 log を JS console に流す
- 戻り値の `unlisten` で detach 可能（解説 1 文）

### 2.6 Public API

#### 2.6.1 関数表

| Function | Returns | Notes |
|---|---|---|
| `error` | `promise<unit>` | Log at error (5) |
| `warn` | `promise<unit>` | Log at warn (4) |
| `info` | `promise<unit>` | Log at info (3) |
| `debug` | `promise<unit>` | Log at debug (2) |
| `trace` | `promise<unit>` | Log at trace (1) |
| `attachLogger` | `promise<unlisten>` | Subscribe via callback |
| `attachConsole` | `promise<unlisten>` | Stream to JS console |

#### 2.6.2 LogLevel 節

```rescript
PluginLog.LogLevel.trace   // 1
PluginLog.LogLevel.debug_  // 2
PluginLog.LogLevel.info_   // 3
PluginLog.LogLevel.warn_   // 4
PluginLog.LogLevel.error_  // 5
```

`recordPayload.level` と比較する用途、または将来 level filter API が追加された場合の引数として使用する。

#### 2.6.3 logOptions / recordPayload 節

`logOptions` の 3 フィールドの意味を表または箇条書きで示す。`recordPayload` は `attachLogger` の callback 引数として届く `{level, message}`。

#### 2.6.4 attachLogger / attachConsole 節

```rescript
let unlisten = await PluginLog.attachLogger(record => {
  let label = switch record.level {
  | l when l === PluginLog.LogLevel.error_ => "ERROR"
  | l when l === PluginLog.LogLevel.warn_ => "WARN"
  | _ => "INFO"
  }
  Console.log(label ++ ": " ++ record.message)
})
// ...
unlisten()
```

- Tauri Event (`log://log`) 経由で配信される旨を補足
- detach は `unlisten()` を 1 回呼び出す

### 2.7 Pitfalls

#### 2.7.1 `LogLevel` の suffix 命名

`debug` / `info` / `warn` / `error` は ReScript の JS 出力で `$$debug` / `$$info` / `$$warn` / `$$error` にエスケープされるため、`LogLevel` 内では `debug_` / `info_` / `warn_` / `error_` の suffix 付き名で公開している。`trace` のみ衝突なしで素のまま。

#### 2.7.2 `attachLogger` / `attachConsole` のテストモック

両関数は upstream で `__TAURI_INTERNALS__.transformCallback` を通じて Tauri Event を購読するため、テストではこの globals を stub する必要がある（`Mocks.mockIPC` だけでは不足）。実例は `packages/plugin-log/tests/runtime/plugin_log.test.mjs` を参照。

### 2.8 Compatibility 表

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-log` | `^2.0.0` (peer) |
| Rust `tauri-plugin-log` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

### 2.9 See also

- Source: `packages/plugin-log` (GitHub link)
- Upstream docs: `https://v2.tauri.app/plugin/logging/`
- README: `packages/plugin-log/README.md`
- (Live demo は **未追加** なのでリンクしない。CHANGELOG に "Deferred to follow-up sub-steerings" として明示済み)

## 3. 周辺ドキュメント更新

### 3.1 `sphinx-docs/user/index.md`

- "Phase 2 packages" 表に行追加:
  ```
  | `@rescript-tauri/plugin-log` | Structured logging (5 levels + log-stream listeners) | [plugin-log](plugin-log.md) |
  ```
- toctree に `plugin-log` を追加（`plugin-notification` と `schema` の間）

### 3.2 `sphinx-docs/user/installation.md`

- 末尾 note の plugin-log 削除、残るリストを更新:
  ```
  Dedicated user guides for `@rescript-tauri/plugin-shell`,
  `@rescript-tauri/plugin-notification`, `@rescript-tauri/plugin-os`,
  `@rescript-tauri/plugin-clipboard-manager`, and
  `@rescript-tauri/plugin-http` are scheduled for follow-up
  sub-steerings.
  ```
- 既存の install コマンド行はそのまま（変更なし）
- See ガイドへのリンク文の plugin リストに plugin-log を追加:
  ```
  See the [plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
  [plugin-notification](plugin-notification.md), [plugin-log](plugin-log.md),
  and [schema](schema.md) guides for the matching ReScript / Rust /
  capability setup.
  ```

## 4. 検証戦略

- `pnpm run check` — Biome は `.md` 対象外なので diff 起因の警告は出ないはず。安全側で確認
- `pnpm --recursive build` — ドキュメント変更のみだが、CI 整合性を取るため実行
- `grep -n "plugin-log" sphinx-docs/user/installation.md` — follow-up note から削除されていることを確認
- ローカル sphinx build (`cd sphinx-docs && make html`) — Python 環境がある場合のみ実施、なければ CI に委譲

## 5. ロールバック条件

- 文体が他ガイドと著しく乖離する場合は再起草
- sphinx ビルドが壊れる場合は該当箇所を revert
