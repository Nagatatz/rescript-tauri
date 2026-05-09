# タスクリスト: sphinx-docs OGP 設定の強化

## Phase 1: 計画

- [x] `.steering/20260509-052-sphinx-ogp-enhancements/` ディレクトリを作成
- [x] `requirements.md` を作成
- [x] `design.md` を作成
- [x] `tasklist.md` を作成
- [x] `EnterWorktree` で worktree を作成

## Phase 2: 実装

- [x] `sphinx-docs/conf.py` の Open Graph セクションを拡張
  - `ogp_description_length = 300` / `ogp_enable_meta_description = True`
  - `ogp_custom_meta_tags` に Twitter Card を追加
  - `setup(app)` で `config-inited` フックにより og:locale[:alternate] を動的追加
- [x] `sphinx-docs/tests/test_ogp.py` を新設
  - en ビルドの og:locale / og:locale:alternate / twitter:card を検証
  - ja ビルドの og:locale / og:locale:alternate / twitter:card を検証

## Phase 3: 検証

- [x] `make html` 成功
- [x] `make build-ja` 成功
- [x] `_build/html/index.html` を grep し期待メタタグを目視確認
- [x] `_build/html_ja/index.html` を grep し期待メタタグを目視確認
- [x] `uv run pytest` パス (6/6)
- [x] `uv run ruff check .` パス
- [x] `uv run ruff format --check .` パス

## Phase 4: コミット & マージ

- [x] `tasklist.md` の全タスク (本タスク含む) を `[x]` に更新
- [x] `✨ Enhance OGP metadata: multilingual locale, Twitter Card, longer descriptions` でコミット
- [ ] `AskUserQuestion` で main マージ可否を確認
- [ ] CWD をメインリポジトリに変更
- [ ] `git merge worktree-sphinx-ogp-enhancements --no-ff`
- [ ] `git worktree remove .claude/worktrees/sphinx-ogp-enhancements`
- [ ] `git branch -d worktree-sphinx-ogp-enhancements`
- [ ] クリーンアップ検証 (`git worktree list`, `git branch --list 'worktree-*'`, `ls .claude/worktrees/`)
