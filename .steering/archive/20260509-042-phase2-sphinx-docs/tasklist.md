# Tasklist: sphinx-docs Phase 2 sync

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-phase2-sphinx-docs`) 作成 + main 取り込み
- [x] `.steering/20260509-042-phase2-sphinx-docs/` 作成
- [x] `requirements.md`
- [x] `design.md`
- [x] `tasklist.md`（本ファイル）

## Phase 2: 実装

### A. 新規ページ

- [x] `sphinx-docs/user/plugin-fs.md`
- [x] `sphinx-docs/user/plugin-dialog.md`
- [x] `sphinx-docs/user/schema.md`

### B. 既存ページの更新

- [x] `sphinx-docs/user/index.md` — Phase 2 packages セクション +
      toctree に 3 ページ追加
- [x] `sphinx-docs/user/installation.md` — Phase 2 add-on packages
      の `pnpm add` 例を追加
- [x] `sphinx-docs/user/configuration.md` — "Plugin packages
      (Phase 2+)" 表を実装済反映 + ガイドへリンク

### C. 検証

- [x] markdown text-check (タブ・heading・MyST directive)
- [x] 内部リンクが既存 / 新規ファイルに解決すること
- [x] `pnpm --recursive build` regression なし
- [x] `pnpm --recursive test` regression なし (47 tests)

> 単体テスト省略の理由: ドキュメントのみ変更で実コード非対象
> （`testing.md` 例外節適用）。

### D. 翻訳

- [ ] **Out of scope**: `sphinx-docs/locale/ja/LC_MESSAGES/user/`
      の更新は別途 `make gettext` / `make update-po` で行う。
      本 steering ではタスク化のみ（実施しない）。

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [x] commit 1: `📝 Add Phase 2 user guides to sphinx-docs`
  - 含む: 新規 3 ページ
- [x] commit 2: `📝 Wire Phase 2 packages into sphinx user guide nav`
  - 含む: index.md / installation.md / configuration.md
- [x] commit 3 (最終): `📝 Mark steering 042 tasks complete pre-merge`
  - 含む: ステアリング 3 ファイル + tasklist 全 [x]

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [x] `git merge worktree-phase2-sphinx-docs --no-ff -m "..."`
  - [x] `git worktree remove .claude/worktrees/phase2-sphinx-docs`
  - [x] `git branch -d worktree-phase2-sphinx-docs`

## Phase 6: 検証

- [x] `git worktree list` から phase2-sphinx-docs が消える
- [x] `git branch --list 'worktree-phase2-sphinx-docs'` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の §I
      `sphinx-docs/ を Phase 2 全パッケージに対応` を `[x]` に更新

## Phase 8: フォローアップ (次 steering 候補)

- [ ] `make gettext` + `make update-po` 実行で
      `sphinx-docs/locale/ja/LC_MESSAGES/user/{plugin-fs,plugin-dialog,schema}.po`
      stub を生成し、必要に応じて翻訳。
