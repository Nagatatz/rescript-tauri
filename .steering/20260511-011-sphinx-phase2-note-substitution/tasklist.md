# Tasklist: Phase 2 pre-release note を MyST substitution で一元化

## Phase 0: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成

## Phase 1: ステアリングコミット (main)

- [x] main 上で `.steering/20260511-011-sphinx-phase2-note-substitution/` を一括コミット
  - commit msg: `📝 Add steering 20260511-011 (sphinx phase 2 note substitution)`

## Phase 2: worktree 作成

- [x] `git log --oneline origin/main..HEAD` で未 push commit を確認
- [x] `git worktree add -b worktree-phase2-note-substitution .claude/worktrees/phase2-note-substitution HEAD`
- [x] `EnterWorktree path=.claude/worktrees/phase2-note-substitution`

## Phase 3: `conf.py` 更新

- [x] `myst_enable_extensions` に `"substitution"` を追加
- [x] `myst_substitutions = {"phase_2_note": "..."}` を追加
- [x] commit msg: `🔧 Enable MyST substitution and define phase_2_note`

## Phase 4: 8 plugin ユーザーガイドの書換え

- [x] plugin-fs.md / plugin-dialog.md / plugin-notification.md / plugin-shell.md / plugin-log.md / plugin-os.md / plugin-clipboard-manager.md / plugin-http.md それぞれ最初の `{note}` ブロックを `{{ phase_2_note }}` 参照に置換
- [x] plugin-clipboard-manager.md の 2 つ目（Android/iOS Image 注意）は触らない
- [x] commit msg: `♻️ Replace duplicated phase-2 pre-release notes with substitution`

## Phase 5: ビルド検証

- [x] `make -C sphinx-docs html` を実行 (60 warnings, error なし)
- [x] `_build/html/user/plugin-fs.html` の admonition に新文面が表示されることを確認
- [x] `_build/html/user/plugin-http.html` も同様に確認
- [x] `make -C sphinx-docs build-ja` を実行 (47 warnings, error なし)
- [x] `_build/html_ja/user/plugin-fs.html` で日本語 admonition、plugin-shell.html で英語 fallback を確認

## Phase 6: `.po` 再生成

- [x] `make -C sphinx-docs update-po` を実行
- [x] 既存 ja 訳のある plugin-fs.po / plugin-dialog.po の Phase 2 note 部分を新 msgid 用に「本パッケージ ...」表現で書き換え
- [x] 残り 6 plugin (`notification` / `shell` / `log` / `os` / `clipboard-manager` / `http`) の .po は msgstr 空でフォールバック維持
- [x] 全 8 .po で fuzzy マーカーを除去
- [x] commit msg: `📝 Refresh .po files after note refactor`

## Phase 7: 最終コミット

- [x] tasklist.md を全 [x] 化
- [x] commit msg: `✅ Mark steering 20260511-011 tasklist complete`

## Phase 8: マージ準備

- [x] CWD を main repo に移動
- [x] `git fetch origin && git log --oneline HEAD..origin/main` で衝突確認
- [x] AskUserQuestion でマージ可否確認
- [x] `git merge worktree-phase2-note-substitution --no-ff -m "Merge branch 'worktree-phase2-note-substitution' (steering 20260511-011: sphinx phase 2 note substitution)"`

## Phase 9: クリーンアップ

- [x] `git worktree remove .claude/worktrees/phase2-note-substitution`
- [x] `git branch -d worktree-phase2-note-substitution`
- [x] 検証:
  - `git worktree list` から消えていること
  - `git branch --list 'worktree-*'` から消えていること

## Phase 10: 完了報告

- [x] ユーザーに完了報告（削減行数 / Phase 2 npm publish 時の撤去手順 / 既訳保持状況）

## Non-goals（再掲）

- 既存翻訳の品質向上
- note 以外のセクションのリファクタ
- 他ドキュメント (docs/) への substitution 適用
