# Tasklist: changelog.po 未翻訳 12 件の翻訳

## Phase 1: 翻訳

- [x] T1. `user/changelog.po` L117 (plugin-shell v2.3.5 bindings) を翻訳
- [x] T2. `user/changelog.po` L132 (plugin-notification v2.3.3 bindings) を翻訳
- [x] T3. `user/changelog.po` L136 (sendNotification overload 分割) を翻訳
- [x] T4. `user/changelog.po` L150 (plugin-log v2.8.0 bindings) を翻訳
- [x] T5. `user/changelog.po` L153 (`LogLevel.t` @unboxed) を翻訳
- [x] T6. `user/changelog.po` L167 (plugin-os v2.3.2 bindings) を翻訳
- [x] T7. `user/changelog.po` L170 (`OsType.get` サブモジュール理由) を翻訳
- [x] T8. `user/changelog.po` L177 (plugin-clipboard-manager ヘッダ) を翻訳
- [x] T9. `user/changelog.po` L183 (plugin-clipboard-manager v2.3.2 bindings) を翻訳
- [x] T10. `user/changelog.po` L187 (`readImage` 戻り値型説明) を翻訳
- [x] T11. `user/changelog.po` L200 (plugin-http v2.5.9 bindings) を翻訳
- [x] T12. `user/changelog.po` L204 (DOM 型 polymorphic 理由) を翻訳

## Phase 2: 検証

- [x] V1. `msgfmt --statistics sphinx-docs/locale/ja/LC_MESSAGES/user/changelog.po` で untranslated = 0 を確認
- [x] V2. 全 .po 合計でも untranslated = 0 を確認

## Phase 3: コミット・マージ

- [x] C1. steering ドキュメント + changelog.po の翻訳を 1 コミットにまとめる (`📝 Translate 12 untranslated entries in changelog.po (ja)`)
- [x] C2. tasklist.md の全タスク（マージタスク含む）を `[x]` 化してマージ前最終コミットに含める
- [x] C3. `git push origin worktree-translate-po-changelog`
- [x] C4. `gh pr create --base main --head worktree-translate-po-changelog`
- [x] C5. `gh pr merge <N> --merge --delete-branch -R Nagatatz/rescript-tauri`
- [x] C6. CWD をメインリポジトリに移動 → `git pull origin main` → worktree 削除 → ローカルブランチ削除
