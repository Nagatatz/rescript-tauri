# Requirements: Biome による format / lint 導入

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-038 |
| タイトル | add-biome-format-lint |
| 起票日 | 2026-05-09 |
| 起票者 | Nagatatz |

---

## 1. 背景

このリポジトリは ReScript モノレポであり、`.res` / `.resi` は ReScript コンパイラ標準のフォーマッタ（`rescript format`）でフォーマット可能だが、テスト・examples・設定ファイルとして手書きの **JavaScript (`.mjs`)** が混在している。

現状これらの手書き JS にはフォーマッタも lint も導入されておらず:

- インデント・引用符・末尾カンマなどのスタイルが PR ごとにブレる可能性がある
- 未使用変数・到達不能コード等の典型的な問題が CI で検出されない
- レビュー負荷が増える

production-ready バインディング群を謳うリポジトリとして、JS 側にも CI ゲート可能な品質ツールを整備する必要がある。

技術選定の議論結果（会話ログ参照）として **Biome** を採用する:

- 単一バイナリで format + lint を統合
- 設定ファイル 1 つ（`biome.json`）
- ReScript 生成物（`*.res.mjs`）の除外をパスマッチで容易に表現可能
- stable リリース済み（Vite Plus は alpha のため不採用）

## 2. 目的

手書き `.mjs` および JSON 設定ファイルに対して、以下を CI と開発者ワークフローの両方で実行可能にする:

1. **フォーマット**（自動修正可能）
2. **lint**（推奨ルールセット）

## 3. 適用範囲（in scope）

| カテゴリ | パスパターン | 件数 |
|---|---|---|
| examples の手書き JS | `examples/*/src/*.mjs` | 4 |
| パッケージのランタイムテスト | `packages/*/tests/runtime/**/*.mjs` | 8 |
| vitest 設定 | `packages/*/vitest.config.mjs` | 4 |
| パッケージ JSON | `packages/*/package.json`, `packages/*/rescript.json` | ~10 |
| ルート JSON | `package.json`, `pnpm-workspace.yaml`（YAML は対象外）, `biome.json` | 数件 |

**対象ファイル合計: 約 18 ファイル + JSON**

## 4. 適用範囲外（out of scope）

| 除外対象 | 理由 |
|---|---|
| `*.res` / `*.resi` | ReScript 標準フォーマッタの責務 |
| `*.res.mjs`（ReScript 生成物） | コンパイラ出力。手で触らない |
| `**/lib/**` | ReScript ビルド成果物 |
| `**/node_modules/**` | 依存パッケージ |
| `**/target/**` | Rust ビルド成果物（examples の src-tauri） |
| `examples/*/src-tauri/**` | Rust 側コード |
| `sphinx-docs/**` | Sphinx ビルドが管理。Markdown は対象外 |
| `.steering/**`, `docs/**`, `*.md` | Markdown は本ステアリングでは対象外（必要なら別 steering で導入） |
| YAML（`pnpm-workspace.yaml`, `.github/workflows/*.yml`） | Biome は YAML 未対応 |
| `Cargo.toml` 等 Rust 関連 | 別ツール責務 |

## 5. 機能要件

### FR-1: フォーマット実行

- ルートで `pnpm run format` を実行すると、適用範囲の全ファイルがフォーマットされる
- `pnpm run format:check` を実行すると、フォーマット差分の有無のみ検証する（書き換えなし、CI 用）

### FR-2: lint 実行

- ルートで `pnpm run lint` を実行すると、適用範囲の全ファイルが lint される
- 推奨ルールセット（Biome `recommended`）を有効化する
- 既存コードで違反が出る場合、本ステアリング内で修正する

### FR-3: 統合実行

- `pnpm run check` で format + lint を一括実行する（CI ゲート用）
- フォーマット差分または lint 違反があれば非ゼロ終了する

### FR-4: 生成物の除外

- `*.res.mjs` / `lib/` / `node_modules/` / `target/` を Biome のスキャン対象から除外する
- `git status` に余計な差分が出ない・誤って ReScript 生成物を書き換えないことを CI で確認する

### FR-5: CI 統合

- 既存の `.github/workflows/` に Biome 実行ジョブを追加する（または既存ジョブに step を足す）
- PR で format/lint 違反があれば CI が失敗する

## 6. 非機能要件

### NFR-1: パフォーマンス

- ルートで `pnpm run check` の実行時間が **5 秒以内** であること（対象ファイルが少ないため余裕で達成可能）

### NFR-2: 開発者体験

- VS Code の Biome 拡張で動作する設定とする（`biome.json` がプロジェクトルートにあれば自動認識される）
- 既存の `pnpm install` 後すぐに `pnpm run check` が動くこと

### NFR-3: 既存ワークフローへの影響

- 既存の `pnpm --recursive build` / `pnpm --recursive test` を**壊さない**
- ReScript ビルドのインクリメンタル性を**損なわない**（`*.res.mjs` を変更しない）

## 7. 受け入れ基準

- [ ] `pnpm install` 後、`pnpm run format` / `pnpm run lint` / `pnpm run check` の 3 コマンドがルートで動作する
- [ ] 既存の手書き `.mjs` がすべて Biome のフォーマットに準拠している（`format:check` がクリーン）
- [ ] 既存の手書き `.mjs` で lint 違反が 0 件である
- [ ] `*.res.mjs` および `lib/` 配下のファイルは Biome に検出も書き換えもされない
- [ ] CI で `pnpm run check` が実行され、format/lint 違反時に CI が失敗する
- [ ] ドキュメント（`README.md` / `docs/development-guidelines.md` 該当箇所）が更新されている

## 8. 想定リスクと緩和

| リスク | 影響 | 緩和 |
|---|---|---|
| Biome 推奨ルールが既存テストコードと衝突 | 違反多数で導入難航 | 違反箇所を本ステアリングで修正、または該当ルールのみ無効化（`biome.json` で明示） |
| `*.res.mjs` の除外漏れで生成物が書き換わる | ReScript ビルドが壊れる | `experimentalScannerIgnores` および `files.includes` の二重指定で確実に除外、CI で `git diff --exit-code` 検証 |
| Biome のメジャー更新で挙動変化 | 将来の保守コスト | `package.json` で `^` ではなく `~` で固定（マイナーまで許容） |

## 9. 関連ドキュメント

- `.claude/rules/git-conventions.md` — コミットメッセージ規約
- `.claude/rules/testing.md` — テスト規約
- `docs/repository-structure.md` — リポジトリ構造
- 会話ログ（2026-05-09）— Vite Plus との比較検討経緯
