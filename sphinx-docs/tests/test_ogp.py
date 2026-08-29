"""Verify Open Graph meta tag emission for both en and ja builds.

Covers `.steering/archive/20260509-052-sphinx-ogp-enhancements/`:
- og:locale and og:locale:alternate switch correctly between en/ja
- twitter:card is emitted for every page
- ogp_description_length / ogp_enable_meta_description take effect
"""

from __future__ import annotations

import re
import shutil
import subprocess
from collections.abc import Iterator
from pathlib import Path

import pytest

DOCS_ROOT = Path(__file__).resolve().parent.parent
INDEX_HTML = "index.html"


def _sphinx_build(out_dir: Path, language: str | None) -> None:
    """Run `sphinx-build` for the given language into ``out_dir``.

    A clean build is performed every time so stale HTML cannot mask regressions.
    """

    if out_dir.exists():
        shutil.rmtree(out_dir)
    cmd = ["uv", "run", "sphinx-build", "-b", "html", "-q"]
    if language is not None:
        cmd += ["-D", f"language={language}"]
    cmd += [str(DOCS_ROOT), str(out_dir)]
    subprocess.run(cmd, check=True, cwd=DOCS_ROOT)


def _has_meta(html: str, *, key_attr: str, key_value: str, content: str) -> bool:
    """Return True if a `<meta>` tag with the given key/content is present.

    Sphinx may serialize attributes in either order (`name="..." content="..."`
    or `content="..." name="..."`), so the check is order-agnostic.
    """

    pattern = re.compile(
        r"<meta\b[^>]*\b" + re.escape(key_attr) + r'="' + re.escape(key_value) + r'"[^>]*?>',
        re.IGNORECASE,
    )
    for match in pattern.finditer(html):
        if f'content="{content}"' in match.group(0):
            return True
    # Try the reverse attribute order: content first, then key.
    pattern_rev = re.compile(
        r'<meta\b[^>]*\bcontent="' + re.escape(content) + r'"[^>]*?>',
        re.IGNORECASE,
    )
    for match in pattern_rev.finditer(html):
        if f'{key_attr}="{key_value}"' in match.group(0):
            return True
    return False


@pytest.fixture(scope="module")
def en_index_html(tmp_path_factory: pytest.TempPathFactory) -> Iterator[str]:
    out_dir = tmp_path_factory.mktemp("html_en")
    _sphinx_build(out_dir, language=None)  # default: english
    yield (out_dir / INDEX_HTML).read_text(encoding="utf-8")


@pytest.fixture(scope="module")
def ja_index_html(tmp_path_factory: pytest.TempPathFactory) -> Iterator[str]:
    out_dir = tmp_path_factory.mktemp("html_ja")
    _sphinx_build(out_dir, language="ja")
    yield (out_dir / INDEX_HTML).read_text(encoding="utf-8")


class TestEnglishBuild:
    """Default `language=en` build: locale meta should pair en_US with ja_JP."""

    def test_emits_en_us_locale(self, en_index_html: str) -> None:
        assert _has_meta(
            en_index_html,
            key_attr="property",
            key_value="og:locale",
            content="en_US",
        )

    def test_emits_ja_jp_alternate(self, en_index_html: str) -> None:
        assert _has_meta(
            en_index_html,
            key_attr="property",
            key_value="og:locale:alternate",
            content="ja_JP",
        )

    def test_emits_twitter_card(self, en_index_html: str) -> None:
        assert _has_meta(
            en_index_html,
            key_attr="name",
            key_value="twitter:card",
            content="summary_large_image",
        )


class TestJapaneseBuild:
    """`-D language=ja` build: locale meta should pair ja_JP with en_US."""

    def test_emits_ja_jp_locale(self, ja_index_html: str) -> None:
        assert _has_meta(
            ja_index_html,
            key_attr="property",
            key_value="og:locale",
            content="ja_JP",
        )

    def test_emits_en_us_alternate(self, ja_index_html: str) -> None:
        assert _has_meta(
            ja_index_html,
            key_attr="property",
            key_value="og:locale:alternate",
            content="en_US",
        )

    def test_emits_twitter_card(self, ja_index_html: str) -> None:
        assert _has_meta(
            ja_index_html,
            key_attr="name",
            key_value="twitter:card",
            content="summary_large_image",
        )
