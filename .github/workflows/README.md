# GitHub Actions workflows

This directory tracks the CI/CD workflows for rescript-tauri. Files fall into three categories: **active**, **opt-in templates**, and **planned for Phase 1**.

## Active workflows

| File | Trigger | Purpose |
|---|---|---|
| `docs.yml` | push / PR on `sphinx-docs/**`, manual dispatch | Lints `sphinx-docs/`, runs its tests, and (on `main`) deploys the rendered site to GitHub Pages. |
| `build-core.yml` | push / PR on `packages/core/**`, `pnpm-lock.yaml`, `package.json` | Cleans and rebuilds `@rescript-tauri/core` and emits a wall-clock notice (PRD §5.2 budget = 30s). |
| `tests-core-types.yml` | push / PR on `packages/core/**`, `pnpm-lock.yaml` | Compiles the type-level tests (`tests/*_signature.res`) and enforces 100% public-symbol coverage with a grep-based gate. |
| `tests-core-runtime.yml` | push / PR on `packages/core/**`, `pnpm-lock.yaml` | Runs `pnpm --filter @rescript-tauri/core test` (rescript build + vitest). |
| `doc-link-lint.yml` | push / PR on any `packages/core/**/*.resi` | Verifies that every `.resi` file mentions a `v2.tauri.app/` URL. |
| `examples-build.yml` | push / PR on `examples/**`, `packages/core/**`, `pnpm-lock.yaml` | 3 OS matrix (Ubuntu / macOS / Windows). Builds the `hello-world`, `window-management`, `ipc-typed`, and `streaming-ipc` ReScript frontends and runs `cargo check --release` on each Tauri Rust side. |
| `compat-tauri-latest.yml` | nightly (06:00 UTC) / manual dispatch | Pulls `@tauri-apps/api@latest` across every workspace and re-builds / tests `@rescript-tauri/core` + `hello-world`. Surfaces upstream API drift before users hit it (PRD §9 risk row 1). |
| `compat-rescript-prerelease.yml` | nightly (06:00 UTC) / manual dispatch | Pulls `rescript@next` and `rescript@beta` (skips cleanly when a dist-tag is undefined) and re-builds / tests `@rescript-tauri/core`. Catches ReScript 12.x next-minor / next-major drift early (PRD §9 risk row 3). |
| `release.yml` | tag push (`v*`) / manual dispatch | Builds + tests `@rescript-tauri/core`, then `npm publish --provenance` (only when the `NPM_TOKEN` secret is set; otherwise dry-run) and `gh release create --generate-notes`. |

## Opt-in templates

These workflows rely on Claude Code Actions and require an `ANTHROPIC_API_KEY` repository secret. They are kept inert by default (suffixed `.template`) so that forks or fresh clones do not unintentionally consume API credit. To enable, rename the file (drop `.template`) and configure the secret with `gh secret set ANTHROPIC_API_KEY`.

| File | Activation | Purpose |
|---|---|---|
| `auto-pr-description.yml.template` | `mv auto-pr-description.yml.template auto-pr-description.yml` | Generates PR descriptions from the diff via `claude -p`. |
| `claude-code-review.yml.template` | `mv claude-code-review.yml.template claude-code-review.yml` | Posts automated diff review comments via the Claude Code Action. |

## Adding a new workflow

1. Place the YAML in this directory.
2. Document the file in this README under the appropriate section.
3. If it depends on a Claude Code Action or any external secret, suffix the filename with `.template` and add an opt-in note describing the required secrets.
4. Update [`docs/repository-structure.md`](../../docs/repository-structure.md) §8 when the workflow set changes meaningfully.
