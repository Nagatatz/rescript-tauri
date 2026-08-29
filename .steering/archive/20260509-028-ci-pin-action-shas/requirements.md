# Requirements: CI Action SHA Pin

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-028-ci-pin-action-shas |
| 作成日 | 2026-05-09 |
| 起票理由 | CI が `Error: The actions actions/checkout@v4, pnpm/action-setup@v4, and actions/setup-node@v4 are not allowed in Nagatatz/rescript-tauri because all actions must be pinned to a full-length commit SHA.` で全ジョブ失敗 |

## 1. 背景

GitHub のリポジトリポリシー（Settings → Actions → "Allow specified actions and reusable workflows" の SHA pin 必須設定）が有効になっており、`@v4` などのタグ参照では実行が拒否される。`.github/workflows/` 配下の全アクションを 40 文字コミット SHA に pin する必要がある。

なお、これは GitHub の OpenSSF Scorecard 系セキュリティ推奨でもあり（タグは可変なため悪意ある書き換えを防げない）、SHA pin 化は CI 復旧と同時にサプライチェーンセキュリティ強化を兼ねる。

## 2. 対象ファイル

`.github/workflows/` 配下で `uses:` を含むワークフロー（テンプレートは対象外）:

| ファイル | アクション参照箇所 |
|---|---|
| `build-core.yml` | actions/checkout@v4, pnpm/action-setup@v4, actions/setup-node@v4 |
| `examples-build.yml` | actions/checkout@v4, pnpm/action-setup@v4, actions/setup-node@v4, dtolnay/rust-toolchain@stable |
| `docs.yml` | actions/checkout@v6 ×2, astral-sh/setup-uv@v6 ×2, actions/setup-node@v4, actions/upload-pages-artifact@v4, actions/deploy-pages@v4 |
| `doc-link-lint.yml` | actions/checkout@v4 |
| `tests-core-runtime.yml` | actions/checkout@v4, pnpm/action-setup@v4, actions/setup-node@v4 |
| `tests-core-types.yml` | actions/checkout@v4, pnpm/action-setup@v4, actions/setup-node@v4 |

`.template` 拡張子のワークフローテンプレートは GitHub Actions が読み込まないため対象外。

## 3. 機能要件

- [REQ-1] 上記 6 ファイルのすべての `uses: <owner>/<repo>@<ref>` を 40 桁の commit SHA 参照に置換する
- [REQ-2] 各 SHA 参照には `# vX.Y.Z` 形式のコメントを付与し、人間が可読なバージョンを明示する（dependabot 互換）
- [REQ-3] 利用する SHA は 2026-05-09 時点で各メジャータグが指す最新リリース版とする
- [REQ-4] 機能的な振る舞い・ノードバージョン・キャッシュ等のオプションは変更しない（純粋に参照を pin に置き換えるのみ）

## 4. 非機能要件

- [NFR-1] CI 全ジョブ（build-core / examples-build / docs / doc-link-lint / tests-core-runtime / tests-core-types）が SHA 拒否エラーを出さずに起動する
- [NFR-2] 既存ジョブと同じ動作を維持する（ノード 20 / pnpm 10 等）

## 5. スコープ外

- アクションのバージョンアップ（v4 → v5 等の major bump）
- 新規 CI ジョブの追加
- `.template` ワークフローへの SHA pin（テンプレートは将来コピーされる際に再 pin する）
- dependabot 設定追加（別作業として切り出す）
