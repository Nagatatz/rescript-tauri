# Design: examples/plugin-shell-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-008 |
| 関連 | `requirements.md`, `examples/plugin-dialog-demo/**`, `examples/plugin-fs-demo/**`, `packages/plugin-shell/src/PluginShell.resi` |

---

## 1. アプローチ

既存の `plugin-dialog-demo` を雛形にして以下を移植:
- `src/App.res` を PluginShell 全公開 API に書き換え
- `src-tauri/Cargo.toml` / `src-tauri/src/main.rs` で `tauri-plugin-shell` を登録
- `src-tauri/capabilities/default.json` を shell 用に書き換え
- `package.json` / `rescript.json` / `index.html` / `README.md` を plugin-shell-demo 用に調整

新規ロジックは可能な限り上流 demo / 既存 demo のスタイル踏襲。独自の UI 要素は持ち込まない。

## 2. ディレクトリ構造

```
examples/plugin-shell-demo/
├── README.md                          # 動かし方
├── index.html                         # buttons + result pre
├── package.json                       # workspace dep on plugin-shell
├── rescript.json                      # plugin-shell を dep に
├── src/
│   ├── App.res                        # button → 関数の wiring + 全 API 呼び出し
│   ├── App.res.mjs                    # rescript build 後の生成物（commit 対象外、.gitignore 経由）
│   └── main.mjs                       # ./App.res.mjs を import + DOM ready 後に App.main()
└── src-tauri/
    ├── Cargo.toml                     # tauri = 2, tauri-plugin-shell = 2
    ├── build.rs                       # tauri-build invoke
    ├── icons/                         # 既存 demo からコピー (空白の何かを使うなら 32x32.png のダミー)
    ├── src/
    │   └── main.rs                    # .plugin(tauri_plugin_shell::init())
    ├── capabilities/
    │   └── default.json               # shell:default + allow-execute / allow-open
    └── tauri.conf.json                # productName / identifier / windows
```

## 3. 各ファイルの具体仕様

### 3.1 `package.json`

```json
{
  "name": "plugin-shell-demo",
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
    "@rescript-tauri/plugin-shell": "workspace:*",
    "@tauri-apps/api": "^2.11.0",
    "@tauri-apps/plugin-shell": "^2.3.0"
  },
  "devDependencies": {
    "@rescript/core": "^1.6.0",
    "@rescript/runtime": "^12.2.0",
    "@tauri-apps/cli": "^2.0.0",
    "rescript": "^12.2.0"
  }
}
```

### 3.2 `rescript.json`

`plugin-dialog-demo/rescript.json` を読んで踏襲 (Phase 1 でこの構造は確定済み)。`dependencies` を `["@rescript-tauri/core", "@rescript-tauri/plugin-shell"]` に。

### 3.3 `index.html`

button 群と `<pre id="result">` を配置。HTML の構造:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>rescript-tauri plugin-shell demo</title>
    <link rel="stylesheet" href="/src/styles.css" />
  </head>
  <body>
    <main>
      <h1>plugin-shell demo</h1>
      <section>
        <h2>openPath</h2>
        <button id="btn-open-url">Open https://tauri.app/</button>
        <button id="btn-open-with-firefox">Open with firefox (path regex)</button>
      </section>
      <section>
        <h2>Command — one-shot</h2>
        <button id="btn-execute-utf8">Run `echo hello` (utf8)</button>
        <button id="btn-execute-raw">Run `echo hello` (raw bytes)</button>
      </section>
      <section>
        <h2>Command — spawn + Child</h2>
        <button id="btn-spawn-cat">Spawn `cat`, write line, kill</button>
      </section>
      <section>
        <h2>Command — streaming events</h2>
        <button id="btn-stream-echo">Echo via onStdoutData chain</button>
        <button id="btn-stream-remove">Remove all listeners</button>
      </section>
      <h2>Result</h2>
      <pre id="result"></pre>
    </main>
    <script type="module" src="/src/main.mjs"></script>
  </body>
</html>
```

CSS は省略（`/src/styles.css` を空ファイルとして配置するか、`<link>` を消す）。既存 demo に倣う（`plugin-dialog-demo/index.html` を確認して合わせる）。

### 3.4 `src/main.mjs`

```js
import { main } from "./App.res.mjs"
window.addEventListener("DOMContentLoaded", () => main())
```

### 3.5 `src/App.res`

全公開 API を以下のレイアウトで wire する:

```rescript
open RescriptTauriPluginShell

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      setResult(label ++ " failed: " ++ ...)
      Promise.resolve()
    })
}

// ----- openPath -----
let runOpenUrl = async () => {
  await PluginShell.openPath("https://tauri.app/")
  setResult("openPath('https://tauri.app/') resolved")
}

let runOpenWithFirefox = async () => {
  // scope の open regex に "^https?://" を許可していれば動く。
  await PluginShell.openPath("https://github.com/tauri-apps/tauri", ~openWith="firefox")
  setResult("openPath with firefox resolved")
}

// ----- Command.execute (utf8) -----
let runExecuteUtf8 = async () => {
  let cmd = PluginShell.Command.create("echo", ~args=["hello rescript-tauri"])
  let output = await cmd->PluginShell.Command.execute
  setResult("code=" ++ ... ++ "\nstdout: " ++ output.stdout)
}

// ----- Command.execute (raw) -----
let runExecuteRaw = async () => {
  let cmd = PluginShell.Command.createRaw("echo", ~args=["hello"])
  let output = await cmd->PluginShell.Command.execute
  let len = TypedArray.length(output.stdout)
  setResult("raw bytes: " ++ Int.toString(len))
}

// ----- spawn + Child -----
let runSpawnCat = async () => {
  let cmd = PluginShell.Command.create("cat")
  let child = await cmd->PluginShell.Command.spawn
  setResult("spawned cat pid=" ++ Int.toString(PluginShell.Child.pid(child)))
  await child->PluginShell.Child.write("hello from rescript\n")
  // 適切なタイミングで kill
  await child->PluginShell.Child.kill
}

// ----- streaming events -----
let streamCmdRef = ref(None)

let runStreamEcho = async () => {
  let cmd =
    PluginShell.Command.create("echo", ~args=["line one", "line two"])
    ->PluginShell.Command.onStdoutData(line => Console.log2("stdout:", line))
    ->PluginShell.Command.onStderrData(line => Console.log2("stderr:", line))
    ->PluginShell.Command.onClose(payload => {
      Console.log2("close payload:", payload)
      setResult("closed code=" ++ ...)
    })
    ->PluginShell.Command.onError(err => Console.error2("error:", err))
  streamCmdRef := Some(cmd)
  let _ = await cmd->PluginShell.Command.spawn
}

let runStreamRemove = async () => {
  switch streamCmdRef.contents {
  | Some(cmd) =>
    let _ = cmd->PluginShell.Command.removeAllListeners
    setResult("removeAllListeners called")
  | None => setResult("no streaming command active")
  }
}

// ----- type-only references for sidecar variants -----
// CI で sidecar binary を bundle しない方針 (Non-goal)。
// 型存在の reachability だけ保証する。
let _demoSidecar: PluginShell.Command.t<string> = PluginShell.Command.sidecar("ignored-sidecar")
let _demoSidecarRaw: PluginShell.Command.t<Uint8Array.t> = PluginShell.Command.sidecarRaw("ignored-sidecar")

// ----- wiring -----
let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-open-url", runOpenUrl)
  bind("btn-open-with-firefox", runOpenWithFirefox)
  bind("btn-execute-utf8", runExecuteUtf8)
  bind("btn-execute-raw", runExecuteRaw)
  bind("btn-spawn-cat", runSpawnCat)
  bind("btn-stream-echo", runStreamEcho)
  bind("btn-stream-remove", runStreamRemove)
}
```

> sidecar の型レベル参照は `_demoSidecar` / `_demoSidecarRaw` で表現する。`Command.create("ignored-sidecar")` が実際に execute されるわけではなく、変数束縛で reachability だけ示す。

### 3.6 `src-tauri/Cargo.toml`

```toml
[package]
name = "plugin-shell-demo"
version = "0.0.0"
edition = "2021"

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-shell = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### 3.7 `src-tauri/build.rs`

```rust
fn main() {
    tauri_build::build()
}
```

### 3.8 `src-tauri/src/main.rs`

```rust
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 3.9 `src-tauri/capabilities/default.json`

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-shell demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:default",
    {
      "identifier": "shell:allow-execute",
      "allow": [
        { "name": "echo", "cmd": "echo", "args": true },
        { "name": "cat", "cmd": "cat", "args": true }
      ]
    },
    {
      "identifier": "shell:allow-open",
      "allow": [{ "url": "^https?://" }]
    }
  ]
}
```

### 3.10 `src-tauri/tauri.conf.json`

`plugin-dialog-demo` のものをベースに `productName` / `identifier` / `windowsTitle` を変更:

```json
{
  "$schema": "../node_modules/@tauri-apps/cli/schema.json",
  "productName": "plugin-shell-demo",
  "version": "0.0.0",
  "identifier": "com.rescript-tauri.plugin-shell-demo",
  "build": {
    "frontendDist": "../",
    "devUrl": "http://localhost:1420"
  },
  "app": {
    "windows": [
      {
        "label": "main",
        "title": "plugin-shell demo",
        "width": 800,
        "height": 600
      }
    ],
    "security": { "csp": null }
  },
  "bundle": {
    "active": true,
    "targets": "all",
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/128x128@2x.png",
      "icons/icon.icns",
      "icons/icon.ico"
    ]
  }
}
```

実際の `tauri.conf.json` は `examples/plugin-dialog-demo/src-tauri/tauri.conf.json` を Read してそのキー構造をそのまま踏襲する（推測ではなく現物に合わせる）。

### 3.11 `src-tauri/icons/`

`examples/plugin-dialog-demo/src-tauri/icons/` 配下の全ファイルを copy。Tauri は build 時にこれら icons を参照する。

### 3.12 `README.md`

最小構成:

```markdown
# plugin-shell demo

Minimal Tauri 2.x desktop app that exercises every public function
of `@rescript-tauri/plugin-shell`.

## Run

\`\`\`bash
pnpm install
pnpm --filter plugin-shell-demo tauri dev
\`\`\`

## Buttons

- **Open https://tauri.app/** — `PluginShell.openPath`
- **Open with firefox** — `PluginShell.openPath(~openWith="firefox")`
- **Run echo (utf8)** — `Command.create` + `Command.execute`
- **Run echo (raw bytes)** — `Command.createRaw` + `Command.execute`
- **Spawn cat, write, kill** — `Command.spawn` + `Child.write` + `Child.kill`
- **Echo via onStdoutData chain** — chained `onStdoutData` / `onStderrData` / `onClose` / `onError`
- **Remove all listeners** — `Command.removeAllListeners`

Sidecar variants (`Command.sidecar` / `Command.sidecarRaw`) are
type-level-referenced from `src/App.res` only; bundling an actual
sidecar binary is out of scope.

See the [plugin-shell user guide](../../sphinx-docs/user/plugin-shell.md)
for details.
```

## 4. 共有ファイルの変更

### 4.1 root `Cargo.toml`

`members` リストにエントリ追加（アルファベット順）:

```toml
[workspace]
members = [
  "examples/hello-world/src-tauri",
  "examples/ipc-typed/src-tauri",
  "examples/ipc-typed-with-schema/src-tauri",
  "examples/plugin-dialog-demo/src-tauri",
  "examples/plugin-fs-demo/src-tauri",
  "examples/plugin-shell-demo/src-tauri",
  "examples/streaming-ipc/src-tauri",
  "examples/window-management/src-tauri",
]
```

### 4.2 `docs/repository-structure.md` §3

```markdown
examples/plugin-shell-demo/               # @rescript-tauri/plugin-shell 全関数デモ (steering 20260511-008)
```

を `examples/plugin-fs-demo/` の隣に追加。

### 4.3 `sphinx-docs/user/plugin-shell.md` の "See also"

steering 001 で `examples/plugin-shell-demo` がなかったため live demo 行を省略した。本ステアリングで example を追加した時点で:

```markdown
- Live demo:
  [`examples/plugin-shell-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-shell-demo)
```

を See also 先頭 (Source 行の前) に追加。

## 5. 影響範囲

| ファイル | 変更内容 |
|---|---|
| `examples/plugin-shell-demo/**` | 新規追加（14 ファイル前後 = ReScript / TS / Rust + icons） |
| `Cargo.toml` (root) | members 1 行追加 |
| `docs/repository-structure.md` | §3 に 1 行追加 |
| `sphinx-docs/user/plugin-shell.md` | "See also" に 1 entry 追加 |
| `pnpm-workspace.yaml` | 変更なし（glob でカバー） |
| ja `.po` | 変更なし |

## 6. 検証

1. `pnpm install`
2. `pnpm --filter plugin-shell-demo build` — ReScript ビルド成功
3. `cargo check --manifest-path examples/plugin-shell-demo/src-tauri/Cargo.toml` — Rust 側 typecheck 成功（実際の `tauri dev` 実行は CI / 手元での確認、本ステアリングでは check のみ必須）
4. `pnpm run check` — Biome lint（手書き `.mjs` / JSON に対して green であること）
5. `git diff main..HEAD --name-only` で差分が想定範囲内であることを確認

## 7. ロールバック

新規追加ディレクトリ + 3 ファイルの軽量変更のため、`git revert <merge-commit>` で原状復帰可能。
