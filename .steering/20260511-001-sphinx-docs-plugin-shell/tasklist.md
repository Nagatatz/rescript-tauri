# Tasklist: sphinx-docs plugin-shell user guide

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-001 |
| 関連 | `requirements.md`, `design.md` |

各タスクは単独で `git commit` 可能な粒度に分割している（usage limit に備えた checkpoint 構造）。各コミットの完了時点で `pnpm run check` が green であること。

---

## Phase 0: 準備

- [x] T0.1 `git fetch origin` で main の鮮度を確認し、`EnterWorktree plugin-shell-userguide` で worktree 隔離
- [x] T0.2 worktree 内で `git log --oneline -3` を実行し、HEAD が main と同期していることを確認

## Phase 1: 本体追加

- [x] T1.1 `sphinx-docs/user/plugin-shell.md` を design.md §2〜§3.12 に沿って新規作成
- [x] T1.2 ローカルで `grep -E '^#{1,3} ' sphinx-docs/user/plugin-shell.md` を実行し、章立てが design §2 の構造と一致しているか目視確認
- [x] T1.3 `pnpm run check` を実行（Biome は `.md` 対象外なので green になるはず。worktree CWD での `.` 除外で 0 files 扱いになるが、個別ファイルチェックで実害なしを確認済み）
- [x] T1.4 **コミット**: `✨ Add sphinx-docs/user/plugin-shell.md (steering 20260511-001)`
  - 含めるファイル: `sphinx-docs/user/plugin-shell.md`, `.steering/20260511-001-sphinx-docs-plugin-shell/{requirements,design,tasklist}.md`
  - 本コミット完了時、tasklist 内 Phase 1 を `[x]` に更新してから `git add` する

## Phase 2: index.md 更新

- [x] T2.1 `sphinx-docs/user/index.md` の Phase 2 packages テーブルに `@rescript-tauri/plugin-shell` 行を追加（design §4.1 の通り）。あわせて先頭文 "three add-on packages" を "four add-on packages" に更新
- [x] T2.2 同 toctree に `plugin-shell` を `plugin-dialog` と `schema` の間に追加（design §4.2）
- [x] T2.3 **コミット**: `📝 Link plugin-shell user guide from sphinx-docs/user/index.md`

## Phase 3: repository-structure.md 更新

- [x] T3.1 `docs/repository-structure.md` §5 末尾の「未追加のユーザーガイド」記述を design §5 の変更後内容に差し替え
- [x] T3.2 **コミット**: `📝 Mark plugin-shell user guide as added in repository-structure.md`

## Phase 4: 検証

- [ ] T4.1 `git diff main..HEAD --stat` で本ステアリングの差分が `sphinx-docs/user/plugin-shell.md`, `sphinx-docs/user/index.md`, `docs/repository-structure.md`, `.steering/20260511-001-.../*.md` の 6 ファイルに限定されていることを確認
- [ ] T4.2 `pnpm run check` 最終確認
- [ ] T4.3 相対リンク (`plugin-fs.md`, `plugin-dialog.md`, `installation.md` 等) が存在することを `ls sphinx-docs/user/` で確認

## Phase 5: マージ

- [ ] T5.1 tasklist.md の Phase 0〜4 を全部 `[x]` に更新し、本マージタスク自体を含めて全項目チェック済みであることを確認
- [ ] T5.2 **コミット**: `📝 Mark tasklist 20260511-001 complete`
- [ ] T5.3 `AskUserQuestion` でユーザーに main へのマージ可否を確認
- [ ] T5.4 承認後、メインリポジトリで未追跡の `.steering/20260511-001-sphinx-docs-plugin-shell/` を削除（worktree 作成前に main 側に作成した残骸を解消）
- [ ] T5.5 `cd <main-repo>` → `git merge worktree-plugin-shell-userguide --no-ff` → `git worktree remove .claude/worktrees/plugin-shell-userguide` → `git branch -d worktree-plugin-shell-userguide`
- [ ] T5.6 クリーンアップ検証: `git worktree list` で main のみ / `git branch --list 'worktree-*'` の出力が空 / `.claude/worktrees/` が空

## 後続作業 (out-of-scope)

以下は本ステアリングのスコープ外。完了後に別 steering を採番して着手する:

- `examples/plugin-shell-demo/` 新規追加（追加後、本ガイドの See also に live demo リンクを追記）
- `sphinx-docs/locale/ja/` の `.po` 翻訳更新（`make update-po` 実行）
- `sphinx-docs/user/plugin-notification.md` 追加（plugin-shell と同型の作業）
