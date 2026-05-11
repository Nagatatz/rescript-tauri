# Design: examples/plugin-clipboard-manager-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-014 |
| 関連 | `requirements.md`, `examples/plugin-shell-demo/**`, `packages/plugin-clipboard-manager/src/PluginClipboardManager.resi` |

---

## 1. アプローチ

`examples/plugin-shell-demo/` を完全な雛形にして以下のみ変更:
- パッケージ名 / 依存パッケージ
- src/App.res のロジック (6 関数 + `Image.t` ハンドルを ref で保持して `writeImage` round-trip 実現)
- src-tauri/Cargo.toml の plugin crate
- src-tauri/src/main.rs の plugin init
- capabilities/default.json の permission
- tauri.conf.json の productName / identifier

## 2. ファイル構成

`plugin-shell-demo` と同型。全 9 ファイル + icons/ + steering 3 ファイル。

## 3. 主要差異

### 3.1 dependencies

```json
"@rescript-tauri/plugin-clipboard-manager": "workspace:*",
"@tauri-apps/plugin-clipboard-manager": "^2.0.0"
```

`rescript.json` の dependencies も同様。

### 3.2 capabilities/default.json

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-clipboard-manager demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "clipboard-manager:default"
  ]
}
```

`clipboard-manager:default` は upstream のデフォルト permission（全 6 関数を許可）。

### 3.3 src-tauri/Cargo.toml

```toml
[package]
name = "plugin-clipboard-manager-demo"
version = "0.0.0"
edition = "2021"

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-clipboard-manager = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### 3.4 src-tauri/src/main.rs

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_clipboard_manager::init())
        .run(tauri::generate_context!())
        .expect("error while running plugin-clipboard-manager-demo");
}
```

### 3.5 src/App.res の骨子

```rescript
open RescriptTauriPluginClipboardManager
open RescriptTauriCore  // for Image

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let safe = (label, body) => { ... }

// Hold the last `Image.t` for the round-trip writeImage button.
let lastImage: ref<option<Image.t>> = ref(None)

let runWriteText = async () => {
  await PluginClipboardManager.writeText("hello from rescript-tauri")
  setResult("writeText ok")
}

let runReadText = async () => {
  let s = await PluginClipboardManager.readText()
  setResult("readText: " ++ s)
}

let runReadImage = async () => {
  let img = await PluginClipboardManager.readImage()
  lastImage := Some(img)
  let bytes = await Image.rgba(img)
  setResult("readImage rgba bytes: " ++ Int.toString(TypedArray.length(bytes)))
}

let runWriteImageRoundtrip = async () => {
  switch lastImage.contents {
  | Some(img) =>
    await PluginClipboardManager.writeImage(img)
    setResult("writeImage round-trip ok")
  | None => setResult("Run readImage first to capture an Image.t")
  }
}

let runWriteHtml = async () => {
  await PluginClipboardManager.writeHtml(
    "<b>hello</b> from <i>rescript-tauri</i>",
    ~altText="hello from rescript-tauri",
  )
  setResult("writeHtml ok")
}

let runClear = async () => {
  await PluginClipboardManager.clear()
  setResult("clear ok")
}

// wiring + main()
```

### 3.6 tauri.conf.json

`productName: "rescript-tauri-plugin-clipboard-manager-demo"`、`identifier: "com.rescript-tauri.example.plugin-clipboard-manager-demo"`、window title `"plugin-clipboard-manager demo"`。

## 4. 共有ファイル

- root `Cargo.toml`: `"examples/plugin-clipboard-manager-demo/src-tauri"` を `plugin-fs-demo` と `plugin-shell-demo` の間に追加（アルファベット順）
- `docs/repository-structure.md` §1 ツリー + §3 examples 一覧に追加
- `sphinx-docs/user/plugin-clipboard-manager.md` の "See also" 先頭に live demo
- `packages/plugin-clipboard-manager/CHANGELOG.md` の `Added` に live example app
- `.github/workflows/examples-build.yml` の plugin-shell-demo の直後（or 直前、アルファベット順）に 2 step 追加

## 5. ロールバック

merge commit revert で原状復帰可能。
