# Tasklist: sphinx-docs/user/plugin-log.md

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-003 |
| 関連 | requirements.md / design.md |

## Phase 1: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [ ] ユーザー承認
- [ ] EnterWorktree で `plugin-log-userguide` 作成（base ref: fresh = origin/main、ローカル main は origin と同期済み）

## Phase 2: 実装

各 checkpoint は単独で commit 可能。順序は固定。

### Checkpoint 1: 骨格 + Install + Capabilities + Minimal example

- [ ] `sphinx-docs/user/plugin-log.md` 新規作成
  - Title + intro 段落 + `{note}` ステータスブロック
  - `## Install` セクション（JS pnpm add / peerDeps / rescript.json dependencies / Rust Cargo.toml / Rust Builder + targets サンプル）
  - `## Capabilities` セクション（`log:default` JSON）
  - `## Minimal example` セクション（attachConsole + info の最小コード）
- [ ] `pnpm run check` 警告なし
- [ ] commit: `📝 Add sphinx-docs/user/plugin-log.md skeleton (install + capabilities + minimal example)`

### Checkpoint 2: Public API リファレンス

- [ ] `## Public API` セクション追加
  - 7 関数表 (`error` / `warn` / `info` / `debug` / `trace` / `attachLogger` / `attachConsole`)
  - `### Numeric LogLevel constants` サブセクション + 5 定数のコード例
  - `### logOptions / recordPayload` サブセクション + 各フィールドの説明
  - `### attachLogger / attachConsole` サブセクション + level 分岐付きコード例
- [ ] `pnpm run check` 警告なし
- [ ] commit: `📝 Document plugin-log public API in sphinx-docs user guide`

### Checkpoint 3: Pitfalls + Compatibility + See also

- [ ] `## Pitfalls` セクション
  - `### LogLevel naming convention` (suffix `_` の理由)
  - `### attachLogger / attachConsole testing` (`__TAURI_INTERNALS__` stub の必要性)
- [ ] `## Compatibility` 表
- [ ] `## See also` リスト（source / upstream / README、demo はまだないのでリンクしない）
- [ ] `pnpm run check` 警告なし
- [ ] commit: `📝 Add plugin-log pitfalls, compatibility and see-also sections`

### Checkpoint 4: 周辺ドキュメント更新

- [ ] `sphinx-docs/user/index.md` の Phase 2 packages 表に plugin-log 行追加
- [ ] `sphinx-docs/user/index.md` toctree に `plugin-log` を追加（順序: `plugin-notification` の後、`schema` の前）
- [ ] `sphinx-docs/user/installation.md` の follow-up note から plugin-log を削除
- [ ] `sphinx-docs/user/installation.md` の "See the [plugin-fs] ... guides" cross-ref に plugin-log を追加
- [ ] `pnpm run check` 警告なし
- [ ] `grep -n "plugin-log" sphinx-docs/user/installation.md sphinx-docs/user/index.md` で cross-ref を最終確認
- [ ] commit: `📝 Cross-link plugin-log user guide from index/installation`

## Phase 3: マージ前検証

- [ ] `pnpm --recursive --workspace-concurrency=1 build` 成功（ドキュメント変更のみだが念のため）
- [ ] `pnpm run check` 全件パス
- [ ] `grep -rn "plugin-log" sphinx-docs/user/` で意図した箇所すべてに反映されていること
- [ ] tasklist.md の全タスク `[x]` 化
- [ ] commit: `✅ Mark steering 20260511-003 tasklist complete`

## Phase 4: マージ

- [ ] `AskUserQuestion` で main へのマージ可否確認
- [ ] 承認後、CWD を main へ移動
- [ ] 先行 merge による更新を取り込み: `git fetch origin && git merge origin/main`（conflict が出た場合は `installation.md` / `index.md` で手動解消）
- [ ] `git merge worktree-plugin-log-userguide --no-ff -m "Merge branch 'worktree-plugin-log-userguide' (steering 20260511-003: sphinx-docs plugin-log user guide)"`
- [ ] worktree remove: `git worktree remove .claude/worktrees/plugin-log-userguide`
- [ ] branch delete: `git branch -d worktree-plugin-log-userguide`
- [ ] 検証:
  - `git worktree list` で main + 他並列 worktree のみ
  - `git branch --list 'worktree-*'` で `worktree-plugin-log-userguide` が削除されている
  - `.claude/worktrees/plugin-log-userguide/` が存在しない

## ロールバック条件

- 各 checkpoint commit 後、`pnpm run check` 失敗 → 直前コミットを `git revert` し原因切り分け
- マージ時 conflict 解決が困難 → ユーザーに相談して manual resolution
