# タスクリスト: テストカバレッジの CI 導入

| 項目 | 内容 |
|---|---|
| 機能名 | テストカバレッジの CI 導入 |
| 作成日 | 2026-05-09 |
| 進捗 | 0 / 31 完了 |

## フェーズ1: 準備

- [ ] EnterWorktree で `worktree-test-coverage-ci` を作成し隔離環境を用意する
- [ ] `git worktree list` / `git branch --list 'worktree-*'` で worktree 健全性を確認する
- [ ] CWD が `.claude/worktrees/test-coverage-ci/` に移動していることを `pwd` で確認する

## フェーズ2: 依存導入と vitest 設定

### 依存追加

- [ ] `pnpm --filter @rescript-tauri/core add -D @vitest/coverage-v8` を実行
- [ ] `pnpm --filter @rescript-tauri/plugin-fs add -D @vitest/coverage-v8` を実行
- [ ] `pnpm --filter @rescript-tauri/plugin-dialog add -D @vitest/coverage-v8` を実行
- [ ] `pnpm --filter @rescript-tauri/schema add -D @vitest/coverage-v8` を実行
- [ ] `pnpm-lock.yaml` の更新を確認し commit 対象に含める

### vitest.config.mjs に coverage ブロック追加（4 ファイル）

- [ ] `packages/core/vitest.config.mjs` に `coverage` ブロックを追加（design.md §1 共通形）
- [ ] `packages/plugin-fs/vitest.config.mjs` に同上を追加
- [ ] `packages/plugin-dialog/vitest.config.mjs` に同上を追加
- [ ] `packages/schema/vitest.config.mjs` に同上を追加

### package.json に test:coverage スクリプト追加（4 ファイル）

- [ ] `packages/core/package.json` の `scripts` に `"test:coverage": "rescript build && vitest run --coverage"` を追加
- [ ] `packages/plugin-fs/package.json` に同上を追加
- [ ] `packages/plugin-dialog/package.json` に同上を追加
- [ ] `packages/schema/package.json` に同上を追加

### .gitignore 整備

- [ ] `packages/*/coverage/` がルート `.gitignore` で無視されているか確認、無ければ追加

## フェーズ3: ローカル検証

- [ ] `pnpm install --frozen-lockfile` でインストール再現性を確認
- [ ] `pnpm --filter @rescript-tauri/core test:coverage` を実行し `coverage/coverage-summary.json` が生成されることを確認
- [ ] `pnpm --filter @rescript-tauri/plugin-fs test:coverage` を実行し成功を確認
- [ ] `pnpm --filter @rescript-tauri/plugin-dialog test:coverage` を実行し成功を確認
- [ ] `pnpm --filter @rescript-tauri/schema test:coverage` を実行し成功を確認
- [ ] `pnpm --recursive test`（既存スクリプト）が引き続き成功することを確認（既存挙動の非破壊確認）
- [ ] `pnpm --recursive build` が成功することを確認

## フェーズ4: CI ワークフロー作成

- [ ] `.github/workflows/tests-coverage.yml` を新規作成（design.md §1 の YAML スケルトンを使用）
- [ ] action 各 step の SHA を最新 release で書き換え（既存ワークフローと同 SHA を流用可なら流用）
- [ ] `actions/upload-artifact` の最新 SHA を取得して埋める
- [ ] `jq` が ubuntu-latest にプリインストールされていることを前提として summary 生成スクリプトを記述
- [ ] PR コミットで matrix 4 ジョブが起動・成功することを GitHub Actions 上で確認

## フェーズ5: ドキュメント更新

- [ ] `docs/repository-structure.md` §8 の workflows 一覧に `tests-coverage.yml` を追記
- [ ] `docs/functional-design.md` §6 の CI ジョブ表に `tests-coverage` を追記（観測フェーズである旨を注記）
- [ ] `docs/product-requirements.md` の品質指標セクションに「行/分岐カバレッジ: 観測フェーズ・閾値未設定（次フェーズで設定）」を追記
- [ ] `README.md` の Features / Quality セクションに簡潔に追記（必要なら）

## フェーズ6: コミット・マージ準備

- [ ] tasklist.md の進捗を最新化（フェーズ単位）
- [ ] `🔧 Add test coverage CI workflow with vitest v8 provider` 等の規約準拠メッセージで適切粒度コミット
  - コミット案: ①依存追加 + vitest.config + scripts、②CI ワークフロー、③ドキュメント更新、④tasklist 最終更新
- [ ] worktree 内で全コミットが揃ったか `git log --oneline` で確認
- [ ] 完了定義 (`.claude/rules/definition-of-done.md`) Phase 2/3 の項目を確認

## フェーズ7: マージ・クリーンアップ

- [ ] `tasklist.md` の全タスク（マージタスク含む）が `[x]` であることを確認
- [ ] CWD をメインリポジトリに移動: `cd /Users/ngtz/Documents/repos/rescript-tauri`
- [ ] AskUserQuestion でユーザーに main マージ可否を確認
- [ ] 承認後: `git merge worktree-test-coverage-ci --no-ff -m "Merge branch 'worktree-test-coverage-ci'"`
- [ ] `git worktree remove .claude/worktrees/test-coverage-ci` でクリーンアップ
- [ ] `git branch -d worktree-test-coverage-ci` でブランチ削除
- [ ] クリーンアップ検証: `git worktree list` で main のみ、`git branch --list 'worktree-*'` 空、`.claude/worktrees/` 空

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] ローカル `pnpm install --frozen-lockfile && pnpm --recursive --if-present test:coverage`（4 パッケージ）が成功すること
- [ ] PR 上で `tests-coverage` ワークフローの 4 matrix ジョブが成功し、Job summary にカバレッジ表が表示されること
- [ ] artifact `coverage-<package>` が 4 個アップロードされていること
- [ ] 既存ワークフロー（build-core / tests-core-runtime / tests-core-types / examples-build / lint-format / release / docs / compat-*）が引き続き成功すること
- [ ] `requirements.md` §4 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
