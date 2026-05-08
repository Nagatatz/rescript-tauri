# GitHub Actions workflows

This directory tracks the CI/CD workflows for rescript-tauri. Files fall into three categories: **active**, **opt-in templates**, and **planned for Phase 1**.

## Active workflows

| File | Trigger | Purpose |
|---|---|---|
| `docs.yml` | push / PR on `sphinx-docs/**`, manual dispatch | Lints `sphinx-docs/`, runs its tests, and (on `main`) deploys the rendered site to GitHub Pages. |

## Opt-in templates

These workflows rely on Claude Code Actions and require an `ANTHROPIC_API_KEY` repository secret. They are kept inert by default (suffixed `.template`) so that forks or fresh clones do not unintentionally consume API credit. To enable, rename the file (drop `.template`) and configure the secret with `gh secret set ANTHROPIC_API_KEY`.

| File | Activation | Purpose |
|---|---|---|
| `auto-pr-description.yml.template` | `mv auto-pr-description.yml.template auto-pr-description.yml` | Generates PR descriptions from the diff via `claude -p`. |
| `claude-code-review.yml.template` | `mv claude-code-review.yml.template claude-code-review.yml` | Posts automated diff review comments via the Claude Code Action. |

## Planned for Phase 1

The workflows below are specified in [`docs/functional-design.md`](../../docs/functional-design.md) §6. They do not exist yet and will be added once `packages/core/` source code lands.

| File | Purpose |
|---|---|
| `build-core.yml` | Builds `@rescript-tauri/core` on PR / push with a wall-clock budget. |
| `tests-core-types.yml` | Type-level tests (compile-success based). Enforces 100% public-symbol coverage via a grep-based gate. |
| `tests-core-runtime.yml` | Vitest runtime tests, including the `Mocks` integration scenario. |
| `examples-build.yml` | Builds every `examples/*` on a 3 OS matrix (Linux / macOS / Windows). |
| `doc-link-lint.yml` | Validates Tauri documentation URLs embedded in `.resi` doc comments. |
| `compat-tauri-latest.yml` | Nightly compatibility run against the latest Tauri release. |
| `compat-rescript-prerelease.yml` | Nightly compatibility run against the next ReScript 12.x minor / next-major prerelease line. |
| `release.yml` | Tag-driven release pipeline (npm publish + GitHub Release). |

## Adding a new workflow

1. Place the YAML in this directory.
2. Document the file in this README under the appropriate section.
3. If it depends on a Claude Code Action or any external secret, suffix the filename with `.template` and add an opt-in note describing the required secrets.
4. Update [`docs/repository-structure.md`](../../docs/repository-structure.md) §8 when the workflow set changes meaningfully.
