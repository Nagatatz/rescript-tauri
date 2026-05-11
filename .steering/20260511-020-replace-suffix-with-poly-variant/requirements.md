# Requirements: 予約語回避 suffix を polymorphic variant に置換

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260511-020 |
| 作成日 | 2026-05-11 |
| 起点 | リファクタリング監査 候補 #3（命名統一） |
| **破壊的変更** | **YES** — pre-1.0 のため許容 |

## 背景

複数の plugin が ReScript の予約語または JS 出力の `$$xxx` エスケープを避けるため、公開シンボルに `_` suffix を付けている:

| パッケージ | シンボル | suffix の理由 |
|---|---|---|
| plugin-log | `LogLevel.error_` / `warn_` / `info_` / `debug_` | `error` / `warn` / `info` / `debug` が JS 出力で `$$error` 等にエスケープされる |
| plugin-notification | `Importance.default_` | `default` が JS 出力でエスケープされる |
| plugin-notification | `Visibility.private_` / `public_` | `private` が ReScript 予約語、`public` が JS でエスケープされる |
| plugin-os | `osType_()` | `type` が ReScript 予約語 |

これらはすべて int 定数 module または関数名であり、polymorphic variant タグ（`#trace` / `#default` 等）として表現すれば suffix `_` が不要になる。ReScript の polymorphic variant は `@as(N)` 属性で数値 enum として serialize できるため、IPC ペイロード互換性も保てる。

## ゴール

- 4 つの `_` suffix 付きシンボルを polymorphic variant か module 入れ子に置き換え
- 既存テスト・examples を新 API に追従
- ドキュメント（resi の doc comment / sphinx-docs の例）を更新

## スコープ

### 含むもの

#### 1. PluginLog
- `module LogLevel` (int 定数 5 件) を削除
- 新規 `type level = [@as(1) #trace | @as(2) #debug | @as(3) #info | @as(4) #warn | @as(5) #error]` を追加
- `recordPayload.level: int` → `recordPayload.level: level`
- `tests/runtime/plugin_log.test.mjs` を新 API に追従
- `tests/plugin_log_signature.res` の `_check_` 更新

#### 2. PluginNotification — Importance
- `module Importance` (int 定数 5 件) を削除
- 新規 `type importance = [@as(0) #none | @as(1) #min | @as(2) #low | @as(3) #default | @as(4) #high]` を追加
- `channel.importance?: int` → `channel.importance?: importance`

#### 3. PluginNotification — Visibility
- `module Visibility` (int 定数 3 件) を削除
- 新規 `type visibility = [@as(-1) #secret | @as(0) #private | @as(1) #public]` を追加
- `channel.visibility?: int` → `channel.visibility?: visibility`
- `options.visibility?: int` → `options.visibility?: visibility`
- `tests/runtime/plugin_notification.test.mjs` の Importance / Visibility 定数アサーションを polymorphic variant 比較に変更
- `tests/plugin_notification_signature.res` の `_check_` 更新

#### 4. PluginOs
- `external osType_` の関数名を **削除**
- 新規 `module OsType = { let get: unit => osType }` を追加（実装は `external get: unit => osType = "type"` を `@scope("type")` ではなく `@module("@tauri-apps/plugin-os")` で `type` JS 名と紐付け）
  - 注: upstream の `type()` は module レベル関数なので `@module("@tauri-apps/plugin-os") external get: unit => osType = "type"` で OK
- `tests/runtime/plugin_os.test.mjs` の `PluginOs.osType_()` 呼び出しを `PluginOs.OsType.get()` に変更
- `tests/plugin_os_signature.res` の `_check_` 更新

#### 5. ドキュメント
- 各 plugin の `.resi` doc comment を新 API に追従
- 各 plugin の `README.md` / `CHANGELOG.md` を更新（破壊的変更を明記）
- `sphinx-docs/user/plugin-log.md` / `plugin-notification.md` / `plugin-os.md` を更新（例コードに `_` が含まれていれば置換）
- `sphinx-docs/locale/ja/LC_MESSAGES/user/*.po` の対応箇所も更新（後続 steering でもよいが、本 steering で扱う）
- `docs/repository-structure.md` の plugin-log / plugin-notification / plugin-os 説明を更新

### 含まないもの

- 他 plugin (fs / dialog / shell / clipboard-manager / http / schema) のリファクタ
- IPC encoder / decoder の汎用化
- BC shim（pre-1.0 のため不要）
- 数値 enum を string union として serialize する設計変更（upstream は数値 enum を要求するため `@as(N)` を維持）

## 受け入れ基準

- `pnpm --recursive build` 成功
- `pnpm --recursive test` 全件 pass（plugin-log: 9 / plugin-notification: 21 / plugin-os: 10）
- biome check pass（触ったファイル）
- 公開 API から `osType_` / `error_` / `warn_` / `info_` / `debug_` / `default_` / `private_` / `public_` が消える
- 新 API は型推論で機能する（テストファイル内で polymorphic variant タグを明示的にコンストラクトできる）

## 非ゴール / 後続作業

- 後方互換 alias (`let error_ = #error` 等) は導入しない
- IPC レイヤの decoder インフラ刷新は別 steering
