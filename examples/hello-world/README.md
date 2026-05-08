# hello-world

Minimal Tauri 2.x desktop app demonstrating `@rescript-tauri/core`'s
Layer 1 (`Core.Raw.invoke`).

## Status

Phase 1 — implementation in progress. The frontend ReScript piece
builds today (`pnpm --filter hello-world build`); the Rust side
requires the Tauri toolchain (`pnpm tauri dev` from this directory)
and is fully exercised once the CI matrix is wired up
(.steering/20260508-017-ci-workflows; in flight).

## Run locally (after Phase 1 release)

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
  (full namespace path) because the top-level `Tauri.res` re-export
  module hasn't been added yet (PRD §10 row 1 — finalized at Phase 1
  release).
- `tauri.conf.json` keeps `frontendDist` pointing to `../` (this
  directory) so Tauri loads `index.html` directly. A real production
  setup would route through Vite or another bundler.
