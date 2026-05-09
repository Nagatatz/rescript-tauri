# @rescript-tauri/plugin-shell

ReScript bindings for [`@tauri-apps/plugin-shell`](https://www.npmjs.com/package/@tauri-apps/plugin-shell)
— Tauri 2.x's shell plugin (spawn external processes, open files / URLs
with the OS-default app).

## Status

Phase 2+, first iteration. Awaiting first npm publish (`plugin-shell-v0.1.0`).

**Bundled in this iteration:** the `Command` class (string- and
raw-encoded variants, sidecar variants), `Child` process handle, and the
top-level `openPath` function — covering 100% of the stable public
surface of `@tauri-apps/plugin-shell` v2.3.5.

The TypeScript-level conditional return type of upstream's
`Command.create({encoding: 'raw'})` is unrolled into separate ReScript
functions (`Command.create` / `Command.createRaw` /
`Command.sidecar` / `Command.sidecarRaw`) so the result type stays static.

The upstream top-level `open` is exposed as `openPath` to avoid clashing
with ReScript's `open` keyword.

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-shell @rescript-tauri/core @tauri-apps/plugin-shell @tauri-apps/api
```

Add to `rescript.json`:

```json
{
  "dependencies": ["@rescript/core", "@rescript-tauri/core", "@rescript-tauri/plugin-shell"]
}
```

## Quick example

```rescript
module Shell = RescriptTauriPluginShell.PluginShell

// Open a URL in the system default browser.
let openHomepage = async () => {
  await Shell.openPath("https://github.com/tauri-apps/tauri")
}

// Run a command, collect its output.
let listFiles = async () => {
  let cmd = Shell.Command.create("ls", ~args=["-la"])
  let output = await cmd->Shell.Command.execute
  Console.log(output.stdout)
}

// Spawn a long-running command and stream its output.
let tail = async () => {
  let cmd =
    Shell.Command.create("tail", ~args=["-f", "/var/log/system.log"])
    ->Shell.Command.onStdoutData(line => Console.log2("stdout:", line))
    ->Shell.Command.onStderrData(line => Console.log2("stderr:", line))
    ->Shell.Command.onClose(payload =>
      Console.log4("closed code=", payload.code, " signal=", payload.signal)
    )

  let _child = await cmd->Shell.Command.spawn
}
```

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-shell` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-shell` | `^2.3.0` (peer) |
| `@tauri-apps/api` | `^2.0.0` (transitive via core) |
| Rust `tauri-plugin-shell` | `2.x` |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## Public API

| Symbol | Purpose |
|---|---|
| `openPath(path, ~openWith=?)` | Open a URL or file with the OS default (or specified) app |
| `Command.create` / `Command.createRaw` | Build a string- or bytes-encoded command |
| `Command.sidecar` / `Command.sidecarRaw` | Build a sidecar command (program declared in `tauri.conf.json > bundle > externalBin`) |
| `Command.spawn` | Start the command, return a `Child.t` handle |
| `Command.execute` | Run the command to completion, return its `childProcess<'o>` output |
| `Command.onClose` / `Command.onError` | Subscribe to lifecycle events |
| `Command.onStdoutData` / `Command.onStderrData` | Subscribe to streamed output |
| `Command.removeAllListeners` | Detach all listeners on the command |
| `Command.stdout` / `Command.stderr` | Low-level access to the underlying `EventEmitter` |
| `Child.pid` / `Child.write` / `Child.kill` | Child process accessors and operations |
| `EventEmitter` module | 9 generic methods (`on` / `once` / `off` / `addListener` / `removeListener` / `removeAllListeners` / `listenerCount` / `prependListener` / `prependOnceListener`) |
| `spawnOptions` | `{cwd?: string, env?: Dict.t<string>, encoding?: string}` |
| `childProcess<'o>` | `{code, signal, stdout, stderr}` returned by `execute` |
| `terminatedPayload` | Payload of the `close` event |

See `src/PluginShell.resi` for full doc comments and matching upstream
URLs.

## See also

- [Changelog](./CHANGELOG.md)
- Upstream docs:
  [Tauri 2.x shell plugin](https://v2.tauri.app/plugin/shell/)
- [`@rescript-tauri/core` README](../core/README.md)
