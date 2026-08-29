# Tasklist: Biome による format / lint 導入

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` / `design.md` |
| 作業 ID | 20260509-038 |

> 各タスクは**着手したら即座に `[x]` に更新する**（→ `definition-of-done.md` Phase 2）。マージタスク自体を含む全タスクが `[x]` になってから main にマージする。

---

## Phase 0: 準備

- [x] **T-0.1** worktree 作成
  - `EnterWorktree` で `add-biome-format-lint` worktree を作成
  - 作業ブランチ `worktree-add-biome-format-lint` が HEAD から自動生成される

## Phase 1: Biome 導入

- [x] **T-1.1** `biome.json` 作成
  - design.md §4.1 のとおり配置
  - includes パターンで `*.res.mjs` / `lib/` / `node_modules/` / `target/` / `examples/*/src-tauri` / `sphinx-docs` を除外

- [x] **T-1.2** ルート `package.json` 更新
  - `devDependencies` に `@biomejs/biome ^2.0.0` 追加
  - `scripts` に `format` / `format:check` / `lint` / `lint:fix` / `check` / `check:fix` 追加

- [x] **T-1.3** Biome インストール
  - `pnpm install` を実行
  - `pnpm exec biome --version` でバージョン確認

## Phase 2: 既存コードの適合

- [x] **T-2.1** `pnpm run check:fix` を実行
  - 手書き `.mjs` および JSON が Biome 設定にフォーマットされる
  - 差分内容を確認し、想定外の変更がないかレビュー

- [x] **T-2.2** lint 違反対応
  - `pnpm run lint` を実行
  - 違反があればコード側を修正する（推奨）。意味的に困難な場合のみ `biome.json` で限定的に無効化（理由を inline コメントまたは別ファイルで記録）

- [x] **T-2.3** ReScript ビルド非破壊検証
  - `pnpm --recursive build` を実行
  - `git diff -- '**/*.res.mjs'` で `*.res.mjs` に差分が出ていないことを確認
  - `git diff -- '**/lib/**'` で生成物が変更されていないことを確認

- [x] **T-2.4** 既存テスト全件パス確認
  - `pnpm --recursive test` を実行
  - 全パッケージのテストが pass することを確認（→ NFR-3）

## Phase 3: CI 統合

- [x] **T-3.1** `.github/workflows/lint-format.yml` 作成
  - design.md §6.2 のワークフロー定義に従う
  - アクション SHA は既存ワークフロー（`build-core.yml` 等）と同一の pin を使用
  - 最終 step `git diff --exit-code` で生成物の非変更を CI ゲート化

- [x] **T-3.2** ローカルで CI 相当を再現
  - `pnpm install --frozen-lockfile` → `pnpm run check` → `git diff --exit-code` の順で全 step が成功することを確認

## Phase 4: ドキュメント更新

- [x] **T-4.1** `README.md` 更新
  - Development / Code Quality セクションに format/lint コマンドを記載

- [x] **T-4.2** `docs/development-guidelines.md` 更新
  - format/lint 節を追加または既存節に追記

- [x] **T-4.3** `CLAUDE.md` 更新
  - 「ビルド・実行コマンド」節に `pnpm run check` を追記

## Phase 5: コミット

- [x] **T-5.1** 機能コミット作成
  - `biome.json` / `package.json` 変更 / `pnpm-lock.yaml` 変更 / 既存ファイルの format 適用 を 1 コミット
  - 推奨メッセージ: `🔧 Add Biome for JS format and lint`

- [x] **T-5.2** CI コミット作成
  - `.github/workflows/lint-format.yml` 追加を別コミットに分離
  - 推奨メッセージ: `🔧 Add lint-format CI workflow`

- [x] **T-5.3** ドキュメントコミット作成
  - README / docs / CLAUDE.md / steering 一式を 1 コミット
  - 推奨メッセージ: `📝 Document Biome usage and add steering 038`

## Phase 6: マージ準備

- [x] **T-6.1** 自己検証
  - `pnpm run check` がクリーン
  - `pnpm --recursive build` が成功
  - `pnpm --recursive test` が全件パス
  - `git diff -- '**/*.res.mjs' '**/lib/**'` がクリーン

- [x] **T-6.2** Definition of Done 確認
  - `.claude/rules/definition-of-done.md` の Phase 1〜3 すべて満たす

- [x] **T-6.3** tasklist 全項目 `[x]` 更新コミット
  - 本ファイル（`tasklist.md`）の全タスクを `[x]` に更新
  - マージタスク（T-7.1）自体を含む
  - 推奨メッセージ: `📝 Mark steering 038 tasks complete pre-merge`

## Phase 7: マージとクリーンアップ

- [x] **T-7.1** main へのマージ可否確認
  - `AskUserQuestion` でユーザーに main マージを確認

- [x] **T-7.2** マージ実行（承認後一括実行）
  - CWD をメインリポジトリに変更（`steering-workflow.md` の手順に厳密に従う）
  - 未追跡 `.steering/20260509-038-add-biome-format-lint/` ファイルがあれば削除
  - `git merge worktree-add-biome-format-lint --no-ff -m "Merge branch 'worktree-add-biome-format-lint' (steering 038: Biome format/lint)"`
  - `git worktree remove .claude/worktrees/add-biome-format-lint`
  - `git branch -d worktree-add-biome-format-lint`

- [x] **T-7.3** クリーンアップ検証
  - `git worktree list` が main のみ
  - `git branch --list 'worktree-*'` が空
  - `ls .claude/worktrees/` が空またはディレクトリ不在

## 補足

- テスト省略は無し（既存テストの format 修正は実装コミットに含めるため、新規テストは不要）
- セキュリティ関連変更なし（Phase 4 のセキュリティレビューは不要）
- Phase 5 のコミット粒度は要件・設計を満たす範囲で柔軟に調整可能（ただし「機能 / CI / ドキュメント」の3コミット分離は維持推奨）
