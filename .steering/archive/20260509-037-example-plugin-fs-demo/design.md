# Design: examples/plugin-fs-demo

## 1. ディレクトリ構成

`examples/plugin-dialog-demo/`（steering 036）と同じ骨格に plugin-fs
特有の差分を載せる。

```
examples/plugin-fs-demo/
├── README.md
├── index.html
├── package.json
├── rescript.json
├── src/
│   ├── App.res                      # 14 関数を呼び出すロジック
│   └── main.mjs                     # `import "./App.res.mjs"`
└── src-tauri/
    ├── Cargo.toml                   # tauri-plugin-fs 追加
    ├── build.rs
    ├── capabilities/
    │   └── default.json             # fs:default + fs:allow-app-local-data-recursive
    ├── icons/                       # hello-world から流用
    ├── src/
    │   └── main.rs                  # tauri_plugin_fs::init() 登録
    └── tauri.conf.json
```

## 2. ReScript 側 (`src/App.res`)

設計方針:

- `@rescript-tauri/plugin-fs` をフルパスで呼び出す
  (`RescriptTauriPluginFs.PluginFs.*`)。
- すべての操作は `BaseDirectory.appLocalData` 直下の
  `plugin-fs-demo/` サブディレクトリに対して行う（`baseDir` オプション
  で指定）。これにより capability 範囲が `app-local-data` で完結する。
- 結果表示: `<pre id="result">` の `textContent` を **書き換え**
  （前 demo と同じ）。長文になるケースは `\n` で改行整形。
- 各 button handler は async + try/catch (Promise.catch) で保護。

### 2.1 関数カバレッジ（14 関数）

カテゴリ別にボタンを 5 つに集約し、1 ボタンが複数 API を順に呼ぶ
形にする（demo 実行時のクリック数を抑える）。

| ボタン id | 呼ぶ関数 | 説明 |
|---|---|---|
| `btn-setup` | `mkdir`, `writeTextFile`, `writeFile` | `plugin-fs-demo/` を作成し `notes.txt`（テキスト）と `bytes.bin`（4 byte）を書き出す |
| `btn-read` | `exists`, `readTextFile`, `readFile`, `stat`, `size` | `notes.txt` の存在確認 → 内容読み出し → bytes 読み出し → stat → size |
| `btn-list` | `readDir`, `lstat` | `plugin-fs-demo/` の中身列挙 + 各エントリに `lstat` |
| `btn-modify` | `copyFile`, `rename`, `truncate` | `notes.txt` を `notes.copy.txt` にコピー → `notes.renamed.txt` に rename → `bytes.bin` を 2 byte に truncate |
| `btn-cleanup` | `remove` | `plugin-fs-demo/` を recursive 削除（先頭から再実行可能にする） |

これにより 14 公開関数すべてが実呼び出しに含まれる。

### 2.2 共通定数

```rescript
let demoDir = "plugin-fs-demo"
let textFile = "plugin-fs-demo/notes.txt"
let bytesFile = "plugin-fs-demo/bytes.bin"
let copyFile = "plugin-fs-demo/notes.copy.txt"
let renamedFile = "plugin-fs-demo/notes.renamed.txt"
let baseDir = PluginFs.BaseDirectory.appLocalData
```

### 2.3 `Uint8Array` の生成

```rescript
let bytes = Uint8Array.fromArray([0x48, 0x69, 0x21, 0x0a]) // "Hi!\n"
```

`Uint8Array.fromArray` は `@rescript/core` の標準バインディング。

### 2.4 結果表示ヘルパ

```rescript
let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}
```

各 handler は最終結果を 1 回 `setResult` する。途中経過は文字列を
組み立ててから一括書き込み（DOM 操作回数最小化）。

### 2.5 エラーハンドリング

`safe(label, fn)` ヘルパで `Promise.catch` 経由のエラー文字列を
`setResult` に書き出す（plugin-dialog-demo と同じパターン）。

## 3. JS / HTML 側

### 3.1 `src/main.mjs`

```javascript
import "./App.res.mjs";
```

### 3.2 `index.html`

ボタン群は 5 つ（カテゴリ別に並べる）、結果は `<pre id="result">`。
plugin-dialog-demo のスタイル（dark code block + flexbox）を踏襲。

## 4. Rust 側 (`src-tauri/`)

### 4.1 `Cargo.toml`

```toml
[package]
name = "plugin-fs-demo"
version = "0.0.0"
edition = "2021"

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-fs = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### 4.2 `src/main.rs`

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_fs::init())
        .run(tauri::generate_context!())
        .expect("error while running plugin-fs-demo");
}
```

### 4.3 `tauri.conf.json`

`hello-world` ベース、

- `productName`: `"rescript-tauri-plugin-fs-demo"`
- `identifier`: `"com.rescript-tauri.example.plugin-fs-demo"`
- `app.windows[0].title`: `"plugin-fs demo"`

### 4.4 `capabilities/default.json`

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-fs demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "fs:default",
    "fs:allow-app-local-data-recursive"
  ]
}
```

`fs:allow-app-local-data-recursive` は plugin-fs 既定で同梱される
permission alias で、`$APPLOCALDATA` 配下のサブツリー全体を許可する。

### 4.5 `build.rs` / `icons/`

`hello-world` および `plugin-dialog-demo` と同一手順
（`tauri_build::build()` + アイコンコピー）。

## 5. `package.json` / `rescript.json`

### 5.1 `package.json`

```json
{
  "name": "plugin-fs-demo",
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
    "@rescript-tauri/plugin-fs": "workspace:*",
    "@tauri-apps/api": "^2.11.0",
    "@tauri-apps/plugin-fs": "^2.5.0"
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
  "name": "plugin-fs-demo",
  "package-specs": [{ "module": "esmodule", "in-source": true }],
  "suffix": ".res.mjs",
  "sources": [{ "dir": "src", "subdirs": true }],
  "dependencies": [
    "@rescript/core",
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-fs"
  ],
  "jsx": { "version": 4 }
}
```

## 6. README.md

- ステータス（Phase 2、plugin-fs 実装後）
- 実行方法（`pnpm install && pnpm --filter plugin-fs-demo build`、
  Tauri ランタイム実行は `pnpm tauri dev`）
- 各ボタンの挙動（§2.1 表）
- ファイル構成表
- Notes:
  - すべての操作は `$APPLOCALDATA/plugin-fs-demo/` に対して行う
  - capabilities `fs:allow-app-local-data-recursive` でサブツリー
    全体を許可している旨

## 7. ビルド検証手順

1. `pnpm install`（worktree 内で実行）
2. `pnpm --filter plugin-fs-demo build`
3. `pnpm --recursive build`
4. `pnpm --recursive test`

## 8. リスクと対応

| リスク | 対応 |
|---|---|
| `fs:default` だけでは appLocalData 書き込みが拒否される | `fs:allow-app-local-data-recursive` を追加 |
| `Uint8Array.fromArray` が ReScript core stdlib に存在しない | 存在を確認済（`@rescript/core` 提供）。失敗したら `Uint8Array.make([...])` にフォールバック |
| icons の同梱漏れ | hello-world から流用 |
| recursive `remove` の挙動でデモ前提が壊れる | `removeOptions { recursive: true }` を明示指定 |
