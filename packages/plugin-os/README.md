# @rescript-tauri/plugin-os

ReScript bindings for [`@tauri-apps/plugin-os`](https://www.npmjs.com/package/@tauri-apps/plugin-os)
— Tauri 2.x's OS info plugin (`platform` / `version` / `arch` /
`family` / `hostname` / `locale` etc.).

## Status

Phase 2+, first iteration. Awaiting first npm publish (`plugin-os-v0.1.0`).

100% coverage of the stable public surface of `@tauri-apps/plugin-os` v2.3.2.

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-os @rescript-tauri/core @tauri-apps/plugin-os @tauri-apps/api
```

## Quick example

```rescript
module Os = RescriptTauriPluginOs.PluginOs

let logEnv = async () => {
  Console.log4("platform:", Os.platform(), "arch:", Os.arch())
  Console.log2("eol bytes:", Os.eol())
  let host = await Os.hostname()
  Console.log2("hostname:", host->Nullable.toOption->Option.getOr("(none)"))
}
```

## Public API

| Symbol | Sync? | Purpose |
|---|---|---|
| `eol()` | sync | OS-specific end-of-line marker (`\n` / `\r\n`) |
| `platform()` | sync | `[#linux \| #macos \| #ios \| #freebsd \| #dragonfly \| #netbsd \| #openbsd \| #solaris \| #android \| #windows]` |
| `version()` | sync | OS version string |
| `family()` | sync | `[#unix \| #windows]` |
| `osType_()` | sync | `[#linux \| #windows \| #macos \| #ios \| #android]` (renamed from upstream `type` because `type` is reserved in ReScript) |
| `arch()` | sync | `[#x86 \| #x86_64 \| #arm \| #aarch64 \| ...]` (11 variants) |
| `exeExtension()` | sync | Executable file extension (`"exe"` or `""`) |
| `locale()` | async | BCP-47 language tag, or `Nullable.null` |
| `hostname()` | async | OS hostname, or `Nullable.null` |
| `platform` / `osType` / `arch` / `family` | type | Polymorphic variants matching the upstream string-literal types |

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-os` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-os` | `^2.0.0` (peer) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows / iOS / Android |

## See also

- [Changelog](./CHANGELOG.md)
- Upstream docs:
  [Tauri 2.x os plugin](https://v2.tauri.app/plugin/os-info/)
- [`@rescript-tauri/core` README](../core/README.md)
