# Installation

```{note}
The Phase 1 module set is feature-complete in `main`. The first npm
publish (`v0.1.0`) is scheduled at the Phase 1 release. Until then,
consume `@rescript-tauri/core` via the source repository or a
workspace link — the commands below show the future
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

## Install (planned, post Phase 1 release)

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

### Phase 2 add-on packages

Each Phase 2 package is published independently. Install them as
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

# Layer 3 typed IPC (rescript-schema)
pnpm add @rescript-tauri/schema rescript-schema
```

See the [plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
and [schema](schema.md) guides for the matching ReScript / Rust /
capability setup.

```{note}
Dedicated user guides for `@rescript-tauri/plugin-shell`,
`@rescript-tauri/plugin-notification`, `@rescript-tauri/plugin-log`,
and `@rescript-tauri/plugin-os` are scheduled for follow-up
sub-steerings. Until then, refer to each package's own README
(`packages/plugin-{shell,notification,log,os}/README.md`) for full
API coverage and copy-pasteable examples.
```

## Verify

After Phase 1 ships, a minimal verification looks like:

```rescript
let _ = await Tauri.Core.Raw.invoke("ping", ~args=())
```

Combined with a Rust-side `#[tauri::command] fn ping() {}`, this round-trip confirms the bridge works.

## Troubleshooting

Detailed troubleshooting will be added as Phase 1 implementation reveals common pitfalls. For early feedback, please open an issue at [github.com/Nagatatz/rescript-tauri/issues](https://github.com/Nagatatz/rescript-tauri/issues).
