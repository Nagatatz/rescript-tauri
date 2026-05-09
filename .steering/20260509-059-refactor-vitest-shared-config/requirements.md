# Steering 059: vitest config の共通化

## 1. 背景

各パッケージの `vitest.config.mjs` が、閾値の数値以外は完全に同一の boilerplate を持つ。

### 1.1 現状ファイル一覧

| パッケージ | 行数 | 閾値設定 | 閾値根拠コメント |
|---|---|---|---|
| `packages/core/vitest.config.mjs` | 33 | あり (詳細コメント付) | C/D/E 残存ギャップに関する記述あり |
| `packages/plugin-fs/vitest.config.mjs` | 30 | あり (コメント付) | branch 50% の根拠 |
| `packages/plugin-dialog/vitest.config.mjs` | 30 | あり (コメント付) | branch 60% の根拠 |
| `packages/plugin-shell/vitest.config.mjs` | 14 | なし | — |
| `packages/plugin-notification/vitest.config.mjs` | 27 | あり (コメント付) | branch 45% の根拠 |
| `packages/plugin-log/vitest.config.mjs` | 18 | あり (コメントなし) | 95/50/95/95 |
| `packages/plugin-os/vitest.config.mjs` | 18 | あり (コメントなし) | 95/50/95/95 |
| `packages/schema/vitest.config.mjs` | 23 | あり (コメント付) | 88% lines / branch 45% |

合計: 8 ファイル / ~190 行。差分は閾値の数値とその根拠コメントのみ。共通の boilerplate (provider / include / exclude / reporter / reportsDirectory / reportOnFailure / environment / include パス) は全件同一。

### 1.2 メンテナンス上のコスト

新パッケージ追加時 (e.g. plugin-clipboard-manager は閾値未設定で 14 行) に同じ boilerplate を都度 copy-paste している。閾値の根拠コメントは将来 raise する判断のために重要だが、boilerplate と混在しているため拡張・更新時に diff のシグナル / ノイズ比が悪い。

## 2. 目的

ルートに共通 helper を配置し、各パッケージの `vitest.config.mjs` を「ライブラリ呼び出し + 閾値オブジェクト + (任意) 根拠コメント」のみの薄い形に圧縮する。

## 3. 要求事項

### 3.1 機能要求

| ID | 要求 |
|---|---|
| FR-1 | リポジトリルートに `tools/vitest.shared.mjs` を新設し、`definePackageConfig({thresholds?})` を export する |
| FR-2 | 各パッケージの `vitest.config.mjs` を helper 呼び出し形に書き換える (~5-10 行 + コメント) |
| FR-3 | helper は閾値が省略された場合、coverage thresholds 未設定の vitest デフォルト動作になること (= 計測のみ、CI ゲートなし) |
| FR-4 | 既存の閾値および根拠コメントを保持する (情報を失わない) |
| FR-5 | reporter / reportsDirectory / include / exclude / reportOnFailure / provider / environment / test include は helper のデフォルトとして同一値を保持する |

### 3.2 非機能要求

| ID | 要求 |
|---|---|
| NFR-1 | 既存テストが green のままであること (`pnpm --filter <pkg> test` が成功) |
| NFR-2 | coverage 計測の有効/無効・閾値・閾値根拠コメントなど、現行 CI 動作を変更しないこと (NFR-2 は spot check で確認) |
| NFR-3 | `tools/vitest.shared.mjs` の行数が 50 行以下に収まること |
| NFR-4 | 各 `vitest.config.mjs` の行数が現状の半分以下に収まること |

### 3.3 互換性 / 配布

`tools/vitest.shared.mjs` は publish 対象外 (各パッケージの `package.json#files` には含めない)。devtime 依存。`vitest.config.mjs` から相対パス (`../../tools/vitest.shared.mjs`) で import する。

`@types/node` 等の workspace dev dep には影響しない。pnpm-lock の変動は無し (新規 package を入れない)。

## 4. 受け入れ基準

- [ ] `tools/vitest.shared.mjs` が新設されている
- [ ] 8 パッケージの `vitest.config.mjs` がすべて helper 経由に書き換わっている
- [ ] 各 `vitest.config.mjs` の行数が現行の半分以下である
- [ ] helper の関数 export に doc comment が付与されている
- [ ] 1 パッケージで `pnpm --filter <pkg> test:coverage` (もしくは `test`) を実行し、変更前と同じ pass / 同じ閾値判定がされることを確認する (build 負荷を抑えるため core 1 件のみで確認)
- [ ] `docs/repository-structure.md` の `tools/` セクションが追記されている

## 5. スコープ外

- vitest 自体のバージョンアップ / 設定 schema 変更
- `vitest.config.ts` への移行 (現行 `.mjs` を維持)
- coverage threshold の値変更 (steering 059 はリファクタのみ。値は現状維持)
- ルート `package.json` への scripts 追加 (既存 `pnpm --recursive test` を引き続き利用)

## 6. リスクと緩和策

| リスク | 緩和策 |
|---|---|
| helper が `defineConfig` の戻り値型を破壊して vitest が config を読めない | `defineConfig` の戻り値をそのまま返す純粋な spread にとどめる |
| 相対パス import が CI 環境で解決失敗 | ESM の相対 import で `../../tools/vitest.shared.mjs` を指定。pnpm の symlink は問題にならない (ファイルパスは絶対化される) |
| 閾値根拠コメントを失う | 各 `vitest.config.mjs` の `definePackageConfig` 引数の隣にコメントを残す形で保持 |
