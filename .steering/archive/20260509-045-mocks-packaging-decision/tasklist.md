# Tasklist: Mocks packaging decision (PRD §10 #5)

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-prd-mocks-decision`) 作成 + main 取り込み
- [x] `.steering/20260509-045-mocks-packaging-decision/` 作成
- [x] `requirements.md`
- [x] `design.md`（決定 + 代替案比較 + 再評価トリガ）
- [x] `tasklist.md`（本ファイル）

## Phase 2: 実装

### A. PRD / functional-design 更新

- [x] `docs/product-requirements.md` §10 #5 行を確定済に
- [x] `docs/functional-design.md` §10 #5 行を同期

### B. 任意更新

- [x] `docs/architecture.md` §7.2 に方針追記
- [x] `packages/core/src/Mocks.resi` の冒頭 doc-comment に方針追記

### C. 検証

- [x] PRD で `確定済み` が #1 / #5 / #7 の 3 件 にヒット
- [x] functional-design.md §10 が PRD と一致
- [x] `pnpm --recursive build` regression なし
- [x] `pnpm --recursive test` 全件パス (47 tests)

> 単体テスト省略の理由: 設計判断のドキュメント変更のみで実コード
> 非対象 (`testing.md` 例外節)。

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [x] commit 1: `📝 Confirm Mocks packaging decision (PRD §10 #5)`
  - 含む: PRD / functional-design / architecture /
    Mocks.resi doc-comment 追記
- [x] commit 2 (最終): `📝 Mark steering 045 tasks complete pre-merge`
  - 含む: ステアリング 3 ファイル + tasklist 全 [x]

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [x] `git merge worktree-prd-mocks-decision --no-ff -m "..."`
  - [x] `git worktree remove .claude/worktrees/prd-mocks-decision`
  - [x] `git branch -d worktree-prd-mocks-decision`

## Phase 6: 検証

- [x] `git worktree list` から prd-mocks-decision が消える
- [x] `git branch --list 'worktree-prd-mocks-decision'` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の §I
      `PRD §10 残課題 #5 が「確定済み」に` を `[x]` に更新
