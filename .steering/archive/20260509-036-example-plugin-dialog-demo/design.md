# Design: examples/plugin-dialog-demo

## 1. ディレクトリ構成

`examples/hello-world/` をベースに plugin-dialog 用の差分を載せる。

```
examples/plugin-dialog-demo/
├── README.md
├── index.html
├── package.json
├── rescript.json
├── src/
│   ├── App.res                      # ReScript エントリ。8 関数のうち
│   │                                # 6 〜 8 を実際に呼び出す
│   └── main.mjs                     # `import "./App.res.mjs"`
└── src-tauri/
    ├── Cargo.toml                   # tauri-plugin-dialog 追加
    ├── build.rs                     # tauri-build 標準
    ├── capabilities/
    │   └── default.json             # `dialog:default` を許可
    ├── icons/                       # hello-world から流用
    │   ├── icon.png
    │   ├── icon.ico
    │   └── icon.icns
    ├── src/
    │   └── main.rs                  # plugin-dialog init を含む最小 builder
    └── tauri.conf.json              # `productName` / identifier / window 設定
```

## 2. ReScript 側 (`src/App.res`)

設計方針:

- **Layer はフロント素朴呼び出し**。`@rescript-tauri/core` も import
  するが、本 demo の主役は plugin-dialog。core 経由の invoke は使わない。
- `RescriptTauriPluginDialog.PluginDialog.*` をフルパスで呼び出す
  （`Tauri.res` re-export はまだ plugin パッケージを束ねていないため）。
- 各ボタンに `id` を付け、`document.getElementById` + DOM 直叩きで
  クリックハンドラを登録。React 等は導入しない（依存最小）。
- 結果表示: `<pre id="result">` の `textContent` を都度書き換える。
- `Nullable.t<...>` 結果は `Nullable.toOption` でパターンマッチ。

### 2.1 関数カバレッジ

| ボタン id | 呼ぶ関数 | 表示する結果例 |
|---|---|---|
| `btn-open-file` | `openFile(~options)` | `Picked: /path/to/file.txt` / `Cancelled` |
| `btn-open-files` | `openFiles(~options)` | `Picked 3 files: ...` |
| `btn-open-dir` | `openDirectory(~options=?)` | `Picked dir: ...` / `Cancelled` |
| `btn-open-dirs` | `openDirectories(~options=?)` | `Picked dirs: [...]` |
| `btn-save` | `save(~options)` | `Save target: ...` |
| `btn-message-info` | `message(~options={kind: #info, ...})` | `Result: Ok` |
| `btn-message-error` | `message(~options={kind: #error, ...})` | `Result: Ok` |
| `btn-ask` | `ask(~options=?)` | `Answered: true/false` |
| `btn-confirm` | `confirm(~options=?)` | `Confirmed: true/false` |

これにより 8 公開関数すべてが実呼び出しに含まれる
（受け入れ条件 §3 の "6 関数以上" を超過達成）。

### 2.2 型のデモ

- `dialogFilter` を `openFile` の `~options.filters` に渡し、テキスト
  ファイルのみ選択するパスを示す。
- `messageButtons` の `#OkCancel` を `message` で使い `messageResult`
  が文字列で返ることをコメントで明示。
- `pickerMode` / `fileAccessMode` は型を参照する `let _: option<...>`
  ダミーで残し、モバイル限定オプションの存在を示す（実呼び出しなし）。

### 2.3 エラーハンドリング

`Promise.catch` で各ボタン handler を包み、結果表示要素にエラー
メッセージを書き出す（exn → `Console.error` 経由）。Layer 1 の
失敗はネイティブ側で稀だが、demo として落ちない実装にする。

## 3. JS / HTML 側

### 3.1 `src/main.mjs`

```javascript
import "./App.res.mjs";
```

### 3.2 `index.html`

- `<h1>plugin-dialog demo</h1>`
- 9 個のボタン（上記 ID）
- `<pre id="result">(no action yet)</pre>`
- `<script type="module" src="/src/main.mjs"></script>`

## 4. Rust 側 (`src-tauri/`)

### 4.1 `Cargo.toml`

```toml
[package]
name = "plugin-dialog-demo"
version = "0.0.0"
edition = "2021"

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-dialog = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

`tauri-plugin-dialog = "2"` で 2.x 系最新（2.7.x 同梱）。upstream JS
側 peerDep `^2.7.0` と概ね整合する。

### 4.2 `src/main.rs`

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .run(tauri::generate_context!())
        .expect("error while running plugin-dialog-demo");
}
```

例題ロジックを Rust 側に持たない（plugin-dialog はフロント API のみで
完結する）。

### 4.3 `tauri.conf.json`

`hello-world` をベースに、

- `productName`: `"rescript-tauri-plugin-dialog-demo"`
- `identifier`: `"com.rescript-tauri.example.plugin-dialog-demo"`
- `app.windows[0].title`: `"plugin-dialog demo"`
- `frontendDist`: `"../"` （hello-world と同様、`index.html` 直接ロード）

`plugins.dialog` キーは v2 では `init` で十分なので省略。

### 4.4 `capabilities/default.json`

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-dialog demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "dialog:default"
  ]
}
```

`dialog:default` で plugin-dialog の全 API を許可。capabilities 名は
"main" 既定 window と一致させる。

### 4.5 `build.rs`

`hello-world/src-tauri/build.rs` と同一（`tauri_build::build()`）。

### 4.6 `icons/`

`examples/hello-world/src-tauri/icons/` をそのまま流用しても
プレースホルダとしては十分。コピーで配置する（example ごとに icon
を作るのは Phase 2 必須事項ではない）。

## 5. `package.json` / `rescript.json`

### 5.1 `package.json`

```json
{
  "name": "plugin-dialog-demo",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "rescript build",
    "clean": "rescript clean",
    "tauri": "tauri"
  },
  "dependencies": {
    "@rescript-tauri/core": "workspace:*",
    "@rescript-tauri/plugin-dialog": "workspace:*",
    "@tauri-apps/api": "^2.11.0",
    "@tauri-apps/plugin-dialog": "^2.7.0"
  },
  "devDependencies": {
    "@rescript/core": "^1.6.0",
    "@rescript/runtime": "^12.2.0",
    "@tauri-apps/cli": "^2.0.0",
    "rescript": "^12.2.0"
  }
}
```

### 5.2 `rescript.json`

```json
{
  "name": "plugin-dialog-demo",
  "package-specs": [{ "module": "esmodule", "in-source": true }],
  "suffix": ".res.mjs",
  "sources": [{ "dir": "src", "subdirs": true }],
  "dependencies": [
    "@rescript/core",
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-dialog"
  ],
  "jsx": { "version": 4 }
}
```

## 6. README.md

- ステータス（Phase 2 で plugin-dialog 実装完了直後）
- 実行方法（`pnpm install && pnpm --filter plugin-dialog-demo build`、
  Tauri ランタイム実行は `pnpm tauri dev`）
- 各ボタンが何を呼ぶかの表（§2.1 の表を簡略化）
- ファイル構成表（hello-world README と同形式）
- Notes:
  - capabilities/default.json で `dialog:default` を allow
  - peerDep として `@tauri-apps/plugin-dialog ^2.7.0` を要する旨

## 7. ビルド検証手順

1. `pnpm install`
2. `pnpm --filter plugin-dialog-demo build` （ReScript ビルド）
3. `pnpm --recursive build` （他パッケージ regression 確認）
4. （任意）Tauri Rust ビルドは toolchain が無いと skip。
   コンパイル可能性は CI の examples-build.yml に委ねる。

## 8. リスクと対応

| リスク | 対応 |
|---|---|
| `pnpm-workspace.yaml` が `examples/*` をパターン外指定 | 確認し、必要なら追記 |
| `tauri-plugin-dialog` の features 指定が必要 | 2.x 系は init 関数のみで動く。default features で OK |
| icons の同梱漏れで Rust ビルドが落ちる | hello-world からコピーで配置 |
| capabilities の schema 参照パスが解決されない | `$schema` は IDE 補助のみ。Rust ビルドには影響しない |
