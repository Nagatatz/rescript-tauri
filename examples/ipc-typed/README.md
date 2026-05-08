# ipc-typed

Demonstrates `Core.Command.make` — the typed IPC layer of
`@rescript-tauri/core`.

## What it shows

| Command | Rust signature | ReScript ergonomics |
|---|---|---|
| `greet` | `fn(name: &str) -> String` | `greet->Core.Command.invoke("name")` |
| `add` | `fn(a: i32, b: i32) -> i32` | `add->Core.Command.invoke({a, b})` |

Each frontend declaration provides:
- `~encodeArgs`: ReScript value &rarr; `JSON.t`
- `~decodeResult`: `JSON.t` &rarr; `result<value, string>`

The handler unifies success / decoder failure / Rust failure into a
single `result<_, Core.invokeError>` (`DecodeError` / `RustError`).

## Run locally

Requires the [Tauri 2.x prerequisites](https://v2.tauri.app/start/prerequisites/).

```bash
cd examples/ipc-typed
pnpm install
pnpm tauri dev
```

CI builds the frontend and runs `cargo check --release`.

## Files of interest

| File | Role |
|---|---|
| `src/App.res` | ReScript entry — typed `Command` declarations + UI wiring |
| `src-tauri/src/main.rs` | `#[tauri::command] greet`, `#[tauri::command] add` |
