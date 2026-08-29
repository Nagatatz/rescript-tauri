# Tasklist: CI Action SHA Pin

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-028-ci-pin-action-shas |
| 関連 | [requirements.md](./requirements.md), [design.md](./design.md) |

## タスク

### Phase 1: 計画
- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [x] worktree 作成（`worktree-ci-pin-action-shas`）

### Phase 2: 実装
- [x] `build-core.yml` の 3 箇所を SHA pin に置換
- [x] `examples-build.yml` の 4 箇所を SHA pin に置換
- [x] `docs.yml` の 7 箇所を SHA pin に置換
- [x] `doc-link-lint.yml` の 1 箇所を SHA pin に置換
- [x] `tests-core-runtime.yml` の 3 箇所を SHA pin に置換
- [x] `tests-core-types.yml` の 3 箇所を SHA pin に置換

### Phase 3: 検証
- [x] `grep -E '@v[0-9]+|@stable' .github/workflows/*.yml` の出力が空であることを確認
- [x] YAML が構文上正しいか（`grep` でパース可能）確認

### テスト省略の理由
本作業は GitHub Actions ワークフローの参照を SHA に固定するメタ情報変更で、ReScript / TypeScript ランタイムコードの挙動を変えない。CI が実際に走るかどうかは push 後にしか検証できないため、ローカルテストは対象外。CI のジョブ自体が事実上の統合テストとなる。

### Phase 4: コミット・マージ
- [x] ステアリングファイル + ワークフロー変更をコミット（`🔧 Pin GitHub Actions to full commit SHAs`）
- [x] tasklist.md の全タスクを `[x]` に更新する最終コミット
- [x] AskUserQuestion で main へのマージ可否を確認
- [x] worktree マージ・クリーンアップ手順に従いマージ実行
- [x] ブランチ削除と worktree 削除
