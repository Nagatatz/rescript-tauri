# Requirements: examples/plugin-log-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-015 |
| 作業タイトル | examples/plugin-log-demo |
| 作成日 | 2026-05-11 |
| 関連 steering | 003 (user guide), 055 (本体実装), 014 (clipboard-manager-demo 雛形パターン), 008 (plugin-shell-demo 雛形元) |

---

## 1. 背景

`@rescript-tauri/plugin-log` は本体実装・user guide・CHANGELOG・CI 完備、`examples/plugin-log-demo/` のみ未存在。

## 2. 目的

plugin-log の全公開 API を Tauri 2.x デスクトップアプリ上から呼び出せる demo を提供する。

## 3. スコープ

### 3.1 含めるもの (in-scope)

| 関数 / モジュール | デモ表現 |
|---|---|
| `error` / `warn` / `info` / `debug` / `trace` | 5 ボタン、各レベルでサンプルメッセージを送信 |
| `attachLogger(callback)` | サブスクライブ→受信した `recordPayload` を result pane に追記 |
| `attachConsole()` | サブスクライブ→JS console に出力 |
| `unlisten` (戻り値) | "Detach loggers" ボタンで両方の unlisten を呼ぶ |
| `LogLevel` 定数 | 受信した `level: int` を `error` / `warn` / `info` / `debug` / `trace` に変換して表示 |
| `recordPayload` / `logOptions` 型 | 型レベル参照 |

共有ファイル変更:
- root `Cargo.toml` workspace member
- `docs/repository-structure.md` (§1 + §3)
- `sphinx-docs/user/plugin-log.md` の "See also" に live demo
- `packages/plugin-log/CHANGELOG.md` の `Added` 追記 / `Deferred` 削除
- `.github/workflows/examples-build.yml` に build / cargo check の 2 step

### 3.2 含めないもの (out-of-scope)

- Rust 側カスタム `targets` 設定（File / Webview / Stdout / LogDir）— 上流の default で十分
- npm publish 実行
- 翻訳 .po 更新

## 4. 受け入れ基準

- [ ] `examples/plugin-log-demo/` が plugin-shell-demo 雛形と同じファイル構成
- [ ] `src/App.res` に全 5 log 関数 + attachLogger + attachConsole + unlisten 呼び出しを wire
- [ ] `capabilities/default.json` に `log:default` permission
- [ ] root `Cargo.toml` に登録
- [ ] `pnpm --filter plugin-log-demo build` 成功
- [ ] docs / CI / CHANGELOG / user guide cross-link 確立
- [ ] tasklist 全タスク `[x]` で main merge 完了

## 5. リスク

- log の Rust 側 default では `Stdout` 等にしか出ない可能性 — webview 経由の `attachConsole` でブラウザ console に流せれば十分
- 並列衝突は最小限（新規 example ディレクトリ中心）
