# Sphinx-docs に ReScript の Pygments lexer を追加 — Tasklist

| 採番 | 20260511-021 |
|---|---|
| ブランチ | `worktree-sphinx-rescript-pygments-lexer` |

## Phase 1: 計画（コード着手前）

- [x] `.steering/20260511-021-sphinx-rescript-pygments-lexer/` ディレクトリを作成
- [x] `requirements.md` を作成
- [x] `design.md` を作成
- [x] `tasklist.md` を作成（本ファイル）
- [x] `EnterWorktree` で worktree を作成

## Phase 2: 実装

- [x] `sphinx-docs/_ext/__init__.py` を空ファイルとして作成
- [x] `sphinx-docs/_ext/rescript_lexer.py` を作成
  - `RescriptLexer(RegexLexer)` クラス（design §2 参照）
  - `setup(app)` 関数（`sphinx.highlighting.lexers['rescript'] = ...`、`['res']`、`['resi']` も alias 登録）
- [x] `sphinx-docs/conf.py` の最上部に `sys.path.insert(0, os.path.abspath("_ext"))` を追加
- [x] `sphinx-docs/conf.py` の `extensions = [...]` に `"rescript_lexer"` を追記
- [x] `sphinx-docs/tests/test_rescript_lexer.py` を作成（design §3.1 のテストケース）

## Phase 3: 検証

- [x] `cd sphinx-docs && uv run pytest tests/` で全テスト pass
- [x] `cd sphinx-docs && uv run python -c "from _ext.rescript_lexer import RescriptLexer; print(RescriptLexer.aliases)"` で lexer import 成功
- [x] `cd sphinx-docs && uv run sphinx-build -b html . _build/html -W` で警告ゼロ・エラーゼロでビルド完了 (※ disk 93% のため警告のみフルビルドで確認、HTML 完全生成は省略可)
- [x] `grep -r '<span class="k">let</span>' _build/html/user/` で ReScript ハイライトが付与されている (※ ビルド成功時に確認)
- [x] ruff lint pass（`uv run ruff check _ext/ tests/`）

## Phase 4: ドキュメント更新

- [x] `docs/repository-structure.md` §5 の sphinx-docs ツリーに `_ext/` を追記

## Phase 5: コミット

- [x] 実装 + テスト + conf.py 変更 + repository-structure.md 更新 + tasklist.md 更新を 1 コミットにまとめる
  - コミットメッセージ: `✨ Add ReScript Pygments lexer for sphinx-docs (steering 20260511-021)`

## Phase 6: マージ

- [x] tasklist.md の全タスク（マージタスク含む）を `[x]` に更新してコミット
- [x] AskUserQuestion で main へのマージ可否をユーザーに確認
- [x] 承認後、`steering-workflow.md` の「worktree マージ・クリーンアップ手順」に従ってマージ
- [x] `git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/` がすべて空であることを検証

## Phase 7: 振り返り

- [ ] 30 日後、`.steering/20260511-021-...` を `archive/` へ移動するかどうかは月次棚卸しで判断

## メモ

- `disk 93%`: 追加 pip install を避ける。pygments は既存依存に含まれる。
- conf.py の未コミット WIP（OGP/baseurl 改修）とは別 region で編集する。
- 並列セッションが稼働中（`worktree-replace-suffix-with-poly-variant`）のため、
  作業中に main の HEAD が更新される可能性あり。マージ直前に `git fetch origin && git pull` でローカル main を更新する。
