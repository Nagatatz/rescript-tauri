# rescript-tauri

Production-ready ReScript bindings for Tauri 2.x's official JS SDK (`@tauri-apps/api`). A monorepo centered on `@rescript-tauri/core`, exposing the entire Tauri public API surface—IPC, Event, Window, Webview, Menu, Tray—from ReScript with a 3-layer IPC design (Raw / typed Command / Schema-integrated).

```{note}
The project is in **Phase 1 — design complete, implementation not yet started**. Sample code on these pages reflects the **target API** as defined in [RFC-0001](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0001-core-api-design.md) and [`docs/functional-design.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md). The npm package will be published once Phase 1 ships.
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
