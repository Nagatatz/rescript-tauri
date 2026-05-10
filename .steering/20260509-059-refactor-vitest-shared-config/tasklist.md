# Steering 059: Tasklist — vitest config 共通化

## Phase 1: 計画
- [x] requirements.md / design.md / tasklist.md 作成
- [x] EnterWorktree で `worktree-refactor-vitest-shared-config` 作成

## Phase 2: 実装

### Task 1: `tools/vitest.shared.mjs` を新設
- [x] `tools/vitest.shared.mjs` 作成 (`definePackageConfig` helper)
- [x] `node --check tools/vitest.shared.mjs` で構文確認
- [x] コミット: `🔧 Add tools/vitest.shared.mjs helper for package vitest config`

### Task 2: 9 パッケージの `vitest.config.mjs` を helper 経由に書き換え
- [x] `packages/core/vitest.config.mjs`
- [x] `packages/plugin-fs/vitest.config.mjs`
- [x] `packages/plugin-dialog/vitest.config.mjs`
- [x] `packages/plugin-shell/vitest.config.mjs`
- [x] `packages/plugin-notification/vitest.config.mjs`
- [x] `packages/plugin-log/vitest.config.mjs`
- [x] `packages/plugin-os/vitest.config.mjs`
- [x] `packages/plugin-clipboard-manager/vitest.config.mjs`
- [x] `packages/schema/vitest.config.mjs`
- [x] 9 ファイル全件 `node --check` で構文確認
- [x] core で 1 回 `pnpm --filter @rescript-tauri/core test` を実行し変更前と同じ pass を確認
- [x] コミット: `♻️ Migrate package vitest configs to definePackageConfig helper`

### Task 3: ドキュメント更新
- [ ] `docs/repository-structure.md` の `tools/` セクションを追記
- [ ] コミット: `📝 Document tools/ directory in repository-structure`

## Phase 3: マージ前
- [ ] tasklist.md の全タスクを `[x]` に更新
- [ ] `git diff --stat origin/main..HEAD` で純減 50 行以上を確認
- [ ] 最終コミット (tasklist 更新)

## Phase 4: マージ・クリーンアップ
- [ ] AskUserQuestion で main へのマージ可否を確認
- [ ] CWD を main repo へ移動 (ExitWorktree)
- [ ] `git merge worktree-refactor-vitest-shared-config --no-ff`
- [ ] worktree 削除 / ブランチ削除 / 検証
