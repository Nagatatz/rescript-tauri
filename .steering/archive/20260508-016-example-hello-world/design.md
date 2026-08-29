# 設計: examples/hello-world

## ファイル構成

```
examples/hello-world/
├── package.json               # frontend pnpm package
├── rescript.json              # ReScript build config
├── index.html                 # Vite-style entry
├── src/
│   ├── App.res                # Core.Raw.invoke 呼び出し例
│   ├── App.resi               # 公開 API (なし、空でも OK)
│   └── main.mjs               # JS entry
├── src-tauri/
│   ├── Cargo.toml
│   ├── build.rs
│   ├── tauri.conf.json
│   └── src/
│       └── main.rs            # #[tauri::command] greet
└── README.md
```

## 各ファイルの内容

### `package.json`

```json
{
  "name": "hello-world",
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
    "@tauri-apps/api": "^2.11.0"
  },
  "devDependencies": {
    "@rescript/core": "^1.6.0",
    "@rescript/runtime": "^12.2.0",
    "@tauri-apps/cli": "^2.0.0",
    "rescript": "^12.2.0"
  }
}
```

### `rescript.json`

```json
{
  "name": "hello-world",
  "package-specs": [{ "module": "esmodule", "in-source": true }],
  "suffix": ".res.mjs",
  "sources": [{ "dir": "src", "subdirs": true }],
  "dependencies": ["@rescript/core", "@rescript-tauri/core"],
  "jsx": { "version": 4 }
}
```

### `src/App.res`

```rescript
@val external document: 'a = "document"

let renderGreeting = async () => {
  let greeting: string =
    await RescriptTauriCore.Core.Raw.invoke("greet", ~args={"name": "ReScript"})
  let el = document["getElementById"]("greeting")
  el["textContent"] = greeting
}

let _ = renderGreeting()
```

### `src/App.resi`

```rescript
// no public exports — App is the entry script.
```

### `src/main.mjs`

```javascript
import "./App.res.mjs"
```

### `index.html`

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>rescript-tauri hello world</title>
  </head>
  <body>
    <h1>rescript-tauri hello world</h1>
    <p id="greeting">Loading...</p>
    <script type="module" src="/src/main.mjs"></script>
  </body>
</html>
```

### `src-tauri/Cargo.toml`

```toml
[package]
name = "hello-world"
version = "0.0.0"
edition = "2021"

[lib]
name = "hello_world_lib"
crate-type = ["staticlib", "cdylib", "rlib"]

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### `src-tauri/build.rs`

```rust
fn main() {
    tauri_build::build()
}
```

### `src-tauri/src/main.rs`

```rust
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! - from rescript-tauri", name)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### `src-tauri/tauri.conf.json`

最小設定 (frontend は dev で `localhost:1420` の Vite 等を立ち上げる前提だが、本 example では devUrl を null にしてビルド済み HTML を読む):

```json
{
  "$schema": "https://schema.tauri.app/config/2",
  "productName": "rescript-tauri-hello-world",
  "version": "0.0.0",
  "identifier": "com.rescript-tauri.example.hello-world",
  "build": {
    "frontendDist": "../"
  },
  "app": {
    "windows": [
      {
        "title": "rescript-tauri hello world",
        "width": 800,
        "height": 600
      }
    ],
    "security": {
      "csp": null
    }
  }
}
```

> **Note**: `tauri.conf.json` の正確な schema は Tauri 2.x のバージョンに依存。`pnpm tauri info` で実環境を確認する。本ステアリングではビルドが通る最小値とし、CI で検証 (steering 017) する。

### `README.md`

```markdown
# hello-world

Minimal Tauri 2.x desktop app demonstrating `@rescript-tauri/core`'s
Layer 1 (`Core.Raw.invoke`).

## Status

Phase 1 — implementation in progress. Frontend builds today
(`pnpm --filter hello-world build`); the Rust side requires the
Tauri toolchain (`pnpm tauri dev` from this directory) and is fully
exercised once steering 017 wires up the CI matrix.

## Run locally (Phase 1 release后)

```bash
cd examples/hello-world
pnpm install
pnpm tauri dev
```

## What it does

1. Frontend (`src/App.res`) calls `Core.Raw.invoke("greet", {name: "ReScript"})`.
2. Rust (`src-tauri/src/main.rs`) defines `#[tauri::command] fn greet(name: &str) -> String`.
3. The greeting is rendered into the DOM.

## Files of interest

- `src/App.res` / `App.resi` — ReScript entry calling Tauri.
- `src-tauri/src/main.rs` — Rust command handler.
- `tauri.conf.json` — Tauri app config (windows, build).
```

## ルートワークスペース更新

`pnpm-workspace.yaml` には既に `"examples/*"` が含まれているため変更不要。

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-016 (example-hello-world) |
| 2 | ✨ Add examples/hello-world (frontend skeleton + Rust scaffolding + README) |
| 3 | 📝 Mark steering 20260508-016 complete |

検証はフロントエンドのビルドのみ (`pnpm --filter hello-world build`)。Rust 側の `cargo build` は Tauri toolchain が必要なため CI ステアリング (017) に委ねる。

## worktree

`EnterWorktree(name="example-hello-world")`。
