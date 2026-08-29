# Tasklist: sphinx-docs `locale/ja/` 翻訳更新

## Phase 0: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成

## Phase 1: ステアリングコミット (main)

- [x] main 上で `.steering/20260511-006-sphinx-docs-ja-translation/` を一括コミット
  - commit msg: `📝 Add steering 20260511-006 (sphinx-docs ja translation update)`

## Phase 2: worktree 作成

- [x] `git log --oneline origin/main..HEAD` で未 push commit を確認
- [x] `git worktree add -b worktree-ja-translation .claude/worktrees/ja-translation HEAD`
- [x] `EnterWorktree path=.claude/worktrees/ja-translation`

## Phase 3: `.po` 自動生成

- [x] `make -C sphinx-docs update-po` を実行
- [x] 出力を確認し、5 新規 `.po` が作られ、`index.po` / `installation.po` / `dev/project-structure.po` の差分が妥当であることを確認

## Phase 4: 翻訳作業（見出し / テーブルヘッダ / Compatibility 行のみ）

- [x] **4.1** plugin-shell.po（23 entries 翻訳）
- [x] **4.2** plugin-notification.po（17 entries 翻訳）
- [x] **4.3** plugin-log.po（19 entries 翻訳）
- [x] **4.4** plugin-os.po（19 entries 翻訳）
- [x] **4.5** plugin-clipboard-manager.po（16 entries 翻訳）

## Phase 5: 既存 `.po` 更新

- [x] `index.po` の新規 msgid（"eight add-on packages" / 新規テーブル行 5 件）を訳出
- [x] `installation.po` の cross-ref 行と plugin-http follow-up 注記を訳出
- [x] `dev/project-structure.po` の subsystem map fuzzy を解消（design.md §2 の「他ファイル」項に追加）

## Phase 6: ビルド検証

- [x] `make -C sphinx-docs build-ja` 完了（53 warning, error なし）
- [x] `_build/html_ja/user/plugin-os.html` 等の H2 / H3 が日本語化されていることを確認
- [x] `.mo` は `.gitignore` 済みのため commit に含めない（既存 .mo も untracked）

## Phase 7: 最終コミット

- [x] tasklist.md を全 [x] 化
- [x] commit msg: `✅ Mark steering 20260511-006 tasklist complete`

## Phase 8: マージ準備

- [x] CWD を main repo に移動
- [x] `git fetch origin && git log --oneline HEAD..origin/main` で衝突確認
- [x] AskUserQuestion でマージ可否確認
- [x] `git merge worktree-ja-translation --no-ff -m "Merge branch 'worktree-ja-translation' (steering 20260511-006: sphinx-docs ja translation update)"`

## Phase 9: クリーンアップ

- [x] `git worktree remove .claude/worktrees/ja-translation`
- [x] `git branch -d worktree-ja-translation`
- [x] 検証:
  - `git worktree list` で worktree-ja-translation が消えていること
  - `git branch --list 'worktree-*'` から消えていること

## Phase 10: 完了報告

- [x] ユーザーに完了報告（生成された .po 数 / 訳された見出し範囲 / 未訳の長文は後続案件）

## Non-goals（再掲）

- 5 ページの全文翻訳（散文は msgstr 空のまま）
- 既存 `plugin-fs.po` / `plugin-dialog.po` の品質向上
- Sphinx tooling / Makefile の変更
