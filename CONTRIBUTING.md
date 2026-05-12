# Contributing to rescript-tauri

Thank you for your interest in `rescript-tauri`! This document covers the branch / commit / steering / CI conventions every external PR is expected to follow.

---

## 1. Project status

Phase 1 + Phase 2 implementations are merged on `main` (core, plugin-fs, plugin-dialog, schema, seven examples, CI matrices, release runbook, Sphinx docs). The packages are awaiting their first npm publish on the `v0.1.0` track.

The repository is **public** and external pull requests are accepted. GitHub Issues remain the right channel for design feedback, RFC discussion, and clarifying questions.

---

## 2. How you can help

| Channel | Purpose |
|---|---|
| GitHub Pull Requests | Code, docs, examples, CI improvements |
| GitHub Issues | Bug reports, design feedback, RFC discussion, clarifying questions |

Please link the specific PRD / functional-design / RFC section in your issue or PR description so the discussion stays grounded in the canonical documents.

---

## 3. PR workflow

Each item links to the canonical convention (the Source of Truth lives in `.claude/rules/`, not here).

**All changes — from external contributors and maintainers alike — land on `main` through a pull request.** The `main` branch is protected by GitHub branch protection (steering [20260512-006](./.steering/20260512-006-protect-main-branch/)): direct push is rejected with `GH006: Protected branch update failed`, force-push and branch deletion are blocked, and admins are not allowed to bypass. The PR review count requirement is `0`, so maintainers can self-merge their own PRs (used for solo-dev iteration), but every change still flows through a PR record.

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

Every public symbol in `.resi` requires a doc comment with a `See:` line linking to the corresponding Tauri documentation page. See [`.claude/rules/code-comments.md`](./.claude/rules/code-comments.md). The `doc-link-lint.yml` workflow verifies this with grep.

### 3.7 CI gates

Every PR must clear the workflows catalogued in [`.github/workflows/README.md`](./.github/workflows/README.md):

- `build-core` (with a wall-clock budget per PRD §5.2)
- `tests-core-types` / `tests-schema-types` / `tests-plugin-fs-types` / `tests-plugin-dialog-types` (100% public-symbol coverage per package)
- `tests-core-runtime` / `tests-schema-runtime` / `tests-plugin-fs-runtime` / `tests-plugin-dialog-runtime` (vitest)
- `tests-coverage` (matrix coverage observation; non-gating in the current phase)
- `examples-build` (3 OS matrix across all 7 examples)
- `doc-link-lint` (Tauri URL presence)
- `lint-format` (Biome on hand-written `.mjs` / JSON)
- `docs` (Sphinx EN+JA build)

Nightly: `compat-tauri-latest` and `compat-rescript-prerelease` exercise upstream drift detection.

### 3.8 Definition of Done

Every PR is expected to satisfy the project's [Definition of Done](./.claude/rules/definition-of-done.md), which is the single source of truth for completion criteria across Phases 1–5.

### 3.9 Merging into `main` (maintainers)

Branch protection means even maintainers cannot push directly to `main`. The canonical merge path is `gh pr merge <PR> --merge --delete-branch` (the `--merge` strategy is enforced to preserve the existing `--no-ff` history; `--squash` and `--rebase` are not used). The full worktree → push → PR → self-merge → cleanup recipe lives in [`.claude/rules/steering-workflow.md` §worktree から main への反映手順](./.claude/rules/steering-workflow.md). External contributors do not need to run this — the maintainer handles the merge after review.

---

## 4. Local development

The contributor-facing development guide (in Japanese, internal detail) is [`docs/development-guidelines.md`](./docs/development-guidelines.md). It covers the full development flow, local environment requirements, build / test commands, the recipe for adding a new module, coding patterns specific to this codebase, and the release outline.

For a quick start, the README's [Development setup](./README.md#-development-setup) section lists the essential commands.

---

## 5. Reporting bugs and feature requests

Please use **GitHub Issues** with the templates under `.github/ISSUE_TEMPLATE/`. Include:

- The version of `@rescript-tauri/core` you are using (once `0.1.0` ships; until then, the commit SHA on `main`)
- The version of `@tauri-apps/api`, ReScript, and `@rescript/core`
- Operating system
- Minimal reproduction (a snippet or, ideally, a forkable example based on `examples/`)

For **security issues**, do not open a public Issue. See [`SECURITY.md`](./SECURITY.md) for the private disclosure channel (GitHub Security Advisories as the primary path, with an email fallback) and the project's response timeline and disclosure policy.

---

## 6. Code of Conduct

Contributors and reviewers follow the [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md) (Contributor Covenant 2.1). Reports of behavior that violates the Code of Conduct go to the maintainer contact listed in that document.

---

## 7. License

By contributing to `rescript-tauri`, you agree that your contributions are licensed under the [MIT License](./LICENSE).
