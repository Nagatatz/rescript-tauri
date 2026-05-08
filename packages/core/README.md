# @rescript-tauri/core

Production-ready ReScript bindings for Tauri 2.x's official JS SDK
(`@tauri-apps/api`). This is the **core** package of the rescript-tauri
monorepo.

> **Status: Phase 1 — implementation in progress.** Only `Core.Raw.invoke`
> is implemented at this commit; the rest of the API surface (the typed
> `Command` layer, `Channel`, `Event`, `Window`, and the other modules)
> follows in subsequent steerings.

For project-wide context, see the [repository root README](../../README.md).
For the design rationale, see
[docs/product-requirements.md](../../docs/product-requirements.md) and
[docs/functional-design.md](../../docs/functional-design.md) §2.

## Install (after Phase 1 release)

```bash
pnpm add @rescript-tauri/core @tauri-apps/api
```

Add `@rescript-tauri/core` to `dependencies` in your `rescript.json`.

## Usage

See the [Quick Start](../../sphinx-docs/user/quickstart.md) page for the
target API. The currently implemented surface is:

```rescript
let greeting: string =
  await Tauri.Core.Raw.invoke("greet", ~args={"name": "World"})
```

## Development

This package is part of the rescript-tauri monorepo. From the repository
root:

```bash
pnpm install                                  # install all workspaces
pnpm --filter @rescript-tauri/core build      # incremental build
pnpm --filter @rescript-tauri/core test       # type-level + vitest
pnpm --filter @rescript-tauri/core run clean  # clean build artifacts
```
