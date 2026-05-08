# タスクリスト: CI workflow 実体化

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: 5 個の workflow yaml 追加 (build-core, tests-core-types, tests-core-runtime, doc-link-lint, examples-build)
- [x] 検証: 各 yaml の `name:` / `on:` 構造を head 確認（python3 yaml は環境未 install。GitHub Actions 上での実行が真の lint）
- [x] **commit 3**: .github/workflows/README.md を更新（Active に 5 個追加 / Planned 3 個に削減）
- [x] **commit 4**: tasklist 全 [x] 化
- [ ] マージ → クリーンアップ → push
