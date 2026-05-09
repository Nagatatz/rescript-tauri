# @rescript-tauri/plugin-clipboard-manager

ReScript bindings for [`@tauri-apps/plugin-clipboard-manager`](https://www.npmjs.com/package/@tauri-apps/plugin-clipboard-manager)
— Tauri 2.x's clipboard plugin (read/write text, HTML, and images).

## Status

Phase 2+, first iteration. Awaiting first npm publish (`plugin-clipboard-manager-v0.1.0`).

100% coverage of the stable public surface of `@tauri-apps/plugin-clipboard-manager` v2.3.2.

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-clipboard-manager @rescript-tauri/core @tauri-apps/plugin-clipboard-manager @tauri-apps/api
```

## Quick example

```rescript
module Cb = RescriptTauriPluginClipboardManager.PluginClipboardManager

let copyAndPaste = async () => {
  await Cb.writeText("Tauri is awesome!")
  let text = await Cb.readText()
  Console.log2("clipboard:", text)
}
```

## Public API

| Symbol | Purpose |
|---|---|
| `writeText(text, ~opts=?)` | Write plain text. `opts.label` adds an Android entity name |
| `readText()` | Read plain text |
| `writeImage('image)` | Write a raw RGBA buffer / `Image.t` / Uint8Array / array<int> / file path |
| `readImage()` | Read as `RescriptTauriCore.Image.t` (use `Image.rgba` to inspect) |
| `writeHtml(html, ~altText=?)` | Write HTML with optional plain-text fallback |
| `clear()` | Clear the clipboard |
| `writeTextOptions` | `{label?: string}` |

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-clipboard-manager` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-clipboard-manager` | `^2.0.0` (peer) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows (image / HTML APIs unsupported on Android / iOS) |

## See also

- [Changelog](./CHANGELOG.md)
- Upstream docs:
  [Tauri 2.x clipboard plugin](https://v2.tauri.app/plugin/clipboard/)
- [`@rescript-tauri/core` README](../core/README.md)
