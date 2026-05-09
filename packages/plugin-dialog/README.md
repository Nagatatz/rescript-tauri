# @rescript-tauri/plugin-dialog

ReScript bindings for [`@tauri-apps/plugin-dialog`](https://www.npmjs.com/package/@tauri-apps/plugin-dialog)
— Tauri 2.x's native dialog plugin (open / save / message / ask / confirm).

## Status

Phase 2, first iteration. Awaiting first npm publish (`plugin-dialog-v0.1.0`).

**Bundled in this iteration:** 8 functions covering file pickers, save
dialog, and message/ask/confirm prompts, plus their record-style options.

The TypeScript-level conditional return type of upstream's `open` is
unrolled into four ReScript functions (`openFile` / `openFiles` /
`openDirectory` / `openDirectories`) so result types stay static.

**Already shipped alongside this binding:**
- Runnable example app:
  [`examples/plugin-dialog-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-dialog-demo)
  (steering 036)
- Dedicated CI workflows:
  `tests-plugin-dialog-types.yml` / `tests-plugin-dialog-runtime.yml`
  + a `plugin-dialog-demo` cell in the `examples-build` matrix
  (steering 041)
- `release.yml` recognizes the `plugin-dialog-v*` tag prefix so a
  tag push routes to this package's `npm publish` (steering 041)

**Deferred to follow-up sub-steerings:**
- `MessageDialogButtonsYesNoCustom` / custom-button label variants
  for `message`

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-dialog @rescript-tauri/core @tauri-apps/plugin-dialog @tauri-apps/api
```

Add to `rescript.json`:

```json
{
  "dependencies": ["@rescript/core", "@rescript-tauri/core", "@rescript-tauri/plugin-dialog"]
}
```

## Quick example

```rescript
module Dialog = RescriptTauriPluginDialog.PluginDialog

let pickReport = async () => {
  let pick = await Dialog.openFile(
    ~options={
      title: "Pick a report",
      filters: [{name: "CSV", extensions: ["csv"]}],
    },
  )

  switch pick->Nullable.toOption {
  | Some(path) => Console.log2("picked", path)
  | None => Console.log("user cancelled")
  }
}

let confirmDelete = async () => {
  let yes = await Dialog.confirm(
    "Delete this file? This cannot be undone.",
    ~options={kind: #warning, title: "Delete"},
  )
  if yes {
    Console.log("deleting...")
  }
}
```

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-dialog` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-dialog` | `^2.7.0` (peer) |
| `@tauri-apps/api` | `^2.0.0` (transitive via core) |
| Rust `tauri-plugin-dialog` | `2.x` |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## Public API (this iteration)

| Symbol | Purpose |
|---|---|
| `openFile` / `openFiles` | Single / multi file selection |
| `openDirectory` / `openDirectories` | Single / multi directory selection |
| `save` | Save-as dialog |
| `message` | Show a message dialog (returns the clicked button label) |
| `ask` | Yes/No question (returns `bool`) |
| `confirm` | OK/Cancel confirmation (returns `bool`) |
| `dialogFilter` / `openOptions` / `saveOptions` / `messageOptions` / `confirmOptions` | Option records |
| `pickerMode` / `fileAccessMode` / `dialogKind` / `messageButtons` | Polymorphic variants |
| `messageResult` | `string` alias for the `message` return value |

See `src/PluginDialog.resi` for full documentation comments and matching
upstream URLs.

## See also

- [Changelog](./CHANGELOG.md)
- [User guide page](https://github.com/Nagatatz/rescript-tauri/blob/main/sphinx-docs/user/plugin-dialog.md)
- Runnable demo:
  [`examples/plugin-dialog-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-dialog-demo)
- Upstream docs:
  [Tauri 2.x dialog plugin](https://v2.tauri.app/plugin/dialog/)
- [`@rescript-tauri/core` README](../core/README.md)
