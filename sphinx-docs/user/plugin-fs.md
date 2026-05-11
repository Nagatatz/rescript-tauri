# `@rescript-tauri/plugin-fs`

ReScript bindings for the [Tauri 2.x filesystem
plugin](https://v2.tauri.app/plugin/file-system/). Single-shot
file IO (read / write / dir / stat) is covered; `FileHandle`,
`watch`, `readTextFileLines`, and the iOS-only security-scoped
APIs are deferred to a follow-up package iteration.

```{note}
{{ phase_2_note }}
```

## Install

```bash
pnpm add @rescript-tauri/plugin-fs @tauri-apps/plugin-fs
```

`@rescript-tauri/plugin-fs` declares both
`@rescript-tauri/core` and `@tauri-apps/plugin-fs` as
`peerDependencies`, so you control each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-fs"
  ]
}
```

On the Rust side, add the plugin crate and register it on the
builder:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-fs = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_fs::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

## Capabilities

Tauri 2.x requires every filesystem operation to be granted a
capability. The minimal set used by
[`examples/plugin-fs-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-fs-demo)
is:

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "fs:default",
    "fs:allow-app-local-data-recursive"
  ]
}
```

`fs:allow-app-local-data-recursive` is a permission alias shipped
by the plugin that opens up the entire `$APPLOCALDATA` subtree.
Swap it for `fs:allow-home-recursive`,
`fs:allow-document-recursive`, etc. when you need a different
sandbox.

## Minimal example

```rescript
open RescriptTauriPluginFs

let baseDir = PluginFs.BaseDirectory.appLocalData

await PluginFs.mkdir(
  "notes",
  ~options={baseDir: baseDir, recursive: true},
)
await PluginFs.writeTextFile(
  "notes/hello.txt",
  "Hello from rescript-tauri.\n",
  ~options={baseDir: baseDir, create: true},
)
let body = await PluginFs.readTextFile(
  "notes/hello.txt",
  ~options={baseDir: baseDir},
)
Console.log(body)
```

## Public API

All 14 single-shot IO functions are exposed under `PluginFs`:

| Function | Notes |
|---|---|
| `readTextFile` | UTF-8 text read |
| `writeTextFile` | UTF-8 text write |
| `readFile` | Raw bytes (`Uint8Array.t`) |
| `writeFile` | Raw bytes |
| `exists` | Path existence |
| `remove` | File or directory (set `recursive: true` for trees) |
| `rename` | Move within the filesystem |
| `mkdir` | Directory creation (`recursive: true` for parents) |
| `readDir` | Direct children of a directory |
| `stat` | Metadata, follows symlinks |
| `lstat` | Metadata, does **not** follow symlinks |
| `truncate` | Resize a file to N bytes |
| `copyFile` | Copy with optional cross-base-dir paths |
| `size` | Plain byte count |

The associated option records (`readFileOptions`,
`writeFileOptions`, `mkdirOptions`, `removeOptions`,
`renameOptions`, `copyFileOptions`, `statOptions`,
`existsOptions`, `readDirOptions`, `truncateOptions`) are all
re-exported from `PluginFs` and the upstream
[FileInfo](https://v2.tauri.app/reference/javascript/fs/#fileinfo)
/ [DirEntry](https://v2.tauri.app/reference/javascript/fs/#direntry)
shapes are available as `PluginFs.fileInfo` /
`PluginFs.dirEntry`.

`BaseDirectory` is **re-exported from
`@rescript-tauri/core`** so you don't need a separate import:

```rescript
let baseDir = PluginFs.BaseDirectory.appLocalData
// equivalent to RescriptTauriCore.Path.BaseDirectory.appLocalData
```

## Pitfalls

### Single-field record punning

ReScript treats `{baseDir}` as a *block* with a single statement,
not a record with one punned field. Always spell out single-field
options as `{baseDir: baseDir}`:

```rescript
// ❌ compile error: expected record, got block
await PluginFs.exists("foo.txt", ~options={baseDir})

// ✅
await PluginFs.exists("foo.txt", ~options={baseDir: baseDir})
```

Multi-field records (`{baseDir, recursive: true}`) work as
expected.

### `Uint8Array` length

`Uint8Array.t` in `@rescript/core` is an alias for
`TypedArray.t<int>`. The length getter lives on the parent
module:

```rescript
let bytes = await PluginFs.readFile("data.bin", ~options={baseDir: baseDir})
Console.log("byte count: " ++ Int.toString(TypedArray.length(bytes)))
```

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-fs` | `^2.5.0` (peer) |
| Rust `tauri-plugin-fs` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## See also

- Live demo:
  [`examples/plugin-fs-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-fs-demo)
- Source:
  [`packages/plugin-fs`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-fs)
- Upstream docs:
  [Tauri 2.x file-system plugin](https://v2.tauri.app/plugin/file-system/)
