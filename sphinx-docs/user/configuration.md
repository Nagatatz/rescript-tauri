# Configuration

## `rescript.json`

Add `@rescript-tauri/core` to the `dependencies` key. ReScript 12 renamed the legacy `bs-dependencies` to `dependencies`; the `bs-`-prefixed key is still accepted but deprecated.

```json
{
  "name": "my-app",
  "dependencies": ["@rescript-tauri/core"],
  "package-specs": [{ "module": "esmodule", "in-source": true }],
  "suffix": ".res.mjs"
}
```

If you enable `"namespace": true` in your own package, `@rescript-tauri/core` modules remain accessible under the `Tauri` namespace top-level re-export (see [`docs/functional-design.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md) §2.13).

## `peerDependencies`

`@rescript-tauri/core` declares the following `peerDependencies` so you can pin the upstream versions:

| Peer | Range |
|---|---|
| `@tauri-apps/api` | `^2.0.0` |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |

`@rescript/core` 1.6.0+ has a `peerDependencies.rescript` of `>=11.1.0`, which fully covers ReScript 12.x.

## Compatibility matrix

| Component | Supported range |
|---|---|
| Tauri | 2.x (matches the `@tauri-apps/api` peerDep range) |
| ReScript | >= 12.0.0 (uncurried-by-default) |
| `@rescript/core` | >= 1.6.0 |
| Node.js | Active LTS |
| OS | Linux / macOS / Windows (Tauri 2.x desktop targets) |

ReScript 11 is **not supported**. The decision and rationale are recorded in [PRD §10 row 7](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/product-requirements.md) and the corresponding [steering document](https://github.com/Nagatatz/rescript-tauri/tree/main/.steering/20260508-002-rescript-v12-only).

## Top-level `Tauri` re-export

`Tauri.res` re-exports a curated subset of modules so you can `open Tauri` and reach the most common entry points without long paths.

```rescript
open Tauri
let result = await Core.Raw.invoke("greet", ~args={"name": "World"})
```

The Phase 1 re-export set (confirmed 2026-05-09 — PRD §10 row 1):

| In `Tauri` | Reach via `open Tauri` |
|---|---|
| `Core` | `Core.Raw.invoke`, `Core.Command.make`, `Core.Channel`, `Core.convertFileSrc` |
| `Event` | `Event.make`, `Event.listen`, `Event.once`, `Event.emit`, `Event.emitTo` |
| `Window` | `Window.t` + ~80 instance / static methods |
| `Webview` | `Webview.t` + 14 instance methods + drag-drop variant |
| `WebviewWindow` | `WebviewWindow.asWindow` / `asWebview` casts + frequently-used methods |

| Not in `Tauri` (use explicitly) | Why |
|---|---|
| `Path` | Utility namespace; 31 helpers would shadow user names |
| `App` | Process metadata; explicit `App.getName()` is clearer |
| `Dpi` | Sized opaque types; explicit `Dpi.LogicalSize.make` reads better |
| `Image` | Opaque resource handle; explicit lifecycle |
| `Menu` / `Tray` | Heavy with sub-modules (`Menu.MenuItem`, `Menu.Submenu`, ...) |
| `Mocks` | Test-only |

## Plugin packages (Phase 2+)

Each upstream `@tauri-apps/plugin-*` will get a corresponding `@rescript-tauri/plugin-*` binding package starting in Phase 2. Plugin packages declare the upstream `@tauri-apps/plugin-*` as their own `peerDependency`.

| Package | Upstream | Phase |
|---|---|---|
| `@rescript-tauri/plugin-fs` | `@tauri-apps/plugin-fs` | Phase 2+ |
| `@rescript-tauri/plugin-dialog` | `@tauri-apps/plugin-dialog` | Phase 2+ |
| `@rescript-tauri/schema` | `rescript-schema` / `rescript-struct` | Phase 2 |
