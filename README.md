# rescript-tauri

Production-ready ReScript bindings for Tauri 2.x's official JS SDK (`@tauri-apps/api`). A monorepo centered on `@rescript-tauri/core`, exposing the entire Tauri public API surface—IPC, Event, Window, Webview, Menu, Tray—from ReScript.

> **Status:** Phase 1 — design complete, implementation not yet started. This repository currently contains the PRD, functional design, architecture, repository structure, and glossary; no source code is published yet. See [`docs/product-requirements.md`](./docs/product-requirements.md) and [`docs/functional-design.md`](./docs/functional-design.md) for details.
>
> **Visibility:** the repository is **private** while the design is being finalized. It will be switched to **public** at the Phase 1 release, once all of the following are in place: the first `@rescript-tauri/core` version is published to npm; every example workspace under `examples/` builds on the 3 OS matrix; and the CI workflows specified in [`docs/functional-design.md`](./docs/functional-design.md) §6 are wired up (see [`.github/workflows/README.md`](./.github/workflows/README.md) for current status). [`LICENSE`](./LICENSE) (MIT) and [`CONTRIBUTING.md`](./CONTRIBUTING.md) are already in place.

---

## ✨ Highlights

- **Idiomatic ReScript** — leverages `variant` / `option` / `result` / polymorphic variants to translate constructs that TypeScript expresses with `unknown` or string-literal unions into type-safe ReScript.
- **Faithful to Tauri** — preserves a near-1:1 mapping with the JS API surface so the official Tauri docs remain directly applicable. Each `.resi` doc comment links to the corresponding Tauri page.
- **Three-layer IPC** — Layer 1 (Raw `invoke`) / Layer 2 (typed `Command`) / Layer 3 (Schema integration) lets users choose their own point on the safety/ergonomics curve.
- **Maintainable monorepo** — mirrors the structure of `@tauri-apps/plugin-*`, evolving core, plugins, and examples on independent semver. Designed to remain sustainable for a 1–3 person maintainer team.

For the full rationale and scope, see [`docs/product-requirements.md`](./docs/product-requirements.md).

---

## 📦 Packages

| Package | Role | Phase |
|---|---|---|
| `@rescript-tauri/core` | Core bindings covering the entire `@tauri-apps/api` public surface | Phase 1 |
| `@rescript-tauri/plugin-fs` | Bindings for `@tauri-apps/plugin-fs` | Phase 2+ |
| `@rescript-tauri/plugin-dialog` | Bindings for `@tauri-apps/plugin-dialog` | Phase 2+ |
| `@rescript-tauri/schema` | `Command.fromSchemas` helper integrating `rescript-schema` / `rescript-struct` | Phase 2 |

Each package is published with independent semver and declares the corresponding upstream `@tauri-apps/*` package as a `peerDependency`.

---

## 🧩 Compatibility

| Component | Supported range |
|---|---|
| Tauri | 2.x (matches the `@tauri-apps/api` peerDep range) |
| ReScript | >= 12.0.0 (uncurried-by-default) |
| `@rescript/core` | >= 1.6.0 |
| Node.js | Active LTS |
| OS | Linux / macOS / Windows (Tauri 2.x desktop targets) |

Nightly CI against the latest Tauri release and the next ReScript 12.x minor / next-major prerelease line is planned to detect API drift early. The job definitions are tracked in [`docs/functional-design.md`](./docs/functional-design.md) §6 and will be implemented during Phase 1. The current status of every workflow file (active / opt-in template / planned) is documented in [`.github/workflows/README.md`](./.github/workflows/README.md).

---

## 🚀 Installation (planned; post Phase 1 release)

Not yet published. Once Phase 1 ships, installation will look like:

```bash
pnpm add @rescript-tauri/core @tauri-apps/api
```

Then add `@rescript-tauri/core` to `dependencies` in your `rescript.json`.

---

## ⚡ Quick start (target API; see RFC-0001 and functional-design §2)

```rescript
// Layer 1 — Raw invoke (1:1 with @tauri-apps/api)
let greeting: string =
  await Tauri.Core.Raw.invoke("greet", ~args={"name": "ReScript"})

// Layer 2 — typed Command with explicit encoder/decoder
module Commands = {
  let greet = Core.Command.make(
    ~name="greet",
    ~encodeArgs=({name}) =>
      JSON.Encode.object([("name", JSON.Encode.string(name))]),
    ~decodeResult=json =>
      switch json->JSON.Decode.string {
      | Some(s) => Ok(s)
      | None => Error("expected string")
      },
  )
}

switch await Commands.greet->Core.Command.invoke({name: "ReScript"}) {
| Ok(message) => Console.log(message)
| Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
| Error(RustError(json)) => Console.error2("rust error:", json)
}

// Event subscription — Event.make first, then Event.listen
let fileChanged = Event.make(
  ~name="file-changed",
  ~decode=json =>
    switch json->JSON.Decode.string {
    | Some(s) => Ok(s)
    | None => Error("expected string")
    },
)
let unlisten = await fileChanged->Event.listen(evt => Console.log(evt.payload))
```

Runnable examples will live under `examples/` starting in Phase 1 (`hello-world`, `window-management`, `ipc-typed`, `streaming-ipc`).

---

## 🛠️ Development setup

```bash
# Install dependencies (pnpm required)
pnpm install

# Build all workspaces
pnpm --recursive build

# Clean rebuild
pnpm --recursive run clean && pnpm --recursive build

# Tests (type-level + vitest)
pnpm --recursive test

# Incremental build of the core package only
pnpm --filter @rescript-tauri/core build
```

For contributor-facing details (development flow, local setup, the new-module recipe, coding patterns, PR review angles), see [`docs/development-guidelines.md`](./docs/development-guidelines.md) (Japanese, internal-facing).

---

## 📁 Repository layout

The top-level layout is summarized below. **The canonical source is [`docs/repository-structure.md`](./docs/repository-structure.md)**, which must be updated whenever a new directory is introduced.

```
rescript-tauri/
├── packages/         # @rescript-tauri/core, plugin-*, schema
├── examples/         # hello-world / window-management / ipc-typed / streaming-ipc
├── docs/             # Internal design docs (PRD, functional design, architecture, ...)
│   └── ideas/        # Drafts / RFCs (input only; not edited after acceptance)
├── sphinx-docs/      # External-facing docs (English base + Japanese via Sphinx i18n)
├── .steering/        # Per-task steering documents (requirements / design / tasklist)
├── .claude/          # Claude Code configuration (rules / skills / agents / commands)
├── .github/          # GitHub Actions / templates
├── CLAUDE.md         # Mandatory project instructions for Claude Code (Japanese)
└── README.md         # This file
```

---

## 📚 Documentation index

| Document | Contents | Language |
|---|---|---|
| [`docs/product-requirements.md`](./docs/product-requirements.md) | Product Requirements Document (personas, user stories, KPIs) | Japanese |
| [`docs/functional-design.md`](./docs/functional-design.md) | Functional design (per-module APIs and types) | Japanese |
| [`docs/architecture.md`](./docs/architecture.md) | Architecture and technical specification (design principles, 3-layer IPC, cross-cutting policies) | Japanese |
| [`docs/repository-structure.md`](./docs/repository-structure.md) | Repository structure (canonical source) | Japanese |
| [`docs/glossary.md`](./docs/glossary.md) | Ubiquitous-language glossary | Japanese |
| [`docs/ideas/RFC-0001-core-api-design.md`](./docs/ideas/RFC-0001-core-api-design.md) | Core API design RFC (historical input to the PRD; not edited) | English |
| [`CLAUDE.md`](./CLAUDE.md) | Mandatory instructions for Claude Code | Japanese |

External-facing user and contributor documentation lives in [`sphinx-docs/`](./sphinx-docs/) with English as the base language and Japanese translations provided through Sphinx i18n (`.po` files under `sphinx-docs/locale/ja/`). The site is built by [`.github/workflows/docs.yml`](./.github/workflows/docs.yml) and deployed to **GitHub Pages** at <https://nagatatz.github.io/rescript-tauri/> (English under `/en/`, Japanese under `/ja/`). The deployment workflow itself is active, but Pages goes live when the repository visibility is switched to public at the Phase 1 release (see the **Visibility** block above).

---

## 🤖 Claude Code conventions: rules / skills / agents / commands

This repository is configured for development with Claude Code. The `.claude/` directory contains four kinds of configuration:

| Kind | Location | Role | Activation |
|---|---|---|---|
| **rules** | `.claude/rules/` | Always-applied conventions. `@import`-ed from `CLAUDE.md`, enforced in every session. | Always (no manual trigger) |
| **skills** | `.claude/skills/` | Situational knowledge / workflows loaded automatically when conditions match. Can also be triggered explicitly with `/skill-name`. | Auto / explicit `/<name>` |
| **agents** | `.claude/agents/` | Specialized sub-agents (code-reviewer / debugger / build-resolver / security-reviewer / ...). Invoked through the Agent tool. | Agent tool |
| **commands** | `.claude/commands/` | Slash command definitions (`/setup-project`, `/add-feature`, ...). | `/<command>` |

The rule / skill / agent / command files themselves are intentionally kept in Japanese to match the primary working language for Claude Code in this project.

### Where to put new conventions

When introducing a new convention or workflow, choose its location in this priority order:

1. **Must be enforced in every session, without exception** → `rules/` (and `@import` it from `CLAUDE.md`).
2. **Should fire automatically in specific situations / on specific keywords** → `skills/`.
3. **Has a distinct role best handled by a dedicated sub-agent** → `agents/`.
4. **Needs an explicit entry point of the form `/xxx`** → `commands/`.

`rules` and `skills` are easily confused: "always applied" is `rules`; "applied when the situation arises" is `skills`. When in doubt, start in `skills/` and promote to `rules/` later if the scope grows.

### Key always-applied rules

| Rule | Contents |
|---|---|
| [`rules/testing.md`](./.claude/rules/testing.md) | Mandatory tests; self-verification flow |
| [`rules/code-comments.md`](./.claude/rules/code-comments.md) | Doc and inline comment conventions |
| [`rules/git-conventions.md`](./.claude/rules/git-conventions.md) | Emoji-prefixed commits, commit granularity, branch naming |
| [`rules/steering-workflow.md`](./.claude/rules/steering-workflow.md) | Steering documents and worktree workflow |
| [`rules/documentation.md`](./.claude/rules/documentation.md) | Roles of `docs/` vs `sphinx-docs/` |
| [`rules/definition-of-done.md`](./.claude/rules/definition-of-done.md) | Single Source of Truth for the Definition of Done (Phases 1–5) |
| [`rules/permission-modes.md`](./.claude/rules/permission-modes.md) | Plan Mode / steering / auto / sandbox split |

---

## 🤝 Contributing

External pull requests are not yet accepted while the project is in its design phase. Feedback on the design or RFCs is welcome through GitHub Issues. See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for how to engage today (issues only) and the future PR workflow that will apply once Phase 1 ships.

---

## 📜 License

[MIT](./LICENSE) © 2026 Nagatatz and rescript-tauri contributors.
