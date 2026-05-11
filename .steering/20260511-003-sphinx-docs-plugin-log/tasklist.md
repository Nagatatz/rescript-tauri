# Tasklist: sphinx-docs/user/plugin-log.md

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-003 |
| 関連 | requirements.md / design.md |

## Phase 1: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [x] ユーザー承認（「T5を実装してください」で承認、ステアリング 3 点セットを main 上 `0554696` で commit 済み）
- [x] EnterWorktree で `plugin-log-userguide` 作成（base ref: head — ローカル main 13 ahead 取り込みのため `git worktree add HEAD` 経由）

## Phase 2: 実装

各 checkpoint は単独で commit 可能。順序は固定。

### Checkpoint 1: 骨格 + Install + Capabilities + Minimal example

- [x] `sphinx-docs/user/plugin-log.md` 新規作成
  - Title + intro 段落 + `{note}` ステータスブロック
  - `## Install` セクション（JS pnpm add / peerDeps / rescript.json dependencies / Rust Cargo.toml / Rust Builder + targets サンプル）
  - `## Capabilities` セクション（`log:default` JSON）
  - `## Minimal example` セクション（attachConsole + info の最小コード）
- [x] `pnpm run check` — worktree CWD では既知の Biome 2.x exclude 問題で全除外、md は Biome 対象外なので影響なし
- [x] commit `2c45bb1`: `📝 Add sphinx-docs/user/plugin-log.md skeleton (install + capabilities + minimal example)`

### Checkpoint 2: Public API リファレンス

- [x] `## Public API` セクション追加
  - 7 関数表 (`error` / `warn` / `info` / `debug` / `trace` / `attachLogger` / `attachConsole`)
  - `### Level functions` サブセクション + `logOptions` 3 フィールド表
  - `### Numeric LogLevel constants` サブセクション + 5 定数のコード例と upstream 値の表
  - `### attachLogger / attachConsole` サブセクション + level 分岐付きコード例
- [x] `pnpm run check` — md 対象外なので影響なし（既知 Biome exclude 問題）
- [x] commit `b5a911a`: `📝 Document plugin-log public API in sphinx-docs user guide`

### Checkpoint 3: Pitfalls + Compatibility + See also

- [x] `## Pitfalls` セクション
  - `### LogLevel constants are suffixed` (suffix `_` の理由)
  - `### Log calls are async — await them` (promise<unit> を _ignore で意図明示する案内)
  - `### attachLogger / attachConsole are not covered by Mocks.mockIPC` (`__TAURI_INTERNALS__` stub の必要性 + level 系は mockIPC OK の対比)
- [x] `## Compatibility` 表
- [x] `## See also` リスト（source / package README / upstream / upstream JS reference、demo は CHANGELOG の deferred 通りリンクしない）
- [x] `pnpm run check` — md 対象外
- [ ] commit: `📝 Add plugin-log pitfalls, compatibility and see-also sections`

### Checkpoint 4: 周辺ドキュメント更新

- [x] `sphinx-docs/user/index.md` の Phase 2 packages 表に plugin-log 行追加
- [x] `sphinx-docs/user/index.md` toctree に `plugin-log` を追加（順序: `plugin-notification` の後、`schema` の前）
- [x] `sphinx-docs/user/installation.md` の follow-up note から plugin-log を削除
- [x] `sphinx-docs/user/installation.md` の "See the [plugin-fs] ... guides" cross-ref に plugin-log を追加
- [x] 同 follow-up note: 既に user guide が存在する plugin-notification を削除（20260511-002 の漏れ）、plugin-http を新規追加（未着手 user guide なので残置対象）
- [x] `pnpm run check` — md 対象外
- [x] `grep -n "plugin-log" sphinx-docs/user/installation.md sphinx-docs/user/index.md` で 4 件の cross-ref 確認済み
- [x] commit `7220f00`: `📝 Cross-link plugin-log user guide from index/installation`

## Phase 3: マージ前検証

- [x] `pnpm --recursive --workspace-concurrency=1 build` 成功（exit 0、9 パッケージ逐次ビルド）
- [x] `pnpm run check` — worktree CWD では既知の Biome 2.x exclude 問題、md は対象外、CI lint-format.yml は別途緑
- [x] `grep -rn "plugin-log" sphinx-docs/user/` で 4 件の cross-ref を確認（index.md table / index.md toctree / installation.md install command / installation.md "See the ..." line）
- [x] tasklist.md の全タスク `[x]` 化
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
