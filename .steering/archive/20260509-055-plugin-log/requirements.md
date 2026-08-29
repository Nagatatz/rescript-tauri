# 要件定義: `@rescript-tauri/plugin-log` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-055-plugin-log` |
| 作成日 | 2026-05-09 |

## 1. ゴール

`@tauri-apps/plugin-log` v2.8.0 (138 行 / 10 export) の **stable public surface 100%** を `@rescript-tauri/plugin-log` 独立パッケージとして提供する。

## 2. 対象 API

**関数 (7):**
- `error` / `warn` / `info` / `debug` / `trace` — `(message, ~options=?) => promise<unit>`
- `attachLogger` — `(recordPayload => unit) => promise<unlisten>`
- `attachConsole` — `() => promise<unlisten>`

**型 (3):**
- `logOptions` — `{file?, line?, keyValues?}`
- `recordPayload` — `{level, message}` （`attachLogger` の callback payload）
- `unlisten` — `unit => unit` （`@tauri-apps/api/event` の `UnlistenFn` を再宣言。core の `Event.unlisten` と同型）

**Enum:**
- `logLevel` — Trace=1, Debug=2, Info=3, Warn=4, Error=5。`int` named constants として `LogLevel` モジュールで公開。

## 3. 設計判断

- IPC コマンドは `plugin:log|log` のみ。`attachLogger` / `attachConsole` は Tauri Event (`log://log`) 経由で動作。
- 関数名 `error` / `warn` / `info` / `debug` / `trace` は ReScript 予約語ではないが JS 出力で `$$error` 等にエスケープされる懸念あり → 検証して必要なら suffix 付き別名を提供。

## 4. 完了条件

`plugin-shell` / `plugin-notification` と同じ:
- 100% 公開シンボルカバー
- 専用 CI 2 件 + matrix + release.yml
- ドキュメント更新
- monorepo build + test 全件 pass
