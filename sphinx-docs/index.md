# rescript-tauri

Production-ready ReScript bindings for Tauri 2.x's official JS SDK (`@tauri-apps/api`). A monorepo centered on `@rescript-tauri/core`, exposing the entire Tauri public API surface—IPC, Event, Window, Webview, Menu, Tray—from ReScript with a 3-layer IPC design (Raw / typed Command / Schema-integrated).

```{note}
Phase 1 + Phase 2 implementations are merged on `main`. The `@rescript-tauri/core`, `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog`, and `@rescript-tauri/schema` packages are awaiting their first npm publish on the `v0.1.0` track. Sample code on these pages mirrors the merged source — install paths and the `pnpm add @rescript-tauri/*` snippets activate once the first `0.1.0` releases ship.
```

::::{grid} 1 1 2 2
:gutter: 3

:::{grid-item-card} User Guide
:link: user/index
:link-type: doc

Install rescript-tauri, take the typed `Command` API for a spin, and configure your `rescript.json`.

+++
[Get started →](user/index.md)
:::

:::{grid-item-card} Developer Guide
:link: dev/index
:link-type: doc

Set up the docs site locally, learn the build / translate / deploy flow, and contribute.

+++
[Read more →](dev/index.md)
:::
::::

## Quick Links

- [Installation](user/installation.md)
- [Quick Start](user/quickstart.md)
- [Configuration](user/configuration.md)
- [Changelog](user/changelog.md)

```{toctree}
:hidden:
:maxdepth: 2

user/index
dev/index
```
