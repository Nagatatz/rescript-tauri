# Tasklist: npm Trusted Publishing への移行

## Phase 0: 計画とセットアップ

- [x] requirements.md / design.md / tasklist.md を作成
- [x] `EnterWorktree` で worktree-npm-trusted-publishing を作成
- [x] ステアリングファイル 3 点を初回コミット

## Phase 1: workflow 変更

- [x] T1: `.github/workflows/release.yml` の `Determine publish mode` から `NPM_TOKEN` env と空チェック分岐を削除
- [x] T2: `.github/workflows/release.yml` の `Publish target package` から `NODE_AUTH_TOKEN` env を削除
- [x] T3: workflow の構文検証（`actionlint` で OK 確認）
- [x] T4: 上記 T1-T3 を 1 commit にまとめてコミット（dry_run description と permissions コメントも更新）

## Phase 2: リリースチェックリストの更新

- [ ] T5: `.steering/20260509-029-phase1-release-followups/release-checklist.md` の §2 を Trusted Publisher 設定手順に更新
- [ ] T6: `.steering/20260509-046-phase2-release-checklist/release-checklist.md` の §0 / §4 を Trusted Publisher 前提に更新
- [ ] T7: T5-T6 を 1 commit にまとめてコミット

## Phase 3: 完了検証

- [ ] V1: `release.yml` に `NPM_TOKEN` / `NODE_AUTH_TOKEN` への参照が 0 件であることを `grep` で確認
- [ ] V2: `release.yml` の `id-token: write` permission が残っていることを確認
- [ ] V3: tasklist.md を全 `[x]` に更新して最終コミット

## Phase 4: マージ・クリーンアップ

- [ ] M1: ユーザーに main へのマージ可否を確認
- [ ] M2: `ExitWorktree` で worktree を keep して main repo に戻る
- [ ] M3: main にマージ（`git merge worktree-npm-trusted-publishing --no-ff`）
- [ ] M4: worktree を削除（`git worktree remove`）+ ブランチ削除（`git branch -d`）
- [ ] M5: クリーンアップ完了検証
