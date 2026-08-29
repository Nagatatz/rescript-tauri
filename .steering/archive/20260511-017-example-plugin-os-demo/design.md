# Design: examples/plugin-os-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-017 |
| 関連 | `requirements.md`, `packages/plugin-os/src/PluginOs.resi`, `examples/plugin-shell-demo/` |

---

## 1. アプローチ

`plugin-shell-demo` を雛形に、`src/App.res` のロジックを plugin-os 用に差し替え。最小構成 (3 button)。

## 2. ファイル構成

`plugin-shell-demo` と同型 9 ファイル + icons/。

## 3. 主要差異

### 3.1 dependencies

```json
"@rescript-tauri/plugin-os": "workspace:*",
"@tauri-apps/plugin-os": "^2.0.0"
```

### 3.2 src-tauri/Cargo.toml

```toml
[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-os = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### 3.3 src-tauri/src/main.rs

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .run(tauri::generate_context!())
        .expect("error while running plugin-os-demo");
}
```

### 3.4 capabilities/default.json

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-os demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "os:default"
  ]
}
```

### 3.5 src/App.res 骨子

```rescript
open RescriptTauriPluginOs

@val external document: 'a = "document"

let setResult / safe / ...

let platformToString = (p: PluginOs.platform): string =>
  switch p {
  | #linux => "linux"
  | #macos => "macos"
  | #ios => "ios"
  | #freebsd => "freebsd"
  | #dragonfly => "dragonfly"
  | #netbsd => "netbsd"
  | #openbsd => "openbsd"
  | #solaris => "solaris"
  | #android => "android"
  | #windows => "windows"
  }

let osTypeToString = (t: PluginOs.osType): string =>
  switch t {
  | #linux => "linux"
  | #windows => "windows"
  | #macos => "macos"
  | #ios => "ios"
  | #android => "android"
  }

let archToString = (a: PluginOs.arch): string =>
  switch a {
  | #x86 => "x86"
  | #x86_64 => "x86_64"
  | #arm => "arm"
  | #aarch64 => "aarch64"
  | #mips => "mips"
  | #mips64 => "mips64"
  | #powerpc => "powerpc"
  | #powerpc64 => "powerpc64"
  | #riscv64 => "riscv64"
  | #s390x => "s390x"
  | #sparc64 => "sparc64"
  }

let familyToString = (f: PluginOs.family): string =>
  switch f {
  | #unix => "unix"
  | #windows => "windows"
  }

let escapeEol = (s: string): string =>
  s->String.replaceAll("\n", "\\n")->String.replaceAll("\r", "\\r")

let runShowAll = async () => {
  let lines = [
    "eol         : " ++ escapeEol(PluginOs.eol()),
    "platform    : " ++ platformToString(PluginOs.platform()),
    "version     : " ++ PluginOs.version(),
    "family      : " ++ familyToString(PluginOs.family()),
    "osType      : " ++ osTypeToString(PluginOs.osType_()),
    "arch        : " ++ archToString(PluginOs.arch()),
    "exeExtension: '" ++ PluginOs.exeExtension() ++ "'",
  ]
  setResult(Array.join(lines, "\n"))
}

let runGetLocale = async () => {
  let l = await PluginOs.locale()
  let s = switch l->Nullable.toOption {
  | Some(v) => v
  | None => "(null)"
  }
  setResult("locale: " ++ s)
}

let runGetHostname = async () => {
  let h = await PluginOs.hostname()
  let s = switch h->Nullable.toOption {
  | Some(v) => v
  | None => "(null)"
  }
  setResult("hostname: " ++ s)
}

let bind / main / ...
```

### 3.6 tauri.conf.json

`productName: "rescript-tauri-plugin-os-demo"`、`identifier: "com.rescript-tauri.example.plugin-os-demo"`、title `"plugin-os demo"`。

## 4. 共有ファイル

- `Cargo.toml`: members に追加
- `docs/repository-structure.md` §1 + §3
- `sphinx-docs/user/plugin-os.md` "See also" に live demo
- `packages/plugin-os/CHANGELOG.md` `Added` 追加 + `Deferred` 削除
- `.github/workflows/examples-build.yml` の plugin-notification-demo の隣に 2 step
