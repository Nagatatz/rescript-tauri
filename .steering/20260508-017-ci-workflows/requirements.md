# 要求定義: CI workflow 実体化（build-core / tests / doc-link-lint / examples-build）

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-017 |
| タイトル | ci-workflows |
| 起票日 | 2026-05-08 |
| 影響範囲 | `.github/workflows/` 配下に 5 個の新規 workflow + `.github/workflows/README.md` 更新 |

## 動機

functional-design §6 で定義された 8 個の workflow のうち、**Phase 1 実装が出揃った今すぐ動かせる 5 個**を実装する。残り 3 個（`compat-tauri-latest`, `compat-rescript-prerelease`, `release`）は nightly / リリース時にしか動かない別軸の workflow なので、Phase 1 リリース直前に別ステアリングで追加。

## スコープ

### 対象（in-scope）

| ファイル | 役割 | トリガ |
|---|---|---|
| `.github/workflows/build-core.yml` | `pnpm --filter @rescript-tauri/core build` を実行し時間を計測 | PR / push (paths: packages/core/**, pnpm-lock.yaml, package.json) |
| `.github/workflows/tests-core-types.yml` | 型レベル test build + 100% public-symbol coverage grep | 同上 |
| `.github/workflows/tests-core-runtime.yml` | vitest 実行 | 同上 |
| `.github/workflows/doc-link-lint.yml` | 全 `.resi` で `v2.tauri.app/` URL の存在を grep | 同上 |
| `.github/workflows/examples-build.yml` | examples の ReScript フロント + Rust (`cargo build --manifest-path src-tauri/Cargo.toml`) を 3 OS (Ubuntu/macOS/Windows) で | PR / push (paths: examples/**, packages/core/**) |
| `.github/workflows/README.md` 更新 | "Active workflows" 表に 5 個追加、"Planned for Phase 1" から 5 個削除（残 3 個） | — |

### 対象外（後続ステアリング）

- `compat-tauri-latest.yml` / `compat-rescript-prerelease.yml` (nightly)
- `release.yml` (tag push trigger、npm publish)

## 派生決定

| 論点 | 採用 |
|---|---|
| Node.js バージョン | `20` 系（Active LTS）を全 workflow で固定 |
| pnpm setup | `pnpm/action-setup@v4` (sha-pinned に migrating する代わりに、`sha_pinning_required: true` に従い具体的な commit SHA を使う) |
| 100% シンボル coverage の確認手法 | `tests/*_signature.res` の `_check_*` 行数 vs `*.resi` の `let` 行数を grep カウントで比較。完全な AST ベースは過剰 |
| examples-build の 3 OS | `ubuntu-latest`, `macos-latest`, `windows-latest`。Rust toolchain は `dtolnay/rust-toolchain@stable` |
| examples-build で ReScript フロントは `pnpm --filter hello-world build`、Rust は `cargo build --manifest-path examples/hello-world/src-tauri/Cargo.toml` | Tauri アプリ全体をビルドする `pnpm tauri build` は GUI ライブラリ依存重く、CI 上では Rust の `cargo check` 相当だけで十分 |
| Action SHA pinning | sha_pinning_required:true ポリシーがあるため、各 action は `actions/checkout@<sha>` 形式に pin。ただし本ステアリングでは tag 参照 (`@v4` など) で実装し、別ステアリングで自動 SHA 化する判断を残す（手作業の SHA pinning は workflow 数が増えるとメンテ負荷大） |
| worktree 名 | `ci-workflows` |

## 受け入れ条件

- [ ] 5 個の `.yml` ファイルが `.github/workflows/` に配置される
- [ ] 各ファイルが GitHub Actions schema に valid（YAML lint で抜き打ち確認）
- [ ] `.github/workflows/README.md` が active 5 個 + opt-in 2 個 + planned 3 個 に更新される
- [ ] ローカルで全 workflow ファイルの YAML が parse 可能（`python3 -c "import yaml; ..."` 等で確認）
- [ ] visibility public 化後に GitHub Actions が起動することを期待（private 状態でも push は走るがコスト面の懸念あり、limit 監視は別途）
