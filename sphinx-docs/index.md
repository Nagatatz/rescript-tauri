# rescript-tauri

Production-ready ReScript bindings for Tauri 2.x's official JS SDK (`@tauri-apps/api`). A monorepo centered on `@rescript-tauri/core`, exposing the entire Tauri public API surface—IPC, Event, Window, Webview, Menu, Tray—from ReScript with a 3-layer IPC design (Raw / typed Command / Schema-integrated).

```{note}
All ten `@rescript-tauri/*` packages are published on npm (current release `0.1.2`). Sample code on these pages mirrors the released source, and the `pnpm add @rescript-tauri/*` snippets work as written.
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

## Plugins & add-ons

Nine add-on packages build on `@rescript-tauri/core`. Each ships independently and pulls the matching upstream `@tauri-apps/plugin-*` (or `rescript-schema`) through `peerDependencies`.

::::{grid} 1 2 2 3
:gutter: 3

:::{grid-item-card} plugin-fs
:link: user/plugin-fs
:link-type: doc

Filesystem operations (read / write / dir / stat).
:::

:::{grid-item-card} plugin-dialog
:link: user/plugin-dialog
:link-type: doc

Native dialogs (open / save / message / ask / confirm).
:::

:::{grid-item-card} plugin-notification
:link: user/plugin-notification
:link-type: doc

Native notifications (toast / schedule / channels).
:::

:::{grid-item-card} plugin-shell
:link: user/plugin-shell
:link-type: doc

Spawn child processes, open URLs / files with the OS default.
:::

:::{grid-item-card} plugin-log
:link: user/plugin-log
:link-type: doc

Structured logging (5 levels + log-stream listeners).
:::

:::{grid-item-card} plugin-os
:link: user/plugin-os
:link-type: doc

OS info (platform / arch / family / locale / hostname).
:::

:::{grid-item-card} plugin-clipboard-manager
:link: user/plugin-clipboard-manager
:link-type: doc

Clipboard read/write (text / image / HTML).
:::

:::{grid-item-card} plugin-http
:link: user/plugin-http
:link-type: doc

HTTP fetch with CORS bypass + proxy / TLS config.
:::

:::{grid-item-card} schema
:link: user/schema
:link-type: doc

Layer 3 typed IPC via `rescript-schema`.
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
