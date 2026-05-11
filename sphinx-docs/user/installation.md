# Installation

```{note}
All packages are feature-complete in `main`. The first npm publish
(`v0.1.0`) is scheduled for the initial release. Until then, consume
`@rescript-tauri/core` via the source repository or a workspace
link — the commands below show the future
`pnpm add @rescript-tauri/core` workflow that will work
post-publish.
```

## Requirements

| Component | Supported range |
|---|---|
| Tauri | 2.x (matches the `@tauri-apps/api` peerDep range) |
| ReScript | >= 12.0.0 (uncurried-by-default) |
| `@rescript/core` | >= 1.6.0 |
| Node.js | Active LTS |
| pnpm | >= 9 |
| OS | Linux / macOS / Windows (Tauri 2.x desktop targets) |

## Install (planned, post initial release)

```bash
pnpm add @rescript-tauri/core @tauri-apps/api
```

`@rescript-tauri/core` declares `@tauri-apps/api` as a `peerDependency`, so the two are versioned independently and you control the upstream Tauri version.

Then add `@rescript-tauri/core` to `dependencies` in your `rescript.json`:

```json
{
  "name": "my-app",
  "dependencies": ["@rescript-tauri/core"],
  "package-specs": [{ "module": "esmodule", "in-source": true }]
}
```

### Add-on packages

Each add-on package is published independently. Install them as
needed alongside the matching upstream plugin / schema library:

```bash
# Filesystem
pnpm add @rescript-tauri/plugin-fs @tauri-apps/plugin-fs

# Native dialogs
pnpm add @rescript-tauri/plugin-dialog @tauri-apps/plugin-dialog

# Process spawning + open URLs/files
pnpm add @rescript-tauri/plugin-shell @tauri-apps/plugin-shell

# Toast notifications + scheduling (desktop) / Android channels
pnpm add @rescript-tauri/plugin-notification @tauri-apps/plugin-notification

# Structured logging (5 levels + log targets)
pnpm add @rescript-tauri/plugin-log @tauri-apps/plugin-log

# OS info (platform / version / arch / family / hostname / locale)
pnpm add @rescript-tauri/plugin-os @tauri-apps/plugin-os

# Clipboard read/write (text / image / HTML)
pnpm add @rescript-tauri/plugin-clipboard-manager @tauri-apps/plugin-clipboard-manager

# HTTP fetch with CORS bypass + proxy / TLS config
pnpm add @rescript-tauri/plugin-http @tauri-apps/plugin-http

# Layer 3 typed IPC (rescript-schema)
pnpm add @rescript-tauri/schema rescript-schema
```

See the [plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
[plugin-notification](plugin-notification.md),
[plugin-shell](plugin-shell.md),
[plugin-log](plugin-log.md),
[plugin-os](plugin-os.md),
[plugin-clipboard-manager](plugin-clipboard-manager.md),
[plugin-http](plugin-http.md), and
[schema](schema.md) guides for the matching ReScript / Rust /
capability setup.

## Verify

After the initial release ships, a minimal verification looks like:

```rescript
let _ = await Tauri.Core.Raw.invoke("ping", ~args=())
```

Combined with a Rust-side `#[tauri::command] fn ping() {}`, this round-trip confirms the bridge works.

## Troubleshooting

Detailed troubleshooting will be added as adoption surfaces common pitfalls. For early feedback, please open an issue at [github.com/Nagatatz/rescript-tauri/issues](https://github.com/Nagatatz/rescript-tauri/issues).
