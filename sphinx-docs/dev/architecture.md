# Architecture

This page is a high-level summary aimed at first-time readers of the docs site. The canonical, in-depth treatment lives in the internal [`docs/architecture.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/architecture.md) (Japanese).

## Overview

`rescript-tauri` is a pnpm-workspace monorepo of ReScript binding packages around Tauri 2.x's official JS SDK (`@tauri-apps/api`). The core package, `@rescript-tauri/core`, exposes the entire upstream public API surface (IPC, Event, Window, Webview, Menu, Tray, etc.) with idiomatic ReScript types.

```
┌──────────────────────────────────────────────┐
│  Layer 3: @rescript-tauri/schema             │
│   └─ Command.fromSchemas (rescript-schema)   │
├──────────────────────────────────────────────┤
│  Layer 2: Core.Command                       │
│   └─ make / invoke / invokeExn               │
├──────────────────────────────────────────────┤
│  Layer 1: Core.Raw                           │
│   └─ invoke / convertFileSrc                 │
└──────────────────────────────────────────────┘
            ↓ JS bridge
   @tauri-apps/api/core (upstream)
```

## Key components

| Package | Role |
|---|---|
| `@rescript-tauri/core` | Core bindings for the entire `@tauri-apps/api` public surface |
| `@rescript-tauri/plugin-fs` | Bindings for `@tauri-apps/plugin-fs` |
| `@rescript-tauri/plugin-dialog` | Bindings for `@tauri-apps/plugin-dialog` |
| `@rescript-tauri/schema` | `Command.fromSchemas` helper (`rescript-schema` integration) |
| `examples/*` | Buildable usage examples (CI gate on 3 OS) |

## Design principles

The full discussion is in `docs/architecture.md` §3. The headline principles, mirroring the README highlights:

1. **Idiomatic ReScript.** `variant` / `option` / `result` / polymorphic variants replace the `unknown` and string-literal-union escape hatches that TypeScript users reach for.
2. **Faithful to Tauri.** Near-1:1 mapping with the JS API surface so that the official Tauri docs remain directly applicable. Each `.resi` doc comment links to the corresponding Tauri page.
3. **Three-layer IPC.** Layer 1 (Raw) / Layer 2 (typed Command) / Layer 3 (Schema) lets users pick the safety/ergonomics trade-off that fits.
4. **Maintainable monorepo.** Mirrors the structure of `@tauri-apps/plugin-*`. Each package versions independently. Designed to remain sustainable for a 1–3 person maintainer team.

## Where to dig deeper

| Topic | Source |
|---|---|
| Module-by-module API specifications | [`docs/functional-design.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/functional-design.md) (Japanese) |
| Cross-cutting design (error / lifetime / JSON / variants / inheritance) | [`docs/architecture.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/architecture.md) §3, §5 (Japanese) |
| Original RFC | [`docs/ideas/RFC-0001-core-api-design.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0001-core-api-design.md) (English) |
| Repository layout (canonical) | [`docs/repository-structure.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/repository-structure.md) (Japanese) |
