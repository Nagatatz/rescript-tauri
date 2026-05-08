# Building

All builds are driven through the `Makefile`. Run targets from the `sphinx-docs/` directory.

## Build commands

| Command | Description |
|---|---|
| `make install` | Install Python dependencies via `uv sync`. |
| `make html` | Build the English site → `_build/html/`. |
| `make build-ja` | Build the Japanese site (uses `-D language=ja`) → `_build/html_ja/`. |
| `make build-all` | Build EN + JA, assemble into `_build/site/{en,ja}/`, and run Pagefind. |
| `make gettext` | Extract translatable strings into `_build/gettext/*.pot`. |
| `make update-po` | Run `gettext`, then `sphinx-intl update -p _build/gettext -l ja`. Updates `.po` files in `locale/ja/LC_MESSAGES/`. |
| `make serve` | Build EN + JA + assemble + Pagefind, then serve `_build/site/` at `http://localhost:8000`. |
| `make liveserve` | Run `sphinx-autobuild` for the English site only (auto-rebuild on save). |
| `make linkcheck` | Validate all links → `_build/linkcheck/`. |
| `make pagefind` | Build the Pagefind search index for an existing `_build/site/`. |
| `make lint` | Run `ruff check` and `ruff format --check`. |
| `make test` | Run `pytest`. |
| `make check` | `lint` + `test`. |
| `make clean` | Remove `_build/`. |

## Output

| Path | Contents |
|---|---|
| `_build/html/` | English HTML (the default `make html` output, also used as the Pages-default `/en/`). |
| `_build/html_ja/` | Japanese HTML. |
| `_build/site/` | Assembled bilingual site with `/en/`, `/ja/`, root `index.html` (redirects to `/en/`), and Pagefind index. |
| `_build/gettext/` | `.pot` files extracted by `make gettext`. |
| `_build/linkcheck/` | `make linkcheck` results. |

## i18n round-trip

Whenever an English `.md` source changes, the round-trip is:

```bash
make update-po           # rebuilds .po files from current sources
# Edit msgstr in locale/ja/LC_MESSAGES/<file>.po
make build-ja            # verify Japanese build
make build-all           # final bilingual assembly
```

Empty `msgstr` entries in `.po` cause Sphinx to fall back to the English source string for that paragraph in the Japanese build, which is acceptable as a temporary state but should be filled in before release.

## CI Pipeline

The active workflow is [`.github/workflows/docs.yml`](https://github.com/Nagatatz/rescript-tauri/blob/main/.github/workflows/docs.yml). It triggers on push and PR for changes under `sphinx-docs/**` and on manual dispatch.

| Stage | Tool | Purpose |
|---|---|---|
| Install | `uv sync` | Install Python deps |
| Lint | `ruff check`, `ruff format --check` | Style |
| Test | `pytest` | Test suite under `sphinx-docs/tests/` |
| Build | `make build-all` (planned) | EN + JA + Pagefind |
| Deploy | GitHub Pages | Only on `main` branch |

The status of every workflow file (active / opt-in template / planned for Phase 1) is documented in [`.github/workflows/README.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/.github/workflows/README.md).

```{note}
GitHub Pages deployment is currently inactive because the repository is private (see the README "Visibility" block). Pages will be enabled at the Phase 1 release together with the visibility switch.
```
