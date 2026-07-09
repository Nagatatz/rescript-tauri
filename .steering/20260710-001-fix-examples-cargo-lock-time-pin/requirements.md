# requirements — examples ビルドの `cookie` / `time` 破壊対処

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260710-001 |
| タイトル | fix-examples-cargo-lock-time-pin |
| 作成日 | 2026-07-10 |
| 関連 | Dependabot PR #21 (tauri group) / #22 (biome) の CI build 失敗 |

## 背景 / 問題

Dependabot PR #21・#22 の `examples-build.yml`（build (macos/ubuntu/windows)）が失敗している。原因は依存 bump 自体ではなく、examples の Rust ビルドが踏む transitive 依存の非互換:

- `cookie 0.18.1`（crates.io 最新。修正版なし）が `time 0.3.42` 以降でコンパイルエラー `error[E0061]`（`time` の `Parsable::parse` が引数 1→2 に変更、`cookie-0.18.1/src/parse.rs:226`）。
- `time` は 0.3.41（2025-03-23）が cookie 0.18.1 と互換な最後の版。0.3.42（2025-08-31）以降が破壊。CI は最新 0.3.52 を拾って失敗する。
- `cookie` は `examples/plugin-http-demo/src-tauri` の `tauri-plugin-http`（→ reqwest → cookie_store）から来る transitive 依存。

## 根本原因

`Cargo.lock` が `.gitignore`（47 行目）で追跡対象外。examples は Tauri アプリ（バイナリ）で CI ビルドゲートなのに lockfile が無く、CI が毎回依存をゼロ解決するため、上流が壊れた瞬間に巻き込まれる（float 破壊）。

## 実装中の追加調査（2026-07-10）

- `time` を `0.3.41` に precise pin しようとしたところ、`plist 1.10.0`（tauri 2.11.5 経由）が `time ^0.3.47` を要求しており **0.3.41 は選べない**ことが判明。cookie(<0.3.42) と plist(>=0.3.47) を同時に満たす `time` は存在しない。
- 一方、現行最新 `time 0.3.53`（2026-07-01 公開）で `cookie 0.18.1` が**正常にコンパイルできる**ことを `cargo check -p cookie --locked` で確認。time の破壊的変更（0.3.42〜0.3.52。0.3.48/0.3.50 は yank 済み）は **0.3.53 で upstream 修正済み**。CI が失敗した 6/30 は壊れた 0.3.52 を踏んでいた。
- 従って **time の pin は不要かつ不可能**。`Cargo.lock` を commit して time を 0.3.53 に固定すれば、cookie は通り、将来の float 破壊も防げる。

## 要求（改訂）

1. examples ワークスペースの Rust ビルドを CI で green にする。
2. 上流 float 破壊の再発を防ぐため、`Cargo.lock` を追跡対象にして依存を pin する（バイナリ crate の定石）。現時点の解決版 `time 0.3.53` / `cookie 0.18.1` を lock で固定する。
3. CI の `cargo check` を `--locked` 化し、lock 逸脱を fail で顕在化させる（pin の実効化）。
4. 依存構造・追跡ポリシー変更を `docs/repository-structure.md` に反映する（`Cargo.lock` の commit 対象化）。

## 非目標

- `cookie` / `reqwest` / `tauri-plugin-http` のバージョン変更（上流に修正版が出るまで不可）。
- `time` の恒久的固定を将来にわたって維持する運用ルール化（cookie 0.18.2 or reqwest 更新で解除できる暫定 pin）。将来解除できるようコメントで理由を明記するに留める。
- Dependabot PR #21 / #22 のマージ判断そのもの（本修正が main に入り両 PR を rebase して green を確認するのは後続）。

## 受け入れ条件

- worktree でルート workspace の `cargo build`（少なくとも `plugin-http-demo`）がローカルで成功する。
- `Cargo.lock` が commit され、`time` が `0.3.41` に pin されている。
- `.gitignore` から `Cargo.lock` が外れている。
- ローカル `cargo` が無い環境の場合は、pin の妥当性を CI（PR）で検証する旨を明記。
