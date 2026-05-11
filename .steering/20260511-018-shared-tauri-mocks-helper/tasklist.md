# Tasklist: 共有 Tauri モック ヘルパ

## Phase 0: 準備

- [x] `EnterWorktree` で worktree `shared-tauri-mocks-helper` を作成

## Phase 1: ヘルパ実装

- [x] `tools/tauri-mocks.mjs` を新規作成（4 helper + JSDoc）
- [x] `node --check tools/tauri-mocks.mjs` で構文確認

## Phase 2: テスト移行

- [x] `packages/plugin-http/tests/runtime/plugin_http.test.mjs` を helper に書き換え
- [x] `packages/plugin-log/tests/runtime/plugin_log.test.mjs` を helper に書き換え
- [x] `packages/plugin-os/tests/runtime/plugin_os.test.mjs` を helper に書き換え
- [x] `packages/plugin-notification/tests/runtime/plugin_notification.test.mjs` を helper に書き換え

## Phase 3: 検証

- [x] 4 plugin のテストを個別に実行し pass を確認
  - `pnpm --filter @rescript-tauri/plugin-http test` → 3 passed
  - `pnpm --filter @rescript-tauri/plugin-log test` → 9 passed
  - `pnpm --filter @rescript-tauri/plugin-os test` → 10 passed
  - `pnpm --filter @rescript-tauri/plugin-notification test` → 21 passed
- [x] `pnpm --recursive test` で全件 pass を確認
- [x] `pnpm --recursive build` 成功を確認
- [x] biome check (touched files) を pass（既存の 2 warnings は別件、scope 外）

## Phase 4: ドキュメント

- [x] `docs/repository-structure.md` の `tools/` セクションに `tauri-mocks.mjs` 行を追加

## Phase 5: コミット

- [x] 機能単位でコミット:
  - ✨ Add tools/tauri-mocks.mjs shared test helper
  - ♻️ Migrate plugin-{http,log,os,notification} runtime tests to shared helper
  - 📝 Document tools/tauri-mocks.mjs in repository-structure.md

## Phase 6: マージ

- [x] `tasklist.md` の全タスクを `[x]` に更新（マージタスク自体含む）してコミット
- [ ] `AskUserQuestion` でユーザーに main マージ可否を確認
- [ ] 承認後、main マージ → worktree 削除 → ブランチ削除 を一括実行
- [ ] クリーンアップ完了の検証（`git worktree list`, `git branch --list 'worktree-*'`, `.claude/worktrees/`）
