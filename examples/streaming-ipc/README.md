# streaming-ipc

Demonstrates `Core.Channel` — Tauri's one-way streaming bridge from
Rust to the frontend, no polling required.

## What it shows

- `Core.Channel.make` constructs a typed channel handle with its own
  decoder.
- The channel is passed as an argument to a `Core.Command.invoke`
  call. Rust pulls the channel out and calls `channel.send(...)`
  repeatedly.
- Each emission lands in `Core.Channel.onMessage`'s callback after
  the decoder runs.

## Run locally

Requires the [Tauri 2.x prerequisites](https://v2.tauri.app/start/prerequisites/).

```bash
cd examples/streaming-ipc
pnpm install
pnpm tauri dev
```

CI builds the frontend and runs `cargo check --release`.

## Files of interest

| File | Role |
|---|---|
| `src/App.res` | ReScript entry — Channel.make + onMessage + Command.invoke |
| `src-tauri/src/main.rs` | `#[tauri::command] count_to(channel, target)` |
