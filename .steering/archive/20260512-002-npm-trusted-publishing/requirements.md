# Requirements: npm Trusted Publishing への移行

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| 関連 | `.github/workflows/release.yml`, `.steering/20260509-029-phase1-release-followups/release-checklist.md`, `.steering/20260509-046-phase2-release-checklist/release-checklist.md` |

## 1. 背景

`NPM_TOKEN` (Automation token) を repository secret として登録する従来の publish 方式について、npm が UI 上で以下の警告を表示している:

> There are security risks with this option. For automation or CI/CD uses, please use Trusted Publishing instead.

npm の **Trusted Publishing** は GitHub Actions と npm 間で OIDC により信頼関係を確立し、publish 時に短命トークンを自動発行する仕組み。長期 secret を GitHub Secrets に保管する必要がなくなり、漏えいリスクとローテーション運用コストが下がる。

## 2. 現状

`.github/workflows/release.yml` は OIDC 用の要件をすでにほぼ満たしている:

- `permissions: id-token: write` 設定済み（provenance 用途で既に有効）
- `registry-url: "https://registry.npmjs.org"` 設定済み
- `npm publish --provenance --access public` を使用

残作業は以下に絞られる:

- `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` を削除
- `Determine publish mode` ステップから `NPM_TOKEN` 空チェックの分岐を除去（dry_run 入力のみで判定する形に再設計）
- npm 側で各パッケージに Trusted Publisher を設定する手順をリリースチェックリストに反映

## 3. ゴール

1. `release.yml` を Trusted Publishing 前提に書き換え、`NPM_TOKEN` への依存を完全除去
2. Phase 1 / Phase 2 リリースチェックリストの「`NPM_TOKEN` を Repository secret として登録」の項目を「npm 側で Trusted Publisher を設定」に置き換え
3. Phase 1 / Phase 2 リリースチェックリストに、Trusted Publisher 設定手順（npm UI のスクリーンショット位置・項目入力値）を追記

## 4. 非ゴール (Non-Goals)

- 実際のリリース実行（タグ作成・publish）— 本ステアリングはワークフロー整備のみ
- Phase 3 相当の 6 プラグイン（`plugin-shell` / `plugin-notification` / `plugin-log` / `plugin-os` / `plugin-clipboard-manager` / `plugin-http`）のリリースチェックリスト新規作成 — 別ステアリング
- Trusted Publishing への切り替えに伴う追加 hardening（branch protection の更新等）— 別ステアリング
- `release.yml` の他の改善（matrix 化・並列実行など）

## 5. 受け入れ条件

- `release.yml` 内に `NPM_TOKEN` / `NODE_AUTH_TOKEN` への参照が 0 件
- `release.yml` の `permissions:` に `id-token: write` が引き続き存在
- `Determine publish mode` ステップが `dry_run=true` の場合のみ skip し、それ以外は publish する形になっている
- Phase 1 / Phase 2 リリースチェックリストが Trusted Publisher 設定手順を含む
- `release.yml` の構文検証（`actionlint` または GitHub の workflow_dispatch dry-run）でエラーなし
- 既存 CI が green を維持する（release.yml は tag push トリガなので PR では実行されないが、変更による構文エラーがないことを確認）

## 6. 制約

- pre-release のため後方互換性は不要（CLAUDE.md memory）
- `actionlint` などの linter がある場合はそれにも準拠
- workflow ファイル名 `release.yml` は変更しない（npm 側の Trusted Publisher 設定で参照されるため）
