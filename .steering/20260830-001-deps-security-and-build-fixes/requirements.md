# Requirements: 依存更新・セキュリティアラート解消・並列ビルド競合修正

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260830-001 |
| 作成日 | 2026-08-30 |
| 種別 | chore（設定 / 依存 / 運用棚卸し） |
| ブランチ | `worktree-deps-security-and-build-fixes` |

## 背景

2026-08-30 時点のリポジトリ健全性調査で以下を確認した:

1. `pnpm --recursive build` が並列実行時に `Failed to atomically replace compiler-info for package @rescript/core: No such file or directory` で散発的に失敗する（CI は `--filter` 単体実行のため未検出。CLAUDE.md / README.md / docs/development-guidelines.md が案内する標準コマンドが再現性なく落ちる）。
2. Dependabot PR 13 件が未マージ。うち GitHub Actions 4 件 (#36/#44/#49/#50)、cargo 1 件 (#39)、npm 1 件 (#41) は本ステアリング前に直接 merge 済み。残る cargo 2 件 (#46 serde_json / #42 tauri-crates group) と npm 5 件 (#40 oxc / #51 @types/node / #53 vitest / #54 @vitest/coverage-v8 / #55 happy-dom) は lockfile 競合で逐次リベース待ちとなるため、本ステアリングで同内容を取り込む（main に同バージョンが入れば Dependabot が自動 close）。
3. Dependabot セキュリティアラート 15 件 open（すべて dev / docs ツールチェーンの transitive 依存）:
   - npm (`pnpm-lock.yaml`): vite 7.3.3 → 7.3.5 (high ×1, medium ×1)、postcss 8.5.17 → 8.5.23 (high, medium)、nanoid 3.3.16 → 3.3.18 (high)、esbuild 0.27.7 → 0.28.1 (low)
   - pip (`sphinx-docs/uv.lock`): starlette 1.0.0 → 1.3.1 (high ×2, medium ×2, low)、soupsieve 2.8.3 → 2.8.4 (high ×2)、idna 3.14 → 3.15 (medium)
   - cargo (`Cargo.lock`): glib 0.18.5 → 0.20.0 (medium) — tauri / gtk 側の transitive で、examples の直接依存では制御不可
4. `.steering/` 直下に最終コミット 30 日超のディレクトリが 100 件残っており、`archive/` は空（`steering-workflow.md` アーカイブポリシー違反）。

## 要求

### R1. 並列ビルド競合の解消
- `pnpm-workspace.yaml` に `workspaceConcurrency: 1` を追加し、`pnpm --recursive build` を直列化する。
  - **実績**: 当初 `.npmrc` (`workspace-concurrency=1`) で実装したが pnpm 11.0.9 では読まれず（`pnpm config get workspace-concurrency` → `undefined`、ビルドも並列のまま）、`pnpm-workspace.yaml` に移した。
- 3 回連続で `pnpm --recursive build` が exit 0 かつ `ERROR:` 行なしで完走すること。

### R2. Dependabot 未マージ PR 相当の依存更新
- npm: `oxfmt` 0.58.0 → 0.59.0 (exact pin 維持)、`oxlint` ^1.73.0 → ^1.74.0 以上、`@types/node` ^26.1.1 → ^26.2.0 以上、`vitest` / `@vitest/coverage-v8` ^4.1.10 → ^4.1.11、`happy-dom` ^20.10.6 → ^20.11.6 以上（root + `packages/*` 全 10 パッケージ）。
  - **実績**: `pnpm update --recursive` により caret 内の最新へ更新した。`oxlint` ^1.80.0 / `@types/node` ^26.4.0 / `happy-dom` ^20.11.13 / `rescript` `@rescript/runtime` ^12.3.0 → ^12.3.1（`packages/*` と `examples/*` の devDependencies のみ。`peerDependencies` の `>=12.0.0` は不変）。Dependabot 目標より新しいが同一 range 内であり、Dependabot PR は自動 close される。
- cargo: `serde_json` 1.0.150 → 1.0.151、`tauri-plugin-dialog` / `tauri-plugin-log` を #42 相当に更新（`Cargo.lock` のみ、`Cargo.toml` の caret range は変更なし）。

### R3. セキュリティアラートの解消
- npm transitive (vite / postcss / nanoid / esbuild) を `pnpm update` で patched version 以上に更新する。
  - **実績**: postcss 8.5.26 / nanoid 3.3.18 は `pnpm update -r` で更新。vite / esbuild は vitest の *peerDependency* として auto-install されるため `pnpm update` では再解決されず、`pnpm-workspace.yaml` の `overrides` (`vite: ^7.3.6` / `esbuild: ^0.28.1`) を追加したうえで lockfile を再生成して vite 7.3.6 / esbuild 0.28.2 に固定した（pnpm 11 は `package.json` の `pnpm.overrides` を無視するため workspace yaml に置く）。
- pip transitive (starlette / soupsieve / idna) を `uv lock --upgrade-package` で patched version 以上に更新する。
  - **実績**: idna 3.14 → 3.19、soupsieve 2.8.3 → 2.9.2、starlette 1.0.0 → 1.6.0（PyPI 接続が不安定で 3 回リトライ）。
- glib は上流待ちのため対象外とし、本書に明記する。

### R4. `.steering/` アーカイブ
- 最終コミット日が 2026-07-31 より前の `.steering/*` を `.steering/archive/` に `git mv` する（本ステアリングと直近 30 日以内のものは残す）。

### R5. ドキュメント同期
- `docs/repository-structure.md` §1 ルートレイアウト・§9 の `pnpm-workspace.yaml` 行に `workspaceConcurrency` / `overrides` / pnpm 11 の設定集約方針を追記する。
- `README.md` / `CLAUDE.md` のビルドコマンドは変更不要（`pnpm-workspace.yaml` で自動適用）。

## 受け入れ基準

- [ ] `pnpm --recursive build` × 3 が exit 0 かつ `ERROR:` なし
- [ ] `pnpm --recursive test` 全件 pass
- [ ] `pnpm run check` pass
- [ ] `cargo check --locked` が全 examples で pass（`examples-build.yml` 相当）
- [ ] `cd sphinx-docs && uv sync --locked && make html` 相当が pass
- [ ] `gh api repos/{owner}/{repo}/dependabot/alerts?state=open` が glib 1 件のみになる（merge 後に確認）
- [ ] Dependabot PR #40/#42/#46/#51/#53/#54/#55 が自動 close される（merge 後に確認）

## Non-goals

- glib 0.20 への更新（tauri 2.x の gtk 依存が解決するまで不可）
- パッケージのバージョン bump / npm publish（後続ステアリングで扱う）
- oxfmt 0.59.0 による整形差分が出た場合の `.oxfmtrc.json` 調整（差分が出れば `check:fix` で吸収し、本書に記録する）
