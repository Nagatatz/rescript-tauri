# Configuration file for the Sphinx documentation builder.
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys

# Make project-local Sphinx extensions importable (rescript_lexer lives here).
sys.path.insert(0, os.path.abspath("_ext"))

project = "rescript-tauri"
copyright = "2026, Nagatatz and rescript-tauri contributors"
author = "Nagatatz and rescript-tauri contributors"

# -- General configuration ---------------------------------------------------

extensions = [
    "myst_parser",
    "sphinx_copybutton",
    "sphinx_design",
    "sphinxext.opengraph",
    "sphinx_sitemap",
    "notfound.extension",
    "sphinx_tippy",
    "sphinx_last_updated_by_git",
    "sphinx_llms_txt",
    "sphinxcontrib.budoux",
    "atsphinx.htmx_boost",
    "rescript_lexer",
]

# MyST Parser settings
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "fieldlist",
    "attrs_inline",
    "substitution",
]

# Shared MyST substitutions reused across plugin user guides. The
# `phase_2_note` text appears verbatim inside an admonition on every
# `sphinx-docs/user/plugin-*.md` page; centralising it here means a
# single edit covers all guides when the package set ships to npm.
myst_substitutions = {
    "phase_2_note": (
        "This package is feature-complete in `main`. Its first npm publish "
        "is scheduled alongside the other packages. Until then, consume it "
        "via the source repository or a workspace link."
    ),
}

# Source file suffixes
source_suffix = {
    ".md": "markdown",
}

# The master toctree document
master_doc = "index"

# Exclude patterns
exclude_patterns = ["_build", ".venv", ".pytest_cache", "Thumbs.db", ".DS_Store"]

# -- Internationalization ----------------------------------------------------

language = "en"
locale_dirs = ["locale/"]
gettext_compact = False  # One .po file per source document

# -- HTML output -------------------------------------------------------------

html_theme = "furo"

html_theme_options = {
    "sidebar_hide_name": False,
    "navigation_with_keys": True,
    "top_of_page_button": "edit",
    "source_repository": "https://github.com/Nagatatz/rescript-tauri",
    "source_branch": "main",
    "source_directory": "sphinx-docs/",
    "footer_icons": [
        {
            "name": "GitHub",
            "url": "https://github.com/Nagatatz/rescript-tauri",
            "html": '<svg stroke="currentColor" fill="currentColor" stroke-width="0" '
            'viewBox="0 0 16 16"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 '
            "3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37"
            "-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 "
            "1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64"
            "-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 "
            "2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82"
            ".44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95"
            ".29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013"
            ' 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>',
            "class": "",
        },
    ],
}

html_static_path = ["_static"]
html_css_files = ["css/custom.css"]
templates_path = ["_templates"]

# Site prefix for GitHub Pages (e.g., "/my-project")
# Set SPHINX_SITE_PREFIX env var for deployment; empty for local dev.
html_context = {
    "site_prefix": os.environ.get("SPHINX_SITE_PREFIX", ""),
}

# Pagefind search page (replaces default Sphinx search)
html_additional_pages = {"search": "search.html"}

# -- Open Graph (social sharing previews) -----------------------------------

# GitHub Pages base URL. The deployed site lives under /en/ and /ja/ via build-all
# (see Makefile). `html_baseurl` and `ogp_site_url` are finalized per-build in
# `setup()` so canonical URLs, sitemap entries, and og:url all carry the locale
# segment that matches where the page is actually deployed.
html_baseurl = "https://nagatatz.github.io/rescript-tauri/"
ogp_site_url = html_baseurl
ogp_site_name = "rescript-tauri"
ogp_type = "website"

# Description length for social previews (default 200; expanded for richer cards).
ogp_description_length = 300
ogp_enable_meta_description = True

# Static custom meta tags. og:locale[:alternate] are appended dynamically in
# setup() because `make build-ja` overrides `language` via `-D language=ja`
# after this file is evaluated.
ogp_custom_meta_tags = [
    '<meta name="twitter:card" content="summary_large_image" />',
]

# -- Sitemap (SEO) -----------------------------------------------------------

sitemap_url_scheme = "{link}"
sitemap_locales = ["en", "ja"]

# -- 404 page ----------------------------------------------------------------

notfound_urls_prefix = os.environ.get("SPHINX_SITE_PREFIX", "") + "/en/"

# -- Tooltip previews (sphinx-tippy) -----------------------------------------

tippy_anchor_parent_selector = "div.content"
tippy_enable_mathjax = False

# -- Last updated by git -----------------------------------------------------

git_last_updated_timezone = "Asia/Tokyo"

# -- LLM documentation (llms.txt) --------------------------------------------

# URI template uses html_baseurl automatically; no override needed

# -- BudouX (Japanese line breaking) -----------------------------------------

budoux_targets = ["h1", "h2", "h3"]

# -- HTMX Boost (SPA-like page transitions) ----------------------------------

htmx_boost_preload = "mouseover"

# Suppress toctree warnings for locale files
suppress_warnings = ["toc.excluded"]

# -- Link check --------------------------------------------------------------

# The repository is private until the initial release (see README "Visibility").
# Anonymous GitHub fetches return 404 for blob/tree/issues URLs while the repo
# is private. Ignore them in `make linkcheck` and remove this entry once the
# repo is switched to public.
linkcheck_ignore = [
    r"^https://github\.com/Nagatatz/rescript-tauri/(blob|tree|issues|graphs)(/.*)?$",
]


# -- Dynamic per-locale config finalization ----------------------------------


def setup(app):
    """Finalize config that depends on the resolved `language` at build time.

    `make build-ja` overrides the Sphinx `language` config via `-D language=ja`,
    so anything derived from `language` (og:locale, canonical baseurl, og:url)
    must be computed at config-inited time rather than at conf.py module load.
    """

    _OGP_LOCALE_MAP = {
        "en": ("en_US", "ja_JP"),
        "ja": ("ja_JP", "en_US"),
    }
    _BASE_URL = "https://nagatatz.github.io/rescript-tauri/"

    def _finalize_config(_app, config):
        primary, alternate = _OGP_LOCALE_MAP.get(config.language, ("en_US", "ja_JP"))
        config.ogp_custom_meta_tags = list(config.ogp_custom_meta_tags) + [
            f'<meta property="og:locale" content="{primary}" />',
            f'<meta property="og:locale:alternate" content="{alternate}" />',
        ]
        # build-all deploys EN under /en/ and JA under /ja/, so the absolute URLs
        # Sphinx emits (canonical <link>, sitemap.xml, og:url) must include the
        # locale segment to match where each page is actually served.
        config.html_baseurl = f"{_BASE_URL}{config.language}/"
        config.ogp_site_url = config.html_baseurl

    app.connect("config-inited", _finalize_config)
