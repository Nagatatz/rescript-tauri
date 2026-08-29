# 設計: テストカバレッジの CI 導入

| 項目 | 内容 |
|---|---|
| 機能名 | テストカバレッジの CI 導入 |
| 作成日 | 2026-05-09 |

## 1. 実装アプローチ

### 全体方針

- **vitest 標準プロバイダで完結**: `@vitest/coverage-v8` を 4 パッケージの devDependency に追加。Node v8 の coverage 機能をそのまま利用するため、追加の AST 変換やビルドステップは不要。
- **計測対象は ReScript 生成物**: `src/**/*.res.mjs` を `coverage.include` 対象とする。`.res` 原本は実行されないため計測しない。`*.res.mjs` の関数名・行番号は `.res` ソースと厳密に一致しないが、まずは「観測のためのカバレッジ可視化」が目的のため許容する。
- **既存スクリプトを破壊しない**: `pnpm test` の挙動は変えず、`pnpm test:coverage` を新規追加する。`pnpm --recursive test` を使う既存ワークフロー（`tests-core-runtime.yml`）は影響を受けない。
- **CI は単一新規ワークフロー + matrix**: `.github/workflows/tests-coverage.yml` を新設し、4 パッケージを `strategy.matrix` で並列実行。各ジョブで `pnpm --filter <pkg> test:coverage` を呼び、`coverage/` ディレクトリを artifact 化、`coverage/coverage-summary.json` を job summary に整形して書き出す。
- **しきい値ゲートは導入しない**: `coverage.thresholds` は設定しない。fail させるのは「テスト実行自体の失敗」のみ。

### vitest coverage 設定の共通形

各パッケージの `vitest.config.mjs` に以下のブロックを追加する（include パスはパッケージ名で異なる）:

```js
coverage: {
  provider: "v8",
  include: ["src/**/*.res.mjs"],
  exclude: ["src/**/*.test.mjs", "tests/**", "node_modules/**", "lib/**"],
  reporter: ["text-summary", "json-summary", "lcov", "html"],
  reportsDirectory: "./coverage",
  reportOnFailure: false,
  thresholds: undefined,
}
```

- `text-summary`: CI ログおよび job summary 用の短いテキスト
- `json-summary`: `coverage-summary.json` を吐き、Bash で抽出して `$GITHUB_STEP_SUMMARY` に書き込む
- `lcov`: artifact として保存し、ローカルで詳細閲覧
- `html`: artifact として保存し、ブラウザで閲覧
- `reportsDirectory: "./coverage"` で各パッケージの `packages/<pkg>/coverage/` に出力

### CI ワークフロー設計

```yaml
name: tests-coverage

on:
  push:
    branches: [main]
    paths:
      - "packages/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/tests-coverage.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/**"
      - "pnpm-lock.yaml"

permissions:
  contents: read

jobs:
  coverage:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        package:
          - core
          - plugin-fs
          - plugin-dialog
          - schema
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: pnpm/action-setup@a15d269cd4658e1107c09f1fabf4cbd7bd1f308a # v4.4.0
      - uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0
        with:
          node-version: 24
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Run coverage
        run: pnpm --filter @rescript-tauri/${{ matrix.package }} test:coverage
      - name: Write summary
        if: always()
        shell: bash
        run: |
          set -euo pipefail
          summary="packages/${{ matrix.package }}/coverage/coverage-summary.json"
          if [ ! -f "$summary" ]; then
            echo "::warning::No coverage-summary.json for ${{ matrix.package }}"
            exit 0
          fi
          {
            echo "## Coverage: @rescript-tauri/${{ matrix.package }}"
            echo ""
            echo "| Metric | % | Covered / Total |"
            echo "|---|---|---|"
            jq -r '
              .total |
              to_entries[] |
              select(.key=="lines" or .key=="statements" or .key=="branches" or .key=="functions") |
              "| \(.key) | \(.value.pct)% | \(.value.covered) / \(.value.total) |"
            ' "$summary"
          } >> "$GITHUB_STEP_SUMMARY"
      - name: Upload coverage artifact
        if: always()
        uses: actions/upload-artifact@<pinned sha>
        with:
          name: coverage-${{ matrix.package }}
          path: packages/${{ matrix.package }}/coverage/
          retention-days: 30
          if-no-files-found: warn
```

action SHA のピン留めは既存 CI 規約（steering 028）に従い、本ステアリング実装時に最新 release SHA を採用して書き換える。

### Job summary の表示例

PR の Actions タブ「Summary」に各 matrix ジョブのサマリが累積表示される:

```
## Coverage: @rescript-tauri/core
| Metric     | %    | Covered / Total |
|------------|------|-----------------|
| lines      | 78.4 | 245 / 312       |
| statements | 78.4 | 245 / 312       |
| branches   | 65.2 | 60 / 92         |
| functions  | 81.0 | 51 / 63         |
```

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `packages/core/vitest.config.mjs` | `coverage` ブロック追加 | 修正 |
| `packages/core/package.json` | `test:coverage` スクリプト追加、`@vitest/coverage-v8` を devDependencies に追加 | 修正 |
| `packages/plugin-fs/vitest.config.mjs` | `coverage` ブロック追加 | 修正 |
| `packages/plugin-fs/package.json` | `test:coverage` スクリプト追加、`@vitest/coverage-v8` を devDependencies に追加 | 修正 |
| `packages/plugin-dialog/vitest.config.mjs` | `coverage` ブロック追加 | 修正 |
| `packages/plugin-dialog/package.json` | `test:coverage` スクリプト追加、`@vitest/coverage-v8` を devDependencies に追加 | 修正 |
| `packages/schema/vitest.config.mjs` | `coverage` ブロック追加 | 修正 |
| `packages/schema/package.json` | `test:coverage` スクリプト追加、`@vitest/coverage-v8` を devDependencies に追加 | 修正 |
| `packages/*/.gitignore` | `coverage/` を ignore（既存 `.gitignore` がある場合は追記、無い場合はリポジトリルート `.gitignore` に集約） | 修正 |
| `.github/workflows/tests-coverage.yml` | 新規 CI ワークフロー | 新規 |
| `docs/repository-structure.md` | §8 の workflows 一覧に新規ジョブを追記 | 修正 |
| `docs/functional-design.md` | §6 の CI ジョブ表に新規ジョブを追記 | 修正 |
| `docs/product-requirements.md` | 品質指標セクションに行/分岐カバレッジを「観測フェーズ」として追記 | 修正 |
| `pnpm-lock.yaml` | `@vitest/coverage-v8` 追加に伴う自動更新 | 修正 |

## 3. データ構造の変更

なし。本機能はビルド/テスト基盤の追加であり、ReScript モジュールの公開 API・型・モデルには影響しない。

## 4. 影響範囲の分析

### 直接的な影響

- **テスト実行時間**: ローカル `pnpm test` は現状維持（影響なし）。CI の coverage ジョブはテスト時間 + v8 instrumentation オーバーヘッド（経験的に 10–30%）。matrix 並列なので壁時計時間への影響は小。
- **CI 同時実行ジョブ数**: 既存 `tests-core-runtime` (1 job) に加え、新規 `tests-coverage` (4 jobs)。GitHub Actions の OSS 無料枠範囲内。
- **artifact ストレージ**: 4 パッケージ × 30 日保持。HTML レポートが含まれるため 1 PR あたり数 MB 〜数十 MB 想定。容量逼迫時は HTML reporter を外して LCOV のみに減らす余地あり（次フェーズ）。

### 間接的な影響

- **plugin-* / schema の runtime テスト失敗が初めて CI で表面化**: 既存実装は手元で test 通過を確認済みのはずだが、CI 環境（happy-dom、Node 24）固有の問題が出る可能性あり。出た場合は本ステアリング内で修正する。
- **PR レビュー UX**: Job summary でカバレッジ % が一目で見えるようになり、テスト追加 PR のレビュー指標として活用しやすくなる。
- **将来のしきい値設定**: 数 PR ぶんのベースラインが取れた段階で、別ステアリングで `coverage.thresholds` を設定する判断材料となる。

### 影響しないもの

- `tests-core-types` ワークフロー（`.resi` シンボル grep カバレッジ）: 別系統のため変更なし。
- `build-core` / `examples-build` / `compat-*` ワークフロー: 関係なし。
- リリース版（npm publish 対象）の `files`: `coverage/` は publish 対象外（`files` フィールドにより除外済み）。
- 公開 API: 影響なし。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| Coverage プロバイダ | `@vitest/coverage-v8` / `@vitest/coverage-istanbul` | v8 | Node 標準の v8 coverage を直接利用するため依存・実行時オーバーヘッドが最小。istanbul は AST 変換が入り Node v8 native より遅い。`*.res.mjs` のような生成済み JS にはどちらでも問題ないが、最小依存原則で v8 を選択 |
| CI ワークフロー構成 | 単一ワークフロー + matrix / パッケージごとに分割 | 単一 + matrix | 4 パッケージで coverage 設定はほぼ同一。matrix で重複を避け、新規パッケージ追加時は `matrix.package` に 1 行追加で済む |
| 計測対象 | `src/**/*.res.mjs` のみ / `lib/` 含む / `*.res` 含む | `src/**/*.res.mjs` のみ | `lib/` は ReScript ビルド中間物で実行されない。`.res` は ReScript ソースで Node が直接実行しない（v8 coverage は対象にできない） |
| レポータ | text のみ / text + lcov / text + lcov + html + json-summary | 全部 | text-summary は CI ログ、json-summary は GH summary 整形用、lcov/html は artifact 用に必要。各々が異なる用途を担う |
| しきい値ゲート | 初期から導入 / 観測後に導入 | 観測後 | ベースライン未取得段階でしきい値を決めると恣意的になる。数 PR ぶんの実測後に別ステアリングで設定 |
| Codecov 連携 | 同梱 / 別ステアリング | 別ステアリング | `CODECOV_TOKEN` の Secret 設定はリポジトリオーナー権限が必要で、本ステアリングのスコープ外。LCOV を artifact 化しているため、後付け追加は容易 |
| 既存 `tests-core-runtime.yml` の扱い | 廃止 / 据え置き | 据え置き | 既存ワークフローを壊さず、coverage CI が core 全体を coverage 付きで再実行するだけ。重複コストは小（OSS 無料枠内）。整理は次フェーズで |
| trigger paths | `packages/**` 全体 / パッケージ別 path filter | `packages/**` | matrix で 4 パッケージ並列実行する以上、いずれかのパッケージ変更で全 matrix 実行されるのが分かりやすい。スキップ最適化は次フェーズ |
| Node バージョン | 24（既存 CI と統一）/ 18 / 20 | 24 | 既存 `tests-core-runtime.yml` 等と統一。最新 LTS の v8 coverage を利用 |
| action SHA pinning | SHA 固定 / タグ参照 | SHA 固定 | steering 028 の規約に従う。本ステアリング実装時に最新 release SHA で書き換える |

## 6. リスクと回避策

| リスク | 確率 | 影響 | 回避策 |
|---|---|---|---|
| plugin-* / schema の runtime テストが CI 環境で失敗 | 中 | 中 | 本ステアリング内で原因調査・修正。修正困難ならパッケージ単位で `continue-on-error: true` を一時的に付け、別タスク化 |
| `.res.mjs` の行番号と元の `.res` がズレて読みにくい | 高（既知） | 低 | source map は ReScript が出力していないため受容。LCOV を読む際は `*.res.mjs` で見る前提を README に注記 |
| HTML レポート artifact がストレージを逼迫 | 低 | 低 | 30 日保持に制限。逼迫したら HTML を外す |
| `@vitest/coverage-v8` のバージョン不整合 | 低 | 中 | vitest 本体（^3.0.0）と peer 関係にあるため同一メジャーバージョンを採用 |
| CI 実行時間の悪化 | 低 | 低 | matrix 並列・v8 プロバイダで最小化済み。問題化したら paths filter を狭める |
