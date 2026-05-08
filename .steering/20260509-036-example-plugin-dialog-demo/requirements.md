# Requirements: examples/plugin-dialog-demo

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-036 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — examples 追加 |
| 関連パッケージ | `@rescript-tauri/plugin-dialog` (steering 035 で実装済み) |
| 作成日 | 2026-05-09 |

---

## 1. 背景

Phase 2 で `@rescript-tauri/plugin-dialog` の実装が完了した
(steering 035, commit `761ea63`)。Phase 2 完了条件 §I の "examples"
として、PRD §5.4 の CI ゲート対象に組み込める使用例 1 件を追加する。

既存 examples (`hello-world` / `window-management` / `ipc-typed` /
`streaming-ipc`) は Phase 1 の core API のみ使用しており、plugin
パッケージを使用する初の example となる。

## 2. 目的

- `@rescript-tauri/plugin-dialog` の **公開 API すべて** を 1 つの
  Tauri アプリ内から呼び出すデモを示す。
- ReScript フロント + Rust バックエンドが pnpm workspace 内で
  ビルド可能な状態にする（`pnpm --filter plugin-dialog-demo build`）。
- CI から OS 3 種 (Linux / macOS / Windows) でビルドできる骨格を
  整える（CI 設定本体は steering 037 以降で対応、本 steering では
  ジョブ追加が容易な形で **コードを** 揃えるところまで）。

## 3. スコープ

### Must（本 steering で対応）

- `examples/plugin-dialog-demo/` ディレクトリの新規作成
- ReScript フロント (`src/App.res`)
  - `openFile` / `openFiles` / `openDirectory` / `openDirectories`
    のいずれか網羅できる UI（少なくとも `openFile` と `openFiles`
    はボタンで切り分けて呼び出す）
  - `save`
  - `message` (info / error)
  - `ask`
  - `confirm`
  - 各結果を `<pre id="result">` 等の DOM 要素に描画
- Rust 側 (`src-tauri/`)
  - `tauri-plugin-dialog` v2.x を `Cargo.toml` に追加し
    `tauri::Builder` に `.plugin(tauri_plugin_dialog::init())` で
    登録
  - `capabilities/default.json` を新規作成し `dialog:default`
    パーミッションを許可
- `index.html`（ボタン群と結果表示要素）
- `package.json` / `rescript.json`
  - `package.json` の `dependencies` に `@rescript-tauri/plugin-dialog`
    と `@tauri-apps/plugin-dialog` を加える
- `README.md`（実行方法・ファイル構成・各ボタンの挙動）
- pnpm workspace（ルート `pnpm-workspace.yaml`）への追加が必要なら追加
  – ※ 既存 `examples/*` がワイルドカードで含まれていれば追加不要
- `pnpm --filter plugin-dialog-demo build` がローカルで成功する

### Should（余裕があれば）

- `docs/repository-structure.md` §3 の `examples/` リストに
  `plugin-dialog-demo/` を追記
- README に "上流 plugin-dialog v2.7 系を `peerDependencies` 経由
  で取り込んでいる" 旨の互換マトリクス節
- `tauri.conf.json` に `plugins.dialog` が空オブジェクトで登録される
  形にしておく（v2 では init で十分なため必須ではない）

### 非対象（Out of scope）

- `pnpm tauri dev` の実機実行確認（OS とアイコン素材揃えが
  別 steering の責務）
- CI ワークフロー (`examples-build.yml` 等) の実際のジョブ追加
  – steering 037 以降で B 軸として対応
- iOS / Android 専用 option (`pickerMode` / `fileAccessMode`) の
  本格動作デモ — 型の存在を ReScript 側 example で参照する程度に
  とどめる
- アイコン素材の独自生成（`hello-world/icons/` の流用 or 同等の
  プレースホルダで OK）

## 4. 受け入れ条件

1. `examples/plugin-dialog-demo/` が新規ディレクトリとして作成され、
   `package.json` に `name: "plugin-dialog-demo"` が含まれる。
2. ローカルで `pnpm install && pnpm --filter plugin-dialog-demo build`
   が **エラーなく完了** する（ReScript 側ビルドのみで OK、
   Tauri Rust ビルドは Tauri toolchain がない環境では skip 可）。
3. `src/App.res` から plugin-dialog の **公開 8 関数すべて**
   (`openFile`, `openFiles`, `openDirectory`, `openDirectories`,
    `save`, `message`, `ask`, `confirm`) のうち最低 6 関数以上を
   実際に使用する（残り 2 関数は型レベルで参照されていれば可）。
4. `tauri-plugin-dialog` バージョン pin が `@tauri-apps/plugin-dialog`
   peerDep の 2.7.x 系と整合している。
5. `pnpm --recursive build` が他パッケージに regression を起こさず
   全件成功する。
6. `tasklist.md` の全タスク（マージタスクを含む）が `[x]` の状態で
   main マージされる。

## 5. 依存・前提

- steering 035 で `@rescript-tauri/plugin-dialog` が `packages/` に
  存在すること（commit `761ea63` で完了済み）。
- `pnpm-workspace.yaml` が `examples/*` をワイルドカード登録している
  こと（既存 examples 4 件がすでに配置されているため確認のみで OK）。

## 6. リスク

- **Rust 側ビルドの実機検証ができない**: 開発環境に Tauri CLI と
  Rust toolchain が無い場合、`pnpm tauri build` は CI に委ねる。
  本 steering ではフロント側ビルド (`rescript build`) と
  ファイル整合性のみで完了とする。受け入れ条件 §2 で明文化。
- **plugin-dialog のキャプ設定**: Tauri 2.x ではアプリ毎に
  capabilities ファイルが必要。漏れるとデモアプリが動かないが、
  本 steering ではビルド成立が条件のため最低限 `default.json` を
  追加するに留める。

## 7. 影響範囲

- 追加: `examples/plugin-dialog-demo/**`、ステアリング一式
- 更新（任意）: `docs/repository-structure.md`
- 既存パッケージへの破壊的変更なし
