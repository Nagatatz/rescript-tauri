# Steering 058: Tasklist — CI ワークフロー集約

## Phase 1: 計画
- [x] requirements.md / design.md / tasklist.md 作成
- [x] EnterWorktree で `worktree-refactor-ci-workflow-consolidation` 作成

## Phase 2: 実装

### Task 1: reusable workflow 2 ファイルを新設
- [x] `.github/workflows/_test-package-runtime.yml` 作成
- [x] `.github/workflows/_test-package-types.yml` 作成 (public-symbol coverage 検証 Bash を内包、`PKG_PATH` 環境変数経由でパス渡し)
- [x] YAML 構文チェック (Python yaml モジュール)
- [x] コミット: `🔧 Add reusable workflows _test-package-{runtime,types}.yml`

### Task 2: 既存 16 ワークフローを薄い wrapper に書き換え

8 パッケージ × runtime/types を機械的に書き換える。1 コミットで全件:

- [x] `tests-core-runtime.yml`
- [x] `tests-core-types.yml`
- [x] `tests-plugin-fs-runtime.yml`
- [x] `tests-plugin-fs-types.yml`
- [x] `tests-plugin-dialog-runtime.yml`
- [x] `tests-plugin-dialog-types.yml`
- [x] `tests-plugin-shell-runtime.yml`
- [x] `tests-plugin-shell-types.yml`
- [x] `tests-plugin-notification-runtime.yml`
- [x] `tests-plugin-notification-types.yml`
- [x] `tests-plugin-log-runtime.yml`
- [x] `tests-plugin-log-types.yml`
- [x] `tests-plugin-os-runtime.yml`
- [x] `tests-plugin-os-types.yml`
- [x] `tests-plugin-clipboard-manager-runtime.yml`
- [x] `tests-plugin-clipboard-manager-types.yml`
- [x] `tests-schema-runtime.yml`
- [x] `tests-schema-types.yml`
- [x] 全ファイルの YAML 構文チェック
- [x] reusable workflow 側の `inputs:` と wrapper 側の `with:` が一致することを grep で検証
- [x] コミット: `♻️ Migrate plugin/schema test workflows to reusable workflow_call`

### Task 3: ドキュメント更新
- [x] `docs/repository-structure.md` の `.github/workflows/` 説明に reusable workflow の存在を追記
- [x] コミット: `📝 Document reusable workflow pattern in repository-structure`

## Phase 3: マージ前
- [x] tasklist.md の全タスクを `[x]` に更新
- [x] `git diff --stat origin/main..HEAD` で純減 200 行以上を確認
- [x] 最終コミット (tasklist 更新)

## Phase 4: マージ・クリーンアップ
- [x] AskUserQuestion で main へのマージ可否を確認
- [x] CWD を main repo へ移動 (ExitWorktree)
- [x] `git merge worktree-refactor-ci-workflow-consolidation --no-ff`
- [x] worktree 削除 / ブランチ削除 / 検証
