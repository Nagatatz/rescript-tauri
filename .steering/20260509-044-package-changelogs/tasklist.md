# Tasklist: Per-package CHANGELOGs

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-phase2-changelogs`) 作成 + main 取り込み
- [x] `.steering/20260509-044-package-changelogs/` 作成
- [x] `requirements.md`
- [x] `design.md`
- [x] `tasklist.md`（本ファイル）

## Phase 2: 実装

### A. 新規 CHANGELOG (4 件)

- [x] `packages/core/CHANGELOG.md`
- [x] `packages/schema/CHANGELOG.md`
- [x] `packages/plugin-fs/CHANGELOG.md`
- [x] `packages/plugin-dialog/CHANGELOG.md`

### B. README cross-link

- [x] `packages/core/README.md` の See also に Changelog 行
- [x] `packages/schema/README.md` の See also に Changelog 行
- [x] `packages/plugin-fs/README.md` の See also に Changelog 行
- [x] `packages/plugin-dialog/README.md` の See also に Changelog 行

### C. sphinx-docs 更新

- [x] `sphinx-docs/user/changelog.md` を Phase 2 全パッケージに対応
      (4 セクション + canonical link + Repository-level セクション)

### D. 検証

- [x] 4 CHANGELOG を text-check (タブ・heading)
- [x] README から `./CHANGELOG.md` 相対リンクが新規ファイルに到達
- [x] sphinx changelog の絶対リンクが解決
- [x] `pnpm --recursive build` regression なし
- [x] `pnpm --recursive test` 全件パス (47 tests)

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [x] commit 1: `📝 Add per-package CHANGELOG.md (Keep a Changelog format)`
  - 含む: 4 つの新規 CHANGELOG
- [x] commit 2: `📝 Link CHANGELOG from each package README`
  - 含む: 4 README の See also 節
- [x] commit 3: `📝 Update sphinx user changelog for Phase 2 packages`
  - 含む: `sphinx-docs/user/changelog.md`
- [x] commit 4 (最終): `📝 Mark steering 044 tasks complete pre-merge`

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [x] `git merge worktree-phase2-changelogs --no-ff -m "..."`
  - [x] `git worktree remove .claude/worktrees/phase2-changelogs`
  - [x] `git branch -d worktree-phase2-changelogs`

## Phase 6: 検証

- [x] `git worktree list` から phase2-changelogs が消える
- [x] `git branch --list 'worktree-phase2-changelogs'` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の §I
      `CHANGELOG が各パッケージで 0.1.0 以降の履歴を持つ` を `[x]` に更新
