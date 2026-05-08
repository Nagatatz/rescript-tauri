# Design: Examples Cargo Manifest Fix

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-033-examples-cargo-manifest-fix |
| 関連 | [requirements.md](./requirements.md) |

## 1. 変更内容

### 1.1 修正前

各 `examples/*/src-tauri/Cargo.toml` は以下の構造を持つ:

```toml
[package]
name = "<example-name>"
version = "0.0.0"
edition = "2021"

[lib]
name = "<example_name>_lib"
crate-type = ["staticlib", "cdylib", "rlib"]

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### 1.2 修正後

`[lib]` ブロック（およびその直前の空行 1 行）を削除する:

```toml
[package]
name = "<example-name>"
version = "0.0.0"
edition = "2021"

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

`main.rs` がデフォルトでバイナリエントリ (`src/main.rs`) として認識される。`[[bin]]` セクションも不要。

## 2. 対象ファイルと削除行

| ファイル | 削除する行 |
|---|---|
| `examples/hello-world/src-tauri/Cargo.toml` | `[lib]` 〜 `crate-type = [...]` の 3 行（前の空行含めて 4 行） |
| `examples/window-management/src-tauri/Cargo.toml` | 同上 |
| `examples/ipc-typed/src-tauri/Cargo.toml` | 同上 |
| `examples/streaming-ipc/src-tauri/Cargo.toml` | 同上 |

各 lib name は example ごとに異なる（`hello_world_lib`, `window_management_lib`, `ipc_typed_lib`, `streaming_ipc_lib`）が、いずれも削除されるため命名揺れは問題にならない。

## 3. 検証方針

### 3.1 ローカル

cargo がインストールされていれば `cargo check` で 4 example すべての manifest 解釈成功を確認する:

```bash
for d in examples/*/src-tauri; do
  echo "--- $d ---"
  (cd "$d" && cargo check --release --message-format=short 2>&1 | head -20)
done
```

cargo がローカルに無い場合はスキップ可能（CI で検証する）。

### 3.2 CI

push 後に `examples-build` ジョブ（3 OS）が cargo check 段階を通過することを確認。`pnpm --filter hello-world build` と `cargo check --release` の両ステップが green になれば成功。

## 4. リスクと緩和

| リスク | 緩和策 |
|---|---|
| `tauri::generate_context!()` などのマクロが `[lib]` 配置時とバイナリ単独時で異なる挙動を持つ | Tauri 2 のマクロは `[bin]` でも `[lib]` でも同じ展開で動作する設計（公式テンプレでもデスクトップ専用は bin only でビルド可）。ローカル/CI で実証 |
| 将来 mobile 対応を始めた際にこの削除が後戻りになる | mobile 対応自体が PRD のスコープ外（CLAUDE.md「Tauri 2.x desktop アプリ」）。将来 mobile を追加する場合は別 RFC で `lib.rs` 構造を導入する |
| examples が pnpm-lock 等から `[lib]` 名を引いている | grep で確認済み: `tauri.conf.json` 含めどこからも参照されていない |

## 5. 参考

- Tauri 2 公式ドキュメントの "Project Structure": https://v2.tauri.app/start/project-structure/
- `tauri-app` テンプレートの desktop-only モード（`--mobile=false`）が `[lib]` を生成しないことを確認
