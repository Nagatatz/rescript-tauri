# 要件定義: `@rescript-tauri/plugin-os`

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-056-plugin-os` |
| 作成日 | 2026-05-09 |

## 1. ゴール

`@tauri-apps/plugin-os` v2.3.2 (121 行 / 11 export) の **stable public surface 100%** を `@rescript-tauri/plugin-os` 独立パッケージとして提供する。

## 2. 対象 API

**型 (4 polymorphic variants):**
- `platform` — 10 OS バリアント (linux / macos / ios / ... / windows)
- `osType` — 5 バリアント
- `arch` — 11 バリアント
- `family` — `unix` / `windows`

**関数 (9):**
- `eol(): string` (sync)
- `platform(): platform` (sync)
- `version(): string` (sync)
- `family(): family` (sync)
- `type(): osType` (sync) — ReScript 予約語のため **`osType_` にリネーム**して公開
- `arch(): arch` (sync)
- `exeExtension(): string` (sync)
- `locale(): promise<Nullable.t<string>>` (async)
- `hostname(): promise<Nullable.t<string>>` (async)

## 3. 設計判断

- 7 つの sync 関数は `window.__TAURI_OS_PLUGIN_INTERNALS__` から読み取り（IPC ではない）。テストではこの globals を stub。
- `type` は ReScript の予約語のため、ReScript 側では `osType_` で公開（`@module` external で JS 側名を `"type"` に固定）。
- `locale` と `hostname` は IPC (`plugin:os|locale` / `plugin:os|hostname`) 経由で動作。

## 4. 完了条件

`plugin-shell` / `plugin-notification` / `plugin-log` と同じ:
- 100% 公開シンボルカバー
- 専用 CI 2 件 + matrix + release.yml
- ドキュメント更新
- monorepo build + test 全件 pass
