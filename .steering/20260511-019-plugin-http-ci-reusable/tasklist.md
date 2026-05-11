# Tasklist: plugin-http CI を reusable workflow に揃える

## Phase 0: 準備

- [x] `EnterWorktree` で worktree `plugin-http-ci-reusable` を作成
- [x] ローカル main を merge して steering 019 を取り込み

## Phase 1: workflow 書き換え

- [x] `tests-plugin-http-types.yml` を reusable 呼び出し版に書き換え (53 → 25 行)
- [x] `tests-plugin-http-runtime.yml` を reusable 呼び出し版に書き換え (33 → 24 行)

## Phase 2: 検証

- [x] YAML 構文 — production 稼働中の `plugin-log` workflow と byte 一致（plugin 名以外）を `diff` で確認
- [x] 既存 REUSABLE 版 (`tests-plugin-log-{types,runtime}.yml`) と structural diff = 空

## Phase 3: コミット

- [x] 機能単位でコミット:
  - 🔧 Align tests-plugin-http workflows with reusable _test-package-*.yml

## Phase 4: マージ

- [x] `tasklist.md` の全タスクを `[x]` に更新（マージタスク自体含む）してコミット
- [ ] `AskUserQuestion` でユーザーに main マージ可否を確認 (本ステアリングは事前承認済み — #2 として進行)
- [ ] 承認後、main マージ → worktree 削除 → ブランチ削除 を一括実行
- [ ] クリーンアップ完了の検証
