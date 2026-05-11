# Contributing Guide

This page is a docs-site-specific extension of the canonical [`CONTRIBUTING.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/CONTRIBUTING.md) at the repository root. **Read the root `CONTRIBUTING.md` first** for project-wide context (status, branch naming, commit style, PR process, Definition of Done).

```{important}
All packages are merged on `main` and external pull requests are accepted. Issues remain welcome for design feedback and RFC discussion. The workflow described below is the live contributor workflow.
```

## Where to start

1. Read the project [README](https://github.com/Nagatatz/rescript-tauri/blob/main/README.md) for the high-level pitch.
2. Read the root [`CONTRIBUTING.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/CONTRIBUTING.md) for the project-wide workflow.
3. For docs-site work specifically, follow [Development Setup](setup.md) and [Building](building.md) on this site.

## Docs-site-specific contributions

The most common contributions to `sphinx-docs/` are:

| Type | What to change | Verification |
|---|---|---|
| Translation update | `sphinx-docs/locale/ja/LC_MESSAGES/<file>.po` | `make build-ja` |
| Fix a typo or broken link in English | `sphinx-docs/**/*.md` | `make html`, `make linkcheck` |
| Add a new English page | New `.md` + entry in the parent `index.md` `toctree` | `make update-po` to regenerate `.po`, then translate |
| Improve a code sample | The relevant `.md` | `make html` to verify rendering |

After any source `.md` change, run `make update-po` so the Japanese `.po` files reflect the new strings, then update the corresponding `msgstr` entries.

## Branch naming and commit style

Same as the project root. See [`CONTRIBUTING.md` §3.1 / §3.2](https://github.com/Nagatatz/rescript-tauri/blob/main/CONTRIBUTING.md). Docs changes typically use the `docs/` branch prefix and the 📝 commit emoji.

## Before opening a PR

```bash
cd sphinx-docs
make lint          # ruff check + format
make build-all     # EN + JA + Pagefind assembly
make linkcheck     # broken-link detection (external 404s acceptable)
```

Attach screenshots in the PR if visual layout changes.

## Translation guidelines

The project's translation tone is:

- **です・ます調** (polite informal Japanese).
- Technical terms stay in **English** (Layer 1 (Raw), polymorphic variant, peerDependencies, IPC, Channel, Event, Window, etc.).
- **Code blocks are not translated.** If a `msgid` contains code, copy it verbatim into the `msgstr`.
- **URLs and link targets are not translated.** Translate the link text only.
- Existing translation choices for shared terms should match the rescript-tauri internal [`docs/glossary.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/docs/glossary.md).
