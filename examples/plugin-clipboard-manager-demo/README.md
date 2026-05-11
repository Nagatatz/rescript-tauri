# plugin-clipboard-manager demo

Minimal Tauri 2.x desktop app that exercises every public function
of [`@rescript-tauri/plugin-clipboard-manager`](../../packages/plugin-clipboard-manager).

## Run

```bash
pnpm install
pnpm --filter plugin-clipboard-manager-demo tauri dev
```

## Buttons

| Button | Calls |
|---|---|
| **writeText** | `PluginClipboardManager.writeText` |
| **readText** | `PluginClipboardManager.readText` |
| **readImage** | `PluginClipboardManager.readImage` (captures the result as a `RescriptTauriCore.Image.t` handle in memory) |
| **writeImage (round-trip last readImage)** | `PluginClipboardManager.writeImage` with the most recent `Image.t` from `readImage` |
| **writeHtml** | `PluginClipboardManager.writeHtml(html, ~altText)` |
| **clear** | `PluginClipboardManager.clear` |

Take a screenshot (or copy an image from any app) before pressing
**readImage**, then **writeImage (round-trip)** to re-publish the
same image. The polymorphic `'image` parameter of `writeImage`
accepts `string` / `Image.t` / `Uint8Array.t` / `ArrayBuffer.t` /
`array<int>` — the demo uses the `Image.t` shape.

## Capabilities

The demo uses `clipboard-manager:default`, which covers all six
clipboard APIs. See
[`src-tauri/capabilities/default.json`](./src-tauri/capabilities/default.json).

## See also

- [plugin-clipboard-manager user guide](../../sphinx-docs/user/plugin-clipboard-manager.md)
- [`@rescript-tauri/plugin-clipboard-manager` README](../../packages/plugin-clipboard-manager/README.md)
- Upstream: [Tauri 2.x clipboard plugin](https://v2.tauri.app/plugin/clipboard/)
