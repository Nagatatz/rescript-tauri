# タスクリスト: `@rescript-tauri/plugin-notification` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-054-plugin-notification` |
| ブランチ | `worktree-plugin-notification`（worktree 経由） |

## Phase 0: 準備

- [x] worktree を作成 (`EnterWorktree plugin-notification`)
- [x] requirements.md / design.md / tasklist.md をユーザー承認

## Phase 1: パッケージ scaffolding

- [x] `packages/plugin-notification/package.json`
- [x] `packages/plugin-notification/rescript.json`
- [x] `packages/plugin-notification/vitest.config.mjs`
- [x] `packages/plugin-notification/README.md`
- [x] `packages/plugin-notification/CHANGELOG.md`
- [x] `pnpm install` で workspace に取り込み・peerDependency を解決
- [x] コミット: `🔧 Scaffold @rescript-tauri/plugin-notification package`

## Phase 2: バインディング実装

- [x] `src/PluginNotification.res` / `.resi`
  - [x] 型: `notificationPermission` / `attachment` / `scheduleInterval` / `scheduleEvery` / `options` / `action` / `actionType` / `pendingNotification` / `activeNotification` / `channel` / `removeActiveTarget`
  - [x] `Schedule` モジュール (type t, at, interval, every)
  - [x] `Importance` / `Visibility` モジュール（int 定数）
  - [x] 15 関数（isPermissionGranted ... onAction）
- [x] `pnpm --filter @rescript-tauri/plugin-notification build` 成功
- [x] コミット: `✨ Implement @rescript-tauri/plugin-notification bindings`

## Phase 3: テスト

- [x] `tests/plugin_notification_signature.res` — 全公開シンボルへの型注釈付き呼び出し
- [x] `tests/runtime/plugin_notification.test.mjs` — `Mocks.mockIPC` で IPC コマンド名検証
- [x] `pnpm --filter @rescript-tauri/plugin-notification test` 全件 pass
- [x] コミット: `✅ Add type-level and runtime tests for plugin-notification`

## Phase 4: CI 拡張

- [x] `.github/workflows/tests-plugin-notification-types.yml` 新設
- [x] `.github/workflows/tests-plugin-notification-runtime.yml` 新設
- [x] `.github/workflows/tests-coverage.yml` matrix に `plugin-notification` 追加
- [x] `.github/workflows/release.yml` の tag prefix と case に `plugin-notification-v*` 追加
- [x] コミット: `🔧 Add plugin-notification CI workflows and release routing`

## Phase 5: ドキュメント更新

- [x] `docs/repository-structure.md` §1 ルートツリー + §2.2 に plugin-notification セクション追記
- [x] `README.md` (root) Packages 表に `@rescript-tauri/plugin-notification` 行追加
- [x] コミット: `📝 Document @rescript-tauri/plugin-notification`

## Phase 6: 最終検証

- [x] `pnpm --workspace-concurrency 1 --recursive build` 成功
- [x] `pnpm --workspace-concurrency 1 --recursive test` 全件 pass
- [x] tasklist.md の全タスクを `[x]` に更新
- [x] コミット: `✅ Mark steering 054 tasks complete`

## Phase 7: マージ・クリーンアップ

- [x] CWD をメインリポジトリに変更
- [x] 未追跡 `.steering/` ファイルがあれば事前削除
- [x] `git merge worktree-plugin-notification --no-ff -m "Merge branch 'worktree-plugin-notification' (steering 054: plugin-notification)"`
- [x] worktree 削除
- [x] ブランチ削除
- [x] `git worktree list` で確認
