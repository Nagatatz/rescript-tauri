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

## Compatibility matrix

| `@rescript-tauri/plugin-fs` | `@rescript-tauri/core` | `@tauri-apps/plugin-fs` | `@tauri-apps/api` |
|---|---|---|---|
| `^0.1.0` | `^0.1.0` | `^2.5.0` | `^2.0.0` |

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
