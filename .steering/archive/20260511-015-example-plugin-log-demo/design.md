# Design: examples/plugin-log-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-015 |
| 関連 | `requirements.md`, `packages/plugin-log/src/PluginLog.resi`, `examples/plugin-shell-demo/` |

---

## 1. アプローチ

`plugin-shell-demo` を雛形に。`src/App.res` のロジックを plugin-log API に差し替え。

## 2. ファイル構成

`plugin-shell-demo` と同型 9 ファイル + icons/。

## 3. 主要差異

### 3.1 dependencies

```json
"@rescript-tauri/plugin-log": "workspace:*",
"@tauri-apps/plugin-log": "^2.0.0"
```

### 3.2 src-tauri/Cargo.toml

```toml
[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-log = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### 3.3 src-tauri/src/main.rs

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_log::Builder::new().build())
        .run(tauri::generate_context!())
        .expect("error while running plugin-log-demo");
}
```

upstream `tauri-plugin-log` は `Builder::new().build()` 形式で plugin instance を作る。
他 plugin (init() 関数を直接使うもの) と異なる点に注意。

### 3.4 capabilities/default.json

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-log demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "log:default"
  ]
}
```

### 3.5 src/App.res

```rescript
open RescriptTauriPluginLog

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let appendResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = el["textContent"] ++ "\n" ++ text
}

let safe = (label, body) => { ... }

let levelToString = (level: int): string =>
  if level === PluginLog.LogLevel.error_ { "ERROR" }
  else if level === PluginLog.LogLevel.warn_ { "WARN" }
  else if level === PluginLog.LogLevel.info_ { "INFO" }
  else if level === PluginLog.LogLevel.debug_ { "DEBUG" }
  else if level === PluginLog.LogLevel.trace { "TRACE" }
  else { "L" ++ Int.toString(level) }

// Hold latest unlisten handles so the Detach button can call them.
let loggerUnlisten: ref<option<PluginLog.unlisten>> = ref(None)
let consoleUnlisten: ref<option<PluginLog.unlisten>> = ref(None)

let runLogError = async () => {
  await PluginLog.error("Sample error from rescript-tauri")
  appendResult("sent error")
}
// 同様に warn / info / debug / trace

let runAttachLogger = async () => {
  let un = await PluginLog.attachLogger(record => {
    appendResult("[" ++ levelToString(record.level) ++ "] " ++ record.message)
  })
  loggerUnlisten := Some(un)
  setResult("attachLogger: listening. Press log buttons to see records.")
}

let runAttachConsole = async () => {
  let un = await PluginLog.attachConsole()
  consoleUnlisten := Some(un)
  appendResult("attachConsole: log records will appear in the JS console")
}

let runDetach = async () => {
  switch loggerUnlisten.contents {
  | Some(un) => un() ; loggerUnlisten := None
  | None => ()
  }
  switch consoleUnlisten.contents {
  | Some(un) => un() ; consoleUnlisten := None
  | None => ()
  }
  appendResult("detached all listeners")
}

// Type-only references for the option records:
let _demoLogOptions: PluginLog.logOptions = {
  file: "App.res",
  line: 1,
  keyValues: Dict.fromArray([("source", "demo")]),
}
let _demoPayload = (r: PluginLog.recordPayload): string =>
  "L" ++ Int.toString(r.level) ++ " " ++ r.message
```

### 3.6 tauri.conf.json

`productName: "rescript-tauri-plugin-log-demo"`、`identifier: "com.rescript-tauri.example.plugin-log-demo"`、title `"plugin-log demo"`。

## 4. 共有ファイル

- `Cargo.toml`: `"examples/plugin-log-demo/src-tauri"` を `plugin-http-demo` の隣に追加
- `docs/repository-structure.md` §1 ツリー + §3 一覧に追加
- `sphinx-docs/user/plugin-log.md` の "See also" 先頭に live demo
- `packages/plugin-log/CHANGELOG.md` の `Added` に live example、`Deferred` 削除
- `.github/workflows/examples-build.yml` の clipboard-manager-demo の直後に 2 step
