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

## Polymorphic variants

Four polymorphic-variant types mirror the upstream string-literal
unions. Each is exhaustively pattern-matchable, so the ReScript
compiler flags missing cases at build time.

| Type | Cases | Returned by |
|---|---|---|
| `platform` | `#linux` / `#macos` / `#ios` / `#freebsd` / `#dragonfly` / `#netbsd` / `#openbsd` / `#solaris` / `#android` / `#windows` (10) | `platform()` |
| `osType` | `#linux` / `#windows` / `#macos` / `#ios` / `#android` (5) | `osType_()` |
| `arch` | `#x86` / `#x86_64` / `#arm` / `#aarch64` / `#mips` / `#mips64` / `#powerpc` / `#powerpc64` / `#riscv64` / `#s390x` / `#sparc64` (11) | `arch()` |
| `family` | `#unix` / `#windows` (2) | `family()` |

### Pattern match example

Branch on `platform()` to label the runtime environment:

```rescript
open RescriptTauriPluginOs

let labelForPlatform = () =>
  switch PluginOs.platform() {
  | #macos => "macOS"
  | #linux
  | #freebsd
  | #dragonfly
  | #netbsd
  | #openbsd
  | #solaris => "Unix-like"
  | #windows => "Windows"
  | #ios => "iOS"
  | #android => "Android"
  }

Console.log(labelForPlatform())
```

If upstream adds a new platform in a future minor release and the
binding picks it up, the compiler will flag this `switch` as
non-exhaustive on the next build — turning a silent upstream
expansion into a deliberate decision point.

## Pitfalls

### `type()` renamed to `osType_()`

Upstream JavaScript exposes the OS type through a function called
`type`. `type` is reserved in ReScript, so the binding renames it
to `osType_()` (suffixed underscore matches the project-wide
convention for reserved-word avoidance):

```rescript
let osType = PluginOs.osType_() // not PluginOs.type()
```

### Sync getters don't go through IPC

`Mocks.mockIPC` only intercepts IPC commands. The seven sync
getters bypass IPC entirely, so tests that need to fake their
return values stub the underlying global directly:

```javascript
// in a vitest setup file
globalThis.window = globalThis.window || {}
globalThis.window.__TAURI_OS_PLUGIN_INTERNALS__ = {
  platform: "linux",
  version: "6.5.0",
  family: "unix",
  os_type: "Linux",
  arch: "x86_64",
  exe_extension: "",
  eol: "\n",
}
```

The async `locale()` / `hostname()` calls do go through IPC and
can be mocked with `Mocks.mockIPC` as usual.

### `#x86_64`, `#powerpc64`, etc. are valid as-is

ReScript polymorphic-variant tags accept `_` and digits, so the
upstream `"x86_64"` / `"powerpc64"` / `"riscv64"` / `"s390x"` /
`"sparc64"` strings translate to `#x86_64` / `#powerpc64` /
`#riscv64` / `#s390x` / `#sparc64` without any quoting or escape.

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-os` | `^2.0.0` (peer) |
| Rust `tauri-plugin-os` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows / iOS / Android |

## See also

- Source:
  [`packages/plugin-os`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-os)
- Upstream docs:
  [Tauri 2.x os plugin](https://v2.tauri.app/plugin/os-info/)
- Upstream JS reference:
  [os module](https://v2.tauri.app/reference/javascript/os/)
