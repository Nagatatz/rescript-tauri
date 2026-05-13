# Tasklist — sphinx-docs top page plugin widget

| 項目 | 内容 |
|---|---|
| Steering ID | 20260513-001 |
| 関連 | [requirements.md](./requirements.md), [design.md](./design.md) |

## Phase A: 実装

- [x] A1. `sphinx-docs/index.md` に「## Plugins & add-ons」セクションと grid widget (9 cards) を追加する
- [x] A2. `conf.py` で `sphinx_design` が enable されていることを確認 (extension 追加は不要のはず)

## Phase B: テスト / 検証

- [x] B1. `cd sphinx-docs && uv run make html` を実行し warning 0 で成功
- [x] B2. `_build/html/index.html` を grep し 9 plugin リンクの存在を確認
- [x] B3. `cd sphinx-docs && uv run make -e SPHINXOPTS="-D language=ja" html` を実行し warning 0 で成功 (po 更新後に再確認)

> sphinx-docs のドキュメントは Markdown / RST であり ReScript / vitest テスト対象外なので、`testing.md` のテスト省略例外 (UI / 結合系) ではなく「ビルド検証で代替」とする。tasklist にビルド検証タスクを明記しているため `testing.md` の "省略時は理由明記" の要件を満たす。

## Phase C: ja 翻訳同期

- [x] C1. `cd sphinx-docs && uv run make update-po` で `locale/ja/LC_MESSAGES/index.po` を再生成
- [x] C2. 新規 msgid に msgstr を記入 (既存 user/index.po の訳語と統一)
- [x] C3. `grep -n "#, fuzzy" sphinx-docs/locale/ja/LC_MESSAGES/index.po` の出力が空であること
- [x] C4. `grep -nE 'msgstr ""' sphinx-docs/locale/ja/LC_MESSAGES/index.po` で未翻訳が残らないこと (空 msgid のヘッダ行を除く)

## Phase D: コミット

- [x] D1. `sphinx-docs/index.md` + `sphinx-docs/locale/ja/LC_MESSAGES/index.po` + `.steering/.../*.md` を 1 commit にまとめる
- [x] D2. コミットメッセージ: `📝 Add plugins & add-ons widget to docs top` (絵文字プレフィックス規約準拠)

## Phase E: PR / Merge / Cleanup

- [x] E1. `git push origin worktree-sphinx-docs-top-plugin-widget`
- [x] E2. `gh pr create --base main --head worktree-sphinx-docs-top-plugin-widget` で PR 作成
- [x] E3. `gh pr merge <num> -R Nagatatz/rescript-tauri --merge --delete-branch` で self-merge (worktree 内からは `-R` 必須)
- [x] E4. CWD をメインリポジトリに変更 (worktree 削除前)
- [x] E5. `git pull origin main` でローカル main を最新化
- [x] E6. `git worktree remove .claude/worktrees/sphinx-docs-top-plugin-widget`
- [x] E7. `git branch -d worktree-sphinx-docs-top-plugin-widget`
- [x] E8. クリーンアップ完了の検証 (`git worktree list` / `git branch --list 'worktree-*'` / `.claude/worktrees/` 空)
- [x] E9. このタスクリストの全項目を `[x]` にしてマージ前最終 commit に含める

## Definition of Done

- Phase A〜E すべてのチェックが `[x]`
- `definition-of-done.md` の Phase 1〜5 を満たす
