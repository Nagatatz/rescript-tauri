# `@rescript-tauri/plugin-clipboard-manager`

ReScript bindings for the [Tauri 2.x clipboard
plugin](https://v2.tauri.app/plugin/clipboard/) — read and write
text, HTML, and images.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-clipboard-manager-v0.1.0`) is scheduled
alongside the other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-clipboard-manager` via the source
repository or a workspace link.
```

```{tip}
The image APIs (`writeImage` / `readImage`) reuse
`@rescript-tauri/core`'s
[`Image`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/core/src/Image.resi)
module directly — no separate image type ships with this
package. Construct an `Image.t` with `Core.Image.fromPath` or
`Core.Image.fromBytes`, write it via `writeImage`, and inspect
clipboard image bytes with `Core.Image.rgba`.
```

## Install

```bash
pnpm add @rescript-tauri/plugin-clipboard-manager @tauri-apps/plugin-clipboard-manager
```

`@rescript-tauri/plugin-clipboard-manager` declares both
`@rescript-tauri/core` and `@tauri-apps/plugin-clipboard-manager`
as `peerDependencies`, so you control each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-clipboard-manager"
  ]
}
```

On the Rust side, add the plugin crate and register it on the
builder:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-clipboard-manager = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_clipboard_manager::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

## Capabilities

Tauri 2.x requires every clipboard operation to be granted a
capability. The minimal set is:

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "clipboard-manager:default"
  ]
}
```

`clipboard-manager:default` covers every read and write API
exposed by this binding. To allow only a subset, swap it for the
narrower aliases shipped by the plugin
([reference](https://v2.tauri.app/plugin/clipboard/#permissions)) —
for example `clipboard-manager:allow-write-text` plus
`clipboard-manager:allow-read-text` for a paste-only utility.

## Minimal example

```rescript
module Cb = RescriptTauriPluginClipboardManager.PluginClipboardManager

let copyAndPaste = async () => {
  await Cb.writeText("Tauri is awesome!")
  let text = await Cb.readText()
  Console.log2("clipboard:", text)
}
```

## Public API

The six public functions plus the `writeTextOptions` record cover
the entire upstream surface of
`@tauri-apps/plugin-clipboard-manager` v2.3.x.

| Symbol | Purpose |
|---|---|
| `writeText(text, ~opts=?)` | Write plain text. `opts.label` adds an Android entity name |
| `readText()` | Read plain text |
| `writeImage('image)` | Write a raw RGBA buffer / `Image.t` / `Uint8Array` / `array<int>` / file path |
| `readImage()` | Read as `RescriptTauriCore.Image.t` (inspect with `Image.rgba`) |
| `writeHtml(html, ~altText=?)` | Write HTML with optional plain-text fallback |
| `clear()` | Clear the clipboard |
| `writeTextOptions` | `{label?: string}` |

### Text APIs

`writeText` and `readText` are the most common entry points.
`writeText` accepts an optional `writeTextOptions` record whose
only field, `label`, surfaces as the *clipboard entity name* on
Android clipboard history pickers (no-op on desktop):

```rescript
await Cb.writeText(
  "Public address: 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
  ~opts={label: "Wallet address"},
)

let copied = await Cb.readText()
Console.log("clipboard now contains: " ++ copied)
```

`readText()` returns `string`. If the clipboard does not contain
text, the underlying Rust call surfaces an error — wrap the call
in `try { ... } catch` if you need to differentiate "empty
clipboard" from real failures.
