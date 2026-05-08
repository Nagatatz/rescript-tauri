# 要求定義: examples/hello-world

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-016 |
| タイトル | example-hello-world |
| 起票日 | 2026-05-08 |
| 影響範囲 | `examples/hello-world/` 新規（Tauri 2.x アプリのスケルトン）|

## 動機

PRD §10.4 Phase 1 の「examples/hello-world」+ Story 6-1 + repository-structure §3。最小の動く Tauri 2.x アプリで `@rescript-tauri/core` の Layer 1 (Raw.invoke) を実演する。Phase 1 リリース時の visibility 切替条件 #2「examples/* が 3 OS マトリクスでビルド成功」に向けた最初の例題。

## スコープ

### 対象 (in-scope)

`examples/hello-world/` 配下の最小ファイルセット:

- ReScript フロント:
  - `package.json`（front-end pnpm package、`@rescript-tauri/core` を workspace 依存）
  - `rescript.json`（`@rescript-tauri/core` を `dependencies` に）
  - `src/App.res`（`Core.Raw.invoke("greet", {name})` 呼び出し + DOM 描画）
  - `src/main.mjs`（entry）
  - `index.html`
- Tauri Rust バックエンド:
  - `src-tauri/Cargo.toml`
  - `src-tauri/build.rs`
  - `src-tauri/src/main.rs`（`#[tauri::command] fn greet`）
  - `src-tauri/tauri.conf.json`
  - `src-tauri/icons/` は最小限（後で）
- `README.md`（セットアップ手順、Phase 1 release 待ち）

### 対象外

- 他の examples（`window-management`, `ipc-typed`, `streaming-ipc`）— PRD §10.4 / repository-structure §3 では存在を宣言しているが、本ステアリングは hello-world 1 個のみ
- 実 Tauri ビルド検証（`pnpm tauri dev` 等のローカル実行 / CI 上の `cargo build`）— CI workflow ステアリング 017 で対応
- アイコンアセット（PNG 等）— 公式テンプレートからコピーするか別途用意、今は `tauri.conf.json` の icons 配列を空 / minimal にして CI ビルドが通る最小限に

## 派生決定

| 論点 | 採用 |
|---|---|
| Tauri 2.x のビルドターゲット | `tauri.conf.json` の `bundle` 設定は最小（CI 通過のための Tauri 公式デフォルト）|
| ReScript エントリ | `src/App.res` 1 個。`Tauri.res` re-export がないので `RescriptTauriCore.Core.Raw.invoke` でフルパス参照 |
| greet コマンド | Rust 側 `fn greet(name: &str) -> String` を定義、ReScript から `invoke("greet", {name: "World"})` で呼ぶ |
| package.json scripts | `dev` / `build` / `tauri` (= `tauri-cli`) を持つが、devDependencies で `@tauri-apps/cli` を追加 |
| 子 package の workspace 参照 | `"@rescript-tauri/core": "workspace:*"` |
| worktree 名 | `example-hello-world` |

## 受け入れ条件

- [ ] `examples/hello-world/` 配下に上記ファイル群が配置される
- [ ] `pnpm install` (ルート) で hello-world が workspace project として認識される
- [ ] `pnpm --filter hello-world build` で ReScript 部分（`src/App.res.mjs` 生成）が成功する
- [ ] Rust 側のコンパイルは Tauri toolchain 必要なため本ステアリング外（CI 整備時に検証）
- [ ] README にローカル実行手順と Phase 1 リリース後の利用イメージが記載
