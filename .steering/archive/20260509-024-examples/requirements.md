# Steering 024: 残り 3 examples の整備

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §5.4, repository-structure.md §3 |
| ブランチ | `worktree-phase1-examples` |

## 背景

PRD §5.4 が「examples ビルドの 3 OS 緑」をリリースゲートに指定。`hello-world` は steering 016 で完了済み。残る `window-management` / `ipc-typed` / `streaming-ipc` を整備する。

## 要求

### 共通

各 example は `examples/<name>/` に以下のレイアウトで配置:

```
examples/<name>/
├── README.md           # 「何を示す例か」「どう動かすか」
├── index.html          # HTML host
├── package.json        # name, scripts, deps
├── rescript.json       # ReScript build config
├── src/
│   ├── App.res         # ReScript エントリ
│   └── main.mjs        # JS bridge
└── src-tauri/
    ├── Cargo.toml
    ├── build.rs
    ├── tauri.conf.json
    └── src/
        └── main.rs     # Rust 側コマンド
```

### window-management

- `Window.t` / `WebviewWindow.t` の操作デモ
- `Tauri.Window.getCurrent()` から始まり、`setTitle` / `maximize` / `minimize` / `setSize` などボタン操作
- 別ウィンドウを `WebviewWindow.make` で作るボタン
- `Tauri.Webview` 経由で zoom 変更デモも 1 か所
- ReScript ファイルは uncurried-by-default、`open Tauri` を使い main 効果を出す

### ipc-typed

- `Core.Command.make` の典型例
- `greet` (string -> string), `add` (record -> int) の 2 コマンド
- `JSON.Decode.*` での decoder ハンドコード例
- Rust 側に対応する `#[tauri::command]` を実装
- `Core.Command.invoke` の `result<_, invokeError>` 分岐をすべて表示

### streaming-ipc

- `Core.Channel` のデモ
- Rust 側 `#[tauri::command] fn count_to(channel: Channel<u32>, target: u32) {...}` で順次 send
- フロント側 `Channel.make` + `Channel.onMessage` + `Channel.id` でカウンタを表示
- `Core.Command` 経由でチャンネルを Rust に渡し、ストリームを subscribed する流れを示す

### CI 統合

`.github/workflows/examples-build.yml` を 3 例に対応させる。それぞれの `pnpm --filter <name> build` と `cargo check --release` を追加。マトリクス OS は変えない（Ubuntu / macOS / Windows）。

### Phase 1 末以降の改善

- `tauri.conf.json` の `frontendDist` は hello-world と同様 `../` に固定する（最小化のため Vite を入れない）。
- README は実装可動を verify するためのコマンド一式と対応 PRD ストーリーを記載。

## Non-goals

- React / Vite / Vue 等の UI フレームワーク統合（Phase 2）
- Rust 側のテスト（`cargo test`） — Phase 1 では `cargo check --release` のみ
- npm publish 用の `private: false`（example はモノレポ内 private）

## 受け入れ条件

- [x] 3 example dir 作成、各ファイル配置
- [x] `pnpm --filter window-management build` 緑（フロントのみ）
- [x] `pnpm --filter ipc-typed build` 緑
- [x] `pnpm --filter streaming-ipc build` 緑
- [x] CI matrix を 3 例に拡張
- [x] 既存 hello-world は引き続き緑
- [x] `pnpm --filter @rescript-tauri/core test` も緑
