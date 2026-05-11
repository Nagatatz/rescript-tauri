# Requirements: 共有 Tauri モック ヘルパ

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260511-018 |
| 作成日 | 2026-05-11 |
| 起点 | リファクタリング監査 候補 #1（テスト stub 一元化） |

## 背景

各 plugin パッケージのランタイムテスト (`packages/plugin-*/tests/runtime/*.test.mjs`) で、Tauri のグローバル stub セットアップが各自実装されている。

- `packages/plugin-http/tests/runtime/plugin_http.test.mjs:15-30` — `__TAURI_INTERNALS__` (invoke + transformCallback)
- `packages/plugin-log/tests/runtime/plugin_log.test.mjs:49-64` — `__TAURI_INTERNALS__` + `__TAURI_EVENT_PLUGIN_INTERNALS__`
- `packages/plugin-os/tests/runtime/plugin_os.test.mjs:9-25` — `__TAURI_OS_PLUGIN_INTERNALS__`
- `packages/plugin-notification/tests/runtime/plugin_notification.test.mjs:9-12,18,161,176,192` — `window.Notification`

stub の shape は微妙に異なり、新規 plugin 追加時にどの stub が必要かを既存テストから読み解く必要がある。

## ゴール

`tools/tauri-mocks.mjs` を新設し、4 種類の install helper を提供する。各 helper は cleanup 関数を返す（`beforeEach` / `afterEach` で `setupX()` → `teardown` の対称ペアにする）。既存 4 plugin のテストをこの helper に移行する。

## スコープ

### 含むもの

- `tools/tauri-mocks.mjs` 新設 — 4 ヘルパ:
  - `installTauriInternals({invoke?, transformCallback?}?)` — `__TAURI_INTERNALS__`
  - `installEventPluginInternals()` — `__TAURI_EVENT_PLUGIN_INTERNALS__`
  - `installOsPluginInternals(overrides?)` — `__TAURI_OS_PLUGIN_INTERNALS__`
  - `installNotificationStub(impl)` — `window.Notification`
- 4 plugin の runtime テスト書き換え:
  - `plugin-http` / `plugin-log` / `plugin-os` / `plugin-notification`
- `docs/repository-structure.md` の `tools/` セクションに新ヘルパを追記
- 既存テストの全件 pass 維持（vitest）

### 含まないもの

- `plugin-{dialog,fs,shell,clipboard-manager}` — グローバル stub を使っていない。`Mocks.mockIPC` のみで動いており、変更しない
- ReScript 側のコード変更
- `tools/vitest.shared.mjs` への統合（独立ファイルのまま）
- 新規 plugin の追加

## 受け入れ基準

- `tools/tauri-mocks.mjs` が存在し、4 helper が export されている
- 各 helper は cleanup 関数を返す
- `pnpm --recursive test` が全件 pass
- `pnpm --recursive build` が成功
- 4 plugin のテストファイルから直接的な `globalThis.window.__TAURI_*` への代入が消えている（helper 経由のみ）
- `docs/repository-structure.md` の `tools/` テーブルに `tauri-mocks.mjs` が記載されている

## 非ゴール / 後続作業

- 旧来の inline stub を残したまま helper を追加するハイブリッド構成にはしない（DRY 原則優先）
- helper を npm publish 対象にはしない（テスト用ツール）
