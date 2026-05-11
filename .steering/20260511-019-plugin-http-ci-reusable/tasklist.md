# Tasklist: plugin-http CI を reusable workflow に揃える

## Phase 0: 準備

- [ ] `EnterWorktree` で worktree `plugin-http-ci-reusable` を作成
- [ ] ローカル main を merge して steering 019 を取り込み

## Phase 1: workflow 書き換え

- [ ] `tests-plugin-http-types.yml` を reusable 呼び出し版に書き換え
- [ ] `tests-plugin-http-runtime.yml` を reusable 呼び出し版に書き換え

## Phase 2: 検証

- [ ] YAML 構文確認（`yq eval` or `python -c "import yaml; yaml.safe_load(...)"`)
- [ ] 既存 REUSABLE 版 (`tests-plugin-log-{types,runtime}.yml`) と structural diff を取り、`package-name` 以外で差分が無いことを確認

## Phase 3: コミット

- [ ] 機能単位でコミット:
  - 🔧 Align tests-plugin-http workflows with reusable _test-package-*.yml

## Phase 4: マージ

- [ ] `tasklist.md` の全タスクを `[x]` に更新（マージタスク自体含む）してコミット
- [ ] `AskUserQuestion` でユーザーに main マージ可否を確認
- [ ] 承認後、main マージ → worktree 削除 → ブランチ削除 を一括実行
- [ ] クリーンアップ完了の検証
