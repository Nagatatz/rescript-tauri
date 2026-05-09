# @rescript-tauri/plugin-fs

ReScript bindings for [`@tauri-apps/plugin-fs`](https://www.npmjs.com/package/@tauri-apps/plugin-fs)
— Tauri 2.x's filesystem plugin.

## Status

Phase 2, first iteration. Awaiting first npm publish (`plugin-fs-v0.1.0`).

**Bundled in this iteration:** 14 single-shot IO functions
(`readTextFile` / `writeTextFile` / `readFile` / `writeFile` / `exists` /
`remove` / `rename` / `mkdir` / `readDir` / `stat` / `lstat` / `truncate` /
`copyFile` / `size`) plus their record types.

**Deferred to follow-up sub-steerings:**
- `FileHandle` class (`open` / `create` + instance methods)
- `watch` / `watchImmediate` + `WatchEvent` variant tree
- `readTextFileLines` (AsyncIterable return)
- iOS-only security-scoped resource APIs

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-fs @rescript-tauri/core @tauri-apps/plugin-fs @tauri-apps/api
```

Add to `rescript.json`:

```json
{
  "dependencies": ["@rescript/core", "@rescript-tauri/core", "@rescript-tauri/plugin-fs"]
}
```

## Quick example

```rescript
module Fs = RescriptTauriPluginFs.PluginFs
module Path = RescriptTauriCore.Path

let main = async () => {
  // Resolve to $APPCONFIG/notes.txt and write
  await Fs.writeTextFile(
    "notes.txt",
    "hello, ReScript",
    ~options={baseDir: Path.BaseDirectory.appConfig},
  )

  // Read it back
  let body = await Fs.readTextFile(
    "notes.txt",
    ~options={baseDir: Path.BaseDirectory.appConfig},
  )
  Console.log(body)
}
```

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-fs` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-fs` | `^2.5.0` (peer) |
| `@tauri-apps/api` | `^2.0.0` (transitive via core) |
| Rust `tauri-plugin-fs` | `2.x` |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## Public API (this iteration)

| Symbol | Purpose |
|---|---|
| `readTextFile` / `writeTextFile` | UTF-8 text round-trip |
| `readFile` / `writeFile` | Raw bytes round-trip (`Uint8Array.t`) |
| `exists` | Check whether a path is present |
| `remove` | Remove a file or directory (with optional recursion) |
| `rename` | Move / rename |
| `mkdir` | Create a directory (with optional recursion + mode) |
| `readDir` | Enumerate a directory's children (`array<dirEntry>`) |
| `stat` / `lstat` | File metadata (`fileInfo`); `lstat` does not follow symlinks |
| `truncate` | Truncate to `~len` bytes |
| `copyFile` | Copy a file |
| `size` | Return file size in bytes |

`PluginFs.BaseDirectory` is re-exported from `@rescript-tauri/core`'s `Path.BaseDirectory`, so the same numeric-private-int enum is shared across both packages.

See `src/PluginFs.resi` for full documentation comments and matching upstream URLs.

## Pitfalls

- **Single-field record punning**: ReScript treats `{baseDir}` as a
  block, not a one-field record. Use `{baseDir: baseDir}` for any
  single-field option literal. Multi-field option records
  (`{baseDir, recursive: true}`) work as expected.
- **`Uint8Array` length**: `Uint8Array.t` aliases `TypedArray.t<int>`
  in `@rescript/core`; use `TypedArray.length(bytes)` to read the
  byte count.

The full user-guide write-up of these pitfalls is in
[`sphinx-docs/user/plugin-fs.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/plugin-fs.md).

## See also

- [User guide page](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/plugin-fs.md)
- Runnable demo:
  [`examples/plugin-fs-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-fs-demo)
- Upstream docs:
  [Tauri 2.x file-system plugin](https://v2.tauri.app/plugin/file-system/)
- [`@rescript-tauri/core` README](../core/README.md)
