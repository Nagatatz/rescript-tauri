# Tasklist: sphinx-docs JA 完全翻訳

## Phase 0: 計画とセットアップ

- [x] requirements.md / design.md / tasklist.md をユーザー承認
- [x] `EnterWorktree` で worktree-sphinx-docs-ja-full-translation を作成
- [x] ステアリングファイル 3 点を初回コミット

## Phase 1: 大規模ファイル（🔴 優先、初回翻訳）

- [x] T1: `user/plugin-http.po` 翻訳 (85 entries) + コミット
- [x] T2: `user/plugin-shell.po` 翻訳 (73 entries) + コミット
- [x] T3: `user/plugin-clipboard-manager.po` 翻訳 (51 entries) + コミット

## Phase 2: 残存 fuzzy / untranslated エントリの修正

T1–T3 完了後の精密検査で、当初 awk スクリプトが multi-line msgstr を未翻訳と誤判定していたことが判明。実際の残存は `user/index.po` の **1 件 untranslated + 3 件 fuzzy** のみ。Phase 2–5 で予定していた他 17 ファイル (T4–T21) は既に翻訳完了済みのため作業不要。

- [x] T4-precise: `user/index.po` の 1 件 untranslated と 3 件 fuzzy エントリを修正（plugin-http 関連 + Phase 2 件数）+ コミット

## Phase 3: スキップ済み (既に翻訳完了)

以下のファイルは msgattrib --untranslated / --only-fuzzy で 0 件確認済み:

- ~~T4: `user/changelog.po`~~ — already translated (45/45)
- ~~T5: `user/plugin-log.po`~~ — already translated (96/96)
- ~~T6: `user/plugin-notification.po`~~ — already translated (87/87)
- ~~T7: `user/plugin-os.po`~~ — already translated (88/88)
- ~~T8: `user/schema.po`~~ — already translated (50/50)
- ~~T9: `user/plugin-fs.po`~~ — already translated (71/71)
- ~~T10: `dev/architecture.po`~~ — already translated (40/40)
- ~~T11: `user/quickstart.po`~~ — already translated (27/27)
- ~~T12: `dev/building.po`~~ — already translated (72/72)
- ~~T13: `user/configuration.po`~~ — already translated (77/77)
- ~~T14: `user/index.po` (残り)~~ — handled in T4-precise
- ~~T15: `user/plugin-dialog.po`~~ — already translated (60/60)
- ~~T16: `dev/contributing.po`~~ — already translated (37/37)
- ~~T17: `dev/index.po`~~ — already translated (11/11)
- ~~T18: `user/installation.po`~~ — already translated (29/29)
- ~~T19: `dev/setup.po`~~ — already translated (39/39)
- ~~T20: `dev/project-structure.po`~~ — already translated (26/26)
- ~~T21: `index.po`~~ — already translated (15/15)

## Phase 6: 完了検証

- [x] V1: 全 21 .po で msgattrib --untranslated / --only-fuzzy がともに 0 件であることを確認
- [x] V2: msgfmt --check で 21 ファイルすべてが構造的に valid
- [x] V3: tasklist.md を全 `[x]` に更新する最終コミット

## Phase 7: マージ・クリーンアップ

- [ ] M1: ユーザーに main へのマージ可否を確認
- [ ] M2: CWD をメインリポジトリに移動
- [ ] M3: main にマージ（`git merge worktree-sphinx-docs-ja-full-translation --no-ff`）
- [ ] M4: worktree を削除（`git worktree remove`）+ ブランチ削除（`git branch -d`）
- [ ] M5: クリーンアップ完了検証（worktree list / branch list / .claude/worktrees/）
