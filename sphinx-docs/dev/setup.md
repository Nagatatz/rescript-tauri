# Development Setup

Set up the `sphinx-docs/` site locally so you can preview English and Japanese builds before opening a PR.

## Prerequisites

| Requirement | Version | Note |
|---|---|---|
| [uv](https://docs.astral.sh/uv/) | 0.5+ | Python パッケージ管理・仮想環境 |
| Python | 3.12+ | uv が自動でセットアップ |
| Node.js | 24+ | Pagefind 検索インデックス生成に使用 |

The rest of the rescript-tauri toolchain (pnpm, ReScript 12, etc.) is **not** required to work on `sphinx-docs/` alone.

### Install uv

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Homebrew
brew install uv
```

## Clone the repository

```bash
git clone https://github.com/Nagatatz/rescript-tauri.git
cd rescript-tauri/sphinx-docs
```

## Install dependencies

```bash
make install    # uv sync (Python deps); npx will fetch Pagefind on first build
```

## Verify the setup

```bash
make html       # English HTML build → _build/html/
make serve      # Build EN+JA, assemble, and serve at localhost:8000
```

`make liveserve` starts `sphinx-autobuild` for auto-reload during English-only iterations.

## Where files live

| Path | Role |
|---|---|
| `conf.py` | Sphinx configuration (theme, extensions, i18n, OpenGraph, Pagefind) |
| `pyproject.toml` | Python dependency manifest for uv |
| `Makefile` | All build targets (see [Building](building.md)) |
| `index.md`, `user/`, `dev/` | English source documents |
| `locale/ja/LC_MESSAGES/` | Japanese `.po` files (one per source `.md`) |
| `_static/`, `_templates/` | Theme overrides and assets |
| `_build/` | Build output (gitignored) |
