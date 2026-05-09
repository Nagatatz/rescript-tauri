# hello-world

Minimal Tauri 2.x desktop app demonstrating `@rescript-tauri/core`'s
Layer 1 (`Core.Raw.invoke`).

## Status

Phase 1 baseline — shipped. The frontend ReScript piece builds with
`pnpm --filter hello-world build`; the Rust side requires the Tauri
toolchain (`pnpm tauri dev` from this directory). Linux / macOS /
Windows builds run on every PR via the `examples-build` CI matrix.

## Run locally

```bash
cd examples/hello-world
pnpm install
pnpm tauri dev
```

## What it does

1. Frontend (`src/App.res`) calls
   `RescriptTauriCore.Core.Raw.invoke("greet", ~args={"name": "ReScript"})`.
2. Rust (`src-tauri/src/main.rs`) defines
   `#[tauri::command] fn greet(name: &str) -> String`.
3. The greeting is rendered into the `#greeting` DOM element.

## Files of interest

| File | Role |
|---|---|
| `src/App.res` | ReScript entry calling Tauri |
| `src/main.mjs` | Plain JS entry that imports the compiled ReScript |
| `index.html` | HTML host page |
| `src-tauri/src/main.rs` | Rust command handler |
| `src-tauri/Cargo.toml` | Rust dependencies |
| `src-tauri/tauri.conf.json` | Tauri app config |

## Notes

- `App.res` reaches into Tauri via `RescriptTauriCore.Core.Raw.invoke`
  (full namespace path). Apps that prefer shorter access can
  `open Tauri` to reach `Core.Raw.invoke` once the `Tauri` re-export
  is imported (see [`packages/core/src/Tauri.resi`](../../packages/core/src/Tauri.resi)).

## Content-Security-Policy (CSP)

`src-tauri/tauri.conf.json` ships with an explicit CSP:

```json
"csp": "default-src 'self'; img-src 'self' asset: https://asset.localhost; style-src 'self' 'unsafe-inline'; connect-src ipc: http://ipc.localhost"
```

The other examples in this repository leave `"csp": null` to keep
their setup minimal, but **production apps must define an explicit
CSP**. `default-src 'self'` blocks remote script / object loads;
`asset:` and `https://asset.localhost` are required for
`Core.Raw.convertFileSrc`; `ipc:` and `http://ipc.localhost` are
required for Tauri 2.x's `invoke` transport on Windows / macOS.
Tighten the policy (e.g., remove `'unsafe-inline'` and inline only
hashed styles) when your app's bundling pipeline allows it. See
[Tauri's CSP guidance](https://v2.tauri.app/security/csp/) for
details.
- `tauri.conf.json` keeps `frontendDist` pointing to `../` (this
  directory) so Tauri loads `index.html` directly. A real production
  setup would route through Vite or another bundler.
