# Tasklist: sphinx-docs `locale/ja/` 翻訳更新

## Phase 0: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成

## Phase 1: ステアリングコミット (main)

- [ ] main 上で `.steering/20260511-006-sphinx-docs-ja-translation/` を一括コミット
  - commit msg: `📝 Add steering 20260511-006 (sphinx-docs ja translation update)`

## Phase 2: worktree 作成

- [ ] `git log --oneline origin/main..HEAD` で未 push commit を確認
- [ ] `git worktree add -b worktree-ja-translation .claude/worktrees/ja-translation HEAD`
- [ ] `EnterWorktree path=.claude/worktrees/ja-translation`

## Phase 3: `.po` 自動生成

- [ ] `make -C sphinx-docs update-po` を実行
- [ ] 出力を確認し、5 新規 `.po` が作られ、`index.po` / `installation.po` の差分が妥当であることを確認
- [ ] 想定外のファイル変更（`changelog.po` / `quickstart.po` 等の本文変化）が無いことを `git diff` で確認

## Phase 4: 翻訳作業（見出し / テーブルヘッダ / Compatibility 行のみ）

各 `.po` は独立 commit。design.md §3.2 の翻訳辞書に従う。

### 4.1 plugin-shell.po

- [ ] H2 / H3 見出し訳出
- [ ] テーブルヘッダ訳出
- [ ] Compatibility 表 Component 列訳出
- [ ] commit msg: `✨ Add ja translation stub for plugin-shell`

### 4.2 plugin-notification.po

- [ ] 同上
- [ ] commit msg: `✨ Add ja translation stub for plugin-notification`

### 4.3 plugin-log.po

- [ ] 同上（plugin-log.md 上のセクション見出しを参照）
- [ ] commit msg: `✨ Add ja translation stub for plugin-log`

### 4.4 plugin-os.po

- [ ] 同上
- [ ] commit msg: `✨ Add ja translation stub for plugin-os`

### 4.5 plugin-clipboard-manager.po

- [ ] 同上
- [ ] commit msg: `✨ Add ja translation stub for plugin-clipboard-manager`

## Phase 5: 既存 `.po` 更新

- [ ] `index.po` の新規 msgid（"seven add-on packages" / 新規テーブル行 / 新規 toctree）を訳出
- [ ] `installation.po` の cross-ref 行と follow-up 注記の新規 msgid を訳出
- [ ] commit msg: `📝 Refresh ja translations for index and installation`

## Phase 6: ビルド検証

- [ ] `make -C sphinx-docs build-ja 2>&1 | tail -30` を実行し、`error` を含まないこと確認
- [ ] `_build/ja/html/user/plugin-os.html` 等の見出しが日本語化されているか curl / grep で抽出
- [ ] 必要であれば `.mo` を更新して commit に含める
- [ ] commit msg: `🔧 Refresh ja .mo build artifacts`

## Phase 7: 最終コミット

- [ ] tasklist.md を全 [x] 化
- [ ] commit msg: `✅ Mark steering 20260511-006 tasklist complete`

## Phase 8: マージ準備

- [ ] CWD を main repo に移動
- [ ] `git fetch origin && git log --oneline HEAD..origin/main` で衝突確認
- [ ] AskUserQuestion でマージ可否確認
- [ ] `git merge worktree-ja-translation --no-ff -m "Merge branch 'worktree-ja-translation' (steering 20260511-006: sphinx-docs ja translation update)"`

## Phase 9: クリーンアップ

- [ ] `git worktree remove .claude/worktrees/ja-translation`
- [ ] `git branch -d worktree-ja-translation`
- [ ] 検証:
  - `git worktree list` で worktree-ja-translation が消えていること
  - `git branch --list 'worktree-*'` から消えていること

## Phase 10: 完了報告

- [ ] ユーザーに完了報告（生成された .po 数 / 訳された見出し範囲 / 未訳の長文は後続案件）

## Non-goals（再掲）

- 5 ページの全文翻訳（散文は msgstr 空のまま）
- 既存 `plugin-fs.po` / `plugin-dialog.po` の品質向上
- Sphinx tooling / Makefile の変更
