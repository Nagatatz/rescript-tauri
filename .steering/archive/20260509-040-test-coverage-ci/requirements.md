# 要求定義: テストカバレッジの CI 導入

| 項目 | 内容 |
|---|---|
| 機能名 | テストカバレッジの CI 導入 |
| 作成日 | 2026-05-09 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

- 現在 vitest のランタイムテストは存在するが、行・分岐・関数カバレッジは計測されていない（4 パッケージとも素の `vitest run`）。
- CI で runtime テストが走るのは **`@rescript-tauri/core` のみ**（`tests-core-runtime.yml`）。`plugin-fs` / `plugin-dialog` / `schema` の vitest は CI 上で実行されておらず、テストの劣化に気付けない。
- PRD §5.4 / architecture.md §保守性で言及される「100% カバレッジ」は **`.resi` 公開シンボルの grep ベース参照カバレッジ** であり、本ステアリングが扱う行/分岐カバレッジとは別概念。本機能は両者を共存させる。

### 目的

1. 全公開パッケージ（core / plugin-fs / plugin-dialog / schema）の vitest ランタイムテストの **行・分岐・関数カバレッジ** を CI で計測する。
2. プラグイン系パッケージの runtime テストを CI 上で恒常的に実行する（副次効果）。
3. ベースラインの可視化に集中し、**初期はカバレッジしきい値による fail ゲートを設けない**（observation phase）。閾値設定は次フェーズで別ステアリング化する。

## 2. 変更・追加する機能の説明

- 各パッケージの `vitest.config.mjs` に coverage 設定を追加する（プロバイダ・対象ファイル・レポータ）。
- 各パッケージの `package.json` に `test:coverage` スクリプトを追加する（既存の `test` は破壊しない）。
- 新規 GitHub Actions ワークフロー `.github/workflows/tests-coverage.yml` を追加し、**4 パッケージを matrix で並列実行** してカバレッジレポートを生成する。
- レポートは以下の 2 形態で出す:
  - **Job summary**: text-summary レポータの出力を `$GITHUB_STEP_SUMMARY` に書き込む（PR 上で一覧視認）
  - **Artifact**: LCOV / HTML を artifact としてアップロード（30 日保持。ダウンロードしてローカルで詳細確認可能）
- 外部サービス（Codecov / Coveralls 等）連携は **本ステアリングの対象外**。トークン管理が必要なため別ステアリングで扱う。
- 既存の `tests-core-runtime.yml` は廃止せず据え置く（path フィルタが core 限定で coverage CI と粒度が異なるため重複コストは小）。重複と判断した場合の整理は次フェーズで検討。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | コントリビュータ | PR を作成する | tests-coverage ジョブが各パッケージのカバレッジ % をジョブサマリで提示する |
| 2 | コントリビュータ | 詳細を確認したい | Actions の artifact から LCOV / HTML をダウンロードできる |
| 3 | メンテナ | 新規パッケージを追加する | 既存 4 パッケージと同じ手順で coverage 設定を追加できる（手順の再現性） |
| 4 | メンテナ | テスト追加によるカバレッジ向上を確認したい | PR 前後で job summary の数値を比較できる |

## 4. 受け入れ条件

- [ ] 4 パッケージすべての `vitest.config.mjs` に coverage 設定が追加されている
- [ ] 4 パッケージすべての `package.json` に `test:coverage` スクリプトが追加されている
- [ ] `pnpm --filter <pkg> test:coverage` がローカルで成功する（4 パッケージ）
- [ ] `.github/workflows/tests-coverage.yml` が PR / push (main) で起動する
- [ ] CI ジョブが 4 パッケージを matrix で並列実行する
- [ ] CI ジョブサマリに各パッケージの行/分岐/関数カバレッジ % が表示される
- [ ] LCOV / HTML レポートが artifact として 30 日保持される
- [ ] **本ステアリングではしきい値を強制しない**（`coverageThreshold` 等で fail させない）
- [ ] 既存ワークフロー（build-core / tests-core-runtime / tests-core-types など）の挙動が壊れていない
- [ ] `docs/repository-structure.md` の `.github/workflows/` 一覧に新規ワークフローを追記している
- [ ] `docs/functional-design.md` §6 の CI ジョブ表に新規ジョブを追記している
- [ ] `docs/product-requirements.md` の品質指標セクションに、行/分岐カバレッジは「観測フェーズ・閾値未設定」と明記している

## 5. 制約事項

### 技術的制約

- ReScript 12.x の生成物 `*.res.mjs` を計測対象とする（`*.res` ソース原本は実行されない）。
- vitest 公式の `@vitest/coverage-v8` プロバイダを採用する（istanbul プロバイダは追加変換コストがあり、最小依存原則に反する）。
- happy-dom 環境で動作するため、Node.js v8 coverage の標準仕様で問題ない見込み。

### スケジュール / スコープ制約

- Codecov / Coveralls 等の外部サービス連携は **対象外**。
- カバレッジしきい値による fail ゲートは **対象外**（次フェーズで別ステアリング）。
- 既存の `tests-core-runtime.yml` の整理・統合は **対象外**。
- 例題（`examples/*/`）はテストを持たないため対象外（PRD §5.4 のビルドゲートは現状維持）。

### 互換性要件

- 既存の `pnpm --recursive test` および `pnpm --filter <pkg> test` の挙動を破壊しない（`test:coverage` は別スクリプトとして追加）。
- pnpm workspace / Node 24 / Tauri 2.x の前提は変更しない。

## 6. 関連ドキュメント

- `docs/product-requirements.md` §5.4（品質指標 / `.resi` シンボルカバレッジ）
- `docs/functional-design.md` §6（CI ジョブ一覧）
- `docs/architecture.md` §保守性
- `docs/repository-structure.md` §8（`.github/workflows/`）
- `.github/workflows/tests-core-runtime.yml`（既存 runtime テストワークフロー、参考）
- `.github/workflows/tests-core-types.yml`（既存「シンボル参照カバレッジ」ジョブ、本機能とは別系統）
