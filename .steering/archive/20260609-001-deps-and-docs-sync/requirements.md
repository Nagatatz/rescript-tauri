# 要求定義: 依存パッケージ更新とドキュメント整合修正

| 項目 | 内容 |
|---|---|
| 機能名 | deps-and-docs-sync |
| 作成日 | 2026-06-09 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

ライブラリとしてリリース可能なクオリティを維持するため、依存パッケージとドキュメントの棚卸しを実施した。`pnpm outdated --recursive` と実ファイル突き合わせの結果、以下 2 点のずれが判明した。

1. **dev 依存に patch/minor の outdated が複数**: compiler 本体 (`rescript`) を含む 8 パッケージが古い。
2. **`docs/repository-structure.md` §5 の sphinx-docs ツリーが自己矛盾**: §2.2 本文では plugin-shell / log / notification / os / clipboard-manager / http の各 `user/*.md` が「追加済み」と書かれているのに、§5 のディレクトリツリーには反映されていない。

### 目的

- dev 依存を最新の patch/minor に追従し、ビルド・テストが緑であることを保証する。
- repository-structure.md のツリー記述を実態と一致させ、ドキュメントの「正本」性を回復する。

## 2. 変更・追加する機能の説明

コードのロジック変更は伴わない。以下の 2 種の更新のみ:

- **依存更新**: ルート / 各 package / 各 example の dev 依存を最新化。上流 `@tauri-apps/*` の `peerDependencies` は変更しない（`@tauri-apps/api` は 2.11.0 が依然 latest のためカバー対象追従不要）。
- **ドキュメント修正**: `docs/repository-structure.md` §5 の `sphinx-docs/user/` ツリーに 6 つの plugin ページを追記。

### 対象の依存（すべて devDependencies）

| パッケージ | 現在 | 最新 | 種別 |
|---|---|---|---|
| `rescript` | 12.2.0 | 12.3.0 | minor |
| `@rescript/runtime` | 12.2.0 | 12.3.0 | minor |
| `vitest` | 4.1.5 | 4.1.8 | patch |
| `@vitest/coverage-v8` | 4.1.5 | 4.1.8 | patch |
| `happy-dom` | 20.9.0 | 20.10.2 | patch |
| `@tauri-apps/cli` | 2.11.1 | 2.11.2 | patch |
| `@biomejs/biome` | 2.4.14 | 2.4.16 | patch |
| `@types/node` | 25.6.2 | 25.9.2 | minor |

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | メンテナ | リポジトリを clone してビルド | 最新の dev 依存で `pnpm --recursive build` / `test` が緑 |
| 2 | コントリビュータ | repository-structure.md を参照 | sphinx-docs/user/ の実ファイルとツリー記述が一致している |

## 4. 受け入れ条件

- [ ] 対象 dev 依存がすべて最新版に更新されている（`pnpm outdated --recursive` で対象が消える）
- [ ] `pnpm install` 後、`pnpm --recursive build` が成功する
- [ ] `pnpm --recursive test` が全件パスする
- [ ] `pnpm run check`（Biome）が警告・エラーなし
- [ ] `docs/repository-structure.md` §5 のツリーに 6 plugin ページが追記され、実 `sphinx-docs/user/` と一致する
- [ ] `pnpm-lock.yaml` の差分がコミットに含まれている

## 5. 制約事項

- pre-release（pre-1.0）のため後方互換 shim は不要（[memory] pre-release: 後方互換性は不要）。
- ディスク使用率 93%。`pnpm install` は content-addressable store のハードリンク方式で増分は小さいが、install 前に空き容量（16GB）を再確認する。
- branch protection により worktree → PR → self-merge フロー必須。
- `rescript` 12.3.0 は minor bump のため、更新後の全 workspace ビルド・テスト再検証を必須とする。

## 6. 関連ドキュメント

- `docs/repository-structure.md` — 修正対象（§5 / §2.1 カバー記述）
- `.claude/rules/pre-flight-verification.md` — 依存バージョン主張の検証手順
