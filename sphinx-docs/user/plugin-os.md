# `@rescript-tauri/plugin-os`

ReScript bindings for the [Tauri 2.x OS info
plugin](https://v2.tauri.app/plugin/os-info/) — synchronous
getters for `platform` / `version` / `arch` / `family` and async
getters for `locale` / `hostname`. The 100% stable public surface
of `@tauri-apps/plugin-os` v2.3.x is covered, surfaced through
four polymorphic-variant types that mirror the upstream
string-literal unions.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-os-v0.1.0`) is scheduled alongside the
other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-os` via the source repository or a
workspace link.
```

## Install

```bash
pnpm add @rescript-tauri/plugin-os @tauri-apps/plugin-os
```

`@rescript-tauri/plugin-os` declares both `@rescript-tauri/core`
and `@tauri-apps/plugin-os` as `peerDependencies`, so you control
each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-os"
  ]
}
```

On the Rust side, register the plugin on the builder:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-os = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

`tauri_plugin_os::init()` takes no configuration — the default
builder is sufficient for every API exposed by this binding.

## Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "os:default"
  ]
}
```

`os:default` grants the IPC permissions `allow-locale` and
`allow-hostname` that the two async getters require. The seven
synchronous getters do **not** travel over IPC (see [Sync
getters](#sync-getters) below) and therefore do not consume a
capability — but the plugin must still be registered on the Rust
builder for the JavaScript globals to be initialized.

## Sync getters

Seven of the nine functions resolve at call-site without ever
touching IPC: upstream caches the values on the
`window.__TAURI_OS_PLUGIN_INTERNALS__` global during plugin
initialization and the binding just reads them back. This makes
them cheap to call repeatedly, but it also means
`RescriptTauriCore.Mocks.mockIPC` **cannot intercept them** —
runtime tests stub `globalThis.window.__TAURI_OS_PLUGIN_INTERNALS__`
directly (see `packages/plugin-os/tests/runtime/plugin_os.test.mjs`).

```rescript
open RescriptTauriPluginOs

let dumpEnv = () => {
  Console.log2("eol bytes:    ", PluginOs.eol())          // "\n" or "\r\n"
  Console.log2("platform:     ", PluginOs.platform())     // #linux | #macos | ...
  Console.log2("version:      ", PluginOs.version())      // OS version string
  Console.log2("family:       ", PluginOs.family())       // #unix | #windows
  Console.log2("osType:       ", PluginOs.osType_())      // #linux | #windows | ...
  Console.log2("arch:         ", PluginOs.arch())         // #x86_64 | #aarch64 | ...
  Console.log2("exeExtension: ", PluginOs.exeExtension()) // "exe" or ""
}
```

| Function | Returns | Notes |
|---|---|---|
| `eol()` | `string` | OS-specific line terminator (`"\n"` on POSIX, `"\r\n"` on Windows) |
| `platform()` | `platform` variant | 10 cases covering every desktop / mobile target |
| `version()` | `string` | Kernel / release identifier, freeform |
| `family()` | `family` variant | `#unix` for POSIX-like systems, `#windows` otherwise |
| `osType_()` | `osType` variant | Renamed from upstream `type()` — `type` is reserved in ReScript |
| `arch()` | `arch` variant | 11 CPU architectures |
| `exeExtension()` | `string` | `"exe"` on Windows, `""` elsewhere |

## Async getters

The remaining two functions are async because they pull values
from the OS at call time rather than at plugin init. They go
through the regular Tauri IPC (`plugin:os|locale` and
`plugin:os|hostname`) and return `promise<Nullable.t<string>>` —
`Nullable.null` means the OS did not expose the value.

```rescript
open RescriptTauriPluginOs

let printIdentity = async () => {
  let host = await PluginOs.hostname()
  let lang = await PluginOs.locale()

  Console.log2(
    "hostname:",
    host->Nullable.toOption->Option.getOr("(unknown)"),
  )
  Console.log2(
    "locale:  ",
    lang->Nullable.toOption->Option.getOr("(unknown)"),
  )
}
```

| Function | Returns | Notes |
|---|---|---|
| `locale()` | `promise<Nullable.t<string>>` | BCP-47 language tag (e.g. `"en-US"`) |
| `hostname()` | `promise<Nullable.t<string>>` | OS hostname; not guaranteed to be a DNS-resolvable name |

### Capability requirement

Both async getters are gated by the `os:default` capability set
shown above; without it, the IPC bridge rejects the call before
the plugin runs. Sync getters do not check capabilities — they
read the cached globals directly — so a Tauri app could
technically ship without `os:default` if it only uses
`platform()` / `arch()` / etc. In practice, granting
`os:default` is the simplest setup and matches what the upstream
docs recommend.
