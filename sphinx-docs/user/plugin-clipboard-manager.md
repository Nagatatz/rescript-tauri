# `@rescript-tauri/plugin-clipboard-manager`

ReScript bindings for the [Tauri 2.x clipboard
plugin](https://v2.tauri.app/plugin/clipboard/) — read and write
text, HTML, and images.

```{note}
{{ phase_2_note }}
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

### Image APIs

The image APIs share `Image.t` with
`@rescript-tauri/core` — this package does **not** define a
separate image type. Pull `Core.Image` through the peer
dependency and use its constructors / accessors when round-tripping
clipboard images.

`writeImage` is intentionally typed with a polymorphic `'image`
parameter to mirror the upstream union `string | Image |
Uint8Array | ArrayBuffer | number[]`. Pass any of those forms and
annotate the call site if the inferred type is ambiguous.

**(a) Write a `Core.Image.t` constructed from a file path:**

```rescript
module Cb = RescriptTauriPluginClipboardManager.PluginClipboardManager
module Image = RescriptTauriCore.Image

let icon = await Image.fromPath("./assets/icon.png")
await Cb.writeImage(icon)
```

**(b) Write raw RGBA bytes directly:**

```rescript
// 1×1 red pixel: R G B A
let bytes = Uint8Array.fromArray([255, 0, 0, 255])
await Cb.writeImage(bytes)
```

`readImage()` returns a `RescriptTauriCore.Image.t` resource
handle; inspect the pixel buffer with `Core.Image.rgba` (and
`Core.Image.size` for the dimensions):

```rescript
let img = await Cb.readImage()
let bytes = await Image.rgba(img)
let {width, height} = await Image.size(img)
Console.log4(
  "clipboard image:",
  Int.toString(TypedArray.length(bytes)) ++ " bytes,",
  Float.toString(width) ++ "x",
  Float.toString(height),
)
```

```{note}
`writeImage` / `readImage` are unsupported on Android / iOS upstream.
On desktop, ensure your capability set actually grants
`clipboard-manager:allow-write-image` and
`clipboard-manager:allow-read-image` (both are bundled in the
`clipboard-manager:default` alias used above).
```

### Pitfalls — Image RGBA layout

`Core.Image.rgba` and the bytes accepted by `Core.Image.new_` are
**row-major, top-to-bottom, RGBA8** (one byte per channel, alpha
last). Image libraries that hand back BGRA, bottom-to-top scans,
or pre-multiplied alpha must be converted before being handed to
the clipboard — otherwise pasted images will exhibit channel
swaps or vertical mirroring.

### HTML APIs

`writeHtml(html, ~altText=?)` stores rich-text on the clipboard
using the OS-native HTML format. The typical use case is making
formatted text (bold, colors, links, tables) pasteable into apps
that honor HTML clipboard data (word processors, email composers,
rich text editors). The optional `~altText` argument is the
plain-text fallback handed to clients that decline HTML payloads
— always supply it if the rich content has a meaningful textual
equivalent.

```rescript
await Cb.writeHtml(
  "<p>Visit <a href=\"https://tauri.app\">Tauri</a> for docs.</p>",
  ~altText="Visit https://tauri.app for docs.",
)
```

Omitting `~altText` leaves the plain-text slot empty; consumers
that cannot accept HTML may then paste nothing.

### Clear

`clear()` empties the clipboard. On Android with SDK < 28 the
underlying platform API is unavailable and the binding falls back
to writing an empty string — be aware that on those versions the
clipboard will still contain a (zero-length) text item afterwards
rather than being truly empty.

```rescript
await Cb.clear()
```

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-clipboard-manager` | `^2.0.0` (peer) |
| Rust `tauri-plugin-clipboard-manager` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows (image and HTML APIs unsupported on Android / iOS) |

## See also

- Source:
  [`packages/plugin-clipboard-manager`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-clipboard-manager)
- Package README:
  [`packages/plugin-clipboard-manager/README.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-clipboard-manager/README.md)
- Image type (peer-dep reuse):
  [`packages/core/src/Image.resi`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/core/src/Image.resi)
- Upstream docs:
  [Tauri 2.x clipboard plugin](https://v2.tauri.app/plugin/clipboard/)
