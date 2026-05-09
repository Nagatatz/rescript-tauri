# Project Structure

A quick orientation. The canonical, kept-up-to-date layout reference is [`docs/repository-structure.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/repository-structure.md) (Japanese).

## Top-level layout

```
rescript-tauri/
├── packages/         # @rescript-tauri/core, plugin-*, schema
├── examples/         # hello-world / window-management / ipc-typed / streaming-ipc / plugin-fs-demo / plugin-dialog-demo / ipc-typed-with-schema
├── docs/             # Internal design docs (PRD, functional design, architecture, ...)
│   └── ideas/        # Drafts / RFCs (input only; not edited after acceptance)
├── sphinx-docs/      # External-facing docs (this site; English base + Japanese via Sphinx i18n)
├── .steering/        # Per-task steering documents (requirements / design / tasklist)
├── .claude/          # Claude Code configuration (rules / skills / agents / commands)
├── .github/          # GitHub Actions / templates
├── CLAUDE.md         # Mandatory project instructions for Claude Code (Japanese)
├── CONTRIBUTING.md   # External contributor guide (English)
├── README.md         # Project README (English)
└── LICENSE           # MIT
```

## Where each thing lives

| If you want to ... | Look in ... |
|---|---|
| Read what the project promises to do | `README.md`, `docs/product-requirements.md` |
| Read per-module API specs | `docs/functional-design.md` |
| Read cross-cutting design (error / lifetime / JSON / variants) | `docs/architecture.md` |
| Read what conventions Claude Code enforces | `CLAUDE.md`, `.claude/rules/` |
| Read how to contribute (external) | `CONTRIBUTING.md` |
| Read how to develop locally (internal) | `docs/development-guidelines.md` |
| Read how a steering document is shaped | `.steering/<existing>/{requirements,design,tasklist}.md` |
| Modify the docs you are reading right now | `sphinx-docs/` |

## Subsystem map

`packages/core/` is the Phase 1 hub; Phase 2 adds `packages/schema/`, `packages/plugin-fs/`, `packages/plugin-dialog/`, `packages/plugin-shell/`, `packages/plugin-notification/`, `packages/plugin-log/`, `packages/plugin-os/`, and `packages/plugin-clipboard-manager/`. The core layout is:

```
packages/core/
├── src/
│   ├── Core.res / .resi              # invoke / convertFileSrc / Channel / Command / Resource / PluginListener / permissions / isTauri / LowLevel
│   ├── Event.res / .resi             # listen / once / emit / TauriEvent enum
│   ├── Window.res / .resi
│   ├── Webview.res / .resi
│   ├── WebviewWindow.res / .resi
│   ├── Path.res / .resi
│   ├── App.res / .resi
│   ├── Dpi.res / .resi
│   ├── Menu.res / .resi
│   ├── Tray.res / .resi
│   ├── Image.res / .resi
│   ├── Mocks.res / .resi
│   └── Tauri.res / .resi             # top-level re-export
├── tests/
│   ├── (型レベルテスト, *.res)        # compile success = pass
│   └── runtime/                      # vitest tests
├── rescript.json
├── package.json
└── README.md
```

Every `.res` is shadowed by a `.resi` interface file, which is the canonical surface (one of the project's hard rules; see [`docs/repository-structure.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/repository-structure.md) §2.1).
