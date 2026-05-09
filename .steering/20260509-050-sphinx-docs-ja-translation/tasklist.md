# Tasklist: sphinx-docs Japanese translation

## Phase 1: 計画

- [x] 1-1. `.steering/20260509-050-sphinx-docs-ja-translation/` 作成
- [x] 1-2. `requirements.md` 作成
- [x] 1-3. `design.md` 作成
- [x] 1-4. `tasklist.md` 作成（本書）
- [x] 1-5. `EnterWorktree(name="sphinx-ja-translation")` で worktree 作成

## Phase 2: .pot/.po 再生成

- [x] 2-1. worktree 内で `cd sphinx-docs && make gettext`
- [x] 2-2. worktree 内で `cd sphinx-docs && make update-po`
- [x] 2-3. 新規 `.po`（`user/plugin-fs.po`, `user/plugin-dialog.po`, `user/schema.po`）が生成されたことを確認
- [x] 2-4. `🔧 Regenerate .po files for sphinx-docs Japanese locale` コミット

## Phase 3: 翻訳

### ルート / user/

- [ ] 3-1. `locale/ja/LC_MESSAGES/index.po` 翻訳
- [ ] 3-2. `locale/ja/LC_MESSAGES/user/index.po` 翻訳
- [ ] 3-3. `locale/ja/LC_MESSAGES/user/installation.po` 翻訳
- [ ] 3-4. `locale/ja/LC_MESSAGES/user/quickstart.po` 翻訳
- [ ] 3-5. `locale/ja/LC_MESSAGES/user/configuration.po` 翻訳
- [ ] 3-6. `locale/ja/LC_MESSAGES/user/changelog.po` 翻訳
- [ ] 3-7. `locale/ja/LC_MESSAGES/user/plugin-fs.po` 翻訳
- [ ] 3-8. `locale/ja/LC_MESSAGES/user/plugin-dialog.po` 翻訳
- [ ] 3-9. `locale/ja/LC_MESSAGES/user/schema.po` 翻訳
- [ ] 3-10. `📝 Translate sphinx-docs index/user pages to Japanese` コミット

### dev/

- [ ] 3-11. `locale/ja/LC_MESSAGES/dev/index.po` 翻訳
- [ ] 3-12. `locale/ja/LC_MESSAGES/dev/setup.po` 翻訳
- [ ] 3-13. `locale/ja/LC_MESSAGES/dev/building.po` 翻訳
- [ ] 3-14. `locale/ja/LC_MESSAGES/dev/architecture.po` 翻訳
- [ ] 3-15. `locale/ja/LC_MESSAGES/dev/contributing.po` 翻訳
- [ ] 3-16. `locale/ja/LC_MESSAGES/dev/project-structure.po` 翻訳
- [ ] 3-17. `📝 Translate sphinx-docs dev pages to Japanese` コミット

## Phase 4: ビルド検証

- [ ] 4-1. `cd sphinx-docs && make build-ja` 実行
- [ ] 4-2. WARNING / ERROR を確認し、必要なら修正コミット
- [ ] 4-3. `_build/html_ja/index.html`・`user/quickstart/index.html`・`user/plugin-fs/index.html` の本文が日本語化されていることを Read で目視確認
- [ ] 4-4. `git grep '^msgstr ""$' sphinx-docs/locale/ja` の結果がヘッダ部以外で 0 件であることを確認

## Phase 5: マージ前

- [ ] 5-1. tasklist の全項目を `[x]` にする
- [ ] 5-2. `📝 Mark steering 050 tasks complete pre-merge` コミット
- [ ] 5-3. `AskUserQuestion` で main へのマージ可否を確認

## Phase 6: マージ後

- [ ] 6-1. CWD をメインリポジトリに移動
- [ ] 6-2. `git merge worktree-sphinx-ja-translation --no-ff` 実行
- [ ] 6-3. `git worktree remove .claude/worktrees/sphinx-ja-translation` 実行
- [ ] 6-4. `git branch -d worktree-sphinx-ja-translation` 実行
- [ ] 6-5. クリーンアップ検証（`git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/`）
