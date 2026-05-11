# Tasklist: Phase 2 pre-release note を MyST substitution で一元化

## Phase 0: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成

## Phase 1: ステアリングコミット (main)

- [ ] main 上で `.steering/20260511-011-sphinx-phase2-note-substitution/` を一括コミット
  - commit msg: `📝 Add steering 20260511-011 (sphinx phase 2 note substitution)`

## Phase 2: worktree 作成

- [ ] `git log --oneline origin/main..HEAD` で未 push commit を確認
- [ ] `git worktree add -b worktree-phase2-note-substitution .claude/worktrees/phase2-note-substitution HEAD`
- [ ] `EnterWorktree path=.claude/worktrees/phase2-note-substitution`

## Phase 3: `conf.py` 更新

- [ ] `myst_enable_extensions` に `"substitution"` を追加
- [ ] `myst_substitutions = {"phase_2_note": "..."}` を追加
- [ ] commit msg: `🔧 Enable MyST substitution and define phase_2_note`

## Phase 4: 8 plugin ユーザーガイドの書換え

- [ ] plugin-fs.md / plugin-dialog.md / plugin-notification.md / plugin-shell.md / plugin-log.md / plugin-os.md / plugin-clipboard-manager.md / plugin-http.md それぞれ最初の `{note}` ブロックを `{{ phase_2_note }}` 参照に置換
- [ ] plugin-clipboard-manager.md の 2 つ目（Android/iOS Image 注意）は触らない
- [ ] commit msg: `♻️ Replace duplicated phase-2 pre-release notes with substitution`

## Phase 5: ビルド検証

- [ ] `make -C sphinx-docs html` を実行 (error なし)
- [ ] `_build/html/user/plugin-fs.html` の admonition に新文面が表示されることを確認
- [ ] `make -C sphinx-docs build-ja` を実行 (error なし)
- [ ] `_build/html_ja/user/plugin-fs.html` の admonition も同様に表示されることを確認

## Phase 6: `.po` 再生成

- [ ] `make -C sphinx-docs update-po` を実行
- [ ] `git diff` で `.po` 変更を確認
- [ ] 既存 ja 訳のある plugin-fs.po / plugin-dialog.po の note 部分について:
  - 旧 msgid は obsolete 化 / 削除されるはず
  - 新 msgid に対応する Japanese msgstr を旧訳から転写（"this package" / "it" の文脈に合わせて再構成）
- [ ] 残り 6 plugin の .po は新 msgid が `msgstr ""` のままで OK（fallback で英語）
- [ ] commit msg: `📝 Refresh .po files after note refactor`
- [ ] （ja 訳転写があれば別 commit）: `📝 Carry over ja translation for refactored phase_2 note`

## Phase 7: 最終コミット

- [ ] tasklist.md を全 [x] 化
- [ ] commit msg: `✅ Mark steering 20260511-011 tasklist complete`

## Phase 8: マージ準備

- [ ] CWD を main repo に移動
- [ ] `git fetch origin && git log --oneline HEAD..origin/main` で衝突確認
- [ ] AskUserQuestion でマージ可否確認
- [ ] `git merge worktree-phase2-note-substitution --no-ff -m "Merge branch 'worktree-phase2-note-substitution' (steering 20260511-011: sphinx phase 2 note substitution)"`

## Phase 9: クリーンアップ

- [ ] `git worktree remove .claude/worktrees/phase2-note-substitution`
- [ ] `git branch -d worktree-phase2-note-substitution`
- [ ] 検証:
  - `git worktree list` から消えていること
  - `git branch --list 'worktree-*'` から消えていること

## Phase 10: 完了報告

- [ ] ユーザーに完了報告（削減行数 / Phase 2 npm publish 時の撤去手順 / 既訳保持状況）

## Non-goals（再掲）

- 既存翻訳の品質向上
- note 以外のセクションのリファクタ
- 他ドキュメント (docs/) への substitution 適用
