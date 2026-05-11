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
