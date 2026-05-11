# plugin-shell demo

Minimal Tauri 2.x desktop app that exercises every public function
of [`@rescript-tauri/plugin-shell`](../../packages/plugin-shell).

## Run

```bash
pnpm install
pnpm --filter plugin-shell-demo tauri dev
```

## Buttons

| Button | Calls |
|---|---|
| **Open https://tauri.app/** | `PluginShell.openPath` |
| **Open with firefox** | `PluginShell.openPath(~openWith="firefox")` |
| **Run `echo` (utf8)** | `Command.create` + `Command.execute` |
| **Run `echo` (raw bytes)** | `Command.createRaw` + `Command.execute` |
| **Spawn `cat`, write, kill** | `Command.spawn` + `Child.pid` / `Child.write` / `Child.kill` |
| **Echo via onStdoutData chain** | chained `onStdoutData` / `onStderrData` / `onClose` / `onError` |
| **removeAllListeners** | `Command.removeAllListeners` |

`Command.sidecar` / `Command.sidecarRaw` are type-level-referenced
from `src/App.res` only; bundling an actual sidecar binary is out
of scope for this demo (see
[`.steering/20260511-008-example-plugin-shell-demo`](../../.steering/20260511-008-example-plugin-shell-demo)).

## Capabilities

The demo allowlists `echo` and `cat` under `shell:allow-execute`
and `^https?://` under `shell:allow-open`. See
[`src-tauri/capabilities/default.json`](./src-tauri/capabilities/default.json).

## See also

- [plugin-shell user guide](../../sphinx-docs/user/plugin-shell.md)
- [`@rescript-tauri/plugin-shell` README](../../packages/plugin-shell/README.md)
- Upstream: [Tauri 2.x shell plugin](https://v2.tauri.app/plugin/shell/)
