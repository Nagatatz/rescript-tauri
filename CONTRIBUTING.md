# Contributing to rescript-tauri

Thank you for your interest in `rescript-tauri`! This document covers how to engage today and the workflow we will use once external pull requests are accepted.

---

## 1. Project status

`rescript-tauri` is in **Phase 1 — design complete, implementation not yet started**. The repository is currently **private**; external pull requests are **not yet accepted**. The visibility transition criteria are listed in the [README "Visibility" block](./README.md#-rescript-tauri).

What this means for you right now:

- **GitHub Issues are welcome** for design feedback, RFC discussion, and clarifying questions.
- Pull requests will be accepted once we ship Phase 1 (first `@rescript-tauri/core` npm release, examples on the 3 OS matrix, CI gates wired up).
- Until then, the "Future PR workflow" section below describes the workflow we plan to operate under, so you can familiarize yourself with the conventions in advance.

---

## 2. How you can help today

| Channel | Purpose |
|---|---|
| GitHub Issues | Design feedback, RFC discussion, clarifying questions, bug reports for the design docs themselves |
| Star / Watch | Be notified when Phase 1 ships and external PRs open |

Please file issues against the relevant document or design surface (PRD, functional design, RFC-0001, etc.) and link the specific section so we can ground the discussion.

---

## 3. Future PR workflow (post-Phase 1)

Once external PRs are accepted, the workflow below will apply. Each item links to the canonical convention (the Source of Truth lives in `.claude/rules/`, not here).

### 3.1 Branch naming

Branches are created from `main` with a typed prefix. See [`.claude/rules/git-conventions.md` §ブランチ命名規則](./.claude/rules/git-conventions.md).

| Prefix | Use |
|---|---|
| `feature/` | New feature |
| `fix/` | Bug fix |
| `refactor/` | Refactor (no behavior change) |
| `docs/` | Documentation only |
| `test/` | Test additions / fixes |
| `chore/` | Build / dependency / config |

### 3.2 Commit messages

Every commit message starts with an emoji prefix and an English verb, per [`.claude/rules/git-conventions.md` §コミットメッセージ](./.claude/rules/git-conventions.md). Examples:

- `✨ Add Window.setMinSize binding`
- `🐛 Fix Channel.id collision when reusing handles`
- `📝 Update Quick Start with the new Command.make signature`

Priority order when multiple emoji apply: ✨ > 🐛 > ♻️ > 📝 > 🎨 > ⚡ > 🔧 > ✅ > 🗑️.

### 3.3 PR scope and granularity

One logical change per PR. See [`.claude/rules/git-conventions.md` §コミット粒度](./.claude/rules/git-conventions.md). Implementation code, tests, and config registration for the same feature may live in one commit; documentation updates may be batched into one trailing doc commit if preferred.

### 3.4 Steering workflow for medium+ changes

Anything beyond a typo or a single-line config tweak goes through the steering workflow: a `.steering/[YYYYMMDD]-[NNN]-[title]/` directory with `requirements.md` / `design.md` / `tasklist.md`, each user-approved before the next, and implementation done inside an isolated worktree. See [`.claude/rules/steering-workflow.md`](./.claude/rules/steering-workflow.md).

The judgment between "Plan Mode" (lightweight) and "steering workflow" (heavyweight) is documented in [`.claude/rules/permission-modes.md`](./.claude/rules/permission-modes.md).

### 3.5 Required tests

Every code change requires accompanying tests. See [`.claude/rules/testing.md`](./.claude/rules/testing.md).

The project uses a **3-tier test strategy** (functional-design §5/§7):

1. **Type-level** — `packages/core/tests/*.res`. Compile success = pass. Enforces 100% public-symbol coverage.
2. **Runtime** — vitest under `packages/core/tests/runtime/`. encode/decode round-trip and `Mocks.mockIPC` integration.
3. **Integration** — `examples/*` builds on Linux / macOS / Windows.

A failing example build on any of the three OSes blocks release.

### 3.6 Required doc comments

Every public symbol in `.resi` requires a doc comment with a `See:` line linking to the corresponding Tauri documentation page. See [`.claude/rules/code-comments.md`](./.claude/rules/code-comments.md). The `doc-link-lint.yml` workflow (planned for Phase 1) verifies this with grep.

### 3.7 CI gates

The current state of every workflow file (active / opt-in template / planned for Phase 1) is documented in [`.github/workflows/README.md`](./.github/workflows/README.md). Once Phase 1 ships, every PR must clear:

- `build-core` (with a wall-clock budget per PRD §5.2)
- `tests-core-types` (100% public-symbol coverage)
- `tests-core-runtime` (vitest)
- `examples-build` (3 OS matrix)
- `doc-link-lint` (Tauri URL presence)

### 3.8 Definition of Done

Every PR is expected to satisfy the project's [Definition of Done](./.claude/rules/definition-of-done.md), which is the single source of truth for completion criteria across Phases 1–5.

---

## 4. Local development

The contributor-facing development guide (in Japanese, internal detail) is [`docs/development-guidelines.md`](./docs/development-guidelines.md). It covers the full development flow, local environment requirements, build / test commands, the recipe for adding a new module, coding patterns specific to this codebase, and the release outline.

For a quick start, the README's [Development setup](./README.md#-development-setup) section lists the essential commands.

---

## 5. Reporting bugs and feature requests

Please use **GitHub Issues** with the templates under `.github/ISSUE_TEMPLATE/`. Include:

- The version of `@rescript-tauri/core` you are using (once Phase 1 ships)
- The version of `@tauri-apps/api`, ReScript, and `@rescript/core`
- Operating system
- Minimal reproduction (a snippet or, ideally, a forkable example based on `examples/`)

For **security issues**, do not open a public Issue. A `SECURITY.md` with a private disclosure channel will be added at the Phase 1 release. Until then, please contact the maintainer through the email listed in the GitHub profile.

---

## 6. Code of Conduct

A `CODE_OF_CONDUCT.md` will be added at the Phase 1 release. Until then, contributors and reviewers are expected to act with respect, assume good faith, and keep technical discussion focused on the design and code at hand.

---

## 7. License

By contributing to `rescript-tauri`, you agree that your contributions are licensed under the [MIT License](./LICENSE).
