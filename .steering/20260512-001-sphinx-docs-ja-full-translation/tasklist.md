# Tasklist: sphinx-docs JA 完全翻訳

## Phase 0: 計画とセットアップ

- [x] requirements.md / design.md / tasklist.md をユーザー承認
- [x] `EnterWorktree` で worktree-sphinx-docs-ja-full-translation を作成
- [x] ステアリングファイル 3 点を初回コミット

## Phase 1: 大規模ファイル（🔴 優先）

- [x] T1: `user/plugin-http.po` 翻訳 (85 entries) + コミット
- [x] T2: `user/plugin-shell.po` 翻訳 (73 entries) + コミット
- [x] T3: `user/plugin-clipboard-manager.po` 翻訳 (51 entries) + コミット

## Phase 2: 中規模ファイル（🟠）

- [ ] T4: `user/changelog.po` 翻訳 (34 entries) + コミット
- [ ] T5: `user/plugin-log.po` 翻訳 (25 entries) + コミット
- [ ] T6: `user/plugin-notification.po` 翻訳 (21 entries) + コミット
- [ ] T7: `user/plugin-os.po` 翻訳 (19 entries) + コミット

## Phase 3: 小〜中規模ファイル（🟡）

- [ ] T8: `user/schema.po` 翻訳 (16 entries) + コミット
- [ ] T9: `user/plugin-fs.po` 翻訳 (12 entries) + コミット
- [ ] T10: `dev/architecture.po` 翻訳 (11 entries) + コミット
- [ ] T11: `user/quickstart.po` 翻訳 (10 entries) + コミット

## Phase 4: 小規模ファイル（🟢、9 件）

- [ ] T12: `dev/building.po` 翻訳 (9 entries) + コミット
- [ ] T13: `user/configuration.po` 翻訳 (9 entries) + コミット
- [ ] T14: `user/index.po` 翻訳 (9 entries) + コミット
- [ ] T15: `user/plugin-dialog.po` 翻訳 (9 entries) + コミット
- [ ] T16: `dev/contributing.po` 翻訳 (9 entries) + コミット

## Phase 5: 残小規模ファイル（🟢、5 件以下）

- [ ] T17: `dev/index.po` 翻訳 (5 entries) + コミット
- [ ] T18: `user/installation.po` 翻訳 (4 entries) + コミット
- [ ] T19: `dev/setup.po` 翻訳 (3 entries) + コミット
- [ ] T20: `dev/project-structure.po` 翻訳 (3 entries) + コミット
- [ ] T21: `index.po` 翻訳 (2 entries) + コミット

## Phase 6: 完了検証

- [ ] V1: 全 .po で `msgstr ""` がヘッダ以外 0 件であることを検証
- [ ] V2: Sphinx 日本語ビルドを完走させる（`cd sphinx-docs && uv sync && SPHINXOPTS="-D language=ja" make html`）
- [ ] V3: tasklist.md を全 `[x]` に更新する最終コミット

## Phase 7: マージ・クリーンアップ

- [ ] M1: ユーザーに main へのマージ可否を確認
- [ ] M2: CWD をメインリポジトリに移動
- [ ] M3: main にマージ（`git merge worktree-sphinx-docs-ja-full-translation --no-ff`）
- [ ] M4: worktree を削除（`git worktree remove`）+ ブランチ削除（`git branch -d`）
- [ ] M5: クリーンアップ完了検証（worktree list / branch list / .claude/worktrees/）
