# Tasklist: CI Follow-up — pnpm Version Conflict & Sphinx Pytest Empty-collection

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-030-ci-pnpm-and-pytest-fix |
| 関連 | [requirements.md](./requirements.md), [design.md](./design.md) |

## タスク

### Phase 1: 計画
- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [x] worktree 作成（`worktree-ci-pnpm-and-pytest-fix`）
- [x] 番号衝突を解消（029 → 030 にリナンバー）

### Phase 2: 実装

#### 2.1 pnpm `version: 10` 削除（7 ファイル）
- [x] `build-core.yml` から `with: version: 10` 削除
- [x] `examples-build.yml` から `with: version: 10` 削除
- [x] `tests-core-runtime.yml` から `with: version: 10` 削除
- [x] `tests-core-types.yml` から `with: version: 10` 削除
- [x] `compat-rescript-prerelease.yml` から `with: version: 10` 削除
- [x] `compat-tauri-latest.yml` から `with: version: 10` 削除
- [x] `release.yml` から `with: version: 10` 削除

#### 2.2 docs.yml pytest ガード
- [x] `docs.yml` の Pytest ステップに `if: hashFiles(...)` を追加

### Phase 3: 検証
- [x] `grep -nE 'version: 10' .github/workflows/*.yml` の出力が空であることを確認
- [x] `docs.yml` の Pytest ステップに `if:` 行が追加されていることを確認

### テスト省略の理由
本作業は GitHub Actions ワークフロー設定の修正で、ReScript / TypeScript ランタイムコードの挙動を変えない。ワークフロー実行は push 後の CI でしか検証できないため、ローカル単体テストは対象外。CI ジョブ自体が事実上の統合テスト。

### Phase 4: コミット・マージ
- [x] ステアリングファイル + ワークフロー変更をコミット（`🔧 Fix CI: drop redundant pnpm version, guard empty pytest collection`）
- [x] tasklist.md の全タスクを `[x]` に更新
- [x] AskUserQuestion で main マージ可否を確認
- [x] worktree マージ・クリーンアップ手順に従い実行
- [x] ブランチ・worktree 削除
- [x] ユーザーに push を依頼
