# `@rescript-tauri/plugin-shell`

ReScript bindings for the [Tauri 2.x shell
plugin](https://v2.tauri.app/plugin/shell/) — spawn child
processes, stream stdout / stderr, and open files / URLs with the
OS-default app.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-shell-v0.1.0`) is scheduled alongside
the other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-shell` via the source repository or a
workspace link.
```

## Install

```bash
pnpm add @rescript-tauri/plugin-shell @tauri-apps/plugin-shell
```

`@rescript-tauri/plugin-shell` declares both
`@rescript-tauri/core` and `@tauri-apps/plugin-shell` as
`peerDependencies`, so you control each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-shell"
  ]
}
```

On the Rust side, add the plugin crate and register it on the
builder:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-shell = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

## Capabilities

Tauri 2.x requires every shell operation to be granted a
capability. The minimum set for spawning `ls` and opening `http(s)`
URLs is:

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:default",
    {
      "identifier": "shell:allow-execute",
      "allow": [{ "name": "ls", "cmd": "ls", "args": true }]
    },
    {
      "identifier": "shell:allow-open",
      "allow": [{ "url": "^https?://" }]
    }
  ]
}
```

Each program you intend to spawn must be listed under
`shell:allow-execute` with a matching `name`. URLs passed to
`openPath` must match one of the `shell:allow-open` regex
patterns. See the upstream [scope and permissions
reference](https://v2.tauri.app/plugin/shell/#scope-and-permissions)
for the full grammar.

## Minimal example

```rescript
open RescriptTauriPluginShell

await PluginShell.openPath("https://tauri.app/")
```

`openPath` returns `promise<unit>`; the underlying call rejects
when the URL fails the configured `shell:allow-open` regex.

## Public API

| Symbol | Returns | Purpose |
|---|---|---|
| `openPath` | `promise<unit>` | Open a URL / path with the OS-default app (or `~openWith`) |
| `Command.create` / `Command.sidecar` | `Command.t<string>` | Build a UTF-8 command |
| `Command.createRaw` / `Command.sidecarRaw` | `Command.t<Uint8Array.t>` | Build a bytes command (`encoding: "raw"`) |
| `Command.execute` | `promise<childProcess<'o>>` | Run to completion, collect output |
| `Command.spawn` | `promise<Child.t>` | Start the command, return a handle |
| `Command.onClose` / `Command.onError` | `Command.t<'o>` | Subscribe to lifecycle events |
| `Command.onStdoutData` / `Command.onStderrData` | `Command.t<'o>` | Subscribe to streamed output |
| `Command.removeAllListeners` | `Command.t<'o>` | Detach all command-level listeners |
| `Command.stdout` / `Command.stderr` | `EventEmitter.t<{"data": 'o}>` | Low-level access to the underlying event emitter |
| `Child.pid` / `Child.kill` / `Child.write` | `int` / `promise<unit>` / `promise<unit>` | Child accessors and operations |
| `EventEmitter.*` | `t<'events>` | 9 generic methods (`on` / `once` / `off` / `addListener` / `removeListener` / `removeAllListeners` / `listenerCount` / `prependListener` / `prependOnceListener`) |

The associated records (`spawnOptions`, `childProcess<'o>`,
`terminatedPayload`) are re-exported from `PluginShell`. See
[`packages/plugin-shell/src/PluginShell.resi`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-shell/src/PluginShell.resi)
for the full doc comments and matching upstream URLs.

## Running commands

### One-shot execution

`Command.execute` resolves once the child has exited and gives
you the collected output. Best for short-lived commands:

```rescript
module Shell = RescriptTauriPluginShell.PluginShell

let listFiles = async () => {
  let cmd = Shell.Command.create("ls", ~args=["-la"])
  let output = await cmd->Shell.Command.execute
  Console.log(output.stdout)
}
```

`childProcess<'o>` carries `{code, signal, stdout, stderr}`. Both
`code` and `signal` are `Nullable.t<int>` — they're mutually
exclusive on Unix (signal-terminated processes report `code = null`).

### Background processes

`Command.spawn` starts the child and returns a `Child.t` handle
without waiting. Combine it with `Child.write` and `Child.kill`
for interactive use:

```rescript
let runRepl = async () => {
  let cmd = Shell.Command.create("python3", ~args=["-i"])
  let child = await cmd->Shell.Command.spawn
  await child->Shell.Child.write("print('hello')\n")
  // ... later
  await child->Shell.Child.kill
}
```

`Child.pid` returns the OS-level process id.

### Raw byte output

Pass `encoding: "raw"` via the dedicated factory functions to
receive `Uint8Array.t` instead of `string`:

```rescript
let readImage = async () => {
  let cmd = Shell.Command.createRaw("cat", ~args=["icon.png"])
  let output = await cmd->Shell.Command.execute
  Console.log("byte count: " ++ Int.toString(TypedArray.length(output.stdout)))
}
```

The TypeScript-level conditional return type of upstream's
`Command.create({encoding: 'raw'})` is split into four ReScript
functions — `Command.create` / `Command.createRaw` /
`Command.sidecar` / `Command.sidecarRaw` — so the result type is
always statically known.

## Streaming output

Use chained `onStdoutData` / `onStderrData` / `onClose` /
`onError` to stream events from a long-running command. Each
method returns the command, mirroring the upstream
`Promise<this>` pattern:

```rescript
let tail = async () => {
  let cmd =
    Shell.Command.create("tail", ~args=["-f", "/var/log/system.log"])
    ->Shell.Command.onStdoutData(line => Console.log2("stdout:", line))
    ->Shell.Command.onStderrData(line => Console.log2("stderr:", line))
    ->Shell.Command.onClose(payload =>
      switch (payload.code->Nullable.toOption, payload.signal->Nullable.toOption) {
      | (Some(code), _) => Console.log("exited with code " ++ Int.toString(code))
      | (_, Some(sig)) => Console.log("killed by signal " ++ Int.toString(sig))
      | _ => Console.log("closed")
      }
    )
    ->Shell.Command.onError(err => Console.error2("error:", err))

  let _child = await cmd->Shell.Command.spawn
}
```

For advanced subscription patterns (`once`, `prependListener`,
manual `listenerCount`, ...) reach for `Command.stdout` /
`Command.stderr` directly — both return an
`EventEmitter.t<{"data": 'o}>` you can drive with the
`EventEmitter` module's 9 generic methods.

`Command.removeAllListeners` detaches every command-level
listener (`close` / `error`). To clear stdout / stderr listeners,
use `EventEmitter.removeAllListeners` on the corresponding
accessor.

## Sidecar binaries

Sidecars are binaries bundled alongside your app and looked up
through `tauri.conf.json > bundle > externalBin` instead of
`PATH`. Use `Command.sidecar` (or `sidecarRaw` for bytes):

```rescript
let runHelper = async () => {
  let cmd = Shell.Command.sidecar("my-sidecar", ~args=["--check"])
  let output = await cmd->Shell.Command.execute
  Console.log(output.stdout)
}
```

The string passed to `sidecar` matches the `externalBin` entry
without the target triple suffix.

## Opening paths and URLs

`openPath` opens its argument with the system's default
application:

```rescript
await Shell.openPath("https://github.com/tauri-apps/tauri")
await Shell.openPath("/tmp/notes.md")
```

Pass `~openWith` to force a specific opener (`firefox`,
`chromium`, `safari`, `xdg-open`, ...). The path or URL must
match a `shell:allow-open` regex — otherwise the underlying call
rejects:

```rescript
await Shell.openPath("/tmp/notes.md", ~openWith="firefox")
```

## Pitfalls

### `openPath` rename

Upstream exposes this function as `open`, but ReScript reserves
that identifier for module access (`open MyModule`). We re-export
it as `openPath`:

```rescript
// ❌ syntax error: ReScript treats `open` as a keyword
await Shell.open("https://tauri.app/")

// ✅
await Shell.openPath("https://tauri.app/")
```

### `Uint8Array` length

`Uint8Array.t` in `@rescript/core` is an alias for
`TypedArray.t<int>`. The length getter lives on the parent
module:

```rescript
let output = await cmd->Shell.Command.execute
Console.log("byte count: " ++ Int.toString(TypedArray.length(output.stdout)))
```

### Scope misconfiguration

Commands fail to spawn — and `openPath` fails to launch — when
the target is not allowlisted in `src-tauri/capabilities/`. The
`name` field on `shell:allow-execute` must match the first
argument to `Command.create` / `Command.sidecar` exactly:

```json
{
  "identifier": "shell:allow-execute",
  "allow": [{ "name": "git", "cmd": "git", "args": true }]
}
```

`Command.create("git", ...)` then succeeds; `Command.create("Git", ...)`
or `Command.create("/usr/bin/git", ...)` rejects.

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-shell` | `^2.3.0` (peer) |
| Rust `tauri-plugin-shell` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## See also

- Live demo:
  [`examples/plugin-shell-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-shell-demo)
- Source:
  [`packages/plugin-shell`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-shell)
- Upstream docs:
  [Tauri 2.x shell plugin](https://v2.tauri.app/plugin/shell/)
- [Installation guide](installation.md) — set up
  `@rescript-tauri/core` first
