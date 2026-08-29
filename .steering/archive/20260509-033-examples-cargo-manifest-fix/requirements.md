# Requirements: Examples Cargo Manifest Fix — Drop Phantom `[lib]`

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-033-examples-cargo-manifest-fix |
| 作成日 | 2026-05-09 |
| 起票理由 | `examples-build` ジョブが 3 OS とも `cargo check` で manifest パース失敗 (`can't find library 'hello_world_lib'`)。SHA pin / pnpm 修正 (steering 028 / 030) を経て CI が起動するようになった結果、example 側の事前バグが顕在化 |

## 1. 背景

`examples/*/src-tauri/Cargo.toml` がいずれも次の構造を持つ:

```toml
[lib]
name = "hello_world_lib"
crate-type = ["staticlib", "cdylib", "rlib"]
```

これは Tauri 2 の `cargo create-tauri-app` テンプレートが mobile 向けに `lib.rs` ベースのエントリを前提として生成する標準パターン。しかし本リポジトリの 4 examples（hello-world / window-management / ipc-typed / streaming-ipc）はいずれも:

- `src/lib.rs` を持たない（`src/main.rs` のみ）
- `tauri.conf.json` 側で `mainBinaryName` 等のライブラリ名参照は無い

ため、`[lib]` 宣言だけが残り `cargo check` が manifest パース時にエラー終了する。

`examples-build.yml` ジョブは hello-world に対して `cargo check --release` を実行するため、CI 上で確実に再現する。

## 2. 修正方針

本プロダクトのスコープは「Tauri 2.x **desktop** アプリのフロント側ライブラリ」（CLAUDE.md「対象プラットフォーム: Linux / macOS / Windows」）であり、mobile 対応は要件にない。

すべての example について `[lib]` ブロックと `crate-type` を削除し、`main.rs` のみのバイナリクレートとして整合させる。

### 2.1 採用しなかった代替案

| 案 | 不採用理由 |
|---|---|
| `lib.rs` を新規追加し `main.rs` を `<crate>_lib::run()` を呼ぶだけに変更 | mobile 対応を前提とした Tauri 2 標準テンプレ構造。デスクトップのみのスコープでは過剰 |
| `[lib].path = "src/main.rs"` と書く | 1 ファイルで bin と lib を兼ねる exotic 構成。読み手の混乱を招く |

## 3. 機能要件

- [REQ-1] `examples/hello-world/src-tauri/Cargo.toml` から `[lib]` ブロックを削除する
- [REQ-2] `examples/window-management/src-tauri/Cargo.toml` から `[lib]` ブロックを削除する
- [REQ-3] `examples/ipc-typed/src-tauri/Cargo.toml` から `[lib]` ブロックを削除する
- [REQ-4] `examples/streaming-ipc/src-tauri/Cargo.toml` から `[lib]` ブロックを削除する
- [REQ-5] `main.rs` の内容は変更しない（既に有効なバイナリエントリ）
- [REQ-6] `tauri.conf.json` の内容は変更しない（lib 名参照無し）

## 4. 非機能要件

- [NFR-1] `examples-build` ジョブが 3 OS（ubuntu / macos / windows）とも cargo check 段階で失敗しなくなる
- [NFR-2] Tauri 2 標準のデスクトップビルド動作を維持（`tauri::Builder::default()` を `main` から呼ぶパターン）

## 5. スコープ外

- `examples-build.yml` の cargo check 対象を hello-world 以外にも拡張すること（今回は manifest 修正のみ）
- mobile 対応の追加（plant 外）
- example 自体の機能追加・刷新
