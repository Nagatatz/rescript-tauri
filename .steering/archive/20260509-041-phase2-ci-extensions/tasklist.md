# Tasklist: Phase 2 CI extensions

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-phase2-ci-extensions`) 作成 + main 取り込み
- [x] `.steering/20260509-041-phase2-ci-extensions/` 作成
- [x] `requirements.md`
- [x] `design.md`
- [x] `tasklist.md`（本ファイル）

## Phase 2: 実装

### A. schema 用 CI

- [x] `.github/workflows/tests-schema-types.yml`
- [x] `.github/workflows/tests-schema-runtime.yml`

### B. plugin-fs 用 CI

- [x] `.github/workflows/tests-plugin-fs-types.yml`
- [x] `.github/workflows/tests-plugin-fs-runtime.yml`

### C. plugin-dialog 用 CI

- [x] `.github/workflows/tests-plugin-dialog-types.yml`
- [x] `.github/workflows/tests-plugin-dialog-runtime.yml`

### D. examples-build 拡張

- [x] `.github/workflows/examples-build.yml` に 3 例題追加
  - plugin-dialog-demo
  - plugin-fs-demo
  - ipc-typed-with-schema

### E. release.yml 拡張

- [x] `on.push.tags` に `schema-v*` / `plugin-fs-v*` / `plugin-dialog-v*`
- [x] タグ→パッケージ判定ステップ (`steps.target`) 追加
- [x] build / test / publish ステップを `steps.target.outputs.*` 参照に
- [x] GitHub Release 作成条件を `refs/tags/` 全体に緩める

### F. ローカル検証

- [x] 全 YAML を text-check で確認 (環境制約で yaml.safe_load 利用不可、
      タブ・name 欠落チェックを代替実施し全件 OK)
- [x] `pnpm --recursive build` 全件成功
- [x] `pnpm --recursive test` 全件成功 (47 tests)
- [x] release.yml のタグ判定 bash を 6 ケース手動実行
  (`v0.1.0` / `v1.0.0-beta.1` / `schema-v0.1.0` /
  `plugin-fs-v1.2.3` / `plugin-dialog-v0.0.1` / `invalid-x` で fail)
- [x] schema awk 版 PUBLIC_COUNT が 4 (CHECK_COUNT=4) になることを確認、
      plugin-fs (14/15) / plugin-dialog (8/12) も既存通過確認

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [x] commit 1: `🔧 Add Phase 2 package test workflows`
  - 含む: 6 つの新規 `tests-*.yml`
- [x] commit 2: `🔧 Extend examples-build matrix with Phase 2 demos`
  - 含む: `examples-build.yml`
- [x] commit 3: `🔧 Extend release.yml for plugin/schema tags`
  - 含む: `release.yml`
- [x] commit 4 (最終): `📝 Mark steering 041 tasks complete pre-merge`
  - 含む: ステアリング 3 ファイル + tasklist 全 [x]

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [x] `git merge worktree-phase2-ci-extensions --no-ff -m "..."`
  - [x] `git worktree remove .claude/worktrees/phase2-ci-extensions`
  - [x] `git branch -d worktree-phase2-ci-extensions`

## Phase 6: 検証

- [x] `git worktree list` から phase2-ci-extensions が消える
- [x] `git branch --list 'worktree-phase2-ci-extensions'` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の
      §D / §E / §F の "CI 拡張" / "release.yml 対応" を `[x]` に更新
