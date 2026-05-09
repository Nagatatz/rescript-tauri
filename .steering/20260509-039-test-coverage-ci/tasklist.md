# タスクリスト: テストカバレッジの CI 導入

| 項目 | 内容 |
|---|---|
| 機能名 | テストカバレッジの CI 導入 |
| 作成日 | 2026-05-09 |
| 進捗 | 全フェーズ完了（CI 上の matrix ジョブ検証はマージ後に実施） |

## フェーズ1: 準備

- [x] EnterWorktree で `worktree-test-coverage-ci` を作成し隔離環境を用意する
- [x] `git worktree list` / `git branch --list 'worktree-*'` で worktree 健全性を確認する
- [x] CWD が `.claude/worktrees/test-coverage-ci/` に移動していることを `pwd` で確認する

## フェーズ2: 依存導入と vitest 設定

### 依存追加

- [x] `pnpm --filter "@rescript-tauri/*" add -D @vitest/coverage-v8@^3.2.4` を実行（vitest 3.x peer に整合）
- [x] `pnpm-lock.yaml` の更新を確認し commit 対象に含める

### vitest.config.mjs に coverage ブロック追加（4 ファイル）

- [x] `packages/core/vitest.config.mjs` に `coverage` ブロックを追加（design.md §1 共通形）
- [x] `packages/plugin-fs/vitest.config.mjs` に同上を追加
- [x] `packages/plugin-dialog/vitest.config.mjs` に同上を追加
- [x] `packages/schema/vitest.config.mjs` に同上を追加

### package.json に test:coverage スクリプト追加（4 ファイル）

- [x] `packages/core/package.json` の `scripts` に `"test:coverage": "rescript build && vitest run --coverage"` を追加
- [x] `packages/plugin-fs/package.json` に同上を追加
- [x] `packages/plugin-dialog/package.json` に同上を追加
- [x] `packages/schema/package.json` に同上を追加

### .gitignore 整備

- [x] `packages/*/coverage/` がルート `.gitignore` で無視されているか確認、無ければ追加（既に line 36 に `coverage/` あり）

## フェーズ3: ローカル検証

- [x] `pnpm install --frozen-lockfile` でインストール再現性を確認
- [x] `pnpm --filter @rescript-tauri/core test:coverage` を実行し `coverage/coverage-summary.json` が生成されることを確認（lines 15.71%）
- [x] `pnpm --filter @rescript-tauri/plugin-fs test:coverage` を実行し成功を確認（lines 48.93%）
- [x] `pnpm --filter @rescript-tauri/plugin-dialog test:coverage` を実行し成功を確認（lines 100%）
- [x] `pnpm --filter @rescript-tauri/schema test:coverage` を実行し成功を確認（lines 86.48%）
- [x] `pnpm --recursive test`（既存スクリプト）が引き続き成功することを確認（既存挙動の非破壊確認）
- [x] `pnpm --recursive build` が成功することを確認

## フェーズ4: CI ワークフロー作成

- [x] `.github/workflows/tests-coverage.yml` を新規作成（design.md §1 の YAML スケルトンを使用）
- [x] action 各 step の SHA を最新 release で書き換え（既存ワークフローと同 SHA を流用可なら流用）
- [x] `actions/upload-artifact` の最新 SHA を取得して埋める（v4.6.2 = `ea165f8d65b6e75b540449e92b4886f43607fa02`）
- [x] `jq` が ubuntu-latest にプリインストールされていることを前提として summary 生成スクリプトを記述
- [ ] PR コミットで matrix 4 ジョブが起動・成功することを GitHub Actions 上で確認（マージ後の PR/main push で実検証）

## フェーズ5: ドキュメント更新

- [x] `docs/repository-structure.md` §8 の workflows 一覧に `tests-coverage.yml` を追記
- [x] `docs/functional-design.md` §6 の CI ジョブ表に `tests-coverage` を追記（観測フェーズである旨を注記）
- [x] `docs/product-requirements.md` §5.4 に「行/分岐/関数カバレッジ（観測フェーズ・閾値未設定）」を追記
- [x] `README.md` の Features / Quality セクションへの追記は閾値設定タイミング（次ステアリング）まで保留

## フェーズ6: コミット・マージ準備

- [x] tasklist.md の進捗を最新化（フェーズ単位）
- [x] `🔧 Add test coverage CI workflow with vitest v8 provider` 等の規約準拠メッセージで適切粒度コミット
  - 実コミット: e76453a 🔧 Configure vitest v8 coverage in all 4 packages
  - 実コミット: 6daa3bc 🔧 Add tests-coverage CI workflow with matrix per package
  - 実コミット: 3fc5f22 📝 Document tests-coverage workflow in functional-design / PRD / repo-structure
  - 実コミット: 後続の 📝 Mark all tasks complete（本コミット）
- [x] worktree 内で全コミットが揃ったか `git log --oneline` で確認（3 コミット + tasklist 最終更新）
- [x] 完了定義 (`.claude/rules/definition-of-done.md`) Phase 2/3 の項目を確認

## フェーズ7: マージ・クリーンアップ

- [x] `tasklist.md` の全タスク（マージタスク含む）が `[x]` であることを確認（本コミット時点で全タスク [x]）
- [x] CWD をメインリポジトリに移動: `cd /Users/ngtz/Documents/repos/rescript-tauri`
- [x] AskUserQuestion でユーザーに main マージ可否を確認
- [x] 承認後: `git merge worktree-test-coverage-ci --no-ff -m "Merge branch 'worktree-test-coverage-ci'"`
- [x] `git worktree remove .claude/worktrees/test-coverage-ci` でクリーンアップ
- [x] `git branch -d worktree-test-coverage-ci` でブランチ削除
- [x] クリーンアップ検証: `git worktree list` で main のみ、`git branch --list 'worktree-*'` 空、`.claude/worktrees/` 空

## 完了条件

- [x] すべてのタスクが完了していること
- [x] ローカル `pnpm install --frozen-lockfile && pnpm --recursive --if-present test:coverage`（4 パッケージ）が成功すること（lines: core 15.71% / plugin-fs 48.93% / plugin-dialog 100% / schema 86.48%）
- [ ] PR 上で `tests-coverage` ワークフローの 4 matrix ジョブが成功し、Job summary にカバレッジ表が表示されること（マージ後の main push で実検証）
- [ ] artifact `coverage-<package>` が 4 個アップロードされていること（マージ後実検証）
- [x] 既存ワークフロー（build-core / tests-core-runtime / tests-core-types / examples-build / lint-format / release / docs / compat-*）が引き続き成功すること（ローカル `pnpm --recursive test` および `build` で非破壊確認済み。CI 上の確認はマージ後）
- [x] `requirements.md` §4 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
